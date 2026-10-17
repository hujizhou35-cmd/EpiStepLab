"""Static release checks. Never treats format checks as scientific validation."""
from pathlib import Path, PurePosixPath
import argparse, ast, hashlib, json, re, subprocess, sys, tempfile, urllib.parse, zipfile

ROOT=Path(__file__).resolve().parents[2]

def main(smoke=False):
    errors=[];count=0
    files=[p for p in ROOT.rglob('*') if p.is_file() and not any(x in p.relative_to(ROOT).parts for x in ['.git','.build','.test-runs','__pycache__'])]
    top={p.name for p in ROOT.iterdir() if p.name not in ['.git','.build','.test-runs','__pycache__']}
    expected={'README.md','LICENSE','CITATION.cff','.gitignore','.gitattributes','.codex-plugin','.github','skills','docs','development'}
    if top!=expected:errors.append('Unexpected root entries: '+str(top ^ expected))
    plugin=json.loads((ROOT/'.codex-plugin/plugin.json').read_text(encoding='utf-8'))
    version=plugin['version'];manifest=json.loads((ROOT/f'docs/provenance/runtime-v{version}.json').read_text(encoding='utf-8'))
    for row in manifest['files']:
        p=ROOT/row['public']
        if not p.is_file() or hashlib.sha256(p.read_bytes()).hexdigest()!=row['sha256']:errors.append('Runtime mismatch '+row['public'])
    actual={p.relative_to(ROOT).as_posix() for p in (ROOT/'skills/episteplab').rglob('*') if p.is_file()}
    if actual!={x['public'] for x in manifest['files']}:errors.append('Runtime set mismatch')
    entry=(ROOT/'skills/episteplab/SKILL.md').read_text(encoding='utf-8-sig')
    if not entry.startswith('---\n') or not re.search(r'^name: episteplab$',entry,re.M):errors.append('Skill frontmatter identity')
    for field in ['name','version','description','author','interface','skills']:
        if field not in plugin:errors.append('Missing plugin field '+field)
    if plugin.get('name')!='episteplab' or plugin.get('skills')!='./skills/':errors.append('Plugin identity/path')
    for field in ['displayName','shortDescription','longDescription','developerName','category','capabilities','logo','composerIcon']:
        if field not in plugin['interface']:errors.append('Missing plugin UI '+field)
    for k in ['logo','composerIcon']:
        if not (ROOT/plugin['interface'][k]).is_file():errors.append('Missing icon')
    for p in files:
        rel=p.relative_to(ROOT).as_posix()
        if p.is_symlink():errors.append('Symlink '+rel)
        if p.suffix.lower() in ['.py','.r','.md','.txt','.json','.yml','.yaml','.cff','.svg','.csv','.gitattributes','.gitignore'] or p.name in ['LICENSE','.gitattributes','.gitignore']:
            try:text=p.read_text(encoding='utf-8-sig')
            except UnicodeDecodeError:errors.append('Encoding '+rel);continue
            for pattern in [r'(?<![A-Za-z])[A-Z]:[\\/]',r'(?i)(?:thread|codex)://[0-9a-z]',r'gh[pousr]_[A-Za-z0-9]{25,}',r'sk-[A-Za-z0-9]{25,}',r'-----BEGIN [A-Z ]*PRIVATE KEY']:
                if re.search(pattern,text):errors.append('Private path/token pattern '+rel)
            if p.suffix=='.py':
                try:ast.parse(text)
                except SyntaxError as e:errors.append('Python syntax '+rel+':'+str(e.lineno))
        if p.suffix.lower()=='.md':
            # Markdown code fences may contain bracketed text that is not a link.
            body=re.sub(r'```.*?```','',text,flags=re.S)
            for target in re.findall(r'!?\[[^\]]*\]\(([^)]+)\)',body):
                target=target.strip().strip('<>');part=urllib.parse.urlsplit(target)
                if part.scheme or not part.path:continue
                dst=(p.parent/urllib.parse.unquote(part.path)).resolve()
                if ROOT.resolve() not in dst.parents and dst!=ROOT.resolve():errors.append('Link escapes repo '+rel)
                elif not dst.exists():errors.append('Broken link '+rel+' -> '+target)
                elif part.fragment and dst.suffix=='.md':
                    titles=re.findall(r'^#{1,6}\s+(.+)$',dst.read_text(encoding='utf-8-sig'),re.M)
                    slugs=[re.sub(r'[^\w\- ]','',t.lower()).replace(' ','-') for t in titles]
                    if urllib.parse.unquote(part.fragment) not in slugs:errors.append('Broken anchor '+rel+' -> '+target)
                if p.is_relative_to(ROOT/'skills') and not dst.is_relative_to(ROOT/'skills/episteplab'):errors.append('Skill link outside its folder '+rel)
                count+=1
    mapping=json.loads((ROOT/'docs/provenance/public-materials.json').read_text(encoding='utf-8'))
    for row in mapping['files']:
        p=ROOT/row['public']
        if not p.is_file() or hashlib.sha256(p.read_bytes()).hexdigest()!=row['sha256']:errors.append('Public material mapping differs: '+row['public'])
    if smoke:
        output=ROOT/'.build/check-release'/('v'+version)
        subprocess.run([sys.executable,str(ROOT/'development/release/build_release.py'),'--output',str(output)],check=True,stdout=subprocess.DEVNULL)
        for p in output.iterdir():
            if p.suffix not in ['.zip','.skill']:continue
            with zipfile.ZipFile(p) as z:
                if z.testzip():errors.append('ZIP CRC '+p.name)
                names=z.namelist()
                if len(names)!=len(set(names)):errors.append('Duplicate ZIP members')
                for name in names:
                    path=PurePosixPath(name)
                    if path.is_absolute() or '..' in path.parts or '\\' in name:errors.append('Unsafe ZIP member')
                prefix='episteplab/' if p.suffix=='.skill' else 'skills/episteplab/'
                for row in manifest['files']:
                    name=prefix+row['public'].removeprefix('skills/episteplab/')
                    if hashlib.sha256(z.read(name)).hexdigest()!=row['sha256']:errors.append('Archive runtime mismatch')
    if errors:
        print('\n'.join(errors));return 1
    print(json.dumps({'passed':True,'version':version,'files':len(files),'local_links':count,'runtime_files':len(manifest['files']),'root_entries':len(top),'build_smoke':smoke}));return 0

if __name__=='__main__':
    ap=argparse.ArgumentParser();ap.add_argument('--build-smoke',action='store_true');sys.exit(main(ap.parse_args().build_smoke))
