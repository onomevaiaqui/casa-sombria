-- Single animated stress-test actor; all FBX skinning is baked offline.
local E={enabled=true,room='frente',x=6.45,y=4.45,time=0,scale=1.65/1.8,radius=.48,hp=5,state="alive",attackTime=nil,cooldown=0,angle=0}
local metric=require('metric_rooms')
local nav=require('chase_nav158')
local life=require('survival158')
local cameras=require('cameras168')
local D=require('enemy_data155')
local vertices,faces,pool={},{},{}
local triangles={}
for i=1,#D.triangles,7 do
 local a,b,c,d,e,f,k=D.triangles:byte(i,i+6)
 local n=#triangles;triangles[n+1],triangles[n+2],triangles[n+3],triangles[n+4]=a+b*256+1,c+d*256+1,e+f*256+1,k
end
local pa,pb,pc,pd,pe,pf,pg,ph,pi,pj,pk,pl,pm,pn,po,pp
local projectRoom,projectShot,projectX,projectY,projectAngle,projectScale
local depthRow,projectionSine,projectionCosine
local function prepareProjection(room)
 local shot=cameras.room==room and cameras.shot or 1
 if projectRoom==room and projectShot==shot and projectX==E.x and projectY==E.y and projectAngle==E.angle and projectScale==E.scale then return end
 local view=cameras.data[room][shot];local m,v=view.m,view.view
 local sine,cosine=math.sin(E.angle),math.cos(E.angle)
 local scale=E.scale
 depthRow,projectionSine,projectionCosine=v[3],sine,cosine
 -- Coefficients use no per-frame tables or closures.
 local r=m[1];pa,pb,pc,pd=(r[1]*cosine+r[2]*sine)*scale,r[3]*scale,(-r[1]*sine+r[2]*cosine)*scale,r[1]*E.x+r[2]*E.y+r[4]
 r=m[2];pe,pf,pg,ph=(r[1]*cosine+r[2]*sine)*scale,r[3]*scale,(-r[1]*sine+r[2]*cosine)*scale,r[1]*E.x+r[2]*E.y+r[4]
 r=m[4];pi,pj,pk,pl=(r[1]*cosine+r[2]*sine)*scale,r[3]*scale,(-r[1]*sine+r[2]*cosine)*scale,r[1]*E.x+r[2]*E.y+r[4]
 r=v[3];pm,pn,po,pp=(r[1]*cosine+r[2]*sine)*scale,r[3]*scale,(-r[1]*sine+r[2]*cosine)*scale,r[1]*E.x+r[2]*E.y+r[4]
 projectRoom,projectShot,projectX,projectY,projectAngle,projectScale=room,shot,E.x,E.y,E.angle,E.scale
end
local function projectVertex(x,y,z,out)
 local w=pi*x+pj*y+pk*z+pl
 out[1]=math.floor(((pa*x+pb*y+pc*z+pd)/w+1)*240+.5)
 out[2]=math.floor((1-(pe*x+pf*y+pg*z+ph)/w)*135+.5)
 -- Preserve the original arithmetic for depth sorting, including coplanar ties.
 local wx=(x*projectionCosine-z*projectionSine)*E.scale
 local wy=(x*projectionSine+z*projectionCosine)*E.scale
 local v=depthRow
 out[3]=-(v[1]*(E.x+wx)+v[2]*(E.y+wy)+v[3]*(y*E.scale)+v[4])
end
for i=1,D.vertices do vertices[i]={0,0,0}end
for i=1,#D.triangles/7 do pool[i]={0,0,0,0,0}end
local function farther(a,b)return a[4]>b[4]end
local corpseRoom,corpseShot,corpseDoors
local homeX,homeY=6.45,4.45
E.attackRate=1.8;E.attackImpact=D.clips.attack.hitTime;E.speed=2.8;E.runTime=0;E.mode="idle"
local doorBits={1,2,4,8,16,32,64,128}
local doors=require('doors131')
local function paint()
 for i=1,#faces do local f=faces[i];local a,b,c=f[1],f[2],f[3];ui.trisfill(a[1],a[2],b[1],b[2],c[1],c[2],f[5])end
