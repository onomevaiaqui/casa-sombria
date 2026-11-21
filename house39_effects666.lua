local X={windowTime=0}
local session,person,walk,personTris,personVerts
local masks=require('window666_mask')
local function triangles(blob)
 local out={};for i=1,#blob,7 do local a,b,c,d,e,f,k=blob:byte(i,i+6);out[#out+1]={a+b*256+1,c+d*256+1,e+f*256+1,k}end;return out
end
local function bind(s)
 if session~=s then session=s;X.windowTime=0;X.windowActive=false end
end
local function project(m,x,y,z)
 local w=m[4][1]*x+m[4][2]*y+m[4][3]*z+m[4][4]
 if w<=.035 then return {0,0,-1}end
 return {((m[1][1]*x+m[1][2]*y+m[1][3]*z+m[1][4])/w+1)*240,(1-(m[2][1]*x+m[2][2]*y+m[2][3]*z+m[2][4])/w)*135,w}
end
local function point(clip,count,i,phase)
 local f=math.floor(phase);local n=math.min(f+1,clip.count-1);local blend=phase-f;local a=i*3+f*count*3+1;local b=i*3+n*count*3+1
 local x,y,z=clip.data:byte(a,a+2);local u,v,w=clip.data:byte(b,b+2)
 return clip.low[1]+(x+(u-x)*blend)/255*clip.span[1],clip.low[2]+(y+(v-y)*blend)/255*clip.span[2],clip.low[3]+(z+(w-z)*blend)/255*clip.span[3]
end
local function clippedTriangle(ui,mask,a,b,c)
 if a[3]<0 or b[3]<0 or c[3]<0 or(b[1]-a[1])*(c[2]-a[2])-(b[2]-a[2])*(c[1]-a[1])>=0 then return end
 for _,pane in ipairs(mask.polygons)do
  local shape={a,b,c};local area=0
  for i=1,#pane do local p,q=pane[i],pane[i%#pane+1];area=area+p[1]*q[2]-p[2]*q[1]end
  local sign=area>=0 and 1 or -1
  for i=1,#pane do
   if #shape==0 then break end
   local p,q=pane[i],pane[i%#pane+1];local dx,dy=q[1]-p[1],q[2]-p[2];local clipped={};local prev=shape[#shape];local pv=sign*(dx*(prev[2]-p[2])-dy*(prev[1]-p[1]))
   for _,v in ipairs(shape)do
    local cv=sign*(dx*(v[2]-p[2])-dy*(v[1]-p[1]))
    if(cv>=0)~=(pv>=0)then local t=pv/(pv-cv);clipped[#clipped+1]={prev[1]+(v[1]-prev[1])*t,prev[2]+(v[2]-prev[2])*t}end
    if cv>=0 then clipped[#clipped+1]=v end
    prev,pv=v,cv
   end
   shape=clipped
  end
  for i=2,#shape-1 do local p,q,r=shape[1],shape[i],shape[i+1];ui.trisfill(p[1],p[2],q[1],q[2],r[1],r[2],223)end
 end
end

local function drawPasser(ui,cam,dt)
 local mask=masks[cam.name]
 if not X.windowActive then return end
 X.windowTime=X.windowTime+dt;local t=X.windowTime-.9
 if t<0 then return end
 if t>2.2 then X.windowActive=false;person,walk,personVerts,personTris=nil,nil,nil,nil;return end
 if not mask or cam.name~='c39p_solteiro_4'then return end
 if not person then person=require('teen642_data');walk=require('teen642_walk');personTris=triangles(person.triangles);personVerts={}end
 ui.palset(223,2|(3<<5)|(4<<10));local px=-.35+3.7*t/2.2;local py=10.72;local phase=(t/.8%1)*(walk.count-1)
 for i=0,person.vertices-1 do
  local ax,z,ay=point(walk,person.vertices,i,phase)
  -- Walking to the right, behind the glass, never inside the bedroom.
  personVerts[i+1]=project(cam.m,px-ay,py+ax,z*(1.75/1.65))
 end
 for _,f in ipairs(personTris)do clippedTriangle(ui,mask,personVerts[f[1]],personVerts[f[2]],personVerts[f[3]])end
end
function X.draw(ui,cam,x,y,dt,s,visible)
 bind(s)
 local inBedroom=x<3.52 and y>6.84
 if inBedroom and not session.window666_seen then
  -- Consume on first entry, independent of the active camera or later revisits.
  session.window666_seen=true;X.windowActive=true;X.windowTime=0
 elseif not inBedroom and X.windowActive then
  X.windowActive=false;person,walk,personVerts,personTris=nil,nil,nil,nil
 end
 drawPasser(ui,cam,dt)
end
return X
