-- ui.stat(7) reports actual FPS, including single-digit rates on the console.
-- Sample once per update so movement, turning and attacks share one timestep.
local T={dt=1/60,fps=nil,frames=0}
local wallStart,wallFrames,wallFps
function T.sample(ui)
 T.frames=T.frames+1
 local fps
 if type(ui.stat)=='function'then
  local ok,value=pcall(ui.stat,7)
  if ok and type(value)=='number'and value==value and value>=2 and value<=240 then fps=value end
 end
 if fps then T.fps=fps end
 -- Coarse real wall-clock fallback for simulators that omit ui.stat(7).
 -- This is HUD-only; never derive gameplay speed from CPU time or this estimate.
 if not fps and type(os)=='table'and type(os.time)=='function'then
  local ok,now=pcall(os.time)
  if ok and type(now)=='number'then
   if not wallStart then wallStart,wallFrames=now,T.frames
   elseif now-wallStart>=2 then
    wallFps=(T.frames-wallFrames)/(now-wallStart);wallStart,wallFrames=now,T.frames
   end
  end
 end
 -- Bound long stalls; never turn a valid 5 FPS reading into a 60 Hz simulation.
 T.dt=math.min(.5,1/(T.fps or 60))
 return T.dt
end
function T.hud(ui)
 local actual=T.fps or wallFps
 local value=actual and((T.fps and ''or '~')..tostring(math.floor(actual+.5)))or '--'
 ui.rectfill(330,0,479,15,240)
 ui.print(value..' FPS F'..tostring(T.frames%100000),336,3,241)
end
return T
