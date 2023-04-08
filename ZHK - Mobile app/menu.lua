--[[
main-file
local composer = require( "composer" )
display.setStatusBar( display.HiddenStatusBar )
math.randomseed( os.time() )
composer.gotoScene( "menu" )
--]]
local composer = require( "composer" )
local scene = composer.newScene()

local widget = require( "widget" )

local androidFilePicker = require "plugin.androidFilePicker"

local tile = require( "tilebg" )
local roundedRectAndShadow = require( "shadowRR" )

local isDevice = (system.getInfo("environment") == "device")
--local isDevice = true


local backGroup

local mainGroup, testsGroup, quizzScreen, quizzGame, kursesGroup, kursScreen, kursGroup 
local eventGroup, inNewsOverlay, oneNewsGroup
local chatlistGroup, msgGroup
local profileGroup, adminGroup

local uiGroup


local q = require("base")
local chat = require("chat")

local json = require( "json" )
local server


local c = {
	black = q.CL"000000",
	gray = q.CL"808080",
	gray2 = q.CL"DEDEDE",
	grayButtons = q.CL"ADB5BD",
	prewhite = q.CL"F9FAFB",
	ultrablack = q.CL"CCCCCC",
	blue = q.CL"0058EE",
	outline = q.CL"9F9F9F",
	white = q.CL"FFFFFF",
}

local mainLabel
local selected = false
local searchField
local toBotField


local nowScene = "menu"


local mainButton, eventButton, chatButton, profileButton
local closePCMenu = function() end
local closeCN = function() end
local closeEN = function() end

local function hideField(field, group)
  field.x = 10000
  timer.performWithDelay(10, function() 
    group.alpha = 0
  end)
end

