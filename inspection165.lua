-- Shared inspection rule: B reads the visible face, never an undiscovered reverse.
local I={}
function I.text(front,back,angle,revealed)
 if back and revealed and math.cos(angle or 0)<-.72 then return back end
 return front
end
function I.caption(ui,text,y)
 if not text then return end
 local x=240-#text*3
 ui.rectfill(x-8,y,x+#text*6+8,y+18,240)
 ui.print(text,x,y+5,241)
end
function I.controls(ui)
 ui.print('DIRECIONAL: GIRAR  B: LER  A: VOLTAR',100,248,241)
end
return I
