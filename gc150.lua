-- Lua 5.5 changed GC parameter names; report which API actually succeeded.
local G={api='unavailable',mode='unknown',configured=false}
function G.configure(mode)
 mode=mode or 'incremental'
 if type(collectgarbage)~='function'then return false end
 local ok=pcall(collectgarbage,'param','pause',110)
 if ok then
  G.api='5.5';local step=pcall(collectgarbage,'param','stepmul',300)
  local switched=pcall(collectgarbage,mode)
  G.mode=switched and mode or 'default';G.configured=step and switched
 else
  local pause=pcall(collectgarbage,'setpause',110)
  local step=pcall(collectgarbage,'setstepmul',300)
  G.api=pause and 'legacy'or 'unsupported'
  local switched=pcall(collectgarbage,mode)
  G.mode=switched and mode or 'default';G.configured=pause and step
 end
 return G.configured
end
return G
