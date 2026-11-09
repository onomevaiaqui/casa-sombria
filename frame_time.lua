-- ui.stat(7) reports actual FPS, including single-digit rates on the console.
-- Sample once per update so movement, turning and attacks share one timestep.
local T={dt=1/60,fps=nil,frames=0,details=false,peakBytes=0}
local memoryControl=require('gc150')
local nativeCollision=require('native150')
local hudFirst,hudSecond
local function stat(ui,index)
 if type(ui.stat)=='function'then local ok,v=pcall(ui.stat,index);if ok and type(v)=='number'and v==v then return v end end
end
local wallStart,wallFrames,wallFps
function T.sample(ui)
 T.frames=T.frames+1
 if T.details then
  local bytes=stat(ui,0)
  if not bytes and type(collectgarbage)=='function'then local ok,kb=pcall(collectgarbage,'count');if ok then bytes=kb*1024 end end
  if bytes and bytes>=0 then T.luaBytes=bytes;T.peakBytes=math.max(T.peakBytes,bytes)end
  local cpu=stat(ui,1);T.cpu=cpu and cpu>=0 and cpu<=100 and cpu or nil
 end
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
 if T.details then
  if not hudFirst or T.frames%10==1 then
   hudFirst=value..'FPS C'..(T.cpu and tostring(math.floor(T.cpu+.5))or '--')..'%'
   local bytes=T.luaBytes and tostring(math.floor(T.luaBytes/1024+.5))or '--'
   hudSecond='L'..bytes..'K P'..tostring(math.floor(T.peakBytes/1024+.5))..'K G'..(memoryControl.mode=='generational'and 'G'or memoryControl.mode=='incremental'and 'I'or '?')..(nativeCollision.enabled and ' N'or ' L')
  end
  ui.rectfill(264,0,479,15,240);ui.print(hudFirst..' '..hudSecond,266,3,241);return
 end
 ui.rectfill(330,0,479,15,240)
 ui.print(value..' FPS F'..tostring(T.frames%100000),336,3,241)
end
return T
