platform.apiLevel = "2.3"

local w = platform.window:width()
local h = platform.window:height()

local Input = class()
local inputs = {}
local selector = 1

local strings = {}
  strings[1] = "A"
  strings[2] = "a"
  strings[3] = "B"
  strings[4] = "b"
  strings[5] = "C"
  strings[6] = "c"

function calc() end
function storeAns() end

local menu = {
  { "Solve",
    { "Calculate", calc },
    { "Store", storeAns }
  }
}

toolpalette.register(menu)
toolpalette.enable("Solve", "Calculate", true)

function Input:init(x, y, h, w, text)
  self.x = x
  self.y = y
  self.h = h
  self.w = w
  self.text = text

  self.editor = D2Editor.newRichText()
  self.editor
    :setTextColor(0x000000)
    :setText(self.text)
    :setFontSize(12)
    :setVisible(true)
    :setDisable2DinRT(true)
    :setColorable(false)
    :move(self.x, self.y)
    :resize(self.w, self.h)
    :registerFilter{
      tabKey = on.tabKey,
      enterKey = on.tabKey,
      backtabKey = on.backtabKey
    }
end

function on.paint(gc)

--  Draw background rectangle
  gc:setColorRGB(232, 232, 232)
  gc:fillRect(0, 0, w, h/2)

  gc:setColorRGB(0, 0, 0)
  gc:setFont("sansserif", "b", 12)

-- Draw input labels
  for i = 1, 6, 1 do
    local x, y
    if i % 2 == 0 then
      x = w/2
      y = (math.floor(i/2) - 1)*h/6
    else
      x = 0
      y = (math.floor(i/2))*h/6
    end

    y = (((h / 6) - gc:getStringHeight(strings[i].. " = ")) / 2) + y
    x = (((w / 8) - gc:getStringWidth(strings[i].. " = ")) / 2) + x

    gc:drawString(strings[i].." = ", x, y)
  end
end

function on.construction()

--  Draw input boxes
  for i = 1, 6, 1 do
    local x, y

    if i % 2 == 0 then
      x = w/2 + (w / 8)
      y = (math.floor(i/2) - 1)*h/6
    else
      x = 0 + (w / 8)
      y = (math.floor(i/2))*h/6
    end

    inputs[i] = Input(x, y, h/6, 3*w/8, "Blank")
  end

-- Set focus on first input box
  inputs[selector].editor:setFocus(true)
end

function on.tabKey()
  if selector>=6 then selector=1 else selector = selector+1 end
  print("Tabbed")
  for i = 1, 6, 1 do
    if i==selector then
      inputs[i].editor:setFocus(true)
    else
      inputs[i].editor:setFocus(false)
    end
  end
end

function on.backtabKey()
  if selector<=1 then selector = 6 else selector = selector-1 end
  print("BackTabbed")
  for i = 1, 6, 1 do
    if i==selector then
      inputs[i].editor:setFocus(true)
    else
      inputs[i].editor:setFocus(false)
    end
  end
end

function on.resize()
  w = platform.window:width()
  h = platform.window:height()

  for i = 1, 6, 1 do
    local x, y

    if i % 2 == 0 then
      x = w/2 + (w / 8)
      y = (math.floor(i/2) - 1)*h/6
    else
      x = 0 + (w / 8)
      y = (math.floor(i/2))*h/6
    end

    inputs[i].editor:move(x, y):resize(3*w/8, h/6)
  end

  platform.window:invalidate()

  print("resized")
end
