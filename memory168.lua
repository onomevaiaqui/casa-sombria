-- One decoded depth state and one shared camera base; exact XOR/RLE deltas.
local M={};local previous,depth,baseKey,baseDepth
function M.release()previous,depth,baseKey,baseDepth=nil,nil,nil,nil end
local function expand(packed)
 local parts,chunk={},{}
 for i=1,#packed,2 do
  local n,v=packed:byte(i,i+1);chunk[#chunk+1]=string.rep(string.char(v),n)
  if #chunk==256 then parts[#parts+1]=table.concat(chunk);for j=256,1,-1 do chunk[j]=nil end end
 end
 if #chunk>0 then parts[#parts+1]=table.concat(chunk)end
 return table.concat(parts)
end
local function delta(base,packed)
 local parts,chunk={},{};local cursor=1
 for i=1,#packed,2 do
  local n,v=packed:byte(i,i+1)
  if v==0 then chunk[#chunk+1]=base:sub(cursor,cursor+n-1)
  else
   local changed={}
   for j=cursor,cursor+n-1 do changed[#changed+1]=string.char(base:byte(j)~v)end
   chunk[#chunk+1]=table.concat(changed)
  end
  cursor=cursor+n
  if #chunk==256 then parts[#parts+1]=table.concat(chunk);for j=256,1,-1 do chunk[j]=nil end end
 end
 assert(cursor==#base+1,'Incomplete depth delta')
 if #chunk>0 then parts[#parts+1]=table.concat(chunk)end
 return table.concat(parts)
end
function M.depth(s)
 if previous~=s then
  previous,depth=nil,nil
  if s.depthBasePacked then
   if baseKey~=s.depthBasePacked then baseDepth=expand(s.depthBasePacked);baseKey=s.depthBasePacked end
   depth=#s.depthPacked==0 and baseDepth or delta(baseDepth,s.depthPacked)
  else
   baseKey,baseDepth=nil,nil;depth=expand(s.depthPacked)
  end
  assert(#depth==s.depthWidth*s.depthHeight,'Incomplete depth buffer');previous=s
 end
 return depth
end
return M
