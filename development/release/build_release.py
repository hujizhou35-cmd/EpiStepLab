"""Build three deterministic downloads from this checkout, without external dependencies."""
from pathlib import Path
import argparse, hashlib, io, json, shutil, zipfile

ROOT = Path(__file__).resolve().parents[2]

def digest(data): return hashlib.sha256(data).hexdigest()

def archive(entries):
    output=io.BytesIO()
    with zipfile.ZipFile(output,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=9) as z:
        for name,data in sorted(entries):
            info=zipfile.ZipInfo(name,(2026,10,17,0,0,0))
            info.compress_type=zipfile.ZIP_DEFLATED
            info.external_attr=0o100644 << 16
            info.create_system=3
            z.writestr(info,data,compresslevel=9)
    return output.getvalue()

def build(out):
    plugin=json.loads((ROOT/'.codex-plugin/plugin.json').read_text(encoding='utf-8'))
    v=plugin['version']; skill=ROOT/'skills/episteplab'
    manifest=json.loads((ROOT/f'docs/provenance/runtime-v{v}.json').read_text(encoding='utf-8'))
    runtime=[]
    for row in manifest['files']:
        p=ROOT/row['public']; data=p.read_bytes()
        if digest(data)!=row['sha256']: raise ValueError('Runtime differs from preserved version: '+row['public'])
        runtime.append((p.relative_to(skill).as_posix(),data))
    actual={p.relative_to(skill).as_posix() for p in skill.rglob('*') if p.is_file()}
    if actual!={name for name,_ in runtime}: raise ValueError('Unexpected or missing runtime file')
    license_data=(ROOT/'LICENSE').read_bytes()
    complete=archive([('episteplab/'+n,d) for n,d in runtime]+[('episteplab/LICENSE',license_data)])
    plugin_entries=[('skills/episteplab/'+n,d) for n,d in runtime]
    plugin_entries += [('.codex-plugin/plugin.json',(ROOT/'.codex-plugin/plugin.json').read_bytes()),('LICENSE',license_data)]
    icon_paths={plugin['interface'][k].removeprefix('./') for k in ['composerIcon','logo']}
    plugin_entries += [(n,(ROOT/n).read_bytes()) for n in sorted(icon_paths)]
    products={f'episteplab-v{v}.skill':complete,f'episteplab-codex-plugin-v{v}.zip':archive(plugin_entries),'SKILL.md':(skill/'SKILL.md').read_bytes()}
    out=out.resolve(); out.mkdir(parents=True,exist_ok=True)
    rows=[]
    for name,data in products.items():
        p=out/name
        if p.exists() and p.read_bytes()!=data: raise FileExistsError('Refusing to replace different bytes: '+name)
        if not p.exists():p.write_bytes(data)
        rows.append({'name':name,'bytes':len(data),'sha256':digest(data)})
    record={'version':v,'runtime_files':len(runtime),'assets':rows,'format':'complete skill ZIP, Codex compatibility plugin ZIP, entrypoint preview'}
    (out/'manifest.json').write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8')
    return record

if __name__=='__main__':
    ap=argparse.ArgumentParser();ap.add_argument('--output',type=Path,default=ROOT/'.build/release')
    args=ap.parse_args();print(json.dumps(build(args.output),indent=2))
