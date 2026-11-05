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
local detailedSofa = decode("ZEBnQBNKQU9BeVBBWUErWkFpQSk0QjtCSzxCWUIrWkJpQilqQmxCFzFDO0MsPENZQytaQ2lDKWpDbEMXLkQwRBUxRDtELDxEWUQrWkRpRClqRGxEF21EbUQlLkUwRRUxRTtFLDxFWUUrWkVpRSlqRWxFF21FbUUvLkYwRhIxRjtGLDxGWUYrWkZpRilqRmxGLG1GcEYuLUcwRxIxRztHLDxHWUcrWkdpRylqR25HFW9HdEcsLUgwSBIxSDtILDxIWUgrWkhpSClqSG5IFW9Id0gseEh4SC4sSSxJNS1JMEkSMUk7SSw8SVlJK1pJaUkpakl6SRV7SXtJEylKLUouLkowShMxSjtKLDxKWUorWkppSilqSnpKFXtKe0oTJksmS1EnSypLKytLMEsuMUs1Sys2SztLLDxLWUsrWktpSylqS3dLFXhLe0sTJkwmTFEnTCpMKytMNUwuNkw7TCw8TFlMK1pMaUwpakx3TBV4THtMEyZNJk1RJ00sTRUtTTVNLjZNO00sPE1ZTStaTW1NLG5Nc00rdE13TW54TXtNEyZOJk5RJ04sThUtTjVOLjZOO04sPE5ZTitaTm1OLG5Oc04rdE53Tm54TntOEyZPJk9RJ08wTxUxTzVPLjZPO08sPE9BTytCT0lPE0pPWU8uWk9tTyxuT3NPK3RPd09ueE98TxMmUCZQOidQOVAVOlA7UBI8UFlQLlpQbVAsblB3UBV4UHxQEyZRJlE6J1E5URU6UVlRLlpRbVEsblF3URV4UXxREydSOVIVOlJZUi5aUm1Sbm5Sd1IVeFJ8UhMnUzlTFTpTWVMuWlN8UxMnVDlUFTpURVQuRlRZVClaVHxUEydVOVUVOlU7VS48VUVVLEZVWVUpWlV8VRMnVjtWFTxWWVYpWlZ8VhMnVztXFTxXSlcpS1d8VxMnWDtYFTxYSlgpS1h8WBMnWTtZFTxZQlkpQ1lKWRJLWVlZE1pZd1kVeFl6WRMnWjBaEzFaO1oVPFpQWhNRWmlaFWpad1oReFp5WmsnWzBbEzFbO1sVPFtQWxNRW2lbFWpbd1sReFt4Wx0nXDBcEzFcO1wVPFxQXBNRXGlcFWpcdVwRJ10wXRMxXVldFVpdaV0Ral1uXWInXjBeEzFeWV4VWl5nXhEnXyxfCC1fMF8TMV9QXxVRX1lfCVpfXF8HXV9gX2InYCxgCC1gMGATMWBLYBVMYFBgBVFgWWAJJ2EnYTQoYSlhBSphLGEILWEwYRMxYURhFUVhS2EITGFQYQVRYVJhKiliKWJ3KmIsYggtYjBiEzFiO2IVPGJEYhFFYkliB0piS2JhLGMsY3QtYztjETxjQmMHQ2NEYyovZDtkETxkPWQYMWU2ZRE=")
local detail, previousDetail = true, false
local gridPatches
if type(ui.grid) == "function" then
    local pixels = decode("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RE1wfj07cX19Hh4ecHBwcHBwcE1NRE1NTVxaWlpacHBwfj07cHBwcHBwcE1NcHBNcHBwcHBwcHBwWlxNcHBwcHBwcE1NcHBNcHBwcE1wcHBwcE1NcHBwcHBwcHBwcE1NcHBEcHBwcHBwcE1NcHBwcHBwTXBwcE1NcE1wcHBwcHBwTU1NcHBwcHBNTXBwTU1NcE1EcE1wcHBDcE1NcHBwcE1wcHBwTU1NTU1wcE1wcHBwcE1NcHBwQ01wTXBwTU1wTU1wcHBwcENNcE1NcHBwTXBwTXBwTU1wcE1wcHBwcE1wcE1NcHBwcHBwTU1wTXBwcHBwcHBwcENwcHBNcHBwcHBwTXBwcHBDcHBwTXBwcHBwcHBwRHBNTXBwTXBNTXBNTXBwcHBwcHBwcE1wfTt/PT5DTXBNTU1NcHBwcHBwcHBwcE1NHh4eHh4efTs+PkNDcHBwcHBwcHBwcE1wHh4eHn0eHh4iHh59Oz09Pj5wcHBwcD4+Hh4efR4eHh4eHn0eHh4eHR59Oz0+Pj5wkBICEA4OEBAQEA4QEBAQEBBmFhoaG2trLmtray8vLmtrLmtra2tra2sbLi8ua2tra2tragFoGmtra2sua2tramoBBmhra2tra2tragZqamhraxdmZhBoeGdqagQEBAQEBAQEd3dMagQFBAQEBAQEd0x3BwUEBAQEBAQEzFgCW1t+O319fn5YWFtaW1l9fX19fn5+fn5+flo9fzt+fn5+fn5+fnBacERbW1tbW1pZcHBaRFuCW1tbW1tbflpwWltbW1tbW1tbfX19O35+flhaWltbHn19fn5+fn5+fn5+Hn07fn5+fn5+fn5+Pn9+fn5+fn5+fn5+GGwCYGBgKytgdFJVgIBSKysrG2BgYGAbYE9SYBpgYBsbGhobG2BgYGAaGhsbHGBgK2BPGhsbYGArK2A3UlJSGysrKxo3UlJSUlJSYBdvdVJ2dnZ2dnVSdXZ1dlJSdXZ1dXZ1UHZ2UHV1dXV1dnZ2UFB2dXZ2dXZ2OVBQqGICHh4eHh4eHh4efT0+Hh4eHh4eHh4eHh4eHh4eHR0eHh4eHh4dHh4eHh59Hn0eHh4ePWwdHgweHh4eHh0ePUJNTU1DPmweHh4eZyJsTU1NTU1wcE1DImsmQk1NTU1wcENDR0dHTU1NTU1NcEceR0tLRz5CTU1HQx4enDoCfHh8fHh7eXt7GmhoSHhIfHx7ay5rMGhlfHx7SCZoaGhlaGhlSHx8a2tra2hoZWpqfHt5e3t7MHtoaGVpe3t7e3x5eXswaGhle3t8e3l5eTBrax5qeXt7e3x5MGtrIiIie3l5e3t7MHkuay4mcnt7e3t5e3wua2ZohDoCbGxsbD09PT1sPT09bD1sOz1sIj09PW49PWxsPT0eBQUODmg9PT1sPT0eZn89PQY9O2xsbD0eaGw9bGg9ZRYWFxcSFhZmFhcXBgUFAwMEAWoBAwkJPTsean8eCWw9aWo9IiIeajtmaGw9aWp/amoDBWUFBwQEBWpp")
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
    ui.print("6.2 "..status.."  Z: "..(detail and "FINO" or "NORMAL").."  X: "..formats[mode],8,3,241)
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
