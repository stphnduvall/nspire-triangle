platform.apiLevel = "2.3"

local w = platform.window:width()
local h = platform.window:height()

local Input = class()
local inputs = {}
local selector = 1
local answers = { "Press Menu > Solve > Calculate" }

local strings = {}
  strings[1] = "a = "
  strings[2] = "A = "
  strings[3] = "b = "
  strings[4] = "B = "
  strings[5] = "c = "
  strings[6] = "C = "

function calc()
  -- Loop through input and store

  local numbers = {}
  for i = 1, 6, 1 do
    if inputs[i] ~= "" then numbers[i] = tonumber(inputs[i].editor:getText())
    else numbers[i] = null
    end
  end

  answers = solveTriangle(numbers[1], numbers[2], numbers[3], numbers[4], numbers[5], numbers[6])
  platform.window:invalidate(0, h/2, w, h/2)
end

function storeAns() end

local menu = {
  { "Solve",
    { "Calculate", calc },
    { "Store", storeAns }
  }
}

toolpalette.register(menu)
toolpalette.enable("Solve", "Calculate", true)

function Input:init(x, y, height, width, text)
  self.x = x
  self.y = y
  self.h = height
  self.w = width
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

    y = (((h / 6) - gc:getStringHeight(strings[i])) / 2) + y
    x = (((w / 8) - gc:getStringWidth(strings[i])) / 2) + x

    gc:drawString(strings[i], x, y)
  end

--  Draw answers and status
  do
    local x, y, width, height
    width = gc:getStringWidth(answers[1])
    height = gc:getStringHeight(answers[1])
    x = (w - width) / 2
    y = h/2

    gc:drawString(answers[1], x, y)

    if answers[2] ~= nil then
      for i = 2, 7, 1 do
        if type(answers[i]) == "table" then
          answers[i] = round(answers[i][1]) .. " or " .. round(answers[i][2])
        else
          answers[i] = round(answers[i])
        end
      end

      for i = 1, 6, 2 do
        width = gc:getStringWidth(strings[i] .. answers[i+1])
        y = y + height
        x = (w/2 - width) / 2
        gc:drawString(strings[i] .. answers[i + 1], x, y)
      end

      y = h/2
      for i = 2, 6, 2 do
        if type(answers[i+1]) == "table" then
          answers[i+1] = answers[i+1][1] .. " or " .. answers[i+1][2]
        end
        width = gc:getStringWidth(strings[i] .. answers[1+1])
        y = y + height
        x = (w/2 - width) / 2
        gc:drawString(strings[i] .. answers[i + 1], w/2 + x, y)
      end

    end
  end


end

function on.construction()

--  Draw input boxes
  for i = 1, 6, 1 do
    local x, y, v

    if i % 2 == 0 then
      x = w/2 + (w / 8)
      y = (math.floor(i/2) - 1)*h/6
    else
      x = 0 + (w / 8)
      y = (math.floor(i/2))*h/6
    end

    v = ((h/6) - 26 ) / 2

    inputs[i] = Input(x, y + v, 26, 3*w/8, "")
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
    local x, y, v

    if i % 2 == 0 then
      x = w/2 + (w / 8)
      y = (math.floor(i/2) - 1)*h/6
    else
      x = 0 + (w / 8)
      y = (math.floor(i/2))*h/6
    end

    v = ((h/6) - 26 ) / 2

    inputs[i].editor:move(x, y + v):resize(3*w/8, 26)
  end

  platform.window:invalidate()

  print("resized")
end

-- Math functions
bool_to_number = { [true] = 1, [false] = 0}

