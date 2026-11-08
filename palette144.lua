-- Palette state persists in the renderer; suppress identical writes across frames.
local P={writes=0,requests=0}
function P.install(ui)
 local native=ui.palset;local colors={}
 ui.palset=function(index,color)
  P.requests=P.requests+1
  if colors[index]~=color then colors[index]=color;P.writes=P.writes+1;return native(index,color)end
 end
end
return P
