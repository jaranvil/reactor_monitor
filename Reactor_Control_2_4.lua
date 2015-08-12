--  BigReactor Control
--  by jaranvil aka jared314
--
--  feel free to use and/or modify this code
--
-----------------------------------------------
--Reactor Control - Version History
--
--  Version 2.4 - in development
--		to-dos
--			- Multible reactors
--			- Ender IO support
--      - dynamic monitor size
 --     - adjustable text scales 0.5 or 1
 --     - adjustable refresh rate
--
--  Version 2.3 - April 23/15
--    - First update in awhile 
--    - lots of minor fixes and improvments 
--    - New loading and setup search with automated peripheral search 
--    - Changes to the update methods

-----------------------------------------------

local version = 3.0
--is auto power enabled 
local auto_string = false 
--auto on value
local on = 0 
--auto off value
local off = 99 
--is auto control rods enabled 
local auto_rods = false 
--control rod auto value
local auto_rf = 0 
local mainPower = false

--peripherals
local reactor
local reactors = {}
local mon

--monitor size
local monX
local monY

local splitScreen = false

local settingsOffset = 14

local panel1Tool = 1
local panel2Tool = 2
local toolsTool = 1
local currentInfoPage = 0

-- new settings
-- need to be saved to config!
local refresh = 1
local energyStorageSetting = 1

-- button positions
local powerX = 0
local powerX2 = 0
local optionsX = 0
local optionsX2 = 0
local infoX = 0
local infoX2 = 0
local bufferBtn = {}
local enderBtn = {}
local thermalBtn = {}
local refreshUpBtn = {}
local refreshDownBtn = {}
local autoPowerBtn = {}
local offDownBtn = {}
local offUpBtn = {}
local onDownBtn = {}
local onUpBtn = {}
local mainPowerBtn = {}
local lastReactorBtn = {}
local nextReactorBtn = {}


term.clear()
-------------------FORMATTING-------------------------------
function clear()
  mon.setBackgroundColor(colors.black)
  mon.clear()
  mon.setCursorPos(1,1)
end

--display text on computer's terminal screen
function draw_text_term(x, y, text, text_color, bg_color)
  term.setTextColor(text_color)
  term.setBackgroundColor(bg_color)
  term.setCursorPos(x,y)
  write(text)
end

--display text text on monitor, "mon" peripheral
function draw_text(x, y, text, text_color, bg_color)
  mon.setBackgroundColor(bg_color)
  mon.setTextColor(text_color)
  mon.setCursorPos(x,y)
  mon.write(text)
end

--draw line on computer terminal
function draw_line(x, y, length, color)
    mon.setBackgroundColor(color)
    mon.setCursorPos(x,y)
    mon.write(string.rep(" ", length))
end

--draw line on computer terminal
function draw_line_term(x, y, length, color)
    term.setBackgroundColor(color)
    term.setCursorPos(x,y)
    term.write(string.rep(" ", length))
end

--create progress bar
--draws two overlapping lines
--background line of bg_color 
--main line of bar_color as a percentage of minVal/maxVal
function progress_bar(x, y, length, minVal, maxVal, bar_color, bg_color, text)
  draw_line(x, y, length, bg_color) --backgoround bar
  local barSize = math.floor((minVal/maxVal) * length) 
  draw_line(x, y, barSize, bar_color) --progress so far
  
  txtIndent = indent(length, text)
  if barSize >= txtIndent then
    draw_text(x + txtIndent, y, text, colors.black, bar_color)
  else
    draw_text(x + txtIndent, y, text, colors.white, bg_color)
  end
end

--same as above but on the computer terminal
function progress_bar_term(x, y, length, minVal, maxVal, bar_color, bg_color)
  draw_line_term(x, y, length, bg_color) --backgoround bar
  local barSize = math.floor((minVal/maxVal) * length) 
  draw_line_term(x, y, barSize, bar_color)  --progress so far
end

--create button on monitor
function button(x, y, length, text, txt_color, bg_color)
  draw_line(x, y, length, bg_color)
  draw_text((x+2), y, text, txt_color, bg_color)
end

--header and footer bars on monitor
function menu_bar()
  draw_line(1, 1, monX, colors.blue)
  draw_text(2, 1, "Power    Tools    Settings", colors.white, colors.blue)
  draw_line(1, monY, monX, colors.blue)
  draw_text((monX/2)-7, monY, "     Reactor Control", colors.white, colors.blue)
end

function menu_bar_controller()
  draw_line(1, 1, monX, colors.blue)
  draw_text((monX/2)-9, 1, "Connected Reactors", colors.white, colors.blue)
  
  -- Main Menu buttons
  local toolsY = monY-11
  if splitScreen then
    -- line between panels
    draw_line(1, toolsY, monX/2-1, colors.blue)
    draw_text(monX/2, toolsY, "|", colors.blue, colors.black)
    draw_line(monX/2+1, toolsY, monX/2, colors.blue)
    
    col = monX/2
    colCol = col/3
    powerX = indent(colCol, "power")
    infoX = colCol + indent(colCol, "info")
    optionsX = colCol*2 + indent(colCol, "options")
    powerX2 = col + indent(colCol, "power")
    infoX2 = col + colCol + indent(colCol, "info")
    optionsX2 = col + colCol*2 + indent(colCol, "options")
    
   

    -- Panel 1
    if panel1Tool == 1 then

      draw_line(1, toolsY, colCol, colors.white)
      draw_text(powerX,toolsY, "Power", colors.black, colors.white)
    else
      draw_text(powerX,toolsY, "Power", colors.white, colors.blue)
    end
    if panel1Tool == 2 then
      draw_line(colCol, toolsY, colCol, colors.white)
      draw_text(infoX,toolsY, "Info", colors.black, colors.white)
    else
      draw_text(infoX,toolsY, "Info", colors.white, colors.blue)
    end
    if panel1Tool == 3 then
      draw_line(colCol*2, toolsY, colCol, colors.white)
      draw_text(optionsX,toolsY, "Options", colors.black, colors.white)
    else
      draw_text(optionsX,toolsY, "Options", colors.white, colors.blue)
    end
    
    -- Panel 2
    if panel2Tool == 1 then
      draw_line(colCol*3+1, toolsY, colCol-1, colors.white)
      draw_text(powerX2,toolsY, "Power", colors.black, colors.white)
    else
      draw_text(powerX2,toolsY, "Power", colors.white, colors.blue)
    end
    if panel2Tool == 2 then
      draw_line(colCol*4, toolsY, colCol, colors.white)
      draw_text(infoX2,toolsY, "Info", colors.black, colors.white)
    else
      draw_text(infoX2,toolsY, "Info", colors.white, colors.blue)
    end
    if panel2Tool == 3 then
      draw_line(colCol*5, toolsY, colCol, colors.white)
      draw_text(optionsX2,toolsY, "Options", colors.black, colors.white)
    else
      draw_text(optionsX2,toolsY, "Options", colors.white, colors.blue)
    end

  else
    draw_line(1, toolsY, monX, colors.blue)
    col = monX/3
    powerX = indent(col, "power")
    infoX = col + indent(col, "info")
    optionsX = col*2 + indent(col, "options")
    if panel1Tool == 1 then
      draw_line(0, toolsY, col, colors.white)
      draw_text(powerX,toolsY, "Power", colors.blue, colors.white)
    else
      draw_text(powerX,toolsY, "Power", colors.white, colors.blue)
    end
    if panel1Tool == 2 then
      draw_line(col, toolsY, col, colors.white)
      draw_text(infoX,toolsY, "Info", colors.blue, colors.white)
    else
      draw_text(infoX,toolsY, "Info", colors.white, colors.blue)
    end
    if panel1Tool == 3 then
      draw_line(col*2, toolsY, col, colors.white)
      draw_text(optionsX,toolsY, "Options", colors.blue, colors.white)
    else
      draw_text(optionsX,toolsY, "Options", colors.white, colors.blue)
    end
  end
  
  
end

