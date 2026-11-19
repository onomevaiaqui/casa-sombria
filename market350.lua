local cameraModuleCache=type(package)=='table'and package.loaded or nil
local D=require('market_data350')
local M={cameras=D.cameras,palette=D.palette,doors={},bits=0}
local inventory,depth,key
function M.enter(inv)inventory=inv;M.release()end
function M.room(x,y)return y>5.6 and 'deposito'or 'vendas'end
function M.state()local f=inventory and inventory.collected or{};return(f.market_stock_open and 1 or 0)+(f.market_front_open and 2 or 0)end
function M.walkable(x,y)
 if x<=.22 or x>=9.78 or y<=.22 or y>=7.28 then return false end
 for _,b in ipairs(D.boxes)do if x>b[1]-.40 and x<b[3]+.40 and y>b[2]-.30 and y<b[4]+.30 then return false end end
 local flags=inventory and inventory.collected or{}
 if math.abs(y-5.6)<.27 and(not flags.market_stock_open or x<6.98 or x>7.62)then return false end
 if flags.market_stock_open and x>6.65 and x<7.03 and y>5.6 and y<6.65 then return false end
 if not flags.market_front_open and y<.45 and x>3.3 and x<6.7 then return false end
 return true
end
local function sees(c,x,y)
 local g=c.grid;local gx,gy=math.floor((x-g.x0)/g.step+.5),math.floor((y-g.y0)/g.step+.5)
 if gx<0 or gy<0 or gx>=g.w or gy>=g.h then return false end
 local n=gy*g.w+gx;return ((c.vis:byte(n//8+1)or 0)>>(n%8))&1==1
end
function M.clearance(c,x,y)
 local edge=1e6
 for _,z in ipairs({0,1.8})do local m=c.m;local w=m[4][1]*x+m[4][2]*y+m[4][3]*z+m[4][4];if w<.15 then return-1e6 end
 local sx=((m[1][1]*x+m[1][2]*y+m[1][3]*z+m[1][4])/w+1)*240;local sy=(1-(m[2][1]*x+m[2][2]*y+m[2][3]*z+m[2][4])/w)*135;edge=math.min(edge,sx-6,474-sx,sy-16,264-sy)end
 return edge
end
function M.selectCamera(x,y,old)
 local region=M.room(x,y)
 if old and D.cameras[old].room==region and sees(D.cameras[old],x,y)and M.clearance(D.cameras[old],x,y)>8 then return old end
 local best,score=old or 1,-1e9
 for i,c in ipairs(D.cameras)do if sees(c,x,y)then local v=M.clearance(c,x,y)+(c.room==region and 1000 or 0)+(i==old and 12 or 0);if v>score then best,score=i,v end end end
 return best
end
function M.prefix(i)return 'm350_'..D.cameras[i].name..M.state()end
function M.prepare(i)
 local camera=D.cameras[i];if camera.cineDepth then local n=camera.cineDepth..tostring(M.state());if key==n then return end;require('cinema356').pressure();local raw=require(n);depth=require('cinema356').unpack(raw);key=n;assert(#depth==8160);if type(package)=='table'and package.loaded then package.loaded[n]=nil end;return end

 local n='m350d_'..D.cameras[i].name..M.state();if key==n then return end
 require('cinema356').pressure();local raw=require(n);local chunks={};for j=1,#raw,2 do local count,value=raw:byte(j,j+1);chunks[#chunks+1]=string.rep(string.char(value),count)end
 depth=table.concat(chunks);key=n;assert(#depth==8160,'Profundidade do mercado incompleta')
 if type(package)=='table'and package.loaded then package.loaded[n]=nil end
end
function M.triangleVisible(a,b,c)
 local x,y,z=(a[1]+b[1]+c[1])/3,(a[2]+b[2]+c[2])/3,(a[3]+b[3]+c[3])/3;local ix,iy=math.floor(x/4),math.floor(y*68/270)
 return depth and ix>=0 and ix<120 and iy>=0 and iy<68 and z<=(depth:byte(iy*120+ix+1)or 255)/10+.14
end
function M.planDoor()end
function M.action()end
function M.release()depth,key=nil,nil end

local cinema=require('cinema356')
function M.selectCamera(x,y,previous)return cinema.select(D.cameras,x,y,previous,M.room(x,y))end
function M.prefix(i)local c=D.cameras[i];return c.cinePrefix..tostring(M.state())end
return M
