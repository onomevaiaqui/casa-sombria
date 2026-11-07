local I={}
I.paintings={
 id='sala_quadros',room='sala',x1=1.23,x2=2.15,y1=1.45,y2=3.45,
 lookX=-1,lookY=0,
 pages={
  'Um quadro representando dois rockeiros e o outro uma mulher na banheira. Léli 2015',
  'Parece uma ótima pintora'
 }
}
function I.nearby(room,x,y)
 local p=I.paintings
 if room==p.room and x>=p.x1 and x<=p.x2 and y>=p.y1 and y<=p.y2 then return p end
end
return I
