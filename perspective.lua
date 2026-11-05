-- Initial camera fits to visible door landmarks. Backgrounds are not surveyed 3D.
-- Model height stays 1.80 m; the camera determines its projected size.
local P={}
P.rooms={
 sala={horizon=32,foot=147,door=86,focal=320,cx=240},
 cozinha={horizon=30,foot=151,door=91,focal=320,cx=240},
 corredor={horizon=122,foot=232,door=194,focal=320,cx=240},
 banheiro={horizon=100,foot=230,door=160,focal=320,cx=240},
 quarto={horizon=58,foot=222,door=151,focal=320,cx=240},
 garagem={horizon=84,foot=155,door=95,focal=320,cx=240},
 quintal={horizon=8,foot=165,door=110,focal=320,cx=240},
 frente={horizon=35,foot=156,door=80,focal=320,cx=240}
}
for _,c in pairs(P.rooms)do c.height=(c.foot-c.horizon)*2.1/c.door end
function P.scale(room,y)
 local c=P.rooms[room]
 return math.max(.01,(y-c.horizon)/c.height)
end
function P.ground(room,x,y)
 local c=P.rooms[room]
 local z=c.focal/P.scale(room,y)
 return (x-c.cx)*z/c.focal,z
end
function P.screen(room,x,z,height)
 local c=P.rooms[room]
 z=math.max(.1,z)
 return c.cx+c.focal*x/z,c.horizon+c.focal*(c.height-(height or 0))/z
end
function P.vertex(room,x,y,ax,ay,az,facing)
 local gx,gz=P.ground(room,x,y)
 local s,c=math.sin(facing),math.cos(facing)
 local factor=1.8/1.852
 local right,depth=(ax*c+az*s)*factor,(az*c-ax*s)*factor
 local sx,sy=P.screen(room,gx+right,gz+depth,ay*factor)
 return {math.floor(sx+.5),math.floor(sy+.5),gz+depth}
end
function P.move(room,x,y,dx,dy,dt,running,walkable)
 if dx==0 and dy==0 then return x,y,0 end
 local gx,gz=P.ground(room,x,y)
 local tx,tz=P.ground(room,x+dx,y+dy)
 local ux,uz=tx-gx,tz-gz
 local length=math.sqrt(ux*ux+uz*uz)
 if length<1e-9 then return x,y,0 end
 local distance=(running and 4.1070557323 or 1.7009575856)*math.min(dt,.1)
 ux,uz=ux/length*distance,uz/length*distance
 local n=math.max(1,math.ceil(distance/.025));local moved=0
 for i=1,n do
  local sx,sy=P.screen(room,gx+ux/n,gz+uz/n)
  if walkable(sx,sy)then
   local ng,nh=P.ground(room,sx,sy)
   moved=moved+math.sqrt((ng-gx)^2+(nh-gz)^2)
   gx,gz=ng,nh;x,y=sx,sy
  else
   -- Slide along a screen-aligned wall without tunnelling through furniture.
   local nx,ny=P.screen(room,gx+ux/n,gz+uz/n)
   if walkable(nx,y)then
    local ng,nh=P.ground(room,nx,y)
    moved=moved+math.sqrt((ng-gx)^2+(nh-gz)^2);gx,gz=ng,nh;x=nx
   end
   if walkable(x,ny)then
    local ng,nh=P.ground(room,x,ny)
    moved=moved+math.sqrt((ng-gx)^2+(nh-gz)^2);gx,gz=ng,nh;y=ny
   end
  end
 end
 return x,y,moved
end
return P
