-- The Wrapped / Codyanka (CC0). Arm-free recovery authored offline.
local W={room='corredor',state='waiting',hp=3,drawn=0}
W.tuning={speed=1.9,attackRate=1.15,recovery=.42,punchReach=.80,kickReach=.95,weaponReach=1.10,impactReach=.95}
local cameras=require('cameras168')
local metric=require('metric_rooms')
local doors=require('doors131')
local life=require('survival158')
local D,S,run,attack,idle,hit,death
local vertices,triangles,faces,pool={},{},{},{}
local slots={205,206,207,208,209,210,211,212,213,214,215,219,220,221,222,223}
local function load()
 if D then return end
 D=require('window_mesh563');S=require('window_sequence563')
 run=require('window_run563');attack=require('window_attack563');idle=require('window_idle563')
 hit=require('window_hit566');death=require('window_death566')
 for i=1,D.vertices do vertices[i]={0,0,0} end
 for i=1,#D.triangles,7 do
  local a,b,c,d,e,f,k=D.triangles:byte(i,i+6)
  triangles[#triangles+1]={a+b*256+1,c+d*256+1,e+f*256+1,k}
  pool[#pool+1]={0,0,0,0,0}
 end
 W.x,W.y=S.anchor[1],S.anchor[2];W.angle=-math.pi/2
end
function W.reset()
 W.room='corredor'
 W.glassSound624=false
 W.battleMusic636=false
 W.portal=nil
 W.state='waiting';W.hp=3;W.time=0;W.eventTime=0;W.wait=0;W.cooldown=0;W.attackTime=nil;W.blend=0;W.drawn=0;W.moving=false;W.runTime=0;W.poseBlend=1;W.lastPose=nil;W.previousClip=nil
 if S then W.x,W.y=S.anchor[1],S.anchor[2];W.angle=-math.pi/2 end
 W.hitTime=nil;W.deathTime=nil
end
W.reset()
function W.walkable(room,x,y)
 if room~=W.room or W.state~='alive' or W.hp<=0 then return true end
 return (x-W.x)^2+(y-W.y)^2>.52^2
end
function W.tryHit(room,x,y,facing,weapon,kind)
 if room~=W.room or W.state~='alive' or W.hp<=0 then return false end
 local dx,dy=W.x-x,W.y-y
 local reach=weapon and W.tuning.weaponReach or (kind=='kick' and W.tuning.kickReach or W.tuning.punchReach)
 if dx*dx+dy*dy>reach^2 or math.cos(facing-metric.facing(room,dx,dy))<.65 then return false end
 if not require('pursuit605').lineClear(room,x,y,W.x,W.y)then return false end
 W.hp=math.max(0,W.hp-(weapon and 1.2 or .8))
 require('sound626').emit(W.hp<=0 and 'janela_morte'or 'janela_dor')
 W.attackTime=nil;W.moving=false;W.cooldown=.35;W.blend=1
 if W.hp<=0 then W.state='dying';W.deathTime=0;W.hitTime=nil
 else W.hitTime=0 end
 -- Snapshot the current pose so an interrupted attack does not snap upright.
 W.fromPose=W.lastPose;W.lastPose={};W.poseBlend=W.fromPose and 0 or 1;W.previousClip=W.hp<=0 and death or hit
 return true
end
local function clear(x,y)
 return require('pursuit605').clear(W.room,x,y)
end
local function turnToward(dx,dy,dt)
 local desired=math.atan(dx,-dy)
 local delta=math.atan(math.sin(desired-W.angle),math.cos(desired-W.angle))
 local amount=math.max(-2.8*dt,math.min(2.8*dt,delta))
 W.angle=W.angle+amount
 local remaining=math.abs(delta-amount)
 if remaining>.12 then
  W.moving=true;W.runTime=(W.runTime+math.abs(amount)*.22)%run.duration
 end
 return remaining
end
function W.tick(dt,room,px,py)
 if life.dead or W.state=='escaped'then return end
 if W.state=='waiting'and room~=W.room then return end
 if (W.state=='alive'or W.state=='sequence')and not require('pursuit605').inside[room]then W.state='escaped';W.moving=false;return end
 dt=math.min(.1,math.max(0,dt or 0))
 require('sound626').presence('window',W.state=='alive'and not W.hitTime and not W.attackTime,room==W.room and (px-(W.x or px))^2+(py-(W.y or py))^2<49,dt)
 if W.state=='waiting' then
  W.wait=W.wait+dt
  -- Bedroom approach: cross the corridor line just before the door at X4.1m.
  if W.wait>=1.0 and px>=3.6 then load();W.state='sequence';W.time=0 end
  return
 end
 if W.state=='dead' then return end
 W.time=W.time+dt
 if W.state=='sequence' and W.time>=.4 and not W.glassSound624 then W.glassSound624=true;require('sound626').emit('vidro')end
 -- Glass lasts 3 seconds from the break at 0.4s. The landing precedes recovery.
 if W.state=='sequence'and W.time>=3.4 then W.battleMusic636=true end
 W.eventTime=W.eventTime+dt
 if W.state=='dying' then
  W.poseBlend=math.min(1,W.poseBlend+dt/.12);W.deathTime=math.min(death.duration,W.deathTime+dt)
  if W.deathTime>=death.duration then W.state='dead' end
  return
 end
 if W.state=='sequence' then
  if W.time>=5.5 then W.state='alive';W.time=0;W.cooldown=.25;W.blend=0 end
  return
 end
 W.blend=math.min(1,W.blend+dt/.5);W.cooldown=math.max(0,W.cooldown-dt)
 W.poseBlend=math.min(1,W.poseBlend+dt/.20);W.moving=false
 if W.portal then require('pursuit605').advancePortal(W,dt,run.duration);return end
 if room~=W.room then W.attackTime=nil;require('pursuit605').follow(W,room,dt,run.duration);return end
 if W.hitTime then
  W.poseBlend=math.min(1,W.poseBlend+dt/.08);W.hitTime=W.hitTime+dt*1.1
  if W.hitTime>=hit.duration then W.hitTime=nil end
  return
 end
 local dx,dy=px-W.x,py-W.y;local dist=math.sqrt(dx*dx+dy*dy)
 if W.attackTime then
  local old=W.attackTime;W.attackTime=W.attackTime+dt*W.tuning.attackRate
  if old<.48 and W.attackTime>=.48 and dist<W.tuning.impactReach then
   local ok=true
   for i=1,4 do if not clear(W.x+dx*i/5,W.y+dy*i/5)then ok=false end end
   if ok then life.damage() end
  end
  if W.attackTime>=attack.duration then W.attackTime=nil;W.cooldown=W.tuning.recovery end
 elseif dist<.76 and require('pursuit605').lineClear(W.room,W.x,W.y,px,py)then
  local remaining=turnToward(dx,dy,dt)
  if W.cooldown==0 and remaining<.18 then W.attackTime=0;W.moving=false;require('sound626').emit('janela_ataque') end
 else
  local tx,ty,routed=require('pursuit605').waypoint(W.room,W.x,W.y,px,py)
  dx,dy=tx-W.x,ty-W.y;dist=math.sqrt(dx*dx+dy*dy)
  local remaining=turnToward(dx,dy,dt)
  if remaining>.50 then return end
  local step=math.min(math.max(0,dist-(routed and .02 or .60)),W.tuning.speed*dt)
  if dist>.001 then
   local nx,ny=W.x+dx/dist*step,W.y+dy/dist*step
   if clear(nx,ny) then W.x,W.y=nx,ny;W.moving=step>.0001;W.runTime=(W.runTime+step/1.55)%run.duration end
  end
 end
end
function W.palette(u)
 if not D or W.state=='waiting' then return end
 local light=require('lighting593')
 for i,c in ipairs(D.palette)do
  -- Slots1/2 belong to the window opening and glass, not the skin material.
  u.palset(slots[i],i<=2 and light.color(c,W.room,W.x,W.y)or light.enemyColor(c,W.room,W.x,W.y))
 end
end
local function point(x,y,z)
 local a,b,d=cameras.project('corredor',x,y,z)
 return {math.floor(a+.5),math.floor(b+.5),d}
end
local function tri(a,b,c,ink)
 ui.trisfill(a[1],a[2],b[1],b[2],c[1],c[2],ink)
end
function W.background(room)
 if room~='corredor' or W.state=='waiting' or (W.state=='sequence' and W.time<.4)then return end
 local a,b,c,d=point(6.135,.375,1.105),point(6.135,1.425,1.105),point(6.135,1.425,2.135),point(6.135,.375,2.135)
 tri(a,b,c,slots[1]);tri(a,c,d,slots[1])
 local q=math.min(1.3,math.max(0,W.eventTime-.4))
 for i=1,24 do
  local dy=((i*37)%83)/100-.41;local dz=((i*29)%79)/100-.39
  local x=6.2-(.6+(i%9)*.2)*q;local y=.9+dy+((i%5)-2)*.22*q
  local z=math.max(.03,1.62+dz+q*.6-4*q*q);local sz=.025+(i%4)*.018
  local p1,p2,p3
  if z<=.031 then p1,p2,p3=point(x-sz,y,z),point(x+sz,y+sz*.4,z),point(x,y-sz,z)
  else p1,p2,p3=point(x,y-sz,z),point(x,y+sz,z+sz*.5),point(x,y,z-sz) end
  tri(p1,p2,p3,slots[2])
 end
end
local function sample(clip,pos,i)
 local first=math.min(clip.count-1,math.floor(pos));local second=math.min(clip.count-1,first+1);local blend=pos-first
 local a=first*D.vertices*3+(i-1)*3+1;local b=second*D.vertices*3+(i-1)*3+1
 local x,y,z=clip.data:byte(a,a+2);local u,v,w=clip.data:byte(b,b+2)
 return clip.low[1]+(x+(u-x)*blend)/255*clip.span[1],clip.low[2]+(y+(v-y)*blend)/255*clip.span[2],clip.low[3]+(z+(w-z)*blend)/255*clip.span[3]
end
local function farther(a,b)return a[4]>b[4]end
function W.draw(room)
 if room~=W.room or W.state=='waiting'or W.state=='escaped' then return end
 -- Keep the actor hidden until the same instant that exposes the broken window.
 if W.state=='sequence'and W.time<.4 then W.drawn=0;return end
 W.palette(ui)
 local seq=W.state=='sequence';local dead=W.state=='dead';local visible=cameras.occlusion(room)
 local dying=W.state=='dying' or dead
 local clip=dying and death or (W.hitTime and hit or (W.attackTime and attack or (W.moving and run or idle)))
 local pos=(dying and (W.deathTime or death.duration) or (W.hitTime or W.attackTime or (W.moving and W.runTime or (W.time%idle.duration))))*clip.fps
 if not seq and W.previousClip~=clip then
  W.fromPose=W.lastPose;W.lastPose={};W.poseBlend=W.fromPose and 0 or 1;W.previousClip=clip
 end
 local sin,cos=math.sin(W.angle),math.cos(W.angle)
 for i=1,D.vertices do
  local x,y,z
  if seq then x,y,z=sample(S,math.min(55,W.time*10),i)
  else
   local ax,az,ay=sample(clip,pos,i)
   if W.fromPose and W.poseBlend<1 then
    local a=W.fromPose[i];local t=W.poseBlend*W.poseBlend*(3-2*W.poseBlend)
    if a then ax=a[1]+(ax-a[1])*t;az=a[2]+(az-a[2])*t;ay=a[3]+(ay-a[3])*t end
   end
   local lp=W.lastPose[i];if not lp then lp={};W.lastPose[i]=lp end;lp[1],lp[2],lp[3]=ax,az,ay
   x=W.x+ax*cos-ay*sin;y=W.y+ax*sin+ay*cos;z=az
   if W.blend<1 then local a,b,c=sample(S,55,i);local t=W.blend*W.blend*(3-2*W.blend);x=a+(x-a)*t;y=b+(y-b)*t;z=c+(z-c)*t end
  end
  local sx,sy,dep=cameras.project(room,x,y,z);local out=vertices[i];out[1],out[2],out[3]=math.floor(sx+.5),math.floor(sy+.5),dep
 end
 for i=#faces,1,-1 do faces[i]=nil end
 local count=0
 for _,t in ipairs(triangles)do
  local a,b,c=vertices[t[1]],vertices[t[2]],vertices[t[3]]
  if a[3]>.1 and b[3]>.1 and c[3]>.1 and (b[1]-a[1])*(c[2]-a[2])-(b[2]-a[2])*(c[1]-a[1])<0 and visible(a,b,c)then
   count=count+1;local f=pool[count];f[1],f[2],f[3],f[4],f[5]=a,b,c,a[3]+b[3]+c[3],slots[t[4]+1];faces[count]=f
  end
 end
 table.sort(faces,farther)
 for _,f in ipairs(faces)do tri(f[1],f[2],f[3],f[5])end
 W.drawn=count
end
function W.beforePlayer(room,x,y)
 if room~=W.room or W.state=='waiting'then return false end
 local gx,gy=metric.ground(room,x,y);local _,_,pd=cameras.project(room,gx,gy,0)
 local _,_,ed=cameras.project(room,W.x,W.y,0)
 return ed>pd
end
return W
