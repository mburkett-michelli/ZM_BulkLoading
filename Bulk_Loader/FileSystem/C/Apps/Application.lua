--[[
*******************************************************************************

Filename:      Application.lua
Version:       1.0.2.0
Firmware:      2.3.0.0 or Higher
Date:          2016-07-01
Customer:      
Description:
    This is a Fill/Discharge batching application that shows a bar graph on the Segment display

*******************************************************************************
]]

awtxReq = {}   --create the awtxReq namespace

awtx.display.writeLine("bat fd",3000)

require("awtxReqConstants")
require("awtxReqVariables")


--Global Memory Sentinel ... Define this in your app to a different value to clear
-- the Variable table out.
MEMORYSENTINEL = "A5_120001072016Q2"         -- APP_Time_Day_Month_Year 
MemorySentinel = awtxReq.variables.SavedVariable('MemorySentinel', "0", true)
-- if the memory sentinel has changed clear out the variable tables.
if MemorySentinel.value ~= MEMORYSENTINEL then
    -- Clears everything
    awtx.variables.clearTable()
    MemorySentinel.value = MEMORYSENTINEL
end

system = awtx.hardware.getSystem(1) -- Used to identify current hardware type.
config = awtx.weight.getConfig(1)   -- Used to get current system configuration information.
wt = awtx.weight.getCurrent(1)      -- Used to hold current scale snapshot information.

--[[
Description:
  This function registers the setpoint function that is called when the setpoint changes states
  
Parameters:
  None
  
Returns:
  None
]]--
function onStart()
  awtx.setpoint.registerOutputEvent(outputFill,fillFunction)
  awtx.setpoint.registerOutputEvent(outputDischarge,dischargeFunction)
end

saveThruPowerDown = {} -- Table that holds fillTarget, emptyTarget and name through power down
saveThruPowerDown.fill1 = awtxReq.variables.SavedVariable('fill1',0, true) -- Sets target weight index in the table
saveThruPowerDown.name1 = awtxReq.variables.SavedVariable('name1',"",true) -- Sets name index in the table
saveThruPowerDown.discharge1 = awtxReq.variables.SavedVariable('discharge1',0,true)
saveThruPowerDown.amtfill = awtxReq.variables.SavedVariable('amtfill',0,true)
saveThruPowerDown.targfill = awtxReq.variables.SavedVariable('targfill',0,true)
saveThruPowerDown.runtotal = awtxReq.variables.SavedVariable('runtotal',0,true)
saveThruPowerDown.draftidx = awtxReq.variables.SavedVariable('draftidx',0,true)
fill1 = saveThruPowerDown.fill1.value
discharge1 = saveThruPowerDown.discharge1.value
actual1 = 0 
amtfill = saveThruPowerDown.amtfill.value
targfill = saveThruPowerDown.targfill.value
heavywt = 0
lightwt = 0
runtotal = 0
draftidx = 0
NetWt = 0

date = os.date("%m/%d/%Y") -- Gets todays date from the system
time = os.date("%I:%M") -- Gets the current time from the system
outputFill = 1 -- This is the output that gets turned on and off based on if the scale has met the target weight or not
outputDischarge = 2 -- This is the output that gets turned on and off based on if the scale is above or below the empty weight
filling = false -- This variable is used to determine if we want the system to be filling or not
discharging = false -- This variable is used to determine if we want the system to be discharging or not
doPrint = true -- This variable is used to prevent the system from printing when the stop key is pressed

controls = {} -- Creates the controls table

--[[
Description:
  This function creates all the controls that are used in Screen0
  
Parameters:
  None
  
Returns:
  None
]]--
function createControls()
  controls.graph = awtx.graphics.graph.new('graph', 0, 0, 0, 1000)
  controls.graph:setLocation(0, 12) -- Sets the location of the bar graph in the dot matrix
  controls.graph:reSize(35, 4) -- Sets the size of the bar graph in the dot matrix
  controls.graph:setLimits(0,fill1) -- Sets the max value of the bar graph to the target weight of setpoint 1
  controls.graph:setBasis(1)
  controls.graph:setVisible(true)
  
  controls.scale = awtx.display.getScaleControl()
  controls.setpoints = awtx.display.getSetpointControl()
