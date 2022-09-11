# API

[![previous](https://img.shields.io/badge/index-◀_previous_page-fcb434?labelColor=4f4f4f)](INDEX.md)
[![root](https://img.shields.io/badge/back_to_root-536362?)](../README.md)
[![next](https://img.shields.io/badge/▶_next_page-developer-4f4f4f?labelColor=fcb434)](DEVELOPER.md)

Module import :

```lua
local logging = require("lllogger")
```

# ![module](https://img.shields.io/badge/module-5663B3) lllogger

## ![method](https://img.shields.io/badge/method-4f4f4f) lllogger.getLogger

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

## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) lllogger.LEVELS

Tables of all the levels available.

## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) lllogger.DEBUG

Table representing the DEBUG level.

## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) lllogger.INFO

Table representing the INFO level.

## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) lllogger.WARNING

Table representing the WARNING level.

## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) lllogger.ERROR

Table representing the ERROR level.


# ![class](https://img.shields.io/badge/class-6F5ADC) lllogger.Logger

The Logger class available public methods.

## ![method](https://img.shields.io/badge/method-4f4f4f) Logger:setLevel

```
Args :
    level(LEVELS or nil): 
        one of hte level defined in LEVELS
``` 

## ![method](https://img.shields.io/badge/method-4f4f4f) Logger:setFormatter

```
Args :
    formatter(Formatter or nil): instance of the Formatter class to use
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

## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) Logger.formatter

Return the current Formatter instance being used.
This allows to configure how lua objets are converted to string for display.
See [Formatter](#classhttpsimgshieldsiobadgeclass-6f5adc-Formatter).


```
Formatter:
    An Formatter class instance with default or modified settings.
``` 


## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) Logger.name

Return name of the current logger instance. 

```
str:
``` 


# ![class](https://img.shields.io/badge/class-6F5ADC) lllogger.Formatter

Modify Formatter settings you can use it as table and modify its key as usual
or use the pre-build methods. 

See the default value to see what type is expected for the argument.

## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) Formatter.blocks_duplicate 
> `default=true`
> 
> True to not display duplicated message and replace them with a message that
> specify how much time it was repeated.

## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) Formatter.numbers.round 
> `default=3`
> 
> Number of decimals to round numbers to.

## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) Formatter.tables.indent 
> `default=4`
> 
> Number of whitespace as indents used to display tables

## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) Formatter.tables.linebreak_treshold 
> `default=50`
> 
> Maximum length (#table) of the tabel before it being displayed as "one-line"
> (with no line-breaks)
> 
## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) Formatter.tables.max_length 
> `default=999`
> 
> maximum number of table element that can be displayed before being "cut"


## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) Formatter.tables.linebreaks 
> `default=true`
> 
> If the table length is smaller than `tables.length_max`, use a line-break 
> after each key/value pair being displayed.

## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) Formatter.tables.display_indexes 
> `default=false`
> 
> If true, numerical tables have their key also being displayed like `{1:..., 2:...}`.

## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) Formatter.tables.display_functions 
> `default=true`
> 
> If true, values storing a function in the table are displayed.

## ![attribute](https://img.shields.io/badge/attribute-4f4f4f) Formatter.strings.display_quotes 
> `default=false`
> 
> If true, every string is wrap with the `""` around. 

## ![method](https://img.shields.io/badge/method-4f4f4f)Formatter:format
## ![method](https://img.shields.io/badge/method-4f4f4f)Formatter:formatDuplicate
## ![method](https://img.shields.io/badge/method-4f4f4f)Formatter:set_template
## ![method](https://img.shields.io/badge/method-4f4f4f)Formatter:set_blocks_duplicate
## ![method](https://img.shields.io/badge/method-4f4f4f)Formatter:set_num_round
## ![method](https://img.shields.io/badge/method-4f4f4f)Formatter:set_str_display_quotes
## ![method](https://img.shields.io/badge/method-4f4f4f)Formatter:set_tbl_display_indexes
## ![method](https://img.shields.io/badge/method-4f4f4f)Formatter:set_tbl_linebreaks
## ![method](https://img.shields.io/badge/method-4f4f4f)Formatter:set_tbl_max_length
## ![method](https://img.shields.io/badge/method-4f4f4f)Formatter:set_tbl_linebreak_treshold
## ![method](https://img.shields.io/badge/method-4f4f4f)Formatter:set_tbl_indent
## ![method](https://img.shields.io/badge/method-4f4f4f)Formatter:set_tbl_display_functions


---
[![previous](https://img.shields.io/badge/index-◀_previous_page-fcb434?labelColor=4f4f4f)](INDEX.md)
[![root](https://img.shields.io/badge/back_to_root-536362?)](../README.md)
[![next](https://img.shields.io/badge/▶_next_page-developer-4f4f4f?labelColor=fcb434)](DEVELOPER.md)
