local G=require('combat164')
G.preparePose('idle',1)
for i=1,408 do G.blendVertex(i,i/408,.5,0)end
collectgarbage('collect');collectgarbage('stop');local start=collectgarbage('count')
for n=1,1000 do
 G.preparePose(n%2==0 and 'idle'or 'ready',1/60)
 for i=1,408 do G.blendVertex(i,i/408,.5,0)end
end
local growth=collectgarbage('count')-start;collectgarbage('restart')
assert(growth<4,'stance changes allocate vertex tables: '..growth)
print(string.format('PASS 1000 stance transitions: %.2f KB accumulated allocation',growth))
