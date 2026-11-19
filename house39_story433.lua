local Q={mode=nil,cursor=1,digits={0,0,0,0},choice=1,key={22,11.5,.12}}
local inv,refs
function Q.setup(i,r)inv,refs=i,r end
function Q.busy()return Q.mode~=nil end
local function near(x,y,a,b)return(x-a)^2+(y-b)^2<1 end
function Q.action(room,x,y)
 if room=='c39casinha'and(x-1.2)^2+(y-1.65)^2<.65^2 and not inv.collected.crowbar then Q.mode='axe';Q.choice=1;Q.prev={};return true end
 if room=='campo'and near(x,y,Q.key[1],Q.key[2])and not inv.collected.back_key39 then Q.mode='key';Q.choice=1;Q.prev={};return true end
 if room=='c39quintal'and near(x,y,-4.925,16.3)and not inv.collected.house39_shed_open then Q.mode='code';Q.cursor=1;Q.digits={0,0,0,0};Q.error=nil;Q.prev={};return true end
 return false
end
function Q.tick(confirm,cancel,left,right,up,down)
 if not Q.mode then return end
 if cancel then Q.mode=nil;return end
 local p=Q.prev or{};local l=left and not p.l;local r=right and not p.r;local u=up and not p.u;local d=down and not p.d;Q.prev={l=left,r=right,u=up,d=down}
 if Q.mode=='key'or Q.mode=='axe'then
  if l then Q.choice=1 elseif r then Q.choice=2 end
  if confirm then
   if Q.choice==2 then Q.mode=nil;return end
   local isAxe=Q.mode=='axe';local result=inv:collect({id=isAxe and'crowbar'or'back_key39'})
   Q.message=result=='INVENTARIO CHEIO'and'Inventario cheio. O item continua aqui.'or(isAxe and'Peguei a machadinha no deposito.'or'Peguei a chave da Casa 39 no campinho.');Q.mode='message'
  end
 elseif Q.mode=='code'then
  if l then Q.cursor=(Q.cursor+2)%4+1 elseif r then Q.cursor=Q.cursor%4+1 end
  if u then Q.digits[Q.cursor]=(Q.digits[Q.cursor]+1)%10;Q.error=nil elseif d then Q.digits[Q.cursor]=(Q.digits[Q.cursor]+9)%10;Q.error=nil end
  if confirm then
   if table.concat(Q.digits)=='2019'then inv.collected.house39_shed_open=true;Q.message='O cadeado abriu.';Q.mode='message'
   else Q.error='A senha nao funcionou.'end
  end
 elseif confirm then Q.mode=nil end
end
function Q.draw(ui)
 if not Q.mode then return end
 if Q.mode=='code'then require('lock437_view').draw(ui,Q.digits,Q.cursor)end
 ui.rectfill(0,195,479,269,240)
 if Q.mode=='key'or Q.mode=='axe'then ui.print(Q.mode=='axe'and'Uma machadinha na prateleira. Pegar?'or'Uma chave pequena no campinho. Pegar?',8,209,241);ui.print(Q.choice==1 and'> Sim      Nao'or'  Sim    > Nao',8,247,241)
 elseif Q.mode=='code'then
  ui.print('CADEADO DO DEPOSITO',12,204,241)
  for i,v in ipairs(Q.digits)do local x=177+(i-1)*30;ui.print(tostring(v),x,227,241);if i==Q.cursor then ui.line(x-2,238,x+9,238,241)end end
  ui.print(Q.error or(inv.collected.shed_code39_known and'Coleira da Cloe: deposito - 2019.'or'Um cadeado de quatro digitos.'),12,244,241)
  ui.print('Cruz: ajustar   B: confirmar   A: sair',12,258,241)
 else ui.print(Q.message,12,217,241);ui.print('B: continuar   A: fechar',12,249,241)end
end
function Q.drawPickup(ui,m,room,visible)
 if room=='c39casinha'and inv and not inv.collected.crowbar then
  require('axe441').draw(ui,m,visible)
  return
 end
 if room~='campo'or not inv or inv.collected.back_key39 then return end
 local a,b,z=Q.key[1],Q.key[2],Q.key[3];local w=m[4][1]*a+m[4][2]*b+m[4][3]*z+m[4][4];if w<=.1 then return end
 local x=((m[1][1]*a+m[1][2]*b+m[1][3]*z+m[1][4])/w+1)*240;local y=(1-(m[2][1]*a+m[2][2]*b+m[2][3]*z+m[2][4])/w)*135
 local v={x,y,w};if x>8 and x<472 and y>18 and y<260 and(not visible or visible(v,v,v))then ui.spr(refs.w350_key,x-8,y-8)end
end
return Q