--dropdown menu for power options
function power_menu()
  draw_line(1, 2, 9, colors.gray)
  draw_line(1, 3, 9, colors.gray)
  draw_line(1, 4, 9, colors.gray)
  if active then 
    draw_text(2, 2, "ON", colors.lightGray, colors.gray)
    draw_text(2, 3, "OFF", colors.white, colors.gray)
  else
    draw_text(2, 2, "ON", colors.white, colors.gray)
    draw_text(2, 3, "OFF", colors.lightGray, colors.gray)
  end
  draw_text(2, 4, "Auto", colors.white, colors.gray)
end

--dropbox menu for tools
function tools_menu()
  draw_line(10, 2, 14, colors.gray)
  draw_line(10, 3, 14, colors.gray)
  draw_line(10, 4, 14, colors.gray)
  draw_line(10, 5, 14, colors.gray)
  draw_text(11, 2, "Control Rods", colors.white, colors.gray)
  draw_text(11, 3, "Efficiency", colors.white, colors.gray) 
  draw_text(11, 4, "Fuel", colors.white, colors.gray)
  draw_text(11, 5, "Waste", colors.white, colors.gray)
end

--dropdown menu for settings
function settings_menu()
  draw_line(12, 2, 18, colors.gray)
  draw_line(12, 3, 18, colors.gray)
  draw_text(13, 2, "Check for Updates", colors.white, colors.gray)
  draw_text(13, 3, "Reset peripherals", colors.white, colors.gray)
end

--basic popup screen with title bar and exit button 
function popup_screen(y, title, height)
  clear()
  menu_bar()

  draw_line(4, y, 22, colors.blue)
  draw_line(25, y, 1, colors.red)

  for counter = y+1, height+y do
    draw_line(4, counter, 22, colors.white)
  end

  draw_text(25, y, "X", colors.white, colors.red)
  draw_text(5, y, title, colors.white, colors.blue)
end


------------------------END FORMATTING--------------------------

-- Main Screen
function controller()
  -- resolution
  mon.setTextScale(1)
  
  -- main loop
  while true do
    clear()
    menu_bar_controller()
    terminal_screen()
    monX, monY = mon.getSize()
    if monX > 50 then
      splitScreen = true
    else
      splitScreen = false
    end
    
    -- 6 header colums 
    col = monX/6
    headerY = 3
   
    draw_text(indent(col, "reactor") , headerY, "Reactor", colors.white, colors.black)
    draw_text(col+indent(col, "Power") , headerY, "Power", colors.white, colors.black)
    draw_text((col*2)+indent(col, "rf/t"), headerY, "RF/t", colors.white, colors.black)
    draw_text((col*3)+indent(col, "temp"), headerY, "Temp", colors.white, colors.black)
    draw_text((col*4)+indent(col, "fuel"), headerY, "Fuel", colors.white, colors.black)
    draw_text((col*5)+indent(col, "rods"), headerY, "Rods", colors.white, colors.black)

    for x=0, 5 do
      draw_text(col*x, headerY, "|", colors.blue, colors.black)
    end

    -- divide reactor list and menu
    div = monY - 12
    mon.setBackgroundColor(colors.black)
    mon.setTextColor(colors.blue)
    mon.setCursorPos(1,div)
    mon.write(string.rep("=", monX))

    -- populate reactor list above div line
    listReactors(div)
   
    -- draw whatever menus are selected 
    if splitScreen then
      for i = div+1, monY-1 do
        draw_text(monX/2, i, "|", colors.blue, colors.black)
      end
      
      -- power select
      if panel1Tool == 1 then
        powerMenu(1, monX/2-1)
      end
      if panel2Tool == 1 then
        powerMenu(monX/2+1, monX/2-1)
      end
      
      -- info select
      if panel1Tool == 2 then
        infoMenu(1, monX/2-1)
      end
      if panel2Tool == 2 then
        infoMenu(monX/2+1, monX/2-1)
      end
      
      -- options select
      if panel1Tool == 3 then
        settingsMenu(1, monX/2-1)
      end
      if panel2Tool == 3 then
        settingsMenu(monX/2+1, monX/2-1)
      end
      
    else -- if not split screen
    
      if panel1Tool == 1 then
        powerMenu(1, monX)
      end
      if panel1Tool == 2 then
        infoMenu(1, monX)
      end
      if panel1Tool == 3 then
        settingsMenu(1, monX)
      end
    end
   
    sleep(refresh)
    
  end
end

function listReactors(div)

  

   -- list all reactors
    local lineCounter = headerY + 2 
    for i=1, #reactors do
      if lineCounter < div then
      
        if i == currentInfoPage then
          bgcolor = colors.lightGray
          draw_line(1, 2+(3*i), monX, colors.lightGray)
          draw_line(1, 3+(3*i), monX, colors.lightGray)
        else
          bgcolor = colors.black
        end
    
        -- line seperation reactors
        mon.setBackgroundColor(colors.black)
        mon.setTextColor(colors.blue)
        mon.setCursorPos(1,lineCounter-1)
        mon.write(string.rep("-", monX))
        
        -- add columns
        for x=0, 5 do
          draw_text(col*x, lineCounter, "|", colors.blue, bgcolor)
          draw_text(col*x, lineCounter+1, "|", colors.blue, bgcolor)
        end
  
        -- reactor number
        draw_text(2, lineCounter, string.format("%i", i), colors.white, bgcolor)
        
        -- power
        local active = reactors[i].getActive()
        if active then
          draw_text(col+1, lineCounter, "ONLINE", colors.lime, bgcolor)
        else
          draw_text(col+1, lineCounter, "OFFLINE", colors.red, bgcolor)
        end
       
        -- output
        rft = math.floor(reactors[i].getEnergyProducedLastTick())
        string = rft.." "
        draw_text((col*2)+1, lineCounter, string, colors.white, bgcolor)
        
        -- rod temp
        maxHeat = 2000
        heat = math.floor(reactors[i].getFuelTemperature())

        if heat < 500 then
          draw_text((col*3)+1, lineCounter, "R "..heat, colors.lime, bgcolor)
        else if heat < 1000 then
          draw_text((col*3)+1, lineCounter, "R "..heat, colors.yellow, bgcolor)
        else if heat < 1500 then  
          draw_text((col*3)+1, lineCounter, "R "..heat, colors.orange, bgcolor)
        else if heat < 2000 then
          draw_text((col*3)+1, lineCounter, "R "..heat, colors.red, bgcolor)
        else if heat >= 2000 then
          draw_text((col*3)+1, lineCounter, "R "..heat, colors.red, bgcolor)
        end
        end
        end
        end
        end
        
        -- casing temp
        heat = math.floor(reactors[i].getCasingTemperature())

        if heat < 500 then
          draw_text((col*3)+1, lineCounter+1, "C "..heat, colors.lime, bgcolor)
        else if heat < 1000 then
          draw_text((col*3)+1, lineCounter+1, "C "..heat, colors.yellow, bgcolor)
        else if heat < 1500 then  
          draw_text((col*3)+1, lineCounter+1, "C "..heat, colors.orange, bgcolor)
        else if heat < 2000 then
          draw_text((col*3)+1, lineCounter+1, "C "..heat, colors.red, bgcolor)
        else if heat >= 2000 then
          draw_text((col*3)+1, lineCounter+1, "C "..heat, colors.red, bgcolor)
        end
        end
        end
        end
        end
            
        -- fuel level
        local fuelMinVal = 0
        local fuelMaxVal = 0
        fuelMinVal = fuelMinVal + math.floor(reactors[i].getFuelAmount())
        fuelMaxVal = fuelMaxVal + math.floor(reactors[i].getFuelAmountMax())
  
        percent = math.floor((fuelMinVal/fuelMaxVal)*100)
        local string = percent.."%"
  
        if percent < 25 then
        progress_bar(col*4+1, lineCounter, col-1, percent, 100, colors.red, colors.gray, string)
        else if percent < 50 then
        progress_bar(col*4+1, lineCounter, col-1, percent, 100, colors.orange, colors.gray, string)
        else if percent < 75 then 
        progress_bar(col*4+1, lineCounter, col-1, percent, 100, colors.yellow, colors.gray, string)
        else if percent <= 100 then
        progress_bar(col*4+1, lineCounter, col-1, percent, 100, colors.lime, colors.gray, string)
        end
        end
        end
        end

        -- control rods
        percent = reactors[i].getControlRodLevel(0)
        progress_bar(col*5 + 1, lineCounter, col, percent, 100, colors.green, colors.gray, percent.."%")
        
        -- increase line counter for the next reactor
        lineCounter = lineCounter + 3
      end
    end
