--[[
*******************************************************************************

Filename:     awtxReqConstants.lua
Version:      1.0.2.0
Date:         2017-02-01
Customer:     
Description:
This file provides some constant number definitions.

*******************************************************************************
History:
1.0.0.0 - Initial Release
1.0.1.0 - Removed Invalid Fonts
1.0.2.0 - Removed Invalid Scale Values
*******************************************************************************
]]


--
-- DISPLAY
-- 
awtx.display.MODE_SCALE             =   0
awtx.display.MODE_USER              =   1
awtx.display.MODE_MENU              =   2


--
-- DISPLAY
-- 
awtx.graphics.FONT_SYSTEM              =  0   --  23 pixels tall 10 pixels wide
awtx.graphics.FONT_LUCIDA_CON_8        =  3   --   8 pixels tall
awtx.graphics.FONT_LUCIDA_CON_10       =  4   --  10 pixels tall
awtx.graphics.FONT_LUCIDA_CON_12       =  5   --  12 pixels tall
awtx.graphics.FONT_LUCIDA_CON_16       =  6   --  16 pixels tall
awtx.graphics.FONT_LUCIDA_CON_20       =  7   --  20 pixels tall
awtx.graphics.FONT_LUCIDA_CON_40       =  8   --  40 pixels tall
awtx.graphics.FONT_SMALL_ICONS         =  9   --  16 pixels tall
awtx.graphics.FONT_DIS_TEXT            = 10   --  10 pixels tall
awtx.graphics.FONT_ICONS               = 11   --  Old Evo Font
awtx.graphics.FONT_TAHOMA_15           = 13   --  15 pixels tall
awtx.graphics.FONT_VERDANA_15          = 14   --  15 pixels tall
awtx.graphics.FONT_TAHOMA_22           = 19   --  22 pixels tall
awtx.graphics.FONT_VERDANA_22          = 20   --  22 pixels tall
awtx.graphics.FONT_ARIAL_80            = 25   --  80 pixels tall
awtx.graphics.FONT_COOPER_11           = 26   --  11 pixels tall
awtx.graphics.FONT_ARIAL_56            = 28   --  56 pixels tall
awtx.graphics.FONT_ARIAL_31            = 29   --  35 pixels tall
awtx.graphics.FONT_ARIAL_25            = 30   --  25 pixels tall
awtx.graphics.FONT_ARIAL_16            = 31   --  16 pixels tall
awtx.graphics.FONT_WTBASIC_1           = 32   --  ?? pixels tall
awtx.graphics.FONT_WTBASIC_2           = 33   --  ?? pixels tall
awtx.graphics.FONT_WTBASIC_3           = 34   --  ?? pixels tall
awtx.graphics.FONT_WTBASIC_4           = 35   --  ?? pixels tall
awtx.graphics.FONT_WTBASIC_5           = 36   --  ?? pixels tall
awtx.graphics.FONT_ARIAL_BOLD_12       = 37   --  12 pixels tall
awtx.graphics.FONT_ARIAL_BOLD_16       = 38   --  16 pixels tall
awtx.graphics.FONT_COURIER_NEW_BOLD_12 = 42   --  12 pixels tall
awtx.graphics.FONT_COURIER_NEW_BOLD_16 = 43   --  16 pixels tall
awtx.graphics.FONT_LARGE_WT_120        = 47   -- 120 pixels tall
awtx.graphics.FONT_LARGE_WT_160        = 48   -- 160 pixels tall

--
-- KEYPAD
-- 
awtx.keypad.RPN_MODE_DISABLED       = 0
awtx.keypad.RPN_MODE_ENABLED        = 1


