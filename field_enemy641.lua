-- User-provided red-shirt boy. Field encounter persists across camera changes.
local D=require('teen642_data')
local E={x=12,y=31,hp=3,maxHp=3,state='idle',time=0,angle=0,motion=0,enabled=true}
local life=require('survival158')
local verts,faces,pool,tris={},{},{},{}
local slots={205,206,207,208,209,210,211,212,213,214,215,219,220,221,222,223}
for i=1,D.vertices do verts[i]={0,0,0}end
for i=1,#D.triangles,7 do local a,b,c,d,e,f,k=D.triangles:byte(i,i+6);tris[#tris+1]={a+b*256+1,c+d*256+1,e+f*256+1,k};pool[#pool+1]={}end
local current,currentName
local function pose()
 local name=E.state=='dead'and 'death'or E.state
 if name~=currentName then
  current=nil;currentName=name
  local key='teen642_'..name;current=require(key)
  if type(package)=='table'and package.loaded then package.loaded[key]=nil end
 end
 return current
end
local function state(name)E.state=name;E.time=0;pose()end
function E.bind(session)
 if E.session~=session then
  E.session=session;E.x,E.y=12,31;E.hp=3;E.state='idle';E.time=0;E.motion=0;E.angle=0;E.connected=false;E.cooldown=0;E.dropped=false;E.route=nil;E.routeTime=0;current,currentName=nil,nil
  if session.field641_defeated then E.hp=0;E.state='dead';E.time=10;E.dropped=true;E.x=session.field641_key_x or 12;E.y=session.field641_key_y or 31 end
 end
