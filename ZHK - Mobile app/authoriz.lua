
local backGroup, mainGroup, uiGroup
local composer = require( "composer" )

local scene = composer.newScene()
local isDevice = system.getInfo("environment") == "device"
local darkMode = system.getInfo("darkMode")
local json = require( "json" )
local accounts = {} 

local q = require"base"
local crypto = require( "crypto" )
-- local hash = crypto.digest( crypto.md5, "test" )
-- print( hash )
 
local accounts = {} 

local pps = require"popup"
pps.init(q)

local fieldsTable = {}
darkMode = false
local c
if darkMode~=true then
	c = {
	  	text1 = {.97},
		appColor = q.CL"0058EE",
		white = q.CL"000000",
		prewhite = q.CL"F9FAFB",
		ultrablack = q.CL"CCCCCC",
		black = q.CL"FFFFFF",
		gray = q.CL"DEDEDE",
		blue = q.CL"0058EE",
		outline = q.CL"9F9F9F",
	}
else
	c = {
	  backGround = {.08,.08,.18},
	  text1 = {.97},
	  -- text1 = {.97},
	  textOnBack = {.97},
	  textOnGround = {.97},
	  invtext1 = {.03},
	  mainButtons = q.CL"ADB5BD",
	  fieldBack = {.92},

	  upBackLogo = {1,.3},
		hideButton = {1,0,0,.01},

	  buttons = q.CL"ADB5BD",
	  mainButtons = q.CL"ADB5BD",
	  appColor = q.CL"FD4801",
	}
end

local function getSpaceWidth(font,fontSize)
	local label = display.newText( " ", -1000, -1000, font, fontSize )
	local w, h = label.width, label.height
	display.remove( label )
	return w, h
end

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

end

local function createField( group, y, label, name, discription )

	local back = display.newRoundedRect(group, 50, y, q.fullw-50*2, 92, 6)
	back.fill = c.gray
	back.anchorX = 0

	textWithLetterSpacing({
		parent = group,
		text = label,
		x = 50,
		y = y-back.height*.5-48,
		font = "ubuntu_r.ttf",
		fontSize = 14*2,
		color = c.white,
	}, 10)

	local logField = native.newTextField(back.x+20, back.y, back.width-20, 90)
	group:insert( logField )
	logField.anchorX=0
	logField.isEditable=true
	logField.hasBackground = false
	logField.placeholder = discription
	logField.font = native.newFont( "ubuntu_r.ttf",16*2)
	logField:resizeHeightToFitFont()
	fieldsTable[name] = logField

	return 92+38+20
end
local incorrectLabel
local function showWarnin(text,time)
	time = time~=nil and time or 2000
	incorrectLabel.text=text
	incorrectLabel.alpha=1
	incorrectLabel.fill.a=1
	timer.performWithDelay( time, 
	function()
		transition.to(incorrectLabel.fill,{a=0,time=500} )
	end)
end


