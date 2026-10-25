import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
assert.equal(process.env.GITHUB_ACTIONS,'true');assert.equal(process.platform,'linux');
const p=JSON.parse(readFileSync('reviewed-source.json'));
assert.equal(p.base,'9ea8d717ad91f3e93112d5d22bb2a7150df4c85c');
const run=(name,args)=>execFileSync(name,args,{encoding:'utf8',maxBuffer:64e6,stdio:['pipe','pipe','pipe']});
assert.equal(run('calcit',['-v']).trim(),'0.30.1');
const norm=v=>Array.isArray(v)?v.map(norm):v&&typeof v==='object'?Object.fromEntries(Object.entries(v).map(([k,x])=>[k,k==='__edn_set'?x.map(norm).sort((a,b)=>JSON.stringify(a).localeCompare(JSON.stringify(b))):norm(x)])):v;
const query=(...args)=>{const r=JSON.parse(run('calcit',['calcit.cirru','query',...args,'--format','json']));assert.ok(!r.diagnostics?.some(d=>d.severity==='error'));return norm(r.data);};
function views(){
 const namespaces=[],defs=[];
 for(const n of query('ns').namespaces){
  const info=query('ns',n);namespaces.push(info);
  const names=run('calcit',['calcit.cirru','query','defs',n]).split('\n').filter(l=>/^  \S/.test(l)).map(l=>l.trim().split(' ')[0]);assert.equal(names.length,info.definition_count);
  for(const d of names)defs.push(query('def',n+'/'+d));
 }
 return {config:query('config'),namespaces,defs};
}
const after=structuredClone(norm(p.before)),sites=[],aliases={'option:unwrap':'.unwrap','option:unwrap-or':'.unwrap-or'};
function migrate(node,path,id){
 if(!Array.isArray(node)||['quote','quasiquote',';','comment'].includes(node[0]))return;
 if(Object.hasOwn(aliases,node[0])){const before=node[0];assert.equal(node.length,before==='option:unwrap'?2:3);sites.push({id,path,before,after:aliases[before]});node[0]=aliases[before];}
 node.forEach((x,i)=>{assert.ok(!Object.hasOwn(aliases,x),'unexpected binding/reference requires manual review');migrate(x,[...path,i],id);});
}
for(const d of after.defs){assert.notEqual(d.code[0],'defmacro');migrate(d.code,[],d.id);}
assert.equal(sites.filter(s=>s.before==='option:unwrap').length,4);assert.equal(sites.filter(s=>s.before==='option:unwrap-or').length,1);
const blob=()=>run('git',['hash-object','calcit.cirru']).trim();mkdirSync('acceptance',{recursive:true});
if(process.argv[2]==='apply'){
 assert.equal(blob(),p.blob);assert.deepEqual(views(),norm(p.before));
 const ops=sites.map(s=>['tree','replace',s.id,'--path','@'+[...s.path,0].join('.'),'--input-format','json-ast','--code',JSON.stringify(s.after)]);
 writeFileSync('acceptance/expected-source.json',JSON.stringify(after));writeFileSync('acceptance/operations.json',JSON.stringify(ops));
 const args=['calcit.cirru','edit','transaction','--file','acceptance/operations.json','--format','json'];const preview=JSON.parse(run('calcit',[...args,'--dry-run']));assert.ok(preview.scoped_revision);
 writeFileSync('acceptance/preview.json',JSON.stringify(preview));writeFileSync('acceptance/applied.json',run('calcit',[...args,'--expect-revision',preview.scoped_revision]));writeFileSync('acceptance/modified-blob.txt',blob());
}else assert.equal(process.argv[2],'verify');
assert.deepEqual(views(),after);assert.equal(blob(),readFileSync('acceptance/modified-blob.txt','utf8'));
for(const[f,s]of Object.entries(p.manifests))assert.equal(readFileSync(f,'utf8'),s);
run('git',['diff','--exit-code',p.base,'--','.github/workflows/upload.yaml','Agents.md']);
writeFileSync('acceptance/source-evidence.json',JSON.stringify({beforeBlob:p.blob,afterBlob:blob(),sites,fullSourceViewsMatch:true,definitions:after.defs.length,attachedTests:0,originalOfflineEntryUnchanged:true,manifestsUnchanged:true}));