end

-- Draw the power screen 
function powerMenu(x, width)
  y = monY - 10

  -- Main Power Satus Label
  mainPowerBtn = {x+15, y+1}
  draw_text(x+1, y+1, "Main Power:", colors.yellow, colors.black)
  if mainPower then
    draw_line(x+15, y+1, 8, colors.lime)
    draw_text(x+15, y+1, " ONLINE", colors.black, colors.lime)
  else
    draw_line(x+15, y+1, 9, colors.red)
    draw_text(x+15, y+1, " OFFLINE", colors.white, colors.red)
  end
  
  -- total rf/t
  draw_text(x+1, y+2, "Output:", colors.yellow, colors.black)
  rft = 0
  for i=1, #reactors do
    rft = rft + math.floor(reactors[i].getEnergyProducedLastTick())
  end
  draw_text(x+15, y+2, rft.." RF/t", colors.white, colors.black)
  
  --storage
  draw_text(x+1, y+4, "Energy Storage:", colors.yellow, colors.black)
  energy_stored = 0
  for i=1, #reactors do
    energy_stored = energy_stored + reactors[i].getEnergyStored()
    --energy_stored_percent = math.floor((energy_stored/(10000000*#reactors))*100)
  end
  if energyStorageSetting == 1 then
    draw_text(x+1, y+5, "Reactor Buffers", colors.white, colors.black)
  else if energyStorageSetting == 2 then 
    draw_text(x+1, y+5, "EnderIO Capacitors", colors.white, colors.black)
  else if energyStorageSetting == 3 then 
    draw_text(x+1, y+5, "Thermal Expansion", colors.white, colors.black)
  end
  end
  end
  
  barX = x+1
  barLength = width-2
  
  minVal = energy_stored
  maxVal = 10000000*#reactors
  percent = math.floor((minVal/maxVal)*100)
  
  if percent < 25 then
  progress_bar(barX, y+6, barLength, minVal, maxVal, colors.red, colors.gray, percent.."%")
  else if percent < 50 then
  progress_bar(barX, y+6, barLength, minVal, maxVal, colors.orange, colors.gray, percent.."%")
  else if percent < 75 then 
  progress_bar(barX, y+6, barLength, minVal, maxVal, colors.yellow, colors.gray, percent.."%")
  else if percent <= 100 then
  progress_bar(barX, y+6, barLength, minVal, maxVal, colors.lime, colors.gray, percent.."%")
  end
  end
  end
  end
  
  -- auto power
  draw_text(x+1, y+8, "Auto Power:", colors.yellow, colors.black)
  
  auto = auto_string == "true"
      if auto then
        draw_text(x+13, y+8, "active", colors.lime, colors.black)
       -- if active then
         -- draw_text(x+13, y+6, ":", colors.yellow, colors.black)
         -- draw_text(13, 17, off.."% RF Stored", colors.white, colors.black)
         -- if energy_stored_percent >= off then
         --   reactor.setActive(false)
         --   call_homepage()

        --else
--          draw_text(2, 17, "Auto on:", colors.yellow, colors.black)
--          draw_text(13, 17, on.."% RF Stored", colors.white, colors.black)
--          if energy_stored_percent <= on then
--            reactor.setActive(true)
--            call_homepage()
--          end

      else
        draw_text(x+13, y+8, "Off", colors.white, colors.black)

      end
end

function infoMenu(x, width)
  y = monY - 10
  
  -- selection buttons
  lastReactorBtn = {x+4, y+1}
  nextReactorBtn = {x+(width-5), y+1}
  draw_text(lastReactorBtn[1], lastReactorBtn[2], "<<", colors.white, colors.gray)
  draw_text(nextReactorBtn[1], nextReactorBtn[2], ">>", colors.white, colors.gray)
  
  -- title
  if currentInfoPage == 0 then
    draw_text(x+indent(width, "All Reactors"), lastReactorBtn[2], "All Reactors", colors.yellow, colors.black)
  else
    draw_text(x+indent(width, "Reactor 1"), lastReactorBtn[2], "Reactor "..currentInfoPage, colors.yellow, colors.black)
  end
  
  -- fuel tempature
  maxHeat = 0
  heat = 0
  if currentInfoPage == 0 then
    for a=1, #reactors do
      heat = heat + math.floor(reactors[a].getFuelTemperature())
    end
    maxHeat = 2000*#reactors
  else 
    heat = math.floor(reactors[currentInfoPage].getFuelTemperature())
    maxHeat = 2000
  end
  percent = math.floor((heat/maxHeat)*100)
  
  draw_text(x+1, y+3, "Fuel Temp:", colors.yellow, colors.black)
  draw_text(x+20, y+3, heat.."/"..maxHeat, colors.white, colors.black)
  barX = x+1
  barY = y+4
  barLength = width - 2
  if percent < 25 then
  progress_bar(barX, barY, barLength, heat, maxHeat, colors.lime, colors.gray, " ")
  else if percent < 50 then
  progress_bar(barX, barY, barLength, heat, maxHeat, colors.yellow, colors.gray, " ")
  else if percent < 75 then 
  progress_bar(barX, barY, barLength, heat, maxHeat, colors.orange, colors.gray, " ")
  else 
  progress_bar(barX, barY, barLength, heat, maxHeat, colors.red, colors.gray, " ")
  end
  end
  end
  
  -- casing tempature
  maxHeat = 0
  heat = 0
  if currentInfoPage == 0 then
    for a=1, #reactors do
      heat = heat + math.floor(reactors[a].getCasingTemperature())
    end
    maxHeat = 2000*#reactors
  else 
    heat = math.floor(reactors[currentInfoPage].getCasingTemperature())
    maxHeat = 2000
  end
  percent = math.floor((heat/maxHeat)*100)
  
  draw_text(x+1, y+5, "Casing Temp:", colors.yellow, colors.black)
  draw_text(x+20, y+5, heat.."/"..maxHeat, colors.white, colors.black)
  barX = x+1
  barY = y+6
  barLength = width - 2
  if percent < 25 then
  progress_bar(barX, barY, barLength, heat, maxHeat, colors.lime, colors.gray, " ")
  else if percent < 50 then
  progress_bar(barX, barY, barLength, heat, maxHeat, colors.yellow, colors.gray, " ")
  else if percent < 75 then 
  progress_bar(barX, barY, barLength, heat, maxHeat, colors.orange, colors.gray, " ")
  else 
  progress_bar(barX, barY, barLength, heat, maxHeat, colors.red, colors.gray, " ")
  end
  end
  end
  
  -- fuel and energy info
  fuel_usage = 0
  rft = 0
  if currentInfoPage == 0 then
    for i=1, #reactors do
      fuel_usage = fuel_usage + reactors[i].getFuelConsumedLastTick()
      rft = rft + math.floor(reactors[i].getEnergyProducedLastTick())
    end
    rfmb = rft / fuel_usage
  else
    fuel_usage = reactors[currentInfoPage].getFuelConsumedLastTick()
    rft = math.floor(reactors[currentInfoPage].getEnergyProducedLastTick())
    rfmb = rft / fuel_usage
  end
  draw_text(x+1, y+7, "Fuel Consumption: ", colors.yellow, colors.black)
  draw_text(x+20, y+7, fuel_usage.." mB/t", colors.white, colors.black)
  draw_text(x+1, y+8, "Energy per mB: ", colors.yellow, colors.black)
  draw_text(x+20, y+8, rfmb.." RF/mB", colors.white, colors.black)
  draw_text(x+1, y+9, "RF/tick:", colors.yellow, colors.black)
  draw_text(x+20, y+9, rft.." RF/T", colors.white, colors.black)
end

function settingsMenu(x, width)
  y = monY-10
  
  -- Scroll Bar
  for i=1, 8 do
    draw_text(x + width-2, y+i, "||", colors.white, colors.black)
  end
  draw_text(x + width-2, y+1, "^^", colors.white, colors.black)
  draw_text(x + width-2, y+9, "vv", colors.white, colors.black)
  
  drawSettings(x+1, y - 13 + settingsOffset, "Scroll through settings -->", colors.gray, colors.black)
  
  -- Auto Power Settings
  auto = auto_string == "true"
  drawSettings(x+1, y - 11 + settingsOffset, "Auto Power:", colors.yellow, colors.black)
  drawSettings(x+2, y - 10 + settingsOffset, "Control power based on", colors.gray, colors.black)
  drawSettings(x+2, y - 9 + settingsOffset, "total energy storage %", colors.gray, colors.black)
  
  offDownBtn = {x+25, y - 8 + settingsOffset}
  offUpBtn = {x+18, y - 8 + settingsOffset}
  onDownBtn = {x+25, y - 7 + settingsOffset}
  onUpBtn = {x+18, y - 7 + settingsOffset}
  
  if auto then
    autoPowerBtn = {x+(width/2-6), y - 6 + settingsOffset}
    drawSettings(x+4, y - 8 + settingsOffset, "Power OFF at", colors.white, colors.black)
    drawSettings(offUpBtn[1], offUpBtn[2], "<<", colors.white, colors.gray)
    drawSettings(offDownBtn[1], offDownBtn[2], ">>", colors.white, colors.gray)
    drawSettings(offUpBtn[1]+3, offUpBtn[2], off.."%", colors.white, colors.black)
    drawSettings(x+4, y - 7 + settingsOffset, "Power ON at", colors.white, colors.black)
    drawSettings(onUpBtn[1], onUpBtn[2], "<<", colors.white, colors.gray)
    drawSettings(onDownBtn[1], onDownBtn[2], ">>", colors.white, colors.gray)
    drawSettings(onUpBtn[1]+3, onUpBtn[2], on.."%", colors.white, colors.black)
    drawSettingsLine(autoPowerBtn[1], autoPowerBtn[2], 10, colors.gray)
    drawSettings(autoPowerBtn[1]+1, autoPowerBtn[2], "Turn Off", colors.white, colors.gray)
  else
  
    -- reset above control button positions
    
    autoPowerBtn = {x+(width/2-5), y - 7 + settingsOffset}
    drawSettingsLine(autoPowerBtn[1], autoPowerBtn[2], 9, colors.gray)
    drawSettings(autoPowerBtn[1]+1, autoPowerBtn[2], "Turn On", colors.white, colors.gray)
  end

  -- Auto Control Rod Settings
  drawSettings(x+1, y - 4 + settingsOffset, "Limit Output:", colors.yellow, colors.black)
  drawSettings(x+2, y - 3 + settingsOffset, "Adjust control rods to", colors.gray, colors.black)
  drawSettings(x+2, y - 2 + settingsOffset, "mantain output of:", colors.gray, colors.black)
  drawSettings(x+4, y - 1 + settingsOffset, " <<  <  3000 RF/t  >  >>", colors.white, colors.black)

  
  drawSettings(x+1, y + 1 + settingsOffset, "Energy Storage:", colors.yellow, colors.black)
  
  -- Energy Storage Mod Setting
  bufferBtn = {x+4, y+2+settingsOffset}
  enderBtn = {x+4, y+3+settingsOffset}
  thermalBtn = {x+4, y+4+settingsOffset}
  drawSettings(bufferBtn[1], bufferBtn[2], "Reactor Buffers", colors.white, colors.black)
  drawSettings(enderBtn[1], enderBtn[2], "EnderIO Capacitors", colors.white, colors.black)
  drawSettings(thermalBtn[1], thermalBtn[2], "Thermal Expansion", colors.white, colors.black)
  if energyStorageSetting == 1 then
    drawSettingsLine(bufferBtn[1]-1, bufferBtn[2], 20, colors.gray)
    drawSettings(bufferBtn[1], bufferBtn[2], "Reactor Buffers", colors.white, colors.gray)
  else if energyStorageSetting == 2 then
    drawSettingsLine(enderBtn[1]-1, enderBtn[2], 20, colors.gray)
    drawSettings(enderBtn[1], enderBtn[2], "EnderIO Capacitors", colors.white, colors.gray)
  else if energyStorageSetting == 3 then
    drawSettingsLine(thermalBtn[1]-1, thermalBtn[2], 20, colors.gray)
    drawSettings(thermalBtn[1], thermalBtn[2], "Thermal Expansion", colors.white, colors.gray)
  end
  end
  end
  
  -- Screen refresh setting
  refreshUpBtn = {x+10, y+7+settingsOffset}
  refreshDownBtn = {x+10, y+9+settingsOffset}
  drawSettings(x+1, y + 6 + settingsOffset, "Refresh Screen:", colors.yellow, colors.black)
  drawSettings(x+4, y + 8 + settingsOffset, "every", colors.white, colors.black)
  drawSettings(x+10, y + 8 + settingsOffset, string.format("%i", refresh), colors.white, colors.black)
  drawSettings(x+12, y + 8 + settingsOffset, "seconds", colors.white, colors.black)
  drawSettings(refreshUpBtn[1], refreshUpBtn[2], "^", colors.white, colors.gray)
  drawSettings(refreshDownBtn[1], refreshDownBtn[2], "v", colors.white, colors.gray)
end

-- limit content of settings menu to window size
-- enables scrolling 
function drawSettings(x, y, text, fore, back)
  if y > monY-10 then
    draw_text(x, y, text, fore, back)
  end
end
function drawSettingsLine(x, y, length, color)
  if y > monY-10 then
    mon.setBackgroundColor(color)
    mon.setCursorPos(x,y)
    mon.write(string.rep(" ", length))
  end
end

-- this method will be deleted 
function homepage()
  while true do
    clear()
    menu_bar()
    terminal_screen()
    monX, monY = mon.getSize()

    energy_stored = reactor.getEnergyStored()
    
    --------POWER STAT--------------
    draw_text(2, 3, "Power:", colors.yellow, colors.black)
    active = reactor.getActive()
    if active then
      draw_text(10, 3, "ONLINE", colors.lime, colors.black)
    else
      draw_text(10, 3, "OFFLINE", colors.red, colors.black)
    end

    -----------FUEL---------------------
    draw_text(2, 5, "Fuel Level:", colors.yellow, colors.black)
    local maxVal = reactor.getFuelAmountMax()
    local minVal = reactor.getFuelAmount() 
    local percent = math.floor((minVal/maxVal)*100)
    draw_text(15, 5, percent.."%", colors.white, colors.black)

    if percent < 25 then
    progress_bar(2, 6, monX-2, minVal, maxVal, colors.red, colors.gray)
    else if percent < 50 then
    progress_bar(2, 6, monX-2, minVal, maxVal, colors.orange, colors.gray)
    else if percent < 75 then 
    progress_bar(2, 6, monX-2, minVal, maxVal, colors.yellow, colors.gray)
    else if percent <= 100 then
    progress_bar(2, 6, monX-2, minVal, maxVal, colors.lime, colors.gray)
    end
    end
    end
    end

    -----------ROD HEAT---------------
    draw_text(2, 8, "Fuel Temp:", colors.yellow, colors.black)
    local maxVal = 2000
    local minVal = math.floor(reactor.getFuelTemperature())

    if minVal < 500 then
    progress_bar(2, 9, monX-2, minVal, maxVal, colors.lime, colors.gray)
    else if minVal < 1000 then
    progress_bar(2, 9, monX-2, minVal, maxVal, colors.yellow, colors.gray)
    else if minVal < 1500 then  
    progress_bar(2, 9, monX-2, minVal, maxVal, colors.orange, colors.gray)
    else if minVal < 2000 then
    progress_bar(2, 9, monX-2, minVal, maxVal, colors.red, colors.gray)
    else if minVal >= 2000 then
      progress_bar(2, 9, monX-2, 2000, maxVal, colors.red, colors.gray)
    end
    end
    end
    end
    end

    draw_text(15, 8, math.floor(minVal).."/"..maxVal, colors.white, colors.black)

    -----------CASING HEAT---------------
    draw_text(2, 11, "Casing Temp:", colors.yellow, colors.black)
    local maxVal = 2000
    local minVal = math.floor(reactor.getCasingTemperature())
    if minVal < 500 then
    progress_bar(2, 12, monX-2, minVal, maxVal, colors.lime, colors.gray)
    else if minVal < 1000 then
    progress_bar(2, 12, monX-2, minVal, maxVal, colors.yellow, colors.gray)
    else if minVal < 1500 then  
    progress_bar(2, 12, monX-2, minVal, maxVal, colors.orange, colors.gray)
    else if minVal < 2000 then
    progress_bar(2, 12, monX-2, minVal, maxVal, colors.red, colors.gray)
    else if minVal >= 2000 then
      progress_bar(2, 12, monX-2, 2000, maxVal, colors.red, colors.gray)
    end
    end
    end
    end
    end
    draw_text(15, 11, math.floor(minVal).."/"..maxVal, colors.white, colors.black)

    -------------OUTPUT-------------------
    if reactor.isActivelyCooled() then

      draw_text(2, 14, "mB/tick:", colors.yellow, colors.black)
      mbt = math.floor(reactor.getHotFluidProducedLastTick())
      draw_text(13, 14, mbt.." mB/t", colors.white, colors.black)

    else

      draw_text(2, 14, "RF/tick:", colors.yellow, colors.black)
      rft = math.floor(reactor.getEnergyProducedLastTick())
      draw_text(13, 14, rft.." RF/T", colors.white, colors.black)

    end

    ------------STORAGE------------
    if reactor.isActivelyCooled() then 

      draw_text(2, 15, "mB Stored:", colors.yellow, colors.black)
      fluid_stored = reactor.getHotFluidAmount()
      fluid_max = reactor.getHotFluidAmountMax()
      fluid_stored_percent = math.floor((fluid_stored/fluid_max)*100)
      draw_text(13, 15, fluid_stored_percent.."% ("..fluid_stored.." mB)", colors.white, colors.black)

    else

      draw_text(2, 15, "RF Stored:", colors.yellow, colors.black)
      energy_stored_percent = math.floor((energy_stored/10000000)*100)
      draw_text(13, 15, energy_stored_percent.."% ("..energy_stored.." RF)", colors.white, colors.black)


    end

    -------------AUTO CONTROL RODS-----------------------
    auto_rods_bool = auto_rods == "true"
    insertion_percent = reactor.getControlRodLevel(0)

    if reactor.isActivelyCooled() then
      draw_text(2, 16, "Control Rods:", colors.yellow, colors.black)
      draw_text(16, 16, insertion_percent.."%", colors.white, colors.black)
    else

      if auto_rods_bool then
        if active then
          if rft > auto_rf+50 then
            reactor.setAllControlRodLevels(insertion_percent+1)
          else if rft < auto_rf-50 then
            reactor.setAllControlRodLevels(insertion_percent-1)
          end
          end
        end

        draw_text(2, 16, "Control Rods:", colors.yellow, colors.black)
        draw_text(16, 16, insertion_percent.."%", colors.white, colors.black)
        draw_text(21, 16, "(Auto)", colors.red, colors.black)
      
      else
        draw_text(2, 16, "Control Rods:", colors.yellow, colors.black)
        draw_text(16, 16, insertion_percent.."%", colors.white, colors.black)
      end
    end


    -------------AUTO SHUTOFF--------------------------
    if reactor.isActivelyCooled() then

      --i dont know what I should do here


    else
      auto = auto_string == "true"
      if auto then
        if active then
          draw_text(2, 17, "Auto off:", colors.yellow, colors.black)
          draw_text(13, 17, off.."% RF Stored", colors.white, colors.black)
          if energy_stored_percent >= off then
            reactor.setActive(false)
            call_homepage()
          end
        else
          draw_text(2, 17, "Auto on:", colors.yellow, colors.black)
          draw_text(13, 17, on.."% RF Stored", colors.white, colors.black)
          if energy_stored_percent <= on then
            reactor.setActive(true)
            call_homepage()
          end
        end
      else
        draw_text(2, 17, "Auto power:", colors.yellow, colors.black)
        draw_text(14, 17, "disabled", colors.red, colors.black)
      end
    end

    sleep(0.5)
  end
end

--------------MENU SCREENS--------------

--auto power menu
function auto_off()

  auto = auto_string == "true"
  if auto then --auto power enabled

    popup_screen(3, "Auto Power", 11)
    draw_text(5, 5, "Enabled", colors.lime, colors.white)
    draw_text(15, 5, " disable ", colors.white, colors.black)
    
    draw_text(5, 7, "ON when storage =", colors.gray, colors.white)
    draw_text(5, 8, " - ", colors.white, colors.black)
    draw_text(13, 8, on.."% RF", colors.black, colors.white)
    draw_text(22, 8, " + ", colors.white, colors.black)

    draw_text(5, 10, "OFF when storage =", colors.gray, colors.white)
    draw_text(5, 11, " - ", colors.white, colors.black)
    draw_text(13, 11, off.."% RF", colors.black, colors.white)
    draw_text(22, 11, " + ", colors.white, colors.black)

    draw_text(11, 13, " Save ", colors.white, colors.black)

    local event, side, xPos, yPos = os.pullEvent("monitor_touch")

    --disable auto
    if yPos == 5 then
      if xPos >= 15 and xPos <= 21 then
        auto_string = "false"
        save_config()
        auto_off()
      else
        auto_off()
      end
    end

    --increase/decrease auto on %
    if yPos == 8 then
      if xPos >= 5 and xPos <= 8 then
        previous_on = on
        on = on-1
      end
      if xPos >= 22 and xPos <= 25 then
        previous_on = on
        on = on+1
      end
    end

    --increase/decrease auto off %
    if yPos == 11 then
      if xPos >= 5 and xPos <= 8 then
        previous_off = off
        off = off-1
      end
      if xPos >= 22 and xPos <= 25 then
        previous_off = off
        off = off+1
      end
    end

    if on < 0 then on = 0 end
    if off >99 then off = 99 end

    if on == off or on > off then
      on = previous_on
      off = previous_off
      popup_screen(5, "Error", 6)
      draw_text(5, 7, "Auto On value must be", colors.black, colors.white)
      draw_text(5, 8, "lower then auto off", colors.black, colors.white)
      draw_text(11, 10, "Okay", colors.white, colors.black)
      local event, side, xPos, yPos = os.pullEvent("monitor_touch")

      auto_off()
    end

    --Okay button
    if yPos == 13 and xPos >= 11 and xPos <= 17 then 
      save_config()
      call_homepage()
    end

    --Exit button
    if yPos == 3 and xPos == 25 then 
      call_homepage()
    end

    auto_off()
  else
    popup_screen(3, "Auto Power", 5)
    draw_text(5, 5, "Disabled", colors.red, colors.white)
    draw_text(15, 5, " enable ", colors.white, colors.gray)
    draw_text(11, 7, "Okay", colors.white, colors.black)

    local event, side, xPos, yPos = os.pullEvent("monitor_touch")

    --Okay button
    if yPos == 7 and xPos >= 11 and xPos <= 17 then 
      call_homepage()
    end

    if yPos == 5 then
      if xPos >= 15 and xPos <= 21 then
        auto_string = "true"
        save_config()
        auto_off()
      else
        auto_off()
      end
    else
      auto_off()
    end
  end
end

--efficiency menu
function efficiency()
  popup_screen(3, "Efficiency", 12)
  fuel_usage = reactor.getFuelConsumedLastTick()
  rft = math.floor(reactor.getEnergyProducedLastTick())

  rfmb = rft / fuel_usage

  draw_text(5, 5, "Fuel Consumption: ", colors.lime, colors.white)
  draw_text(5, 6, fuel_usage.." mB/t", colors.black, colors.white)
  draw_text(5, 8, "Energy per mB: ", colors.lime, colors.white)
  draw_text(5, 9, rfmb.." RF/mB", colors.black, colors.white)

  draw_text(5, 11, "RF/tick:", colors.lime, colors.white)
  draw_text(5, 12, rft.." RF/T", colors.black, colors.white)

  draw_text(11, 14, " Okay ", colors.white, colors.black)

  local event, side, xPos, yPos = os.pullEvent("monitor_touch")

  --Okay button
  if yPos == 14 and xPos >= 11 and xPos <= 17 then 
    call_homepage()
  end

  --Exit button
  if yPos == 3 and xPos == 25 then 
    call_homepage()
  end

  efficiency()
end


function fuel()
  popup_screen(3, "Fuel", 9)

  fuel_max = reactor.getFuelAmountMax()
  fuel_level = reactor.getFuelAmount()
  fuel_reactivity = math.floor(reactor.getFuelReactivity())

  draw_text(5, 5, "Fuel Level: ", colors.lime, colors.white)
  draw_text(5, 6, fuel_level.."/"..fuel_max, colors.black, colors.white)

  draw_text(5, 8, "Reactivity: ", colors.lime, colors.white)
  draw_text(5, 9, fuel_reactivity.."%", colors.black, colors.white)

  draw_text(11, 11, " Okay ", colors.white, colors.black)

  local event, side, xPos, yPos = os.pullEvent("monitor_touch")


  --Okay button
  if yPos == 11 and xPos >= 11 and xPos <= 17 then 
    call_homepage()
  end

  --Exit button
  if yPos == 3 and xPos == 25 then 
    call_homepage()
  end

  fuel()
end

function waste()
  popup_screen(3, "Waste", 8)

  waste_amount = reactor.getWasteAmount()
  draw_text(5, 5, "Waste Amount: ", colors.lime, colors.white)
  draw_text(5, 6, waste_amount.." mB", colors.black, colors.white)
  draw_text(8, 8, " Eject Waste ", colors.white, colors.red)
  draw_text(11, 10, " Close ", colors.white, colors.black)

  local event, side, xPos, yPos = os.pullEvent("monitor_touch")

  --eject button
  if yPos == 8 and xPos >= 8 and xPos <= 21 then 
    reactor.doEjectWaste()
    popup_screen(5, "Waste Eject", 5)
    draw_text(5, 7, "Waste Ejeceted.", colors.black, colors.white)
    draw_text(11, 9, " Close ", colors.white, colors.black)
    local event, side, xPos, yPos = os.pullEvent("monitor_touch")
    --Okay button
    if yPos == 7 and xPos >= 11 and xPos <= 17 then 
      call_homepage()
    end

    --Exit button
    if yPos == 3 and xPos == 25 then 
      call_homepage()
    end
  end

  --Okay button
  if yPos == 10 and xPos >= 11 and xPos <= 17 then 
    call_homepage()
  end

  --Exit button
  if yPos == 3 and xPos == 25 then 
    call_homepage()
  end
  waste()
end

function set_auto_rf()
  popup_screen(5, "Auto Adjust", 11)
    draw_text(5, 7, "Try to maintain:", colors.black, colors.white)

    draw_text(13, 9, " ^ ", colors.white, colors.gray)
    draw_text(10, 11, auto_rf.." RF/t", colors.black, colors.white)
    draw_text(13, 13, " v ", colors.white, colors.gray)
    draw_text(11, 15, " Okay ", colors.white, colors.gray)

    local event, side, xPos, yPos = os.pullEvent("monitor_touch")

    --increase button
    if yPos == 9 then 
      auto_rf = auto_rf + 100
      save_config()
      set_auto_rf()
    end

    --decrease button
    if yPos == 13 then 
      auto_rf = auto_rf - 100
      if auto_rf < 0 then auto_rf = 0 end
      save_config()
      set_auto_rf()
    end

    if yPos == 15 then 
      control_rods()
    end

    set_auto_rf()
end

function control_rods()

  if reactor.isActivelyCooled() then 

    popup_screen(3, "Control Rods", 13)
    insertion_percent = reactor.getControlRodLevel(0)

    draw_text(5, 5, "Inserted: "..insertion_percent.."%", colors.black, colors.white)
    progress_bar(5, 7, 20, insertion_percent, 100, colors.yellow, colors.gray)

    draw_text(5, 9, " << ", colors.white, colors.black)
    draw_text(10, 9, " < ", colors.white, colors.black)
    draw_text(17, 9, " > ", colors.white, colors.black)
    draw_text(21, 9, " >> ", colors.white, colors.black)

    draw_text(5, 11, "Auto:", colors.black, colors.white)
    draw_text(5, 13, "unavilable for", colors.red, colors.white)
    draw_text(5, 14, "active cooling", colors.red, colors.white)

    draw_text(11, 16, " Close ", colors.white, colors.gray)

    local event, side, xPos, yPos = os.pullEvent("monitor_touch")

    if yPos == 9 and xPos >= 5 and xPos <= 15 then 
      reactor.setAllControlRodLevels(insertion_percent-10)
    end

    if yPos == 9 and xPos >= 10 and xPos <= 13 then 
      reactor.setAllControlRodLevels(insertion_percent-1)
    end

    if yPos == 9 and xPos >= 17 and xPos <= 20 then 
      reactor.setAllControlRodLevels(insertion_percent+1)
    end

    if yPos == 9 and xPos >= 21 and xPos <= 25 then 
      reactor.setAllControlRodLevels(insertion_percent+10)
    end

    ------Close button-------
    if yPos == 16 and xPos >= 11 and xPos <= 17 then 
      call_homepage()
    end

    ------Exit button------------
    if yPos == 5 and xPos == 25 then 
      call_homepage()
    end
    control_rods()

  else

    popup_screen(3, "Control Rods", 13)
    insertion_percent = reactor.getControlRodLevel(0)

    draw_text(5, 5, "Inserted: "..insertion_percent.."%", colors.black, colors.white)
    progress_bar(5, 7, 20, insertion_percent, 100, colors.yellow, colors.gray)

    draw_text(5, 9, " << ", colors.white, colors.black)
    draw_text(10, 9, " < ", colors.white, colors.black)
    draw_text(17, 9, " > ", colors.white, colors.black)
    draw_text(21, 9, " >> ", colors.white, colors.black)

    draw_text(5, 11, "Auto:", colors.black, colors.white)
    draw_text(16, 11, " disable ", colors.white, colors.black)

    auto_rods_bool = auto_rods == "true"
    if auto_rods_bool then
      
      draw_text(5, 13, "RF/t: "..auto_rf, colors.black, colors.white)
      draw_text(18, 13, " set ", colors.white, colors.black)
    else
      draw_text(16, 11, " enable ", colors.white, colors.black)
      draw_text(5, 13, "disabled", colors.red, colors.white)
    end

    draw_text(11, 15, " Close ", colors.white, colors.gray)

    local event, side, xPos, yPos = os.pullEvent("monitor_touch")

    -----manual adjust buttons------------
    if yPos == 9 and xPos >= 5 and xPos <= 15 then 
      reactor.setAllControlRodLevels(insertion_percent-10)
    end

    if yPos == 9 and xPos >= 10 and xPos <= 13 then 
      reactor.setAllControlRodLevels(insertion_percent-1)
    end

    if yPos == 9 and xPos >= 17 and xPos <= 20 then 
      reactor.setAllControlRodLevels(insertion_percent+1)
    end

    if yPos == 9 and xPos >= 21 and xPos <= 25 then 
      reactor.setAllControlRodLevels(insertion_percent+10)
    end


    ------auto buttons-----------------
    if yPos == 11 and xPos >= 16 then 
      if auto_rods_bool then
        auto_rods = "false"
        save_config()
        control_rods()
      else
        auto_rods = "true"
        save_config()
        control_rods()
      end
    end

    if yPos == 13 and xPos >= 18 then 
      set_auto_rf()
    end

    ------Close button-------
    if yPos == 15 and xPos >= 11 and xPos <= 17 then 
      call_homepage()
    end

    ------Exit button------------
    if yPos == 5 and xPos == 25 then 
      call_homepage()
    end
    control_rods()

  end
end

-----------------------Settings--------------------------------


function rf_mode()
  wait = read()
end

function steam_mode()
  wait = read()
end

function install_update(program, pastebin)
    clear()
    draw_line(4, 5, 22, colors.blue)

    for counter = 6, 10 do
      draw_line(4, counter, 22, colors.white)
    end

    draw_text(5, 5, "Updating...", colors.white, colors.blue)
    draw_text(5, 7, "Open computer", colors.black, colors.white)
    draw_text(5, 8, "terminal.", colors.black, colors.white)

    if fs.exists("install") then fs.delete("install") end
    shell.run("pastebin get p4zeq7Ma install")
    shell.run("install")
end

function update()
  popup_screen(5, "Updates", 4)
  draw_text(5, 7, "Connecting to", colors.black, colors.white)
  draw_text(5, 8, "pastebin...", colors.black, colors.white)

  sleep(0.5)
  
  shell.run("pastebin get MkF2QQjH current_version.txt")
  sr = fs.open("current_version.txt", "r")
  current_version = tonumber(sr.readLine())
  sr.close()
  fs.delete("current_version.txt")
  terminal_screen()

  if current_version > version then

    popup_screen(5, "Updates", 7)
    draw_text(5, 7, "Update Available!", colors.black, colors.white)
    draw_text(11, 9, " Install ", colors.white, colors.black)
    draw_text(11, 11, " Ignore ", colors.white, colors.black)

    local event, side, xPos, yPos = os.pullEvent("monitor_touch")

    --Instatll button
    if yPos == 9 and xPos >= 11 and xPos <= 17 then 
      install_update()
    end

    --Exit button
    if yPos == 5 and xPos == 25 then 
      call_homepage()
    end
    call_homepage()

  else
    popup_screen(5, "Updates", 5)
    draw_text(5, 7, "You are up to date!", colors.black, colors.white)
    draw_text(11, 9, " Okay ", colors.white, colors.black)

    local event, side, xPos, yPos = os.pullEvent("monitor_touch")

    --Okay button
    if yPos == 9 and xPos >= 11 and xPos <= 17 then 
      call_homepage()
    end

    --Exit button
    if yPos == 5 and xPos == 25 then 
      call_homepage()
    end
    call_homepage()
  end
end

function indent(width, string)
--((col/2)-(string:len()-1))
  length = string:len()
  if width >= length then
    num = (width/2) - (length/2)
    if num > 0 then
      return num
    else
      return 1
    end  
  else
    return 1  
  end
end

function reset_peripherals()
  clear()
  draw_line(4, 5, 22, colors.blue)

  for counter = 6, 10 do
    draw_line(4, counter, 22, colors.white)
  end

  draw_text(5, 5, "Reset Peripherals", colors.white, colors.blue)
  draw_text(5, 7, "Open computer", colors.black, colors.white)
  draw_text(5, 8, "terminal.", colors.black, colors.white)
  setup_wizard()

end

--stop running status screen if monitors was touched
function stop()
  while true do
    local event, side, xPos, yPos = os.pullEvent("monitor_touch")
      x = xPos
      y = yPos
      stop_function = "monitor_touch"
    return
  end 
end

function mon_touch_controller()
  -- panel menu buttons
  if y == monY-11 then
    if x >= powerX and  x <= powerX+5 then
      selectMenu(1, 1)
    else if x >= infoX and x <= infoX+5 then
      selectMenu(2, 1)
    else if x >= optionsX and x <= optionsX+8 then
      selectMenu(3, 1)
    else if x >= powerX2 and x <= powerX2+5 then
      selectMenu(1, 2)
    else if x >= infoX2 and x <= infoX2+5 then
      selectMenu(2, 2)
    else if x >= optionsX2 and x <= optionsX2+8 then
      selectMenu(3, 2)
    end
    end
    end
    end
    end
    end
  end
  
  if y == mainPowerBtn[2] then 
    if x > mainPowerBtn[1] and x < mainPowerBtn[1]+6 then
      if mainPower then
        mainPower = false
        for i=1, #reactors do
          reactors[i].setActive(false)
        end
      else 
        mainPower = true
        for i=1, #reactors do
          reactors[i].setActive(true)
        end
      end
    end
  end
  
  if y > monY-11 then
    mon_touch_settings(x, y)
  end

  call_controller()
end 

function selectMenu(menu, panel)
  if panel == 1 then
    if panel1Tool == menu then
      panel1Tool = 0
    else 
      panel1Tool = menu
    end
  else if panel == 2 then
    if panel2Tool == menu then
      panel2Tool = 0
    else
      panel2Tool = menu
    end
    
  end
  end
  call_controller()
end

function mon_touch_settings(x, y)
  -- settings scroll bar
  if splitScreen then
    if panel1Tool == 3 then
      if x == ((monX/2) - 2) or x == ((monX/2) - 1) then
        settingsOffset = settingsOffset + 1
      end
    end
    if panel2Tool == 3 then
      if x == (monX - 2) or x == (monX - 1) then
        if y > monY-10 and y < monY-5 then
          settingsOffset = settingsOffset + 1
        end
        if y > monY-5 and y < monY then
          settingsOffset = settingsOffset - 1
        end
      end
    end
  else
    if x == (monX - 1) or x == (monX ) then
      if y > monY-10 and y < monY-5 then
        settingsOffset = settingsOffset + 1
      end
      if y > monY-5 and y < monY then
        settingsOffset = settingsOffset - 1
      end
    end
  end
  
  -- energy storage settings
  if y == bufferBtn[2] then
    if x >= bufferBtn[1] and x < bufferBtn[1]+20 then
      energyStorageSetting = 1
    end
  end
  if y == enderBtn[2] then
    if x >= enderBtn[1] and x < enderBtn[1]+20 then
      energyStorageSetting = 2
    end
  end
  if y == thermalBtn[2] then
    if x >= thermalBtn[1] and x < thermalBtn[1]+20 then
      energyStorageSetting = 3
    end
  end
  
  -- refresh screen settings
  if y == refreshUpBtn[2] then
    if x > refreshUpBtn[1]-1 and x < refreshUpBtn[1]+1 then
      refresh = refresh + 1
    end
  end
  if y == refreshDownBtn[2] then
    if x > refreshDownBtn[1]-1 and x < refreshDownBtn[1]+1 then
      if refresh > 1 then
        refresh = refresh - 1
      end
    end
  end
  
  -- auto power toggle
  if y == autoPowerBtn[2] then
    if x > autoPowerBtn[1] and x < autoPowerBtn[1]+10 then 
      auto = auto_string == "true"
      if auto then
        auto_string = "false"
      else
        auto_string = "true"
      end
    end
  end
  
  -- set auto power percents
  if y == offUpBtn[2] then
    if x > offUpBtn[1] and x < offUpBtn[1]+2 then 
      if off < 100 then
        off = off + 1
      end
    end
  end
  if y == offDownBtn[2] then
    if x > offDownBtn[1] and x < offDownBtn[1]+2 then 
      if off > on+1 then
        off = off - 1
      end
    end
  end
  if y == onUpBtn[2] then
    if x > onUpBtn[1] and x < onUpBtn[1]+2 then 
      if on < off+1 then
        on = on + 1
      end
    end
  end
  if y == onDownBtn[2] then
    if x > onDownBtn[1] and x < onDownBtn[1]+2 then 
      if on > 0 then
        on = on - 1
      end
    end
  end
  
  -- Select reactor for info page
  if y == lastReactorBtn[2] then
    if x > lastReactorBtn[1]-2 and x < lastReactorBtn[1]+3 then
      if currentInfoPage == 0 then
        currentInfoPage = #reactors
      else
        currentInfoPage = currentInfoPage - 1
      end
    end
  end
  if y == nextReactorBtn[2] then
    if x > nextReactorBtn[1]-2 and x < nextReactorBtn[1]+3 then
      if currentInfoPage == #reactors then
        currentInfoPage = 0
      else
        currentInfoPage = currentInfoPage + 1
      end
    end
  end
  
  save_config()
  call_controller()
end

function mon_touch()
  --when the monitor is touch on the homepage
  if y == 1 then 
      if x < monX/3 then
        power_menu()
        local event, side, xPos, yPos = os.pullEvent("monitor_touch")
        if xPos < 9 then
          if yPos == 2 then
            reactor.setActive(true)
            timer = 0 --reset anytime the reactor is turned on/off
            call_homepage()
          else if yPos == 3 then
            reactor.setActive(false)
            timer = 0 --reset anytime the reactor is turned on/off
            call_homepage()
          else if yPos == 4 then
            auto_off()
          else
            call_homepage()
          end
          end
          end
        else
          call_homepage()
        end
        
      else if x < 20 then
        tools_menu()
        local event, side, xPos, yPos = os.pullEvent("monitor_touch")
        if xPos < 25 and xPos > 10 then
          if yPos == 2 then
            control_rods()
          else if yPos == 3 then
            efficiency()
          else if yPos == 4 then
            fuel()
          else if yPos == 5 then
            waste()
          else
            call_homepage()
          end
          end
          end
          end
        else
          call_homepage()
        end
      else if x < monX then
        settings_menu()
        local event, side, xPos, yPos = os.pullEvent("monitor_touch")
        if xPos > 13 then
          if yPos == 2 then
            update()
          else if yPos == 3 then
            reset_peripherals() 
          else
            call_homepage()
          end
          end
        else
          call_homepage()
        end
      end
      end
      end
    else
      call_homepage()
    end
end

function terminal_screen()
  term.clear()
  draw_line_term(1, 1, 55, colors.blue)
  draw_text_term(13, 1, "BigReactor Controls", colors.white, colors.blue)
  draw_line_term(1, 19, 55, colors.blue)
  draw_text_term(13, 19, "by jaranvil aka jared314", colors.white, colors.blue)

  draw_text_term(1, 3, "Current program:", colors.white, colors.black)
  draw_text_term(1, 4, "Reactor Control v"..version, colors.blue, colors.black)
  
  draw_text_term(1, 6, "Installer:", colors.white, colors.black)
  draw_text_term(1, 7, "pastebin.com/p4zeq7Ma", colors.blue, colors.black)

  draw_text_term(1, 9, "Please give me your feedback, suggestions,", colors.white, colors.black)
  draw_text_term(1, 10, "and errors!", colors.white, colors.black)

  draw_text_term(1, 11, "reddit.com/r/br_controls", colors.blue, colors.black)
end

--run both homepage() and stop() until one returns
function call_homepage()
  clear()
  parallel.waitForAny(homepage, stop) 

  if stop_function == "terminal_screen" then 
    stop_function = "nothing"
    setup_wizard()
  else if stop_function == "monitor_touch" then
    stop_function = "nothing"
    mon_touch()
  end
  end
end

function call_controller()
  clear()
  parallel.waitForAny(controller, stop) 

  if stop_function == "terminal_screen" then 
    stop_function = "nothing"
    setup_wizard()
  else if stop_function == "monitor_touch" then
    stop_function = "nothing"
    mon_touch_controller()
  end
  end
end

--write settings to config file
function save_config()
  sw = fs.open("config.txt", "w")   
    sw.writeLine(version)
    sw.writeLine(auto_string)
    sw.writeLine(on)
    sw.writeLine(off)
    sw.writeLine(auto_rods)
    sw.writeLine(auto_rf)
    sw.writeLine(refresh)
  sw.close()
end

--read settings from file
function load_config()
  sr = fs.open("config.txt", "r")
    version = tonumber(sr.readLine())
    auto_string = sr.readLine()
    on = tonumber(sr.readLine())
    off = tonumber(sr.readLine())
    auto_rods = sr.readLine()
    auto_rf = tonumber(sr.readLine())
    refresh = tonumber(sr.readLine())
  sr.close()
end

--test if the entered monitor and reactor can be wrapped
  function test_configs()
  term.clear()

  draw_line_term(1, 1, 55, colors.blue)
  draw_text_term(10, 1, "BigReactors Controls", colors.white, colors.blue)
  
  draw_line_term(1, 19, 55, colors.blue)
  draw_text_term(10, 19, "by jaranvil aka jared314", colors.white, colors.blue)

  draw_text_term(1, 3, "Searching for a peripherals...", colors.white, colors.black)
  sleep(1)

  reactorSearch()
  mon = monitorSearch()
  
  
  draw_text_term(2, 5, "Connecting to reactor...", colors.white, colors.black)
  sleep(0.5)
  if reactors[1] == null then
      draw_text_term(1, 8, "Error:", colors.red, colors.black)
      draw_text_term(1, 9, "Could not find any connected reactors", colors.red, colors.black)
      draw_text_term(1, 10, "Reactors must be connected with networking cable", colors.white, colors.black)
      draw_text_term(1, 11, "and modems or the computer is directly beside", colors.white, colors.black)
      draw_text_term(1, 12,"the reactors computer port.", colors.white, colors.black)
      draw_text_term(1, 14, "Press Enter to continue...", colors.gray, colors.black)
      wait = read()
      setup_wizard()
  else
      if #reactors == 1 then
        draw_text_term(27, 5, #reactors .. " reactor found", colors.lime, colors.black)
      else
        draw_text_term(27, 5, #reactors .. " reactors found", colors.lime, colors.black)
      end
      sleep(0.5)
  end
  
  draw_text_term(2, 6, "Connecting to monitor...", colors.white, colors.black)
  sleep(0.5)
  if mon == null then
      draw_text_term(1, 7, "Error:", colors.red, colors.black)
      draw_text_term(1, 8, "Could not connect to a monitor. Place a 3x3 advanced monitor", colors.red, colors.black)
      draw_text_term(1, 11, "Press Enter to continue...", colors.gray, colors.black)
      wait = read()
      setup_wizard()
  else
      monX, monY = mon.getSize()
      draw_text_term(27, 6, "success", colors.lime, colors.black)
      sleep(0.5)
  end
    draw_text_term(2, 7, "saving configuration...", colors.white, colors.black)  

    save_config()

    sleep(0.1)
    draw_text_term(1, 9, "Setup Complete!", colors.lime, colors.black) 
    sleep(1)

    auto = auto_string == "true"
    
    if #reactors == 1 then
      reactor = reactors[1]
      call_homepage() 
    else
      call_controller()
    end
end
----------------SETUP-------------------------------

function setup_wizard()
  
  term.clear()

  
     draw_text_term(1, 1, "BigReactor Controls v"..version, colors.lime, colors.black)
     draw_text_term(1, 2, "Peripheral setup", colors.white, colors.black)
     draw_text_term(1, 4, "Step 1:", colors.lime, colors.black)
     draw_text_term(1, 5, "-Place 3x3 advanced monitors next to computer.", colors.white, colors.black)
     draw_text_term(1, 7, "Step 2:", colors.lime, colors.black)
     draw_text_term(1, 8, "-Place a wired modem on this computer and on the ", colors.white, colors.black)
     draw_text_term(1, 9, " computer port of the reactor.", colors.white, colors.black)
     draw_text_term(1, 10, "-connect modems with network cable.", colors.white, colors.black)
     draw_text_term(1, 11, "-right click modems to activate.", colors.white, colors.black)
     draw_text_term(1, 13, "Press Enter when ready...", colors.gray, colors.black)
    
     wait = read()
      test_configs()

   
end

function reactorSearch()
   local names = peripheral.getNames()
   local i, name
   local x=1
--   for i, name in pairs(names) do
--      if peripheral.getType(name) == "BigReactors-Reactor" then
--         reactors[x] = peripheral.wrap(name)
--		     x = x + 1
--      end
--   end  
   
   for i=1,#names do
     if peripheral.getType(names[i]) == "BigReactors-Reactor" then
         reactors[x] = peripheral.wrap(names[i])
         x = x + 1
      end
   end
end

function monitorSearch()
   local names = peripheral.getNames()
   local i, name
   for i, name in pairs(names) do
      if peripheral.getType(name) == "monitor" then
        test = name
         return peripheral.wrap(name)
      else
         --return null
      end
   end
end

function start()
  --if configs exists, load values and test
  if fs.exists("config.txt") then
      load_config()
      test_configs()
  else
    setup_wizard()
  end
end

start()