end
local slots={205,206,207,208,209,210,211,212,213,214,215,219,220,221,222,223}
local function ink(n)return slots[n+1]end
function E.palette(ui)for i,color in ipairs(D.palette)do ui.palset(slots[i],color)end end
function E.reset()
 E.hp=5;E.x,E.y=homeX,homeY;E.state='alive';E.time=0;E.runTime=0;E.attackTime=nil;E.cooldown=.15;E.mode='idle';E.moving=false;E.enabled=true;nav.clear();corpseRoom=nil
end
function E.toggle()
 E.enabled=not E.enabled
 if E.enabled and E.hp<=0 then E.reset()end
end
function E.tryHit(room,x,y,facing,baton)
 if not E.enabled or room~=E.room or E.hp<=0 then return false end
 local dx,dy=E.x-x,E.y-y;local reach=baton and 1.5 or 1.1
 if dx*dx+dy*dy>reach*reach then return false end
 local desired=metric.facing(room,dx,dy)
 if math.cos(facing-desired)<.4 then return false end
 local doors=require('doors131')
 for i=1,4 do
  local gx,gy=x+dx*i/5,y+dy*i/5;local sx,sy=metric.project(room,gx,gy,0)
  if not metric.walkable(room,sx,sy)or not doors.walkable(room,gx,gy)then return false end
 end
 E.hp=E.hp-1
 if E.hp==0 then E.state='dying';E.time=0;E.attackTime=nil end
 return true
end
-- Circle footprint, summed with the same 0.25 m courier collision radius.
function E.walkable(room,x,y)
 if not E.enabled or room~=E.room or E.hp<=0 then return true end
 local dx,dy=x-E.x,y-E.y;local radius=E.radius+.25
 return dx*dx+dy*dy>=radius*radius
end
local function clearAttack(room,px,py)
 if not nav.inArea(room,px,py)or life.dead then return false end
 local dx,dy=px-E.x,py-E.y;local distance=math.sqrt(dx*dx+dy*dy)
 if distance>1.35 then return false end
 if distance>.01 and(dx*math.sin(E.angle)-dy*math.cos(E.angle))/distance<.35 then return false end
 for i=1,4 do local sx,sy=metric.project(E.room,E.x+dx*i/5,E.y+dy*i/5,0);if not metric.walkable(E.room,sx,sy)then return false end end
 return true
end
local function moveToward(tx,ty,dt,px,py,playerPresent)
 local wx,wy=nav.waypoint(E.x,E.y,tx,ty,dt);if not wx then return end
 local dx,dy=wx-E.x,wy-E.y;local length=math.sqrt(dx*dx+dy*dy);if length<.01 then return end
 E.angle=math.atan(dx,-dy)
 local distance=math.min(length,E.speed*dt);local steps=math.max(1,math.ceil(distance/.04))
 dx,dy=dx/length*distance/steps,dy/length*distance/steps
 local moved=0
 for i=1,steps do
  local nx,ny=E.x+dx,E.y+dy
  if not nav.canStand(nx,ny)then nav.clear();break end
  if playerPresent and(nx-px)^2+(ny-py)^2<(E.radius+.25)^2 then break end
  E.x,E.y=nx,ny;moved=moved+distance/steps
 end
 E.moving=moved>.0001
 if E.moving then E.runTime=(E.runTime+moved/2.1*D.clips.run.duration)%D.clips.run.duration end