end
createControls() -- Creates controls on start up
local screen0 = nil

varUnitStr= wt.unitsStr      -- Get the units String
varCurrentGross=wt.gross     -- Get current Gross
varCurrentDiv=wt.curDivision -- Get the division size 

--[[
Description:
  This function opens or shows Screen0
  
Parameters:
  None
  
Returns:
  None
]]--
function enterScreen0() 
  awtx.display.setMode(awtx.display.MODE_USER ) -- Sets display to user mode
  screen0:show()
end

--[[
Description:
  This function creates a new screen called screen0
  
Parameters:
  None
  
Returns:
  None
]]--
function createScreen0()
  -- Create the screen
  screen0 = awtx.graphics.screens.new('screen0')
  screen0:addControl(controls.graph) -- Add graph control to the screen
  screen0:addControl(controls.scale) -- Add scale control the the screen
  screen0:addControl(controls.setpoints) -- Add setpoint control to the screen
  
end
createScreen0() -- creates Screen0 on start up

--[[
Description:
  This function will grab the time and date and set the print tokens to print
  
Parameters:
  None
  
Returns:
  None
]]--
function setPrintTokensFill()
    date = os.date("%m/%d/%Y") -- Gets todays date from the system
    time = os.date("%I:%M") -- Gets the current time from the system
    awtx.fmtPrint.varSet(1,time,"Time",awtx.fmtPrint.TYPE_STRING)
    awtx.fmtPrint.varSet(2,date,"Date",awtx.fmtPrint.TYPE_STRING)
    awtx.fmtPrint.varSet(3,saveThruPowerDown.fill1.value,"Target 1",awtx.fmtPrint.TYPE_FLOAT)
    awtx.fmtPrint.varSet(4,actual1,"Actual 1",awtx.fmtPrint.TYPE_FLOAT)
    awtx.fmtPrint.varSet(10,heavywt,"Heavy Wt",awtx.fmtPrint.TYPE_FLOAT)
    awtx.fmtPrint.varSet(11,targfill,"Batch Wt",awtx.fmtPrint.TYPE_FLOAT)
    
    awtx.fmtPrint.varSet(5,saveThruPowerDown.name1.value,"Name",awtx.fmtPrint.TYPE_STRING)
end

--[[
Description:
  This function will grab the time and date and set the print tokens to print
  
Parameters:
  None
  
Returns:
  None
]]--
function setPrintTokensDischarge()
    NetWt = heavywt - lightwt
    date = os.date("%m/%d/%Y") -- Gets todays date from the system
    time = os.date("%I:%M") -- Gets the current time from the system
    awtx.fmtPrint.varSet(6,time,"Time",awtx.fmtPrint.TYPE_STRING)
    awtx.fmtPrint.varSet(7,date,"Date",awtx.fmtPrint.TYPE_STRING)
    awtx.fmtPrint.varSet(8,math.abs(saveThruPowerDown.discharge1.value),"Target 1",awtx.fmtPrint.TYPE_FLOAT)
    awtx.fmtPrint.varSet(9,math.abs(actual2),"Actual 2",awtx.fmtPrint.TYPE_FLOAT)
    awtx.fmtPrint.varSet(12,math.abs(lightwt),"Light Wt",awtx.fmtPrint.TYPE_FLOAT)
    awtx.fmtPrint.varSet(13,NetWt,"Draft Wt",awtx.fmtPrint.TYPE_FLOAT)
    awtx.fmtPrint.varSet(14,runtotal,"Dumped ",awtx.fmtPrint.TYPE_FLOAT)
    awtx.fmtPrint.varSet(15,draftidx,"D Index",awtx.fmtPrint.TYPE_FLOAT)
    awtx.fmtPrint.varSet(5,saveThruPowerDown.name1.value,"Name",awtx.fmtPrint.TYPE_STRING)
end