end
function E.trigger(x,y)return x>=5.5 and x<=20 and y>=24 and y<=38 end
local function waypoint(x,y,canWalk)
 local dx,dy=x-E.x,y-E.y;local length=math.sqrt(dx*dx+dy*dy);local clear=true
 for i=1,math.ceil(length/.25)do local t=i/math.max(1,math.ceil(length/.25));if not canWalk(E.x+dx*t,E.y+dy*t)then clear=false;break end end
 if clear then return x,y end
 if E.routeTime<=0 or not E.route then
  E.routeTime=.6;local step=.5;local width,height=61,81
  local function id(a,b)return math.floor(a/step+.5)+math.floor(b/step+.5)*width end
  local function point(n)return(n%width)*step,math.floor(n/width)*step end
  local a,b=id(E.x,E.y),id(x,y);local q,prev={a},{[a]=a};local head=1
  while head<=#q and not prev[b]do local n=q[head];head=head+1;local cx,cy=point(n)
   for _,d in ipairs({{1,0},{-1,0},{0,1},{0,-1}})do local nx,ny=cx+d[1]*step,cy+d[2]*step;local k=id(nx,ny)
    if nx>=0 and nx<=30 and ny>=0 and ny<=40 and not prev[k]and canWalk(nx,ny)then prev[k]=n;q[#q+1]=k end
   end
  end
  E.route={}
  if prev[b]then local n=b;while n~=a do table.insert(E.route,1,{point(n)});n=prev[n]end end
 end
 local p=E.route[1];if not p then return E.x,E.y end
 if(E.x-p[1])^2+(E.y-p[2])^2<.12^2 then table.remove(E.route,1);p=E.route[1]end
 return p and p[1]or x,p and p[2]or y
end
function E.blocks(x,y)return E.hp>0 and E.state~='idle'and(x-E.x)^2+(y-E.y)^2<.42^2 end
function E.hit(x,y,angle,equipped,canWalk)
 if E.hp<=0 then return false end
 local dx,dy=E.x-x,E.y-y;local dist=math.sqrt(dx*dx+dy*dy);local reach=equipped=='crowbar'and 1.5 or 1.1
 if dist>reach or(dx*math.sin(angle)-dy*math.cos(angle))/math.max(.001,dist)<.4 then return false end
 for i=1,3 do if not canWalk(x+dx*i/4,y+dy*i/4)then return false end end
 E.hp=math.max(0,math.floor(E.hp*10+.5)-(equipped=='crowbar'and 12 or 8))/10
 require('sound626').emit(E.hp==0 and 'inimigo_morte'or 'inimigo_dor');state(E.hp==0 and 'dead'or 'hit');E.cooldown=.32;return true
end
function E.tick(dt,x,y,paused,canWalk)
 if paused then return end
 require('sound626').presence('field',E.state=='walk',(x-E.x)^2+(y-E.y)^2<49,dt)
 dt=math.min(.1,math.max(0,dt));E.time=E.time+dt*(E.state=='rise'and 1.6 or E.state=='attack'and 1.8 or E.state=='hit'and 1.5 or 1);E.cooldown=math.max(0,(E.cooldown or 0)-dt)
 E.routeTime=math.max(0,(E.routeTime or 0)-dt)
 if E.state=='idle'then if E.trigger(x,y)then state('walk')end;return end
 if E.state=='dead'then
  local duration=pose().duration;E.time=math.min(duration,E.time)
  if E.time>=duration and not E.dropped then
   E.dropped=true;E.session.field641_defeated=true
   require('house39_story433').dropFieldKey(E.x,E.y)
  end
  return
 end
 local clip=pose()
 if E.state=='rise'or E.state=='hit'then if E.time>=clip.duration then state('walk')end;return end
 local dx,dy=x-E.x,y-E.y;local distance=math.sqrt(dx*dx+dy*dy)
 if E.state=='attack'then
  local contact=clip.duration*.42
  if not E.connected and E.time>=contact then
   E.connected=true
   if distance<.95 and(dx*math.sin(E.angle)-dy*math.cos(E.angle))/math.max(.001,distance)>.55 then
    local clear=true;for i=1,3 do if not canWalk(E.x+dx*i/4,E.y+dy*i/4)then clear=false end end
    if clear then life.damage()end
   end
  end
  if E.time>=clip.duration then state('walk');E.cooldown=.20 end
  return
 end
 -- All playable field and access path remain in pursuit range; camera changes do not reset it.
 local target=math.atan(dx,-dy);local turn=math.atan(math.sin(target-E.angle),math.cos(target-E.angle));E.angle=E.angle+math.max(-5.5*dt,math.min(5.5*dt,turn))
 if distance<.76 and E.cooldown<=0 then E.connected=false;state('attack');require('sound626').emit('inimigo_ataque');return end
 if distance<=.68 then return end
 local tx,ty=waypoint(x,y,canWalk);dx,dy=tx-E.x,ty-E.y;local routeDistance=math.sqrt(dx*dx+dy*dy);if routeDistance<.001 then return end
 local amount=math.min(2.35*dt,routeDistance,math.max(0,distance-.72));local n=math.max(1,math.ceil(amount/.04));local ax,ay=dx/routeDistance*amount/n,dy/routeDistance*amount/n
 for i=1,n do
  local nx,ny=E.x+ax,E.y+ay
  if canWalk(nx,ny)then E.x,E.y=nx,ny;E.motion=E.motion+amount/n/1.53
  elseif canWalk(nx,E.y)then E.x=nx;E.motion=E.motion+math.abs(ax)/1.53
  elseif canWalk(E.x,ny)then E.y=ny;E.motion=E.motion+math.abs(ay)/1.53 end
 end
end
local function far(a,b)return a[4]>b[4]end
function E.draw(ui,m,visible)
 if not E.enabled then return end
 for i,c in ipairs(D.palette)do local r,g,b=c&31,(c>>5)&31,(c>>10)&31;ui.palset(slots[i],math.floor(r*.34)|(math.floor(g*.40)<<5)|(math.floor(b*.50)<<10))end
 local clip=pose();local phase
 if E.state=='idle'then phase=0
 elseif E.state=='dead'then phase=math.min(clip.count-1,E.time*clip.fps)
 elseif E.state=='walk'then phase=((E.motion or 0)%1)*(clip.count-1)
 else phase=math.min(clip.count-1,E.time*clip.fps)end;local f=math.floor(phase);local n=math.min(f+1,clip.count-1);local blend=phase-f;local sn,cs=math.sin(E.angle),math.cos(E.angle);local r1,r2,r4=m[1],m[2],m[4]
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
