-- Shared full-screen file reader. Bitmaps load lazily through immutable sprite references.
local Reader={}
function Reader.new(id)
 local doc=assert(require('doc655_data')[id],'Arquivo sem leitura: '..tostring(id))
 local state={id=id,page=1,doc=doc}
 function state:handle(pressed)
  if pressed.left or pressed.l then self.page=math.max(1,self.page-1)
  elseif pressed.right or pressed.r then self.page=math.min(#self.doc.pages,self.page+1)
  elseif pressed.b then
   if self.page<#self.doc.pages then self.page=self.page+1 else return true end
  end
  return false
 end
 function state:draw()
  local sprites=require('sprite_refs697')
  local colors=require(self.doc.mother and 'note649_colors718'or'doc655_paper_colors718')
  ui.palset(240,0);ui.palset(241,32767);ui.cls(240)
  for i,v in ipairs(colors)do
   v=math.floor((v&31)*.32)|(math.floor(((v>>5)&31)*.32)<<5)|(math.floor(((v>>10)&31)*.32)<<10)
   ui.palset(i-1,v)
  end
  local paper=self.doc.mother and'note649'or'doc655_paper'
  ui.spr(sprites[paper..'_0'],100,5);ui.spr(sprites[paper..'_1'],100,135)
  ui.palset(192,29|(28<<5)|(23<<10));ui.palset(193,1|(1<<5)|(1<<10))
  ui.palset(194,22|(22<<5)|(18<<10));ui.palset(195,14|(14<<5)|(12<<10))
  ui.palset(196,11|(12<<5)|(10<<10));ui.palset(197,17|(25<<5)|(20<<10));ui.palset(198,5|(6<<5)|(5<<10))
  ui.line(24,46,456,46,198);ui.line(24,200,456,200,198)
  local prefix=self.doc.pages[self.page].prefix
  ui.spr(sprites[prefix..'_0'],35,52);ui.spr(sprites[prefix..'_1'],35,137)
  if self.page>1 then ui.print('<',10,123,197)end
  if self.page<#self.doc.pages then ui.print('>',463,123,197)end
  ui.print(self.page..' / '..#self.doc.pages,404,211,196)
  ui.print('A: arquivos   '..(self.page<#self.doc.pages and'B: proxima pagina'or'B: arquivos'),8,251,241)
  if #self.doc.pages>1 then ui.print('< >: paginas',362,251,241)end
 end
 return state
end
return Reader