local function validemail(str)
  if str == nil then return nil end
  if str:len() == 0 then return nil, "Введите почту" end
  if (type(str) ~= 'string') then
    error("Expected string")
    return nil
  end
  if not str:find("%@.") then 
    return nil, "Часть после @ некорректна!"
  end
  local lastAt = str:find("[^%@]+$")
  local localPart = str:sub(1, (lastAt - 2)) -- Returns the substring before '@' symbol
  local domainPart = str:sub(lastAt, #str) -- Returns the substring after '@' symbol
  -- we werent able to split the email properly
  if localPart == nil then
    return nil, "Часть до @ некорректна!"
  end

  if domainPart == nil or not domainPart:find("%.") then
    return nil, "Часть после @ некорректна!"
  end
  if string.sub(domainPart, 1, 1) == "." then
    return nil, "Первый символ не может быть точкой!"
  end
  -- local part is maxed at 64 characters
  if #localPart > 64 then
    return nil, "Часть до @ должна быть меньше 64симв.!"
  end
  -- domains are maxed at 253 characters
  if #domainPart > 253 then
    return nil, "Часть после @ должна быть меньшк 253симв.!"
  end
  -- somthing is wrong
  if lastAt >= 65 then
    return nil, "Что-то не так..."
  end
  -- quotes are only allowed at the beginning of a the local name
  local quotes = localPart:find("[\"]")
  if type(quotes) == 'number' and quotes > 1 then
    return nil, "Неправильно расположены кавычки!"
  end
  -- no @ symbols allowed outside quotes
  if localPart:find("%@+") and quotes == nil then
    return nil, "Слишком много @!"
  end
  -- no dot found in domain name
  if not domainPart:find("%..") then
    return nil, "Нет .com/.ru части!"
  end
  -- only 1 period in succession allowed
  if domainPart:find("%.%.") then
    return nil, "Две точки подряд после @!"
  end
  if localPart:find("%.%.") then
    return nil, "Две точки подряд до @!"
  end
  -- just a general match
  if not str:match('[%w]*[%p]*%@+[%w]*[%.]?[%w]*') then
    return nil, "Проверка валидности почты провалена!"
  end
  -- all our tests passed, so we are ok
  return true
end

local headers = {
	["Content-Tpe"] = "application/json", 
	["Accept-Language"] = "en-US",
}
-- ========[[[ ]]]======== --

-- local countError = 5
-- local goButton
-- local function gotoOfflineMode()
-- 	exit = true
-- 	local user = {
-- 		mail = "none@none.nome",
-- 		password = "123456789",
-- 		name = "Офлайн режим .",
-- 		id = 1,
-- 		status = "offline",
-- 		test = {"..<24","Да, всеми","Показали волонтёры"},
-- 		signupdate = "01.01.0001"
-- 	}
-- 	q.saveLogin(user)
-- 	composer.gotoScene("menu")
-- 	composer.removeScene( "signin" )
-- end
-- local function noInternerPop( event )
-- 	if nowScene=="noInternet" then return end
-- 	local allPopGroup = display.newGroup()
--   local eventGroupName = pps.popUp("noInternet", allPopGroup)

--  	local backBlackTone = display.newRect(allPopGroup, q.cx, q.cy, q.fullw, q.fullh)
--  	backBlackTone.fill = {0,0,0,.2}

--  	transition.to(allPopGroup, {y = -300, time = 500})

--  	local backWhite = display.newRoundedRect(allPopGroup, q.cx, q.fullh-30, q.fullw, 360, 40)
--  	backWhite.fill = {.88}--c.backGround
--  	backWhite.anchorY = 0

--  	local noEthLabel = display.newText( {
-- 		parent = allPopGroup,
-- 		text = "Нет подключения к интернету...",
-- 		x = 40,
-- 		y = q.fullh + 10,
-- 		font = "ubuntu_b.ttf",
-- 		fontSize = 16*2,
-- 		} )
-- 	noEthLabel.anchorX = 0
-- 	noEthLabel.anchorY = 0
-- 	noEthLabel.fill = {0}--c.text1

-- 	local offlineLabel = display.newText( {
-- 		parent = allPopGroup,
-- 		text = "Вы можете войти без регистрации в оффлайн режим",
-- 		x = 40,
-- 		y = q.fullh + 10 + 50,
-- 		font = "ubuntu_r.ttf",
-- 		fontSize = 12*2,
-- 		} )
-- 	offlineLabel.anchorX = 0
-- 	offlineLabel.anchorY = 0
-- 	offlineLabel.fill ={0}--c.text1

-- 	local offButton = display.newRoundedRect( allPopGroup, q.cx, q.fullh+130, q.fullw-120, 110, 30)
-- 	offButton.anchorY=0
-- 	offButton.fill = {.7}

-- 	local offContinue = textWithLetterSpacing( {
-- 		parent = allPopGroup, 
-- 		text = "ОФФЛАЙН - РЕЖИМ", 
-- 		x = q.cx, 
-- 		y = offButton.y+55, 
-- 		font = "ubuntu_b.ttf", 
-- 		fontSize = 14*2,
-- 		color = {.97},
-- 	}, 10, .5)

-- 	q.event.add("tryConnectionAgain", backBlackTone, function()
-- 		if countError==0 then
--   		network.request( jsonLink, "GET", loadAllUsers )
-- 		end
-- 		countError = 10
--  		transition.to(allPopGroup, {y = 0, time = 500, onComplete = pps.removePop})

-- 	end, eventGroupName)

-- 	q.event.add("noEthGotoOffline", offButton, gotoOfflineMode, eventGroupName)
	
-- 	q.event.group.on(eventGroupName)

-- end
local sendInfo

local function authResponse( event )
	if ( event.isError)  then
		print( "Error!" )
		showWarnin("Ошибка подключения: "..tostring(event.response))
	else
		local myNewData = event.response
		q.saveLogin(json.decode(myNewData))
		composer.gotoScene("menu")
		composer.removeScene( "authoriz" )

		

	end

end


local function serverResponse( event )
	if ( event.isError)  then
		print( "Error!" )
		showWarnin("Ошибка подключения: "..tostring(event.response))
	else
	  local myNewData = event.response
	  if myNewData:find("Authorize Done") or myNewData:find("Login done") then
		
		local params = {}
		params.headers = headers
		params.body = json.encode( {email=sendInfo.email} )

		network.request( "http://127.0.0.1/gisit23/js_get_user.php", "POST", authResponse, params )

		-- q.saveLogin(sendInfo)
		-- composer.gotoScene("menu")
		-- composer.removeScene( "authoriz" )
	  elseif myNewData:find("Already registered") then
		showWarnin("Почта занята")
	  elseif myNewData:find("Login failed") then
		showWarnin("Неверная пара логин/пароль")
	  end
	--   local responeTable = json.decode( myNewData )
	--   if responeTable==nil or responeTable.error~=nil then
	-- 	showWarnin("Неверная пара логин/пароль")
		-- print("Error: Server reg resoponse - "..myNewData	)
		-- if responeTable~=nil then
		-- 		  if responeTable.error=="error" then 
		-- 			  showWarnin("Неверная пара логин/пароль")
		-- 		  elseif responeTable.error.email[1]=="The email has already been taken." then 
		-- 			  showWarnin("Почта занята")
		-- 		  end
		-- 	  end
		-- return
	--   elseif myNewData:sub(1,1)=='{' then
	-- 	print("Warning: server reg resoponse: успешно")
	-- 	print(myNewData)
	-- 		  q.saveLogin(json.decode( myNewData ))
	-- 		  composer.gotoScene("menu")
	-- 		  composer.removeScene( "signin" )
	--   end
	--   print(myNewData)
	end
  end



local signUpMenu
local function signInMenu()

	local signInGroup = display.newGroup()
  	local eventGroupName = pps.popUp("signIn", signInGroup)

	local back = display.newRect(signInGroup,q.cx,q.cy,q.fullw,q.fullh)
	back.fill = c.black

	local backTop = display.newRect(signInGroup,q.cx,0,q.fullw,440)
	backTop.anchorY = 0
	backTop.fill = c.ultrablack


	local backLogo = display.newRoundedRect( signInGroup, q.cx, backTop.height*.5, 180, 180, 14*2 )
	backLogo.fill = c.gray

	local labelSignIn = display.newText( {
		parent = signInGroup,
		text = "Вход",
		x = 50,
		y = 440+100,
		font = "ubuntu_b.ttf",
		fontSize = 24*2,
	} )
	labelSignIn.anchorX = 0
	labelSignIn.fill = c.white

	local labelDiscription = display.newText( {
		parent = signInGroup,
		text = "Войдите в аккаунт",
		x = 50,
		y = 440+100+70,
		font = "ubuntu_r.ttf",
		fontSize = 16*2,
	} )
	labelDiscription.anchorX = 0
	labelDiscription.fill = c.white


	submitButton = display.newRoundedRect(signInGroup, 50, q.fullh-50, q.fullw-50*2, 92, 6)
	submitButton.anchorX=0
	submitButton.anchorY=1
	submitButton.fill = c.blue

	local labelContinue = textWithLetterSpacing( {
		parent = signInGroup, 
		text = "ВОЙТИ", 
		x = submitButton.x+submitButton.width*.5, 
		y = submitButton.y-submitButton.height*.5, 
		font = "ubuntu_b.ttf", 
		fontSize = 14*2
	}, 10, .5)


	incorrectLabel = display.newText( {
		parent = signInGroup, 
		text = "Неверная пара логин/пароль!", 
		x = 60, 
		y = 1180,
		width = q.fullw - 60*2, 
		font = "roboto_r.ttf", 
		fontSize = 37
	})
	incorrectLabel:setFillColor( unpack( q.CL"e07682") )
	incorrectLabel.anchorX=0
	incorrectLabel.anchorY=0
	incorrectLabel.alpha=0	


	createField( signInGroup, 1120-240, "ПОЧТА", "mail", "Введите почту" )
	createField( signInGroup, 1120, "ПАРОЛЬ","pass", "Введите пароль" )

	fieldsTable.mail.text = "admin@gmail.com"
	fieldsTable.mail.inputType = "email"

	fieldsTable.pass.text = "12345678"
	fieldsTable.pass.isSecure = true
	fieldsTable.pass.inputType = "no-emoji"


	-- q.event.add("orToRegister",orLoginButton, function()
	-- 	pps.removePop()
	-- 	fieldsTable = {}
	-- 	signUpMenu()
	-- end, eventGroupName)
	-- q.event.add("finishSignIn", submitButton, submitSignIn, eventGroupName)
	
	-- q.event.group.on(eventGroupName)
end

local function submitSignUp(event)

	local submitButton = event.target
	submitButton.fill = q.CL"4d327a"
	local r,g,b = unpack( c.appColor )
	timer.performWithDelay( 400, 
	function()
		transition.to(submitButton.fill,{r=r,g=g,b=b,time=300} )
	end)

	local email, pass, name = fieldsTable.UPemail.text, fieldsTable.UPpass.text, fieldsTable.UPname.text
	email = q.trim(email)
	email = email:lower()
	name = q.trim(name)
	name = name:gsub("%s%s","%s")

	fieldsTable.UPemail.text = email
	fieldsTable.UPname.text = name

	print(email, pass, name)
	local allows, errorMail = validemail(email)
	if #name==0 then
		showWarnin("Введите ФИО")
	elseif #name<10 then
		showWarnin("ФИО от 10 символов")
	elseif not allows then
		showWarnin(errorMail and errorMail or "mail")
	elseif #pass==0 then
		showWarnin("Введите пароль")
	elseif #pass<8 then
		showWarnin("Пароль от 8 символов")
	elseif pass:find("%s") then
		showWarnin("Пароль не должен содержать пробелы")
	else
		

		if isDevice then
			q.saveLogin({
				name = name,
				email = email,
				id = 12,
				region = "Yakutsk",
			})
			composer.gotoScene("menu")
			composer.removeScene( "authoriz" )
		else
			sendInfo = {
				name = name,
				password = crypto.digest( crypto.md5, pass ),
				email = email,
			}
			
			local params = {}
			params.headers = headers
			params.body = json.encode( sendInfo )

			network.request( "http://127.0.0.1/gisit23/js_register.php", "POST", serverResponse, params )
		end
	end
end
signUpMenu = function()

	local signUpGroup = display.newGroup()
	local eventGroupName = pps.popUp("signUp", signUpGroup, {
		onHide=function()
			for k, v in pairs(fieldsTable) do
				v.x = q.fullw
			end
		end,
		onShow=function()
			for k, v in pairs(fieldsTable) do
				v.x = 70
			end
		end,
	})

	local back = display.newRect(signUpGroup,q.cx,q.cy,q.fullw,q.fullh)
	back.fill = c.black


	local backTop = display.newRect(signUpGroup,q.cx,0,q.fullw,440)
	backTop.anchorY = 0
	backTop.fill = c.ultrablack


	local backLogo = display.newRoundedRect( signUpGroup, q.cx, backTop.height*.5, 180, 180, 14*2 )
	backLogo.fill = c.gray

	local labelSignIn = display.newText( {
		parent = signUpGroup,
		text = "Регистрация",
		x = 50,
		y = 440+100,
		font = "ubuntu_b.ttf",
		fontSize = 24*2,
		} )
	labelSignIn.anchorX = 0
	labelSignIn.fill = c.white

	local labelDiscription = display.newText( {
		parent = signUpGroup,
		text = "Создайте свой аккаунт",
		x = 50,
		y = 440+100+80,
		font = "ubuntu_r.ttf",
		fontSize = 16*2,
		} )
	labelDiscription.anchorX = 0
	labelDiscription.fill = c.white


	createField( signUpGroup, 1120-240, "ПОЧТА", "UPemail", "Введите почту" )
	fieldsTable.UPemail.inputType = "email"
	createField( signUpGroup, 1120-50, "ПАРОЛЬ","UPpass", "Введите пароль" )
	fieldsTable.UPpass.inputType = "no-emoji"

	createField( signUpGroup, 1120+240-100, "ФИО","UPname", "Фамалия Имя Отчество" )
	fieldsTable.UPname.inputType = "no-emoji"


	submitButton = display.newRoundedRect(signUpGroup, 50, q.fullh-50, q.fullw-50*2, 92, 6)
	submitButton.anchorX=0
	submitButton.anchorY=1
	submitButton.fill = c.blue


	local labelContinue = textWithLetterSpacing( {
		parent = signUpGroup, 
		text = "РЕГИСТРАЦИЯ", 
		x = submitButton.x+submitButton.width*.5, 
		y = submitButton.y-submitButton.height*.5, 
		font = "ubuntu_b.ttf", 
		fontSize = 14*2
		}, 10, .5)

	local label = display.newText( {
		parent = signUpGroup, 
		text = "Уже есть аккаунт?",
		x = 60,
		y = 1120+240-20, 
		font = "ubuntu_b.ttf", 
		fontSize = 16*2
		})
	label:setFillColor( unpack(c.white) )
	label.alpha = .5
	label.anchorX=0


	incorrectLabel = display.newText( {
		parent = signUpGroup, 
		text = "Неверная пара логин/пароль!", 
		x = 60, 
		y = q.fullh-195,
		width = q.fullw - 60*2, 
		font = "roboto_r.ttf", 
		fontSize = 37})
	incorrectLabel:setFillColor( unpack( q.CL"e07682") )
	incorrectLabel.anchorX=0
	incorrectLabel.anchorY=0
	incorrectLabel.alpha=0


	-- local labelSucess = display.newText( {
	-- 	parent = finishGroup,
	-- 	text = "Регистрация завершена",
	-- 	x = 50,
	-- 	y = 440+100,
	-- 	font = "ubuntu_b.ttf",
	-- 	fontSize = 24*2,
	-- 	} )
	-- labelSucess.anchorX = 0
	-- labelSucess:setFillColor(unpack(c.white))

	-- local labelDiscription = display.newText( {
	-- 	parent = finishGroup,
	-- 	text = "Теперь для можете входить в аккаунт",
	-- 	x = 50,
	-- 	y = 440+100+80+20,
	-- 	width = q.fullw-120,
	-- 	font = "ubuntu_r.ttf",
	-- 	fontSize = 16*2,
	-- 	} )
	-- labelDiscription.anchorX = 0
	-- labelDiscription:setFillColor(unpack(c.white))

	-- local labelContinue = textWithLetterSpacing( {
	-- 	parent = finishGroup, 
	-- 	text = "ОК", 
	-- 	x = submitButton.x+submitButton.width*.5, 
	-- 	y = submitButton.y-submitButton.height*.5, 
	-- 	font = "ubuntu_b.ttf", 
	-- 	fontSize = 14*2
	-- 	}, 10, .5)


	fieldsTable.UPemail.text = "admin@gmail.com"
	fieldsTable.UPpass.text = "12345678"
	fieldsTable.UPname.text = "Lev Love Lol"


	-- label:addEventListener( "tap", function()
	-- 	for k,v in pairs(fieldsTable) do
	-- 		display.remove(fieldsTable[k])
	-- 	end
	-- 	timer.performWithDelay( 1, function()
	-- 		composer.gotoScene("signin")
	-- 	end )
	-- end )
	-- q.event.add("finishSignIn", submitButton, submitSignIn, eventGroupName)
	q.event.add("finishSignIn", submitButton, submitSignUp, eventGroupName)
	-- submitButton:addEventListener( "tap", submitFunc )
	
	q.event.group.on(eventGroupName)

	-- noInternerPop()
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
      pps.removePop()
      
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
    print( message )

    if ( event.phase == "down" ) then
      if key=="escape" and nowScene~="menu" and nowScene~="chatlist" then
        -- display.remove(newPopUp)
        pps.removePop()
      end
    end

  end
end
function scene:create( event )
	local sceneGroup = self.view

	backGroup = display.newGroup()
	sceneGroup:insert(backGroup)


	mainGroup = display.newGroup()
	sceneGroup:insert(mainGroup)
	mainGroup.alpha = 0

	local welcomeGroup = display.newGroup()
	sceneGroup:insert(welcomeGroup)
	
	uiGroup = display.newGroup()
	sceneGroup:insert(uiGroup)


	local back = display.newRect(backGroup,q.cx,q.cy,q.fullw,q.fullh)
	back.fill = c.black


	do -- Г Л А В Н Ы Й

		local welcomeImage = display.newImageRect( welcomeGroup, "img/welcome.png", q.fullw, q.fullw*1.45 )
		welcomeImage.x = q.cx
		welcomeImage.y = q.fullh*.35

		local regButton = display.newRoundedRect(welcomeGroup, 60, q.fullh-50-130, q.fullw-60*2, 110, 30)
		regButton.anchorX=0
		regButton.anchorY=1
		regButton.fill = c.blue

		local labelContinue = textWithLetterSpacing( {
			parent = welcomeGroup, 
			text = "НАЧАТЬ", 
			x = regButton.x+regButton.width*.5, 
			y = regButton.y-regButton.height*.5,  
			font = "ubuntu_b.ttf", 
			fontSize = 14*2,
			color = c.black,
		}, 10, .5)


		local signButton = display.newRoundedRect(welcomeGroup, 60, q.fullh-50, q.fullw-60*2, 110, 30)
		signButton.anchorX=0
		signButton.anchorY=1
		signButton.fill = c.black

		local labelContinue = textWithLetterSpacing( {
			parent = welcomeGroup, 
			text = "ВОЙТИ", 
			x = q.cx, 
			y = q.fullh-105,  
			font = "ubuntu_b.ttf", 
			fontSize = 14*2,
			color = c.blue,
		}, 10, .5)
	
		q.event.add("toSignIn", signButton, signInMenu, "hub-popUp")
		q.event.add("toRegister", regButton, signUpMenu, "hub-popUp")

		pps.addMainScene("hub", welcomeGroup, {
		onShow = function()
			goButton = nil
			incorrectLabel.alpha = 0
		end})
		q.event.group.on("hub-popUp")
	end

	incorrectLabel = display.newText( {
		parent = uiGroup, 
		text = "Неверная пара логин/пароль!", 
		x = q.fullw-50, 
		y = q.fullh-195,
		width = q.fullw - 60*2,
		align = "right", 
		font = "img/hindv_b.ttf", 
	fontSize = 30})
	incorrectLabel:setFillColor( unpack( c.appColor) )
	incorrectLabel.anchorX=1
	incorrectLabel.anchorY=0
	incorrectLabel.alpha=0
	
  	Runtime:addEventListener( "key", onKeyEvent )
end


function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

		for k,v in pairs(fieldsTable) do
			fieldsTable[k].x = 70
		end

	elseif ( phase == "did" ) then
		local accountInfo = q.loadLogin()
		if accountInfo~=nil and accountInfo~={} and accountInfo["password"]~=nil and accountInfo["password"]~="" then
			print(accountInfo.name)
			composer.gotoScene( "menu" )
			composer.removeScene( "signin" )
		end

	end
end


function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
    	Runtime:removeEventListener( "key", onKeyEvent )
		pps.reset()
		if allUsers then
  		composer.setVariable( "allUsers", allUsers)
		end

	elseif ( phase == "did" ) then
	end
end


function scene:destroy( event )

	local sceneGroup = self.view

end


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