--
-- TOKEN TYPES
--
awtx.fmtPrint.TYPE_UNDEFINED        = 0
awtx.fmtPrint.TYPE_WEIGHT           = 1
awtx.fmtPrint.TYPE_STRING           = 2
awtx.fmtPrint.TYPE_DATE             = 3
awtx.fmtPrint.TYPE_TIME             = 4
awtx.fmtPrint.TYPE_FLOAT            = 5
awtx.fmtPrint.TYPE_INTEGER          = 6
awtx.fmtPrint.TYPE_BOOLEAN          = 7
awtx.fmtPrint.TYPE_WEIGHT_VAR       = 8
awtx.fmtPrint.TYPE_STRING_VAR       = 9
awtx.fmtPrint.TYPE_DATE_VAR         = 10
awtx.fmtPrint.TYPE_TIME_VAR         = 11
awtx.fmtPrint.TYPE_FLOAT_VAR        = 12
awtx.fmtPrint.TYPE_INTEGER_VAR      = 13
awtx.fmtPrint.TYPE_BOOLEAN_VAR      = 14

-- 
-- PRINTER STATUS
--
awtx.printer.STATUS_OFFLINE           = 1
awtx.printer.STATUS_ONLINE            = 2
awtx.printer.STATUS_OK                = 3
awtx.printer.STATUS_NOT_OK            = 4
awtx.printer.STATUS_PAPER_LOW         = 5
awtx.printer.STATUS_NOT_PAPER_LOW     = 6
awtx.printer.STATUS_SELECTED          = 7
awtx.printer.STATUS_NOT_SELECTED      = 8
awtx.printer.STATUS_GENERAL_ERROR     = 9
awtx.printer.STATUS_NOT_GENERAL_ERROR = 10

awtx.printer.JOB_STATUS_DONE          = 1
awtx.printer.JOB_STATUS_ABORTED       = 2
awtx.printer.JOB_STATUS_CREATE_FAILED = 3

--
-- SCALE VALUES
--
awtx.weight.VAL_GROSS               =  0
awtx.weight.VAL_NET                 =  1
awtx.weight.VAL_TARE                =  2
awtx.weight.VAL_MIN                 =  3
awtx.weight.VAL_MAX                 =  4
awtx.weight.VAL_ROC                 =  5
awtx.weight.VAL_GTOTAL              =  6
awtx.weight.VAL_NTOTAL              =  7
awtx.weight.VAL_TTOTAL              =  8
awtx.weight.VAL_CTOTAL              =  9
awtx.weight.VAL_TRANS               = 10
awtx.weight.VAL_COUNT               = 11
awtx.weight.VAL_VAR                 = 12
awtx.weight.VAL_PCWT                = 13
awtx.weight.VAL_ADCCOUNTS           = 14
awtx.weight.VAL_STD_DEV             = 15
awtx.weight.VAL_TREND               = 16
awtx.weight.VAL_X_BAR_R             = 17
awtx.weight.VAL_PERCENT             = 18
awtx.weight.VAL_NET_MINUS_ANNUN     = 19
awtx.weight.VAL_BLANK               = 20
awtx.weight.VAL_INMOTION            = 21
awtx.weight.VAL_TARGET              = 22
awtx.weight.VAL_GTOT_PLUS_CURRENT   = 23
awtx.weight.VAL_GTOT_MINUS_CURRENT  = 24
awtx.weight.VAL_NTOT_PLUS_CURRENT   = 25
awtx.weight.VAL_NTOT_MINUS_CURRENT  = 26
awtx.weight.VAL_CTOT_PLUS_CURRENT   = 27
awtx.weight.VAL_CTOT_MINUS_CURRENT  = 28
awtx.weight.VAL_GAVERAGE            = 29
awtx.weight.VAL_NAVERAGE            = 30
awtx.weight.VAL_CAVERAGE            = 31
awtx.weight.VAL_NMIN                = 32
awtx.weight.VAL_NMAX                = 33
awtx.weight.VAL_FREEFALL_1          = 34
awtx.weight.VAL_GFUTURE_1           = 35
awtx.weight.VAL_NFUTURE_1           = 36
awtx.weight.VAL_FREEFALL_2          = 37
awtx.weight.VAL_GFUTURE_2           = 38
awtx.weight.VAL_NFUTURE_2           = 39
awtx.weight.VAL_PCWT_1000           = 40
awtx.weight.VAL_PERCENT_ACCURACY    = 41
awtx.weight.VAL_LAST_SAMPLE         = 42
awtx.weight.VAL_USER_MESSAGE        = 53