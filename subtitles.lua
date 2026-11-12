-- Classic bottom-left subtitles. Accent marks extend the console's ASCII font.
local S={}
local accents={
 ['á']={'a','acute'},['é']={'e','acute'},['í']={'i','acute'},['ó']={'o','acute'},['ú']={'u','acute'},
 ['Á']={'A','acute'},['É']={'E','acute'},['Í']={'I','acute'},['Ó']={'O','acute'},['Ú']={'U','acute'},
 ['ã']={'a','tilde'},['õ']={'o','tilde'},['Ã']={'A','tilde'},['Õ']={'O','tilde'},
 ['â']={'a','hat'},['ê']={'e','hat'},['ô']={'o','hat'},['Â']={'A','hat'},['Ê']={'E','hat'},['Ô']={'O','hat'},
 ['à']={'a','grave'},['À']={'A','grave'},['ç']={'c','cedilla'},['Ç']={'C','cedilla'}
}
local function chars(text)
 local result={}
 for character in text:gmatch('[%z\1-\127\194-\244][\128-\191]*')do result[#result+1]=character end
 return result
end
function S.wrap(text,width)
 local lines,line={},''
 for word in text:gmatch('%S+')do
  local candidate=line==''and word or line..' '..word
  if #chars(candidate)>width and line~=''then lines[#lines+1]=chars(line);line=word else line=candidate end
 end
 if line~=''then lines[#lines+1]=chars(line)end
 return lines
end
local function length(lines)
 local n=0;for _,line in ipairs(lines)do n=n+#line end;return n
end
local function mark(ui,kind,x,y,ink)
 if kind=='acute'then ui.line(x+2,y-1,x+4,y-3,ink)
 elseif kind=='grave'then ui.line(x+1,y-3,x+3,y-1,ink)
 elseif kind=='hat'then ui.line(x,y-1,x+2,y-3,ink);ui.line(x+2,y-3,x+4,y-1,ink)
 elseif kind=='tilde'then ui.line(x,y-2,x+1,y-3,ink);ui.line(x+1,y-3,x+3,y-1,ink);ui.line(x+3,y-1,x+4,y-2,ink)
 elseif kind=='cedilla'then ui.line(x+2,y+7,x+3,y+8,ink);ui.line(x+3,y+8,x+1,y+9,ink)end
end
local function drawLine(ui,line,x,y,count)
 local plain,marks={},{}
 for i=1,math.min(#line,count)do
  local glyph=line[i];local accent=accents[glyph]
  plain[#plain+1]=accent and accent[1]or glyph
  if accent then marks[#marks+1]={accent[2],x+(i-1)*6}end
 end
 plain=table.concat(plain)
 for _,offset in ipairs({{-1,0},{1,0},{0,-1},{0,1}})do
  ui.print(plain,x+offset[1],y+offset[2],240)
  for _,a in ipairs(marks)do mark(ui,a[1],a[2]+offset[1],y+offset[2],240)end
 end
 ui.print(plain,x,y,241)
 for _,a in ipairs(marks)do mark(ui,a[1],a[2],y,241)end
end
function S.new()
 local d={active=false,clock=0,page=1,revealed=0,toastTime=0}
 function d:close()self.active=false;self.pages=nil;self.question=false;self.answer=nil end
 function d:open(pages)
  self.pages=pages;self.page=1;self.active=true;self.revealed=0;self.toastTime=0
  self.lines=S.wrap(pages[1],66);self.total=length(self.lines)
 end
 function d:ask(text,answer)
  self:open({text});self.question=true;self.answer=answer;self.choice=1;self.revealed=self.total
  self.choiceLeft,self.choiceRight=true,true
 end
 function d:notify(text,seconds)
  self.toast=S.wrap(text,66);self.toastTime=seconds or 2.5
 end
 function d:handle(confirm,cancel,left,right)
  if not self.active then return end
  if cancel then self:close();return end
  if self.question then
   if left and not self.choiceLeft then self.choice=1 end
   if right and not self.choiceRight then self.choice=2 end
   self.choiceLeft,self.choiceRight=left,right
   if confirm then local answer,yes=self.answer,self.choice==1;self:close();if yes and answer then answer()end end
   return
  end
  if confirm then
   if self.revealed<self.total then self.revealed=self.total
   elseif self.page<#self.pages then
    self.page=self.page+1;self.lines=S.wrap(self.pages[self.page],66)
    self.total=length(self.lines);self.revealed=0
   else self:close()end
  end
 end
 function d:tick(dt)
  self.clock=self.clock+dt
  if self.active then self.revealed=math.min(self.total,self.revealed+45*dt)
  else self.toastTime=math.max(0,self.toastTime-dt)end
 end
 function d:draw(ui)
  local lines=self.active and self.lines or(self.toastTime>0 and self.toast)
  if not lines then return end
  local remaining=self.active and math.floor(self.revealed)or math.huge
  local y=(self.question and 223 or 244)-(#lines-1)*14
  for _,line in ipairs(lines)do
   local x=32
   drawLine(ui,line,x,y,remaining);remaining=math.max(0,remaining-#line);y=y+14
  end
  if self.question then
   drawLine(ui,chars(self.choice==1 and '> Sim      Nao'or '  Sim    > Nao'),32,248,99);return
  end
  if self.active and self.revealed>=self.total and self.clock%1<.7 then
   ui.print('>',453,254,240);ui.print('>',452,253,241)
  end
 end
 return d
end
return S
