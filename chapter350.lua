local C={}
local dialogue=require('subtitles').new()
local inv,refs
local function near(x,y,a,b,r)return(x-a)^2+(y-b)^2<(r or .8)^2 end
local function flags()return inv and inv.collected or{}end
function C.setup(inventory,sprites)inv,refs=inventory,sprites end
function C.busy()return dialogue.active end
function C.reset()dialogue:close();dialogue.toastTime=0 end
local function collect(id,document,question)
 dialogue:ask(question,function()
  local result=inv:collect({id=id,document=document})
  if result=='INVENTARIO CHEIO'then dialogue:notify('Nao tenho espaco. Posso voltar para buscar depois.');return end
  inv:open();inv.tab=document and 2 or 1;inv.focus=document and 'files'or 'items';inv.mode='grid';inv.previous={b=true}
  if document then inv.fileSelected=#inv.files else inv.selected=#inv.bag end
 end)
end
function C.nearOutside(x,y)
 return near(x,y,11.86,-43.3,1.8)or near(x,y,-8.2,-63.9,1.15)or near(x,y,-8.2,-59.1,1.0)
end
function C.actionOutside(x,y)
 local f=flags()
 if near(x,y,11.86,-43.3,1.8)then
  if not f.gazebo_order then collect('gazebo_order',true,'Pegar o bilhete deixado no coreto?')
  elseif f.market_returned then dialogue:open({'A chave e a anotacao apontam para a Casa 12, na Rua dos Cedros.'})
  else dialogue:open({'O bilhete menciona uma entrada de servico no mercadinho. Preciso procurar na Rua das Acacias.'})end
  return
 end
 if near(x,y,-8.2,-63.9,1.15)then
  if f.market_service_open then return 'enter_market_service'end
  dialogue:open({'Tabuas pregadas sobre a porta de servico. A madeira esta apodrecida.','Posso tentar quebra-las com a machadinha.'});return
 end
 if near(x,y,-8.2,-59.1,1.0)then
  if f.market_front_open then return 'enter_market_front'end
  dialogue:open({'A persiana esta travada por dentro. Deve haver outra entrada.'});return
 end
end
function C.hit(x,y,angle,equipped)
 local f=flags();if f.market_service_open or not near(x,y,-8.2,-63.9,1.2)then return end
 if equipped~='crowbar'then return 'Preciso da machadinha para quebrar estas tabuas.'end
 local dx,dy=-9.1-x,-63.9-y;local length=math.sqrt(dx*dx+dy*dy)
 if length>.05 and(math.sin(angle)*dx-math.cos(angle)*dy)/length<.55 then return end
 f.market_board_hits=(f.market_board_hits or 0)+1
 if f.market_board_hits>=3 then f.market_service_open=true;return 'As tabuas cederam. B: entrar pela porta de servico.'end
 return 'A madeira esta cedendo...'
end
function C.actionInside(x,y)
 local f=flags()
 if near(x,y,9.55,1.2,.8)then return 'exit_market_service'end
 if near(x,y,5,.5,.8)then
  if f.market_front_open then return 'exit_market_front'end
  dialogue:open({'O mecanismo da persiana esta ligado ao deposito. Preciso destrava-lo por dentro.'});return
 end
 if near(x,y,7.55,3.45,.85)and not f.market_key then collect('market_key',false,'Pegar a chave pequena do balcao?');return end
 if near(x,y,7.3,5.25,.85)then
  if f.market_stock_open then dialogue:open({'A porta do deposito esta aberta.'})
  elseif inv:has('market_key')then
   f.market_stock_open=true
   for i,id in ipairs(inv.bag)do if id=='market_key'then table.remove(inv.bag,i);break end end
   inv.selected=math.max(1,math.min(inv.selected,#inv.bag));dialogue:notify('Usei a chave e abri o deposito.')
  else dialogue:open({'DEPOSITO. A porta esta trancada. Deve haver uma chave perto do caixa.'})end
  return
 end
 if y>5.8 then
  if near(x,y,5.9,6.65,.75)and not f.medkit then collect('medkit',false,'Pegar o kit medico?');return end
  if near(x,y,3.25,6.5,.8)and not f.market_ledger then collect('market_ledger',true,'Pegar a anotacao do deposito?');return end
  if near(x,y,7.4,6.85,.75)and not f.house12_key then collect('house12_key',false,'Pegar a chave com a etiqueta 12?');return end
  if near(x,y,8.95,6.9,.85)then
   if not f.market_front_open then f.market_front_open=true;dialogue:notify('A persiana da frente foi destravada. Tenho um caminho de volta.')
   else dialogue:open({'A saida pela frente ja esta liberada.'})end
   return
  end
 end
 dialogue:open({'Prateleiras empoeiradas e comida esquecida. O lugar foi abandonado as pressas.'})
end
function C.tick(dt,x,y,outside,confirm,cancel,left,right)
 dialogue:tick(dt)
 if dialogue.active then dialogue:handle(confirm,cancel,left,right);return end
 local f=flags()
 if outside and inv and not inv.visible and f.house12_key and f.market_ledger and not f.market_returned and near(x,y,11.86,-43.3,1.8)then
  f.market_returned=true;dialogue:open({'Voltei a praca. A anotacao e a chave apontam para a Casa 12.','O caminho continua pela Rua dos Cedros.'})
 end
end
function C.draw(ui)dialogue:draw(ui)end
local pickups={{id='market_key',x=8.3,y=3.45,z=1.03,icon='w350_key'},{id='medkit',x=5.9,y=6.65,z=.20,icon='w350_medkit'},{id='market_ledger',x=3.25,y=6.5,z=.20,icon='w350_note'},{id='house12_key',x=7.4,y=6.85,z=.20,icon='w350_key'}}
local function project(m,x,y,z)
 local w=m[4][1]*x+m[4][2]*y+m[4][3]*z+m[4][4];if w<=.1 then return end
 return((m[1][1]*x+m[1][2]*y+m[1][3]*z+m[1][4])/w+1)*240,(1-(m[2][1]*x+m[2][2]*y+m[2][3]*z+m[2][4])/w)*135,w
end
function C.drawPickups(ui,m,inside,region,visible)
 local f=flags()
 if not inside then
  if not f.gazebo_order then local x,y=project(m,11.86,-43.3,.15);if x then ui.spr(refs.w350_note,x-8,y-8)end end
  return
 end
 for _,p in ipairs(pickups)do if not f[p.id]and((region=='deposito')==(p.y>5.6))then local x,y,z=project(m,p.x,p.y,p.z);if x and x>8 and x<472 and y>18 and y<260 then local v={x,y,z};if not visible or visible(v,v,v)then ui.spr(refs[p.icon],x-8,y-8)end end end end
end
function C.status()
 local f=flags()
 if f.market_returned then return 'Concluido: pista da Casa 12'end
 if f.house12_key and f.market_ledger then return 'Voltar ao coreto da praca'end
 if f.market_front_open then return 'Buscar a pista e a chave no deposito'end
 if f.market_stock_open then return 'Explorar o deposito e liberar a persiana'end
 if f.market_service_open then return 'Encontrar a chave do deposito'end
 if f.gazebo_order then return 'Procurar a entrada de servico do mercadinho'end
 return 'Examinar o bilhete no coreto'
end
return C
