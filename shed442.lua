local S={opened=false,progress=0,target=0}
local data,side,frameCache,depthCache,module
local slots={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191}
function S.release()
 data=nil;side=nil;frameCache=nil;depthCache=nil
 if module and type(package)=='table'and package.loaded then package.loaded[module]=nil end;module=nil
 if type(package)=='table'and package.loaded then package.loaded.shed693_out=nil;package.loaded.shed693_in=nil end
end
function S.open()
 if S.target~=1 then S.target=1;require('sound626').emit('porta_abrir')end
end
function S.tick(dt)
 S.progress=math.min(S.target,S.progress+math.max(0,dt or 0)/.85);S.opened=S.progress>=1
end
function S.reset()S.release();S.opened=false;S.progress=0;S.target=0 end
function S.draw(ui,room,shot,inv)
 if not inv or not inv.collected.house39_shed_open then return end
 local wanted=room=='c39quintal'and shot==62 and'out'or(room=='c39casinha'and shot==77 and'in'or nil)
 if not wanted then return end
 if side~=wanted then S.release();side=wanted end
 local t=S.progress*S.progress*(3-2*S.progress);local frame=math.floor(t*8+.5)+1
 if frameCache~=frame then
  data=nil;depthCache=nil
  if module and type(package)=='table'and package.loaded then package.loaded[module]=nil end
  require('cinema356').pressure();module='shed695_'..side..'_'..frame;data=require(module)
 end
 local f=data;local raw=f.image
 for i=1,#raw,5 do local lo,hi,y,n,color=raw:byte(i,i+4);local x=lo+hi*256;ui.line(x,y,x+n-1,y,slots[color])end
 if frameCache~=frame then local out={};for i=1,#f.depth,2 do local n,c=f.depth:byte(i,i+1);out[#out+1]=string.rep(string.char(c),n)end;depthCache=table.concat(out);frameCache=frame end
 return depthCache
end
return S
