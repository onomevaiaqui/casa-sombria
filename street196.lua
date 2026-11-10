local actor
local M={}
local cameras=require('street_data')
local hole=require('hole')
-- Embedded: the console package did not contain street_palette.lua.
local palette={0,20219,17014,14901,16911,12753,13774,13741,11660,10605,10603,11627,10571,10570,10570,7530,9546,9546,9514,9514,9513,9513,8489,9513,8457,8457,8456,7464,6408,7433,8456,8456,8456,8456,7431,7399,8455,7399,7399,7399,7399,7399,7399,7399,7399,7399,7398,5351,6374,7366,6342,4326,6342,4263,6342,6342,6342,6342,6342,6342,6342,5286,6342,6342,6341,6341,5317,5285,6341,6309,6309,6309,4293,5285,5285,5285,5285,5285,5285,5285,5285,5285,4261,5285,5285,5285,5285,5285,5285,5285,5285,5284,4261,5285,2212,2212,5284,5284,5252,5252,5252,4228,5252,4228,3204,3203,2179,3174,3173,3172,2148,4228,3204,3172,2148,4227,4227,3203,3171,2147,2147,3203,3170,3170,3170,3170,2146,2146,130,97,3170,2146,2146,97,2116,2115,2115,2115,2114,1091,2114,1090,2114,2113,1089,1089,65,1058,1058,1057,1057,1057,1057,33,1057,1057,64,32,32,32,1057,32,32,32,1056,32,32,32,32,2080,2080,2080,32,1056,32,32,32,1024,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
local sprites

local x,y,angle=0,5,0

local shot=1
local step=0
local previousA,previousB=false,false
local help=false
local notice,noticeTime='',0
local function held(k)return ui.btn(k)end
local function project(cx,cy,cz)
 local c=cameras[shot];local m=c.m;local w=m[4][1]*cx+m[4][2]*cy+m[4][3]*cz+m[4][4]
 local sx=(m[1][1]*cx+m[1][2]*cy+m[1][3]*cz+m[1][4])/w
 local sy=(m[2][1]*cx+m[2][2]*cy+m[2][3]*cz+m[2][4])/w
 return (sx+1)*240,(1-sy)*135,w
end
-- Screen-space safety for the full body, including animation/shoulder padding.
local function clearance(c,px,py)
 local edge=1e6;local m=c.m
 for _,dx in ipairs({-.32,.32})do for _,dy in ipairs({-.32,.32})do for _,z in ipairs({0,2.05})do
  local xx,yy=px+dx,py+dy
  local w=m[4][1]*xx+m[4][2]*yy+m[4][3]*z+m[4][4]
  if w<.2 then return -1e6 end
  local sx=((m[1][1]*xx+m[1][2]*yy+m[1][3]*z+m[1][4])/w+1)*240
  local sy=(1-(m[2][1]*xx+m[2][2]*yy+m[2][3]*z+m[2][4])/w)*135
  edge=math.min(edge,sx-8,472-sx,sy-20,263-sy)
 end end end
 return edge
end
local function selectCamera(px,py,previous)
 local preferred
 if py< -5 then preferred=px<0 and 3 or 4
 elseif py< -1.4 then preferred=2
 elseif px< -1.8 and py<6.5 then preferred=5
 elseif px< -1.8 and py<10.5 then preferred=6
 elseif py>20.5 then preferred=8
 elseif py>12 then preferred=7
 elseif py>7 then preferred=9
 else preferred=1 end
 local safe=clearance(cameras[preferred],px,py)
 if safe>=14 then return preferred end
 if previous and clearance(cameras[previous],px,py)>=10 then return previous end
 local best,score=preferred,safe
 for i,c in ipairs(cameras)do local v=clearance(c,px,py);if v>score then best,score=i,v end end
 return best
end
local obstacles={{-5.15,-4.65,7.75,8.25},{4.65,5.15,-2.25,-1.75},{-5.25,-4.75,-24.25,-23.75},{4.75,5.25,-30.25,-29.75},{4.4,5.5,3.2,4.5},{-5.3,-4.4,-4.3,-3.1},{1.15,2.85,-4.9,-4.1},{-3.4,-2.0,-5.1,-4.4}}
local function walkable(px,py)
 local r=.25
 local atGate=px>=-4.75 and px<=-3.8 and ((py>2.65 and py<3.95)or(py>6.65 and py<9.35))
 local onNeck=(math.abs(px)<=4.0 or atGate)and py<=13.0 and py>=-27.5
 local onTurnaround=px*px+(py-18)^2<=8.25^2
 if not onNeck and not onTurnaround then return false end
 local inside=false;local j=#hole
 for i=1,#hole do
  local a,b=hole[i],hole[j]
  if (a[2]>py)~=(b[2]>py) and px<(b[1]-a[1])*(py-a[2])/(b[2]-a[2])+a[1]then inside=not inside end
  local vx,vy=b[1]-a[1],b[2]-a[2];local t=math.max(0,math.min(1,((px-a[1])*vx+(py-a[2])*vy)/(vx*vx+vy*vy)))
  if (px-a[1]-t*vx)^2+(py-a[2]-t*vy)^2<.32^2 then return false end
  j=i
 end
 if inside then return false end
 for _,b in ipairs(obstacles)do
  local nx,ny=math.max(b[1],math.min(b[2],px)),math.max(b[3],math.min(b[4],py))
  if (px-nx)^2+(py-ny)^2<r*r then return false end
 end
 return true
end
local vertices,faces,facePool
local function ink(i)return i<16 and 224+i or 226+i end
local function farther(a,b)return a[4]>b[4]end
local function drawActor(clip,phase)
 local frame=math.floor(phase);local nextFrame=math.min(frame+1,clip.count-1);local blend=phase-frame;local low,span=clip.low or actor.low,clip.span or actor.span;local sn,cs=math.sin(angle),math.cos(angle);local factor=1.8/1.852
 for i=0,407 do
  local p=i*3+frame*1224+1;local q=i*3+nextFrame*1224+1
  local a,b,c=clip.data:byte(p,p+2);local d,e,f=clip.data:byte(q,q+2)
  local ax=(low[1]+(a+(d-a)*blend)/255*span[1])*factor
  local ay=(low[2]+(b+(e-b)*blend)/255*span[2])*factor
  local az=(low[3]+(c+(f-c)*blend)/255*span[3])*factor
  local sx,sy,depth=project(x+ax*cs-az*sn,y+ax*sn+az*cs,ay)
  local v=vertices[i+1];v[1],v[2],v[3]=math.floor(sx+.5),math.floor(sy+.5),depth
 end
 for i=#faces,1,-1 do faces[i]=nil end
 for i=1,#actor.triangles,7 do
  local al,ah,bl,bh,cl,ch,color=actor.triangles:byte(i,i+6)
  local a,b,c=vertices[al+ah*256+1],vertices[bl+bh*256+1],vertices[cl+ch*256+1]
  if a[3]>.2 and b[3]>.2 and c[3]>.2 and (b[1]-a[1])*(c[2]-a[2])-(b[2]-a[2])*(c[1]-a[1])<0 then local n=#faces+1;local f=facePool[n];if not f then f={};facePool[n]=f end;f[1],f[2],f[3],f[4],f[5]=a,b,c,a[3]+b[3]+c[3],ink(color);faces[n]=f end
 end
 table.sort(faces,farther)
 for _,f in ipairs(faces)do ui.trisfill(f[1][1],f[1][2],f[2][1],f[2][2],f[3][1],f[3][2],f[5])end
end
function M.update(paused)
 local fps=60
 if ui.stat then local ok,v=pcall(ui.stat,7);if ok and type(v)=='number' and v>=2 and v<=240 then fps=v end end
 local dt=math.min(.1,1/fps)
 local a,b=held(BTN_G or 13),held(BTN_Z or 4)

 if not paused and b and not previousB then notice='A rua desabou. Nao consigo passar por aqui.';noticeTime=3 end
 previousA,previousB=a,b
 local horizontal=(held(LEFT or 4)and 1 or 0)-(held(RIGHT or 2)and 1 or 0)
 local throttle=(held(UP or 1)and 1 or 0)-(held(DOWN or 3)and 1 or 0)
 local run=held(BTN_F or 12)and throttle>0
 if paused then horizontal,throttle=0,0 end
 angle=(angle+horizontal*(run and 2.5 or 3.2)*dt)%(2*math.pi)
 local distance=(run and 4.1070557323 or 1.7009575856)*dt*throttle
 local moved=0;local n=math.max(1,math.ceil(math.abs(distance)/.04))
 for i=1,n do
  local dx,dy=math.sin(angle)*distance/n,-math.cos(angle)*distance/n
  if walkable(x+dx,y+dy)then x,y=x+dx,y+dy;moved=moved+math.abs(distance/n)
  elseif walkable(x+dx,y)then x=x+dx;moved=moved+math.abs(dx)
  elseif walkable(x,y+dy)then y=y+dy;moved=moved+math.abs(dy)end
 end
 shot=selectCamera(x,y,shot)

 ui.cls(0)
 for i,v in ipairs(palette)do ui.palset(i-1,v)end
 for i,v in ipairs(actor.palette)do ui.palset(ink(i-1),v)end
 ui.palset(240,0);ui.palset(241,32767)
 for i=0,2 do
  local name='street_'..cameras[shot].name..'_'..i;local ref=assert(sprites[name],'Fundo ausente: '..name)
  local result=ui.spr(ref,0,i*90);assert(result~=false,'Falha ao desenhar: '..name)
 end
 local clip=actor.clips.idle;local phase=0
 if moved>0 then
  clip=run and actor.clips.run or actor.clips.walk
  step=(step+moved/(run and 3.0118408704 or 1.7576561718))%1;phase=step*(clip.count-1)
 end
 drawActor(clip,phase)
 ui.rectfill(0,0,479,13,240);ui.print('15.22 RUA / '..cameras[shot].name,5,3,241)
 if noticeTime>0 then noticeTime=noticeTime-dt;ui.rectfill(0,247,479,269,240);ui.print(notice,8,253,241)end
 if help then ui.rectfill(80,80,405,190,240);ui.print('TESTE DE CENARIO E COLISOES',92,94,241);ui.print('Cruz: avancar, recuar e girar',92,116,241);ui.print('Y: correr   B: examinar',92,138,241);ui.print('A: fechar esta ajuda',92,160,241)end
end
function M.setup(sharedActor,refs,buffers)
 assert(sharedActor and refs and buffers,'Dados incompletos da rua')
 for _,c in ipairs(cameras)do for i=0,2 do local name='street_'..c.name..'_'..i;assert(refs[name],'Fundo ausente: '..name)end end
 actor,sprites=sharedActor,refs
 vertices,faces,facePool=buffers.vertices,buffers.faces,buffers.pool
 assert(#vertices==408 and #facePool>=#actor.triangles/7,'Buffer 3D incompleto')
end
M.selectCamera=selectCamera;M.clearance=clearance;M.walkable=walkable
function M.position()return x,y,angle,shot end
function M.reset(px,py,a)x,y,angle=px,py,a or 0;shot=1;noticeTime=0;previousA,previousB=true,true end
return M
