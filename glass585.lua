-- Foreground shower frame and glass tint, evaluated after actor projection.
local G={};local palette={};local tint={}
for i,v in ipairs({9651,2147,4234,11732,13846,3172,5320,4299,6375,5388,2117,2118,3205,3206,5292,5325,3175,3208,8558,9617,5285,5286,1058,1091,6479,7504,7400,7434,6414,6446})do local ix=i-1;palette[(ix<16 and 224+ix or 226+ix)+1]=v end
local function within(cameras,room,a,b,c)
 if room~='banheiro'or cameras.shot~=2 then return false end
 local x,y,d=(a[1]+b[1]+c[1])/3,(a[2]+b[2]+c[2])/3,(a[3]+b[3]+c[3])/3
 local p={};for i,v in ipairs({{.10,1.95,.09},{1.45,1.95,.09},{1.45,1.95,2.07},{.10,1.95,2.07}})do p[i]={cameras.project(room,v[1],v[2],v[3])}end
 for _,ix in ipairs({{1,2,3},{1,3,4}})do
  local u,v,w=p[ix[1]],p[ix[2]],p[ix[3]];local det=(v[2]-w[2])*(u[1]-w[1])+(w[1]-v[1])*(u[2]-w[2])
  local f=((v[2]-w[2])*(x-w[1])+(w[1]-v[1])*(y-w[2]))/det
  local g=((w[2]-u[2])*(x-w[1])+(u[1]-w[1])*(y-w[2]))/det;local h=1-f-g
  if f>=0 and g>=0 and h>=0 and d>f*u[3]+g*v[3]+h*w[3]+.035 then return true end
 end
 return false
end
function G.ink(cameras,room,a,b,c,ink)
 if not within(cameras,room,a,b,c)then return ink end
 if tint[ink]then return tint[ink]end
 local value=palette[ink+1];if not value then return ink end
 local r,g,b=value&31,(value>>5)&31,(value>>10)&31
 local grey=r*.30+g*.59+b*.11
 r,g,b=r*.70+grey*.30,g*.70+grey*.30,b*.70+grey*.30
 local best,score=ink,1e9
 for i,v in pairs(palette)do local dr,dg,db=(v&31)-r,((v>>5)&31)-g,((v>>10)&31)-b;local s=dr*dr+dg*dg+db*db;if s<score then best,score=i-1,s end end
 tint[ink]=best;return best
end
function G.draw(cameras,room,ui,gx,gy)
 -- The baked frame already receives scene lighting and depth occlusion.
 -- Do not repaint it in the full-bright HUD white over the character.
 return
end
return G
