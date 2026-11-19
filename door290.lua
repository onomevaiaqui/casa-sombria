local M={}
local D=require('door290_data')
local I=require('interaction287')
function M.draw(family,room,shot,ui,refs)
 local f,id,frame=I.doorVisual();if f~=family then return end
 local key=family..'_'..room..'_'..tostring(shot)..'_'..id
 local d=D[key];if not d then return end
 for _,tile in ipairs(d[frame])do local ref=refs[tile[1]];if ref then ui.spr(ref,tile[2],tile[3])end end
end
return M
