-- Cloudy glass: soften the actor only where its pixels lie behind the pane.
local G={};local original={}
for i,v in ipairs({9651,2147,4234,11732,13846,3172,5320,4299,6375,5388,2117,2118,3205,3206,5292,5325,3175,3208,8558,9617,5285,5286,1058,1091,6479,7504,7400,7434,6414,6446})do local n=i-1;original[n<16 and 224+n or 226+n]=v end
local slots={205,206,207,208,209,210,211,212,213,214,215,219,220,221,222,223}
local pixels,depths={},{}
function G.ink(cameras,room,a,b,c,ink)return ink end
local function rgb(v)return v&31,(v>>5)&31,(v>>10)&31 end
local function pack(r,g,b)return math.floor(r+.5)|(math.floor(g+.5)<<5)|(math.floor(b+.5)<<10)end
local function bary(a,b,c,x,y)
 local det=(b[2]-c[2])*(a[1]-c[1])+(c[1]-b[1])*(a[2]-c[2]);if math.abs(det)<.001 then return end
 local u=((b[2]-c[2])*(x-c[1])+(c[1]-b[1])*(y-c[2]))/det
 local v=((c[2]-a[2])*(x-c[1])+(a[1]-c[1])*(y-c[2]))/det
 if u>=0 and v>=0 and u+v<=1 then return u*a[3]+v*b[3]+(1-u-v)*c[3]end
end
function G.draw(cameras,room,ui,gx,gy,faces,actorSlotsOnly)
 if room~='banheiro'or not faces or #faces==0 then return end
 local pane={};for i,p in ipairs({{.10,1.95,.09},{1.45,1.95,.09},{1.45,1.95,2.055},{.10,1.95,2.055}})do pane[i]={cameras.project(room,p[1],p[2],p[3])}end
 local function behind(x,y,d)
  if not d then return false end
  local pd=bary(pane[1],pane[2],pane[3],x,y)or bary(pane[1],pane[3],pane[4],x,y)
  return pd and d>pd+.04
 end
 for k in pairs(pixels)do pixels[k]=nil;depths[k]=nil end
 local minx,miny,maxx,maxy=479,269,0,0
 for _,f in ipairs(faces)do
  local a,b,c=f[1],f[2],f[3]
  if original[f[5]]then
   local x0=math.max(0,math.floor(math.min(a[1],b[1],c[1])));local x1=math.min(479,math.ceil(math.max(a[1],b[1],c[1])))
   local y0=math.max(16,math.floor(math.min(a[2],b[2],c[2])));local y1=math.min(269,math.ceil(math.max(a[2],b[2],c[2])))
   minx,miny,maxx,maxy=math.min(minx,x0),math.min(miny,y0),math.max(maxx,x1),math.max(maxy,y1)
   for y=y0,y1 do for x=x0,x1 do local d=bary(a,b,c,x+.5,y+.5);if d then local k=y*480+x;pixels[k]=f[5];depths[k]=d end end end
  end
 end
 local colors={};local light=require('lighting593')
 for ink,v in pairs(original)do local r,g,b=rgb(light.color(v,room,gx,gy));colors[ink]={r,g,b}end
 local gr,gg,gb=rgb(light.color(pack(12,15,14),room,gx,gy));local shades={}
 for i=1,12 do local c=colors[223+i];shades[i]={c[1]*.72+gr*.28,c[2]*.72+gg*.28,c[3]*.72+gb*.28}end
 for i=13,16 do local t=(i-13)/3*.30+.70;shades[i]={gr*t,gg*t,gb*t}end
 local outputSlots=slots
 if actorSlotsOnly then
  shades={};outputSlots={};for ink,c in pairs(colors)do shades[#shades+1]=c;outputSlots[#outputSlots+1]=ink end
 else
  for i,c in ipairs(shades)do ui.palset(slots[i],pack(c[1],c[2],c[3]))end
 end
 local function nearest(r,g,b)
  local best,dist=1,1e9;for i,c in ipairs(shades)do local d=(r-c[1])^2+(g-c[2])^2+(b-c[3])^2;if d<dist then best,dist=i,d end end;return outputSlots[best]
 end
 local function span(x0,y,x1,ink)
  ui.trisfill(x0,y,x1,y,x1,y+1,ink);ui.trisfill(x0,y,x1,y+1,x0,y+1,ink)
 end
 local painted=0
 for y=math.max(16,miny-1),math.min(269,maxy+1),2 do
  local run,prev=nil,nil
  for x=math.max(0,minx-1),math.min(479,maxx+2),2 do
   local k=y*480+x;local d=depths[k];local own=pixels[k];local count,r,g,b,total=0,0,0,0,0;local nd=d
   local center=colors[own];local er,eg,eb=gr,gg,gb;if center then er,eg,eb=center[1],center[2],center[3]end
   for dy=-1,1 do for dx=-1,1 do local n=k+dy*480+dx;local col=colors[pixels[n]];local w=(dx==0 and 2 or 1)*(dy==0 and 2 or 1)
    if col and behind(x+.5,y+.5,depths[n])then r=r+col[1]*w;g=g+col[2]*w;b=b+col[3]*w;count=count+w;nd=nd or depths[n]else r=r+er*w;g=g+eg*w;b=b+eb*w end;total=total+w
   end end
   local ink
   -- Keep the complete two-pixel output block inside the actor's silhouette.
   local inside=own and pixels[k+1]and pixels[k+480]and pixels[k+481]
   if inside and count>0 and behind(x+.5,y+.5,d)and behind(x+1.5,y+1.5,depths[k+481])then ink=nearest(r/total*.72+gr*.28,g/total*.72+gg*.28,b/total*.72+gb*.28)end
   if ink then painted=painted+1 end
   if ink~=prev then if run then span(run,y,x-1,prev)end;run=ink and x or nil;prev=ink end
  end
  if run then span(run,y,math.min(479,maxx+2),prev)end
 end
 G.painted=painted
end
return G