end
function E.tick(dt,room,px,py)
 if not E.enabled then return end
 E.moving=false
 if E.state=='dying'then E.time=math.min(D.clips.death.duration,E.time+dt);if E.time>=D.clips.death.duration then E.state='dead'end;return end
 if E.state=='dead'then return end
 E.time=(E.time+dt)%D.clips.idle.duration
 E.cooldown=math.max(0,E.cooldown-dt)
 local present=nav.inArea(room,px,py)and not life.dead
 local mode=present and 'chase'or 'return'
 if mode~=E.mode then nav.clear();E.mode=mode end
 if not present then E.attackTime=nil end
 if life.dead then E.attackTime=nil;return end
 if E.attackTime then
  local old=E.attackTime;E.attackTime=E.attackTime+dt*E.attackRate
  if E.attackTime<E.attackImpact*.5 then E.angle=math.atan(px-E.x,-(py-E.y))end
  local impact=E.attackImpact
  if not E.attackHit and old<impact and E.attackTime>=impact then
   E.attackHit=true
   if clearAttack(room,px,py)then life.damage()end
  end
  if E.attackTime>=D.clips.attack.duration then E.attackTime=nil;E.cooldown=.3 end
  return
 end
 if present then
  local dx,dy=px-E.x,py-E.y
  if dx*dx+dy*dy<=1.15^2 then
   E.angle=math.atan(dx,-dy)
   if E.cooldown==0 then E.attackTime=0;E.attackHit=false end
  else moveToward(px,py,dt,px,py,true)end
 elseif(E.x-homeX)^2+(E.y-homeY)^2>.15^2 then moveToward(homeX,homeY,dt,px,py,false)end
end
function E.draw(room)
 if not E.enabled or room~=E.room then return end
 local doorMask=doors.stateMask(doorBits)
 if E.state=='dead'and corpseRoom==room and corpseShot==cameras.shot and corpseDoors==doorMask then paint();return end
 prepareProjection(room)
 local clip=E.hp<=0 and D.clips.death or(E.attackTime and D.clips.attack or(E.moving and D.clips.run or D.clips.idle))
 local pos=(E.hp<=0 and E.time or(E.attackTime or(E.moving and E.runTime or E.time)))*clip.fps
 local first=math.min(clip.count-1,math.floor(pos));local second=math.min(clip.count-1,first+1)
 local blend=pos-first;local stride=D.vertices*3
 local low,span=clip.low,clip.span
 for i=1,D.vertices do
  local a=first*stride+(i-1)*3+1;local b=second*stride+(i-1)*3+1
  local x,y,z=string.byte(clip.data,a,a+2);local u,v,w=string.byte(clip.data,b,b+2)
  x=low[1]+(x+(u-x)*blend)/255*span[1]
  y=low[2]+(y+(v-y)*blend)/255*span[2]
  z=low[3]+(z+(w-z)*blend)/255*span[3]
  projectVertex(x,y,z,vertices[i])
 end
 for i=#faces,1,-1 do faces[i]=nil end
 local count=0;local visible=cameras.occlusion(room)
 for i=1,#triangles,4 do
  local a,b,c=vertices[triangles[i]],vertices[triangles[i+1]],vertices[triangles[i+2]]
  local color=triangles[i+3]
  if (b[1]-a[1])*(c[2]-a[2])-(b[2]-a[2])*(c[1]-a[1])<0 and visible(a,b,c)then
   count=count+1;local f=pool[count]
   f[1],f[2],f[3],f[4],f[5]=a,b,c,a[3]+b[3]+c[3],ink(color);faces[count]=f
  end
 end
 table.sort(faces,farther)
 paint()
 if E.state=='dead'then corpseRoom,corpseShot,corpseDoors=room,cameras.shot,doorMask else corpseRoom=nil end
 E.drawn=count
end
function E.beforePlayer(room,x,y)
 if room~=E.room or not E.enabled then return false end
 local view=cameras.data[room][cameras.room==room and cameras.shot or 1].view[3]
 local ed=-(view[1]*E.x+view[2]*E.y+view[4])
 local gx,gy=metric.ground(room,x,y);local pd=-(view[1]*gx+view[2]*gy+view[4])
 return ed>pd
end
return E
