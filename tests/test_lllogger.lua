--[[

Primitive tests. No assert cause lazy.

]]

local logging = require("lllogger")
local LNAME = "lllogerTest"
local logger = logging.getLogger(LNAME)


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

  logger:setLevel("error")

  logger:info("!! this should not be printed")
  logger:error("this should be printed")

end

runs[#runs + 1] = function ()
  _runctx("log level change after a first change")
  logger:setLevel("debug")
  logger:debug("this is a debug message, should be printed.")

end

runs[#runs + 1] = function ()
  _runctx("log with multiple argument types")
  logger:setLevel("debug")
  local t = {"2", "4", "8"}
  logger:debug("Debug:", 100, ", t=", t)

end

runs[#runs + 1] = function ()
  _runctx("log with duplicate blocking")
  logger:setLevel("debug")
  logger.formatter:set_blocks_duplicate(true)

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
  logger:setLevel("debug")
  logger.formatter:set_blocks_duplicate(true)

  logger:info("Hello from run05 !")
  for i=1, 7 do
    logger:info("Hello from run05's loop")
    if i==5 then
      logger:error("Error *simulation* at index 5")
    end
  end
  logger:info("Goodbye from run05 ! You should see 7 message repeated above.")
end

runs[#runs + 1] = function ()
  _runctx("changing global formatting")
  logger:setLevel("debug")
  logger.formatter:set_blocks_duplicate(true)
  logger.formatter.template = "{time} [{level:9}] {{appctx}}({logger}){message}"
  logger.formatter.time_format = "%H:%M:%S"

  logger:info("Hello from run06 !")
  for i=1, 15 do
    logger:info("Hello from run06's loop")
    if i==5 then
      logger:error("Error *simulation* at index 5")
    end
  end
  logger:info("Goodbye from run06 !")
end


runs[#runs + 1] = function ()
  _runctx("changing duplicate template")
  logger:setLevel("debug")
  logger.formatter:set_blocks_duplicate(true)
  logger.formatter.template_duplicate = "  {time} repeated {nrepeat} times"
  logger.formatter.time_format = "%H:%M:%S"

  logger:info("Hello from run06 !")
  for i=1, 15 do
    logger:info("Hello from run06's loop")
    if i==5 then
      logger:error("Error *simulation* at index 5")
    end
  end
  logger:info("Goodbye from run06 !")
end


print("\n\n")
print(string.rep("=", 125))
print(string.rep("=", 125))
print(("[llloger.test] %s Starting ..."):format(os.date()))
print(string.rep("=", 125))
for _, func in ipairs(runs) do
  logger = logging.getLogger(LNAME, true)
  func()
end
