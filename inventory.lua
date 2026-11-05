local Inventory = {}

local items = {
    car_key = {name="Chave", detail="Chave de um Fusca ano 76. O plastico esta gasto.", usable=true},
    door_key = {name="Chave", detail="Uma etiqueta desbotada diz: GARAGEM.", usable=true},
    lighter = {name="Isqueiro", detail="Isqueiro vermelho. Ainda tem gas.", usable=true},
    phone = {name="Celular", detail="Meu celular. A tela funciona, mas esta sem sinal.", equippable=true},
    battery = {name="Pilha", detail="Pilha pequena. Parece servir no controle do portao.", usable=true},
    remote = {name="Controle", detail="Controle de portao eletronico. Falta uma pilha.", usable=true},
    collar = {name="Coleira", detail="A placa diz BENTO. Ha marcas profundas no couro.", usable=true},
    valve = {name="Volante", detail="Volante de valvula avulso. Tem um encaixe quadrado.", usable=true},
    screwdriver = {name="Chave Phillips", detail="Ponta cruzada para parafusos pequenos.", usable=true},
    cutters = {name="Corta-cadeado", detail="Mandibulas pesadas para cortar metal fino.", usable=true},
    crowbar = {name="Pe de cabra", detail="Pequeno e resistente. Serve para fazer alavanca.", equippable=true}
}

local documents = {
    order = {title="Pedido de entrega", text="Pedido 37. Uma pizza grande. Entrega na casa 37. Pagamento na entrega. O cliente pediu para insistir na campainha."},
    letter = {title="Carta antiga", text="Achei a carta de voces da faculdade. Nao acredito que ainda guardam o copo. Se forem repetir aquela brincadeira, me esperem. Quero ver se alguem tem coragem."},
    note = {title="Bilhete na cozinha", text="A pizza ja foi pedida. Volto antes de esfriar. Deixei as coisas em cima da mesa. Nao comecem sem mim."}
}

