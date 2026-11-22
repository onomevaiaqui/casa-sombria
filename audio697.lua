-- Native single-stream backend, matching Combat Rally's interrupt/restore contract.
local A={wanted='off',active=nil,hold=0,priority=0,gain=1,errors=0,lastError=nil}
local effects={telefone_toca={1.25,10},telefone_desligado={.85,10},["portao_metal"]={2.87718820861678,5},["madeira"]={0.24045351473922902,1},["azulejo"]={0.35628117913832197,1},["grama"]={0.4343764172335601,1},["terra"]={0.6777324263038549,1},["asfalto"]={0.1546485260770975,1},["calcada"]={0.35628117913832197,1},["soco_esforco"]={0.17578231292517008,4},["chute_esforco"]={0.25387755102040815,4},["soco_impacto"]={0.35582766439909297,7},["chute_impacto"]={0.32770975056689344,7},["personagem_dor"]={0.24961451247165534,7},["personagem_morte"]={0.36970521541950113,8},["inimigo_presenca"]={0.7915646258503402,2},["inimigo_ataque"]={0.7125623582766439,5},["inimigo_dor"]={0.7956462585034013,7},["inimigo_morte"]={0.8341950113378684,8},["vidro"]={2.9580045351473925,8},["janela_presenca"]={1.9500226757369614,2},["janela_ataque"]={1.6537868480725624,5},["janela_dor"]={1.9500226757369614,7},["janela_morte"]={1.6537868480725624,8},["mulher_presenca"]={0.696780045351474,2},["mulher_ataque"]={0.3969160997732426,5},["mulher_dor"]={0.7587301587301587,7},["mulher_morte"]={1.2899773242630386,8},["porta_abrir"]={2.681541950113379,5},["macaneta"]={0.5500226757369614,5},["menino_presenca"]={0.7708843537414966,2},["menino_ataque"]={0.6999546485260771,5},["menino_dor"]={0.7750566893424037,7},["menino_morte"]={0.812063492063492,8},["menino_levantar"]={0.4527891156462585,5}}
local levels={L01=.24,N02=.34,D02=.60,B01=.30}
local function call(f,...)
 if type(f)~='function'then return false end
 local ok,value,reason=pcall(f,...)
 if not ok or value==false or(value==nil and type(reason)=='string')then A.errors=A.errors+1;A.lastError=tostring(not ok and value or reason or 'Audio recusado');return false end
 return true
end
local function volume(value,fade)
 if type(music)=='table'then call(music.volume,value,CH_ALL or 31,fade or .1)end
end
function A.scene(name,gain)
 gain=gain or 1
 if name==A.wanted then
  if math.abs(gain-A.gain)>.035 then A.gain=gain;if A.priority==0 and A.active==name then volume((levels[name]or .3)*gain,.18)end end
  return
 end
 local previous=A.wanted;A.wanted=name;A.gain=gain
 if previous=='B01'and name~='B01'and type(music)=='table'then call(music.stop,4);A.hold=4;A.priority=100;A.active=nil
 elseif name=='off'and type(music)=='table'then call(music.stop,.8);A.active=nil end
end
function A.effect(name)
 local e=effects[name];if not e or type(music)~='table'then return end
 -- Recorded steps have no independent mixer on this firmware. Never chop a suspense loop at each footfall.
 if e[2]==1 and A.wanted~='off'then return end
 if A.hold>0 and e[2]<A.priority then return end
 local gain=name=='vidro'and .8 or name=='soco_impacto'and .48 or name=='chute_impacto'and .54 or name:find('esforco')and .23 or .32
 if call(music.play or music.loop,'music/'..name,0)then
  volume(gain,.015);A.hold=e[1];A.priority=e[2];A.active='effect'
 end
end
function A.tick(dt)
 A.hold=math.max(0,A.hold-dt)
 if A.hold>0 then return end
 A.priority=0
 if A.wanted=='off'or type(music)~='table'then return end
 if A.active~=A.wanted then
  if call(music.loop,'music/'..A.wanted,A.wanted=='B01'and .7 or 1.1)then
   A.active=A.wanted;volume((levels[A.wanted]or .3)*A.gain,A.wanted=='B01'and .7 or 1.1)
  end
 end
end
return A
