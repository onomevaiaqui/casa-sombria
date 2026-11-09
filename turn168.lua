-- Offline-baked in-place poses. Actual steering owns the rotation and translation.
local data=require('turn_data168')
local T={direction=0,phase=0,position=0}
function T.stop()T.direction=0;T.phase=0;T.position=0 end
function T.tick(horizontal,active,delta)
 if not active or horizontal==0 or math.abs(delta)<1e-9 then T.stop();return end
 local direction=horizontal<0 and -1 or 1
 if direction~=T.direction then T.phase=0 end
 T.direction=direction
 local clip=direction<0 and data.left or data.right
 T.phase=(T.phase+math.abs(delta)/clip.turnRadians)%1
 -- Invert source yaw to synchronize planted feet with the unchanged game turn speed.
 local progress=clip.progress;local lo,hi=1,#progress
 while hi-lo>1 do local mid=math.floor((lo+hi)/2);if progress[mid]<=T.phase then lo=mid else hi=mid end end
 local span=progress[hi]-progress[lo]
 T.position=lo-1+(span>1e-9 and(T.phase-progress[lo])/span or 0)
end
function T.clip()return T.direction<0 and data.left or data.right end
return T
