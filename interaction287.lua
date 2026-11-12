-- One active interaction; only its compressed, offline-baked clip is loaded.
local I={}
local active,clip,module
local function release()
 clip=nil
 if module and type(package)=='table'and package.loaded then package.loaded[module]=nil end
 module=nil
end
local function load(kind)
 release();module='interaction287_'..kind;clip=require(module)
 assert(type(clip)=='table'and #clip.data==clip.count*1224,'Animacao de interacao incompleta')
end
local function interpolate(a,b,t)return a+(b-a)*t end
local function turn(a,b,t)return a+math.atan(math.sin(b-a),math.cos(b-a))*t end
function I.busy()return active~=nil end
function I.stage()return active and active.stage end
function I.begin(spec)
 if active then return false end
 active=spec;active.stage='align';active.time=0;active.progress=0;active.kind=spec.kind or 'pickup';load(active.kind);return true
end
function I.cancel()
 local s=active;active=nil;release();if s and s.cancel then s.cancel()end
end
function I.tick(dt)
 local s=active;if not s then return end
 dt=math.max(0,math.min(dt or 1/60,.10));s.time=s.time+dt
 local duration=s.stage=='align'and .28 or(s.stage=='cross'and(s.crossSeconds or .85)or(s.stage=='close'and clip.duration*.8 or clip.duration))
 local p=math.min(1,s.time/duration);s.progress=p
 if s.stage=='align'then
  local t=p*p*(3-2*p);s.set(interpolate(s.from[1],s.dock[1],t),interpolate(s.from[2],s.dock[2],t),turn(s.from[3],s.face,t))
 elseif s.stage=='open'then
  if s.kind~='pickup'and not s.opened and p>=.90 then s.opened=true;s.open()end
 elseif s.stage=='cross'then s.advance(p)
 elseif s.stage=='close'then
  if not s.closed and p>=.95 then s.closed=true;s.close()end
 end
 if p<1 then return end
 s.time=0;s.progress=0
 if s.stage=='align'then s.stage='open'
 elseif s.stage=='open'then
  if s.kind=='pickup'then active=nil;release();if s.finish then s.finish()end
  else if not s.opened then s.opened=true;s.open()end;s.stage='cross'end
 elseif s.stage=='cross'then s.stage='close';if s.faceBack then s.faceBack()end
 elseif s.stage=='close'then
  if not s.closed then s.close()end;active=nil;release();if s.finish then s.finish()end
 end
end
function I.pose(walk,idle)
 local s=active;if not s then return nil end
 if s.stage=='align'then return idle,0,'interaction_align'end
 if s.stage=='cross'then return walk,s.progress*(walk.count-1),'interaction_cross'end
 return clip,(s.stage=='close'and(1-s.progress)or s.progress)*(clip.count-1),'interaction_'..s.kind
end
function I.doorVisual()
 local s=active;if not s or not s.visualDoor or(s.stage~='open'and s.stage~='close')then return end
 local t=math.max(0,math.min(1,(s.progress-.17)/.68));t=t*t*(3-2*t)
 if s.stage=='close'then t=1-t end
 return s.visualFamily,s.visualDoor,math.floor(t*8+.5)+1
end
return I
