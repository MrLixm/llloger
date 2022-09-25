local _M_ = {}
_M_._VERSION = "2.0.0"
_M_._AUTHOR = "<Liam Collod monsieurlixm@gmail.com>"
_M_._DESCRIPTION = "A simple logging module based on Python one."
_M_._LICENSE = [[
  Copyright 2022 Liam Collod

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
]]

-- make some global lua fonction local to improve perfs
local tableconcat = table.concat
local tostring = tostring
local stringrep = string.rep
local tonumber = tonumber
local stringformat = string.format
local select = select
local print = print
local type = type

-------------------------------------------------------------------------------
-- CONSTANTS

--- Log levels available.
local LEVELS = {
      DEBUG = {
        name = "DEBUG",  -- name displayed in the console
        weight = 10
      },
      INFO = {
        name = "INFO",
        weight = 20
      },
      WARNING = {
        name = "WARNING",
        weight = 30
      },
      ERROR = {
        name = "ERROR",
        weight = 40,
      }
}

--- list of instances of all loggers ever created
--- numerical table
local __loggers = {}

--- This is available as a token in the Formatter template and allow to distinguinsh
--- llloger message from other loggers from potential other languages.
local APPCONTEXT = os.getenv("LLLOGGER_CONTEXT")
if not APPCONTEXT then
  APPCONTEXT = "lua"
end


--- All logger instances will use this level instead of the one set on them.
local LEVEL_OVERRIDE = os.getenv("LLLOGGER_LEVEL_OVERRIDE")
if LEVEL_OVERRIDE then
  LEVEL_OVERRIDE = LEVELS[LEVEL_OVERRIDE]
end

-------------------------------------------------------------------------------
-- functions/classes

--- The loop-safe string concatenation method.
--- @return string
local conkat

--- Convert a table to human readable string.
--- By default formatted on multiples lines for clarity. Specify tdtype=oneline
---   to get no line breaks.
--- If the key is a number, only the value is kept.
--- If the key is something else, it is formatted to "stringify(key)=stringify(value),"
--- If the table is too long (max_length), it is formatted as oneline
--- @param tablevalue table table to convert to string
--- @param depth number recursive level of stringify
--- @param settings Formatter|nil Configure how table are displayed.
--- @return string
local table2string

--- Convert the source to a readable string , based on it's type.
--- @param source any any type
--- @param depth number recursive level of stringify
--- @param formatter Formatter configure how source is formatted
local stringify

--- Source: http://lua-users.org/wiki/SimpleRound
--- @param num number number to round
--- @param numDecimalPlaces number number of decimal to keep
--- @return number
local round

