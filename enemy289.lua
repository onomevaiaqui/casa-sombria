local hand295=require('punch295')
local grip293=require('enemy_grip293')
local D=require('enemy289_data');D.clips.walk=require('enemy291_walk')
local E={x=0,y=18,hp=6,maxHp=6,time=0,state='idle',angle=0,enabled=false,contacts=0}
local verts,faces,pool={},{},{}
local slots={205,206,207,208,209,210,211,212,213,214,215,219,220,221,222,223}
for i=1,D.vertices do verts[i]={0,0,0}end
local tris={}
for i=1,#D.triangles,7 do local a,b,c,d,e,f,k=D.triangles:byte(i,i+6);tris[#tris+1]={a+b*256+1,c+d*256+1,e+f*256+1,k};pool[#pool+1]={}end
function E.reset()E.punchHit=false;E.punchIndex=1;E.hp=6;E.time=0;E.state='idle';E.enabled=true;E.contacts=0;E.alert=false;E.patrol=1;E.grabbing=false;E.cooldown=0;E.releasePending=false;E.grabMix=0;E.x,E.y=0,18 end
function E.blocks(x,y)return not E.testingMove and E.enabled and E.hp>0 and(x-E.x)^2+(y-E.y)^2<.62^2 end
function E.hit(x,y,angle,equipped)
 if not E.enabled or E.hp<=0 then return false end
 local dx,dy=E.x-x,E.y-y;local reach=equipped=='crowbar'and 1.65 or 1.2;local dist=math.sqrt(dx*dx+dy*dy)
 if dist>reach or(dx*math.sin(angle)-dy*math.cos(angle))/math.max(.001,dist)<.35 then return false end
 E.hp=math.max(0,E.hp-(equipped=='crowbar'and 1.2 or .8));if E.hp<.0001 then E.hp=0;E.state='death';E.time=0;if E.grabbing then E.releasePending=true end;E.grabbing=false end
 return true
end
local punchTimes={13/30,26/30,38/30,57/30}
function E.consumePunchHit()local hit=E.punchHit;E.punchHit=false;return hit end
local patrol={{-2.5,18},{2.5,18},{0,21}}
function E.tick(dt,x,y,paused,running,canWalk,playerAngle)
 if not E.enabled or paused then return end
 E.time=E.time+dt;E.cooldown=math.max(0,(E.cooldown or 0)-dt)
 if E.state=='death'then E.grabbing=false;E.time=math.min(E.time,D.clips.death.duration);return end
 local dx,dy=x-E.x,y-E.y;local dist=math.sqrt(dx*dx+dy*dy)
 if (E.state=='attack'or E.state=='bite')and running and dist>2.3 and not E.grabbing and E.time>.35 then E.state='run';E.time=0 end
 if E.state=='attack'or E.state=='bite'then
  if E.state=='attack'then
   local k=E.punchIndex or 1;local contactTime=punchTimes[k]
   if contactTime and E.time>contactTime+.12 then E.punchIndex=k+1
   elseif contactTime and E.time>=contactTime-.12 and not E.punchConnected then
    local phase=math.min(hand295.count-1,E.time*hand295.fps);local i=math.floor(phase);local j=math.min(i+1,hand295.count-1);local t=phase-i;local d=hand295.data
    for h=0,1 do
     local a=i*6+h*3;local b=j*6+h*3
     local hx=d[a+1]+(d[b+1]-d[a+1])*t;local hy=d[a+2]+(d[b+2]-d[a+2])*t;local hz=d[a+3]+(d[b+3]-d[a+3])*t
     local cs,sn=math.cos(E.angle),math.sin(E.angle);local wx,wy=E.x+hx*cs-hy*sn,E.y+hx*sn+hy*cs
     if hz>.70 and hz<1.85 and(wx-x)^2+(wy-y)^2<.29^2 then E.punchHit=true;E.punchConnected=true;break end
    end
   end
   if E.lastPunchIndex~=E.punchIndex then E.punchConnected=false;E.lastPunchIndex=E.punchIndex end
  end
  if E.state=='bite'then
   if not E.biteResolved and E.time>.76 then
    E.biteResolved=true;E.biteConnected=dist<1.15
    if E.biteConnected then
     E.victimX,E.victimY,E.victimAngle=x,y,playerAngle or E.angle
     E.exitX,E.exitY=x,y
     for _,offset in ipairs({0,.35,-.35,.7,-.7})do
      local a=E.angle+offset;local gx,gy=E.x+math.sin(a)*.96,E.y-math.cos(a)*.96
      E.testingMove=true;local valid=not canWalk or canWalk(gx,gy);E.testingMove=false
      if valid then E.exitX,E.exitY=gx,gy;break end
     end
    end
   end
   local was=E.grabbing;E.grabbing=E.biteConnected and E.time>.76 and E.time<2.95
   if was and not E.grabbing then E.releasePending=true end
  end
  if E.time>=D.clips[E.state].duration then E.grabbing=false;E.state='idle';E.time=0;E.cooldown=.35;E.contacts=E.contacts+1 end
  return
 end
 local inArena=x*x+(y-18)^2<8.2^2 and y>11.5
 local facingDot=(dx*math.sin(E.angle)-dy*math.cos(E.angle))/math.max(.001,dist)
 if inArena and dist<9 and(facingDot>.25 or dist<2.3)then E.alert=true end
 if not inArena then E.alert=false end
 if E.alert and dist<1.02 and E.cooldown<=0 then
  E.state=dist<.80 and 'bite'or 'attack';E.punchIndex=1;E.punchConnected=false;E.lastPunchIndex=1;E.punchHit=false;E.time=0;E.angle=math.atan(dx,-dy);E.victimX,E.victimY=x,y;E.biteResolved=false;E.biteConnected=false;return
 end
 local tx,ty,speed,nextState
 if E.alert then tx,ty=x,y;speed=running and 4.6 or 1.45;nextState=running and 'run'or 'walk'
 else
  E.patrol=E.patrol or 1;local p=patrol[E.patrol];tx,ty=p[1],p[2];speed=.85;nextState='walk'
  if(tx-E.x)^2+(ty-E.y)^2<.35^2 then E.patrol=E.patrol%#patrol+1 end
 end
 if E.state~=nextState then E.state=nextState;E.time=0 end
 local mx,my=tx-E.x,ty-E.y;local n=math.sqrt(mx*mx+my*my)
 if n>.001 and(not E.alert or dist>.82)then
  E.angle=math.atan(mx,-my);local amount=math.min(speed*dt,n);local steps=math.max(1,math.ceil(amount/.05))
  for i=1,steps do
   local nx,ny=E.x+mx/n*amount/steps,E.y+my/n*amount/steps
   E.testingMove=true;local allowed=not canWalk or canWalk(nx,ny);E.testingMove=false
   if allowed and nx*nx+(ny-18)^2<7.8^2 then E.x,E.y=nx,ny;E.motion=(E.motion or 0)+amount/steps/(nextState=='run'and 2.7 or 1.55)end
  end
 end
 -- Test mode intentionally never calls life.damage.
