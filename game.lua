-- Teste 3.2: fundo e mascara em bitmap, entregador em 3D.
local function decode(encoded)
local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local digits, parts = {}, {}
for i = 1, #alphabet do digits[alphabet:sub(i,i)] = i-1 end
for i = 1, #encoded, 4 do
    local a,b,c,d = encoded:sub(i,i),encoded:sub(i+1,i+1),encoded:sub(i+2,i+2),encoded:sub(i+3,i+3)
    local first = digits[a]*4 + math.floor(digits[b]/16)
    local second = (digits[b]%16)*16 + math.floor((digits[c] or 0)/4)
    local third = ((digits[c] or 0)%4)*64 + (digits[d] or 0)
    parts[#parts+1] = c == "=" and string.char(first)
        or (d == "=" and string.char(first,second) or string.char(first,second,third))
end
return table.concat(parts)
end
local detailedBackground = decode("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")
local detailedSofa = decode("Lz4wPhUxPjY+Kzc+OT46Lj8wPxUxPzs/LDw/Pz8rQD9CP3kuQDBAEjFAO0AsPEBKQCtLQExAeS1BMEESMUE7QSw8QVJBKy1CMEISMUI7Qiw8QllCK1pCW0J9LEMsQzotQzBDEjFDO0MsPENZQytaQ2JDKWRDZUMCKEQsRC4tRDBEEjFEO0QsPERZRCtaRGhEKSZFJkVQJ0UpRSkqRTBFLjFFO0UsPEVZRStaRWhFKWlFaUUYJkYmRlAnRilGKSpGMEYuMUY7Riw8RllGK1pGaEYpaUZrRhgmRyZHUCdHLEcVLUcwRy4xRztHLDxHWUcrWkdoRylpR2tHGGxHbEcdJkgmSFAnSCxIFS1IMEguMUg7SCw8SFlIK1pIaEgpaUhrSBhsSGxIHSZJJklQJ0ksSRUtSTBJbjFJNkkuN0k7SSw8SVlJK1pJaEkpaUlrSRhsSWxJHW1JbUkvJkomSlAnSixKFS1KMEpuMUo2Si43SjtKLDxKWUorWkpoSilpSmtKGGxKbEodbUpuSi8mSyZLUSdLLEsVLUs5S246S1lLK1pLaEspaUtwS24nTCxMFS1MOUxuOkxZTCtaTGhMKWlMckxuJ00sTRUtTTlNbjpNPE0uPU1KTRRLTVlNK1pNaE0paU10TW4nTixOFS1OOU5uOk5KTi5LTllOK1pOaE4paU53Tm54TnhOEydPLE8VLU85T246T1lPLlpPaE8paU93T254T3pPEydQLFAVLVA5UG46UGhQLmlQd1BueFB7UBMnUTlRFTpRaFEuaVF3UW54UXtREydSO1IVPFJoUi5pUndSbnhSe1ITJ1M7UxU8U0pTK0tTWVMsWlNoUy5pU3RTLHVTd1MVeFN7UxMnVCxUEi1UO1QVPFRZVClaVGhUbmlUdFQsdVR3VBV4VHtUEydVLFUSLVU7VRU8VVlVKVpVaFVuaVV3VRV4VXtVEydWLFYSLVY7VhU8VllWKVpWaFZuaVZ3VhV4VnxWEydXLFcSLVc7VxU8V0pXE0tXWVcpWldoV25pV3dXFXhXfFcTJ1gsWBItWDtYFTxYSlgTS1hoWBJpWHdYFXhYfFgTJlksWRItWTtZFTxZSlkTS1loWRJpWXdZD3hZe1kTJlomWjQnWihaBSlaKVoDKlosWhEtWllaFVpaaFoUaVp3WhN4WnlaGXpaeloTKFsoW3QpWylbAypbLFsRLVtZWxVaW2hbFGlbd1sTeFt5WxkqXCxcES1cWVwVWlxoXBRpXHdcE3hceFwZK10sXREtXVldFVpdaF0UaV13XRN4XXhdGSxeLF4RLV47Xgk8XkpeB0teWV4JWl5oXhRpXndeEy5fMF8JMl80Xwk2XzdfCTlfO18JPV8+XxdAX0pfF0tfWV8JWl9oX2tpX3ZfE2BgYGAcYmBjYBxlYGhgHGlgc2AH")
local detail, previousDetail = true, false
local gridPatches
if type(ui.grid) == "function" then
    local pixels = decode("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goKCW1tbW1pZWVl/Ozp9HR0JHgkJCQkHgoJbW1uCgluCgoJbW1tZWzsJHh4JCQlqW1tbW1tbW4KCW1taWlpZW34MaQkMDAkJW1tbW1tbgoKCW1tbW1tZW34MHgkJCQkJWFhYWFhYWFtbW1tbW1tbW3AJDAwJCQkJWFhYWFhYWFpbW1tbW1tbW1lsbGxuHh4eWFhYWFhYWFpbW1tbW1tbW1s9PT09PT1/WFhXWFhYWFtbW1tbW1tbW1s+PT09PT1sW1tbW1paWltbW1tbW1tbW1twPT09fz1sW1tbW1tbW1d+fn5+V1dXWVl+bGxsbD09W1tbW1tbW1h+fn5+fn5+fn47CQwMCQwetFgBPnBacHBwWlpacH5+fn5+fn5+fn5+fn5+cHBwWltbW1tbW1tbW1tbWlpacH5+fn5+cHBaW1tbW1tbW1tbW1tbW1tbW1tbW1tbWltbW1tbW1tbW1tbW1tbW1tbW1tbW1taW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1t+fn5+fn5+cHBaWltbW1tbW1tbW1tbWn5+fn5+fn87f39/fn5+cHB+cHBaWlpafn5+fn5+fn5+fn5+fn5+f39/f39/flpaW1tafn5+fn5+fn5+fn5+fn5+fn5wW1tbW1tbO39+fn5+fn5+fn5+fn5+f35bW1tbW1tbf39/f39/f39+fn5+fn9/flpbW1tbW1tbXFxcXFpaWlxaWnBwfn5aW1tbW1tbW1tbXFpcWlpaWlpaWlpbcH07f39/fn5wcFpaWlxcWlpaWlpaWlpwOn07Ozs7Ozs7Ozt/WlxaWlpaWlpaWjt9fTs7Ozs7Ozs7Ozs7WlpaWlpaWlpwfX19fX07Ozs7Ozs7Ozo7cHBwWnBacH19fWx9fX19Ozs7Ozs6Ojs7WlpaWlpwf31sfX19fX19fX07Ozs7Ozs7Hh4ePkREcD49f39/O319fX19fX19Ozs7Hh5sTVpaXFxcXFxwcHBwfj09f387O319wE4BaWlpaWlpCWlpDB0dHR0dCX1XV1dXV1dXaWlpaWlpaWlpDB0dHR0dHR1xcXE7Ozt+aWlpaWlpaWlpDB0dHR0dHR0dCQkJCQkJaQkJCQkJCWlpaR0dHR0dHR0dHR0dHR0dPT1sbGxxHh4eCR0dHR1pHh4JCR5pHR0dPj4+Pj4+Pj4+Pj49PT07fzs7OnE7Hn0ePj4+Pj4+Pj4+cHBaW1t+flpbW1tbW1taPj4+Pj4+PnBaW1tbW35+WoJbgoJbgoKCHX19fTt+cFlbW1tbcH5aW4JbgoKCW1tbHR1xO35+fn5+fn5bW1tbW1uCgoKCgltbHTt+fn5+fn5+fluCW1tbW4KCgltbgoJbf35+fn5+fn5+cFtbW1tbgoJbW1tbgltbWlpacFpXfn5+W1tbW4KCW1uCgltbW1tbW1tbW1tbW1t+fnBwWFtbW1uCW1tbW1tbW1tbW1tbW1dXfn5+fld+fldXfldwcFhbW1tbW1tbcFd+fn5+V1d+fld+V1d+V1dXWltbgltwfn5+fn5XV35XV35+V35XV1dXfn5+flpbcHB+fllXV1dXfn5+fn5XfldXfn5+cFtbW1tbW4JbgltbW1tYfnB+V1d+fn5+W1tbW1tbgltbW1tbW1tbW1tbW1tanGIBTU1NTUIeHh4eHh4eHh4eHh4eHh0eHh0dQmweHh4eHh4eHh4eHh4eHh4eHh4eHh59IiImJiZ9Ih4eHh4eHh4eHh4eHh4eHh4eIiJ6TU1NQ0JCPWxsbB4dCQkeHgwMDB4eIiIiIiIiIiI9Q0JCTU1NTU1NTU1NQ3BwayIiJiIiIiIiPT1DTU1NTT5NTU1NTU1NIiIiIiIiZyIiIiJsQkJNTU1NTU1NTU1NIiIiIiIiImtrayY9PUJCTU1NTU1NTU1NIiIibGw9ekJCTUtLTUtLTU1NTU1NTU1NR0dHTU1HR0dHR0dNTU1NTU1NTU1NTU1NR0dNTUtLS0tHR0tLQ0NNTU1HTU1NTU1NS0JCR0JCQkJCQj5wcE1CQnBNTU1NTUtHR0JCR0dHTU1NTU1NQ0NDTU1NTU1NTU1NPUJCcHBNQ0NDcHBDQ0NNTU1NQkJwQ0NNHh4eHh5uJiZNTU1NTU1NTUJDQ0NNTX0eHh4eHh4MDB4eHh5NTUdHTU1NTWxsHh4eHh4eHh4eHh4eDB4eHiYmPT1CIiIeHh4eHh4eHh4eHh4eHh4eHh5CQ0NDQz49PSYmHh4eHh4eHh4eDAxsbE1DQ0NDS01NTU1NHgwMHh4eHh4ebm5NTU1DQ01NQkNDQ0NDqE4BBwcHBwcHBwZqampqampqampqampqampqBwcHBwcHBwZqampqagkeCQkJCWpqampqBwcHBwcHBwZqamoJHh4eHh4eHh4eHh4JFmUHBwcHZWUJHh5sbGxsbGxsbGwmJh4JHmkJCWlpaWgeHiJsJiYmJiYmJj1sHgwMDGlpaQxpCQwJCQkJCQkMDR4eHiZsbm4eaAkJCQloDAwMDGlpaQwJCQkePT09PT16bCIiIh4eaWloCQloaAkJaWw9PT09ej1CQnpCenp6PT09JmxsIm4eJkJCekJCej09enpFQnp6PT09enp6emweHh4eHm5sbGw9R0VFenp6QkJCQkI9HmkMHh4eDAwMHh4ePUJFekJFR0J6QmwJCQweHh4eHh4eDB4eDB4eHh4ibGx6bB4eHh4MDAwNHh4eHh4eDB4NDAwMDGxCTU1Dej49bGxsbG4eHh4eHh4eHgwePU1wQ3BNcHBwcD4+cHBwcHBDDAweHmxCTUJDcHBDQ0NwPnBwcHBwcENwbh4ePU1NTU1NTUNDcD4+cHBwcHBwcHBwTT0ebm4mbD09QkI+PnBNTXBDQ0NwcHBwbB4eHh4MHh4eHmkdHn1sbD09cHBwcHBwDR4eHh4eHh4MaR4eHh4eHh4eHh59fX9stE4CaWhpBwcHaWlpaWlpCWkMCR4eHh0JHh5pDGgJCQwJDAl/fz4+Qj1CQj4+PR07Oz09PT49PnA+Hh0eHR4dHh4eHn1wcD49f306Hh4eO3BwcHBwWltbcHA9Hn09PlpbW1tbcDseHh47fn5+f39+Pn99fX5+fn5+fn5+kBICEA4OEBAQEA4QEBAQEBBmFhoaG2trLmtray8vLmtrLmtra2tra2sbLi8ua2tra2tragFoGmtra2sua2tramoBBmhra2tra2tragZqamhraxdmZhBoeGdqagQEBAQEBAQEd3dMagQFBAQEBAQEd0x3BwUEBAQEBAQE2GICWlpwOztxOzs7fQxpWlpwOjs7O319fR4JWlp+cTt9fX19fR5ofTt+fjt9fX19fR4JOzp+Wlpwfj19Hh4MfX1wcHBwcHBwcHA9fX1wcHBwcHBwcHA9fX1wcHBwcHBwcHBCfX1NcHBwTXBwPkNCfR1wcHBwQ3BwcENCzCYCbGxsbGxsbGxsHh4eHh4eHh4eDB4JCQkJCQkJCQkJCQkJCQkJcXE7O35+fn5YWFhYWFhYWFhYWFhYWFhYV3FYWFhYWFhYWFhYOjo6cX9YWFhYWFhYfnFYWFhYWFhYWFhYV3F+flhYWFhYWFhYVzpYWFhYWFhYWFhYMBwCN3g3b2sWFhYcHC57OTc5OTdISEhISHt8OTk3OUpKSEhISEhIUDlQckh4SHh4eEhyOTk5SEhIeHh4SEhIOTlQSEh4SHh4SHhINzk3SEh4SEh4eEh4dG9ycnJ4SHhIeEh4DxAFEBAWYHlvSEpyZQUFBQUQERAQBQRKGGwCdnZSdXVSUDlQUHY5dnV2dTlQOVBQOW9ndXZ2OTk5OTk3YBYcGm92UFBQORwaHGcWZxYWZhY3FhYcZ2ZnZmZmZhZQUDlmFmYWZmZmOTk5OTk3ORsWZmY5OTk5OTk5OXJyOVBQOTk3NzdycnJyUDk5OTc5cnJycnJy")
    gridPatches = {}
    local offset = 1
    while offset <= #pixels do
        local px, py, scale = string.byte(pixels, offset, offset+2)
        local width, height = 24/scale, 20/scale
        local rows = {}
        for start = offset+3, offset+2+width*height, width do
            rows[#rows+1] = {string.byte(pixels, start, start+width-1)}
        end
        gridPatches[#gridPatches+1] = {x = px*2, y = py*2, scale = scale, rows = rows}
        offset = offset+3+width*height
    end
end
local Palette = {0x0000,0x0001,0x0421,0x0002,0x0022,0x0023,0x0422,0x0423,0x0443,0x0821,0x0C22,0x0843,0x0C42,0x0C43,0x0024,0x0044,0x0444,0x0445,0x0446,0x0447,0x0467,0x0C64,0x0865,0x0866,0x0C66,0x0C85,0x0886,0x0887,0x0C86,0x1021,0x1042,0x1063,0x1C41,0x1862,0x1064,0x1483,0x10A7,0x1C84,0x18A6,0x0469,0x0868,0x08A8,0x088A,0x088B,0x0CC9,0x08AE,0x10C8,0x10C9,0x18C9,0x10EA,0x18E9,0x10ED,0x0D0D,0x150A,0x1D0A,0x152E,0x192D,0x194F,0x2041,0x2062,0x2882,0x24A6,0x28C6,0x3482,0x38E7,0x24E8,0x28E8,0x30E8,0x3D07,0x2509,0x212B,0x290A,0x212C,0x254D,0x216E,0x2D4C,0x2D6E,0x3509,0x0D33,0x1571,0x1970,0x1992,0x19D5,0x11F8,0x0E3C,0x1A39,0x225A,0x44A1,0x4CC2,0x48E4,0x4506,0x5547,0x4928,0x6188,0x571A,0x0424,0x0888,0x0C87,0x192E,0x212D,0x7FFF,0x0442,0x0844,0x0885,0x0842,0x0822,0x0021,0x1087,0x1884,0x0468,0x1083,0x10CA,0x38E6,0x1840,0x192C,0x0D0C,0x08C9,0x1592,0x1993,0x5B1B,0x214D,0x14C9,0x20C8,0x190A,0x210B,0x1842,0x3481,0x2862,0x11F9,0x1E5A,0x6588}
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

local function drawImage(image, minX, maxX)
    local scale = 2
    for i = 1, #image, 5 do
        local a,b,c,d,color = string.byte(image,i,i+4)
        if (c+1)*scale-1 >= minX and a*scale <= maxX then
            if (d+1)*scale-1 >= 16 then
                ui.rectfill(a*scale,math.max(16,b*scale),(c+1)*scale-1,(d+1)*scale-1,color-1)
            end
        end
    end
end

function update()
    local colorButton = held(BTN_X or 6)
    if colorButton and not previous then mode = mode % #formats + 1 end
    previous = colorButton
    local detailButton = held(BTN_Z or 7)
    if detailButton and not previousDetail then detail = not detail end
    previousDetail = detailButton
    ui.cls(0)
    local status
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
    local status = y <= 150 and "LUA / ATRAS" or "LUA / FRENTE"
    ui.palset(240, 0)
    ui.palset(241, encode(32767))
    ui.rectfill(0,0,479,15,240)
    ui.print("6.1 "..status.."  Z: "..(detail and "FINO" or "NORMAL").."  X: "..formats[mode],8,3,241)
    drawImage(detailedBackground, 0, 479)
    if detail and gridPatches then
        for _, patch in ipairs(gridPatches) do
            if not pcall(ui.grid, patch.x, patch.y, patch.scale, patch.scale, patch.rows) then
                gridPatches = nil
                break
            end
        end
    end
    courier()
    if y <= 150 then drawImage(detailedSofa, x-24, x+24) end
end
