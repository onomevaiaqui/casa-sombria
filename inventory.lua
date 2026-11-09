local inspection=require('inspection165')
local theme=require('inventory_theme163')
local Inventory = {}

local items = {
    shed_key = {name="Chave",detail="Chave pequena de um cadeado. A etiqueta diz: FERRAMENTAS.",usable=true},
    car_key = {name="Chave", detail="Chave do carro da garagem. O plastico esta gasto.", usable=true},
    door_key = {name="Chave", detail="Uma etiqueta desbotada diz: GARAGEM.", usable=true},
    lighter = {name="Isqueiro", detail="Isqueiro vermelho. Ainda tem gas.", usable=true},
    phone = {name="Celular", detail="Meu celular. A tela funciona, mas esta sem sinal.", equippable=true},
    battery = {name="Pilha", detail="Pilha pequena. Parece servir no controle do portao.", usable=true},
    remote = {name="Controle", detail="Controle de portao eletronico. Falta uma pilha.", usable=true},
    collar = {name="Coleira", detail="A placa diz BENTO. Ha marcas profundas no couro.", usable=true},
    valve = {name="Volante", detail="Volante de valvula avulso. Tem um encaixe quadrado.", usable=true},
    screwdriver = {name="Chave Phillips", detail="Ponta cruzada para parafusos pequenos.", usable=true},
    cutters = {name="Corta-cadeado", detail="Mandibulas pesadas para cortar metal fino.", usable=true},
    crowbar = {name="Pe de cabra", detail="Pesado e resistente. Posso usá-lo como arma ou para fazer alavanca.", equippable=true}
}

local documents = {
    family_photo={title='Desenho infantil',text='Um desenho encontrado junto da foto no quarto.'},
    order = {title="Pedido de entrega", text="Pedido 37. Uma pizza grande. Entrega na casa 37. Pagamento na entrega. O cliente pediu para insistir na campainha."},
    letter = {title="Carta antiga", text="Achei a carta de voces da faculdade. Nao acredito que ainda guardam o copo. Se forem repetir aquela brincadeira, me esperem. Quero ver se alguem tem coragem."},
    note = {title="Bilhete na cozinha", text="A pizza ja foi pedida. Volto antes de esfriar. Deixei as coisas em cima da mesa. Nao comecem sem mim."}
}

-- Temporary locations for testing collection; documents use a separate list.
local pickups = {{["id"]='door_key',["room"]='quarto',["x"]=161.05263157894734,["y"]=171.02564102564102},{["id"]='letter',["document"]=true,["room"]='quarto',["x"]=113.68421052631577,["y"]=214.74358974358972},{["id"]='note',["document"]=true,["room"]='cozinha',["x"]=335.83333333333326,["y"]=205.47619047619048},{["id"]='battery',["room"]='garagem',["x"]=126.95652173913041,["y"]=207.54385964912282},{["id"]='remote',["room"]='garagem',["x"]=126.95652173913041,["y"]=190.1754385964912},{["id"]='screwdriver',["room"]='garagem',["x"]=126.95652173913041,["y"]=197.89473684210526},{["id"]='cutters',["room"]='garagem',["x"]=126.95652173913041,["y"]=168.94736842105263},{["id"]='crowbar',["room"]='corredor',["x"]=214.19354838709677,["y"]=195.0},{["id"]='valve',["room"]='banheiro',["x"]=206.66666666666666,["y"]=195.0},{["id"]='collar',["room"]='quintal',["x"]=240.0,["y"]=197.2}}

