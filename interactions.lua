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
I.rottenFood={id='cozinha_comida_podre',room='cozinha',lookX=0,lookY=1,pages={'A comida esta podre. O cheiro neste ambiente e insuportavel.'}}
I.showerBody={id='shower_body712',room='banheiro',lookX=0,lookY=1}
function I.examine(interaction,inv)
 if interaction.id~='shower_body712'then return interaction.pages end
 if inv.collected.shower_body_token712 then return {'Esta morto. Nao ha mais nada com ele.'}end
 if #inv.bag>=6 then return {'Esta morto. Ha uma ficha telefonica no bolso, mas meu inventario esta cheio.'}end
 inv.bag[#inv.bag+1]='phone_token';inv.collected.shower_body_token712=true
 return {'Esta morto... Ha uma ficha telefonica no bolso.','Voce pegou uma ficha telefonica.'}
end
function I.nearby(room,x,y)
 if room=='banheiro'and x>=.65 and x<=2.15 and y>=.90 and y<=2.80 then return I.showerBody end
 if room=='cozinha'and x>=.3 and x<=3.4 and y>=2.8 and y<=3.65 then return I.rottenFood end
 if room=='quintal'and (x-1.4585)^2+(y-7.676)^2<1.4^2 then
  local d=math.max(.001,math.sqrt((x-1.4585)^2+(y-7.676)^2));I.ghostGirl.lookX=(1.4585-x)/d;I.ghostGirl.lookY=(7.676-y)/d;return I.ghostGirl
 end
 local p=I.paintings
 if room==p.room and x>=p.x1 and x<=p.x2 and y>=p.y1 and y<=p.y2 then return p end
end
return I
