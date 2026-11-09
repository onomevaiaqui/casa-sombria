local G=require('gc150');assert(G.configure());assert(G.configured)
if _VERSION=='Lua 5.5'then assert(G.api=='5.5');assert(not pcall(collectgarbage,'setpause',140))end
local T=require('frame_time');T.details=true;local labels={}
local values={[0]=2*1024*1024,[1]=73,[7]=15}
local ui={stat=function(i)return values[i]end,rectfill=function()end,print=function(s)labels[#labels+1]=s end}
T.sample(ui);T.hud(ui);assert(T.dt==1/15 and T.cpu==73 and T.luaBytes==2097152)
assert(labels[1]:match('15FPS C73%%')and labels[1]:match('L2048K P2048K GG'))
values[0]=1024*1024;T.sample(ui);assert(T.peakBytes==2097152,'sample high-water lost')
ui.stat=nil;T.sample(ui);assert(type(T.luaBytes)=='number','memory fallback missing')
print('PASS FPS/CPU/Lua-memory HUD and '..G.api..' GC configuration without changing movement dt')
