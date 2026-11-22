-- Finite, explicit checkpoints. Numbers are from the NANPA fictional 555-01xx range.
local C={}
local names={'Saida da primeira casa','Desenho da coleira','Chave da Casa 39','Machadinha obtida','Passagem pelo muro aberta'}
local gear={'Sem ferramentas.','Desenho no arquivo.','Chave da Casa 39 e desenho.','Chave da Casa 39 e machadinha.','Chave, machadinha e passagem livre.'}
local function normalize(code)if type(code)~='string'then return end;local s=code:gsub('[%s%-]','');if #s~=7 or s:find('%D')then return end;local n=tonumber(s);if not n or n<5550100 or n>5550104 then return end;return n-5550100 end
function C.select(d)
 local p=d.inventory and d.inventory.collected or{}
 if p.c39_boards675_open then return 4 end
 if p.crowbar then return 3 end
 for _,id in ipairs(d.inventory and d.inventory.bag or{})do if id=='crowbar'then return 3 end end
 if p.back_key39 then return 2 end
 for _,id in ipairs(d.inventory and d.inventory.bag or{})do if id=='back_key39'then return 2 end end
 if p.family_photo then return 1 end
 for _,id in ipairs(d.inventory and d.inventory.files or{})do if id=='family_photo'then return 1 end end
 return 0
end
function C.encode(d)return string.format('555-%04d',100+C.select(d))end
function C.info(code)local i=normalize(code);if i==nil then return nil,'Numero de checkpoint invalido.'end;return {index=i,name=names[i+1],gear=gear[i+1],hp=4,number=string.format('555-%04d',100+i)}end
function C.format(code)local info=C.info(code);return info and info.number or'___-____'end
function C.decode(code)
 local info,err=C.info(code);if not info then return nil,err end;local stage=info.index
 local d={version=1,checkpoint703=stage,hp=4,inventory={bag={},files={'order'},collected={},remoteReady=false,lit=false,clueRevealed=false,collarBoxOpen=false},doors={opened={jardim_quintal=true,cozinha_quintal=true},unlocked={jardim_quintal=true,cozinha_quintal=true}},enemies={enemy153={hp=0,state='dead',room='frente',x=6.45,y=4.45,time=999},window_enemy563={hp=0,state='dead',room='corredor',x=3.65,y=.9,time=999}}}
 local inv=d.inventory;local p=inv.collected;p.shower_body_token712=true
 if stage>=1 then inv.files[#inv.files+1]='family_photo';p.collar=true;p.family_photo=true;p.shed_code39_known=true;inv.clueRevealed=true;inv.collarBoxOpen=true end
 if stage>=2 then
  inv.bag[#inv.bag+1]='back_key39';inv.files[#inv.files+1]='mother_note39';p.back_key39=true;p.field641_defeated=true;p.field661_awakened=true;p.field641_key_dropped=true;p.field641_key_x=12;p.field641_key_y=32;p.house39_door_note_seen=true;p.house39_door_note_read=true
  d.enemies.field_enemy641={hp=0,state='dead',x=12,y=32,time=999,dropped=true}
 end
 if stage>=3 then inv.bag[#inv.bag+1]='crowbar';inv.equipped='crowbar';p.crowbar=true;p.house39_shed_open=true;p.house39_rear_open=true end
 if stage>=4 then p.c39_boards675_open=true;p.c39_boards675_hits=3 end
 return d
end
return C
