local S={opened=false}
local data,cachedFrame,cachedDepth
function S.release()data=nil;cachedFrame=nil;cachedDepth=nil;if type(package)=='table'and package.loaded then package.loaded.shed442_frames=nil end end
function S.draw(ui,room,shot,inv)
 if room~='c39quintal'or shot~=62 or not inv or not inv.collected.house39_shed_open then return end
 data=data or require('shed442_frames');local family,door,frame=require('interaction287').doorVisual();if family~='shed442'then frame=S.opened and 9 or 1 end
 local f=data.frames[frame];local raw=f.image;for i=1,#raw,5 do local lo,hi,y,n,color=raw:byte(i,i+4);local x=lo+hi*256;ui.line(x,y,x+n-1,y,data.slots[color])end
 if cachedFrame~=frame then local out={};for i=1,#f.depth,2 do local n,c=f.depth:byte(i,i+1);out[#out+1]=string.rep(string.char(c),n)end;cachedDepth=table.concat(out);cachedFrame=frame end
 return cachedDepth
end
return S
