local D=require('house31_data')
local M={cameras=D.cameras,palette=D.palette,doors={},bits=0}
local depth,key
local function room(x,y)
 if x<2.4 then return 'varanda'end
 if x>6.2 then return y<3.5 and 'quarto'or(y<5.6 and 'banheiro'or 'suite')end
 if y>7.9 then return x<4.1 and 'servico'or 'banho_suite'end
 return y<4.2 and 'sala'or 'cozinha'
end
function M.room(x,y)return room(x,y)end
function M.walkable(x,y)
 if x<=.22 or x>=8.78 or y<=.22 or y>=9.78 then return false end
 for _,b in ipairs(D.boxes)do if x>b[1]-.17 and x<b[3]+.17 and y>b[2]-.17 and y<b[4]+.17 then return false end end
 return true
end
local function sees(c,x,y)
 local gx,gy=math.floor(x/.2+.5),math.floor(y/.2+.5)
 if gx<0 or gx>=46 or gy<0 or gy>=51 then return false end
 local n=gy*46+gx;return ((c.vis:byte(n//8+1)or 0)>>(n%8))&1==1
end
function M.clearance(c,x,y)
 local edge=1e6
 for _,z in ipairs({0,1.8})do local m=c.m;local w=m[4][1]*x+m[4][2]*y+m[4][3]*z+m[4][4];if w<.15 then return -1e6 end
 local sx=((m[1][1]*x+m[1][2]*y+m[1][3]*z+m[1][4])/w+1)*240;local sy=(1-(m[2][1]*x+m[2][2]*y+m[2][3]*z+m[2][4])/w)*135;edge=math.min(edge,sx-6,474-sx,sy-16,264-sy)end
 return edge
end
function M.selectCamera(x,y,old)
 local rn=room(x,y)
 if rn=='varanda'and y<3.0 then for i,c in ipairs(D.cameras)do if c.name=='varanda_hole'and sees(c,x,y)and M.clearance(c,x,y)>2 then return i end end end
 if old and D.cameras[old].room==rn and sees(D.cameras[old],x,y)and M.clearance(D.cameras[old],x,y)>5 then return old end
 local best,score=old or 1,-1e9
 for i,c in ipairs(D.cameras)do if sees(c,x,y)then local v=M.clearance(c,x,y)+(c.room==rn and 1000 or 0)+(i==old and 20 or 0);if v>score then best,score=i,v end end end
 return best
end
function M.prefix(i)return 'h31_'..D.cameras[i].name end
function M.prepare(i)
 local n='h31d_'..D.cameras[i].name;if key==n then return end
 local raw=require(n);local parts={};for j=1,#raw,2 do local a,b=raw:byte(j,j+1);parts[#parts+1]=string.rep(string.char(b),a)end
 depth=table.concat(parts);key=n;assert(#depth==8160)
 if type(package)=='table'and package.loaded then package.loaded[n]=nil end
end
function M.triangleVisible(a,b,c)
 local x,y,z=(a[1]+b[1]+c[1])/3,(a[2]+b[2]+c[2])/3,(a[3]+b[3]+c[3])/3;local ix,iy=math.floor(x/4),math.floor(y*68/270)
 return depth and ix>=0 and ix<120 and iy>=0 and iy<68 and z<=(depth:byte(iy*120+ix+1)or 255)/10+.14
end
function M.planDoor()return nil end
function M.setDoor()end
function M.action(x,y)
 if x<2.3 and y<1 then return 'exit31'end
 for _,p in ipairs({{6.2,2.6},{6.2,4.6},{6.2,6.45},{6.2,8.8},{3.2,7.9},{2.4,5.7},{4.25,0}})do if(x-p[1])^2+(y-p[2])^2<1.1^2 then return 'A porta esta fechada.'end end
 return 'A casa parece abandonada.'
end
function M.release()depth,key=nil,nil end
return M