local scenes = {"menu"}
local pops = {}
local downNavigateGroup
local function hideLayer(toScene)

  if nowScene==toScene then return end
	timer.performWithDelay( 1, function()
    print("hiding from "..nowScene.." to "..toScene)
    native.setKeyboardFocus( nil )
		
    if nowScene == "menu" then
      mainButton:setFillColor( unpack( c.grayButtons ) )
      q.event.group.off("menu-buttons")
    elseif nowScene == "chatlist" then
      chatButton:setFillColor( unpack( c.grayButtons ) )
      q.event.group.off("chatlist-buttons")
    elseif nowScene == "profile" then
      profileGroup.alpha = 0
      profileButton:setFillColor( unpack( c.grayButtons ) )
		end
    if toScene~="menu"
    and toScene~="chatlist"
    and toScene~="profile" then
      q.event.group.off(nowScene.."-buttons")
      scenes[#scenes+1] = toScene
      print("add scene", toScene, #scenes)
    end
    nowScene = toScene
	end )
end 
local function removePop()
  -- print(#pops,"pops")
  if #pops==1 then -- Если массив сейчас опустеет
    downNavigateGroup.alpha = 1 

    if scenes[1]=="menu" then
      mainButton:setFillColor( unpack( c.blue ) )
    elseif scenes[1]=="chatlist" then
      mainLabel.text="Чаты"
      chatButton:setFillColor( unpack( c.blue ) )
    end
  elseif #pops==0 then return end -- Если массив пустой
  -- if #pops==0 then return end
  print("remove pop",scenes[#scenes])
  q.event.group.remove(scenes[#scenes].."-buttons")
  
  print(q.printTable(scenes))  
  local i = #pops
  display.remove(pops[i])
  pops[i] = nil
  scenes[#scenes] = nil
  
  print(q.printTable(scenes))  
  q.event.group.on(scenes[#scenes].."-buttons")
  nowScene = scenes[#scenes]

  timer.performWithDelay( 1, function()

    native.setKeyboardFocus( nil )

  end )
end
local function removeAllPop()
  for i=#pops, 1, -1 do
    q.event.group.remove(scenes[#scenes].."-buttons")
    display.remove(pops[i])
    pops[i] = nil
    scenes[#scenes] = nil
  end  
  print(q.printTable(scenes))  

end

local to = {}

function to.getName( groupName )
  local i = 1
  local doo = true
  
  while doo do
    local noFound = true
    for j=1, #scenes do
      -- print(j.."# "..scenes[j].." /"..#scenes)
      if groupName..tostring(i) == scenes[j] then
        -- print("занято")
        i = i + 1
        noFound = false
        break
      end
    end
    if noFound then doo = false 
      -- print( groupName..tostring(i),"свободен")  
    end

  end
  return groupName..tostring(i)
end

function to.changeMain( groupName )
  q.event.group.off(scenes[1].."-buttons")
  if scenes[1]=="menu" then
    mainGroup.alpha = 0
  elseif scenes[1]=="chatlist" then
    chatlistGroup.alpha = 0
  elseif scenes[1]=="profile" then
    profileGroup.alpha = 0
  end

  hideLayer(groupName)
  removeAllPop()
  q.event.group.on(groupName.."-buttons")
  scenes = {groupName}
  pops = {}
end

function to.menu()
  to.changeMain("menu")
  mainGroup.alpha = 1
  mainLabel.alpha = 0
  mainButton:setFillColor( unpack( c.blue ) )
  downNavigateGroup.alpha = 1
  return true
end

function to.profGroup()
  local name = to.getName( "profGroup" )
  hideLayer(name)
  downNavigateGroup.alpha = 0
  return name
end

function to.story()
  -- local name = to.getName( "profiesInVuz" )
  hideLayer("story")
  return name
end

function to.thisSpecInVuzes()
  local name = to.getName( "thisSpecInVuzes" )
  hideLayer(name)
  return name
end

function to.profInVuz()
  local name = to.getName( "profInVuz" )
  hideLayer(name)
  return name
end

function to.vuz()
  local name = to.getName( "vuz" )
  hideLayer(name)
  return name
end

function to.profiesInVuz()
  local name = to.getName( "profiesInVuz" )
  hideLayer(name)
  return name
end

-- -- --

function to.chatlist()
  to.changeMain("chatlist")
  mainLabel.text = "Чаты"
  chatlistGroup.alpha = 1
  chatButton:setFillColor( unpack( c.blue ) )
  mainLabel.alpha = 1
  return true
end

function to.chat()
  local name = to.getName( "chat" )
  hideLayer(name)
  mainLabel.alpha = 1
  return name
end
-- -- --

function to.account()
  to.changeMain("profile")
  mainLabel.text = "Профиль"
  mainLabel.alpha = 1
  profileGroup.alpha = 1
  profileButton:setFillColor( unpack( c.blue ) )
  return true
end

-- -- --
local function textWithLetterSpacing(options, space, anchorX)
	space = space*.01 + 1
	if options.color==nil then options.color={1,1,1} end

	local j = 0
	local text = options.text 
	local width = 0
	local textGroup = display.newGroup()
	options.parent:insert(textGroup)
	for i=1, #text:gsub('[\128-\191]', '') do
		local char = text:sub(i+j,i+j+1)
    local bytes = {string.byte(char,1,#char)}

    if bytes[1]==208 or bytes[1]==209 then -- for russian char
      char = text:sub(i+j,i+j+1)
      j=j+1
    else  -- for english char
      char = char:sub(1,1)
    end
		local charLabel = display.newText( textGroup, char, options.x+width, options.y, options.font, options.fontSize )
		charLabel.anchorX=0
		width = width + (charLabel.width-1.5)*space
		charLabel:setFillColor( unpack(options.color) )
	end
	if anchorX then
		textGroup.x = -width*(anchorX)
	end
  return textGroup
end


local function jsonForUrl(val)
  return q.jsonForUrl( json.encode( val ) )
end


local function sendQuizz(name, quizz)
  if name==nil then name = quizz.title end
  local quests = jsonForUrl( quizz.questions )
  local answers = jsonForUrl( quizz.answers )
  local praises = jsonForUrl( quizz.praises )
  -- print(server)
  -- print("http://"..server.."/dashboard/testUpload.php?title="..name.."&questions="..quests.."&answers="..answers.."&praises"..praises)
  network.request( "http://"..server.."/dashboard/testUpload.php?title="..name.."&questions="..quests.."&answers="..answers.."&praises="..praises, "GET" )

end


local allQuizz = {}
local topMain


local quizzInfo = {}
local function startQuizz(event)
  if event.y>(q.fullh-125) or event.y<330 then return end
  q.event.group.off("testsButtons")
  searchField.x = -1000
	searchField.y = -1000

  quizzInfo = allQuizz[event.target.i]
  mainLabel.alpha = 0


  -- if quizzScreen==nil then quizzScreen = display.newGroup() uiGroup:insert(quizzScreen) quizzScreen:toBack( ) end
  -- local quizzGame = quizzScreen
  hideLayer("test")
  if quizzGame ~=nil then display.remove(quizzGame) quizzGame=nil end
  quizzGame = display.newGroup()
  quizzScreen:insert( quizzGame )

  local backGround = display.newRect(quizzGame, q.cx, q.cy, q.fullw, q.fullh)
  backGround.fill={.95}

  local grayBack = display.newRect( quizzGame, q.cx, 0, q.fullw, 370 )
  grayBack.anchorY=0
  grayBack.fill = {0}
  grayBack.alpha = .15

  local testwarnLabel = display.newText({
    parent = quizzGame,
    text = "Каркас теста.\nДизайн в разработке",
    x=30,
    y=100,
    font="roboto_r.ttf",
    align="left",
    fontSize=24*2,
  })
  testwarnLabel:setFillColor( 1 )
  testwarnLabel.anchorX=0
  testwarnLabel.anchorY=0

  local whiteTop = display.newRect( quizzGame, q.cx, 0, q.fullw, 80 )
  whiteTop.anchorY=0

  local countLabel = display.newText({
    parent = quizzGame,
    text = "Вопрос 1/4",
    x=30,
    y=40,
    font="ubuntu_m.ttf",
    fontSize=24*2,
  })
  countLabel:setFillColor( 0 )
  countLabel.anchorX=0


  local butWidth = 335
  local butHeight = 220
  local butY = 840
  local backQuest = display.newRoundedRect(quizzGame, q.cx, 600,q.fullw-100, 320,30)
  backQuest.fill=q.CL"6120FF"

  local backL1 = display.newRoundedRect(quizzGame, q.fullw*.25+15, butY, butWidth,butHeight,30)
  backL1.anchorY=0
  backL1.fill=q.CL"1CD0FF"

  local backL2 = display.newRoundedRect(quizzGame, q.fullw*.25+15, butY+butHeight+35, butWidth,butHeight,30)
  backL2.anchorY=0
  backL2.fill=q.CL"1D91FF"

  local backR1 = display.newRoundedRect(quizzGame, q.fullw*.75-15, butY, butWidth,butHeight,30)
  backR1.anchorY=0
  backR1.fill=q.CL"00C2FF"

  local backR2 = display.newRoundedRect(quizzGame, q.fullw*.75-15, butY+butHeight+35, butWidth,butHeight,30)
  backR2.anchorY=0
  backR2.fill=q.CL"346BFF"
  
  backL1.i=1
  backL2.i=2
  backR1.i=3
  backR2.i=4

  local labelQuest = display.newText( {
    parent = quizzGame, 
    text ="Многократно повторяющаяся часть алгоритма", 
    x = q.cx, 
    y = backQuest.y, 
    font = "roboto_m.ttf",
    fontSize = 50,
    align = "center",
    width = backQuest.width-100
    })

  local labelL1 = display.newText( {
    parent = quizzGame, 
    text ="Объявления", 
    x = backL1.x, 
    y = backL1.y+backL1.height*.5, 
    font = "roboto_r.ttf",
    fontSize = 40,
    align = "center",
    width = backL1.width
    })

  local labelL2 = display.newText( {
    parent = quizzGame, 
    text ="Циклы", 
    x = backL2.x, 
    y = backL2.y+backL2.height*.5, 
    font = "roboto_r.ttf",
    fontSize = 40,
    align = "center",
    width = backL2.width
    })

  local labelR1 = display.newText( {
    parent = quizzGame, 
    text ="Условное выражение", 
    x = backR1.x, 
    y = backR1.y+backR1.height*.5, 
    font = "roboto_r.ttf",
    fontSize = 40,
    align = "center",
    width = backR1.width
    })

  local labelR2 = display.newText( {
    parent = quizzGame, 
    text ="Переменная", 
    x = backR2.x, 
    y = backR2.y+backR2.height*.5, 
    font = "roboto_r.ttf",
    fontSize = 40,
    align = "center",
    width = backR2.width
    })
  local backs = {
    backL1,
    backL2,
    backR1,
    backR2
  }

  local curretI = 0
  local questionsComplete = 0

  local rezult = {}
  for i=1, #quizzInfo.praises.names do
    rezult[i] = 0
  end
  local waitAnswer
  local function checkCorrect(event)
  	local i = event.target.i
    -- if i==correctNow then
      -- event.target.fill=q.CL"93d9a6"
      questionsComplete = questionsComplete + 1
      local plus = quizzInfo.answers[curretI].balance[i]
      -- print( q.printTable(plus) )
      for i=1, #rezult do
        if plus[i] then
          rezult[i] = rezult[i] + plus[i]
        end
        
      end
      -- print(curretI,i,plus[1],plus[1])
    -- else
    --   event.target.fill=q.CL"e9625a"
    --   backs[correctNow].fill=q.CL"93d9a6"
    -- end
    backL1:removeEventListener( "tap", checkCorrect )
    backL2:removeEventListener( "tap", checkCorrect )
    backR1:removeEventListener( "tap", checkCorrect )
    backR2:removeEventListener( "tap", checkCorrect )
    waitAnswer()
    -- timer.performWithDelay(1000, waitAnswer)
  end
  local function finish()
    display.remove(grayBack)
    countLabel.text = "Результаты"
    backQuest.y = 300
    labelQuest.y = 300
    backL1.alpha = 0
    backL2.alpha = 0
    backR1.alpha = 0
    backR2.alpha = 0

    labelL1.alpha = 0
    labelL2.alpha = 0
    labelR1.alpha = 0
    labelR2.alpha = 0

    local man = display.newImageRect( quizzGame, "img/man.png", 442, 1312 )
    man.x, man.y = 50, q.fullh-180
    man.anchorX, man.anchorY = 0, 1
    man.xScale, man.yScale = .58, .58
    man.alpha = .7

		local sum = 0
		local topMost = {}
    -- print( q.printTable(rezult) )
		for i=1, #rezult do
			sum = sum + rezult[i]
			topMost[i] = {i,(rezult[i] + 1) - 1}
		end

		local a = function (a, b) return (a[2] > b[2]) end
		table.sort (topMost, a)
    -- print( q.printTable(topMost) )
		-- print("the best",topMost[1][1],topMost[1][2])

		local finishLabel = ""
    local labels = {}
    for j=1, #rezult do
      local i = topMost[j][1]
      -- print(i,"i")
			labels[j] = display.newText( {
        parent = quizzGame,
        text = quizzInfo.praises.names[i].." "..q.round(rezult[i]/sum*100).."%\n",
        x=0,
        y=0,
        font="roboto_m.ttf",
        fontSize=20*2,
		  } )
      labels[j]:setFillColor( unpack( q.CL"503CFF" ) )
      labels[j].anchorX = 0
    end

    local labelCoords = {
      {
        x = 320,
        y = q.fullh-750,
      },
      {
        x = 340,
        y = q.fullh-750+110,
      },
      {
        x = 305,
        y = q.fullh-750+220,
      },
    }
    for i=1, #labels do
      labels[i].x = labelCoords[i].x
      labels[i].y = labelCoords[i].y
    end

    labelQuest.text = quizzInfo.praises.long[topMost[1][1]]

    local exitBut = display.newRoundedRect(quizzGame, q.fullw-50, q.fullh-250, 400, 110,30)
    exitBut.anchorX=1
    exitBut.fill=q.CL"6120FF"

    local okLabel = display.newText( {
      parent = quizzGame,
      text = "OK",
      x=exitBut.x-exitBut.width*.5,
      y=exitBut.y,
      font="roboto_m.ttf",
      fontSize=20*2,
    } )
    okLabel:setFillColor( 1 )


    exitBut:addEventListener( "tap", toMenu )

  
  end
  waitAnswer = function()
    curretI = curretI + 1
    local i = curretI
    
    -- backL1.fill = q.CL"1E3090"
    -- backL2.fill = q.CL"1E3090"
    -- backR1.fill = q.CL"1E3090"
    -- backR2.fill = q.CL"1E3090"
    if i>#quizzInfo.answers then
      finish() return
    end
    countLabel.text = "Вопрос "..i.."/"..#quizzInfo.questions

    correctNow = quizzInfo.answers[i][5]
    labelQuest.text = quizzInfo.questions[i]
    labelL1.text = quizzInfo.answers[i].text[1]
    labelL2.text = quizzInfo.answers[i].text[2]
    labelR1.text = quizzInfo.answers[i].text[3]
    labelR2.text = quizzInfo.answers[i].text[4]
    
    backL1:addEventListener( "tap", checkCorrect )
    backL2:addEventListener( "tap", checkCorrect )
    backR1:addEventListener( "tap", checkCorrect )
    backR2:addEventListener( "tap", checkCorrect )
  end
  waitAnswer()
  -- finish()
end

local kursesInfo = {

}
local function videoListener( event )
  -- print( "Event phase: " .. event.phase )
  if event.errorCode then
      native.showAlert( "Error!", event.errorMessage, { "OK" } )
  end
end
local allToms = {}
-- print( json.encode(allToms[4].tomes))


local function statisticResponder(event)
  if ( event.isError)  then
    print( "statistic load error:", event.response)
  else
    local myNewData = event.response
    -- print("Users ",myNewData)
    local statAll = json.decode( myNewData )
    local stat = statAll["1"]
    statGraf = statAll["2"]
    
    
    local sum = 0
    for i=1, #stat do
      sum = sum + stat[i]
    end
    local working = q.round(sum/#stat*100)
    local notWorking = 100 - working
    -- print("stat",#stat,sum)

    workingLabel = display.newText({
      parent = adminGroup,
      text = "- Занятых "..working.."%",
      x=290,
      y=180,
      font = "ubuntu_m.ttf",
      fontSize = 16*2} )
    workingLabel:setFillColor( unpack( c.black) )
    workingLabel.anchorX=0

    notWorkingLabel = display.newText({
      parent = adminGroup,
      text = "- Безработных "..notWorking.."%",
      x=130,
      y=370,
      font = "ubuntu_m.ttf",
      fontSize = 16*2} )
    notWorkingLabel:setFillColor( unpack( c.black) )
    notWorkingLabel.anchorX=0

    local statLabel = display.newText( {
      parent = adminGroup,
      text = "Трудоустроено за сутки",
      x = 35,
      y = 530,
      font = "ubuntu_m.ttf",
      fontSize = 20*2,
      } )

    statLabel:setFillColor( unpack( c.black) )
    statLabel.anchorX = 0
    
    statistic = working
  end
end

local function createTextFiled(x,y,paramText,ParamField)
  
  local label = display.newText( paramText.group, "-", x, y, paramText.font, paramText.fontSize)
  label:setFillColor(unpack(paramText.textColor))
  label.anchorX=0
  local oneSize = label.width
  label.text = paramText.text
  
  local back = display.newRect(paramText.group, label.width, y, label.width, label.height)
  back.anchorX=0
  back.fill = paramText.textColor

  local Field = native.newTextField(x+label.width+10, y, 400, 110)
  ParamField.group:insert( Field )
  Field.anchorX=0

  for k, v in pairs(ParamField.auto) do
    Field[k] = v
  end
  Field.height=label.height
  firldsTable[ParamField.key] = Field
  display.remove(label)
end

local incorrectChange
local function showPassWarning(text, time)
  timer.cancel( "passwarn" )
  transition.cancel( "passwarn" )
  
  time = time~=nil and time or 2000
  incorrectChange.text=text
  incorrectChange.alpha=1
  incorrectChange.fill.a=1
  timer.performWithDelay( time, 
  function()
    transition.to(incorrectChange.fill,{a=0,time=500, tag="passwarn"} )
  end, 1, "passwarn")
end
local function changeResponder(event)
  if ( event.isError) then
    print( "Change password server error:", event.response)
  else
    local myNewData = event.response
    -- print("Server:"..myNewData)
    if myNewData=="Incorrect\n\n\n" then
      showPassWarning("Текущий пароль не верен")
    elseif myNewData=="PasswordChanged\n\n\n" then
      -- showPassWarning("Пароль изменён успешно!")
      closePCMenu()
    else
    -- elseif myNewData=="User not found\n\n\n" then
      showPassWarning("Упс.. Что-то пошло не так")
    end

  end
end

local function line(group, y, width, stroke, color)
  local line = display.newRoundedRect(group, q.cx, y, width or (q.fullw-110), stroke or (3*2), 50 )
  line.fill = color or q.CL"EEEEEE"
  return line
end



local function getLabelSize(options)
  -- print(options)
  local label = display.newText(options)
  local width = label.width
  local height = label.height
  display.remove(label)
  return width, height
end

-- local function textLineHeightControl(options,lineHeight)

-- end

-- local function generateThisKolledg(options)
--   local group = display.newGroup()
--   options.parent:insert(group)
--   group.y = options.y

-- end

local function moneySpaces(num)
  num = tostring( num )
  local spc = 0
  for i=#num-3, 1, -3 do
    local left = num:sub(1,i)
    local right = num:sub(i+1,-1)
    num = left .." "..right
  end
  return num
end

local function generateThisSpecButtons(options)
  local scrollView = widget.newScrollView(
    {
      top = options.y-30,
      left = 0,
      width = q.fullw,
      height = q.fullh-options.y+30,--100,
      scrollWidth = 0,
      scrollHeight = 0,
      horizontalScrollDisabled = true,
      -- verticalScrollDisabled = true,
      hideBackground = true,
    }
  )
  options.parent:insert( scrollView )

  local group = display.newGroup()
  scrollView:insert(group)
  group.y = 30
  ---

  local lastX = 30
  local lastY = 0
  local backs = {}
  -- for i=1, #options.buttonsInfo do
  for specNum, info in pairs(options.buttonsInfo) do
    -- local info = options.buttonsInfo[i]
    
    local miniLogoWidth = lastX
    if info.miniLogo then
      local miniLogo = display.newImageRect(group, info.miniLogo, 43*2, 43*2)
      miniLogo.anchorX, miniLogo.anchorY = 0, 0
      miniLogo.x, miniLogo.y = lastX + 25, lastY + 20

      miniLogoWidth = miniLogo.x + miniLogo.width
    end

    local label = display.newParagraph(info.label, 60,{
      font = "mont_sb",
      size = 15*2,
      align = "left",
      color = {0,0,0}
    })
    group:insert(label)
    label.x = (miniLogoWidth + 25) + 15 - 30
    label.y = lastY - 20
    label.anchorX, label.anchorY = 0, 0

    local text = ""
    if #info.vuzes==1 then
      text=info.vuzes[1]
    else
      text=#info.vuzes.." вуза"
    end
    text = text.." | "..info.specNum

    local disc = display.newText{
      parent = group,
      text = text,
      x = miniLogoWidth + 25 - 10,
      y = label.y + label.height + 25,
      font = "mont_m",
      fontSize = 15*2,
      align = "left",
      width = q.fullw - lastX*2 - (miniLogoWidth + 25 - 10)
    }
    disc.anchorX, disc.anchorY = 0, 0
    disc:setFillColor(0)
    disc.alpha = .375

    local photo = display.newRoundedRect(group, q.cx, disc.y + disc.height+30, q.fullw-lastX*2 - 50, 121*2, 12*2)
    photo.fill = {
      type = "image",
      filename = info.specPhoto
    }
    -- photo:setFillColor(.5)
    photo.anchorY = 0
    if info.specPhotoFill then
      photo:setFillColor(unpack(info.specPhotoFill))
    end

    local back = roundedRectAndShadow{
      parent = group, 
      x = lastX, 
      y = lastY, 
      width = q.fullw - lastX*2, 
      height = math.ceil(photo.y + photo.height+25 - lastY),
      shadeWidth = 7,
      cornerRadius = 12*2, 
      anchorX = 0, 
      anchorY = 0
    }
    back:toBack() 
    backs[specNum] = back.rect
    backs[specNum].options = {
      vuzes=info.vuzes,
      specNum=info.specNum
    }

    local function bigAndSmallText(y, text1, text2, text3)
      local label = display.newGroup()
      group:insert(label)
      label.x = q.fullw - lastX*2 - 20
      label.y = y

      local disc = display.newText{
        parent = label,
        text = text1,
        x = 0,
        y = 0,
        font = "mont_m",
        fontSize = 12*2,
      }
      disc.anchorX, disc.anchorY = 1, 0

      local num = display.newText{
        parent = label,
        text = text2,
        x = - disc.width - 5,
        y = 35,
        font = "mont_sb",
        fontSize = 16*2,
      }
      num.anchorX, num.anchorY = 1, 1

      if text3 then
        local ot = display.newText{
          parent = label,
          text = text3,
          x = num.x - num.width - 5,
          y = 0,
          font = "mont_m",
          fontSize = 12*2,
        }
        ot.anchorX, ot.anchorY = 1, 0
      end
      return label
    end

    if info.budget.ball then
      bigAndSmallText(photo.y + 60, "бал. бюджет", info.budget.ball, "от")
    end
    if info.platno.ball then
      bigAndSmallText(photo.y + 60 + 40, "бал. платно", info.platno.ball, "от")
    end

    if info.budget.mest then
      bigAndSmallText(photo.y + 60 + 40*2 + 10, "мест бюджет", info.budget.mest)
    end
    if info.platno.mest then
      bigAndSmallText(photo.y + 60 + 40*3 + 10, "мест платно", info.platno.mest)
    end

    local payLabel = bigAndSmallText(photo.y + 60 + 40*3 + 10, "₽/год", moneySpaces(info.pay), "от")
    payLabel.x = lastX + 50 + payLabel.width

    lastY = lastY + back.rect.height + 35
  end

  -- local scrollEndPoint = display.newRect( group, q.cx, group.y + group.height + 100, 20, 20)
  -- scrollEndPoint.fill = {1,0,0}
  return backs
end

local function generateProgBall(options)

  local group = display.newGroup()
  options.parent:insert(group)
  group.y = options.y
  
  --- ===== ---

  -- parent = allBalls,
  -- y = y + 50,
  
  --   ochno = true,
  --   pay = nil,
  --   ege = {
  --     {"Информатика и ИКТ", 44},
  --     {"Математика", 39},
  --     {"Русский язык", 40},
  --   },
  --   ball = {
  --     all = 163,
  --     middle = 54,
  -- },


  local lastX = 30

  local text = options.ochno and "Очно" or "Заочно"

  local topLabel = display.newText( group, text, lastX + 40,  35, "mont_sb", 16*2 )
  topLabel:setTextColor(0)
  topLabel.anchorX = 0
  topLabel.anchorY = 0

  if options.pay~=nil then
    local payLabel = display.newText( group, "от "..moneySpaces(options.pay).."р", q.fullw - lastX - 40,  35-5, "mont_sb", 17*2 )
    payLabel:setTextColor(0)
    payLabel.anchorX = 1
    payLabel.anchorY = 0
  end

  line(group, 90)

  local egeLabel = display.newText( group, "ЕГЭ (по приоритетам)", q.cx,  120, "mont_sb", 17.75*2 )
  egeLabel:setTextColor(0)
  egeLabel.anchorY = 0

  local predmetLabel = display.newText( group, "Предмет", lastX + 70,  egeLabel.y+70, "mont_m", 14.2*2 )
  predmetLabel:setTextColor(unpack(q.CL"B5B5B5"))
  predmetLabel.anchorX = 0
  predmetLabel.anchorY = 0

  local ballLabel = display.newText( group, "Балл", q.fullw - lastX - 160,  egeLabel.y+70, "mont_m", 14.2*2 )
  ballLabel:setTextColor(unpack(q.CL"B5B5B5"))
  ballLabel.anchorY = 0

  -- options.ege[#options.ege] = nil
  -- options.ege[#options.ege] = nil
  -- options.ege[#options.ege] = nil

  local verical = line(group, ballLabel.y, 45 + 67*#options.ege)
  -- verical.x = lastX + 70
  -- verical.fill = {1,0,0}
  verical.anchorX = 0
  verical.rotation = 90

  local leftPoint = 0
  local rightPoint = ballLabel.x-ballLabel.width*.5
  for i=1, #options.ege do
    local predmet = display.newText( group, options.ege[i][1], lastX + 70,  predmetLabel.y+67*(i), "mont_m", 14.2*2 )
    predmet:setTextColor(0)
    predmet.anchorX = 0
    predmet.anchorY = 0

    local ball = display.newText( group, options.ege[i][2], q.fullw - lastX - 160,  predmetLabel.y+67*(i), "mont_m", 14.2*2 )
    ball:setTextColor(0)
    ball.anchorY = 0

    leftPoint = leftPoint>(predmet.x + predmet.width) and leftPoint or (predmet.x + predmet.width)
    rightPoint = rightPoint<(ball.x-ball.width*.5) and rightPoint or (ball.x-ball.width*.5)
  end

  local space = rightPoint - leftPoint
  
  local center = leftPoint + space*.5
  verical.x = center
  
  -- leftPoint = leftPoint + 40 -- расстояние от линии слева
  -- if q.cx<leftPoint then
    -- verical.x = leftPoint
  -- end
  local prevYear = tonumber(os.date("%Y")) - 1

  local atestBallLabel = display.newText( group, "Проходной балл ("..prevYear..")", q.cx,  verical.y + verical.width + 35, "mont_sb", 17.75*2 )
  atestBallLabel:setTextColor(0)
  atestBallLabel.anchorY = 0

  local officealLabel = display.newText( group, "Полный", lastX + 70,  atestBallLabel.y+80, "mont_m", 14.2*2 )
  officealLabel:setTextColor(0)
  officealLabel.anchorX = 0
  officealLabel.anchorY = 0

  local inmiddleLabel = display.newText( group, "В среднем", lastX + 70,  officealLabel.y+67, "mont_m", 14.2*2 )
  inmiddleLabel:setTextColor(0)
  inmiddleLabel.anchorX = 0
  inmiddleLabel.anchorY = 0

  local leftPoint = officealLabel.x + officealLabel.width
  local rightPoint = q.fullw

  local ball = {options.ball.all,options.ball.middle}
  for i=1, 2 do
    local ball = display.newText( group, ball[i] and "от "..ball[i] or "---", q.fullw - lastX - 160,  atestBallLabel.y+80+67*(i-1), "mont_m", 14.2*2 )
    ball:setTextColor(0)
    ball.anchorY = 0

    rightPoint = rightPoint<(ball.x-ball.width*.5) and rightPoint or (ball.x-ball.width*.5)
  end

  local vertical = line(group, officealLabel.y, 45 + 67)
  vertical.anchorX = 0
  vertical.rotation = 90

  local space = rightPoint - leftPoint
  
  local center = leftPoint + space*.5 
  vertical.x = center

  local back = roundedRectAndShadow{
    parent = group, 
    x = lastX, 
    y = 0, 
    width = q.fullw - lastX*2, 
    height = math.ceil(vertical.y + vertical.width + 40),
    shadeWidth = 7,
    cornerRadius = 12*2, 
    anchorX = 0, 
    anchorY = 0
  }
  back:toBack()

  return group
end

local function generateEgeBall(options)

  local group = display.newGroup()
  options.parent:insert(group)
  group.y = options.y
    
  local lastX = 0
  local space = 40

  local yearLabel = display.newText( group, "Год", 45,  40, "mont_m", 16*2 )
  yearLabel:setTextColor(unpack(q.CL"B5B5B5"))
  yearLabel.anchorX = 0
  yearLabel.anchorY = 0

  local budgetLabel = display.newText( group, "Бюджет", 45, yearLabel.y+space+30, "mont_m", 16*2 )
  budgetLabel:setTextColor(0)
  budgetLabel.anchorX = 0
  budgetLabel.anchorY = 0

  local platnoLabel = display.newText( group, "Платное", 45, budgetLabel.y+space+30, "mont_m", 16*2 )
  platnoLabel:setTextColor(0)
  platnoLabel.anchorX = 0
  platnoLabel.anchorY = 0

  local lastX = platnoLabel.x + platnoLabel.width + 70 + 35

  local lastYear = tonumber(options.balls.lastYear)
  for i=1, 4 do
    local yearLabel = display.newText({
      parent = group,
      text = tostring( lastYear ),
      x = lastX,
      y = yearLabel.y,
      font = "mont_m",
      fontSize = 16*2,
    })
    yearLabel:setTextColor(unpack(q.CL"B5B5B5"))
    -- yearLabel.anchorX = 0
    yearLabel.anchorY = 0

    local budBallLabel = display.newText({
      parent = group,
      text = options.balls.budget[5-i],
      x = lastX,
      y = budgetLabel.y,
      font = "mont_m",
      fontSize = 16*2,
    })
    budBallLabel:setTextColor(0)
    -- budBallLabel.anchorX = 0
    budBallLabel.anchorY = 0

    local platBallLabel = display.newText({
      parent = group,
      text = options.balls.platno[5-i],
      x = lastX,
      y = platnoLabel.y,
      font = "mont_m",
      fontSize = 16*2,
    })
    platBallLabel:setTextColor(0)
    -- budBallLabel.anchorX = 0
    platBallLabel.anchorY = 0

    if i~=4 then
      local verical = line(group, yearLabel.y, (platnoLabel.y + platnoLabel.height)-yearLabel.y)
      verical.x = lastX + 130*.5
      verical.anchorX = 0
      verical.rotation = 90

      lastX = lastX + 130
      lastYear = lastYear-1
    end
  end


  return group
end


local allSpec = {
  ["11.03.01"] = "Инфокоммуникационные технологии и системы связи",
  ["11.03.02"] = "Электроника и наноэлектроника",
  ["11.03.04"] = "Программирование и электроника информационных систем",
  ["11.03.99"] = "Фундаментальная информатика и информационные технологии",
  ["21.05.02"] = "Физическая география и ландшафтоведение",

}

local predmetsRus = {
  rus = "Русский язык",
  matem = "Математика",
  physics = "Физика",
  chemi = "Химия",
  history = "История",
  social = "Обществознание",
  info = "Информатика и ИКТ",
  bio = "Биология",
  geo = "География",
  
  eng = "Английский язык",
  ger = "Немецкий язык",
  frc = "Французский язык",
  jap = "Китайский язык",
  spn = "Испанский язык",
}

local vuzes = {
  {
    nameFullRu = "Якутский колледж инновационных технологий",
    nameShortRu = "ЯКИТ",
    nameEn = "yakit",
    gos = true,

    site = "https://yakit.ru/",
    email = "yakit10@mail.ru",
    phone = "8 (4112) 36-97-92",
    adress = "Якутск, ул. Ларионова, 4",
    -- mapCoords = "129.762586,129.752628",

    egeStat = {
      lastYear = "2022",
      budget = { "71.2","77.4","80.5","71.9"},
      platno = { "54.9","61.4","57.4","55.8"},
    },
    spec = {
      {
        specNum = "11.03.99",
        month = "48",
        ege = {
          predmeti = {"info","matem","rus"},
          ball = {
            ochnoBudget = {"1","2","3"},
            zaochnoBudget = {"4","5","6"},
            
            ochnoPlatno = {"7","8","9"},
            zaochnoPlatno = {"10","11","12"},
          },
        },
        mest = {
          budget = "97",
          platno = "50",
        },
        ball = {
          middleBudgetOchno = "97",
          middlePlatnoOchno = "50",

          middleBudgetZaochno = "97",
          middlePlatnoZaochno = "50",

          allBudgetOchno = "194",
          allBudgetZaochno = "194",

          allPlatnoOchno  = "194",
          allPlatnoZaochno  = "194",
        },
        pay = {
          ochno = "250000",
          zaochno = "188000",
        },
      },
      {
        specNum = "11.03.02",
        month = "48",

        ege = {
          predmeti = {"info","matem","rus"},
          ball = {
            ochnoBudget = {"1","2","3"},
            zaochnoBudget = {"4","5","6"},
            
            ochnoPlatno = {"7","8","9"},
            zaochnoPlatno = {"10","11","12"},
          },
        },
        mest = {
          budget = "97",
          platno = "50",
        },
        ball = {
          middleBudgetOchno = "97",
          middlePlatnoOchno = "50",

          middleBudgetZaochno = "97",
          middlePlatnoZaochno = "50",

          allBudgetOchno = "194",
          allBudgetZaochno = "194",

          allPlatnoOchno  = "194",
          allPlatnoZaochno  = "194",
        },
        pay = {
          ochno = "250000",
          zaochno = "188000",
        },
      }
      -- {
      --   specNum = "11.03.99",
      --   predmeti = {"info","matem","rus"},

      --   ochno = {
      --     platno = {
      --       month = "48",
      --       mest = "50",
      --       egeBall = {"7","8","9"},
      --       middleball = "50",
      --       allball = "194",
      --       pay = "250000",
      --     },
      --     budget = {

      --       month = "48",
      --       mest = "97",
      --       egeBall = {"1","2","3"},
      --       middleball = "50",
      --       allball = "194",
      --     }
      --   },

      --   zaochno = {
      --     platno = {

      --       month = "48",
      --       mest = "50",
      --       egeBall = {"10","11","12"},
      --       middleball = "50",
      --       allball = "194",
      --       pay = "188000"
      --     },
      --     budget = {
            
      --       month = "48",
      --       mest = "97",
      --       egeBall = {"4","5","6"},
      --       middleball = "50",
      --       allball = "194",
      --     }
      --   }
      -- }
    }
  },
  {
    nameFullRu = "Ленский технологический техникум \"Пеледуйский\" филиал",
    nameShortRu = "ЛТХ",
    nameEn = "lth",
    site = "https://lensktekh.ru/index.html",
    email = "ltt_lensk@gov14.ru",
    phone = "8 (4113) 72-31-29",
    adress = "Ленск, Республика Саха (Якутия), Нюйская, 14",
    gos = true,
    egeStat = {
      lastYear = "2022",
      budget = { "71.2","77.4","80.5","71.9"},
      platno = { "54.9","61.4","57.4","55.8"},
    },
    spec = {
      {
        specNum = "11.03.01",
        month = "48",
        ege = {
          predmeti = {"info","matem","rus"},
          ball = {
            ochnoBudget = {"55","32","13"},
            zaochnoBudget = {"43","45","63"},
            
            ochnoPlatno = {"7","8","9"},
            zaochnoPlatno = {"10","11","12"},
          },
        },
        mest = {
          budget = "97",
          platno = "50",
        },
        ball = {
          middleBudgetOchno = "68",
          middleBudgetZaochno = "47",

          middlePlatnoOchno = "52",
          middlePlatnoZaochno = "47",

          allBudgetOchno = "194",
          allBudgetZaochno = "194",

          allPlatnoOchno  = "194",
          allPlatnoZaochno  = "194",
        },
        pay = {
          ochno = "232000",
          zaochno = "175000",
        },
      }
    }
  },
  {
    nameFullRu = "Институт математики и информатики СВФУ",
    nameShortRu = "ИМИ СВФУ",
    nameEn = "imisvfu",
    site = "https://www.s-vfu.ru/universitet/obrazovanie/vuzovskoe/institut-matematiki-i-informatiki.php",
    email = "priem@s-vfu.ru",
    phone = "+7 (4112) 49-69-62",
    adress = "Якутск, ул. Кулаковского, 48",
    gos = true,
    egeStat = {
      lastYear = "2022",
      budget = { "71.2","77.4","80.5","71.9"},
      platno = { "54.9","61.4","57.4","55.8"},
    },
    spec = {
      {
        specNum = "11.03.02",
        month = "48",
        ege = {
          predmeti = {"info","matem","rus"},
          ball = {
            ochnoBudget = {"1","2","3"},
            zaochnoBudget = {"4","5","6"},
            
            ochnoPlatno = {"7","8","9"},
            zaochnoPlatno = {"10","11","12"},
          },
        },
        mest = {
          budget = "97",
          platno = "50",
        },
        ball = {
          middleBudgetOchno = "97",
          middlePlatnoOchno = "54",

          middleBudgetZaochno = "64",
          middlePlatnoZaochno = "49",

          allBudgetOchno = "194",
          allBudgetZaochno = "194",

          allPlatnoOchno  = "194",
          allPlatnoZaochno  = "194",
        },
        pay = {
          ochno = "126000",
          zaochno = "110000",
        },
      }
    }
  },
  {
    nameFullRu = "Южно-Якутский технологический колледж",
    nameShortRu = "ЮЯТК",
    nameEn = "yuyatk",
    site = "https://юятк.рф/",
    email = "uytk_nerungri@gov14.ru",
    phone = "8 (4114) 74-84-47",
    adress = "Нерюнгри, Республика Саха (Якутия), ул. Кравченко, 16/1",
    gos = true,
    egeStat = {
      lastYear = "2022",
      budget = { "71.2","77.4","80.5","71.9"},
      platno = { "54.9","61.4","57.4","55.8"},
    },
    spec = {
      {
        specNum = "11.03.02",
        month = "48",
        ege = {
          predmeti = {"info","matem","rus"},
          ball = {
            ochnoBudget = {"1","2","3"},
            zaochnoBudget = {"4","5","6"},
            
            ochnoPlatno = {"7","8","9"},
            zaochnoPlatno = {"10","11","12"},
          },
        },
        mest = {
          platno = "50",
        },
        ball = {
          middleBudgetOchno = "97",
          middlePlatnoOchno = "50",

          middleBudgetZaochno = "97",
          middlePlatnoZaochno = "50",

          allBudgetOchno = "194",
          allBudgetZaochno = "194",

          allPlatnoOchno  = "194",
          allPlatnoZaochno  = "194",
        },
        pay = {
          ochno = "198000",
          zaochno = "160000",
        },
      }
    }
  },
  {
    nameFullRu = "Чурапчинский аграрно-технический колледж",
    nameShortRu = "ЧУТК",
    nameEn = "chutk",
    site = "http://churcollege.ru/index.php",
    email = "abitura.colleg@mail.ru",
    phone = "8 (4115) 14-21-92",
    adress = "Чурапча, ул Нидьили 4",
    gos = true,
    egeStat = {
      lastYear = "2022",
      budget = { "71.2","77.4","80.5","71.9"},
      platno = { "54.9","61.4","57.4","55.8"},
    },
    spec = {
      {
        specNum = "21.05.02",
        month = "48",
        ege = {
          predmeti = {"info","matem","rus"},
          ball = {
            ochnoBudget = {"1","2","3"},
            zaochnoBudget = {"4","5","6"},
            
            ochnoPlatno = {"7","8","9"},
            zaochnoPlatno = {"10","11","12"},
          },
        },
        mest = {
          platno = "49",
          budget = "28",
        },
        ball = {
          middleBudgetOchno = "97",
          middlePlatnoOchno = "50",

          middleBudgetZaochno = "97",
          middlePlatnoZaochno = "50",

          allBudgetOchno = "194",
          allBudgetZaochno = "194",

          allPlatnoOchno  = "194",
          allPlatnoZaochno  = "194",
        },
        pay = {
          ochno = "78000",
          zaochno = "65000",
        },
      }
    }
  }
}

local function getFirstSumb(text,i)
  return text:sub(1,i)
end

local function mouthToYear(mouth)
  return q.round(mouth/12)
end

local function deepcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
        copy[deepcopy(orig_key)] = deepcopy(orig_value)
    end
    setmetatable(copy, deepcopy(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

local function getVuzesWithSpecNum( specNum )
  if type(specNum)~="string" then error("bad argument #1 (string expected, got ".. type(specNum) ..")") end
  if #specNum==6 and allSpec[specNum]==nil then error("bad argument #1 (spec ".. (specNum) .." not found)") end

  local vuzes = deepcopy(vuzes)
  local get = getFirstSumb
  local num = #specNum
  local out = {}
  for index,vuz in pairs(vuzes) do
    
    local add = {}
    local tempSpec = vuz.spec
    for i=1, #tempSpec do
      if (get(tempSpec[i].specNum,num)):find(specNum) then
        -- print("add vuz: "..vuz.nameShortRu)
        -- print("cause: "..specNum.." found in "..get(tempSpec[i].specNum,num))
        add[#add+1] = tempSpec[i]
      end
    end

    if #add~=0 then
      vuz.sortedSpec = add
      vuz.spec = nil
      out[#out+1] = vuz
    end
  
  end
  return out
end

local function getVuzByName( nameEn )
  local vuz 
  for i=1, #vuzes do
    if vuzes[i].nameEn == nameEn then
      vuz = deepcopy(vuzes[i])
      break
    end
  end
  return vuz
end

local popUp
local newPopUp
local function standartPopUp()

  newPopUp = display.newGroup()
  mainGroup:insert(newPopUp)
  pops[#pops+1] = newPopUp
  
  -- backGround.fill = {.2}
  -- local backGround = tile("img/bg-2.png", q.fullw, q.fullh, q.fullw/5)
  -- popUp:insert(backGround)

  local backLight = display.newRect(newPopUp, q.cx, 0, q.fullw, q.fullh*2)
  backLight.anchorY = 0

  local forImage = display.newGroup()
  newPopUp:insert(forImage)
  forImage.x, forImage.y = q.cx, 162

  -- local image = display.newImageRect(forImage, "img/back/tech.png", q.fullw, 162*2)
  local image = display.newRect(forImage, 0, 0, q.fullw, 162*2)

  local toner = display.newRect(newPopUp, q.cx, 0, q.fullw, 162*2)
  toner.fill = q.CL"040F36"
  toner.alpha = .56
  toner.anchorY = 0

  local forLogo = display.newGroup()
  newPopUp:insert(forLogo)
  forLogo.x, forLogo.y = 80, 70

  -- local logo = display.newImageRect(forLogo, "img/icon/radio_white.png", 44*2, 35*2)
  local logo = display.newRect(forLogo, 0,0, 43*2, 43*2)

  -- local topLabel = display.newText({
  --   parent = newPopUp,
  --   text = "Заголовок",
  --   x = 14*2,
  --   y = 180,
  --   font = "mont_sb",
  --   fontSize = 20*2,
  --   align = "left",
  -- })
  -- topLabel.anchorX = 0

  local topLabel = display.newParagraph(("Заголовок должен быть не очень большим"):gsub("\n"," \n "), 55,{
    lineHeight = 1,
    font = "mont_sb",
    size = 20*2,
    align = "left",
  })
  newPopUp:insert( topLabel )
  topLabel.x = 14*2
  topLabel.y = 180 - topLabel.height

  local podTopLabel = display.newText({
    parent = newPopUp,
    text = "Подробности",
    x = 30*2,
    y = toner.height - 50,
    font = "mont_sb",
    fontSize = 13*2,
  })
  podTopLabel.anchorX = 0

  local grayBack = display.newRoundedRect(newPopUp, 30*2-34, podTopLabel.y, 34*2 + podTopLabel.width, 26*2, 28 )
  grayBack:setFillColor(unpack(q.CL"A3A3A3"))
  grayBack.alpha = .39
  grayBack.anchorX = 0

  podTopLabel:toFront()

  local bottomToner = display.newRect(newPopUp, q.cx, toner.height, q.fullw, 126*2)
  bottomToner.fill = {.5}
  bottomToner.anchorY = 0

  local front = tile("img/bg-2.png", q.fullw, bottomToner.height,  bottomToner.height, 0, 0)
  newPopUp:insert(front)
  front.x = 0
  front.y = bottomToner.y
  front.alpha = .51

  local firstBack = display.newRoundedRect(newPopUp, 30, front.y+bottomToner.height*.5, 123*2, 98*2, 12*2)
  firstBack:setFillColor(0, 0, 0, .16)
  firstBack.anchorX = 0

  local forH = display.newText( "Ф", 0, 0, "mont_m", 16*2)
  local oneHeight = forH.height
  display.remove(forH)

  local tonerTexts = {}
  local function labelAndDiscription(x, y, text1, text2, alpha)
    tonerTexts[#tonerTexts+1] = {}
    local label = display.newText(newPopUp, text1, x, y, "mont_sb", 22*2)
    label.anchorX = 0
    label.anchorY = 0
    tonerTexts[#tonerTexts][1] = label

    local disc = display.newText(newPopUp, text2, x, y + label.height - 5, "mont_m", 16*2)
    disc.anchorX = 0
    disc.anchorY = 0
    disc.alpha = alpha or 1
    tonerTexts[#tonerTexts][2] = disc

    return math.max(label.width, disc.width)
  end

  local y = firstBack.y - firstBack.height*.5 + 20
  local x = firstBack.x + 20

  labelAndDiscription(x, y, "Блок 1", "Описание")
  labelAndDiscription(x, y, "Блок 2", "Описание",.68)
  labelAndDiscription(x, y, "Блок 3", "Описание",.68)


  local function repositAllTexts(space)
    firstBack.width = 42.5 + math.max( tonerTexts[1][1].width, tonerTexts[1][2].width )
    
    local width = firstBack.x + firstBack.width + space
    tonerTexts[2][1].x = width
    tonerTexts[2][2].x = width 

    width = tonerTexts[2][1].x + math.max( tonerTexts[2][1].width, tonerTexts[2][2].width) + space
    tonerTexts[3][1].x = width
    tonerTexts[3][2].x = width

    -- ====== --

    if oneHeight>=tonerTexts[1][2].height then
      tonerTexts[1][1].y = y + 20
    else
      tonerTexts[1][1].y = y
    end
    tonerTexts[1][2].y = tonerTexts[1][1].y + tonerTexts[1][1].height - 5
  end
  repositAllTexts(25)

  local out = {
    logo = logo,
    specPhoto = image,
    topLabelSetText = function(text)
      display.remove(topLabel)
      local topLabel = display.newParagraph(text:gsub("\n"," \n "), 55,{
        lineHeight = 1.1,
        font = "mont_sb",
        size = 20*2,
        align = "left",
      })
      newPopUp:insert( topLabel )
      topLabel.x = 14*2
      topLabel.y = 180 - topLabel.height
    end,
    podTopSetText = function(text)
      podTopLabel.text = text
      grayBack.width = 34*2 + podTopLabel.width
    end,
    toner = bottomToner,
    tonerSetText = function(i,text1,text2,space)
      tonerTexts[i][1].text = text1
      tonerTexts[i][2].text = text2
      -- print(i)
      if i==3 then
        repositAllTexts(space or 25)
      end
    end,
    back = backLight
  }

  return newPopUp, bottomToner.y + bottomToner.height + 30, out

end
local openVUZ

local function specNumToNums(text)
  local n1 = tonumber(text:sub(1,2))
  local n2 = tonumber(text:sub(4,5))
  local n3 = tonumber(text:sub(7,8))
  return n1, n2, n3
end


local sortByGroup = {
  tech = {imagePath = "img/icon/radio.png", label = "Информационные\nтехнологии", specSort = "11.03"},
  agro = {imagePath = "img/icon/traktor.png", label = "Сельхоз", specSort = "21.05"},
  build = {imagePath = "img/icon/building.png", label = "Строительсво", specSort = "N"},
  medic = {imagePath = "img/icon/medical.png", label = "Медицина", specSort = "N"},
  economic = {imagePath = "img/icon/vesi.png", label = "Экономика\nЮрисприденция", specSort = "N"},
  transport = {imagePath = "img/icon/kovsh.png", label = "Транспорт", specSort = "N"},
  teaching = {imagePath = "img/icon/book.png", label = "Образование\nТворчество", specSort = "N"},
  secure = {imagePath = "img/icon/ship.png", label = "Безопасность", specSort = "N"},
  factory = {imagePath = "img/icon/honey.png", label = "Промышленость", specSort = "N"},
}

local sortSpec = {
  ["11.01.01"] = {imagePath = "img/icon/radio.png", label = "Информационные\nтехнологии"},
}

local function payMin(a,b,c)
  -- print("get:",a,b,c)
  local i
  if a and b and c then i=3
  elseif a and b then i=2
  elseif b and c then i=2; a=b; b=c; c=nil 
  elseif a and c then i=2; b=c; c=nil
  elseif a then i=1
  elseif b then i=1; a=b; b=nil
  elseif c then i=1; a=c; c=nil
  else i=0
  end
  -- print("not nil:",i)

  local min = a
  if i==0 then
    return nil
  elseif i==1 then
    -- print("min:",min,"\n==============")
    return min
  elseif i==2 then
    min = tostring(math.min( tonumber(min), tonumber(b) ))
    -- print("min:",min,"\n==============")
    return min
  elseif i==3 then
    min = tostring(math.min( tonumber(min), tonumber(b) ))
    min = tostring(math.min( tonumber(min), tonumber(c) ))
    -- print("min:",min,"\n==============")
    return min
  else error("wrong i:"..i) end
end


local function getButtonsInfo( vuzes, grouped )
  local buttonsInfo = {}
  for index, vuz in pairs(vuzes) do
    for i=1, #vuz.sortedSpec do
      local sorted = vuz.sortedSpec[i]
      local specNum = sorted.specNum
      local to = (grouped and specNum or #buttonsInfo+1)
      
      if buttonsInfo[to]==nil then

        local minBudget = payMin(sorted.ball.middleBudgetOchno, sorted.ball.middleBudgetZaochno)
        local minPlatno = payMin(sorted.ball.middlePlatnoOchno, sorted.ball.middlePlatnoZaochno)

        buttonsInfo[to] = {
          miniLogo = "img/icon/vuzes/"..vuz.nameEn..".png",
          label = allSpec[specNum],
          specNum = specNum,
          vuzes = {vuz.nameShortRu, eng=vuz.nameEn},
          specPhoto = (grouped and "img/spec/".. specNum:gsub("%.","/")..".png" or "img/kolledg/"..vuz.nameEn..".png"),
          specPhotoFill = nil,
          budget = {
            mest = sorted.mest.budget,
            ball = minBudget,
          },
          platno = {
            mest = sorted.mest.platno,
            ball = minPlatno,
          },
          pay = payMin(sorted.pay.ochno, sorted.pay.zaochno)
        }
      else
        local mas = buttonsInfo[to] 
        mas.miniLogo = "img/icon/chemodan.png"
        mas.vuzes[#mas.vuzes+1] = vuz.nameEn

        mas.pay = payMin(mas.pay, sorted.pay.ochno, sorted.pay.zaochno)

        if sorted.mest.budget then
          mas.budget.mest = tostring(tonumber(mas.budget.mest or 0) + tonumber(sorted.mest.budget))
        end
        if sorted.mest.platno then
          mas.platno.mest = tostring(tonumber(mas.platno.mest or 0) + tonumber(sorted.mest.platno)) 
        end

        local minBudget = payMin(sorted.ball.middleBudgetOchno, sorted.ball.middleBudgetZaochno)
        if minBudget then
          mas.budget.ball = tostring(math.min(tonumber((mas.budget.ball~=nil) and mas.budget.ball or 10000),tonumber(minBudget))) 
        end

        local minPlatno = payMin(sorted.ball.middlePlatnoOchno, sorted.ball.middlePlatnoZaochno)
        if minPlatno then
          mas.platno.ball = tostring(math.min(tonumber((mas.platno.ball~=nil) and mas.platno.ball or 10000),tonumber(minPlatno)))
        end
      end
      
    
    end
  end
  return buttonsInfo
end

local function generateButtonWithLogo(options)
  if options.textWidth==nil then
    options.textWidth = getLabelSize({
      font = "mont_sb",
      fontSize = 15*2,
      text = options.text1
    })
  end
  local group = display.newGroup( )
  if options.parent then
    options.parent:insert(group)
  end
  group.x = options.x
  group.y = options.y

  local text = {
    font = "mont_sb",
    fontSize = 15*2,
  }
  local back = roundedRectAndShadow({
    parent = group, 
    x = 0, 
    y = 0, 
    width = 140+math.ceil(options.textWidth), 
    height = 66*2,
    shadeWidth = 7,
    cornerRadius = 12*2, 
    anchorX = 0, 
    anchorY = 0
  })
  group.back = back

  local icon = display.newImageRect(group, options.imagePath, 80, 80 )
  icon.x, icon.y = back.x - back.rect.width*.5, back.rect.height*.5
  icon.anchorX = 0
  icon.x = icon.x + 20


  text.parent = group
  text.x = icon.x + icon.width + 15
  text.y = icon.y - 20
  text.align = "left"

  local label = display.newParagraph(options.text1:gsub("\n"," \n "), 60,{
    lineHeight = 1,
    font = "mont_sb",
    size = text.fontSize,
    align = "left",
    color = {0,0,0}
  })
  group:insert( label )
  label.x = text.x
  label.y = text.y - label.height*.5 - 30


  text.text = options.text2
  text.y = text.y + label.height*.5 + 15
  text.font = "mont_m.ttf"
  local label = display.newText(text)
  label:setFillColor(0)
  label.anchorX = 0
  label.alpha = .35

  return group
end

local function generateMiniSpecButtons(options)

  local group = display.newGroup()
  options.parent:insert(group)
  group.y = options.y

  local bufferX = 35
  local bufferY = 30
  local startX = -10 + bufferX
  
  local height = 66*2

  local lastX = startX
  local lastY = 0
  local buttons = {}
  for k, v in pairs(options.buttons) do
    local text = options.buttons[k].label

    local textWidth = getLabelSize({
      font = "mont_sb",
      fontSize = 15*2,
      text = text
    })
    if (lastX + textWidth) >= (q.fullw - bufferX*2) then
      lastX = startX
      lastY = lastY + height + bufferY
    end
    local button = generateButtonWithLogo({
      parent = group,
      x = lastX,
      y = lastY,
      text1 = text,
      text2 = options.buttons[k].discrition,
      imagePath = options.buttons[k].imagePath,
      textWidth = textWidth,
    })
    buttons[k] = button
    -- button.specName = v
    -- q.event.add("to"..(v:upper()).."_"..info.name, button, openGroupSpec, "menu-buttons" )
   
    lastX = lastX + (140 + math.ceil(textWidth)) + bufferX
  end

  local scrollEndPoint = display.newRect(group, q.cx, lastY+320, 20, 20)

  return group, buttons
end



local function openProfiesInVuz( event )
  local eventGroupName = to.profiesInVuz()
  
  local vuz = deepcopy(event.target.vuz)
  local sumS = {
    programs = 0,
    mestB = 0,
    mestP = 0,
  }

  for i=1, #vuz.spec do
    local spec = vuz.spec[i]
    if spec.mest.budget~=nil then
      sumS.mestB = sumS.mestB + spec.mest.budget
      sumS.programs = sumS.programs + 2 ------============================== !!!!! добавить проверку есть ли очный и заочный
    end
    if spec.mest.platno~=nil then
      sumS.mestP = sumS.mestP + spec.mest.platno
      sumS.programs = sumS.programs + 2 ------============================== !!!!! добавить проверку есть ли очный и заочный
    end
  end
  
  local pop, y, config = standartPopUp()
  config.logo.fill = {
    type = "image",
    filename = "img/icon/vuzes/".. vuz.nameEn ..".png",
  }
  config.specPhoto.fill = {
    type = "image",
    filename = "img/kolledg/"..vuz.nameEn..".png"
  }
  config.topLabelSetText(vuz.nameFullRu)
  config.podTopSetText(vuz.gos and "Государтсвенный" or "Негосудартсвенный")
  config.toner.fill = q.CL"2C70D7"

  config.tonerSetText(1, tostring(sumS.programs), "Программ\nобучения")
  config.tonerSetText(2, tostring(sumS.mestB) or ("---"), "Бюджет.\nмест")
  config.tonerSetText(3, tostring(sumS.mestP) or ("---"), "Платных\nмест",36)



  -- local buttonsInfo = {
  --   {
  --     miniLogo = "img/icon/chemodan.png",
  --     label = "Программирование и электроника информационных систем",
  --     specNum = "11.03.04",
  --     vuzes = {"id1","id2"},
  --     specPhoto = "img/kolledg/spec.png",
  --     budget = {
  --       ball = "47",
  --       mest = "97",
  --     },
  --     platno = {
  --       ball = "41",
  --       mest = "50",
  --     },
  --     pay = "40478",
  --   },
  -- ball = {
    -- middleBudgetOchno = "97",
    -- middlePlatnoOchno = "50",

    -- middleBudgetZaochno = "97",
    -- middlePlatnoZaochno = "50",

    -- allBudgetOchno = "194",
    -- allBudgetZaochno = "194",

    -- allPlatnoOchno  = "194",
    -- allPlatnoZaochno  = "194",
  -- },
  vuz.sortedSpec = vuz.spec
  local buttonsInfo = getButtonsInfo({vuz}, false)
  for i=1, #buttonsInfo do
    buttonsInfo[i].specPhoto = "img/spec/".. buttonsInfo[i].specNum:gsub("%.","/")..".png"
    buttonsInfo[i].specPhotoFill = {.5,.5,.5}
  end

  local buttons = generateThisSpecButtons{
    parent = pop,
    y = y,
    buttonsInfo = buttonsInfo
  }

  for i=1, #buttonsInfo do
    q.event.add("toSpecInVuz-"..i.."_byVuz", buttons[i], openProfInVuz, eventGroupName.."-buttons")
  end
  q.event.group.on(eventGroupName.."-buttons")
end

local function openVuz( event )
  local options = event.target.options
  local eventGroupName = to.vuz()

  -- print(q.printTable(options))
  -- print("get options")

  local vuz = options.vuz--getVuzByName(options.vuzes.eng)
  local sumS = {
    programs = 0,
    mestB = 0,
    mestP = 0,
  }

  for i=1, #vuz.spec do
    local spec = vuz.spec[i]
    if spec.mest.budget~=nil then
      sumS.mestB = sumS.mestB + spec.mest.budget
      sumS.programs = sumS.programs + 2 ------============================== !!!!! добавить проверку есть ли очный и заочный
    end
    if spec.mest.platno~=nil then
      sumS.mestP = sumS.mestP + spec.mest.platno
      sumS.programs = sumS.programs + 2 ------============================== !!!!! добавить проверку есть ли очный и заочный
    end
  end


  local scrollView = widget.newScrollView(
    {
      top = 0,
      left = 0,
      width = q.fullw,
      height = q.fullh,
      scrollWidth = 0,
      scrollHeight = 0,
      horizontalScrollDisabled = true,
      -- verticalScrollDisabled = true,
      hideBackground = true,
      isBounceEnabled = false,
    }
  )

  mainGroup:insert(scrollView)

  local pop, y, config = standartPopUp()
  scrollView:insert(pop)

  pops[#pops] = scrollView

  config.logo.fill = {
    type = "image",
    -- filename = "img/icon/vuzes/optionswhite_agat.png",
    filename = "img/icon/vuzes/".. vuz.nameEn ..".png",
  }
  config.specPhoto.fill = {
    type = "image",
    filename = "img/kolledg/"..vuz.nameEn..".png"
  }
  config.topLabelSetText(vuz.nameFullRu)
  config.podTopSetText(vuz.gos and "Государтсвенный" or "Негосудартсвенный")
  config.toner.fill = q.CL"2C70D7"
  -- local year = tostring(mouthToYear(tonumber(prof.month)))
  config.tonerSetText(1, tostring(sumS.programs), "Программ\nобучения")
  config.tonerSetText(2, tostring(sumS.mestB) or ("---"), "Бюджет.\nмест")
  config.tonerSetText(3, tostring(sumS.mestP) or ("---"), "Платных\nмест",36)



  local group = display.newGroup()
  pop:insert(group)

  local specLabel = display.newParagraph("Средний балл ЕГЭ", 60,{
    font = "mont_sb",
    size = 20*2,
    align = "left",
    color = {0,0,0}
  })
  group:insert(specLabel)
  specLabel.x = 40
  specLabel.y = (y - 80) + 35
  specLabel.anchorX, specLabel.anchorY = 0, 0

  local egeBallGroup = generateEgeBall({
    parent = pop,
    y = specLabel.y + specLabel.height + 30,
    balls = vuz.egeStat,
  })

  local verical = line(group, egeBallGroup.y + egeBallGroup.height + 30 + 50)

  local specLabel = display.newText({
    parent = group,
    text = "О "..vuz.nameShortRu,
    font = "mont_sb",
    fontSize = 20*2,
    x = 40,
    y = verical.y + 30
  })
  specLabel.anchorX, specLabel.anchorY = 0, 0
  specLabel:setFillColor( 0 )

  local allButtons = display.newGroup()
  group:insert(allButtons)

  local info = {
    {
      label = "Программы",
      discrition = tostring(#vuz.spec*4),
      imagePath = "img/icon/shapka.png",
    },
    {
      label = "Специальности",
      discrition = tostring(#vuz.spec),
      imagePath = "img/icon/chemodan.png",
    },
    {
      label = "Подразделения",
      discrition = "1",
      imagePath = "img/icon/vuz.png",
    }
  }
  local bakButtons, buttonsList = generateMiniSpecButtons(
    {
      parent = allButtons,
      name = "bak",
      y = specLabel.y + specLabel.height + 30,
      buttons = info
    }
  )

  buttonsList[1].vuz = vuz
  q.event.add("toVuzProfies1", buttonsList[1], openProfiesInVuz, eventGroupName.."-buttons")
  buttonsList[2].vuz = vuz
  q.event.add("toVuzProfies2", buttonsList[2], openProfiesInVuz, eventGroupName.."-buttons")
  
  for i=3, #buttonsList do
    local button = buttonsList[i]

    q.event.add("VUZfake"..i, button, function()
      native.showAlert( "Внимание", "Этот вид сортировки ещё не реализован", { "OK" } )
    end, eventGroupName.."-buttons" )
  end

  local contactGroup = display.newGroup( )
  group:insert( contactGroup )
  contactGroup.y = bakButtons.y+bakButtons.height*.5+30+50

  local backContact = display.newRoundedRect(contactGroup, q.cx, 0,q.fullw-60,500,12*2)
  backContact:setFillColor( unpack( q.CL"3B4CDC" ) )
  backContact.anchorY = 0

  local contactLabel = display.newText({
    parent = contactGroup,
    text = "Контакты",
    font = "mont_sb",
    fontSize = 20*2,
    x = 60,
    y = 50
  })
  contactLabel.anchorX, specLabel.anchorY = 0, 0

  local lastY = 70 + 25
  local info = {
    {image = "website.png",text=vuz.site,func=function()
      if system.canOpenURL("tel:"..vuz.site) then
        system.openURL(vuz.site)
      else
        native.showAlert( "Ошибка", "Не удалось вызвать приложение \"Chrome\"", { "OK" } )
      end
    end},
    {image = "message.png",text=vuz.email,func=function()
      if system.canOpenURL("mailto:"..vuz.email) then
        system.openURL("mailto:"..vuz.email)
      else
        native.showAlert( "Ошибка", "Не удалось вызвать приложение \"Почта\"", { "OK" } )
      end
    end},
    {image = "phone.png",text=vuz.phone,func=function()
      local perms = system.getInfo("grantedAppPermissions") or {}
      local granted = false
      for i=1, #perms do
        -- print(perms[i])
        if perms[i]=="android.permission.CALL_PHONE" or perms[i]=="Phone" then granted=true break end
      end
      if not granted then
        native.showPopup( "requestAppPermission", {
          appPermission = "android.permission.CALL_PHONE",
          rationaleTitle = "Нет доступа",
          rationaleDescription = "Для ввода номера нужно разрешение",
        })
        return
      end
      local phone = vuz.phone--"8 (924) 178-57-13"
      phone = phone:gsub(" ","")
      phone = phone:gsub("%(","")
      phone = phone:gsub("%)","")
      phone = phone:gsub("-","")
      if phone:sub(1,1)=="8" then phone = "+7"..phone:sub(2,-1) end
      
      if system.canOpenURL("tel:"..phone) then
        system.openURL("tel:"..phone)
      else
        native.showAlert( "Ошибка", "Не удалось вызвать приложение \"Телефон\"", { "OK" } )
      end
    end},
    {image = "map.png",text=vuz.adress,func=function()
      if system.canOpenURL("https://2gis.ru/yakutsk/search/"..vuz.adress) then
        system.openURL("dgis://2gis.ru/yakutsk/search/"..vuz.adress)
      else
        system.openURL("https://google.com/search?q=2gis+"..vuz.adress)
      end
    end},
  }
  for i=1, 4 do
    local backLine = display.newRect( contactGroup, q.cx, lastY, backContact.width, 92 )
    backLine.anchorY=0
    backLine.fill = q.CL"2B28CC"
    q.event.add("contact"..i, backLine, info[i].func,eventGroupName.."-buttons")

    local logo = display.newImageRect( contactGroup, "img/icon/"..info[i].image, 37*2, 37*2 )
    logo.x = contactLabel.x + 60
    logo.y = lastY + backLine.height*.5

    lastY = lastY + backLine.height + 20

    local text = display.newText({
      parent = contactGroup,
      text = info[i].text,
      x = logo.x + logo.width*.5 + 40,
      y = logo.y-2.5,
      font = "mont_m",
      fontSize = 16*2,
      align = "left",
      width = q.fullw - 250
    })
    text.anchorX = 0

    if text.height>backLine.height then
      text.text = text.text:sub(1, 60).."..." 
    end

  end

  backContact.height = lastY + 25

  config.back.height = contactGroup.y + backContact.height + 50
  q.event.group.on( eventGroupName.."-buttons" )
end 

openProfInVuz = function( event )
  local options = event.target.options
  local eventGroupName = to.profInVuz()

  -- print(q.printTable(options))
  -- print("get options")
  local vuz = getVuzByName(options.vuzes.eng)
  local prof
  for i=1, #vuz.spec do
    if vuz.spec[i].specNum==options.specNum then
      prof = deepcopy(vuz.spec[i])
      break
    end
  end


  -- print(q.printTable(options))
  local pop, y, config = standartPopUp()
  config.logo.fill = {
    type = "image",
    filename = "img/icon/vuzes/".. vuz.nameEn ..".png",
  }
  config.specPhoto.fill = {
    type = "image",
    filename = "img/kolledg/"..vuz.nameEn..".png"
  }
  config.topLabelSetText(vuz.nameFullRu)
  config.podTopSetText(vuz.gos and "Государтсвенный" or "Негосудартсвенный")
  config.toner.fill = q.CL"2C70D7"
  local year = tostring(mouthToYear(tonumber(prof.month)))
  config.tonerSetText(1, year.." года", "обучения")
  config.tonerSetText(2, prof.mest.budget or ("---"), "Бюджет.\nмест")
  config.tonerSetText(3, prof.mest.platno or ("---"), "Платных\nмест",36)

  local backToKolledg = display.newRect( pop, q.fullw, 162*2+125, 30*3, 125*2)
  backToKolledg.fill = {0,0,0,.2}
  backToKolledg.anchorX = 1
  backToKolledg.options = {vuz = vuz}

  local oKolledge = display.newText({
    parent = pop, 
    text = "О колледже",
    x = q.fullw-30,
    y = 162*2 + 125,
    font = "mont_sb",
    fontSize = 13*2,
  })
  oKolledge.rotation = -90
  oKolledge.anchorY = 1

  local group = display.newGroup()
  pop:insert(group)

  local specLabel = display.newParagraph(allSpec[options.specNum], 60,{
    font = "mont_sb",
    size = 18*2,
    align = "left",
    color = {0,0,0}
  })
  group:insert(specLabel)
  specLabel.x = 40
  specLabel.y = (y - 80) + 35
  specLabel.anchorX, specLabel.anchorY = 0, 0

  local variantLabel = display.newText({
    parent = group, 
    text = "Варианты обучения",
    x = 40, 
    y = specLabel.y + specLabel.height + 40,
    font = "mont_sb",
    fontSize = 16*2,
    align = "left",
  })
  variantLabel:setFillColor(unpack(q.CL"A3A3A3"))
  variantLabel.anchorX, variantLabel.anchorY = 0, 0


  local gray = q.CL"DDDDDD"
  local green = q.CL"2DD799"
  local blue = q.CL"1B98DE"
  local grayLabel = q.CL"909090"

  local y = y + specLabel.height + variantLabel.height + 30

  local freeBack = roundedRectAndShadow({
    parent = group,
    x = 50, 
    y = y, 
    width = 164*2, 
    height = 38*2, 
    color = green, 
    cornerRadius = 12*2,
    shadowWidth = 1, 
    anchorX = 0, 
    anchorY = 0
  })

  local freeLabel = display.newText( {
    parent = group,
    x = 50 + 164,
    y = y + 38,
    text = "Бюджет",
    font = "mont_sb.ttf",
    fontSize = 15*2,
    align = "center",
  })

  local payBack = roundedRectAndShadow({
    parent = group, 
    x = q.fullw-50, 
    y = y, 
    width = 164*2, 
    height = 38*2, 
    color = gray, 
    cornerRadius = 12*2, 
    shadowWidth = 1, 
    anchorX = 1, 
    anchorY = 0
  })

  local payLabel = display.newText( {
    parent = group,
    x = q.fullw - (50 + 164),
    y = y + 38,
    text = "Платно",
    font = "mont_sb.ttf",
    fontSize = 15*2,
    align = "center",
  })
  payLabel:setTextColor(unpack(grayLabel))
  
  local y = y + payBack.height*.5

  local allBalls = display.newGroup()
  group:insert(allBalls)

  local scrollView
  local function scrollListener( event )
 
    local phase = event.phase
    if ( phase == "began" ) then
     -- print( "Scroll view was touched" )
    -- elseif ( phase == "moved" ) then print( "Scroll view was moved" )
    elseif ( phase == "ended" ) then
      local _, y = event.target:getContentPosition()
      -- print( "Scroll view was released on pos: "..y )
      if y<-100 then
        transition.to( pop, {y = -162*2, time=500} )

      end
    end
 
    -- In the event a scroll limit is reached...
    if ( event.limitReached ) then
        if ( event.direction == "up" ) then 
          -- print( "Reached bottom limit" )
        elseif ( event.direction == "down" ) then
         -- print( "Reached top limit" )
          transition.to( pop, {y = 0, time=500} )
        -- elseif ( event.direction == "left" ) then print( "Reached right limit" )
        -- elseif ( event.direction == "right" ) then print( "Reached left limit" )
        end
    end
 
    return true
  end

  local scrollHeight = q.fullh - (y+50-30) + 162*2

  scrollView = widget.newScrollView(
    {
      top = y+50-30,
      left = 0,
      width = q.fullw,
      height = scrollHeight,-- -170 + 162*2,
      scrollWidth = 0,
      scrollHeight = 0,
      horizontalScrollDisabled = true,
      -- verticalScrollDisabled = true,
      hideBackground = true,
      listener = scrollListener,
    }
  )
  allBalls:insert( scrollView )

  -- print(  q.printTable( prof.ege ) )
  local egeBall = {}
  for i=1, #prof.ege.predmeti do
    local predmet = prof.ege.predmeti[i]
    local ball = prof.ege.ball.ochnoBudget[i]
    egeBall[#egeBall+1] = {predmetsRus[predmet],ball}
  end

  -- print(  q.printTable( prof.ball ) )


  local freeBall = generateProgBall(
    {
      parent = scrollView,
      y = 30,
      
      ochno = true,
      pay = nil,
      ege = egeBall,
      ball = {
        all = prof.ball.allBudgetOchno,
        middle = prof.ball.middleBudgetOchno,
      },
    }
  )

  local egeBall = {}
  for i=1, #prof.ege.predmeti do
    local predmet = prof.ege.predmeti[i]
    local ball = prof.ege.ball.zaochnoBudget[i]
    egeBall[#egeBall+1] = {predmetsRus[predmet],ball}
  end

  
  local freeZaoBall = generateProgBall(
    {
      parent = scrollView,
      y = freeBall.height + 30,
      
      ochno = false,
      pay = nil,
      ege = egeBall,
      ball = {
        all = prof.ball.allBudgetZaochno,
        middle = prof.ball.middleBudgetZaochno,
      },
    }
  )

  -- ============ --
  local scrollView = widget.newScrollView(
    {
      top = y+50-30,
      left = q.fullw,
      width = q.fullw,
      height = scrollHeight,-- -170 + 162*2,
      scrollWidth = 0,
      scrollHeight = 0,
      horizontalScrollDisabled = true,
      -- verticalScrollDisabled = true,
      hideBackground = true,
      listener = scrollListener,
    }
  )
  allBalls:insert( scrollView )

  local egeBall = {}
  for i=1, #prof.ege.predmeti do
    local predmet = prof.ege.predmeti[i]
    local ball = prof.ege.ball.ochnoPlatno[i]
    egeBall[#egeBall+1] = {predmetsRus[predmet],ball}
  end

  local freeBall = generateProgBall(
    {
      parent = scrollView,
      y = 30,
      
      ochno = true,
      pay = 250000,
      ege = egeBall,
      ball = {
        all = prof.ball.allPlatnoOchno,
        middle = prof.ball.middlePlatnoOchno,
      },
    }
  )
  -- freeBall.x = q.fullw

  local egeBall = {}
  for i=1, #prof.ege.predmeti do
    local predmet = prof.ege.predmeti[i]
    local ball = prof.ege.ball.zaochnoPlatno[i]
    egeBall[#egeBall+1] = {predmetsRus[predmet],ball}
  end

  local freeZaoBall = generateProgBall(
    {
      parent = scrollView,
      y = freeBall.height + 30,
      
      ochno = false,
      pay = 200000,
      ege = egeBall,
      ball = {
        all = prof.ball.allPlatnoZaochno,
        middle = prof.ball.middlePlatnoZaochno,
      },
    }
  )
  -- freeZaoBall.x = q.fullw

  
  local onMove = false
  local function freePaySwitch(event)
    if onMove then return end
    onMove = true
    timer.performWithDelay(700, function()
      onMove=false
    end)
    local toWhat = event.target.type
    if toWhat=="free" then

      transition.to(allBalls,{x=0, time=700, transition=easing.inOutQuad})

      transition.to(freeBack.rect.fill,{r=green[1], g=green[2], b=green[3], time=700, transition=easing.inOutQuad})
      transition.to(payBack.rect.fill,{r=gray[1], g=gray[2], b=gray[3], time=700, transition=easing.inOutQuad})

      transition.to(freeLabel.fill,{r=1, g=1, b=1, time=700, transition=easing.inOutQuad})
      transition.to(payLabel.fill,{r=grayLabel[1], g=grayLabel[2], b=grayLabel[3], time=700, transition=easing.inOutQuad})

    elseif toWhat=="pay" then
    
      transition.to(allBalls,{x=-q.fullw, time=700, transition=easing.inOutQuad})
    
      transition.to(freeBack.rect.fill,{r=gray[1], g=gray[2], b=gray[3], time=700, transition=easing.inOutQuad})
      transition.to(payBack.rect.fill,{r=blue[1], g=blue[2], b=blue[3], time=700, transition=easing.inOutQuad})

      transition.to(freeLabel.fill,{r=grayLabel[1], g=grayLabel[2], b=grayLabel[3], time=700, transition=easing.inOutQuad})
      transition.to(payLabel.fill,{r=1, g=1, b=1, time=700, transition=easing.inOutQuad})
    
    end

  end
  freeBack.rect.type = "free"
  payBack.rect.type = "pay"
  q.event.add("freeButtons", freeBack.rect, freePaySwitch,eventGroupName.."-buttons")
  q.event.add("payButtons",  payBack.rect,  freePaySwitch,eventGroupName.."-buttons")

  q.event.add("toKolledg", backToKolledg, openVuz,eventGroupName.."-buttons")

  q.event.group.on(eventGroupName.."-buttons")
end

local function openThisSpecInVuzes( event )
  local spec = event.target.specNum
  local name = allSpec[spec]
  -- print(spec)
  -- local info = sortByGroup[spec] 
  
  -- if spec ~= "tech" then return end
  local vuzes = getVuzesWithSpecNum(spec)
  if #vuzes==0 then
    native.showAlert( "Внимание", "Эта профессия ещё не добавлена!", { "OK" } )
    return
  end

  local eventGroupName = to.thisSpecInVuzes()
  local pop, y, config = standartPopUp()
  config.logo.alpha = 0
  -- config.logo.fill = {
  --   type = "image",
  --   filename = "img/back/".. spec ..".png"
  -- }
  config.logo.yScale = .75
  config.specPhoto.fill = {
    type = "image",
    filename = "img/spec/".. spec:gsub("%.","/") ..".png",
  }
  config.topLabelSetText(name)
  config.podTopSetText(#vuzes.." учебных заведения")
  config.toner.fill = q.CL"2CD7C2"

  local programsNum = 0
  local budgetMest = 0
  local platnoMest = 0
  for i=1, #vuzes do
    local vuzSpec = vuzes[i].sortedSpec 
    for j=1, #vuzSpec do
      programsNum = programsNum + ((vuzSpec[j].mest.budget~=nil) and 1 or 0)
      programsNum = programsNum + ((vuzSpec[j].mest.platno~=nil) and 1 or 0)
      budgetMest = budgetMest + ((vuzSpec[j].mest.budget~=nil) and tonumber(vuzSpec[j].mest.budget) or 0)
      platnoMest = platnoMest + ((vuzSpec[j].mest.platno~=nil) and tonumber(vuzSpec[j].mest.platno) or 0)

    end
  end
  config.tonerSetText(1, tostring(programsNum), "Программы\nобучения")
  config.tonerSetText(2, tostring(budgetMest), "Бюджет.\nмест")
  config.tonerSetText(3, tostring(platnoMest), "Платных\nмест")



  -- local buttonsInfo = {
  --   {
  --     miniLogo = "img/icon/chemodan.png",
  --     label = "Программирование и электроника информационных систем",
  --     specNum = "11.03.04",
  --     vuzes = {"id1","id2"},
  --     specPhoto = "img/kolledg/spec.png",
  --     budget = {
  --       ball = "47",
  --       mest = "97",
  --     },
  --     platno = {
  --       ball = "41",
  --       mest = "50",
  --     },
  --     pay = "40478",
  --   },
  -- ball = {
    -- middleBudgetOchno = "97",
    -- middlePlatnoOchno = "50",

    -- middleBudgetZaochno = "97",
    -- middlePlatnoZaochno = "50",

    -- allBudgetOchno = "194",
    -- allBudgetZaochno = "194",

    -- allPlatnoOchno  = "194",
    -- allPlatnoZaochno  = "194",
  -- },

  local buttonsInfo = getButtonsInfo(vuzes, false)
  for i=1, #buttonsInfo do
    buttonsInfo[i].specPhotoFill = {.5,.5,.5}
  end
  -- print(q.printTable(buttonsInfo))

  local buttons = generateThisSpecButtons{
    parent = pop,
    y = y,
    buttonsInfo = buttonsInfo
  }

  for i=1, #buttonsInfo do
    q.event.add("toSpecInVuz-"..i, buttons[i], openProfInVuz, eventGroupName.."-buttons")
  end
  q.event.group.on(eventGroupName.."-buttons")
end

local function openGroupSpec( event )
  local spec = event.target.specName
  -- print(spec)
  local info = sortByGroup[spec] 
  
  -- if spec ~= "tech" then return end
  local vuzes = getVuzesWithSpecNum(info.specSort)
  if #vuzes==0 then
    native.showAlert( "Внимание", "Колледжи из данной категории ещё не добавлены", { "OK" } )
    return
  end

  local eventGroupName = to.profGroup()
  local pop, y, config = standartPopUp()
  config.logo.fill = {
    type = "image",
    filename = "img/icon/forsort/".. spec ..".png",
  }
  config.logo.yScale = .75
  config.specPhoto.fill = {
    type = "image",
    filename = "img/back/".. spec ..".png"
  }
  config.topLabelSetText(info.label)
  config.podTopSetText(#vuzes.." учебных заведения")
  config.toner.fill = q.CL"2CD7C2"

  local programsNum = 0
  local budgetMest = 0
  local platnoMest = 0
  for i=1, #vuzes do
    local vuzSpec = vuzes[i].sortedSpec 
    for j=1, #vuzSpec do
      programsNum = programsNum + ((vuzSpec[j].mest.budget~=nil) and 1 or 0)
      programsNum = programsNum + ((vuzSpec[j].mest.platno~=nil) and 1 or 0)
      budgetMest = budgetMest + ((vuzSpec[j].mest.budget~=nil) and tonumber(vuzSpec[j].mest.budget) or 0)
      platnoMest = platnoMest + ((vuzSpec[j].mest.platno~=nil) and tonumber(vuzSpec[j].mest.platno) or 0)

    end
  end
  config.tonerSetText(1, tostring(programsNum), "Программы\nобучения")
  config.tonerSetText(2, tostring(budgetMest), "Бюджет.\nмест")
  config.tonerSetText(3, tostring(platnoMest), "Платных\nмест")

  -- local buttonsInfo = {
  --   {
  --     miniLogo = "img/icon/chemodan.png",
  --     label = "Программирование и электроника информационных систем",
  --     specNum = "11.03.04",
  --     vuzes = {"id1","id2"},
  --     specPhoto = "img/kolledg/spec.png",
  --     budget = {
  --       ball = "47",
  --       mest = "97",
  --     },
  --     platno = {
  --       ball = "41",
  --       mest = "50",
  --     },
  --     pay = "40478",
  --   },
  -- ball = {
    -- middleBudgetOchno = "97",
    -- middlePlatnoOchno = "50",

    -- middleBudgetZaochno = "97",
    -- middlePlatnoZaochno = "50",

    -- allBudgetOchno = "194",
    -- allBudgetZaochno = "194",

    -- allPlatnoOchno  = "194",
    -- allPlatnoZaochno  = "194",
  -- },

  local buttonsInfo = getButtonsInfo(vuzes, true)
  for k, v in pairs(buttonsInfo) do
    buttonsInfo[k].specPhotoFill = {.5,.5,.5}
  end
  -- print(q.printTable(buttonsInfo))

  local buttons = generateThisSpecButtons{
    parent = pop,
    y = y,
    buttonsInfo = buttonsInfo
  }

  for specNum, info in pairs(buttonsInfo) do
    -- local info = buttonsInfo[i]

    if #info.vuzes==1 then
      q.event.add("toSpecInVuz-"..specNum, buttons[specNum], openProfInVuz, eventGroupName.."-buttons")
    else
      buttons[specNum].specNum = specNum
      q.event.add("toThisSpecInVuzes-"..specNum,buttons[specNum], openThisSpecInVuzes,eventGroupName.."-buttons")
      -- q.event.add("toThisSpecInVuzes-"..specNum,buttons[specNum],function()
      --   native.showAlert( "Внимание", "Просмотр группы вузов по профессии не отлажен", { "OK" } )
      -- end,"profGroup-buttons")
    end
  end
  q.event.group.on(eventGroupName.."-buttons")
end

---------------------

local account
local myID, toID, id1, id2, myI

local function htmlRead(text)
  text = text:gsub("<b>","")
  text = text:gsub("</b>","")
  text = text:gsub("<br>","\n")
  text = text:gsub("<br />","")
  print("response:\n"..text)
  return text
end

local function drawInMsg(event)
  if ( event.isError)  then
    print( "Messager load error:", event.response)
    return
  end

  local myNewData = event.response
  -- htmlRead(myNewData)
  -- if text~="[]" then
  --   error(text)
  -- end
  -- print( "response:", myNewData:gsub("<br>","\n"))
  local msg = json.decode( myNewData ) or {}
  local msgIn = {}
  for k,v in pairs(msg) do
    msgIn[tonumber(k)] = v
  end
  for k,v in pairs(msgIn) do
    msgIn[k].fromYou = false
    msgIn[k].i = nil
  end
  -- print( "response:", q.printTable(msgIn))
  
  for k,msg in pairs(msgIn) do
    chat.addMsg(msg)
  end
end

local function openChat(event)
  local params = event.target.params
  
  myID = account.id
  toID = params.id
  local my,toID = tonumber( account.id ), tonumber( params.id )
  id1 = tostring(math.min(my,toID))
  id2 = tostring(math.max(my,toID))
  myI = (myID==id1) and 1 or 2
  
  local chatGroup = display.newGroup()
  chatlistGroup:insert( chatGroup )

  q.event.group.off("chatlist-buttons")
  local eventGroupName = to.chat()
  pops[#pops+1] = chatGroup

  mainLabel.text = params.name
  -- print("add",#scenes)
  local back = display.newRect(chatGroup, q.cx, q.cy, q.fullw, q.fullh)

  q.timer.add("updateChat", 1500, function()

    q.getConnection("","timerinmsg.php", drawInMsg, {
      roomid = params.roomid,
      id = account.id,
      -- hasedPassword = account.hasedPassword,
      hasedPassword = "fa585d89c851dd338a70dcf535aa2a92fee7836dd6aff1226583e88e0996293f16bc009c652826e0fc5c706695a03cddce372f139eff4d13959da6f1f5d3eabe",
    })    
  
  end, 0) 
  q.timer.on"updateChat"

  local scrollView = widget.newScrollView(
    {
      top = 150,
      left = 0,
      width = q.fullw,
      height = q.fullh-200 -100,
      scrollWidth = 0,
      scrollHeight = 0,
      horizontalScrollDisabled = true,
      -- verticalScrollDisabled = true,
      hideBackground = true,
    }
  )
  chatGroup:insert(scrollView)

  display.remove(msgGroup)
  msgGroup = display.newGroup()
  scrollView:insert(msgGroup)

  chat.init(msgGroup,0)
  for i=1, #params.msg do
    chat.addMsg(params.msg[i])
  end
  -- chat.addMsg({fromYou=false,text="Здраствуйте! Хороший день чтобы заняться вот чем:"})

  local keyboardOffset = 165
  local inTextGroup = display.newGroup()
  chatGroup:insert(inTextGroup)
  inTextGroup.y = q.fullh - 150
  inTextGroup.startY = inTextGroup.y


  local rounded = display.newRoundedRect( inTextGroup, 30, 0, q.fullw-200, 80, 30 )
  rounded.anchorX = 0
  rounded.anchorY = 1
  rounded.fill = c.gray2

  local send = display.newRoundedRect( inTextGroup, rounded.x+rounded.width+30, 0, q.fullw-(rounded.x+rounded.width+30*2), 80, 40 )
  send.anchorX = 0
  send.anchorY = 1
  send.fill = c.blue

 

  local scrollChatOn = false
  
  local function moveFieldsDown()
    timer.performWithDelay(100, function()
      transition.to( inTextGroup, { time=200, y=inTextGroup.startY} )
    end)
  end
  local function moveFieldsUp()
    transition.to( inTextGroup, { time=200, y=q.fullh-keyboardOffset-150-200+20} )
  end

  local toBotField
  q.event.add("sendMsg", send, function()
    local text = q.trim(toBotField.text)

    if text~="" then 
      
        
      local my,to = tonumber( account.id ), tonumber( params.id )
      local id = {
        tostring(math.min(my,to)),
        tostring(math.max(my,to)),
      }
      moveFieldsDown()
      q.getConnection("","addmsg.php", function(event)
        print("response",event.response)
        if event.response=="Chat updated" then
          chat.addMsg({fromYou=true,text = text})
          toBotField.text = ""
          native.setKeyboardFocus( nil )
        end
      end, {
        myid = account.id,
        id1 = id[1],
        id2 = id[2],
        msg = text,
        hasedPassword = account.hasedPassword,
        -- hasedPassword = "fa585d89c851dd338a70dcf535aa2a92fee7836dd6aff1226583e88e0996293f16bc009c652826e0fc5c706695a03cddce372f139eff4d13959da6f1f5d3eabe",
      })  
      -- timer.performWithDelay(250, function()
      --   chat.addMsg({fromYou=false,text = "К сожелению чат бот не поддерживается в оффлайн режиме!"})
      --   scrollView:setScrollHeight(msgGroup.height + 150)
      -- end )
    
    end
  end, eventGroupName.."-buttons" )

  local function keyBack(event)
    if event.phase=="down" then
      local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
      chat.addMsg({fromYou=false,text=message})
      if event.keyName == "back" then
        moveFieldsDown()
        return true
      end
      return false
    end
  end
-- if ( system.getInfo("environment") == "device" ) then
  local function moveDescription(event) 
    if event.phase == "began" then
      moveFieldsUp()
      -- Runtime:addEventListener( "key", keyBack )

    elseif event.phase == "editing" then
      
      
    elseif event.phase == "submitted" then
      chat.addMsg({fromYou=false,text="submitted"})
      moveFieldsDown()
    end
  end
  toBotField = native.newTextField(rounded.x+20-3000, -rounded.height*.5, rounded.width-20*2, 200)
  inTextGroup:insert( toBotField )
  toBotField.anchorX=0

  toBotField.startX=toBotField.x+3000
  toBotField.hasBackground = false
  toBotField.placeholder = "Введите сообщение"

  toBotField.font = native.newFont( "ubuntu_r.ttf",20*2)

  toBotField:resizeHeightToFitFont()
  toBotField:setTextColor( 0, 0, 0 )
  toBotField:addEventListener( "userInput", moveDescription )

  local sendIco = display.newImageRect( inTextGroup, "img/send.png", 45, 45 )
  sendIco.x, sendIco.y = send.x+send.width*.5+5, send.y-send.height*.5

  toBotField.x=toBotField.startX
  inTextGroup.y = inTextGroup.y + 10
     
  q.event.group.on(eventGroupName.."-buttons")
end

local allChats = {}
local function messagerInput(event)
  if ( event.isError)  then
    print( "Messager load error:", event.response)
    return
  end

  local myNewData = event.response
  print( "response:", myNewData:gsub("<br>","\n"))
  local serverChats = json.decode( myNewData ) or {}
        
  local i = 1
  for k, v in pairs(serverChats) do
    allChats[i] = v
    local thisChat = allChats[i]
    thisChat.id = k
    local my,to = tonumber( account.id ), tonumber( thisChat.id )
    local id = {
      tostring(math.min(my,to)),
      tostring(math.max(my,to)),
    }
    local intMsg = {}
    for k, v in pairs(thisChat.msg) do
      intMsg[tonumber( k )] = v
      thisChat.msg[k] = nil
    end
    thisChat.msg = nil
    thisChat.msg = intMsg

    for msgI=1, #thisChat.msg do
      local msg = thisChat.msg[msgI]
      msg.fromYou = id[tonumber(msg.i)] == account.id
    end
    
    i = i + 1
  end
  
  -- print(q.printTable(serverChats))
  print(q.printTable(allChats))

  do ------- ОТРИСОВКА ЧАТА -------

    local lastY = 210
    local sizeLogo = 65
    local x = 40
    -- allChats[2] = allChats[1]
    for i = 1, #allChats do
      local info = allChats[i]
      local logo = display.newCircle( chatlistGroup, 110, lastY, sizeLogo )
      -- logo.anchorX = 0
      logo.fill = {
        type = "image",
        filename = "img/chat_profile.png"
      }

      local name = q.subBySpaces(info.name)

      local nameLabel = textWithLetterSpacing( {
        parent = chatlistGroup, 
        text = name[1].." "..name[2], 
        x = logo.x+logo.width*.5+x, 
        y = lastY-25, 
        font = "ubuntu_m.ttf", 
        fontSize = 16*2,
        color = {0},
      }, 10, 0)

      local lastMsg = "Нет сообщений"
      if #info.msg~=0 then
        lastMsg = info.msg[#info.msg].text:sub(1,30)
        if #lastMsg>50 then
          lastMsg = lastMsg.."..."
        end
      end
      local lastMsg = display.newText({
        parent = chatlistGroup, 
        text = lastMsg, 
        x = logo.x+logo.width*.5+x, 
        y = lastY+28, 
        font = "ubuntu_r.ttf", 
        fontSize = 16*2,
      })
      lastMsg:setFillColor( unpack( q.CL"808080" ) )
      lastMsg.anchorX = 0

      local button = display.newRect( chatlistGroup, q.cx, lastY, q.fullw, 160 )
      button.fill = {0,0,0,.5}
      button.alpha = .01

      button.params = info
      q.event.add("chatWith_"..info.id,button,openChat,"chatlist-buttons")

      lastY = lastY + 180
    end
  end

  to.chatlist()

end


local onKeyEvent
if ( system.getInfo("environment") == "device" ) then
  onKeyEvent = function( event )
    -- Print which key was pressed down/up
    local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
    -- print( message )
    -- print(system.getInfo("platform") )
    -- If the "back" key was pressed on Android, prevent it from backing out of the app
    if ( event.keyName == "back" and nowScene~="menu" and nowScene~="chatlist" and event.phase == "down" ) then
      removePop()
      
      return true
    end

    -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
    -- This lets the operating system execute its default handling of the key
    return false
  end
else
  onKeyEvent = function( event )
    
    local key = event.keyName
    local message = "PC Key '" .. key .. "' was pressed " .. event.phase
    -- print( message )

    if ( event.phase == "down" ) then
      if key=="escape" and nowScene~="menu" and nowScene~="chatlist" then
        -- display.remove(newPopUp)
        removePop()
      end
    end

  end
end
 

local function getMenuButtonsInfo( numiration )
  local out = {}
  for i=1, #numiration do
    local enName = numiration[i]
    out[i] = {
      label = sortByGroup[enName].label,
      discrition = #(getVuzesWithSpecNum(sortByGroup[enName].specSort)) or "0",
      imagePath = sortByGroup[enName].imagePath
    }
  end
  return out
end

local function createButton(group,label,y, name)
  local submitButton = display.newRoundedRect(group, 50, y, q.fullw-50*2, 100, 6)
  submitButton.anchorX=0
  submitButton.anchorY=1
  submitButton.fill = c.blue

  local labelContinue = textWithLetterSpacing( {
    parent = group, 
    text = label, 
    x = submitButton.x+submitButton.width*.5, 
    y = submitButton.y-submitButton.height*.5, 
    font = "ubuntu_b.ttf", 
    fontSize = 14*2,
    }, 10, .5)

  return submitButton, labelContinue
end

function scene:create( event )
	local sceneGroup = self.view

	backGroup = display.newGroup() -- Группа фоновых элементов
	sceneGroup:insert(backGroup)

	mainGroup = display.newGroup() -- Группа основного экрана
	sceneGroup:insert(mainGroup)

  testsGroup = display.newGroup() -- Группа списка тестов
  mainGroup:insert(testsGroup)

  kursesGroup = display.newGroup() -- Группа списка курсов
  mainGroup:insert(kursesGroup)
  kursesGroup.alpha = 0

	eventGroup = display.newGroup() -- Группа списка новостей
	sceneGroup:insert(eventGroup)
	eventGroup.alpha = 0

  inNewsOverlay = display.newGroup() -- Группа для кнопок 
  eventGroup:insert(inNewsOverlay)

	chatlistGroup = display.newGroup() -- Группа чата
	sceneGroup:insert(chatlistGroup)
	chatlistGroup.alpha = 0

 
  msgGroup = display.newGroup()

	profileGroup = display.newGroup() -- Группа профиля
	sceneGroup:insert(profileGroup)
	profileGroup.alpha = 0

  account = q.loadLogin()
  -- if account.lic=="admin" then
  --   adminGroup = display.newGroup()
  --   sceneGroup:insert(adminGroup)
  --   adminGroup.alpha = 0
  -- end


	uiGroup = display.newGroup() -- Группа общих элементов
	sceneGroup:insert(uiGroup)

	quizzScreen = display.newGroup() -- Группа для прохождения теста
	uiGroup:insert(quizzScreen)

  kursScreen = display.newGroup() -- Группа для просмотра курса
  uiGroup:insert(kursScreen)

  server = composer.getVariable( "ip" )

  local back = display.newRect( backGroup, q.cx, q.cy, q.fullw, q.fullh )

  mainLabel = display.newText( {
  	parent = uiGroup,
  	text = "Навигация",
  	x=30,
  	y=60,
  	font = "ubuntu_m.ttf",
  	fontSize = 24*2} )
  mainLabel.fill = c.black	
  mainLabel.anchorX = 0
  mainLabel.alpha = 0

  downNavigateGroup = display.newGroup()
  uiGroup:insert(downNavigateGroup)

  local downBack = display.newRect(downNavigateGroup, q.cx, q.fullh, q.fullw, 125)
  downBack.anchorY = 1

  local Vshadow = display.newImageRect( downNavigateGroup, "img/shadow.png", q.fullw, q.fullw*.0611 )
  Vshadow.x = q.cx
  Vshadow.y = q.fullh-downBack.height
  Vshadow.anchorY=1
  
  mainButton = display.newImageRect( downNavigateGroup, "img/main.png", 58*2, 44*2 )
  mainButton.y = q.fullh - mainButton.height*.5-20
  mainButton.x = q.cx*.25+20
  mainButton:setFillColor( unpack( c.blue ) )
  q.event.add("toMenu",mainButton, to.menu, "downBar")

  eventButton = display.newImageRect( downNavigateGroup, "img/events.png", 58*2, 44*2 )
  eventButton.y = q.fullh - eventButton.height*.5-20
  eventButton.x = q.cx*.75+10
  eventButton:setFillColor( unpack( c.grayButtons ) )

  chatButton = display.newImageRect( downNavigateGroup, "img/chat.png", 58*2, 44*2 )
  chatButton.y = q.fullh - chatButton.height*.5-20
  chatButton.x = q.cx*1.25-10
  chatButton:setFillColor( unpack( c.grayButtons ) )
  q.event.add("toChat",chatButton, to.chatlist, "downBar")




  profileButton = display.newImageRect( downNavigateGroup, "img/profile.png", 58*2, 44*2 )
  profileButton.y = q.fullh - profileButton.height*.5-20
  profileButton.x = q.cx*1.75-20
  profileButton:setFillColor( unpack( c.grayButtons ) )
  q.event.add("toProfile",profileButton, to.account, "downBar")

  
  

  -- ======= М Е Н Ю ========= --
  do
    local scrollView = widget.newScrollView(
      {
        top = 0,
        left = 0,
        width = q.fullw,
        height = q.fullh,
        scrollWidth = 0,
        scrollHeight = 0,
        horizontalScrollDisabled = true,
        -- verticalScrollDisabled = true,
        hideBackground = true,
      }
    )
    mainGroup:insert(scrollView)

    topMain = display.newGroup()
    scrollView:insert(topMain)


    local logo = display.newImageRect( topMain, "img/logo1.png",76*2,76*2 )
    logo.x, logo.y = 18*2, 18*2
    logo.anchorX = 0
    logo.anchorY = 0

    local logoLabel = display.newText( {
      parent = topMain,
      x = logo.x + logo.width + 15,
      y = logo.y + logo.height*.5,
      text = "Центр опережающей\nпрофессианальной\nподготовки",
      font = "mont_sb.ttf",
      fontSize = 15*2,
      align = "left",
    })
    logoLabel.anchorX = 0
    logoLabel:setFillColor(0)
    if isDevice then 
      display.remove(logoLabel)
      display.remove(logo)
      local logo = display.newRoundedRect( topMain, 112+20,112,76*2,76*2, 20*2 )
      logo.fill = {
        type = "image",
        filename = "img/profine.png"
      }
      local logoLabel = display.newText( {
        parent = topMain,
        x = logo.x + logo.width*.5 + 25,
        y = logo.y,
        text = "Profine",
        font = "mont_sb.ttf",
        fontSize = 25*2,
        align = "left",
      })
      logoLabel.anchorX = 0
      logoLabel:setTextColor(0)
      -- logo.fill = {.5}
    end
    
    local avatarGroup = display.newGroup()
    topMain:insert(avatarGroup)

    local backAvatar = display.newCircle( avatarGroup, q.fullw-(logo.y+logo.height*.5), logo.y+logo.height*.5, logo.height-50*2 )
    backAvatar.fill = c.gray2


    local ifImage = display.newImageRect( "userAvatar"..account.id..".png", system.DocumentsDirectory, 1, 1 )
    if ifImage then
      backAvatar.fill = {
        type = "image",
        filename = pathToImport,
      }
      ifImage:removeSelf()
    end
    avatarGroup:addEventListener( "tap", function()

    end )

    local scrollView = widget.newScrollView(
      {
        top = logo.y+logo.height+17*2,
        left = 0,
        width = q.fullw,
        height = 158*2+17*4,
        scrollWidth = 0,
        scrollHeight = 0,
        -- horizontalScrollDisabled = true,
        verticalScrollDisabled = true,
        hideBackground = true,
      }
    )
    topMain:insert( scrollView )

    local storyes = display.newGroup()
    scrollView:insert(storyes)

    local storyInfo = {
      {text = "Абитуриент 2022"},
      {text = "Вебинар: поступление"},
      {text = "Справочник абитуриента"},
    }
    local space = 17*2
    for i = 1, #storyInfo do
      local back = display.newRoundedRect(storyes, 10+space+(17*2+121*2)*(i-1),  17*2, 121*2, 158*2, 8 )
      back.anchorX = 0
      back.anchorY = 0
      -- back.fill = {.7}
      if isDevice and i==1 then
        scrollView.y = scrollView.y - 30
        back.fill = {
          type = "image",
          filename = "img/story/"..i.."p.png",
        }
      else
        back.fill = {
          type = "image",
          filename = "img/story/"..i..".png",
        }
      end 


      local disc = display.newText( {
        parent = storyes,
        x = back.x + 20,
        y = back.y + back.height - 20,
        text = storyInfo[i].text,
        font = "mont_m.ttf",
        fontSize = 13*2,
        align = "left",
        width = back.width-20*2,
      })
      disc.anchorX = 0
      disc.anchorY = 1
    end
    local scrollEndPoint = display.newRect(storyes, 10*2+space+(17*2+121*2)*(#storyInfo)+17*2, 17*2, 10, 10)

    local y = scrollView.y + scrollView.height*.5
    -- local y = 158*2+17*2+logo.y+logo.height+17*2 + 20
    line(topMain, y)


    local button = display.newImageRect(topMain, "img/toTest.png", q.fullw-50, (q.fullw-50)*(66/344)*1.3+10 )
    button.x, button.y = q.cx, y-5
    button.anchorY = 0
    button:setFillColor(0)
    button.fill.effect = "filter.blurGaussian"
    button.fill.effect.horizontal.blurSize = 34
    button.fill.effect.vertical.blurSize = 34
    button.fill.effect.horizontal.sigma = 34
    button.fill.effect.vertical.sigma = 34
    button.alpha=.3
    

    local button = display.newImageRect(topMain, "img/toTest.png", q.fullw-50, (q.fullw-50+40)*(66/344)*1.3 )
    button.x, button.y = q.cx, y
    button.anchorY = 0
    y = y + button.height
    q.event.add("toCoppTest",button,
    function()
      system.openURL( "https://platform.copp14.ru/careertest" )
    end, "menu-buttons" )


    line(topMain, y + 10)
    y = y + 10

    local naprToPost = display.newText( {
      parent = topMain,
      x = 40,
      y = y + 50,
      text = "Направления для поступления",
      font = "mont_sb.ttf",
      fontSize = 20*2,
      align = "center",
    })
    naprToPost.anchorX = 0
    naprToPost:setFillColor(0)
    y = y + 50
    y = y + 50

    local bakBack = roundedRectAndShadow({
      parent = topMain,
      x = 50, 
      y = y, 
      width = 164*2, 
      height = 38*2, 
      color = q.CL"1B98DE", 
      cornerRadius = 12*2,
      shadowWidth = 1, 
      anchorX = 0, 
      anchorY = 0
    })

    local bakavLabel = display.newText( {
      parent = topMain,
      x = 50 + 164,
      y = y + 38,
      text = "Бакалавриат",
      font = "mont_sb.ttf",
      fontSize = 15*2,
      align = "center",
    })

    local magBack = roundedRectAndShadow({
      parent = topMain, 
      x = q.fullw-50, 
      y = y, 
      width = 164*2, 
      height = 38*2, 
      color = q.CL"DDDDDD", 
      cornerRadius = 12*2, 
      shadowWidth = 1, 
      anchorX = 1, 
      anchorY = 0
    })

    local magicLabel = display.newText( {
      parent = topMain,
      x = q.fullw - (50 + 164),
      y = y + 38,
      text = "Магистратура",
      font = "mont_sb.ttf",
      fontSize = 15*2,
      align = "center",
    })
    local grayLabel = q.CL"909090"
    magicLabel:setFillColor(unpack(grayLabel))

    y = y + 38*2
    line(topMain, y + 40)
    y = y + 40

    local allButtons = display.newGroup()
    topMain:insert(allButtons)

    local numiration = {
      "tech",
      "agro",
      "build",
      "medic",
      "economic",
      "transport",
      "teaching",
      "secure",
      "factory",
    }
    local bakButtons, buttonsList = generateMiniSpecButtons(
      {
        parent = allButtons,
        name = "bak",
        y = y + 50,
        buttons = getMenuButtonsInfo(numiration)
      }
    )
    for i=1, #numiration do
      local name = numiration[i]
      local button = buttonsList[i]

      button.specName = name
      q.event.add("to"..(name:upper()).."_bak", button, openGroupSpec, "menu-buttons" )
    end

    local numiration = {
      "agro",
      "factory",
      "economic",
      "medic",
      "teaching",
      "transport",
      "secure",
      "build",
      "tech",
    }
    local magButtons, buttonsList = generateMiniSpecButtons(
      {
        parent = allButtons,
        name = "mag",
        y = y + 50,
        buttons = getMenuButtonsInfo(numiration)
      }
    )
    magButtons.x = q.fullw
    for i=1, #numiration do
      local name = numiration[i]
      local button = buttonsList[i]

      button.specName = name
      q.event.add("to"..(name:upper()).."_mag", button, openGroupSpec, "menu-buttons" )
    end


    local gray = (q.CL"DDDDDD")
    local blue = (q.CL"1B98DE")
    local onMove = false
    local function bakMagSwitch(event)
      if onMove then return end
      onMove = true
      timer.performWithDelay(700, function()
        onMove=false
      end)
      local toWhat = event.target.type
      if toWhat=="balakvariat" then

        transition.to(allButtons,{x=0, time=700, transition=easing.inOutQuad})

        transition.to(bakBack.rect.fill,{r=blue[1], g=blue[2], b=blue[3], time=700, transition=easing.inOutQuad})
        transition.to(magBack.rect.fill,{r=gray[1], g=gray[2], b=gray[3], time=700, transition=easing.inOutQuad})

        transition.to(bakavLabel.fill,{r=1, g=1, b=1, time=700, transition=easing.inOutQuad})
        transition.to(magicLabel.fill,{r=grayLabel[1], g=grayLabel[2], b=grayLabel[3], time=700, transition=easing.inOutQuad})

      elseif toWhat=="magistratura" then
      
        transition.to(allButtons,{x=-q.fullw, time=700, transition=easing.inOutQuad})
      
        transition.to(bakBack.rect.fill,{r=gray[1], g=gray[2], b=gray[3], time=700, transition=easing.inOutQuad})
        transition.to(magBack.rect.fill,{r=blue[1], g=blue[2], b=blue[3], time=700, transition=easing.inOutQuad})

        transition.to(bakavLabel.fill,{r=grayLabel[1], g=grayLabel[2], b=grayLabel[3], time=700, transition=easing.inOutQuad})
        transition.to(magicLabel.fill,{r=1, g=1, b=1, time=700, transition=easing.inOutQuad})
      
      end

    end
    bakBack.rect.type = "balakvariat"
    magBack.rect.type = "magistratura"

    q.event.add("bakButtons", bakBack.rect, bakMagSwitch,"menu-buttons")
    q.event.add("magButtons", magBack.rect, bakMagSwitch,"menu-buttons")
  end

  -- ======= Ч А Т ========== --

  do
    local backTop = display.newRect(chatlistGroup, q.cx, 0, q.fullw, 130)
    backTop.anchorY=0
    backTop.fill = c.white

    local notificationButton = display.newImageRect( chatlistGroup, "img/notifications.png", 60, 60 )
    notificationButton.x = q.fullw-60
    notificationButton.y = mainLabel.y+5

    local newchatButton = display.newImageRect( chatlistGroup, "img/newchat.png", 60, 60 )
    newchatButton.x = q.fullw-140
    newchatButton.y = mainLabel.y+5
    q.event.add("newchat",newchatButton, function()
    end, "chatlist-buttons")

    local peopleToChat = {
      "1"
    }
    local all_msg = {

    }

    q.getConnection("","getallmsg.php", messagerInput, {
      myid = account.id,
      -- hasedPassword = account.hasedPassword,
      hasedPassword = "fa585d89c851dd338a70dcf535aa2a92fee7836dd6aff1226583e88e0996293f16bc009c652826e0fc5c706695a03cddce372f139eff4d13959da6f1f5d3eabe",
    })    
  end

  -- ======== П Р О Ф И Л Ь ========== --

  do
    local pathToImport = system.pathForFile( "userAvatar"..account.id..".png", system.DocumentsDirectory )
    
    local avatarGroup = display.newGroup()
    profileGroup:insert(avatarGroup)

    local backAvatar = display.newCircle( avatarGroup, 160, 270-30, 90 )
    backAvatar.fill = c.gray2

    local backPen = display.newCircle( profileGroup, 160+backAvatar.width*.35, 270-30+backAvatar.height*.35, 30 )
    backPen.fill = {.9}
    backPen.alpha=0

    local penIcon = display.newImageRect( profileGroup, "img/pen.png", 50, 50 )
    penIcon.x = backAvatar.x
    penIcon.y = backAvatar.y


    local ifImage = display.newImageRect( pathToImport, 1, 1 )
    if ifImage then
      backAvatar.fill = {
        type = "image",
        filename = pathToImport,
      }
      ifImage:removeSelf()
      backPen.alpha=1

      penIcon.x = backPen.x
      penIcon.y = backPen.y
      penIcon.xScale, penIcon.yScale = .8, .8
    end
    -- avatarGroup:addEventListener( "tap", function()
    q.event.add("changeAvatar",avatarGroup, function()
    -- avatarGroup:addEventListener( "tap", function()

      androidFilePicker.show("image/*",pathToImport, function(event)
        if (event.isError == false) then
          display.remove( backAvatar )
          timer.performWithDelay( 100, function()
            backAvatar = display.newCircle( avatarGroup, 160, 270-30, 90 )
            backAvatar.fill = {
              type = "image",
              filename = pathToImport,
            }
            backPen.alpha=1
            penIcon.x = backPen.x
            penIcon.y = backPen.y
            penIcon.xScale, penIcon.yScale = .8, .8

          end )
          -- local showImage = display.newImageRect( "userAvatar.png", system.DocumentsDirectory, 100, 100 )
          -- showImage.x, showImage.y = display.contentCenterX, display.contentCenterY+150
        end
      end )
    
    end, "profile-buttons" )


    
    local nameLabel = textWithLetterSpacing({
      parent = profileGroup,
      x=290,
      y=backAvatar.y-20,
      text = account.name:sub(1,#account.name-(account.name:reverse()):find(" ")),
      font = "ubuntu_m.ttf",
      fontSize = 16*2,
      color = c.black,
      }, 15)

    local sityLabel = textWithLetterSpacing({
      parent = profileGroup,
      x=290,
      y=backAvatar.y+20,
      text = account.sity,
      font = "ubuntu_r.ttf",
      fontSize = 16*2,
      color = c.gray,
      }, 15)

    local line = display.newRect( profileGroup, q.cx, 380, q.fullw-100, 6 )
    line.fill = c.gray2

    local infoLabel = display.newText( {
      parent = profileGroup,
      text = "Данные",
      x=70,
      y=line.y+70,
      font = "ubuntu_m.ttf",
      fontSize = 16*2} )
    infoLabel.fill = c.black
    infoLabel.anchorX = 0

    local infoShow = {
      {account.signupdate,"Дата регистрации"},
      {account.id,"ID"},
    }
    if account.lic=="user" then
      -- infoShow[3] = {account.working=="1" and "Да" or "Нет","Работаю ли"}
    end

    for i=1, #infoShow do
      local infoLabel = display.newText( {
      parent = profileGroup,
      text = infoShow[i][2],
      x=70,
      y=510+50*(i-1),
      font = "ubuntu_m.ttf",
      fontSize = 16*2} )
      infoLabel.anchorX = 0
      infoLabel.fill = c.gray

      local infoLabel = display.newText( {
      parent = profileGroup,
      text = infoShow[i][1],
      x=q.fullw-70,
      y=510+50*(i-1),
      font = "ubuntu_r.ttf",
      fontSize = 16*2} )
      infoLabel.anchorX = 1
      infoLabel.fill = c.black
    end

    local line = display.newRect( profileGroup, q.cx,510+50*(#infoShow-1)+70, q.fullw-100, 6 )
    line.fill = c.gray2

    -- local createButton(profileGroup, "ИЗМЕНИТЬ АВАТАРКУ",740,"id")
    local change = createButton(profileGroup, "СМЕНИТЬ ПАРОЛЬ",925-125,"id")
    local logOut = createButton(profileGroup, "ВЫЙТИ",925,"id")
    
    q.event.add("logout", logOut, function()
      q.saveLogin({})
      composer.gotoScene( "signin"  )
      composer.removeScene( "menu"  )
    end, "profile-buttons")
    -- logOut:addEventListener( "tap", function()

    local adminBut
    -- change:addEventListener( "tap", function() 
    q.event.add("changepass", change, function()
      change.alpha=0
      logOut.alpha=0
      if changeWorkButton then
        changeWorkButton.alpha=0
      end
      if adminBut then
        adminBut.alpha=0
      end
      local changeLayer = display.newGroup()
      profileGroup:insert(changeLayer)

      local back = display.newRoundedRect(changeLayer, 50, 865-125*2+30, q.fullw-50*2, 80, 6)
      back.fill = c.gray2
      back.anchorX = 0

      local oldPass = native.newTextField(back.x+30, back.y, back.width-30*2, 90)
      changeLayer:insert( oldPass )
      oldPass.anchorX=0
      oldPass.pos = {x=oldPass.x, y=oldPass.y}
      oldPass.isEditable=true
      oldPass.hasBackground = false
      oldPass.placeholder = "Текущий пароль"
      oldPass.font = native.newFont( "ubuntu_r.ttf",16*2)
      oldPass:resizeHeightToFitFont()
      oldPass:setTextColor( 0, 0, 0 )


      local back = display.newRoundedRect(changeLayer, 50, back.y+100, q.fullw-50*2, 80, 6)
      back.fill = c.gray2
      back.anchorX = 0

      local newPass = native.newTextField(back.x+30, back.y, back.width-30*2, 90)
      changeLayer:insert( newPass )
      newPass.anchorX=0
      newPass.pos = {x=oldPass.x, y=oldPass.y}
      newPass.isEditable=true
      newPass.hasBackground = false
      newPass.placeholder = "Новый пароль"
      newPass.font = native.newFont( "ubuntu_r.ttf",16*2)
      newPass:resizeHeightToFitFont()
      newPass:setTextColor( 0, 0, 0 )

      
      

      local okButton = createButton(changeLayer, "ОК",965-50,"okPass")
      okButton:addEventListener( "tap", function()
        okButton.fill = q.CL"4d327a"
        local r,g,b = unpack( c.blue )
        timer.performWithDelay( 400, 
        function()
          transition.to(okButton.fill,{r=r,g=g,b=b,time=300} )
        end)

        local textOldPass, textNewPass = oldPass.text, newPass.text
        if #textOldPass==0 then
          showPassWarning("Введите текущий пароль")
        elseif #textNewPass==0 then
          showPassWarning("Введите новый пароль")
        elseif #textOldPass<8 or #textNewPass<8 then
          showPassWarning("Пароли от 8 символов")
        elseif textOldPass==textNewPass then
          showPassWarning("Пароли не могут совпадать")
        else
          network.request( "http://"..server.."/dashboard/changePassword.php?oldpassword="..oldPass.text.."&newpassword="..newPass.text.."&email="..account.email, "GET", changeResponder )
        end

      end )

      closePCMenu = function()
        display.remove(changeLayer)
        change.alpha=1
        logOut.alpha=1
        if changeWorkButton then
          changeWorkButton.alpha=1
        end
        if adminBut then
          adminBut.alpha=1
        end
      end
      local cancelButton = createButton(changeLayer, "ОТМЕНА",965+100-30,"cancelPass")
      cancelButton:addEventListener( "tap", closePCMenu )

      incorrectChange = display.newText({
        parent = changeLayer,
        text = "Ошибка!",
        x=50,
        y=cancelButton.y+50,
        font = "ubuntu_m.ttf",
        fontSize = 16*2} )
      incorrectChange:setFillColor( unpack( q.CL"e07682") )
      incorrectChange.anchorX=0
      incorrectChange.alpha=0
    end, "profile-buttons")



    -- if account.lic=="admin" then
    --   adminBut = createButton(profileGroup, "АДМИН-МЕНЮ",925+125,"id")
    --   adminBut:addEventListener( "tap", toAdmin )
    --   -- -- --
    --   if isDevice then
    --       local data = q.getConnection("static")
    --       statisticResponder({response=data --[[]]})
    --     else
    --     network.request( "http://"..server.."/dashboard/allWorking.php", "GET", statisticResponder )
    --   end

    -- end
  end

  

  q.event.group.on"downBar"
  q.event.group.on("menu-buttons")
  Runtime:addEventListener( "key", onKeyEvent )

  print("menu SHOW state: CREATE")
end


function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

  print("menu SHOW state: "..phase:upper())
	if ( phase == "will" ) then

	elseif ( phase == "did" ) then
    -- openVuz(
    --   {target={options ={vuz = getVuzByName("imisvfu")}}}
    -- )
	end
end


function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

  print("menu HIDE state: "..phase:upper())
	if ( phase == "will" ) then

	elseif ( phase == "did" ) then
    -- q.event.group.off()
    -- composer.removeScene( "menu" )
    -- print("scene hide")
	end
end


function scene:destroy( event )

  print("menu HIDE state: DESTROY")
	local sceneGroup = self.view
  q.event.clearAll()
  chat.reset()

end


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
