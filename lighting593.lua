-- Position-dependent actor response matching the prerendered interior lights.
-- RGB555 material palettes remain untouched; exterior C lighting follows visible fixtures.
local L={}
local rooms={
 c39_shed={ambient=.33,sources={{1.45,1.35,.28,1.65}}},
 c39_quintal={ambient=.35,sources={{8.05,6.85,.30,2.1},{8.05,15.85,.30,2.1},{-4.9,16.3,.13,1.5}}},
 c39_sala={ambient=.33,sources={{3.901,2.4,0.28,1.65}}},
 c39_cozinha={ambient=.33,sources={{4.95,9.549,0.28,1.65}}},
 c39_casal={ambient=.33,sources={{3.175,0.64,0.28,1.65},{3.175,2.91,0.28,1.65}}},
 c39_solteiro={ambient=.33,sources={{3.2,8.0,.12,1.65},{.2,9.0,.28,1.65}}},
 c39_banho={ambient=.33,sources={{1.1,6.469,0.28,1.1}}},
 c39_corredor={ambient=.33,sources={{2.681,5.45,0.28,1.1}}},
 rua={ambient=.35,sources={{-1.05,0,.28,3.2},{18.03,5.01,.30,2.2}}},
 quintal={ambient=.36,sources={{6.135,2.3,.30,2.2},{6.135,6.3,.175,1.8},{.8,1,.24,1.6}}},
 frente={ambient=.36,sources={{8,8.535,.30,2.2},{14.4,5.79,.27,2.1}}},
 sala={ambient=.35,sources={{.5,.6,.58,1.85}}},
 cozinha={ambient=.36,sources={{2.4,2.1,.48,2.0}}},
 corredor={ambient=.29,sources={{.25,.30,.38,1.2},{2.65,1.45,.38,1.2},{5.35,.30,.38,1.2},{5.92,.9,.12,1.0}}},
 banheiro={ambient=.38,sources={{1.3,1.8,.39,1.4}}},
 quarto={ambient=.40,sources={{1.23,3.42,.38,1.8},{3.50,3.42,.38,1.8}}},
 garagem={ambient=.27,sources={{1.7,2.5,.38,2.0}}},
 area={ambient=.32,sources={{1.5,.75,.35,1.8}}}
}
function L.level(room,x,y)
 local r=rooms[room];if not r or not x or not y then return 1 end
 local v=r.ambient
 for _,s in ipairs(r.sources)do local d=((x-s[1])^2+(y-s[2])^2)/(s[4]^2);v=v+s[3]*math.exp(-d)end
 return math.min(.91,v)
end
function L.color(color,room,x,y)
 if not rooms[room]then return color end
 local scale=L.level(room,x,y);local r,g,b=color&31,(color>>5)&31,(color>>10)&31
 local grey=r*.30+g*.59+b*.11;local sat=.65
 local warmth=0
 r=(r*sat+grey*(1-sat))*scale*(.91+.17*warmth);g=(g*sat+grey*(1-sat))*scale*(1-.08*warmth);b=(b*sat+grey*(1-sat))*scale*(1.02-.30*warmth)
 local function q(v)return math.max(0,math.min(31,math.floor(v+.5)))end
 return q(r)|(q(g)<<5)|(q(b)<<10)
end
function L.enemyColor(color,room,x,y)
 local lit=L.color(color,room,x,y)
 if not rooms[room]then return lit end
 -- Matte skin must sit within the dark baked environment, not above its exposure.
 local exposure=.62+.10*L.level(room,x,y)
 local r,g,b=lit&31,(lit>>5)&31,(lit>>10)&31
 local function q(v)return math.max(0,math.min(31,math.floor(v*exposure+.5)))end
 return q(r)|(q(g)<<5)|(q(b)<<10)
end
return L
