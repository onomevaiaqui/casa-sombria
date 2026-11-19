-- On-demand traversal poses. Scene anchors and height belong to the caller.
local T={active=false}
local pose,kind,time,finish,callback
local function load(name)
 pose=nil;kind=name;local n='traversal361_'..name;pose=require(n)
 if type(package)=='table'and package.loaded then package.loaded[n]=nil end
 time=0;T.active=true
end
function T.begin(name,onFinish)
 assert(name=='stairs'or name=='ladder'or name=='top','Unknown traversal')
 callback=onFinish;finish=false;load(name)
end
function T.finish()if kind=='ladder'then finish=true elseif kind=='stairs'then T.cancel()end end
function T.cancel()pose=nil;T.active=false;kind=nil;callback=nil end
function T.tick(dt)
 if not T.active then return end
 time=time+math.max(0,dt)
 if time>=pose.duration then
  if kind=='ladder'and finish then load('top')
  elseif kind=='top'then local f=callback;T.cancel();if f then f()end
  else time=time%pose.duration end
 end
end
function T.pose()if T.active then return pose,math.min(pose.count-1,time*pose.fps),'traversal_'..kind end end
return T