-- Temporary locations for testing collection; documents use a separate list.
local pickups = {
    {id="door_key", room="quarto", x=285,y=215},
    {id="letter", document=true, room="quarto", x=245,y=217},
    {id="note", document=true, room="cozinha", x=164,y=219},
    {id="battery", room="garagem", x=347,y=210},
    {id="remote", room="garagem", x=301,y=202},
    {id="screwdriver", room="garagem", x=328,y=226},
    {id="cutters", room="garagem", x=223,y=228},
    {id="crowbar", room="corredor", x=344,y=221},
    {id="valve", room="banheiro", x=267,y=216},
    {id="collar", room="quintal", x=120,y=223}
}

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
        self.bag = {"car_key","lighter","phone"}
        self.files = {"order"}
        self.collected = {}
        self.visible,self.tab,self.focus = false,1,"tabs"
        self.selected,self.fileSelected = 1,1
        self.mode,self.action,self.inspected,self.message = "grid",1,false,nil
        self.equipped,self.combineSource = nil,nil
        self.remoteReady,self.lit = false,false
        self.previous = {}
    end

    function state:open()
        self.visible = true
        self.mode,self.inspected,self.message = "grid",false,nil
        self.previous = {}
    end

    function state:close()
        self.visible,self.message,self.combineSource = false,nil,nil
        self.mode = "grid"
    end

    function state:icon(id,x,y)
        local ref = self.sprites["item_"..id]
        if ref and type(ui.spr)=="function" then
            local ok = pcall(ui.spr,ref,x,y)
            if ok then return end
        end
        ui.print("+",x+12,y+12,242)
    end

    function state:use(id,room)
        if id=="lighter" then
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

    function state:handle(up,down,left,right,confirm,room)
        local input = {up=up,down=down,left=left,right=right,b=confirm}
        local pressed = {}
        for key,value in pairs(input) do
            pressed[key] = value and not self.previous[key]
        end
        self.previous = input
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
            if self.focus=="tabs" then
                if pressed.left or pressed.right then self.tab=1 end
                if pressed.down then self.focus="files" end
            else
                if pressed.up then
                    if self.fileSelected==1 then self.focus="tabs"
                    else self.fileSelected=self.fileSelected-1 end
                end
                if pressed.down then self.fileSelected=math.min(#self.files,self.fileSelected+1) end
                if pressed.b then self.mode=self.mode=="read" and "grid" or "read" end
            end
            return
        end
        if self.focus=="tabs" then
            if pressed.left or pressed.right then self.tab=2;self.mode="grid" end
            if pressed.down then self.focus="items" end
            return
        end
        local old = self.selected
        if pressed.left and (self.selected-1)%3>0 then self.selected=self.selected-1 end
        if pressed.right and (self.selected-1)%3<2 then self.selected=self.selected+1 end
        if pressed.up then
            if self.selected<=3 then
                if self.mode~="combine" then self.focus="tabs" end
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

    function state:markers(room)
        for _,pickup in ipairs(pickups) do
            if pickup.room==room and not self.collected[pickup.id] then
                ui.rectfill(pickup.x-1,pickup.y-2,pickup.x+1,pickup.y,241)
            end
        end
    end

    function state:draw(palette)
        for i,color in ipairs(palette) do ui.palset(i-1,color) end
        ui.palset(240,0)
        ui.palset(241,32767)
        ui.palset(242,11674)
        ui.palset(243,1000)
        ui.palset(244,130)
        ui.palset(245,16912)
        ui.palset(246,2146)
        ui.cls(240)
        ui.print("INVENTARIO",185,6,241)
        ui.print((self.tab==1 and "> " or "  ").."ITENS",176,26,self.tab==1 and 242 or 245)
        ui.print((self.tab==2 and "> " or "  ").."ARQUIVOS",302,26,self.tab==2 and 242 or 245)
        ui.rect(12,42,145,167,242)
        ui.print("CONDICAO",24,53,241)
        ui.print("BEM",24,81,243)
        ui.line(24,72,45,72,243);ui.line(45,72,49,63,243)
        ui.line(49,63,54,78,243);ui.line(54,78,61,72,243)
        ui.line(61,72,132,72,243)
        ui.print("EQUIPADO",24,111,241)
        if self.equipped then
            self:icon(self.equipped,60,128)
        else ui.print("NENHUM",24,140,245) end
        if self.tab==1 then
            for index=1,6 do
                local x=168+((index-1)%3)*100
                local y=46+math.floor((index-1)/3)*61
                local selected = self.selected==index and self.focus~="tabs"
                if selected then ui.rectfill(x+1,y+1,x+88,y+54,246) end
                ui.rect(x,y,x+89,y+55,selected and 241 or 242)
                local id=self.bag[index]
                if id then
                    self:icon(id,x+29,y+8)
                    if id==self.equipped then ui.print("E",x+76,y+4,243) end
                end
            end
            ui.print(#self.bag.."/6",430,8,241)
            local id=self.bag[self.selected]
            local item=id and items[id]
            ui.rect(12,176,466,228,242)
            if item then
                ui.print(item.name,24,184,241)
                local detail = self.message or (self.inspected and item.detail or "")
                if self.inspected and id=="remote" and self.remoteReady and not self.message then
                    detail="Controle com a pilha instalada. O LED acende."
                end
                if self.inspected and id=="lighter" and not self.message then
                    detail = self.lit and "Isqueiro vermelho. Esta aceso." or "Isqueiro vermelho. Ainda tem gas."
                end
                wrapped(detail,24,201,53,245,2)
            elseif self.message then wrapped(self.message,24,201,53,245,2) end
            if self.mode=="actions" and item then
                ui.rectfill(279,76,463,155,240)
                ui.rect(279,76,463,155,242)
                local actions={item.equippable and "EQUIPAR" or "USAR","COMBINAR","INSPECIONAR"}
                for index,text in ipairs(actions) do
                    ui.print((self.action==index and "> " or "  ")..text,290,87+(index-1)*22,self.action==index and 241 or 245)
                end
            end
        else
            ui.rect(164,44,466,228,242)
            if self.mode=="read" and self.files[self.fileSelected] then
                local doc=documents[self.files[self.fileSelected]]
                ui.print(doc.title,176,54,241)
                wrapped(doc.text,176,78,34,245,11)
            else
                for index,id in ipairs(self.files) do
                    ui.print((self.fileSelected==index and self.focus~="tabs" and "> " or "  ")..documents[id].title,174,61+(index-1)*23,241)
                end
                ui.print("B LER / VOLTAR A LISTA",174,211,245)
            end
        end
        ui.print("A FECHA  B ACOES  CIMA: ABAS",20,235,245)
    end

    state:reset()
    return state
end

return Inventory


