-- Single animated stress-test actor; all FBX skinning is baked offline.
local E={enabled=true,room='sala',x=2.45,y=2.65,time=0}
local metric=require('metric_rooms')
local cameras=require('cameras168')
local D=require('enemy_data153')
local vertices,faces,pool={},{},{}
for i=1,D.vertices do vertices[i]={0,0,0}end
for i=1,#D.triangles/7 do pool[i]={0,0,0,0,0}end
local function farther(a,b)return a[4]>b[4]end
local function ink(n)return n<16 and 224+n or 226+n end
function E.tick(dt)E.time=(E.time+dt)%D.duration end
function E.draw(room)
 if not E.enabled or room~=E.room then return end
 local project=cameras.projector(room)
 local pos=E.time*D.fps
 local first=math.min(D.count-1,math.floor(pos));local second=math.min(D.count-1,first+1)
 local blend=pos-first;local stride=D.vertices*3
 local low,span=D.low,D.span
 for i=1,D.vertices do
  local a=first*stride+(i-1)*3+1;local b=second*stride+(i-1)*3+1
  local x,y,z=string.byte(D.data,a,a+2);local u,v,w=string.byte(D.data,b,b+2)
  x=low[1]+(x+(u-x)*blend)/255*span[1]
  y=low[2]+(y+(v-y)*blend)/255*span[2]
  z=low[3]+(z+(w-z)*blend)/255*span[3]
  local sx,sy,depth=project(E.x+x,E.y+z,y)
  if not sx then sx,sy,depth=metric.project(room,E.x+x,E.y+z,y)end
  local out=vertices[i];out[1],out[2],out[3]=math.floor(sx+.5),math.floor(sy+.5),depth
 end
 for i=#faces,1,-1 do faces[i]=nil end
 local count=0;local visible=cameras.occlusion(room)
 for i=1,#D.triangles,7 do
  local al,ah,bl,bh,cl,ch,color=string.byte(D.triangles,i,i+6)
  local a,b,c=vertices[al+ah*256+1],vertices[cl+ch*256+1],vertices[bl+bh*256+1]
  if (b[1]-a[1])*(c[2]-a[2])-(b[2]-a[2])*(c[1]-a[1])<0 and visible(a,b,c)then
   count=count+1;local f=pool[count]
   f[1],f[2],f[3],f[4],f[5]=a,b,c,a[3]+b[3]+c[3],ink(color);faces[count]=f
  end
 end
 table.sort(faces,farther)
 for i=1,count do local f=faces[i];local a,b,c=f[1],f[2],f[3];ui.trisfill(a[1],a[2],b[1],b[2],c[1],c[2],f[5])end
 E.drawn=count
end
function E.beforePlayer(room,x,y)
 if room~=E.room or not E.enabled then return false end
 local _,_,ed=cameras.projector(room)(E.x,E.y,0)
 local gx,gy=metric.ground(room,x,y);local _,_,pd=cameras.projector(room)(gx,gy,0)
 return ed>pd
end
return E
