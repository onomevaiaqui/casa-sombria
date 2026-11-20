from pathlib import Path
import os,sys,json,re
R=Path.cwd();sys.path.insert(0,str(R/'work/lua55-libs'));from lupa.lua54 import LuaRuntime
plan=json.loads((R/'work/release645-assets.json').read_text());D=R/'outputs/Lupi-16.45';os.chdir(D);l=LuaRuntime(encoding=None,max_memory=4*1024*1024)
refs={k.encode():l.table_from({b'path':('/apps/1445294631/'+k).encode(),b'width':v[0],b'height':v[1],b'ntiles':1})for k,v in plan['dimensions'].items()};l.globals().nativeRefs=l.table_from(refs);l.globals().nativePal=l.table_from(plan['palette'])
l.execute(b'''LEFT,RIGHT,UP,DOWN=0,1,2,3;BTN_Z,BTN_F,BTN_G,BTN_E=4,12,13,15
local refs=setmetatable({},{__index=nativeRefs,__newindex=function()error('Sprites somente leitura')end})
package.preload.sprites=function()return refs end;package.preload.palette=function()return nativePal end
keys={};sounds={};music={play=function(path,fade)sounds[#sounds+1]={'play',path,fade};return true end,loop=function(path,fade)sounds[#sounds+1]={'loop',path,fade};return true end,stop=function(fade)sounds[#sounds+1]={'stop',fade}end,volume=function()end};sfx={volume=function()end}
ui={btn=function(i)return keys[i]or false end,stat=function(i)if i==0 then return collectgarbage('count')*1024 elseif i==7 then return 60 end end,cls=function()end,palset=function()end,print=function()end,rectfill=function()end,rect=function()end,line=function()end,trisfill=function()end,spr=function(ref)assert(ref,'Missing bitmap');return true end,fillp=function()end}
dofile('game.lua');for i=1,70 do update()end;assert(require('startup544').loaded)
keys={[BTN_Z]=true};update();keys={};for i=1,100 do update()end
assert(not require('startup544').error and not require('boot349').error)
local function find(fn,key,seen)
 seen=seen or{};if seen[fn]then return end;seen[fn]=true
 for i=1,150 do local n,v=debug.getupvalue(fn,i);if not n then break end;if n==key then return fn,i,v end end
 for i=1,150 do local n,v=debug.getupvalue(fn,i);if not n then break end;if type(v)=='function'then local a,b,c=find(v,key,seen);if a then return a,b,c end end end
end
local function get(key)local f,i,v=find(require('startup544').tick,key);assert(f,key);return v end
local function set(key,value)local f,i=find(require('startup544').tick,key);assert(f,key);debug.setupvalue(f,i,value)end
set('currentRoom','frente');local metric=require('metric_rooms');local px,py=metric.project('frente',9.7,-.08,0);set('x',px);set('y',py);set('streetCooldown',0);set('crossing',false);set('transitionCarry',nil)
for i=1,12 do update()end;assert(get('streetMode'),'real house-to-street transition');assert(not get('pendingStreet'),'staged transition incomplete');local street=get('street')
street.enterFacility('campo','campo',{12,22,math.pi});for i=1,5 do update()end
assert(not require('startup544').error,require('startup544').error);assert(not require('boot349').error,require('boot349').error)
local e=require('field_enemy641');assert(e.state=='idle')
street.review39(12,25,math.pi);for i=1,90 do update()end
assert(e.state~='idle','field trigger');assert(e.y<31,'chase')
local free=require('facility363').walkable;local px,py=e.x,e.y+.65;for i=1,4 do e.hit(px,py,0,nil,free)end
for i=1,200 do update()end
assert(e.hp==0 and require('house39_story433').key,'field key after death')
assert(not require('startup544').error,require('startup544').error)
print('PASS native menu, New Game, field idle/trigger/chase/death/key; Lua bytes',collectgarbage('count')*1024)
package=nil;for i=1,30 do update()end;assert(not require('startup544').error)
local heard=false;for _,a in ipairs(sounds)do if a[1]=='loop'and a[2]=='music/D02'then heard=true end end;assert(heard,'native menu music loop')
print('PASS package absent, immutable sprites, native music API calls')
''')
l=LuaRuntime(encoding=None)
for p in D.glob('*.lua'):
 result=l.eval(b'loadfile')(str(p).encode());assert not isinstance(result,tuple),(p.name,result)
missing=set()
for p in D.glob('*.lua'):
 for name in re.findall(r"require\s*\(?\s*['\"]([^'\"]+)['\"]",p.read_text(encoding='utf8')):
  if name not in {'sprites','palette','review_config'}and not(D/(name+'.lua')).exists():missing.add(name)
assert not missing,missing
print('PASS native Lua syntax and dependency closure')