function solveTriangle(a, angA, b, angB, c, angC)
  local sides = (bool_to_number[a ~= null]) + (bool_to_number[b ~= null]) + (bool_to_number[c ~= null])
  local angles = (bool_to_number[angA ~= null]) + (bool_to_number[angB ~= null]) + (bool_to_number[angC ~= null])
  local status

  if (sides + angles ~= 3) then
    -- Throw an error for too much info
    print("Give exactly 3 pieces of information")
    do return { "Give exaclty 3 pieces of information", a, angA, b, angB, c, angC } end
  elseif (sides == 0) then
    -- throw an error for not enough sides
    print("Give at least one side length")
    do return { "Give at least one side length", a, angA, b, angB, c, angC } end
  elseif (sides == 3) then
    status = "Side Side Side (SSS) Triangle"

    if (a + b <= c) or (a + c <= b) or (b + c <= a) then
      print("No Solution")
      do return { "No solution", a, angA, b, angB, c, angC } end
    end

    -- Solve Angles
    angA = solveAngle(b, c, a)
    angB = solveAngle(c, a, b)
    angC = solveAngle(a, b, c)
    -- Calc area?

  elseif (angles == 2) then
    status = "ASA Triangle"

    -- Find missing angle
    if (angA == null) then angA = 180 - angB - angC end
    if (angB == null) then angB = 180 - angA - angC end
    if (angC == null) then angC = 180 - angA - angB end
    if (angA <= 0) or (angB <= 0 ) or (angC <= 0 ) then
      -- Throw error and escape out of here
      print("No Solution")
      do return { "No Solution", a, angA, b, angB, c, angC } end
    end

    local sinA = math.sin(degToRad(angA))
    local sinB = math.sin(degToRad(angB))
    local sinC = math.sin(degToRad(angC))

    -- Use law of sines to find sides
    local ratio
    if (a ~= null) then ratio = a / sinA end
    if (b ~= null) then ratio = b / sinB end
    if (c ~= null) then ratio = c / sinC end
    if (a == null) then a = ratio * sinA end
    if (b == null) then b = ratio * sinB end
    if (c == null) then c = ratio * sinC end

  elseif (angA ~= null and a == null) or (angB ~= null and b == null) or (angC ~= null and c == null) then
    status = "SAS Triangle"

    if(angA ~= null and angA >= 180) or (angB ~= null and angB >= 180) or (angC ~= null and angC >= 180) then
      -- Throw error escape out of here
      print("No Solution")
      do return { "No Solution", a, angA, b, angB, c, angC } end
    end

    if a == null then a = solveSide(b, c, angA) end
    if b == null then b = solveSide(c, a, angB) end
    if c == null then a = solveSide(a, b, angC) end
    if angA == null then angA = solveAngle(b, c, a) end
    if angB == null then angB = solveAngle(c, a, b) end
    if angC == null then angC = solveAngle(a, b, c) end

  else
    status = "SSA Triangle"
    local knownSide, knownAngle, partialSide

    if a ~= null and angA ~= null then knownSide = a  knownAngle = angA end
    if b ~= null and angB ~= null then knownSide = b  knownAngle = angB end
    if c ~= null and angC ~= null then knownSide = c  knownAngle = angC end

    if a ~= null and angA == null then partialSide = a end
    if b ~= null and angB == null then partialSide = b end
    if c ~= null and angC == null then partialSide = c end

    if knownAngle >= 180 then
      -- Throw error and escape out
      print("No solution")
      do return { "No Solution", a, angA, b, angB, c, angC } end
    end

    local ratio = knownSide / math.sin(degToRad(knownAngle))
    local temp = partialSide / ratio
    local partialAngle, unknownSide, unknownAngle

    if (temp > 1) or ((knownAngle >= 90) and (knownSide <= partialSide)) then
      -- Throw error and escape out
      print("No solution")
      do return { "No Solution", a, angA, b, angB, c, angC } end
    elseif (temp == 1) or (knownSide >= partialSide) then
      status = status .. ": Unique solution"
      partialAngle = radToDeg(math.asin(temp))
      unknownAngle = 180 - knownAngle - partialAngle
      unknownSide = ratio * math.sin(degToRad(unknownAngle))
    else
      status = status .. ": Two Solutions"
      local partialAngle0, unknownAngle0, unknownSide0, partialAngle1, unknownAngle1, unknownSide1

      partialAngle0 = radToDeg(math.asin(temp))
      partialAngle1 = 180 - partialAngle0

      unknownAngle0 = 180 - knownAngle - partialAngle0
      unknownAngle1 = 180 - knownAngle - partialAngle1

      unknownSide0 = ratio * math.sin(degToRad(unknownAngle0))
      unknownSide1 = ratio * math.sin(degToRad(unknownAngle1))

      partialAngle = {partialAngle0, partialAngle1 }
      unknownAngle = {unknownAngle0, unknownAngle1 }
      unknownSide = {unknownSide0, unknownSide1 }
    end

    if (a ~= null and angA == null) then angA = partialAngle end
    if (b ~= null and angB == null) then angB = partialAngle end
    if (c ~= null and angC == null) then angC = partialAngle end
    if (a == null and angA == null) then a = unknownSide  angA = unknownAngle end
    if (b == null and angB == null) then b = unknownSide  angB = unknownAngle end
    if (c == null and angC == null) then c = unknownSide  angC = unknownAngle end

  end

  return { status, a, angA, b, angB, c, angC }
end

function solveSide(a, b, locAngC)
  locAngC = degToRad(locAngC)
  if (locAngC > 0.001) then
    return math.sqrt(a * a + b * b - 2 * a * b * math.cos(locAngC))
  else
    return math.sqrt((a - b) * (a-b) + a * b * locAngC * locAngC * (1 - locAngC * locAngC / 12))
  end
end

function solveAngle(a, b, c)
  local temp = (a * a + b * b - c * c) / (2 * a * b)

  if (-1 <= temp and temp <= 0.9999999) then
    return radToDeg(math.acos(temp))
  elseif (temp <= 1) then
    return radToDeg(math.sqrt((c * c - (a - b) * (a - b)) / (a * b)))
  else
    print("No solution")
    return null
  end
end

function radToDeg(x)
  return x * (180 / math.pi)
end

function degToRad(x)
  return x * (math.pi / 180)
end

function round(x)
  return math.eval("round(" .. x .. ", 1)")
end