-- Index zero is transparent on the console: never use it as a room carrier.
local M=require('metric_rooms')
for room,bank in pairs(M.banks)do
 for _,entry in ipairs(bank)do assert(entry[1]~=0,room..': transparent carrier')end
end
print('All eight room banks avoid transparent colour zero')
