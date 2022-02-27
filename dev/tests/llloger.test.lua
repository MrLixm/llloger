--[[

Primitive tests. No assert cause lazy.

]]

local logging = require("lllogger")
local logger = logging:get_logger("LllogerTest")


local function _runctx(test_msg)
  local buf = {}
  buf[#buf+1] = "\n"
  buf[#buf+1] = string.rep("_", 50)
  buf[#buf+1] = "\n[test line"
  buf[#buf+1] = debug.getinfo(2).linedefined
  buf[#buf+1] = "]\n"
  buf[#buf+1] = test_msg
  buf[#buf+1] = "\n--------\n"
  print(table.concat(buf))
end

local runs = {}

runs[#runs + 1] = function ()
  _runctx("log level change")
  -- should print
  logger:debug("this is a debug message")

  logger:set_level("error")

  logger:info("!! this should not be printed")
  logger:error("this should be printed")

end

runs[#runs + 1] = function ()
  _runctx("log level change after a first change")
  logger:set_level("debug")
  logger:debug("this is a debug message, should be printed.")

end

runs[#runs + 1] = function ()
  _runctx("log with multiple argument types")
  logger:set_level("debug")
  local t = {"2", "4", "8"}
  logger:debug("Debug:", 100, ", t=", t)

end

runs[#runs + 1] = function ()
  _runctx("log with duplicate blocking")
  logger:set_level("debug")
  logger.formatting:set_blocks_duplicate(true)

  logger:info("Hello from run04 ! You should now see multiple message :")
  for i=1, 15 do
    logger:info("   Hello from run04's loop index <", i, ">")
  end
  logger:info("Now you should see only one message :")
  for i=1, 15 do
    logger:info("   Hello from run04's loop")
  end

  logger:info("Goodbye from run04 !")

end

runs[#runs + 1] = function ()
  _runctx("log with duplicate blocking special case 01")
  logger:set_level("debug")
  logger.formatting:set_blocks_duplicate(true)

  logger:info("Hello from run05 !")
  for i=1, 15 do
    logger:info("Hello from run05's loop")
    if i==5 then
      logger:error("Error *simulation* at index 5")
    end
  end
  logger:info("Goodbye from run05 !")

end

runs[#runs + 1] = function ()
  _runctx("log formatting : no line")

  logger:set_level("debug")

  logger:debug("Without context.")
  logger:info("Without context.")
  logger:error("With context.")
  logger.ctx = "Context from line 94 !"
  logger:info("With context.")
  logger:info("Without context.")
  logger.formatting:set_display_context(false)
  logger:debug("Without context.")
  logger:error("Without context.")
  logger.ctx = "Context from line 100 !"
  logger:info("Without context.")

end

runs[#runs + 1] = function ()
  _runctx("logging display levels available")

  logger:info(logging:list_levels())

end


runs[#runs + 1] = function ()
  _runctx("display time tests")

  logger:set_level("debug")

  logger.formatting:set_display_time(true)
  logger:info("With time.")

  logger.formatting:set_display_time(false)
  logger:debug("Without time.")
  logger:info("Without time.")
  logger:error("Without time.")

  logger.formatting:set_display_time(true)
  logger:debug("With time.")

end



print("\n\n")
print(string.rep("_", 125))
print("[llloger.test] Starting ...")
for _, func in ipairs(runs) do
  func()
end