--[[
Description:
  This function will prompt the user for the target weight of ingredients one
  when the target key is pressed down.
  
Parameters:
  None
  
Returns:
  None
]]--
function awtx.keypad.KEY_TARGET_DOWN()
  wt = awtx.weight.getCurrent(1)
  awtx.display.setMode(awtx.display.MODE_USER ) -- Sets display to user mode
  
  tmpTargFill = saveThruPowerDown.targfill.value
  tmpTargFill, isEnterKey = awtx.keypad.enterWeightWithUnits(tmpTargFill, 0, 999999, varUnitStr, config.displaySeparator, -1, 1, "Enter", "BatchWt" )
  
  if (isEnterKey) then
    saveThruPowerDown.targfill.value = tmpTargFill -- saves the new entered value 
    targfill = saveThruPowerDown.targfill.value -- saves the new entered value to the fill1 variable to be used my the setpoint configuration
    actual1 = 0
    saveThruPowerDown.amtfill.value = 0
    amtfill = saveThruPowerDown.amtfill.value    
    heavywt = 0
    lightwt = 0
  else
    awtx.display.writeLine("Abort",500)
    awtx.display.setMode(awtx.display.MODE_SCALE) -- sets display to scale mode
    return
  end
  
  
  tmpFill1 = saveThruPowerDown.fill1.value -- sets the last entered target weight value to a temporary variable
  
  tmpFill1, isEnterKey = awtx.keypad.enterWeightWithUnits(tmpFill1, 0, wt.curCapacity, varUnitStr, config.displaySeparator, -1, 1, "Enter", "Target")
  --tmpFill1, isEnterKey = awtx.keypad.enterFloat(tmpFill1, 0, wt.curCapacity, -1, "Enter", "Target") -- prompts user for target weight value
  
  -- tmpFill1=math.floor(tmpFill1 + 0.5)

  if (isEnterKey) then
    saveThruPowerDown.fill1.value = tmpFill1 -- saves the new entered value 
    fill1 = saveThruPowerDown.fill1.value -- saves the new entered value to the fill1 variable to be used my the setpoint configuration
    actual1 = 0
  else
    awtx.display.writeLine("Abort",500)
    awtx.display.setMode(awtx.display.MODE_SCALE) -- sets display to scale mode
    return
  end
  
  tmpDischarge1 = saveThruPowerDown.discharge1.value   ---*-1
  tmpDischarge1, isEnterKey1 = awtx.keypad.enterWeightWithUnits(tmpDischarge1, 0, wt.curCapacity, varUnitStr, config.displaySeparator, -1, 1, "Enter", "Empty")
  --tmpDischarge1, isEnterKey1 = awtx.keypad.enterFloat(tmpDischarge1, wt.curCapacity * -1, wt.curCapacity, -1, "Enter", "Empty") -- prompts user for empty weight value
  if (isEnterKey1) then
    saveThruPowerDown.discharge1.value = tmpDischarge1
    discharge1 = saveThruPowerDown.discharge1.value
  else 
    awtx.display.writeLine("Abort",500)
    awtx.display.setMode(awtx.display.MODE_SCALE)
    return
  end
  
  
  
  awtx.display.setMode(awtx.display.MODE_SCALE)
end


function StartDischarge()
  if (discharging == true) then
    wt = awtx.weight.getCurrent(1)
    if wt.gross >= math.abs(discharge1) then 
      awtx.display.setMode(awtx.display.MODE_SCALE)
      doPrint = true
      discharging = true
      --awtx.weight.requestTare(1)
      awtx.weight.graphEnable(1,2) -- Enables the bar graph
      awtx.weight.setBar(1,1,discharge1,0) -- sets the bar graphs min value
      awtx.os.sleep(1000)
      awtx.setpoint.outputSet(outputDischarge)
    else
      filling = false
      discharging = false
      doPrint = false
      awtx.weight.graphEnable(1,0) -- disables the graph
      awtx.display.setMode(awtx.display.MODE_SCALE)
      awtx.setpoint.outputClr(outputFill)
      awtx.setpoint.outputClr(outputDischarge)
      awtx.display.setMode(awtx.display.MODE_USER)
      --awtx.display.writeLine("Press",500)
      --awtx.display.writeLine("Start",500)
      --awtx.display.writeLine("To",500)
      --awtx.display.writeLine("Fill",500)
      --awtx.display.setMode(awtx.display.MODE_SCALE)
    end
  --else
    --awtx.weight.requestTare(1)
  end
