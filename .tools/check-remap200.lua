-- The pipeline may assign any stable index order to the PNG RGB555 carrier keys.
local S=require('street196');local refs=dofile('.tools/sprites196.lua');local original=dofile('.tools/palette142.lua')
local positions={};for i=1,408 do positions[i]={0,0,0}end
local buffers={vertices=positions,faces={},pool={}}
local actor={triangles='',palette={},clips={}}
S.setup(actor,refs,buffers,original)
local reference={};S.backgroundPalette(function(i,v)reference[i]=v end)
local function verify(master)
 S.setup(actor,refs,buffers,master)
 local actual={};S.backgroundPalette(function(i,v)assert(i>=0 and i<224);actual[i]=v end)
 local index={};for i,color in ipairs(master)do index[color]=i-1 end
 for i=2,#original do
  local native=index[original[i]]
  assert(actual[native]==reference[i-1],'background color changed after palette reindexing at '..i)
 end
end
-- Keep transparent index 0; reverse and rotate opaque slots, including opaque RGB 0.
local reverse={original[1]};for i=#original,2,-1 do reverse[#reverse+1]=original[i]end;verify(reverse)
for shift=1,203,17 do
 local moved={original[1]};for i=0,#original-2 do moved[#moved+1]=original[2+(i+shift)%(#original-1)]end
 verify(moved)
end
local incomplete={0,1};local ok,err=pcall(S.setup,actor,refs,buffers,incomplete);assert(not ok and tostring(err):find('Cor da rua ausente'))
print('PASS 13 reordered native palettes, every opaque carrier color, transparent slot and incomplete-palette recovery')
