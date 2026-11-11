-- Casa 39 pickups. World icons use the existing actor palette; no extra 3D meshes.
local M={active=nil,choice=1}
local pickups={
 {id='pills',room='banheiro',x=3.07,y=7.95,z=1.48,reachX=3.07,reachY=7.05,name='o analgesico'},
}
function M.near(x,y,inv)
 if not inv then return end
 local closest,dist=nil,.7^2
 for _,p in ipairs(pickups)do
  local q=(x-p.reachX)^2+(y-p.reachY)^2
  if not inv.collected[p.id]and q<dist then closest,dist=p,q end
 end
 return closest
end
function M.ask(x,y,inv)
 local p=M.near(x,y,inv)
 if (x-3.07)^2+(y-7.05)^2<.5^2 then
  M.cabinet=true;M.opened=false;M.active=nil;return true
 end
 if not p then return false end
 M.active=p;M.choice=1;M.previousLeft,M.previousRight=true,true;return true
end
function M.busy()return M.active~=nil or M.cabinet==true end
function M.cancel()M.active=nil;M.cabinet=false end
function M.input(left,right,confirm,cancel,inv)
 if M.cabinet and not M.active then
  if cancel then M.cancel()
  elseif confirm then
   if not M.opened then M.opened=true
   elseif not inv.collected.pills then M.active=pickups[1];M.choice=1;M.previousLeft,M.previousRight=true,true
   else return 'O armario esta vazio.'end
  end
  return
 end
 if not M.active then return end
 if cancel then M.cancel();return end
 if left and not M.previousLeft then M.choice=1 end
 if right and not M.previousRight then M.choice=2 end
 M.previousLeft,M.previousRight=left,right
 if confirm then
  local p=M.active;M.cancel()
  if M.choice==1 then
   local result=inv:collect({id=p.id})
   return result=='INVENTARIO CHEIO'and 'O inventario esta cheio.'or 'Item guardado no inventario.'
  end
 end
end
function M.draw()end
function M.prompt(ui,refs,inv)
 if M.cabinet then
  local state=not M.opened and 'closed'or(inv.collected.pills and 'empty'or 'open')
  ui.cls(0)
  for i=0,2 do ui.spr(assert(refs['medcab_'..state..'_'..i],'Imagem do espelho ausente'),0,i*90)end
  ui.rectfill(0,245,479,269,240)
  ui.print(not M.opened and 'B: ABRIR ESPELHO   A: VOLTAR'or(inv.collected.pills and 'O armario esta vazio.   A: VOLTAR'or 'B: PEGAR ANALGESICO   A: VOLTAR'),20,253,241)
 end
 if not M.active then return end
 ui.rectfill(0,225,479,269,240)
 ui.print('Pegar '..M.active.name..'?',32,234,241)
 ui.print(M.choice==1 and '> Sim       Nao'or '  Sim     > Nao',32,252,241)
end
return M
