from pathlib import Path
import json,sys,os,time
R=Path.cwd();D=R/'outputs/Lupi-16.46';sys.path.insert(0,str(R/'work/lua55-libs'));from lupa.lua54 import LuaRuntime
plan=json.loads((R/'work/release656-assets.json').read_text());os.chdir(D)
def setup(case,cap=4*1024*1024):
 l=LuaRuntime(encoding=None,max_memory=cap)
 refs={k.encode():l.table_from({b'path':('/apps/1445294631/'+k).encode(),b'width':v[0],b'height':v[1],b'ntiles':1})for k,v in plan['dimensions'].items()}
 l.globals().refs544=l.table_from(refs);l.globals().pal544=l.table_from(plan['palette'])
 l.execute(b'''LEFT,RIGHT,UP,DOWN=0,1,2,3;BTN_Z,BTN_F,BTN_G,BTN_E=4,12,13,15
 local refs=setmetatable({},{__index=refs544,__newindex=function()error('Sprites e somente leitura')end});Sprites=refs
 package.preload.sprites=function()return refs end;package.preload.palette=function()return pal544 end
 keys544={};captured={};ui={btn=function(i)return keys544[i]or false end,stat=function(i)if i==0 then return collectgarbage('count')*1024 elseif i==7 then return 60 end end,cls=function()end,palset=function()end,print=function(t)captured[#captured+1]=t end,rectfill=function()end,rect=function()end,line=function()end,trisfill=function()end,spr=function(ref)assert(ref,'missing sprite');return true end}
 ''')
 if case=='missing_late_asset':l.execute(b"refs544.z0001795=nil")
 if case=='missing_module':l.execute(b"package.preload.enemy153=function()error('INJECTED MODULE ERROR')end")
 if case=='missing_initial_asset':
  key=plan['aliases']['sala75_0'];l.execute(('refs544.'+key+'=nil').encode())
 l.execute(b"dofile('game.lua')")
 t=time.perf_counter();l.execute(b'for i=1,70 do update()end');elapsed=time.perf_counter()-t
 b=l.eval(b"require('startup544')")
 if case in {'missing_module','missing_initial_asset','low_memory'}:
  assert b[b'error'],case
  l.execute(b"for i=1,15 do update()end;assert(captured[#captured]=='Envie uma foto desta tela.')")
  print('PASS captured',case,b[b'label'],b[b'error'][:150])
 else:
  assert b[b'loaded']and not b[b'error'],(case,b[b'error'])
  l.execute(b"package=nil;for i=1,70 do update()end;assert(not require('startup544').error)")
  if case=='normal':l.execute(b"keys544={[BTN_Z]=true};update();keys544={};for i=1,80 do update()end;assert(not require('startup544').error);assert(not require('boot349').error);assert(require('cameras168').enabled)")
  print('PASS boot normal title and New Game',case,'Lua bytes',l.get_memory_used(),'elapsed',round(elapsed,3))
 return l
for case in ['normal','missing_late_asset','missing_module']:setup(case)

setup("low_memory",2*1024*1024)
