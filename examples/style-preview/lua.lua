-- Line comment.
--- Documentation-style comment.
--[[
Block comment for the Lua lexer.
]]

local project_name = "mrbmacs"
local count = 17
local literal = [[long string
with multiple lines]]

local function greet(name)
  if name == nil then
    return "missing"
  elseif count > 0 then
    return string.format("hello %s: %d", name, count)
  end
  return literal
end

::retry::
for index, value in ipairs({ "lua", "lexer" }) do
  print(index, value, greet(project_name))
end

goto retry