end


function StartFilling()
  wt = awtx.weight.getCurrent(1)
  varCurrentGross=wt.gross
  lightwt = wt.gross
  
  if varCurrentGross<0 then
     awtx.display.writeLine("Cant", 500)
     awtx.display.setMode(awtx.display.MODE_SCALE)
  else
    if (fill1 >= 0 and wt.gross <= math.abs(discharge1)) then
      if (filling == false and discharging == false) then
        awtx.display.setMode(awtx.display.MODE_SCALE)
        doPrint = true
        filling = true
        
        --awtx.weight.requestTare(1)
        awtx.weight.graphEnable(1,2) -- Enables the bar graph
        awtx.weight.setBar(1,1,0,fill1) -- sets the bar graphs max value
        awtx.display.writeLine("FILL",500)
        awtx.display.setMode(awtx.display.MODE_SCALE)
        awtx.setpoint.outputSet(outputFill)
      else
        awtx.display.setMode(awtx.display.MODE_USER)
        awtx.display.writeLine("Press",500)
        awtx.display.writeLine("Tare",500)
        awtx.display.writeLine("To",500)
        awtx.display.writeLine("Discharge",500)
        awtx.display.setMode(awtx.display.MODE_SCALE)
      end
    elseif wt.gross >= math.abs(discharge1) then
      awtx.display.setMode(awtx.display.MODE_USER)
      awtx.display.writeLine("Tare To Discharge",1000)
      awtx.display.setMode(awtx.display.MODE_SCALE)
    else
      awtx.display.setMode(awtx.display.MODE_USER)
      awtx.display.writeLine("Invalid",500)
      awtx.display.writeLine("Target",500)
      awtx.display.setMode(awtx.display.MODE_SCALE)
    end
  end
end

--[[
Description:
  This function will get the current weight of the scale and turn setpoint 2 on
  once setpoint 1 has gone off.
  
Parameters:
  param[in]   number - The setpoint output that is being turned on/off
  param[in]   state - The current state of the setpoint either on or off (true/false)
  
Returns:
  None
]]--
function fillFunction(number,state)
  if (state == false and filling == true) then
    tmpStable, actual1 = waitForStability()
    heavywt = actual1
    setPrintTokensFill()
    --awtx.printer.PrintFmt(1)
    filling = false
    discharging = true  
    awtx.display.writeLine("DCHARGE",500)
    --awtx.display.writeLine("Done",2000)
    awtx.display.setMode(awtx.display.MODE_SCALE)
    StartDischarge()
  end
end

--[[
Description:
  This function will get the current weight of the scale and display the
  appropriate values to serial port 1 once setpoint 2 has gone off.
  
Parameters:
  param[in]   number - The setpoint output that is being turned on/off
  param[in]   state - The current state of the setpoint either on or off
  
Returns:
  None
]]--
function dischargeFunction (number,state)
  if (state == false and discharging == true) then
     
     tmpStable, actual2 = waitForStability()
     lightwt = actual2
     NetWt = heavywt - lightwt
     draftidx = draftidx + 1
     runtotal = runtotal + NetWt     
     
     setPrintTokensDischarge()
     awtx.printer.PrintFmt(6)
     awtx.display.writeLine("PRINT",500)
     --awtx.display.writeLine("Done",2000)
     awtx.display.setMode(awtx.display.MODE_SCALE)
     awtx.weight.setActiveValue(0)
     discharging = false
     lastdraft = targfill - runtotal
     
     if (lastdraft < 0) or (lastdraft==0) then
       
       awtx.printer.PrintFmt(7)
       awtx.weight.graphEnable(1,0) -- disables the graph
       awtx.display.setMode(awtx.display.MODE_SCALE)
       awtx.setpoint.outputClr(outputFill)
       awtx.setpoint.outputClr(outputDischarge)
       awtx.display.writeLine("BATCH",2000)
       awtx.display.writeLine("FINISH",2000)
       awtx.display.setMode(awtx.display.MODE_SCALE)
       filling = false
       discharging = false
       doPrint = false
       
     elseif (lastdraft < fill1) then
       
       fill1 = lastdraft
       StartFilling()
       
     else
      
       StartFilling()
      
     end
          
  end
