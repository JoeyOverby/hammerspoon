
--Most of this code is from: https://gist.github.com/nyergler/7056c61174194a9af9b4d5d727f1b566 
--Need to check out https://github.com/jwkvam/hammerspoon-config/blob/master/init.lua (to see about re-sizing on other screens as it does't seem to be working right) 
-- Another tutorial: https://zzamboni.org/post/just-enough-lua-to-be-productive-in-hammerspoon-part-1/

-- Must download miro-windows-manager https://github.com/miromannino/miro-windows-manager/blob/master/MiroWindowsManager.spoon.zip



-- Must install spaces project from: https://github.com/asmagill/hs._asm.spaces
-- Expected relative path is ./hs/spaces.lua for that project 
-- =========================================== --
--             Needed Imports                  --
-- =========================================== --
hs.loadSpoon("MiroWindowsManager") 
local spaces = require "hs.spaces"
local window = require "hs.window"


-- =========================================== --
--             Global Variables                --
-- =========================================== --
-- Variables to clarify my keyboard 
winKey = "ctrl" 
ctrlKey = "cmd" 
altKey = "alt" 
shiftKey = "shift" 
-- Moving windows variables
leftKey = "left" 
rightKey = "right" 
downKey = "down" 
upKey = "up" 
 
hyper = {ctrlKey, altKey} 
fullHyper = {ctrlKey, winKey, altKey} 
moveWindowMonitors = fullHyper 
moveWindowSpaces = {ctrlKey, winKey}

left = "left" 
right = "right" 
top = "top" 
bottom = "bottom" 
middle = "middle" 
half = 2 
third = 3 
quarter = 4 
fifth = 5
 
-- Global vars used by the resize window call. 
xVal = 0 
yVal = 0 
width = nil 
height = nil 
hs.window.animationDuration = 0.3 

-- Log to console or screen
logToConsole = true
-- Allow for toggling between normal two button mouse to 4 button mouse. 
fourButtonMouseMode = false
remapNext = true
-- -- A table for the fourButtonMouseMode changes
remapTable = {}
remapTable[0] = 'leftMouse'
remapTable[1] = 'leftMouse'
remapTable[2] = 'rightMouse'
remapTable[3] = 'rightMouse'



-- =========================================== --
--        Printing/Logging Functions           --
-- =========================================== --
-- Print a message to the screen! --
function printToScreen(message) 
hs.alert.show( 
         message, 
         { 
            textFont= "Comic Sans MS", 
            textSize=32, 
            fadeOutDuration=5 
         } 
      ) 
end 
-- Switch between the print to screen and log to the Hammerspoon Console. 
function debugLog(message)
  if logToConsole == true then
    hs.console.printStyledtext(message)
  else
    printToScreen(message)
  end
end 
function dump(o)
  if type(o) == 'table' then
     local s = '{ '
    --  hs.console.printStyledtext(pairs(o).size)
     for k,v in pairs(o) do
        if type(k) ~= 'number' then k = '"'..k..'"' end
        s = s .. '['..k..'] = ' .. dump(v) .. ','
     end
     return s .. '} '
  else
     return tostring(o)
  end
end
 


spoon.MiroWindowsManager:bindHotkeys({ 
  up = {hyper, "up"}, 
  right = {hyper, "right"}, 
  down = {hyper, "down"}, 
  left = {hyper, "left"}, 
  fullscreen = {fullHyper, upKey} 
}) 
 

 function handleWindowSizingParams(direction, splitType) 
  --local window = hs.window.focusedWindow() 
  local window = hs.window.frontmostWindow() 
  local windowBoundary = window:frame() 
  local windowWidth = windowBoundary.w 
  local screen = window:screen() 
  local frame = screen:frame() --This is the height and width max of the screen 
  --debugLog("BEFORE: FrameX: " .. frame.x .. " FrameY: " .. frame.y) 
  --debugLog("BEFORE: WindowX: " .. windowBoundary.x .. " FrameY: " .. windowBoundary.y) 
 -- Unless Changed 
  xVal = frame.x 
  yVal = frame.y 
  local maxWidth = frame.w 
  local maxHeight = frame.h 
  if direction == middle then 
    --If we are at 1/2's go to 1/3's 
    if windowWidth == maxWidth /2 then 
      splitType = 3 
    else  
      splitType = 2   
    end 
    width = maxWidth / splitType         
    xVal = xVal + (maxWidth - width) / 2 
  end 
 --     if direction == left then  
 --    width = maxWidth / splitType 
 --     end 
 --     if direction == right then         
 --       width = maxWidth / splitType 
 --       xVal = xVal + maxWidth * (splitType-1)/splitType 
 --     end 

      if direction == up then 
        height = frame.h / splitType 
        yVal = 0 
      end 

      if direction == bottom then  
        yVal = 0 
        height = frame.h / splitType 
      end 
  end 
 
 
