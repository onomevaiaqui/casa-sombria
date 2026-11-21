local N={phase=0,choice=1}
N.text={'Filha,','Seu irmao foi jogar bola e levou a chave.','Ele deve estar no campinho.'}

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
 elseif N.phase==4 then N.phase=5
 elseif N.phase==5 then N.phase=4 end
end
function N.draw(ui)
 if N.phase==0 then return end
 if N.phase==4 or N.phase==5 then
  local sprites=require('sprite_refs656');local colors=require('note649_palette')
  ui.palset(240,0);ui.palset(241,32767);ui.cls(240)
  for i,v in ipairs(colors)do if N.phase==5 then v=math.floor((v&31)*.32)|(math.floor(((v>>5)&31)*.32)<<5)|(math.floor(((v>>10)&31)*.32)<<10)end;ui.palset(i-1,v)end
  ui.spr(sprites.note649_0,100,5);ui.spr(sprites.note649_1,100,135)
  if N.phase==5 then
   ui.palset(192,29|(28<<5)|(23<<10));ui.palset(193,1|(1<<5)|(1<<10))
   ui.palset(194,22|(22<<5)|(18<<10));ui.palset(195,14|(14<<5)|(12<<10))
   ui.palset(196,11|(12<<5)|(10<<10));ui.palset(198,5|(6<<5)|(5<<10))
   ui.line(24,46,456,46,198);ui.line(24,200,456,200,198)
   ui.spr(sprites.note654_transcript_0,35,52);ui.spr(sprites.note654_transcript_1,35,137)
  end
  ui.print(N.phase==5 and 'B: ver bilhete   A: fechar'or'B: ler   A: fechar',8,251,241)
 else
  ui.rectfill(0,215,479,269,240)
  ui.print(N.phase==1 and 'A porta esta trancada.'or N.phase==2 and 'Ha um bilhete preso na porta.'or'Ler o bilhete?',8,225,241)
  ui.print(N.phase==3 and(N.choice==1 and '> Sim      Nao'or'  Sim    > Nao')or'B: continuar   A: fechar',8,248,241)
 end
end
return N
