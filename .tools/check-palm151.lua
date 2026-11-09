LEFT,RIGHT,UP,DOWN=0,1,2,3
package.preload.sprites=function()return dofile('.tools/sprites168.lua')end
package.preload.palette=function()return dofile('.tools/palette142.lua')end
ui={stat=function()return 60 end,btn=function()return false end,cls=function()end,palset=function()end,print=function()end,rectfill=function()end,rect=function()end,line=function()end,spr=function()end,trisfill=function()end}
dofile('game.lua')
local function get(fn,key)for i=1,100 do local n,v=debug.getupvalue(fn,i);if n==key then return v end end;error(key)end
local c=get(update,'courier');local clips=get(c,'actorClips');local low,span=get(c,'actorLow'),get(c,'actorSpan');local G=require('combat164')
local ids={49,109,110,213,237};local idSet={};for _,i in ipairs(ids)do idSet[i]=true end
local function vertex(clip,pos,id)
 pos=math.max(0,math.min(clip.count-1,pos));local f=math.floor(pos);local next=math.min(f+1,clip.count-1);local t=pos-f
 local a,b,c=clip.data:byte(f*408*3+id*3+1,f*408*3+id*3+3);local d,e,g=clip.data:byte(next*408*3+id*3+1,next*408*3+id*3+3);local lo,sp=clip.low or low,clip.span or span
 return lo[1]+(a+(d-a)*t)/255*sp[1],lo[2]+(b+(e-b)*t)/255*sp[2],lo[3]+(c+(g-c)*t)/255*sp[3]
end
local count=0
for _,name in ipairs({'idle','walk','run','guard','punch','ready','swing'})do
 local clip=name=='ready'and G.ready or name=='swing'and G.swing or clips[name]
 for f=0,clip.count*4-1 do
  local pos=math.min(clip.count-1,f/4);local mean={0,0,0}
  for _,id in ipairs(ids)do local x,y,z=vertex(clip,pos,id);mean[1],mean[2],mean[3]=mean[1]+x/5,mean[2]+y/5,mean[3]+z/5 end
  local s=G.socket(name,pos);for i=1,3 do assert(math.abs(s[i]-mean[i])<.0000001,'palm mismatch '..name..' '..pos)end;count=count+1
 end
end
for _,name in ipairs({'idle','ready','swing','ready','run','walk','idle'})do
 local clip=name=='ready'and G.ready or name=='swing'and G.swing or clips[name]
 for f=0,12 do
  local pos=math.min(f/2,clip.count-1);G.preparePose(name,1/60);local mean={0,0,0}
  for id=0,407 do local x,y,z=vertex(clip,pos,id);x,y,z=G.blendVertex(id+1,x,y,z);if idSet[id]then mean[1],mean[2],mean[3]=mean[1]+x/5,mean[2]+y/5,mean[3]+z/5 end end
  local s=G.blendSocket(G.socket(name,pos));for i=1,3 do assert(math.abs(s[i]-mean[i])<.0000001,'transition palm mismatch '..name)end
 end
end
print('PASS '..count..' sampled/interpolated palm anchors and 91 transition frames match actual hand mesh')
