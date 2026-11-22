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
-- Native half-resolution frosted pass, restricted to pixels actually behind the pane.
function G.draw(cameras,room,ui,gx,gy,faces,actorSlotsOnly)
 if room~='banheiro'or gy<1.55 or not faces or #faces==0 then G.painted=0;return end
 local pane={};for i,p in ipairs({{.10,1.95,.09},{1.45,1.95,.09},{1.45,1.95,2.055},{.10,1.95,2.055}})do pane[i]={cameras.project(room,p[1],p[2],p[3])}end
 local function behind(x,y,d)local p=bary(pane[1],pane[2],pane[3],x,y)or bary(pane[1],pane[3],pane[4],x,y);return p and d>p+.04 end
 for k in pairs(pixels)do pixels[k]=nil end
 local light=require('lighting593');local shades={};local gr,gg,gb=rgb(light.color(pack(12,15,14),room,gx,gy))
 for ink,c in pairs(original)do local r,g,b=rgb(light.color(c,room,gx,gy));shades[ink]={r*.72+gr*.28,g*.72+gg*.28,b*.72+gb*.28}end
 local output={};local count=0
 for ink,c in pairs(shades)do local best,dist=ink,1e9
  for target,t in pairs(shades)do local r,g,b=rgb(light.color(original[target],room,gx,gy));local e=(r-c[1])^2+(g-c[2])^2+(b-c[3])^2;if e<dist then best,dist=target,e end end;output[ink]=best
 end
 local minx,miny,maxx,maxy=480,270,0,0
 for _,f in ipairs(faces)do local a,b,c=f[1],f[2],f[3]
  if output[f[5]]then
   local x0=math.max(0,math.floor(math.min(a[1],b[1],c[1])/2)*2);local x1=math.min(478,math.ceil(math.max(a[1],b[1],c[1])/2)*2)
   local y0=math.max(16,math.floor(math.min(a[2],b[2],c[2])/2)*2);local y1=math.min(268,math.ceil(math.max(a[2],b[2],c[2])/2)*2)
   for y=y0,y1,2 do for x=x0,x1,2 do local d=bary(a,b,c,x+1,y+1)
    if d and behind(x+1,y+1,d)then pixels[y*480+x]=output[f[5]];minx,miny,maxx,maxy=math.min(minx,x),math.min(miny,y),math.max(maxx,x),math.max(maxy,y)end
   end end
  end
 end
 for y=miny,maxy,2 do local start,previous
  for x=minx,maxx+2,2 do local ink=pixels[y*480+x]
   if ink~=previous then if start then ui.rectfill(start,y,x-1,y+1,previous);count=count+1 end;start=ink and x or nil;previous=ink end
  end
 end
 G.painted=count
end
return G
