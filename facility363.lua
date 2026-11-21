local cache=type(package)=='table'and package.loaded or nil
local D
local loadedData
local cinema=require('cinema356')
local M={cameras={},palette={},doors={},bits=0,current='loja'}
for i=1,205 do M.palette[i]=0 end
local progress675={}
function M.bind675(collected)progress675=collected or {};M.release()end
function M.boardsOpen675()return progress675.c39_boards675_open==true end
function M.hit675(x,y,angle,equipped)
 if M.current~='c39quintal'or M.boardsOpen675()or(x-15.16)^2+(y-4.76)^2>1.5^2 then return end
 if equipped~='crowbar'then return 'Preciso da machadinha para remover as tabuas.'end
 local dx,dy=15.16-x,4.76-y;local n=math.sqrt(dx*dx+dy*dy)
 if n>.05 and(math.sin(angle)*dx-math.cos(angle)*dy)/n<.60 then return end
 progress675.c39_boards675_hits=(progress675.c39_boards675_hits or 0)+1
 if progress675.c39_boards675_hits>=3 then progress675.c39_boards675_open=true;M.release();return 'As tabuas cederam. A passagem esta livre.'end
 return 'A madeira esta cedendo...'
end
local depth,key
function M.enter(r)
 M.release()
 local name='facility_room697_'..r
 if loadedData~=name then
  D=nil;M.cameras={};if cache and loadedData then cache[loadedData]=nil end
  cinema.pressure();collectgarbage('collect')
  D=require(name);loadedData=name;if cache then cache[name]=nil end
 end
 assert(D.rooms[r],'Comodo ausente');M.cameras=D.cameras;M.current=r
end
function M.room()return M.current end
local titles415={c39p_sala='SALA',c39p_cozinha='COZINHA',c39p_casal='QUARTO CASAL',c39p_solteiro='QUARTO SOLTEIRO',c39p_banho='BANHEIRO',c39p_corredor='CORREDOR'}
function M.roomTitle()local c=M.selected415 and D.cameras[M.selected415];return M.current=='c39teste'and c and('CASA 39 - '..(titles415[c.name:gsub('_%d+$','')]or'INTERIOR'))or D.rooms[M.current].title end
function M.actorColor(color,x,y)
 if M.current=='c39casinha'then return require('lighting593').color(color,'c39_shed',x,y)end
 if M.current=='c39quintal'then return require('lighting593').color(color,'c39_quintal',x,y)end
 if M.current~='c39teste'then return color end
 local zone=x>=3.60 and(y>=5.57 and'cozinha'or'sala')or y<4.25 and'casal'or y>6.80 and'solteiro'or x<2.45 and'banho'or'corredor'
 return require('lighting593').color(color,'c39_'..zone,x,y)
end
function M.walkable(x,y)
 if M.current=='c39quintal'and not require('shed442').opened and math.abs(x+4.925)<.65 and y>15.7 and y<16.06 then return false end
 if M.current=='c39casinha'and not require('shed442').opened and math.abs(x-2.2)<.65 and y<.50 then return false end

 if M.current=='c39quintal'then
  -- Solid boundary faces: keep the actor radius on the yard side.
  if y>=19.19 or (x<=-5.73 and y>=6.37)then return false end
  -- Replacement wall across the old shed, including both end joints.
  if x>=10.38 and y>11.20 and y<11.86 then return false end
 end

 if M.current=='c39quintal'and not M.boardsOpen675()and x>14.91 and x<15.49 and y>4.0 and y<5.52 then return false end
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
 if M.current=='c39casinha'then
  local exitIndex
  for k,c in ipairs(D.cameras)do if c.name=='shed690_saida'then exitIndex=k;break end end
  local towardExit=y<1.15 or(old==exitIndex and y<1.45)
  local k=towardExit and exitIndex or 49
  if k then M.selected415=k;local bank=D.cameras[k].bank;for j=1,#bank do M.palette[j]=bank[j]end;return k end
 end

 if M.current=='campo'and x>=4.5 and x<=22.5 and y>=22 and y<=38.8 then
  for k,c in ipairs(D.cameras)do if c.name=='campo_10'and cinema.sees(c,x,y)and cinema.framing(c,x,y)>7 then
   M.selected415=k;for j=1,#c.bank do M.palette[j]=c.bank[j]end;return k
  end end
 end

 -- Prefer the approved window-silhouette shot throughout its unobstructed bedroom sector.
 local preferred668
 if M.current=='c39teste' and x<3.60 and y>6.80 then
  for k,c in ipairs(D.cameras)do if c.name=='c39p_solteiro_4' and cinema.sees(c,x,y) and cinema.framing(c,x,y)>=8 then preferred668=k;break end end
 end
 local restricted693
 if M.current=='c39quintal'and y>=11.2 then local c=D.cameras[52];restricted693={c,c.rejected368};c.rejected368=true end
 local restricted674
 if M.current=='c39quintal' and x>=6.0 then
  for _,c in ipairs(D.cameras)do if c.name=='q409_frente-trilha'then restricted674={c,c.rejected368};c.rejected368=true;break end end
 end
 local i=preferred668 or cinema.select(D.cameras,x,y,old,M.current);
 if restricted693 then restricted693[1].rejected368=restricted693[2]end
 if restricted674 then restricted674[1].rejected368=restricted674[2]end;M.selected415=i;local selected=D.cameras[i];local bank=M.boardsOpen675()and(selected.bank675open or selected.bank)or selected.bank
 for j=1,#bank do M.palette[j]=bank[j]end
 return i
end
function M.prefix(i)local c=D.cameras[i];return M.boardsOpen675()and(c.prefix675open or c.prefix)or c.prefix end
function M.prepare(i)
 local c=D.cameras[i];local n=M.boardsOpen675()and(c.depth675open or c.depth)or c.depth;if key==n then return end
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
  if x>14.0 and y>4.05 and y<5.48 then
   if not M.boardsOpen675()then return 'A passagem esta bloqueada. A madeira esta podre... Talvez ceda com uma ferramenta.'end
   if x>14.65 then M.exitStreet416=false;return 'exit_facility'end
   return 'A passagem pelo muro esta livre.'
  end
 return 'Trilha pelos fundos. J: examinar portas e acessos.'
 elseif M.current=='c39casinha'then if(x-2.2)^2+(y-.35)^2<1 then return {shedExit442=true}end;return 'Um deposito de madeira.'end
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
