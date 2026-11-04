-- Teste 3.2: fundo e mascara em bitmap, entregador em 3D.
local spriteModule
if type(require) == "function" then
    local ok, value = pcall(require, "sprites")
    if ok and type(value) == "table" then spriteModule = value end
    pcall(require, "palette")
end
local mode, previous = 1, false
local formats = {"BGR555", "RGB555", "RGB565"}
local function encode(c)
    if mode == 1 then return c end
    local r, g, b = c % 32, math.floor(c / 32) % 32, math.floor(c / 1024)
    if mode == 2 then return r * 1024 + g * 32 + b end
    return r * 2048 + (g * 2 + math.floor(g / 16)) * 32 + b
end
local x, y, facing, walking, step = 65, 143, 1, false, 0
local actorPalette = {
    2056,5136,7282,8549,10665,12653,10570,15820,
    15501,11133,21471,6328,11833,9511
}
local actorFaces = {
    {1,2,3,4,0},{5,8,7,6,1},{1,5,6,2,0},
    {4,3,7,8,1},{1,4,8,5,0},{2,6,7,3,1}
}

local function courier()
    local scale = 0.75 + (y - 145) / 180
    local angle = -facing * 0.75
    local sine, cosine = math.sin(angle), math.cos(angle)
    local stride = walking and math.sin(step / 4) * 2.5 or 0
    local faces = {}

    local function part(px, py, pz, w, h, d, lit, dark)
        local vertices = {}
        for _, corner in ipairs({
            {0,0,0},{1,0,0},{1,1,0},{0,1,0},
            {0,0,1},{1,0,1},{1,1,1},{0,1,1}
        }) do
            local ax = px + corner[1] * w
            local ay = py + corner[2] * h
            local az = pz + corner[3] * d
            local depth = az * cosine - ax * sine
            local magnification = scale * 95 / (95 + depth)
            vertices[#vertices + 1] = {
                math.max(0, math.min(479, math.floor(x + (ax * cosine + az * sine) * magnification))),
                math.floor(y - (ay + depth * 0.22) * magnification),
                depth
            }
        end
        for _, face in ipairs(actorFaces) do
            local a,b,c,e = vertices[face[1]],vertices[face[2]],vertices[face[3]],vertices[face[4]]
            local area = (b[1]-a[1])*(c[2]-a[2]) - (b[2]-a[2])*(c[1]-a[1])
            if area < 0 then
                faces[#faces + 1] = {a,b,c,e,a[3]+b[3]+c[3]+e[3],face[5]==0 and lit or dark}
            end
        end
    end

    part(-7,2,-3+stride,5,11,6,14,3)
    part(2,2,-3-stride,5,11,6,14,3)
    part(-7,0,-5+stride,5,3,8,5,2)
    part(2,0,-5-stride,5,3,8,5,2)
    part(-8,12,-4,16,12,8,12,9)
    part(-6,24,-4,12,8,8,13,9)
    part(-7,31,-5,14,4,10,12,9)
    part(-6,31,-9,12,2,5,12,9)
    part(-10,15,-6,4,7,6,13,9)
    part(6,15,-6,4,7,6,13,9)
    part(-10,16,-15,20,3,12,11,10)

    table.sort(faces,function(a,b) return a[5]>b[5] end)
    for _, face in ipairs(faces) do
        local a,b,c,d,color = face[1],face[2],face[3],face[4],face[6]
        ui.trisfill(a[1],a[2],b[1],b[2],c[1],c[2],color + 223)
        ui.trisfill(a[1],a[2],c[1],c[2],d[1],d[2],color + 223)
    end
end

local function held(button)
    local value = ui.btn(button, 0)
    return value == true or (type(value) == "number" and value > 0)
end

local function drawAsset(asset, px, py)
    if type(asset) ~= "table" or type(ui.spr) ~= "function" then return false end
    return pcall(ui.spr, asset, px, py)
end

function update()
    local colorButton = held(BTN_X or 6)
    if colorButton and not previous then mode = mode % #formats + 1 end
    previous = colorButton
    local sprites = type(Sprites) == "table" and Sprites or spriteModule
    ui.palset(0, 0)
    ui.cls(0)
    local status
    if not sprites or type(sprites.sala) ~= "table" then
        status = "FUNDO AUSENTE"
    elseif type(sprites.sofa) ~= "table" then
        status = "MASCARA AUSENTE"
    elseif type(Palette) ~= "table" or #Palette == 0 then
        status = "PALETA AUSENTE"
    elseif #Palette > 224 then
        status = "PALETA SEM ESPACO PARA O ATOR"
    else
        for i, color in ipairs(Palette) do ui.palset(i-1, encode(color)) end
        for i, color in ipairs(actorPalette) do ui.palset(i+223, encode(color)) end
        local dx = (held(RIGHT or 2) and 1 or 0) - (held(LEFT or 4) and 1 or 0)
        local dy = (held(DOWN or 3) and 1 or 0) - (held(UP or 1) and 1 or 0)
        if dx ~= 0 then facing = dx end
        walking = dx ~= 0 or dy ~= 0
        if walking then step = step + 1 end
        -- Back aisle, right turn, then front aisle. The middle is furniture.
        local function walkable(px, py)
            return px >= 48 and px <= 392 and py >= 130 and py <= 230
                and (py <= 150 or py >= 207 or px >= 268)
        end
        local nextX, nextY = x + dx * 1.4, y + dy * 1.25
        if walkable(nextX, y) then x = nextX end
        if walkable(x, nextY) then y = nextY end
        if drawAsset(sprites.sala, 0, 0) then
            courier()
            status = "BITMAP / FRENTE"
            if y <= 150 then
                status = drawAsset(sprites.sofa, 76, 127) and "BITMAP / ATRAS" or "ERRO MASCARA"
            end
        else
            status = "ERRO FUNDO"
        end
    end
    ui.palset(240, 0)
    ui.palset(241, encode(32767))
    ui.rectfill(0,248,479,269,240)
    ui.print("3.3 "..status.."   X: "..formats[mode],8,253,241)
end
