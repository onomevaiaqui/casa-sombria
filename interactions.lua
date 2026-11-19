local I={}
I.paintings={
 id='sala_quadros',room='sala',x1=1.23,x2=2.15,y1=1.45,y2=3.45,
 lookX=-1,lookY=0,
 pages={
  'Um quadro representando dois rockeiros e o outro uma mulher na banheira. Léli 2015',
  'Parece uma ótima pintora'
 }
}
I.ghostGirl={id='ghost_girl_swing',room='quintal',lookX=0,lookY=1,pages={'Mamãe foi brincar na árvore.'}}
function I.nearby(room,x,y)
 if room=='quintal'and (x-1.4585)^2+(y-7.676)^2<1.4^2 then
  local d=math.max(.001,math.sqrt((x-1.4585)^2+(y-7.676)^2));I.ghostGirl.lookX=(1.4585-x)/d;I.ghostGirl.lookY=(7.676-y)/d;return I.ghostGirl
 end
 local p=I.paintings
 if room==p.room and x>=p.x1 and x<=p.x2 and y>=p.y1 and y<=p.y2 then return p end
end
return I