--- token are expressed as "{token}" in <source> but also as "{token:args}" where
--- "args" are passed to string.format (https://en.cppreference.com/w/c/io/fprintf#Parameters)
--- @param token string  token to find in source
--- @param source string template string where we can find the token
--- @param value string any string to replace the token with
--- @return string source argument with the given <token> replace by <value> if <token> found.
local tokenReplace

--- @class Formatter
local Formatter = {}

--- @class Logger
local Logger = {}

conkat = function (...)
  local buf = {}
  for i=1, select("#",...) do
    buf[ #buf + 1 ] = tostring(select(i,...))
  end
  return tableconcat(buf)
end

stringify = function(source, depth, formatter)

  if not formatter then
    formatter = Formatter:new()
  end

  if not depth then
    depth = 0
  end


  if (type(source) == "table") then
    source = table2string(source, depth, formatter)

  elseif (type(source) == "number") then
    source = tostring(round(source, formatter.numbers.round))

  elseif (type(source) == "string") and formatter.strings.display_quotes == true then
    source = conkat("\"", source, "\"")

  elseif (type(source) == "string") then
    -- do nothing

  else
    source = tostring(source)

  end

  return source

end

table2string = function(tablevalue, depth, settings)

  -- check if table is empty
  if next(tablevalue) == nil then
   return "{}"
  end

  -- if no depth specified, recursive level is 0 (first time)
  if not depth then
    depth = 0
  end

  local tsettings
  if settings and settings.tables then
    tsettings = settings.tables
  else
    tsettings = Formatter:new().tables
  end

  local linebreak_start = "\n"
  local linebreak = "\n"
  local inline_indent = stringrep(
      "$i$", depth * tsettings.indent + tsettings.indent
  )
  local inline_indent_end = stringrep(
      "$i$", depth * tsettings.indent
  )

  -- to avoid string concatenation in loop, we use a table
  local out = {}
  out[#out + 1] = "{"
  out[#out + 1] = linebreak_start

  local table_length = 1
  -- we can only use pairs() as we dont know if the table keys are only numeric
  for k, v in pairs(tablevalue) do

    if tsettings.max_length > 0 and table_length >= tsettings.max_length then
      out[#out + 1] = inline_indent
      out[#out + 1] = ("[...]")
      out[#out + 1] = linebreak
      break
    end

    -- if table is build with number as keys, just display the value
    if (type(k) == "number") and tsettings.display_indexes == false then
      out[#out + 1] = inline_indent
      out[#out + 1] = stringify(v, depth +1, settings)
      out[#out + 1] = ","
      out[#out + 1] = linebreak
    else

      if (type(v) == "function") and tsettings.display_functions == false then
        out[#out + 1] = ""
      else
        out[#out + 1] = inline_indent
        out[#out + 1] = stringify(k, depth +1, settings)
        out[#out + 1] = "="
        out[#out + 1] = stringify(v, depth +1, settings)
        out[#out + 1] = ","
        out[#out + 1] = linebreak
      end
    end
    table_length = table_length + 1
  end
  out[#out + 1] = inline_indent_end
  out[#out + 1] = "}"

  out = tostring(tableconcat(out))

  -- if specifically asked for the table to be displayed as one line
  if tsettings.linebreaks == false then
    out = out:gsub("%$i%$", "")
    out = out:gsub("\n", "")
  -- if the table is too long make it one line with no line break
  elseif table_length > tsettings.linebreak_treshold then
    out = out:gsub("%$i%$", "")
    out = out:gsub("\n", "")
  else
    out = out:gsub("%$i%$", " ")
  end

  return out

end

round = function(num, numDecimalPlaces)
  return tonumber(
      stringformat(
          conkat("%.", (numDecimalPlaces or 0), "f"),
          num
      )
  )
end

--- Replace the given <token> existing or not in the <source> with the given <value>.

tokenReplace = function(token, source, value)

  local format_arg = source:match(("{%s:([^}]+)}"):format(token))
  local replace_with = "%s"
  if format_arg then
    replace_with = ("%%%ss"):format(format_arg)
  end
  replace_with = replace_with:format(value)
  local replaced = source:gsub(("{%s[^}]*}"):format(token), replace_with)
  return replaced

end

--- The logger message formatter. Configure how message are displayed.
function Formatter:new(template)

  -- these are the default values
  local attrs = {

    ["blocks_duplicate"] = true,

    --- see https://www.lua.org/pil/22.1.html for available tokens
    ["time_format"] = "%c",  -- %c ~= "09/16/98 23:48:10"

    ---tokens available are :
    ---[time, message, logger, level, appctx]
    ---
    ---check https://en.cppreference.com/w/c/io/fprintf#Parameters for what
    ---string formatting arg are available (defined after the ":")
    ["template"] = "[{level:-7}] {time} [{appctx}][{logger}]{message}",

    --- tokens available are :
    --- [time ,logger, appctx ,nrepeat]
    ---
    --- check https://en.cppreference.com/w/c/io/fprintf#Parameters for what
    --- string formatting arg are available (defined after the ":")
    ["template_duplicate"] = "    [{logger}] The last message was repeated <{nrepeat}> times ...",

    ["numbers"] = {
      --- how much decimals should be kept for floating point numbers
      ["round"] = 3
    },
    ["tables"] = {
      --- how much whitespaces is considered an indent
      ["indent"] = 4,
      --- maximum number of table element that can be displayed before being "cut"
      ["max_length"] = 999,
      --- max table size before displaying it as oneline to avoid flooding
      ["linebreak_treshold"] = 50,
      --- true to display the table on multiples lines with indents
      ["linebreaks"] = true,
      ["display_indexes"] = false,
      ["display_functions"] = true
    },
    ["strings"] = {
      ["display_quotes"] = false
    }
  }

  if template then
    attrs["template"] = template
  end

  --- Return the string to log for the given parameters.
  --- They will be applied on the template.
  --- @param message string
  --- @param level string level name
  --- @param logger string name of the logger
  --- @return string
  function attrs:format(message, level, logger)
    local out = self.template
    local time = os.date(self.time_format)
    out = tokenReplace("time", out, time)
    out = tokenReplace("message", out, message)
    out = tokenReplace("logger", out, logger)
    out = tokenReplace("level", out, level)
    out = tokenReplace("appctx", out, APPCONTEXT)
    return out
  end

  --- Return the string to log to inform that the previous message has been
  --- repeated ``repeated`` number of times.
  --- @param logger string name of the logger
  --- @param repeated number
  --- @return string
  function attrs:formatDuplicate(logger, repeated)
    local out = self.template_duplicate
    local time = os.date(self.time_format)
    out = tokenReplace("time", out, time)
    out = tokenReplace("logger", out, logger)
    out = tokenReplace("appctx", out, APPCONTEXT)
    out = tokenReplace("nrepeat", out, repeated)
    return out
  end

  --- @param tmpl string template for displaying message, with tokens.
  function attrs:set_template(tmpl)
    self.template = tmpl
  end

  --- @param enable boolean true to enable blocking of repeated messages
  function attrs:set_blocks_duplicate(enable)
    self.blocks_duplicate = enable
  end

  --- @param round_value number
  function attrs:set_num_round(round_value)
    -- round_value(int):
    self.numbers.round = round_value
  end

  --- @param display_value boolean
  function attrs:set_str_display_quotes(display_value)
    -- display_value(bool):
    self.strings.display_quotes = display_value
  end

  --- @param display_value boolean
  function attrs:set_tbl_display_indexes(display_value)
    self.tables.display_indexes = display_value
  end

  --- @param display_value boolean
  function attrs:set_tbl_linebreaks(display_value)
    self.tables.linebreaks = display_value
  end

  --- @param length number int
  function attrs:set_tbl_max_length(length)
    self.tables.max_length = length
  end

  --- @param linebreak_treshold number int
  function attrs:set_tbl_linebreak_treshold(linebreak_treshold)
    self.tables.linebreak_treshold = linebreak_treshold
  end

  --- @param indent number int
  function attrs:set_tbl_indent(indent)
    self.tables.indent = indent
  end

  --- @param display_value boolean
  function attrs:set_tbl_display_functions(display_value)
    self.tables.display_functions = display_value
  end

  return attrs

end

--- Display logging messages using an instance of this class.
--- @param name string name of the logger to be displayed on every message
function Logger:new(name)

  local attrs = {
    name = name,
    formatter = Formatter:new(),
    --- table current log level being used
    _level = LEVELS.INFO,
    --- string last message logged
    __last = false,
    --- number of times the last message was repeated
    __lastnum = 0,

  }

  --- @param level string|nil see LEVELS keys for values available
  function attrs:setLevel(level)

    if level == nil then
      return
    end

    if level.weight == nil or level.name == nil then
      error("[setLevel] level argument passed doesn't seems to have the expected attributes")
    else
      self._level = level
    end

  end

  --- @param formatter Formatter instance of the Formatter class to use
  function attrs:setFormatter(formatter)

    if formatter == nil then
      return
    end
    self.formatter = formatter

  end

  --- @param level table level object as defined in LEVELS
  --- @param messages table list of object to display as message or a single object
  function attrs:_log(level, messages)

    if LEVEL_OVERRIDE then
      self._level = LEVEL_OVERRIDE
    end

    if level.weight < self._level.weight then
      return
    end
    -- avoid string concat in loops using a table buffer
    local messagebuf = {}
    -- make sure messages is always a table to iterate later
    if (type(messages)~="table") then
      messages = {messages}
    end

    for _, mvalue in ipairs(messages) do
      messagebuf[#messagebuf + 1] = stringify(mvalue, nil, self.formatter)
    end
    messagebuf = tableconcat(messagebuf)

    messagebuf = self.formatter:format(messagebuf, level.name, self.name)

    self:_print(messagebuf)

  end

  --- Call the print function but before check if the message is repeated
  --- to avoid flooding. (if enable)
  function attrs:_print(message)

    -- we dont need all the later stuff if settings disable it
    if self.formatter.blocks_duplicate == false then
      print(message)
      return
    end

    -- check if the new message is actually repeated
    if message == self.__last then
      self.__lastnum = self.__lastnum + 1
      return -- don't print

    else
      -- if the previous message was repeated, tell it to the user
      if self.__lastnum > 0 then
        print(self.formatter:formatDuplicate(self.name, self.__lastnum))
      end
      -- and then reset to the new message
      self.__last = message
      self.__lastnum = 0

      print(message)

    end

  end

  function attrs:debug(...)
    self:_log(LEVELS.DEBUG, { ... })
  end

  function attrs:info(...)
    self:_log(LEVELS.INFO, { ... })
  end

  function attrs:warning(...)
    self:_log(LEVELS.WARNING, { ... })
  end

  function attrs:error(...)
    self:_log(LEVELS.ERROR,{ ... })
  end

  return attrs

end

-------------------------------------------------------------------------------
-- PUBLIC FUNCTIONS


--- Return the logger for the given name.
--- If no instance is existing, create a new one.
--- @param name string name of the logger to create/retrieve
--- @param force_new boolean if True, force the creation of a new instance even if its already exists
--- @return Logger logger class instance
function _M_.getLogger(name, force_new)

  local logger_instance
  local logger_index

  for index, lllogger in ipairs(__loggers) do
    if lllogger.name == name then
      logger_instance = lllogger
      logger_index = index
    end
  end

  if not logger_instance then
    logger_instance = Logger:new(name)
    table.insert(__loggers, logger_instance)
  elseif force_new then
    logger_instance = Logger:new(name)
    __loggers[logger_index] = logger_instance
  end

  return logger_instance

end

--- Set the logging LEVEL to multiple logger starting with the given name.
--- @param name string  start of the name of the logger
--- @param level table table in LEVELS
function _M_.propagateLoggerLevel(name, level)

  for _, lllogger in pairs(__loggers) do
    if string.match(lllogger.name, ("^%s"):format(name)) then
      lllogger:setLevel(level)
    end
  end

end

_M_.__loggers = __loggers
_M_.LEVELS = LEVELS
_M_.DEBUG = LEVELS.DEBUG
_M_.INFO = LEVELS.INFO
_M_.WARNING = LEVELS.WARNING
_M_.ERROR = LEVELS.ERROR
_M_.Logger = Logger
_M_.Formatter = Formatter

return _M_