local cache=type(package)=='table'and package.loaded or nil
local D=require('facility_data363')
local cinema=require('cinema356')
local M={cameras=D.cameras,palette={},doors={},bits=0,current='loja'}
for i=1,205 do M.palette[i]=0 end
local depth,key
function M.enter(r)assert(D.rooms[r],'Comodo ausente');M.current=r;M.release()end
function M.room()return M.current end
local titles415={c39p_sala='SALA',c39p_cozinha='COZINHA',c39p_casal='QUARTO CASAL',c39p_solteiro='QUARTO DUAS CAMAS',c39p_banho='BANHEIRO',c39p_corredor='CORREDOR'}
function M.roomTitle()local c=M.selected415 and D.cameras[M.selected415];return M.current=='c39teste'and c and('CASA 39 - '..(titles415[c.name]or'INTERIOR'))or D.rooms[M.current].title end
function M.walkable(x,y)
 local r=D.rooms[M.current];if r.obb409 then local within=false;for j,f in ipairs(r.floor403)do if (j==2 and x>f[1]and x<f[3]and y>f[2]and y<f[4])or(x>f[1]+.18 and x<f[3]-.18 and y>f[2]+.18 and y<f[4]-.18)then within=true end end;if not within then return false end end;if r.floor403 then local free=false;for _,f in ipairs(r.floor403)do if x>=f[1]and x<=f[3]and y>=f[2]and y<=f[4]then free=true end end;if not free then return false end end;if r.obb409 then for _,o in ipairs(r.obb409)do local dx,dy=x-o.x,y-o.y;local cs,sn=math.cos(o.angle),math.sin(o.angle);if math.abs(dx*cs+dy*sn)<o.half[1]+.18 and math.abs(-dx*sn+dy*cs)<o.half[2]+.18 then return false end end end;if x<=(r.minX426 and r.minX426+.18 or .23)or y<=.23 or x>=r.size[1]-.23 or y>=r.size[2]-.23 then return false end
 if r.field then local f=r.field;local free=x>f[1]and y>f[2]and x<f[3]and y<f[4];for i=1,#r.path-1 do local a,b=r.path[i],r.path[i+1];local dx,dy=b[1]-a[1],b[2]-a[2];local t=math.max(0,math.min(1,((x-a[1])*dx+(y-a[2])*dy)/(dx*dx+dy*dy)));if(x-a[1]-t*dx)^2+(y-a[2]-t*dy)^2<1.05^2 then free=true end end;if not free then return false end end
 local margin=r.obb409 and .1811 or r.floor403 and .16 or .22;for _,b in ipairs(r.boxes)do if x>b[1]-margin and x<b[3]+margin and y>b[2]-margin and y<b[4]+margin then return false end end
 return true
end
function M.defaultSpawn()
 local r=D.rooms[M.current];local best,score
 for y=.55,r.size[2]-.4,.25 do for x=.55,r.size[1]-.4,.25 do if M.walkable(x,y)then local d=(x-r.size[1]/2)^2+(y-r.size[2]/2)^2;if not score or d<score then best,score={x,y,0},d end end end end
 return assert(best,'Comodo sem area livre')
