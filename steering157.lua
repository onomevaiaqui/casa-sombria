-- Digital-pad steering. No analogue-stick dependency or per-frame tables.
local S={walkRate=16,aimRate=20}
local perspective=require('perspective')
local cameras=require('cameras168')
function S.turn(angle,target,dt,rate)
 local difference=(target-angle+math.pi)%(2*math.pi)-math.pi
 local limit=rate*math.max(0,math.min(dt,.5))
 return angle+math.max(-limit,math.min(limit,difference))
end
function S.target(room,x,y,dx,dy)
 if dx==0 and dy==0 then return end
 local gx,gy=perspective.ground(room,x,y)
 local tx,ty=perspective.ground(room,x+dx,y+dy)
 local wx,wy=tx-gx,ty-gy
 if cameras.enabled then wx,wy=cameras.captureDirection(room,gx,gy,dx,dy,wx,wy)end
 if wx*wx+wy*wy<1e-12 then return end
 return perspective.facing(room,wx,wy)
end
return S