-- Function that actually does the resizing -- 
function resizeWindow(direction, splitType, secondDirection, secondSplitType) 
  --debugLog("Called") 
  --debugLog(direction) 
  --debugLog(splitType) 
  --debugLog(secondDirection) 
  --debugLog(secondSplitType) 
  --local window = hs.window.focusedWindow() 
  local window = hs.window.frontmostWindow() 
  local windowBoundary = window:frame() 
  local screen = window:screen() 
  local max = screen:frame() 
  windowBoundary.x = max.x 
  windowBoundary.y = max.y 
  windowBoundary.w = max.w 
  windowBoundary.h = max.h 
--Default Values 
  xVal = max.x 
  yVal = max.y 
  width = max.w 
  height = max.h 
 --debugLog("xVal: " .. xVal .. " yVal: " .. yVal .. " heigt: " .. height .. " width: " .. width  ) 
    
    if direction ~= nil then 
      handleWindowSizingParams(direction, splitType) 
    end 
  --debugLog("xVal: " .. xVal .. " yVal: " .. yVal .. " heigt: " .. height .. " width: " .. width  ) 
    if secondDirection ~= nil then 
      handleWindowSizingParams(secondDirection, secondSplitType) 
    end 
  --debugLog("xVal: " .. xVal .. " yVal: " .. yVal .. " heigt: " .. height .. " width: " .. width  ) 
  windowBoundary.x = xVal 
  windowBoundary.y = yVal 
  windowBoundary.w = width 
  windowBoundary.h = height 
--debugLog("Setting To: FrameX: " .. xVal .. " FrameY: " .. yVal) 
  window:setFrame(windowBoundary) 
end 

-- =========================================== --
--                Key Bindings                 --
-- =========================================== --
---------- Mouse Button Changes -----------
hs.hotkey.bind(fullHyper, "M", function() 
  if(fourButtonMouseMode == true) then
    printToScreen("Changing Mouse Mode to 2 Button Mouse") 
  else
    printToScreen("Changing Mouse Mode to 4 Button Mouse") 
  end
  fourButtonMouseMode = not fourButtonMouseMode
end) 

------------- Debug Mode Logging Options -------------
hs.hotkey.bind(fullHyper, "D", function() 
  logToConsole = not logToConsole
  
  if(logToConsole == true) then
    printToScreen("Debug Mode Logging: Hammerspoon Console") 
  else
    printToScreen("Debug Mode Logging: Screen") 
  end
  
end) 

------------- Window Movement Functions -------------
-- Middles ---------------- 
hs.hotkey.bind(fullHyper, downKey, function() 
  resizeWindow(middle, half) 
end) 
hs.hotkey.bind(fullHyper, downKey, function() 
  resizeWindow(middle, third) 
end) 
hs.hotkey.bind(fullHyper, downKey, function() 
  resizeWindow(middle, fourth) 
end) 
hs.hotkey.bind(fullHyper, downKey, function() 
  resizeWindow(middle, fifth) 
end) 

-- Move Windows Monitors---------------- 
hs.hotkey.bind(moveWindowMonitors, rightKey, function() 
  -- move the focused window one display to the right 
  local win = hs.window.focusedWindow() 
  win:moveOneScreenEast() 
end) 
hs.hotkey.bind(moveWindowMonitors, leftKey, function() 
  -- move the focused window one display to the left 
  local win = hs.window.focusedWindow() 
  win:moveOneScreenWest() 
end) 
hs.hotkey.bind({winKey, altKey, ctrlKey}, "R", function() 
      RoundedCorners = hs.loadSpoon('RoundedCorners') 
      RoundedCorners.radius = 20 
      RoundedCorners:start() 
      hs.alert.show("Oooooooooh, so ROUND!") 
end) 

