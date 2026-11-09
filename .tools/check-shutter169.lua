local S=require('shutter169');local data=require('shutter_data169');local C=require('cameras168');local D=require('doors131')
local refs={};local count=0
for room,views in pairs(data)do for shot,states in pairs(views)do for mask,modes in pairs(states)do for mode,tiles in pairs(modes)do for _,t in ipairs(tiles)do refs[t[1]]=t[1];count=count+1 end end end end end
S.setup(refs);C.enabled=true;C.active=true
local draws=0
for room,views in pairs(data)do for shot,states in pairs(views)do C.room=room;C.shot=shot
 for mask,modes in pairs(states)do D.reset();for _,door in ipairs(D.list)do if mask&door.bit~=0 then D.open(door.id)end end
 for mode,tiles in pairs(modes)do if mode==1 then D.open('garagem_externa')else D.opened.garagem_externa=nil end
 local n=0;S.draw(C,room,function(ref,x,y)assert(refs[ref]and x>=0 and y>=16);n=n+1;draws=draws+1 end);assert(n==#tiles,'wrong shutter state')
 end end end end
assert(data.garagem and data.frente and draws>0);print('PASS shutter: '..draws..' tile draws, closed/open states and camera palettes')
