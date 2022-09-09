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
  _runctx("test tables")

  local ta = {2,4,6,8,10,12,14,16,18}
  local tb = {
    ["a"] = 1,
    ["b"] = 2,
    ["c"] = 3,
    ["d"] = 4,
    ["e"] = 5,
    ["f"] = 6,
  }
  local tc = {
    ["a"] = {
      ["0a"] = {"a", "b", "c", "d"},
      ["0b"] = 2,
      ["0c"] = 3,
    },
    ["b"] = {10,8,6,4},
  }
  logger:debug("with line breaks ta = ", ta)
  logger:debug("with line breaks tb = ", tb)
  logger:debug("with line breaks tc = ", tc)
  logger.formatter.tables.linebreaks = false
  logger:debug("no line breaks ta = ", ta)
  logger:debug("no line breaks tb = ", tb)
  logger:debug("no line breaks tc = ", tc)

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

runs[#runs + 1] = function ()
  _runctx("test table max length")
  logger.formatter.tables.max_length = 5

  local ta = {2,4,6,8,10,12,14,16,18}
  local tb = {
    ["a"] = 1,
    ["b"] = 2,
    ["c"] = 3,
    ["d"] = 4,
    ["e"] = 5,
    ["f"] = 6,
  }

  logger:info("This is ta: ", ta)
  print("    ta should display [...]")
  logger:info("This is tb: ", tb)
  print("    tb should display [...]")

end


runs[#runs + 1] = function ()
  _runctx("test table linebreak_treshold")
  logger.formatter.tables.linebreak_treshold = 4

  local ta1 = {2,4,6,8,10,12,14,16,18}
  local ta2 = {2,4,6,8}
  local tb = {
    ["a"] = 1,
    ["b"] = 2,
    ["c"] = 3,
    ["d"] = 4,
    ["e"] = 5,
    ["f"] = 6,
  }

  logger:info("This is ta1: ", ta1)
  print("  ta1 shoudl not break")
  logger:info("This is ta2: ", ta2)
  print("  ta2 should break")

  logger:info("This is tb: ", tb)
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
