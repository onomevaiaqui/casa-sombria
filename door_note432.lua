local N={phase=0,choice=1}
N.text={'Filha,','Seu irmao foi jogar bola e levou a chave.','Ele deve estar no campinho.','- Mae'}

function N.busy()return N.phase>0 end
function N.begin(inventory)
 if inventory.collected.house39_door_note_seen then return false end
 inventory.collected.house39_door_note_seen=true
 N.inventory=inventory;N.phase=1;N.choice=1;N.left=false;N.right=false
 return true
end
function N.tick(confirm,cancel,left,right)
 if N.phase==0 then return end
 if cancel then N.phase=0;return end
 if N.phase==3 then
  if left and not N.left then N.choice=1 end
  if right and not N.right then N.choice=2 end
 end
 N.left,N.right=left,right
 if not confirm then return end
 if N.phase<3 then N.phase=N.phase+1
 elseif N.phase==3 then
  if N.choice==1 then N.phase=4;N.inventory.collected.house39_door_note_read=true;N.inventory:collect({id='mother_note39',document=true})
  else N.phase=0 end
 else N.phase=0 end
end
function N.draw(ui)
 if N.phase==0 then return end
 if N.phase==4 then
  ui.rectfill(16,79,463,222,241)
  ui.print('BILHETE NA PORTA',30,94,240)
  for i,line in ipairs(N.text)do ui.print(line,30,112+(i-1)*21,240)end
  ui.print('B ou A: fechar',30,204,240)
 else
  ui.rectfill(0,215,479,269,240)
  ui.print(N.phase==1 and 'A porta esta trancada.'or N.phase==2 and 'Ha um bilhete preso na porta.'or'Ler o bilhete?',8,225,241)
  ui.print(N.phase==3 and(N.choice==1 and '> Sim      Nao'or'  Sim    > Nao')or'B: continuar   A: fechar',8,248,241)
 end
end
return N