end
function M.selectCamera(x,y,old)
 local i=cinema.select(D.cameras,x,y,old,M.current);if M.current=='c39quintal'and x>.65 and x<9.5 and y>15.8 then for k,c in ipairs(D.cameras)do if c.name=='q409_integrada_0'and cinema.sees(c,x,y)and cinema.framing(c,x,y)>7 then i=k;break end end end;if M.current=='c39quintal'and x>8.5 and y>5.5 and y<9 then for k,c in ipairs(D.cameras)do if c.name=='q421_patio_direito'and cinema.sees(c,x,y)and cinema.framing(c,x,y)>6 then i=k;break end end end;if M.current=='c39quintal'and x>6 and x<8 and y>5.5 and y<7 then for k,c in ipairs(D.cameras)do if c.name=='q421_porta_frente'and cinema.sees(c,x,y)and cinema.framing(c,x,y)>6 then i=k;break end end end;if M.current=='c39quintal'and x>6.1 and x<8.5 and y>15.6 then for k,c in ipairs(D.cameras)do if c.name=='q420_fundos_porta'and cinema.sees(c,x,y)and cinema.framing(c,x,y)>6 then i=k;break end end end;if M.current=='c39quintal'and x>9.1 and x<9.5 and y>5.6 and y<6.1 and cinema.framing(D.cameras[52],x,y)>10 then i=52 end;if M.current=='c39quintal'and x<.3 and y>6.37 then local k=y<12.6 and 47 or 53;if cinema.sees(D.cameras[k],x,y)and cinema.framing(D.cameras[k],x,y)>7 then i=k end end;if M.current=='c39quintal'and x> -5.7 and x<9 and y>17.5 and cinema.sees(D.cameras[55],x,y)and cinema.framing(D.cameras[55],x,y)>7 then i=55 end;if M.current=='c39quintal'and(x+4.925)^2+(y-16.3)^2<2.5 and cinema.sees(D.cameras[62],x,y)and cinema.framing(D.cameras[62],x,y)>7 then i=62 end;if M.current=='c39quintal'and x>10.8 and y>12 then local k=y<15.4 and 48 or 60;if cinema.sees(D.cameras[k],x,y)and cinema.framing(D.cameras[k],x,y)>4 then i=k end end;M.selected415=i;local bank=D.cameras[i].bank
 for j=1,#bank do M.palette[j]=bank[j]end
 return i
end
function M.prefix(i)return D.cameras[i].prefix end
function M.prepare(i)
 local n=D.cameras[i].depth;if key==n then return end
 depth=nil;cinema.pressure();depth=cinema.unpack(require(n));key=n;assert(#depth==8160)
 if cache then cache[n]=nil end
end
function M.triangleVisible(a,b,c)
 local depth=M.shedDepth442 or depth
 local ix,iy=math.floor((a[1]+b[1]+c[1])/12),math.floor((a[2]+b[2]+c[2])/3*68/270)
 if not depth or ix<0 or ix>=120 or iy<0 or iy>=68 then return false end
 return (depth:byte(iy*120+ix+1)or 255)==255 or (a[3]+b[3]+c[3])/3<=(depth:byte(iy*120+ix+1)or 255)/10+.14
end
function M.action(x,y)
 if M.current=='c39quintal'then
 if(x-6.94)^2+(y-6.65)^2<1 then return 'A entrada e pelos fundos. Esta porta abre por dentro.'end
 if(x-6.94)^2+(y-16.05)^2<1 then return {enterHouse409='rear'}end
 if(x+4.925)^2+(y-16.3)^2<1 then return {shedDoor433=true}end
 if y<2.5 and x>4.5 and x<6.1 then M.exitStreet416=true;return 'exit_facility'end
  if x>12.6 and y>4.2 and y<8.5 then M.exitStreet416=false;return 'exit_facility'end
 return 'Trilha pelos fundos. J: examinar portas e acessos.'
 elseif M.current=='c39casinha'then if(x-.7)^2+(y-.35)^2<1 then return {shedExit442=true}end;return 'Um deposito de madeira.'end
 if M.current=='c39teste'then if(x-4.94)^2+(y-1.86)^2<.9^2 then M.exitNorth403=false;return 'exit_facility'elseif(x-4.44)^2+(y-9.66)^2<.9^2 then M.exitNorth403=true;return 'exit_facility'end;return 'Portas internas abertas.'end
 local r=D.rooms[M.current]
 for _,p in ipairs(r.portals)do
  local px=p.side=='west'and 0 or p.side=='east'and r.size[1]or p.at
  local py=p.side=='south'and 0 or p.side=='north'and r.size[2]or p.at
  if (x-px)^2+(y-py)^2<(M.current=='campo'and 1.6 or 1.05)^2 then
   if p.to=='outside'then return 'exit_facility'end
   return {facilityRoom=p.to,spawn=p.arrival}
  end
 end
end
function M.release()depth,key=nil,nil;M.shedDepth442=nil end
return M
