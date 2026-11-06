-- ui.stat(7) reports actual FPS, including single-digit rates on the console.
-- Sample once per update so movement, turning and attacks share one timestep.
local T={dt=1/60,fps=nil}
function T.sample(ui)
 local fps
 if type(ui.stat)=='function'then
  local ok,value=pcall(ui.stat,7)
  if ok and type(value)=='number'and value==value and value>=2 and value<=240 then fps=value end
 end
 if fps then T.fps=fps end
 -- Bound long stalls; never turn a valid 5 FPS reading into a 60 Hz simulation.
 T.dt=math.min(.5,1/(T.fps or 60))
 return T.dt
end
return T
