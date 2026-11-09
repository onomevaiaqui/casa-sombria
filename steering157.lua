-- Classic digital tank controls, independent of the active render camera.
local S={turnRate=3.2,runTurnRate=2.5,aimTurnRate=2.6}
local metric=require('metric_rooms')
function S.rotate(angle,horizontal,dt,aiming,running)
 local rate=aiming and S.aimTurnRate or(running and S.runTurnRate or S.turnRate)
 return(angle-horizontal*rate*math.max(0,math.min(dt,.5)))%(2*math.pi)
end
function S.forward(room,angle)
 local rx,ry,ax,ay=metric.basis(room)
 local sine,cosine=math.sin(angle),math.cos(angle)
 local x,y=-(rx*sine+ax*cosine),-(ry*sine+ay*cosine)
 local length=math.sqrt(x*x+y*y)
 return x/length,y/length
end
return S
