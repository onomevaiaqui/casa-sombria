-- Authored ground-plane camera sectors. Positions, facing and animation never choose a shot.
local Z={stats={cuts=0,localRecovery=0,uncovered=0,unmapped=0,unexpected=0}}
local function box(id,x0,x1,y0,y1,shots,links)return{id=id,box={x0,x1,y0,y1},shots=shots,links=links or{}}end
Z.zones={
 box('bar_proto',-30,-17,-82.8,-73.4,{133,134},{'avenida_oeste','casa31'}),
 box('farmacia_identificacao',-18,-5.5,-86.2,-77,{131,51,48},{'farmacia','avenida_centro_oeste','avenida_oeste'}),
 box('mercado_identificacao',-9.2,.6,-66,-51.8,{132,53,54},{'mercado','acacias_baixa','acacias_centro'}),
 {id='coreto',circle={11.86,-43.3,1.85},shots={16,11},links={'praca','praca_oeste'}},
 box('mercado',-19,-5.4,-66.5,-52.4,{54,53},{'acacias_baixa','acacias_centro'}),
 box('casa31',-31.5,-18.5,-96,-84.1,{121,122,47},{'avenida_oeste'}),
 box('farmacia',-17,-6,-86.5,-80.6,{51,42,48},{'avenida_centro_oeste'}),
 box('ubs',38.4,51.5,-65.3,-63.3,{62,104},{'cedros_baixo'}),
 box('posto',30.5,46,-96.1,-84,{64,76,77},{'avenida_leste'}),
 box('oficina',50.5,63,-97,-84,{65,73,75},{'avenida_extremo_leste'}),
 box('jardim39',5.7,18.2,.6,10,{1,2},{'saida39'}),
 box('saida39',5.7,18.2,-3.35,.6,{2,123,1},{'jardim39','passagem41'}),
 box('passagem41',6.1,18,-4.7,-3.35,{123,125},{'saida39','fundos41_alto'}),
 box('fundos41_alto',16.25,18.2,-9,-4.7,{125,123,124},{'passagem41','fundos41'}),
 box('fundos41',16.25,18.2,-15.5,-9,{124,125,126},{'fundos41_alto','grade'}),
 box('grade',15.3,20,-20.5,-15.5,{126,27,124},{'fundos41','trilha_norte'}),
 box('trilha_norte',13.7,20.2,-27.5,-20.5,{27,129,12},{'grade','trilha_meio'}),
 box('trilha_meio',12.5,20.2,-34.6,-27.5,{129,29,27},{'trilha_norte','chegada_praca'}),
 box('chegada_praca',10,19,-40.1,-34.6,{128,11},{'trilha_meio','praca','saidaB','praca_oeste'}),
 box('saidaA',-3.8,10.2,-44.2,-37,{85,128},{'praca_oeste','praca','acacias_centro'}),
 box('saidaB',19,30.5,-43.6,-32,{127,11},{'praca','chegada_praca','cedros_centro'}),
 box('praca_oeste',4,10.2,-50,-39.8,{85,128,11},{'saidaA','coreto','praca','parque_sul'}),
 box('praca',10.2,24.5,-50,-39.8,{11,130,127,128},{'coreto','chegada_praca','saidaA','saidaB','praca_oeste','parque_sul'}),
 box('parque_sul',4,29,-55,-50,{39,15,11},{'praca','praca_oeste','mata_sul'}),
 box('mata_sul',4,29,-62,-55,{33,31,35},{'parque_sul','saidaC'}),
 box('saidaC',4,29,-74.8,-62,{32,37,36},{'mata_sul','avenida_centro','avenida_parque'}),
 box('acacias_norte',-9,6.5,-32,-5.5,{18,82,19,25},{'acacias_centro'}),
 box('acacias_centro',-9,6.5,-47,-32,{55,85,17,26},{'acacias_norte','saidaA','acacias_baixa','mercado'}),
 box('acacias_baixa',-9,6.5,-64,-47,{20,26,22},{'acacias_centro','mercado','acacias_esquina'}),
 box('acacias_esquina',-9,7,-76.5,-64,{21,43,49},{'acacias_baixa','avenida_centro'}),
 box('cedros_retorno',24,42,-20.5,-5,{60,67,78},{'cedros_alto'}),
 box('cedros_alto',24,42,-31,-20.5,{58,68,78},{'cedros_retorno','cedros_centro'}),
 box('cedros_centro',24,42,-43,-31,{57,59,68},{'cedros_alto','saidaB','cedros_meio'}),
 box('cedros_meio',24,42,-55,-43,{69,81,61},{'cedros_centro','cedros_baixo'}),
 box('cedros_baixo',24,42,-66.5,-55,{70,61,62},{'cedros_meio','ubs','cedros_esquina'}),
 box('cedros_esquina',24,42,-76.5,-66.5,{71,74,63},{'cedros_baixo','avenida_leste','avenida_parque'}),
 box('avenida_oeste',-42,-22,-86,-72,{47,50,89},{'casa31','avenida_centro_oeste'}),
 box('avenida_centro_oeste',-22,-8,-86,-72,{48,41,42},{'farmacia','avenida_oeste','avenida_centro'}),
 box('avenida_centro',-8,7,-86,-72,{43,49,46},{'avenida_centro_oeste','acacias_esquina','avenida_parque','saidaC'}),
 box('avenida_parque',7,33,-86,-72,{46,72,32,99},{'saidaC','avenida_centro','cedros_esquina','avenida_leste'}),
 box('avenida_leste',33,48,-86,-72,{77,74,66},{'cedros_esquina','avenida_parque','posto','avenida_extremo_leste'}),
 box('avenida_extremo_leste',48,65,-86,-72,{65,75,73},{'avenida_leste','oficina'}),
}
-- Explicit local alternatives, validated offline against sector visibility.
local recovery374={
 avenida_oeste={79,80,116,117},
 casa31={50,51},
 avenida_centro_oeste={45,49,79,47,116,89,98},
 acacias_esquina={91,41,89,20,36},
 acacias_baixa={17,128,91,21,85},
 acacias_centro={19,82,13,118},
 acacias_norte={84,118,24,119,120,92,102},
 saidaA={19,127,55,29,13,82},
 saidaC={34,36,95,21,91,35,97,96},
 mata_sul={85,61,91,83,81,87,93},
 parque_sul={83,81,26,88,87},
 praca_oeste={13,127,26},
 jardim39={106,123},
 chegada_praca={127,29,88,87},
 avenida_parque={63,44,97,36,111,64,105},
 praca={10,88,15},
 saidaB={15,68,56,94,88},
 cedros_esquina={97,62,32,70,103,81,100},
 cedros_alto={108,57,112},
 cedros_meio={59,88,56},
 cedros_baixo={81,83,97},
 cedros_retorno={58,107},
 posto={63,101,109,73,86},
 cedros_centro={69,94},
 ubs={83},
 avenida_leste={75},
 avenida_extremo_leste={86},
 oficina={77,86,115},
}
for _,z in ipairs(Z.zones)do for _,i in ipairs(recovery374[z.id]or{})do z.shots[#z.shots+1]=i end end
local lastZone,lastX,lastY,lastShot
local function inside(z,x,y,m)
 m=m or 0
 if z.circle then local c=z.circle;return(x-c[1])^2+(y-c[2])^2<=(c[3]+m)^2 end
 local b=z.box;return x>=b[1]-m and x<=b[2]+m and y>=b[3]-m and y<=b[4]+m
end
local function has(t,v)for _,n in ipairs(t)do if n==v then return true end end;return false end
function Z.reset()lastZone,lastX,lastY,lastShot=nil,nil,nil,nil end
function Z.zone(x,y)for _,z in ipairs(Z.zones)do if inside(z,x,y)then return z end end end
function Z.select(views,C,x,y,previous)
 if previous and previous==lastShot and x==lastX and y==lastY then return previous end
 local z=Z.zone(x,y)
 if not z then Z.stats.unmapped=Z.stats.unmapped+1;return nil end
 local teleport=not previous or not lastX or(x-lastX)^2+(y-lastY)^2>9
 local function valid(i,margin)local c=views[i];return c and not c.rejected368 and C.framing(c,x,y)>=(margin or 3)and C.sees(c,x,y)end
 -- Overlap is used only with an explicitly adjacent sector and a still-visible shot.
 if not teleport and lastZone and z~=lastZone and has(lastZone.links,z.id)and inside(lastZone,x,y,.32)and has(lastZone.shots,previous)and valid(previous,5)then z=lastZone end
 local shot
 if not teleport and z==lastZone and has(z.shots,previous)and valid(previous,10)then shot=previous end
 if not shot then for _,i in ipairs(z.shots)do if valid(i,10)then shot=i;break end end end
 if not shot then for _,i in ipairs(z.shots)do if valid(i,5)then shot=i;break end end end
 if not shot then
  -- Only explicitly linked neighboring zones can provide a clear continuation.
  for _,other in ipairs(Z.zones)do if has(z.links,other.id)then
   for _,i in ipairs(other.shots)do if valid(i,8)then shot=i;break end end
   if shot then break end
  end end
 end
 if not shot then shot=z.shots[1];Z.stats.uncovered=Z.stats.uncovered+1 end
 if shot~=z.shots[1]then Z.stats.localRecovery=Z.stats.localRecovery+1 end
 if previous and previous~=shot then Z.stats.cuts=Z.stats.cuts+1 end
 if not teleport and lastZone and lastZone~=z and not has(lastZone.links,z.id)then Z.stats.unexpected=Z.stats.unexpected+1 end
 lastZone,lastX,lastY,lastShot=z,x,y,shot;return shot,z.id
end
return Z