-- Switch windows -----
hs.hotkey.bind({winKey, altKey, ctrlKey}, "F", function() 
  -- toggle the focused window to full screen (workspace) 
  local win = hs.window.focusedWindow() 
  win:setFullScreen(not win:isFullScreen()) 
end) 
hs.hotkey.bind({ctrlKey, altKey}, "L", function() 
  hs.caffeinate.systemSleep() 
end) 

 

 
-- =========================================== --
--        Functions                            --
-- =========================================== --
-- Mute the laptop on wake 
function muteOnWake(eventType) 
  if (eventType == hs.caffeinate.watcher.systemDidWake) then 
    local output = hs.audiodevice.defaultOutputDevice() 
    output:setMuted(true) 
  end 
end 

-- Automatically reload config on save of hammerspoon file
function reloadConfig(files) 
  doReload = false 
  for _,file in pairs(files) do 
      if file:sub(-4) == ".lua" then 
          doReload = true 
      end 
  end 
  if doReload then 
      hs.reload() 
  end 
end 



------ Prints to the Hammerspoon Console the mouse button being clicked -------
printMouseButtonClicked = hs.eventtap.new({ 
  hs.eventtap.event.types.otherMouseDown,
  hs.eventtap.event.types.leftMouseDown,
  hs.eventtap.event.types.rightMouseDown
}, function(e)
  local button = e:getProperty(
      hs.eventtap.event.properties['mouseEventButtonNumber']
  )
  debugLog(string.format("Clicked Mouse Button: %i", button))
end)

-- This function handles the actual remapping of a button click or button up event. 
function remapMouseEvent(mouseButton, clicked) 
  
  -- Only do this in fourButtonMouseMode
  if(fourButtonMouseMode == true) then
    debugLog('\nRemap Called: ' .. mouseButton)
    if ( remapNext == true ) then
      debugLog('RemapNext: true')
    else
      debugLog('RemapNext: false')
    end


    if (clicked == true) then
      debugLog('Remap Called: ' .. mouseButton .. ' Clicked')
      buttonDirection = 'Down'
    else
      debugLog('Remap Called: ' .. mouseButton .. ' Up')
      buttonDirection = 'Up'
    end
    newEvent = remapTable[mouseButton] .. buttonDirection
    newEventUp = remapTable[mouseButton] .. 'Up'
    
    debugLog('New Event- ' .. newEvent)
    local point = hs.mouse.absolutePosition()
    if (remapNext == true) then
      remapNext = false
      debugLog('Calling new event: ' .. newEvent)
      hs.eventtap.event.newMouseEvent(hs.eventtap.event.types[newEvent], point):post()
      debugLog('Calling new event: ' .. newEventUp)
      hs.eventtap.event.newMouseEvent(hs.eventtap.event.types[newEventUp], point):post()
    else
      remapNext = true
    end
    return true
  else
    -- debugLog('Not in 4 Button Mode')
  end
end


overrideMouseButtonsDown = hs.eventtap.new({ 
  hs.eventtap.event.types.leftMouseDown, 
  hs.eventtap.event.types.rightMouseDown, 
  hs.eventtap.event.types.otherMouseDown 
  }, 
  function(e)
    local mouseButton = e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber'])
    -- debugLog('Calling remap: Button: ' .. mouseButton .. ' - clicked: true');
    return remapMouseEvent(mouseButton, true)
end)


overrideMouseButtonsUp = hs.eventtap.new({ 
  hs.eventtap.event.types.leftMouseUp, 
  hs.eventtap.event.types.rightMouseUp, 
  hs.eventtap.event.types.otherMouseUp 
},
  function(e)
    local mouseButton = e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber'])
    -- debugLog('Calling remap: Button: ' .. mouseButton .. ' - clicked: false');
    return remapMouseEvent(mouseButton, false)
end)

-- =========================================== --
--             Move Windows Spaces             --
-- =========================================== --
function getGoodFocusedWindow(nofull)
  local win = window.focusedWindow()
  if not win or not win:isStandard() then return end
  if nofull and win:isFullScreen() then return end
  return win
