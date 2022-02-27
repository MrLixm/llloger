--[[
VERSION = 18
llloger

A simple logging module based on Python one. Originaly made for use with
Foundry's Katana software, OpScript feature.
This is a module version.

Author: Liam Collod
Last-Modified: 27/02/2022

[LICENSE]
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

local LEVELS = {
      --[[
      Log levels available.
      ]]
      debug = {
        name = "  DEBUG",  -- name displayed in the console
        weight = 10
      },
      info = {
        name = "   INFO",
        weight = 20
      },
      warning = {
        name = "WARNING",
        weight = 30
      },
      error = {
        name = "  ERROR",
        weight = 40,
      }
}

-- list of instances of all loggers ever created
-- numerical table
local __loggers = {}

-------------------------------------------------------------------------------
-- functions/classes
local conkat
local table2string
local stringify
local round
local StrFmtSettings = {}
local Logger = {}

conkat = function (...)
  --[[
  The loop-safe string concatenation method.
  ]]
  local buf = {}
  for i=1, select("#",...) do
    buf[ #buf + 1 ] = tostring(select(i,...))
  end
  return tableconcat(buf)
end

stringify = function(source, index, settings)
  --[[
  Convert the source to a readable string , based on it's type.

  Args:
    source(any): any type
    index(int): recursive level of stringify
    settings(StrFmtSettings or nil): configure how source is formatted
  ]]
  if not settings then
    settings = StrFmtSettings:new()
  end

  if not index then
    index = 0
  end


  if (type(source) == "table") then
    source = table2string(source, index, settings)

  elseif (type(source) == "number") then
    source = tostring(round(source, settings.numbers.round))

  elseif (type(source) == "string") and settings.strings.display_quotes == true then
    source = conkat("\"", source, "\"")

  elseif (type(source) == "string") then
    -- do nothing

  else
    source = tostring(source)

  end

  return source

end

table2string = function(tablevalue, index, settings)
    --[[
  Convert a table to human readable string.
  By default formatted on multiples lines for clarity. Specify tdtype=oneline
    to get no line breaks.
  If the key is a number, only the value is kept.
  If the key is something else, it is formatted to "stringify(key)=stringify(value),"
  If the table is too long (max_length), it is formatted as oneline

  Args:
    tablevalue(table): table to convert to string
    index(int): recursive level of conversions used for indents
    settings(StrFmtSettings or nil):
      Configure how table are displayed.

  Returns:
    str:

  ]]

  -- check if table is empty
  if next(tablevalue) == nil then
   return "{}"
  end

  -- if no index specified recursive level is 0 (first time)
  if not index then
    index = 0
  end

  local tsettings
  if settings and settings.tables then
    tsettings = settings.tables
  else
    tsettings = StrFmtSettings:new().tables
  end

  local linebreak_start = "\n"
  local linebreak = "\n"
  local inline_indent = stringrep(
      " ", index * tsettings.indent + tsettings.indent
  )
  local inline_indent_end = stringrep(
      " ", index * tsettings.indent
  )

  -- if the table is too long make it one line with no line break
  if #tablevalue > tsettings.length_max then
    linebreak = ""
    inline_indent = ""
    inline_indent_end = ""
  end
  -- if specifically asked for the table to be displayed as one line
  if tsettings.linebreaks == false then
    linebreak = ""
    linebreak_start = ""
    inline_indent = ""
    inline_indent_end = ""
  end

  -- to avoid string concatenation in loop using a table
  local outtable = {}
  outtable[#outtable + 1] = "{"
  outtable[#outtable + 1] = linebreak_start

  for k, v in pairs(tablevalue) do
    -- if table is build with number as keys, just display the value
    if (type(k) == "number") and tsettings.display_indexes == false then
      outtable[#outtable + 1] = inline_indent
      outtable[#outtable + 1] = stringify(v, index+1, settings)
      outtable[#outtable + 1] = ","
      outtable[#outtable + 1] = linebreak
    else

      if (type(v) == "function") and tsettings.display_functions == false then
        outtable[#outtable + 1] = ""
      else
        outtable[#outtable + 1] = inline_indent
        outtable[#outtable + 1] = stringify(k, index+1, settings)
        outtable[#outtable + 1] = "="
        outtable[#outtable + 1] = stringify(v, index+1, settings)
        outtable[#outtable + 1] = ","
        outtable[#outtable + 1] = linebreak
      end

    end
  end
  outtable[#outtable + 1] = inline_indent_end
  outtable[#outtable + 1] = "}"
  return tostring(tableconcat(outtable))

end

round = function(num, numDecimalPlaces)
  --[[
  Source: http://lua-users.org/wiki/SimpleRound
  Parameters:
    num(number): number to round
    numDecimalPlaces(number): number of decimal to keep
  Returns: number
  ]]
  return tonumber(
      stringformat(
          conkat("%.", (numDecimalPlaces or 0), "f"),
          num
      )
  )
end

function StrFmtSettings:new()
  --[[
  A base class that hold configuration settings for string formatting used
  by stringify() and table2string()
  ]]

  -- these are the default values
  local attrs = {
    ["display_context"] = true,
    ["blocks_duplicate"] = true,
    -- how much decimals should be kept for floating point numbers
    ["numbers"] = {
      ["round"] = 3
    },
    -- nil by default cause the table2string already have some defaults
    ["tables"] = {
      -- how much whitespaces is considered an indent
      ["indent"] = 4,
      -- max table size before displaying it as oneline to avoid flooding
      ["length_max"] = 50,
      -- true to display the table on multiples lines with indents
      ["linebreaks"] = true,
      ["display_indexes"] = false,
      ["display_functions"] = true
    },
    ["strings"] = {
      ["display_quotes"] = false
    }
  }

  function attrs:set_display_context(enable)
    -- enable(bool): true to display line from where the logger was called
    self.display_context = enable
  end

  function attrs:set_blocks_duplicate(enable)
    -- enable(bool): true to enable blocking of repeated messages
    self.blocks_duplicate = enable
  end

  function attrs:set_num_round(round_value)
    -- round_value(int):
    self.numbers.round = round_value
  end

  function attrs:set_str_display_quotes(display_value)
    -- display_value(bool):
    self.strings.display_quotes = display_value
  end

  function attrs:set_tbl_display_indexes(display_value)
    -- display_value(bool):
    self.tables.display_indexes = display_value
  end

  function attrs:set_tbl_linebreaks(display_value)
    -- display_value(bool):
    self.tables.linebreaks = display_value
  end

  function attrs:set_tbl_length_max(length_max)
    -- length_max(int):
    self.tables.length_max = length_max
  end

  function attrs:set_tbl_indent(indent)
    -- indent(int):
    self.tables.indent = indent
  end

  function attrs:set_tbl_display_functions(display_value)
    -- display_value(bool):
    self.tables.display_functions = display_value
  end

  return attrs

end

function Logger:new(name)
  --[[
  Display logging messages using an instance of this class.

  Args:
	  name(str): name of the logger to be displayed on every message

	Attributes:
	  name(str):
	  formatting(StrFmtSettings):
	  _level(table): current log level being used
	  __last(str or false): last message logged
	  __lastnum(num): number of times the last message was repeated
  ]]

  local attrs = {
    name = name,
    formatting = StrFmtSettings:new(),
    ctx = false,
    _level = LEVELS.debug,
    __last = false,
    __lastnum = 0,

  }

  function attrs:set_level(level)
    -- level(string or nil): see self.levels keys for value

    if level == nil then
      return
    end

    if LEVELS[level] ~= nil then
      self._level = LEVELS[level]
    end

  end

  function attrs:_log(level, messages, ctx)
    --[[
    Args:
      level(table): level object as defined in self.levels
      messages(table): list of object to display
      ctx(str or nil): from where the log function is executed.
        Only used for error level, else used
    ]]

    if level.weight < self._level.weight then
      return
    end
    -- avoid string conact in loops using a table buffer
    local outbuf = {}
    -- make sure messages is always a table to iterate later
    if (type(messages)~="table") then
      messages = {messages}
    end

    ctx = ctx or self.ctx

    outbuf[#outbuf + 1] = "[OpScript]["
    outbuf[#outbuf + 1] = level.name
    outbuf[#outbuf + 1] = "]["
    outbuf[#outbuf + 1] = self.name
    outbuf[#outbuf + 1] = "]"
    if (ctx or self.ctx) and self.formatting.display_context == true then
      outbuf[#outbuf + 1] = "["
      outbuf[#outbuf + 1] = stringify(ctx, nil, self.formatting)
      outbuf[#outbuf + 1] = "] "
    end
    for _, mvalue in ipairs(messages) do
      outbuf[#outbuf + 1] = stringify(mvalue, nil, self.formatting)
      outbuf[#outbuf + 1] = " "
    end

    self.ctx = false

    -- concatenate the buffer to string and print
    self:_print(tableconcat(outbuf))

  end

  function attrs:_print(message)
    --[[
    Call the print function but before check if the message is repeated
    to avoid flooding. (if enable)
    ]]

    -- we dont need all the later stuff if settings disable it
    if self.formatting.blocks_duplicate == false then
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
        local buf = {}
        buf[#buf + 1] = "    ... ["
        buf[#buf + 1] = self.name
        buf[#buf + 1] = "] The last message was repeated <"
        buf[#buf + 1] = self.__lastnum
        buf[#buf + 1] = "> times..."
        print(tableconcat(buf))
      end
      -- and then reset to the new message
      self.__last = message
      self.__lastnum = 0

      print(message)

    end

  end

  function attrs:debug(...)
    self:_log(LEVELS.debug, { ... })
  end

  function attrs:info(...)
    self:_log(LEVELS.info, { ... })
  end

  function attrs:warning(...)
    self:_log(LEVELS.warning, { ... })
  end

  function attrs:error(...)
    self:_log(
      LEVELS.error,
      { ... },
      conkat(debug.getinfo(2).name, ":line", debug.getinfo(2).currentline)
    )
  end

  return attrs

end

-------------------------------------------------------------------------------
-- PUBLIC FUNCTIONS


local function get_levels(self)
  --[[
  Returns:
      table[num=str]:
          {"debug level name", ...}
  ]]
  local levels_name = {}
  for k, _ in pairs(LEVELS) do
    table.insert(levels_name, k)
  end
  return levels_name
end


local function get_logger(self, name)
  --[[
  Return the logger for the given name.
  Create a new instance if not already existing else return the existing instance.

  Returns:
    Logger:
        logger class instance
  ]]

  local logger_instance

  for _, lllogger in ipairs(__loggers) do
    if lllogger.name == name then
      logger_instance = lllogger
    end
  end

  if not logger_instance then
    logger_instance = Logger:new(name)
    table.insert(__loggers, logger_instance)
  end

  return logger_instance

end

return {
  get_logger = get_logger,
  list_levels = get_levels
}