end




--[[
Description:
  This function will look to make sure that the target weights have been entered
  and then it will turn on setpoint 1 if they have.
  
Parameters:
  None
  
Returns:
  None
]]--
function awtx.keypad.KEY_START_DOWN()
  
  tmpName1 = saveThruPowerDown.name1.value -- sets the last entered name to a temporary variable
  tmpName1, isEnterKey = awtx.keypad.enterString(tmpName1,4,-1,"Name","Enter") -- prompts the user for a name
  
  if isEnterKey then
    saveThruPowerDown.name1.value = tmpName1 -- saves the new entered name
  else
    awtx.display.writeLine("Abort",500)
    awtx.display.setMode(awtx.display.MODE_SCALE)
    return
  end
  
  lightwt = wt.gross
  heavywt = 0
  runtotal = 0
  draftidx = 0
  fill1 = saveThruPowerDown.fill1.value
  awtx.printer.PrintFmt(4)
  StartFilling()
  
end

--[[
Description:
  This function will turn the setpoints off when the stop key is pressed down
  
Parameters:
  None
  
Returns:
  None
]]--
function awtx.keypad.KEY_STOP_DOWN()
  filling = false
  discharging = false
  doPrint = false
  awtx.weight.graphEnable(1,0) -- disables the graph
  awtx.display.setMode(awtx.display.MODE_SCALE)
  awtx.setpoint.outputClr(outputFill)
  awtx.setpoint.outputClr(outputDischarge)
  awtx.display.writeLine("BATCH",2000)
  awtx.display.writeLine("Abort",2000)
  awtx.display.setMode(awtx.display.MODE_SCALE)
end

--[[
Description:
  This function will zero the scale when the zero key is pressed
  
Parameters:
  None
  
Returns:
  None
]]--
function awtx.keypad.KEY_ZERO_DOWN()
  awtx.weight.requestZero()
end

--[[
Description:
  This function will print the current information on the scale when the print key is pressed
  
Parameters:
  None
  
Returns:
  None
]]--
function awtx.keypad.KEY_PRINT_DOWN()
  awtx.weight.getRefreshLastPrint(1)
  awtx.printer.PrintFmt(2)
end


--[[
Description:
  This function will tare the current weight when the tare key is pressed
  
Parameters:
  None
  
Returns:
  None
]]--
function awtx.keypad.KEY_TARE_DOWN()
  StartDischarge()
end

--[[
Description:
  This function will cycle through the displayable values when the select key is pressed
  
Parameters:
  None
  
Returns:
  None
]]--
function awtx.keypad.KEY_SELECT_DOWN()
  awtx.weight.cycleActiveValue()
end

MAX_LOOP = 100  --100 loops * 0.050 seconds per loop is 5 seconds then exit in waitForStability()

--[[
Description:
  This function waits for the scale to stabilize before getting the weight on the scale.
  And returns after 5 seconds, if motion never stops.
  
Parameters:
  None
  
Returns:
  None
]]--
function waitForStability()
local loop = 0
local tmpStable = true
    wt = awtx.weight.getCurrent(1)
    while wt.motion do        -- waits for a stable weight
        wt = awtx.weight.getCurrent(1)
        awtx.os.systemEvents(50)        -- pause this code for (50) milliseconds and exit function so system code can be checked and run, then return and continue this function
        loop = loop + 1
        if loop > MAX_LOOP then         -- weight has not stablized for 5 seconds so exit loop and return
            tmpStable = false
            break
        end
    end
    return tmpStable, wt.net
end

onStart()