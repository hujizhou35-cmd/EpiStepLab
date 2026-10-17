"""Stage and run existing synthetic checks only. Windows rerun route; no third-party packages."""
from pathlib import Path
import argparse, csv, hashlib, json, os, shutil, subprocess, sys

ROOT=Path(__file__).resolve().parents[2]

def run(version,rscript,output):
    if os.name!='nt':raise RuntimeError('Original rerun route is Windows; other OS execution is unverified.')
    output=output.resolve()
    allowed=(ROOT/'.test-runs').resolve()
    if allowed not in output.parents:raise ValueError('Choose a fresh directory under this checkout .test-runs/')
    if output.exists():raise FileExistsError('Refusing to overwrite a previous run')
    rscript=shutil.which(str(rscript)) or str(rscript)
    if not Path(rscript).is_file():raise FileNotFoundError('Pass an available Rscript executable')
    output.mkdir(parents=True);tmp=output/'tmp_r';tmp.mkdir()
    env=dict(os.environ);env.update(TMP='./tmp_r',TEMP='./tmp_r',TMPDIR='./tmp_r',LC_ALL='English_United States.utf8')
    mapped=None;before=subprocess.check_output(['subst'],text=True)
    sources=ROOT/f'development/tests/v{version}/sources'
    steps=[]
    def command(args,log):
        with log.open('wb') as stream:
            result=subprocess.run([rscript,'--vanilla',*map(str,args)],cwd=output,env=env,stdout=stream,stderr=subprocess.STDOUT)
        return result.returncode
    try:
        # Preserve original test cwd behavior while giving R a no-space temporary path.
        for letter in 'ZYXWVUTSR':
            alias=letter+':'
            if not Path(alias+'/').exists():
                subprocess.run(['subst',alias,str(output)],check=True,capture_output=True)
                mapped=alias;env.update(TMP=alias+'/tmp_r',TEMP=alias+'/tmp_r',TMPDIR=alias+'/tmp_r');break
        if mapped is None:raise RuntimeError('No free temporary drive alias; no R tests executed.')
        probe=output/'temporary-directory.txt'
        if command(['-e','cat(normalizePath(tempdir(), winslash="/", mustWork=TRUE))'],probe):raise RuntimeError('R temporary-directory probe failed')
        actual_tmp=probe.read_text(encoding='utf-8',errors='replace').strip()
        if not any(actual_tmp.lower().startswith(prefix.lower()) for prefix in [mapped+'/tmp_r/',output.as_posix()+'/tmp_r/']):raise RuntimeError('R temporary files left the selected run directory')
        if version=='1.0.0':
            technical=output/'validation/technical';technical.mkdir(parents=True)
            for p in sources.iterdir():shutil.copyfile(p,technical/p.name)
            manifest=json.loads((ROOT/'docs/provenance/runtime-v1.0.0.json').read_text(encoding='utf-8'))
            for row in manifest['files']:
                if row['public'].endswith('.R'):
                    src=ROOT/row['public'];assert hashlib.sha256(src.read_bytes()).hexdigest()==row['sha256']
                    dst=output/row['source'];dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,dst)
            code=command([technical/'run_technical_tests.R',output],output/'technical-run.txt')
            if code:raise RuntimeError('Original 17-scenario runner failed; inspect saved log')
            rows=list(csv.DictReader((technical/'technical_results.csv').open(encoding='utf-8-sig')))
            assert len(rows)==17 and all(list(x.values())[3]=='TRUE' for x in rows)
            result={'version':version,'technical_scenarios':len(rows),'passed':True}
        else:
            # Fixture generator requires a nonexistent directory; logs remain in its parent.
            runroot=output/'method-cases'
            if command([sources/'generate_fixtures.R',sources,runroot],output/'fixture-generation.txt'):raise RuntimeError('Fixture generator failed')
            rows=list(csv.DictReader((runroot/'cases.csv').open(encoding='utf-8-sig')))
            for row in rows:
                step=runroot/row['case'];code=command([step/'本步分析.R'],step/'运行日志.txt')
                expected=row['expected_success']=='TRUE';outputs=list(step.glob('输出_*'))
                message=True if expected else row['expected_message'] in (step/'运行日志.txt').read_text(encoding='utf-8',errors='replace')
                ok=(code==0 and bool(outputs)) if expected else (code!=0 and not outputs and message)
                steps.append({'Case':row['case'],'ExpectedSuccess':expected,'ExitCode':code,'MessageMatched':message,'OutputCount':len(outputs),'Pass':ok})
            with (output/'process_checks.csv').open('w',encoding='utf-8',newline='') as f:
                writer=csv.DictWriter(f,fieldnames=list(steps[0]));writer.writeheader();writer.writerows(steps)
            if not all(x['Pass'] for x in steps):raise RuntimeError('Process scenario mismatch')
            if command([sources/'audit_results.R',runroot],output/'numeric-audit.txt'):raise RuntimeError('Numeric audit failed')
            numeric=list(csv.DictReader((runroot/'audit/numeric_checks.csv').open(encoding='utf-8-sig')))
            assert len(numeric)==26 and all(x['pass']=='TRUE' for x in numeric)
            result={'version':version,'process_scenarios':len(steps),'successful_methods':sum(x['ExpectedSuccess'] for x in steps),'refusals':sum(not x['ExpectedSuccess'] for x in steps),'numeric_checks':len(numeric),'passed':True}
    finally:
        if mapped:subprocess.run(['subst',mapped,'/D'],check=True,capture_output=True)
        after=subprocess.check_output(['subst'],text=True)
        restored=before==after
        (output/'restoration.json').write_text(json.dumps({'drive_mappings_restored':restored,'parent_environment_changed':False,'temporary_files_under_run_directory':True},indent=2)+'\n',encoding='utf-8')
        if not restored:raise RuntimeError('Drive mappings did not restore')
    (output/'summary.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8');print(json.dumps(result))

if __name__=='__main__':
    ap=argparse.ArgumentParser();ap.add_argument('--version',choices=['1.0.0','1.1.0'],required=True);ap.add_argument('--rscript',required=True);ap.add_argument('--output',type=Path,required=True)
    a=ap.parse_args();run(a.version,a.rscript,a.output)
