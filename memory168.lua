-- Packed run/count pairs; one decoded state and bounded scratch space.
local M={};local previous,depth
function M.release()previous=nil;depth=nil end
function M.depth(s)
 if previous~=s then
  previous=nil;depth=nil
  local parts,chunk={},{};local packed=s.depthPacked
  for i=1,#packed,2 do
   local n,v=packed:byte(i,i+1);chunk[#chunk+1]=string.rep(string.char(v),n)
   if #chunk==256 then parts[#parts+1]=table.concat(chunk);for j=256,1,-1 do chunk[j]=nil end end
  end
  if #chunk>0 then parts[#parts+1]=table.concat(chunk)end
  depth=table.concat(parts);previous=s
 end
 return depth
end
return M