end
local function smooth(t)t=math.max(0,math.min(1,t));return t*t*(3-2*t)end
function E.playerGrab()
 if E.releasePending then
  E.releasePending=false;E.grabMix=0
  return E.exitX or E.victimX,E.exitY or E.victimY,E.angle
 end
 if not E.grabbing then E.grabMix=0;return end
 local phase=math.max(0,math.min(grip293.count-1,E.time/grip293.duration*(grip293.count-1)))
 local i=math.floor(phase);local j=math.min(i+1,grip293.count-1);local t=phase-i;local d=grip293.data
 local ax=d[i*2+1]+(d[j*2+1]-d[i*2+1])*t;local az=d[i*2+2]+(d[j*2+2]-d[i*2+2])*t
 local cs,sn=math.cos(E.angle),math.sin(E.angle);local gx,gy=E.x+ax*cs-az*sn,E.y+ax*sn+az*cs
 local enter=smooth((E.time-.76)/.24);local leave=smooth((E.time-2.65)/.30)
 gx=E.victimX+(gx-E.victimX)*enter;gy=E.victimY+(gy-E.victimY)*enter
 gx=gx+(E.exitX-gx)*leave;gy=gy+(E.exitY-gy)*leave;E.grabMix=enter*(1-leave)
 local a=E.victimAngle+math.atan(math.sin(E.angle-E.victimAngle),math.cos(E.angle-E.victimAngle))*enter
 return gx,gy,a
end
function E.grabPoseTime()return math.max(0,E.time-.76)end
local function far(a,b)return a[4]>b[4]end
function E.draw(ui,m,visible)
 if not E.enabled then return end
 for i,c in ipairs(D.palette)do ui.palset(slots[i],c)end
 local clip=D.clips[E.state];local phase=E.state=='death'and math.min(clip.count-1,E.time*clip.fps)or(E.time%clip.duration)*clip.fps;if E.state=='walk'or E.state=='run'then phase=((E.motion or 0)%1)*(clip.count-1)end;local f=math.floor(phase);local n=math.min(f+1,clip.count-1);local blend=phase-f;local sn,cs=math.sin(E.angle),math.cos(E.angle);local r1,r2,r4=m[1],m[2],m[4]
 for i=0,D.vertices-1 do
  local p=i*3+f*D.vertices*3+1;local q=i*3+n*D.vertices*3+1;local a,b,c=clip.data:byte(p,p+2);local d,e,g=clip.data:byte(q,q+2)
  local ax=clip.low[1]+(a+(d-a)*blend)/255*clip.span[1];local z=clip.low[2]+(b+(e-b)*blend)/255*clip.span[2];local az=clip.low[3]+(c+(g-c)*blend)/255*clip.span[3]
  local wx,wy=E.x+ax*cs-az*sn,E.y+ax*sn+az*cs;local depth=r4[1]*wx+r4[2]*wy+r4[3]*z+r4[4];local v=verts[i+1];v[1],v[2],v[3]=math.floor(((r1[1]*wx+r1[2]*wy+r1[3]*z+r1[4])/depth+1)*240+.5),math.floor((1-(r2[1]*wx+r2[2]*wy+r2[3]*z+r2[4])/depth)*135+.5),depth
 end
 for i=#faces,1,-1 do faces[i]=nil end
 for i,t in ipairs(tris)do local a,b,c=verts[t[1]],verts[t[2]],verts[t[3]]
  if a[3]>.2 and b[3]>.2 and c[3]>.2 and(b[1]-a[1])*(c[2]-a[2])-(b[2]-a[2])*(c[1]-a[1])<0 and visible(a,b,c)then local v=pool[i];v[1],v[2],v[3],v[4],v[5]=a,b,c,a[3]+b[3]+c[3],slots[t[4]+1];faces[#faces+1]=v end
 end
 table.sort(faces,far);for _,f in ipairs(faces)do ui.trisfill(f[1][1],f[1][2],f[2][1],f[2][2],f[3][1],f[3][2],f[5])end
end
return E
