local C={}
local alphabet="23456789ABCDEFGHJKLMNPQRSTUVWXYZ"
local items={"phone_token","remedy_r05","remedy_r02","back_key39","market_key","house12_key","pills","medkit","shed_key","car_key","door_key","lighter","phone","battery","remote","collar","valve","screwdriver","cutters","crowbar"}
local docs={"mother_note39","gazebo_order","market_ledger","family_photo","order","letter","note"}
local flags={"back_key39","battery","blockedPassage","c39_boards675_open","car_key","collar","crowbar","cutters","door_key","family_photo","field641_defeated","field641_key_dropped","field661_awakened","gazebo_order","house12_key","house39_door_note_read","house39_door_note_seen","house39_rear_open","house39_shed_open","letter","lighter","market_front_open","market_key","market_ledger","market_stock_open","medkit","message","mother_note39","note","order","phone","phone_token","pills","remedy_r02","remedy_r05","remote","screwdriver","shed_code39_known","shed_key","valve","window666_seen","yard39_open"}
local numbers={"c39_boards675_hits","field641_key_x","field641_key_y","yard39_hits"}
local doors={'quarto','banheiro','entrada','garagem','cozinha_quintal','corredor','jardim_quintal','garagem_externa','casinha'}
local enemyNames={'enemy153','window_enemy563','field_enemy641','enemy360'}
local rooms={'frente','sala','cozinha','corredor','quarto','banheiro','garagem','quintal','area','campo'}
local states={'waiting','dormant','alive','walk','dead','escaped','sleep'}
local function index(t,v)for i,x in ipairs(t)do if x==v then return i end end end
local function crc(s)local v=65535;for i=1,#s do v=v~(s:byte(i)<<8);for _=1,8 do v=((v<<1)~((v&32768)~=0 and 4129 or 0))&65535 end end;return v end
local function writer()
 local out,byte,n={},0,0
 local function put(v,bits)assert(v>=0 and v<2^bits,'Valor fora do limite');for i=bits-1,0,-1 do byte=byte*2+((v>>i)&1);n=n+1;if n==8 then out[#out+1]=string.char(byte);byte,n=0,0 end end end
 local function str(s)assert(#s<128,'Texto muito longo');put(#s,7);for i=1,#s do put(s:byte(i),8)end end
 return put,str,function()if n>0 then out[#out+1]=string.char(byte<<(8-n))end;return table.concat(out)end
end
local function reader(s)
 local offset=0
 local function get(bits)local v=0;for _=1,bits do assert(offset<#s*8,'Codigo incompleto');local b=s:byte(offset//8+1);v=v*2+((b>>(7-offset%8))&1);offset=offset+1 end;return v end
 local function str()local n=get(7);local out={};for i=1,n do out[i]=string.char(get(8))end;return table.concat(out)end
 return get,str
end
local function base32(s)
 local out,v,n={},0,0
 for i=1,#s do v=(v<<8)|s:byte(i);n=n+8;while n>=5 do n=n-5;local k=(v>>n)&31;out[#out+1]=alphabet:sub(k+1,k+1)end;v=v&((1<<n)-1)end
 if n>0 then local k=(v<<(5-n))&31;out[#out+1]=alphabet:sub(k+1,k+1)end
 return table.concat(out)
end
local function unbase32(s)
 local out,v,n={},0,0
 for i=1,#s do local k=alphabet:find(s:sub(i,i),1,true);assert(k,'Caractere invalido');v=(v<<5)|(k-1);n=n+5;if n>=8 then n=n-8;out[#out+1]=string.char((v>>n)&255);v=v&((1<<n)-1)end end
 assert(v==0,'Final de codigo invalido');return table.concat(out)
end
local function encode(d)
 local put,str,finish=writer();local inv=d.inventory;assert(type(inv)=='table');put(1,4);put(math.max(1,math.min(4,d.hp or 4)),3)
 put(#inv.bag,3);assert(#inv.bag<=6)
 for _,id in ipairs(inv.bag)do put(assert(index(items,id),'Item desconhecido'),5)end
 put(#inv.files,4);assert(#inv.files<=15);for _,id in ipairs(inv.files)do put(assert(index(docs,id),'Arquivo desconhecido'),4)end
 put(inv.equipped and assert(index(items,inv.equipped))or 0,5)
 for _,k in ipairs{'remoteReady','lit','clueRevealed','collarBoxOpen'}do put(inv[k]and 1 or 0,1)end
 local collected=inv.collected or{};local known={}
 for _,k in ipairs(flags)do put(collected[k]==true and 1 or 0,1);known[k]='boolean' end
 for _,k in ipairs(numbers)do known[k]='number';local v=collected[k];put(v~=nil and 1 or 0,1);if v~=nil then local pos=k=='field641_key_x'or k=='field641_key_y';put(pos and math.floor((v+128)*16+.5)or v,pos and 12 or 7)end end
 local extras={};for k,v in pairs(collected)do if not known[k]or type(v)~=known[k]then extras[#extras+1]=k end end;table.sort(extras);assert(#extras<32);put(#extras,5)
 for _,k in ipairs(extras)do str(k);local v=collected[k];local t=type(v);assert(t=='boolean'or t=='number'or t=='string');put(t=='boolean'and 0 or t=='number'and 1 or 2,2);if t=='boolean'then put(v and 1 or 0,1)else str(tostring(v))end end
 for _,kind in ipairs{'opened','unlocked'}do for _,k in ipairs(doors)do put(d.doors and d.doors[kind]and d.doors[kind][k]and 1 or 0,1)end end
 for _,name in ipairs(enemyNames)do
  local e=d.enemies and d.enemies[name];put(e and 1 or 0,1)
  if e then
   local state=e.state or'alive';if(e.hp or 1)<=0 then state='dead'end
   if not index(states,state)then state=name=='field_enemy641'and'walk'or'alive'end
   put(index(states,state)-1,3);put(math.max(0,math.min(127,math.floor((e.hp or 1)*10+.5))),7)
   for _,k in ipairs{'x','y'}do local v=math.floor(((e[k]or 0)+128)*16+.5);assert(v>=0 and v<4096);put(v,12)end
   put(math.floor(((e.angle or 0)%(math.pi*2))/(math.pi*2)*256+.5)%256,8);put(e.room and assert(index(rooms,e.room),'Comodo desconhecido')or 0,4);put(e.enabled==false and 0 or 1,1)
  end
 end
 local raw=finish();local sum=crc(raw);return 'UE1-'..base32(raw..string.char(sum>>8,sum&255))
end
local function decode(code)
 code=code:upper():gsub('%s',''):gsub('-','');assert(code:sub(1,3)=='UE1','Versao de codigo invalida');code=code:sub(4);assert(#code>5 and #code<=1024,'Tamanho de codigo invalido');local raw=unbase32(code);assert(#raw>=3);local data=raw:sub(1,-3);assert(crc(data)==raw:byte(-2)*256+raw:byte(-1),'Codigo digitado incorretamente')
 local get,str=reader(data);assert(get(4)==1);local d={version=1,hp=get(3),inventory={bag={},files={},collected={}},doors={opened={},unlocked={}},enemies={}};assert(d.hp>=1 and d.hp<=4);local inv=d.inventory
 local n=get(3);assert(n<=6);for i=1,n do inv.bag[i]=assert(items[get(5)])end
 n=get(4);for i=1,n do inv.files[i]=assert(docs[get(4)])end
 n=get(5);if n>0 then inv.equipped=assert(items[n]);assert(index(inv.bag,inv.equipped),'Item equipado ausente')end
 for _,k in ipairs{'remoteReady','lit','clueRevealed','collarBoxOpen'}do inv[k]=get(1)==1 end
 for _,k in ipairs(flags)do if get(1)==1 then inv.collected[k]=true end end
 for _,k in ipairs(numbers)do if get(1)==1 then local pos=k=='field641_key_x'or k=='field641_key_y';local v=get(pos and 12 or 7);inv.collected[k]=pos and(v/16-128)or v end end
 n=get(5);for _=1,n do local k=str();local t=get(2);local v;if t==0 then v=get(1)==1 elseif t==1 then v=tonumber(str());assert(v and v==v and math.abs(v)<1e9)elseif t==2 then v=str()else error('Tipo invalido')end;inv.collected[k]=v end
 for _,kind in ipairs{'opened','unlocked'}do for _,k in ipairs(doors)do if get(1)==1 then d.doors[kind][k]=true end end end
 for _,name in ipairs(enemyNames)do if get(1)==1 then
  local e={};e.state=assert(states[get(3)+1]);e.hp=get(7)/10;e.x=get(12)/16-128;e.y=get(12)/16-128;e.angle=get(8)/256*math.pi*2;local r=get(4);if r>0 then e.room=assert(rooms[r])end;e.enabled=get(1)==1;e.time=e.state=='dead'and 999 or 0;e.cooldown=0;e.connected=false;e.attackTime=nil
  if name=='window_enemy563'and e.state~='waiting'and e.state~='escaped'and e.state~='dead'then e.state='alive'end
  d.enemies[name]=e
 end end
 return d
end
function C.encode(d)local ok,value=pcall(encode,d);if ok and #value<=1028 then local valid=pcall(decode,value);if valid then return value end end;return nil,'Estado nao pode ser codificado.'end
function C.decode(s)if type(s)~='string'then return nil,'Codigo invalido'end;local ok,value=pcall(decode,s);if ok then return value end;return nil,'Codigo invalido. Confira os caracteres.'end
C.alphabet=alphabet
function C.format(s)local body=s:sub(5);return 'UE1-'..body:gsub('.....','%0-'):gsub('-$','')end
return C
