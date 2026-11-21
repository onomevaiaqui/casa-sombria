local A={enabled=true,clocks={}}
function A.configure(preview)A.enabled=not not preview end
function A.emit(name)if A.enabled then require('audio697').effect(name)end end
function A.presence(id,alive,near,dt)
 if not A.enabled or not alive or not near then A.clocks[id]=nil;return end
 local t=(A.clocks[id]or 1.5)+(dt or 0)
 if t>=7 then t=0;A.emit((id=='window'and 'janela'or id=='front'and 'mulher'or id=='field'and 'menino'or 'inimigo')..'_presenca')end
 A.clocks[id]=t
end
return A
