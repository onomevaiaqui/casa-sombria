-- Offline-rendered steel shutter, using each camera's existing color bank.
local data=require('shutter_data169')
local doors=require('doors131')
local M={}
local refs
function M.setup(sprites)refs=sprites end
function M.draw(camera,room,spr)
 if not refs or not camera.enabled or not camera.active then return end
 local roomData=data[room];local view=roomData and roomData[camera.shot]
 if not view then return end
 local c=camera.data[room][camera.shot]
 local states=view[doors.stateMask(c.doorBits)]
 local tiles=states and states[doors.isOpen('garagem_externa')and 1 or 0]
 if tiles then for _,tile in ipairs(tiles)do
  local ref=refs[tile[1]];if ref then spr(ref,tile[2],tile[3])end
 end end
end
return M
