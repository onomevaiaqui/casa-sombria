-- Four independent decimal rollers. No save item or inventory slot is required.
local L={};L.__index=L
function L.new()return setmetatable({digits={0,0,0,0},selected=1,previous={},active=false},L)end
function L:reset()self.digits={0,0,0,0};self.selected=1;self.active=false;self.previous={}end
function L:begin()self.active=true;self.message='';self.previous={b=true};self.repeatTime=0 end
function L:setup(refs,palette)
 self.refs=refs;self.map={};for i,v in ipairs(palette)do self.map[v]=i-1 end
 self.data=require('lock_data158')
end
function L:input(keys,dt,doors)
 local function edge(k)return keys[k]and not self.previous[k]end
 if edge('a')then self.active=false;self.previous=keys;return 'cancel' end
 if edge('left')then self.selected=(self.selected+2)%4+1 end
 if edge('right')then self.selected=self.selected%4+1 end
 local direction=keys.up and 1 or(keys.down and -1 or 0)
 if direction~=0 then
  self.repeatTime=(self.repeatTime or 0)-dt
  if edge('up')or edge('down')or self.repeatTime<=0 then
   self.digits[self.selected]=(self.digits[self.selected]+direction)%10
   self.repeatTime=(edge('up')or edge('down'))and .32 or .11;self.message=''
  end
 else self.repeatTime=0 end
 if edge('b')then
  if table.concat(self.digits)=='2019'then doors.open('casinha');self.active=false;self.previous=keys;return 'opened'
  else self.message='CODIGO INCORRETO' end
 end
 self.previous=keys
end
function L:draw(ui)
 ui.cls(0)
 if self.data and self.refs then
  for _,p in ipairs(self.data.bank)do local i=self.map[p[1]];if i then ui.palset(i,p[2])end end
  for i=0,2 do ui.spr(self.refs['lock158_'..i],0,i*90)end
 end
 ui.palset(240,0);ui.palset(241,32767);ui.palset(242,31);ui.palset(243,15855)
 local segments={'abcdef','bc','abged','abgcd','fgbc','afgcd','afgecd','abc','abcdefg','abfgcd'}
 local lines={a={2,2,9,3},b={9,3,10,10},c={9,11,10,18},d={2,18,9,19},e={1,11,2,18},f={1,3,2,10},g={2,10,9,11}}
 for i,n in ipairs(self.digits)do
  local c=self.data and self.data.centres[i]or{200+i*18,135};local x,y=c[1]-6,c[2]-10
  ui.rectfill(x-3,y-3,x+14,y+23,i==self.selected and 242 or 243)
  ui.rectfill(x-1,y-1,x+12,y+21,241)
  for ch in segments[n+1]:gmatch('.')do local a=lines[ch];ui.rectfill(x+a[1],y+a[2],x+a[3],y+a[4],240)end
 end
 ui.rectfill(0,0,479,24,240);ui.print('CADEADO',24,8,241)
 ui.rectfill(0,218,479,269,240);ui.print(self.message or '',24,221,242)
 ui.print('ESQ/DIR: SELECIONAR   CIMA/BAIXO: GIRAR',24,237,241)
 ui.print('B CONFIRMAR   A VOLTAR',24,253,241)
end
return L

