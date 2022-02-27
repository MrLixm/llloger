# API

[![previous](https://img.shields.io/badge/index-◀_previous_page-fcb434?labelColor=4f4f4f)](INDEX.md)
[![root](https://img.shields.io/badge/back_to_root-536362?)](../README.md)
[![next](https://img.shields.io/badge/▶_next_page-developer-4f4f4f?labelColor=fcb434)](DEVELOPER.md)

Module import :

```lua
local logging = require("lllogger")
```

# ![module](https://img.shields.io/badge/module-5663B3) logging

## ![method](https://img.shields.io/badge/method-4f4f4f) logging:get_logger

Return the logger for the given name.
Create a new instance if not already existing else return the existing instance.

```
Args :
    name(str): 
        name of the logger to create/get.

Returns:
    Logger:
        logger class instance
``` 

## ![method](https://img.shields.io/badge/method-4f4f4f) logging:list_levels

```
Returns:
    table[num=str]:
        {"debug level name", ...}
```

# ![class](https://img.shields.io/badge/class-6F5ADC) Logger

The Logger class available public methods.

## ![method](https://img.shields.io/badge/method-4f4f4f) Logger:set_level

```
Note:
    Does nothing if the level is not valid.

Args :
    level(str or nil): 
        name of the log level to set as current.
        See get_levels() table's keys for possible values.

``` 

## ![method](https://img.shields.io/badge/method-4f4f4f) Logger:debug
## ![method](https://img.shields.io/badge/method-4f4f4f) Logger:info
## ![method](https://img.shields.io/badge/method-4f4f4f) Logger:warning
## ![method](https://img.shields.io/badge/method-4f4f4f) Logger:error

Log a message with the corresponding log level.

```
Args :
    ...(any): 
        List of arguments combined to a single string for display.

``` 

## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) Logger.formatting

Return the current StrFmtSettings instance being used.
This allows to configure how lua objets are converted to string for display.
See [StrFmtSettings](#classhttpsimgshieldsiobadgeclass-6f5adc-strfmtsettings).


```
StrFmtSettings:
    An StrFmtSettings class instance with default or modified settings.
``` 


## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) Logger.name

Return name of the current logger instance. 

```
str:
``` 

## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) Logger.ctx

A string representing the last context from where the logger was called from.
You should only set this.

It is reset each time a message in log, so the goal is to set it before logging
a message.

You also need to have `Logger.formatting.display_context` set to true to have
it displayed in the final message.

```
str:
``` 


# ![class](https://img.shields.io/badge/class-6F5ADC) StrFmtSettings

Modify StrFmtSettings settings you can use it as table and modify its key as usual
or use the pre-build methods. 

See the default value to see what type is expecte for the argument.

## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) StrFmtSettings.display_time 
> `default=true`
> 
> True to display the current time at beginning of the message. Formatted as hour:min:seconds.

## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) StrFmtSettings.display_context 
> `default=true`
> 
> True to display the line from where the logger was called from.

## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) StrFmtSettings.blocks_duplicate 
> `default=true`
> 
> True to not display duplicated message and replace them with a message that
> specify how much time it was repeated.

## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) StrFmtSettings.numbers.round 
> `default=3`
> 
> Number of decimals to round numbers to.

## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) StrFmtSettings.tables.indent 
> `default=4`
> 
> Number of whitespace as indents used to display tables

## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) StrFmtSettings.tables.length_max 
> `default=50`
> 
> Maximum length (#table) of the tabel before it being displayed as "one-line"
> (with no line-breaks)

## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) StrFmtSettings.tables.linebreaks 
> `default=true`
> 
> If the table length is smaller than `tables.length_max`, use a line-break 
> after each key/value pair being displayed.

## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) StrFmtSettings.tables.display_indexes 
> `default=false`
> 
> If true, numerical tables have their key also being displayed like `{1:..., 2:...}`.

## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) StrFmtSettings.tables.display_functions 
> `default=true`
> 
> If true, values storing a function in the table are displayed.

## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) StrFmtSettings.strings.display_quotes 
> `default=false`
> 
> If true, every string is wrap with the `""` around. 


## ![method](https://img.shields.io/badge/method-4f4f4f) StrFmtSettings:set_display_time
## ![method](https://img.shields.io/badge/method-4f4f4f) StrFmtSettings:set_display_context
## ![method](https://img.shields.io/badge/method-4f4f4f) StrFmtSettings:set_blocks_duplicate
## ![method](https://img.shields.io/badge/method-4f4f4f) StrFmtSettings:set_num_round
## ![method](https://img.shields.io/badge/method-4f4f4f) StrFmtSettings:set_tbl_indent
## ![method](https://img.shields.io/badge/method-4f4f4f) StrFmtSettings:set_tbl_length_max
## ![method](https://img.shields.io/badge/method-4f4f4f) StrFmtSettings:set_tbl_linebreaks
## ![method](https://img.shields.io/badge/method-4f4f4f) StrFmtSettings:set_tbl_display_indexes
## ![method](https://img.shields.io/badge/method-4f4f4f) StrFmtSettings:set_tbl_display_functions
## ![method](https://img.shields.io/badge/method-4f4f4f) StrFmtSettings:set_str_display_quotes



---
[![previous](https://img.shields.io/badge/index-◀_previous_page-fcb434?labelColor=4f4f4f)](INDEX.md)
[![root](https://img.shields.io/badge/back_to_root-536362?)](../README.md)
[![next](https://img.shields.io/badge/▶_next_page-developer-4f4f4f?labelColor=fcb434)](DEVELOPER.md)