-- Story progression: the first weapon belongs inside the locked tool shed.
for i=#pickups,1,-1 do if pickups[i].id=='crowbar'or pickups[i].room=='quintal'then table.remove(pickups,i)end end
local cx,cy=require('metric_rooms').project('ferramentas',1.30,1.72,0)
pickups[#pickups+1]={id='crowbar',room='ferramentas',x=cx,y=cy}

local function wrapped(text, x, y, width, color, maxLines)
    local line, count = "", 0
    for word in text:gmatch("%S+") do
        if #line+#word+1 > width and line~="" then
            ui.print(line,x,y+count*12,color)
            count, line = count+1, ""
            if count >= maxLines then return end
        end
        line = line=="" and word or line.." "..word
    end
    if line~="" and count<maxLines then ui.print(line,x,y+count*12,color) end
end

function Inventory.new(sprites)
    local state = {}
    state.sprites = sprites or {}

    function state:reset()
        require('photo162').reset()
        self.bag = {"car_key","lighter","phone"}
        self.files = {"order"}
        self.collected = {}
        self.visible,self.tab,self.focus = false,1,"items"
        self.selected,self.fileSelected = 1,1
        self.mode,self.action,self.inspected,self.message = "grid",1,false,nil
        self.equipped,self.combineSource = nil,nil
        self.remoteReady,self.lit = false,false
        self.previous = {}
    end

    function state:open()
        self.visible = true
        self.mode,self.inspected,self.message = "grid",false,nil
        self.focus=self.tab==1 and "items"or "files"
        self.previous = {}
    end

    function state:close()
        self.visible,self.message,self.combineSource = false,nil,nil
        self.mode = "grid"
    end

    function state:icon(id,x,y)
        if id=="crowbar"then require("crowbar160").icon(ui,x,y);return end
        local ref = self.sprites["item_"..(id=="shed_key"and "door_key"or id)]
        if ref and type(ui.spr)=="function" then
            local ok = pcall(ui.spr,ref,x,y)
            if ok then return end
        end
        ui.print("+",x+12,y+12,242)
    end

    function state:has(id)for _,v in ipairs(self.bag)do if v==id then return true end end;return false end

    function state:use(id,room)
        if id=="shed_key"then return "Aproxime-se do cadeado da casinha e pressione B."
        elseif id=="lighter" then
            self.lit = not self.lit
            return self.lit and "O isqueiro esta aceso." or "Apaguei o isqueiro."
        elseif id=="remote" then
            if not self.remoteReady then return "O controle esta sem pilha." end
            return "O controle pisca. Nao ha um receptor ativo aqui."
        elseif id=="car_key" and room=="garagem" then
            return "A chave e deste Fusca. Ele continua sem funcionar."
        elseif id=="battery" then
            return "Posso combinar a pilha com o controle."
        end
        return "Nao ha onde usar este item aqui."
    end

    function state:handle(up,down,left,right,confirm,room,shoulderLeft,shoulderRight)
        local input = {up=up,down=down,left=left,right=right,b=confirm,l=shoulderLeft,r=shoulderRight}
        local pressed = {}
        for key,value in pairs(input) do
            pressed[key] = value and not self.previous[key]
        end
        self.previous = input
        if pressed.l or pressed.r then
            self.tab=self.tab==1 and 2 or 1;self.focus=self.tab==1 and "items"or "files"
            self.mode,self.inspected,self.message,self.combineSource="grid",false,nil,nil
            return
        end
        if self.mode=="actions" then
            if pressed.up then self.action = (self.action+1)%3+1 end
            if pressed.down then self.action = self.action%3+1 end
            if pressed.b then
                local id = self.bag[self.selected]
                local item = id and items[id]
                if not item then self.mode="grid";return end
                if self.action==3 then
                    self.inspected,self.message,self.mode = true,nil,"grid"
                elseif self.action==2 then
                    self.combineSource,self.mode,self.message = id,"combine","Escolha o segundo item."
                elseif item.equippable then
                    if self.equipped==id then self.equipped=nil else self.equipped=id end
                    self.message = self.equipped and "Item equipado." or "Item desequipado."
                    self.mode = "grid"
                else
                    self.message,self.mode = self:use(id,room),"grid"
                end
            end
            return
        end
        if self.tab==2 then
            self.focus='files'
            if pressed.up then self.fileSelected=math.max(1,self.fileSelected-1);self.mode='grid'end
            if pressed.down then self.fileSelected=math.min(#self.files,self.fileSelected+1);self.mode='grid'end
            if pressed.b and self.files[self.fileSelected]then
                if self.files[self.fileSelected]=='family_photo'then require('photo162').begin()
                else self.mode=self.mode=='read'and 'grid'or 'read'end
            end
            return
        end
        self.focus='items'
        local old = self.selected
        if pressed.left and (self.selected-1)%3>0 then self.selected=self.selected-1 end
        if pressed.right and (self.selected-1)%3<2 then self.selected=self.selected+1 end
        if pressed.up then
            if self.selected<=3 then
                -- Top row stays in the grid; shoulders select tabs.
            else self.selected=self.selected-3 end
        end
        if pressed.down and self.selected<=3 then self.selected=self.selected+3 end
        if self.selected~=old then self.inspected,self.message=false,nil end
        if pressed.b then
            local id = self.bag[self.selected]
            if self.mode=="combine" then
                local source = self.combineSource
                if id and ((source=="battery" and id=="remote") or (source=="remote" and id=="battery")) and not self.remoteReady then
                    for i,item in ipairs(self.bag) do
                        if item=="battery" then table.remove(self.bag,i);break end
                    end
                    self.remoteReady = true
                    self.message = "Coloquei a pilha no controle."
                else
                    self.message = id and "Estes itens nao combinam." or "Escolha um item ocupado."
                end
                self.mode,self.combineSource="grid",nil
            elseif id then
                self.mode,self.action,self.message="actions",1,nil
            end
        end
    end

    function state:nearby(room,x,y)
        for _,pickup in ipairs(pickups) do
            if pickup.room==room and not self.collected[pickup.id]
                and math.abs(x-pickup.x)<=16 and math.abs(y-pickup.y)<=13 then
                return pickup
            end
        end
    end

    function state:collect(pickup)
        if self.collected[pickup.id] then return "" end
        if pickup.document then
            self.files[#self.files+1]=pickup.id
            self.collected[pickup.id]=true
            return "ARQUIVO COLETADO"
        end
        if #self.bag>=6 then return "INVENTARIO CHEIO" end
        self.bag[#self.bag+1]=pickup.id
        self.collected[pickup.id]=true
        return "ITEM COLETADO"
    end


    function state:back()
        if self.mode~='grid'then self.mode,self.message,self.combineSource='grid',nil,nil
        else self:close()end
    end

    function state:draw(palette)
        for i,color in ipairs(palette)do ui.palset(i-1,color)end
        theme.palette(ui);ui.cls(240)
        local frame=theme.frame
        frame(ui,8,8,464,254)
        frame(ui,19,19,91,19,self.tab==1);frame(ui,114,19,91,19,self.tab==2)
        ui.print('ITENS',46,24,self.tab==1 and 241 or 243)
        ui.print('ARQUIVOS',133,24,self.tab==2 and 241 or 243)
        ui.print('L/R: ABAS',380,25,243)
        frame(ui,19,46,148,118)
        ui.print('CONDICAO',29,56,243)
        local hp=require('survival158').hp;local health=hp>=3 and 248 or 249
        ui.line(30,97,46,97,health);ui.line(46,97,51,92,health)
        ui.line(51,92,56,102,health);ui.line(56,102,61,82,health)
        ui.line(61,82,66,105,health);ui.line(66,105,71,97,health)
        ui.line(71,97,95,97,health);ui.line(95,97,100,92,health)
        ui.line(100,92,105,100,health);ui.line(105,100,110,97,health);ui.line(110,97,154,97,health)
        ui.print(hp>=3 and 'ESTAVEL'or(hp==2 and 'ALERTA'or(hp==1 and 'PERIGO'or 'MORTO')),29,120,health)
        ui.print('EQUIPADO',29,145,243)
        local equipped=self.equipped and items[self.equipped]
        ui.print(equipped and equipped.name or 'NENHUM',84,145,241)
        frame(ui,19,180,434,69)
        if self.tab==1 then
            for index=1,6 do
                local x=179+((index-1)%3)*92;local y=46+math.floor((index-1)/3)*59
                frame(ui,x,y,86,54,self.selected==index)
                ui.print('0'..index,x+7,y+6,243)
                local id=self.bag[index]
                if id then self:icon(id,x+27,y+10);if id==self.equipped then ui.print('E',x+72,y+6,248)end end
            end
            ui.print(#self.bag..' / 6 ESPACOS',359,169,243)
            local id=self.bag[self.selected];local item=id and items[id]
            ui.print(item and item.name or 'VAZIO',29,190,241)
            local detail=self.message or(self.inspected and item and inspection.text(item.detail,item.reverseDetail,0,false)or '')
            if self.inspected and id=='remote'and self.remoteReady and not self.message then detail='Controle com a pilha instalada. O LED acende.'end
            if self.inspected and id=='lighter'and not self.message then detail=self.lit and 'Isqueiro vermelho. Esta aceso.'or 'Isqueiro vermelho. Ainda tem gas.'end
            wrapped(detail,29,205,66,243,3)
            if self.mode=='actions'and item then
                frame(ui,307,85,140,74,true)
                ui.print((self.action==1 and '> 'or '  ')..(item.equippable and 'EQUIPAR'or 'USAR'),317,97,self.action==1 and 241 or 243)
                ui.print((self.action==2 and '> 'or '  ')..'COMBINAR',317,115,self.action==2 and 241 or 243)
                ui.print((self.action==3 and '> 'or '  ')..'INSPECIONAR',317,133,self.action==3 and 241 or 243)
            end
        else
            for index,id in ipairs(self.files)do
                local y=46+(index-1)*28
                frame(ui,179,y,274,25,self.fileSelected==index)
                ui.print(documents[id].title,190,y+8,self.fileSelected==index and 241 or 243)
            end
            ui.print('ARQUIVOS NAO OCUPAM ESPACOS',181,169,243)
            local id=self.files[self.fileSelected];local doc=id and documents[id]
            if doc then
                ui.print(doc.title,29,190,241)
                if id=='family_photo'then ui.print('B: EXAMINAR DESENHO',29,205,243)
                elseif self.mode=='read'then wrapped(inspection.text(doc.text,doc.reverseText,0,false),29,205,66,243,4)end
            end
        end
        ui.print('A: VOLTAR   B: ACOES   L/R: ITENS / ARQUIVOS',29,251,243)
    end

    state:reset()
    return state
end

return Inventory
