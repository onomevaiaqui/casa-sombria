-- Full mesh, screen-space batching. Original painter order, geometry and palette indices.
local B={calls=0,tiles=0,fallbacks=0}
print('BATCH724 IMG_API '..type(ui.img))
local pixels,rows,rowPool,seen={},{},{},{}
local LIMIT=2048
for i=1,LIMIT do pixels[i]=0 end
local function edgeX(p,q,y)if(p[2]<=y and q[2]>y)or(q[2]<=y and p[2]>y)then return p[1]+(y-p[2])*(q[1]-p[1])/(q[2]-p[2])end end
for y=1,16 do rowPool[y]={}end
local function paintTile(x,y,w,h,ox,oy,stride)
 for k in pairs(seen)do seen[k]=nil end
 local colors=0
 for yy=0,h-1 do local pos=(y+yy-oy)*stride+x-ox+1
  for xx=0,w-1 do local ink=pixels[pos+xx]or 0;if not seen[ink]then seen[ink]=true;colors=colors+1 end end
 end
 if colors>16 then
  if w>=h and w>1 then local a=w//2;paintTile(x,y,a,h,ox,oy,stride);paintTile(x+a,y,w-a,h,ox,oy,stride)
  elseif h>1 then local a=h//2;paintTile(x,y,w,a,ox,oy,stride);paintTile(x,y+a,w,h-a,ox,oy,stride)end
  return
 end
 if colors==1 and seen[0]then return end
 for yy=1,h do local row=rowPool[yy];local pos=(y+yy-1-oy)*stride+x-ox+1
  for xx=1,w do row[xx]=pixels[pos+xx-1]or 0 end
  for xx=w+1,#row do row[xx]=nil end;rows[yy]=row
 end
 for yy=h+1,#rows do rows[yy]=nil end
 if not B.disabled then local ok,result=pcall(ui.img,rows,x,y);if not ok or result==false then B.disabled=true;B.lastError=tostring(result);print('BATCH724 '..B.lastError)else B.tiles=B.tiles+1;if not B.announced then B.announced=true;print('BATCH724 ACTIVE full original mesh')end end end
end
function B.draw(faces)
 if B.disabled or type(ui.img)~='function'or not faces or #faces==0 then return false end
 local minx,miny,maxx,maxy=480,270,-1,-1
 for _,f in ipairs(faces)do for i=1,3 do local p=f[i];minx=math.min(minx,p[1]);maxx=math.max(maxx,p[1]);miny=math.min(miny,p[2]);maxy=math.max(maxy,p[2])end end
 minx=math.max(0,math.floor(minx));maxx=math.min(479,math.ceil(maxx));miny=math.max(16,math.floor(miny));maxy=math.min(269,math.ceil(maxy))
 if minx>maxx or miny>maxy then return true end
 local width=maxx-minx+1;local band=math.max(1,LIMIT//width);B.calls=B.calls+1
 for top=miny,maxy,band do local bottom=math.min(maxy,top+band-1);local count=width*(bottom-top+1)
  for i=1,count do pixels[i]=0 end
  for _,f in ipairs(faces)do local a,b,c=f[1],f[2],f[3]
   local y0=math.max(top,math.ceil(math.min(a[2],b[2],c[2])-.5));local y1=math.min(bottom,math.ceil(math.max(a[2],b[2],c[2])-.5)-1)
   for y=y0,y1 do local cy=y+.5;local lo,hi
    local x1,x2,x3=edgeX(a,b,cy),edgeX(b,c,cy),edgeX(c,a,cy)
    if x1 then lo=x1 end
    if x2 then if lo then lo,hi=math.min(lo,x2),math.max(lo,x2)else lo=x2 end end
    if x3 then if lo then lo,hi=math.min(lo,x3),math.max(hi or lo,x3)else lo=x3 end end
    if lo and hi then local x0=math.max(minx,math.ceil(lo-.5));local x1=math.min(maxx,math.ceil(hi-.5)-1);local base=(y-top)*width-minx+1
     for x=x0,x1 do pixels[base+x]=f[5]end
    end
   end
  end
  for y=top,bottom,16 do for x=minx,maxx,32 do paintTile(x,y,math.min(32,maxx-x+1),math.min(16,bottom-y+1),minx,top,width)end end
 end
 return not B.disabled
end
return B

