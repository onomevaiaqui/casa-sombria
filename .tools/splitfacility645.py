from pathlib import Path
import sys
R=Path.cwd();sys.path.insert(0,str(R/'work/lua55-libs'));from lupa.lua54 import LuaRuntime
l=LuaRuntime(encoding=None);D=R/'outputs/Lupi-16.45';l.globals().src=str(D/'facility_data363.lua').encode()
result=l.execute(b'''local d=dofile(src);local out={};local function dump(t)if type(t)=='string'then return string.format('%q',t)elseif type(t)~='table'then return tostring(t)end;local a={'{'};for k,v in pairs(t)do a[#a+1]='['..dump(k)..']='..dump(v)..','end;a[#a+1]='}';return table.concat(a)end
for r,v in pairs(d.rooms)do local f={rooms={[r]=v},cameras={}};for i,c in ipairs(d.cameras)do f.cameras[i]=c.room==r and c or{rejected368=true}end;out[r]='return '..dump(f)end;return out''')
for r,s in result.items():
 s=b''.join(bytes([x])if x<128 else ('\\%03d'%x).encode()for x in s)
 (D/('facility_room645_'+r.decode()+'.lua')).write_bytes(s)
p=D/'facility363.lua';s=p.read_text().replace("local name=r=='campo'and'field_data645'or'facility_data363'","local name='facility_room645_'..r")
p.write_text(s)
print('Split native facility data into',len(list(result.items())),'rooms; preserve global camera indices')
