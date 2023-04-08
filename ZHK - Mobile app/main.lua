

local composer = require( "composer" )
composer.setVariable( "ip", "127.0.0.1" )
require "text"

display.setStatusBar( display.HiddenStatusBar )
math.randomseed( os.time() )

--[[
do -- Вычесление дробной степени
	local function stepen(num, x)
		local result = 1
		for i=1, x do
	  	result = result * num
	  end
	  return result
	end

	local function mySqrA( x, num, tochnost )
		tochnost = tochnost or 5

		local i = 0
		while stepen(i,x)<num do
			i = i + 1
		end
		if stepen(i,x)==num then
			return i
		end
		i = i - 1
		
		local out = i.."."
		-- print("first ",out:sub(1,-2))
		local i = tonumber(out.."0")
		-- print(i)
		for j=1, tochnost do
			-- print("#"..j)
			while stepen(i,x)<num do
				-- print(i)

				i = i + 1/stepen(10,j)
			end
			i = i - 1/stepen(10,j)
		end

		i = tostring( i )


		local a = (i:find("%.") or 0)+tochnost
		i = i..("0"):rep(a-#i)

		return i
	end

	local function foar( x, y )
		local result = 1
		if y%1==0 then -- если степень целая
		  result = stepen(x,y)
		else

			local stringy = tostring(y) 
			-- local Y = stringy:gsub("%.","") -- Число без запятой (2.675 == 2675)
			-- local Y = tonumber(Y) -- Число без запятой (2.675 == 2675)
			local Y = tonumber((stringy:gsub("%.",""))) -- Число без запятой (2.675 == 2675)


			local len = stepen(10,#stringy-stringy:find("%.")) -- Основания для корня (зависит от кол-ва знаков после запятой)

			local podStepen = stepen(x,Y) -- Возводим число в степень без запятой
			result = mySqrA(len,podStepen) --Вычислаем корень
			-- print("sqr"..len.." ("..x.."^"..Y..") = ...")
			-- print("sqr"..len.." ("..podStepen..") = "..result) 
			if tostring(podStepen)=="inf" then
				print("Error: "..x.."^"..Y.."=inf")
			elseif tostring(result)=="inf" then
				print("Error: sqr"..len.." ("..podStepe..") = inf")
			end

		end
		 return result  
	end

	local function tests( a,b, tochnost )
		print("Testing:  "..a.." ^ "..b )

		tochnost = tochnost or 5
		local foar = tostring(foar(a,b,tochnost))
		local real = tostring(a^b)
		-- print(real)
		if tonumber(real)%1~=0 then
			real = real:sub(1, (real:find("%.") or 0)+tochnost)
		end
		local out = a.."^"..b.." - ".. foar .. '(my) !! ' .. real .. "(math)"
		if foar~=real then
			out = "Warning: ".. out:gsub("!!","!=")
		else
			out = "Complete: ".. out:gsub("!!","==")
		end
		out = out
		print(out.."\n")
	end
	for i=1, 10 do
		local num = math.random( 1,9 )
		local stepen = math.random(0,5)+math.random(0,9)/10
		tests(num, stepen)
	end
end --]]

composer.gotoScene( "authoriz" )