end 
function flashScreen(screen)
  local flash=hs.canvas.new(screen:fullFrame()):appendElements({
  action = "fill",
  fillColor = { alpha = 0.25, red=1},
  type = "rectangle"})
  flash:show()
  hs.timer.doAfter(.15,function () flash:delete() end)
end 
function switchSpace(skip,dir)
  for i=1,skip do
     hs.eventtap.keyStroke({"ctrl","fn"},dir,0) -- "fn" is a bugfix!
  end 
end
function moveWindowOneSpace(dir,switch)
  local win = getGoodFocusedWindow(true)
  if not win then return end
  local screen=win:screen()
  local uuid=screen:getUUID()
  local userSpaces=nil
  for k,v in pairs(spaces.allSpaces()) do
     userSpaces=v
     if k==uuid then break end
  end
  if not userSpaces then return end
  local thisSpace=spaces.windowSpaces(win) -- first space win appears on
  if not thisSpace then return else thisSpace=thisSpace[1] end
  local last=nil
  local skipSpaces=0
  for _, spc in ipairs(userSpaces) do
     if spaces.spaceType(spc)~="user" then -- skippable space
  skipSpaces=skipSpaces+1
     else
  if last and
     ((dir=="left" and spc==thisSpace) or
      (dir=="right" and last==thisSpace)) then
        local newSpace=(dir=="left" and last or spc)
        if switch then
          -- printToScreen("Switch called")
          -- spaces.gotoSpace(newSpace)  -- also possible, invokes MC
          switchSpace(skipSpaces+1,dir)
        end
        spaces.moveWindowToSpace(win,newSpace)
        -- Focus this window so that you can move it again. 
        win:focus()
        return
  end
  last=spc   -- Haven't found it yet...
  skipSpaces=0
     end
  end
  flashScreen(screen)   -- Shouldn't get here, so no space found
end
hs.hotkey.bind(moveWindowSpaces, rightKey, nil,
     function() 
      moveWindowOneSpace("right",true) end)
hs.hotkey.bind(moveWindowSpaces, leftKey ,nil,
     function() moveWindowOneSpace("left",true) end)
-- hs.hotkey.bind(mashshift, "s",nil,
--      function() moveWindowOneSpace("right",false) end)
-- hs.hotkey.bind(mashshift, "a",nil,
--      function() moveWindowOneSpace("left",false) end)
    


-- =========================================== --
--             Commented Out/Saved Code        --
-- =========================================== --

---- Other Helpful Hammerspoon Links ------
-- https://tom-henderson.github.io/2018/12/14/hammerspoon.html
-- hs.hotkey.bind({"alt", "ctrl"}, "Tab", function()
--   hs.application.launchOrFocus("Mission Control.app")
-- end)
-- ===========   https://gist.github.com/wolever/ca59d78fdd800d6dfbfb6cb093cfd813 =================================


-- This function handles the actual remapping of a button click or button up event. 
-- function remapMouseEventOld(mouseButton, clicked) 
--   debugLog('Remap Called: ' .. mouseButton)
--   -- Only do this in fourButtonMouseMode
--   if(fourButtonMouseMode == true) then
--     if (clicked == true) then
--       buttonDirection = 'Down'
--     else
--       buttonDirection = 'Up'
--     end
--     newEvent = remapTable[mouseButton] .. buttonDirection
    
--     debugLog('New Event- ' .. newEvent)
--     local point = hs.mouse.getAbsolutePosition()
--     hs.eventtap.event.newMouseEvent(hs.eventtap.event.types[newEvent], point):post()
--     return true
--   else
--     debugLog('Not in 4 Button Mode')
--   end
-- end


-- Kensington Button Layout --
--
--  -------
-- | 2 | 3 |
--  -------
-- | 0 | 1 |
--  -------
--
--
--
-- Right Click Function: hs.eventtap.rightClick(point[, delay])






-- ======================================================================================
-- =========================================== --
--             Turn On/Off Functions           --
-- =========================================== --
-- ======================================================================================
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start() 
hs.alert.show("Config Reloaded") 
caffeinateWatcher = hs.caffeinate.watcher.new(muteOnWake) 
caffeinateWatcher:start() 
-- === Mouse Related Functions === ---
-- printMouseButtonClicked:start()
-- Turn ON/OFF the remapping functions.
overrideMouseButtonsDown:start()
-- overrideMouseButtonsUp:start()
