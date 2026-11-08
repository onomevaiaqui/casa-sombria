local original=dofile('.tools/memory165-reference.lua')
local function hash(s)local a,b=1,0;for i=1,#s do a=(a+s:byte(i))%65521;b=(b+a)%65521 end;return b*65536+a end
local current=require('camera_data155');local memory=require('memory165');local states=0
for room,views in pairs(original)do
 local actual=current[room];assert(#actual==#views,room)
 assert(package.loaded['camera_mem165_'..room]==nil,'room pinned in require cache')
 for i,c in ipairs(views)do
  local v=actual[i];assert(hash(v.visibility)==c.visibility,room..' visibility changed')
  for mask,s in pairs(c.states)do
   local t=v.states[mask];assert(t.prefix==s[2] and hash(memory.depth(t))==s[1],'depth changed: '..room..' '..mask)
   states=states+1
  end
 end
end
print('PASS '..states..' native camera/door states: depth and visibility byte-for-byte identical; require room cache released')
