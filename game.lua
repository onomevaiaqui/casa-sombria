local startup=require('startup544')
local diagnostic=require('save_probe700')
function update()
 if diagnostic.active then diagnostic.tick();return end
 startup.tick()
end
