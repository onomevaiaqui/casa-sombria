-- A single decompressed camera/door-state depth buffer, never all states.
local M={};local previous,depth
function M.depth(s)
 if previous~=s then
  local parts={};for i=1,#s.depthRle,4 do
   local n=tonumber(s.depthRle:sub(i,i+1),16);local v=tonumber(s.depthRle:sub(i+2,i+3),16)
   parts[#parts+1]=string.rep(string.char(v),n)
  end
  depth=table.concat(parts);previous=s
 end
 return depth
end
return M
