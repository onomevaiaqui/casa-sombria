local M={phase=nil,choice=1}
function M.ask(x,y,inv)
 if (x-.88)^2+(y-6.10)^2>.78^2 then return false end
 M.phase='closed';M.choice=1;return true
end
function M.cancel()M.phase=nil end
function M.busy()return M.phase~=nil end
function M.draw()end
function M.input(left,right,confirm,cancel,inv)
 if cancel then M.cancel();return end
 if not M.phase then return end
 if M.phase=='confirm'then
  if left and not M.left then M.choice=1 end
  if right and not M.right then M.choice=2 end
 end
 M.left,M.right=left,right
 if not confirm then return end
 if M.phase=='closed'then M.phase=inv.collected.remedy_r05 and'empty'or'open'
 elseif M.phase=='open'then M.phase='confirm';M.choice=1
 elseif M.phase=='confirm'then
  if M.choice==2 then M.phase='open';return end
  local result=inv:collect({id='remedy_r05'})
  if result=='INVENTARIO CHEIO'then M.phase='open';return 'O inventario esta cheio.'end
  M.phase='empty';return 'Frasco de remedio guardado. Recupera 2 pontos de vida.'
 end
end
function M.prompt(ui,refs,inv)
 if not M.phase then return end
 local state=M.phase=='confirm'and'open'or M.phase
 local bank=require('med672_banks')[state];for i,c in ipairs(bank)do ui.palset(i-1,c)end
 for i=0,2 do ui.spr(assert(refs['med672_'..state..'_'..i]),0,i*90)end
 ui.palset(240,1057);ui.palset(241,32767);ui.rectfill(0,234,479,269,240)
 local text=M.phase=='closed'and'B: ABRIR ARMARIO    A: VOLTAR'or M.phase=='open'and'B: PEGAR FRASCO DE REMEDIO    A: VOLTAR'or M.phase=='empty'and'O armario esta vazio.    A: VOLTAR'or(M.choice==1 and'Pegar o frasco?   > SIM     NAO'or'Pegar o frasco?     SIM   > NAO')
 ui.print(text,18,248,241)
end
return M
