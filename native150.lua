-- Optional native broad phase; Lua keeps the exact strict boundary convention.
local N={enabled=false,rects={},calls=0}
local circle={x=0,y=0,r=.25}
local overlap
function N.bind(api)
 N.enabled=false;overlap=nil
 if type(api)~='table'or type(api.circ_rect_overlap)~='function'then return false end
 local fn=api.circ_rect_overlap
 local cases={{.5,.5,true},{-.1,.5,true},{1.1,1.1,true},{-2,.5,false},{2,2,false},{.5,2,false}}
 local rect={x=0,y=0,w=1,h=1}
 for _,c in ipairs(cases)do
  circle.x,circle.y=c[1],c[2]
  local ok,v=pcall(fn,circle,rect)
  if not ok or type(v)~='boolean'or v~=c[3]then return false end
 end
 overlap=fn;N.enabled=true;return true
end
function N.prepare(rooms)
 for _,boxes in pairs(rooms)do for _,b in ipairs(boxes)do N.rects[b]={x=b[1],y=b[3],w=b[2]-b[1],h=b[4]-b[3]}end end
end
function N.blocked(x,y,r,b)
 circle.x,circle.y,circle.r=x,y,r;N.calls=N.calls+1
 if not overlap(circle,N.rects[b])then return false end
 local nx,ny=math.max(b[1],math.min(b[2],x)),math.max(b[3],math.min(b[4],y))
 return(x-nx)^2+(y-ny)^2<r*r
end
N.bind(util)
return N
