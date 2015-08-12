-----BigReactor Control
-----by jaranvil aka jared314

-----feel free to use and/or mondify this code
-----------------------------------------------

version = 2.2
term.clear()
-------------------FORMATTING-------------------------------
function clear()
	mon.setBackgroundColor(colors.black)
	mon.clear()
	mon.setCursorPos(1,1)
end

function draw_text_term(x, y, text, text_color, bg_color)
	term.setTextColor(text_color)
	term.setBackgroundColor(bg_color)
	term.setCursorPos(x,y)
	write(text)
end

function draw_text(x, y, text, text_color, bg_color)
	mon.setBackgroundColor(bg_color)
	mon.setTextColor(text_color)
	mon.setCursorPos(x,y)
	mon.write(text)
end

function draw_line(x, y, length, color)
		mon.setBackgroundColor(color)
		mon.setCursorPos(x,y)
		mon.write(string.rep(" ", length))
end

function draw_line_term(x, y, length, color)
		term.setBackgroundColor(color)
		term.setCursorPos(x,y)
		term.write(string.rep(" ", length))
end

function progress_bar(x, y, length, minVal, maxVal, bar_color, bg_color)
	draw_line(x, y, length, bg_color) --backgoround bar
	local barSize = math.floor((minVal/maxVal) * length) 
	draw_line(x, y, barSize, bar_color)	--progress so far
end

function progress_bar_term(x, y, length, minVal, maxVal, bar_color, bg_color)
	draw_line_term(x, y, length, bg_color) --backgoround bar
	local barSize = math.floor((minVal/maxVal) * length) 
	draw_line_term(x, y, barSize, bar_color)	--progress so far
end

function button(x, y, length, text, txt_color, bg_color)
	draw_line(x, y, length, bg_color)
	draw_text((x+2), y, text, txt_color, bg_color)
end

function menu_bar()
	draw_line(1, 1, monX, colors.blue)
	draw_text(2, 1, "Power    Tools    Settings", colors.white, colors.blue)
	draw_line(1, 19, monX, colors.blue)
	draw_text(2, 19, "     Reactor Control", colors.white, colors.blue)
end

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

function settings_menu()
	draw_line(12, 2, 18, colors.gray)
	draw_line(12, 3, 18, colors.gray)
	draw_text(13, 2, "Check for Updates", colors.white, colors.gray)
	draw_text(13, 3, "Reset peripherals", colors.white, colors.gray)
end

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

function homepage()
	while true do
		clear()
		menu_bar()
		terminal_screen()

		energy_stored = reactor1.getEnergyStored()
		

		--------POWER STAT--------------
		draw_text(2, 3, "Power:", colors.yellow, colors.black)
		active = reactor1.getActive()
		if active then
			draw_text(10, 3, "ONLINE", colors.lime, colors.black)
		else
			draw_text(10, 3, "OFFLINE", colors.red, colors.black)
		end


		-----------FUEL---------------------
		draw_text(2, 5, "Fuel Level:", colors.yellow, colors.black)
		local maxVal = reactor1.getFuelAmountMax()
		local minVal = reactor1.getFuelAmount() 
		local percent = math.floor((minVal/maxVal)*100)
		draw_text(15, 5, percent.."%", colors.white, colors.black)

		if percent < 25 then
		progress_bar(2, 6, monX-2, minVal, maxVal, colors.red, colors.gray)
		else if percent < 50 then
		progress_bar(2, 6, monX-2, minVal, maxVal, colors.orange, colors.gray)
		else if percent < 75 then	
		progress_bar(2, 6, monX-2, minVal, maxVal, colors.yellow, colors.gray)
		else if percent < 100 then
		progress_bar(2, 6, monX-2, minVal, maxVal, colors.lime, colors.gray)
		end
		end
		end
		end


		-----------ROD HEAT---------------
		draw_text(2, 8, "Fuel Temp:", colors.yellow, colors.black)
		local maxVal = 2000
		local minVal = math.floor(reactor1.getFuelTemperature())

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
		local minVal = math.floor(reactor1.getCasingTemperature())
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
		if reactor1.isActivelyCooled() then

			draw_text(2, 14, "mB/tick:", colors.yellow, colors.black)
			mbt = math.floor(reactor1.getHotFluidProducedLastTick())
			draw_text(13, 14, mbt.." mB/t", colors.white, colors.black)

		else

			draw_text(2, 14, "RF/tick:", colors.yellow, colors.black)
			rft = math.floor(reactor1.getEnergyProducedLastTick())
			draw_text(13, 14, rft.." RF/T", colors.white, colors.black)

		end

		------------STORAGE------------
		if reactor1.isActivelyCooled() then 

			draw_text(2, 15, "mB Stored:", colors.yellow, colors.black)
			fluid_stored = reactor1.getHotFluidAmount()
			fluid_max = reactor1.getHotFluidAmountMax()
			fluid_stored_percent = math.floor((fluid_stored/fluid_max)*100)
			draw_text(13, 15, fluid_stored_percent.."% ("..fluid_stored.." mB)", colors.white, colors.black)

		else

			draw_text(2, 15, "RF Stored:", colors.yellow, colors.black)
			energy_stored_percent = math.floor((energy_stored/10000000)*100)
			draw_text(13, 15, energy_stored_percent.."% ("..energy_stored.." RF)", colors.white, colors.black)


		end

		-------------AUTO CONTROL RODS-----------------------
		auto_rods_bool = auto_rods == "true"
		insertion_percent = reactor1.getControlRodLevel(0)

		if reactor1.isActivelyCooled() then
			draw_text(2, 16, "Control Rods:", colors.yellow, colors.black)
			draw_text(16, 16, insertion_percent.."%", colors.white, colors.black)
		else

			if auto_rods_bool then
				if active then
					if rft > auto_rf+50 then
						reactor1.setAllControlRodLevels(insertion_percent+1)
					else if rft < auto_rf-50 then
						reactor1.setAllControlRodLevels(insertion_percent-1)
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
		if reactor1.isActivelyCooled() then

			--i dont know what I should do here


		else
			auto = auto_string == "true"
			if auto then
				if active then
					draw_text(2, 17, "Auto off:", colors.yellow, colors.black)
					draw_text(13, 17, off.."% RF Stored", colors.white, colors.black)
					if energy_stored_percent >= off then
						reactor1.setActive(false)
						call_homepage()
					end
				else
					draw_text(2, 17, "Auto on:", colors.yellow, colors.black)
					draw_text(13, 17, on.."% RF Stored", colors.white, colors.black)
					if energy_stored_percent <= on then
						reactor1.setActive(true)
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

---------------Power---------------
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

-------------------Tools----------------------

function efficiency()
	popup_screen(3, "Efficiency", 12)
	fuel_usage = reactor1.getFuelConsumedLastTick()
	rft = math.floor(reactor1.getEnergyProducedLastTick())

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
	popup_screen(5, "Fuel", 9)

	fuel_max = reactor1.getFuelAmountMax()
	fuel_level = reactor1.getFuelAmount()
	fuel_reactivity = math.floor(reactor1.getFuelReactivity())

	draw_text(5, 7, "Fuel Level: ", colors.lime, colors.white)
	draw_text(5, 8, fuel_level.."/"..fuel_max, colors.black, colors.white)

	draw_text(5, 10, "Reactivity: ", colors.lime, colors.white)
	draw_text(5, 11, fuel_reactivity.."%", colors.black, colors.white)

	draw_text(11, 13, " Okay ", colors.white, colors.black)

	local event, side, xPos, yPos = os.pullEvent("monitor_touch")


	--Okay button
	if yPos == 13 and xPos >= 11 and xPos <= 17 then 
		call_homepage()
	end

	--Exit button
	if yPos == 5 and xPos == 25 then 
		call_homepage()
	end

	fuel()
end

function waste()
	popup_screen(5, "Waste", 8)

	waste_amount = reactor1.getWasteAmount()
	draw_text(5, 7, "Waste Amount: ", colors.lime, colors.white)
	draw_text(5, 8, waste_amount.." mB", colors.black, colors.white)
	draw_text(8, 10, " Eject Waste ", colors.white, colors.red)
	draw_text(11, 12, " Close ", colors.white, colors.black)

	local event, side, xPos, yPos = os.pullEvent("monitor_touch")

	--eject button
	if yPos == 10 and xPos >= 8 and xPos <= 21 then 
		reactor1.doEjectWaste()
		popup_screen(5, "Waste Eject", 5)
		draw_text(5, 7, "Waste Ejeceted.", colors.black, colors.white)
		draw_text(11, 9, " Close ", colors.white, colors.black)
		local event, side, xPos, yPos = os.pullEvent("monitor_touch")
		--Okay button
		if yPos == 9 and xPos >= 11 and xPos <= 17 then 
			call_homepage()
		end

		--Exit button
		if yPos == 5 and xPos == 25 then 
			call_homepage()
		end
	end

	--Okay button
	if yPos == 12 and xPos >= 11 and xPos <= 17 then 
		call_homepage()
	end

	--Exit button
	if yPos == 5 and xPos == 25 then 
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

	if reactor1.isActivelyCooled() then 

		popup_screen(3, "Control Rods", 13)
		insertion_percent = reactor1.getControlRodLevel(0)

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
			reactor1.setAllControlRodLevels(insertion_percent-10)
		end

		if yPos == 9 and xPos >= 10 and xPos <= 13 then 
			reactor1.setAllControlRodLevels(insertion_percent-1)
		end

		if yPos == 9 and xPos >= 17 and xPos <= 20 then 
			reactor1.setAllControlRodLevels(insertion_percent+1)
		end

		if yPos == 9 and xPos >= 21 and xPos <= 25 then 
			reactor1.setAllControlRodLevels(insertion_percent+10)
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
		insertion_percent = reactor1.getControlRodLevel(0)

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
			reactor1.setAllControlRodLevels(insertion_percent-10)
		end

		if yPos == 9 and xPos >= 10 and xPos <= 13 then 
			reactor1.setAllControlRodLevels(insertion_percent-1)
		end

		if yPos == 9 and xPos >= 17 and xPos <= 20 then 
			reactor1.setAllControlRodLevels(insertion_percent+1)
		end

		if yPos == 9 and xPos >= 21 and xPos <= 25 then 
			reactor1.setAllControlRodLevels(insertion_percent+10)
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
		draw_text(11, 9, " Intall ", colors.white, colors.black)
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

function mon_touch()
	--when the monitor is touch on the homepage
	if y == 1 then 
			if x < monX/3 then
				power_menu()
				local event, side, xPos, yPos = os.pullEvent("monitor_touch")
				if xPos < 9 then
					if yPos == 2 then
						reactor1.setActive(true)
						timer = 0 --reset anytime the reactor is turned on/off
						call_homepage()
					else if yPos == 3 then
						reactor1.setActive(false)
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

--try to wrap peripherals
--catch any errors
	function test_reactor_connection()
		reactor1 = peripheral.wrap(name)  --wrap reactor
		c = reactor1.getConnected() 
	    if unexpected_condition then error() end   
	end

	function test_monitor_connection()
		mon = peripheral.wrap(side) --wrap mon
		monX, monY = mon.getSize() --get mon size () 
	    if unexpected_condition then error() end   
	end

function save_config()
	sw = fs.open("config.txt", "w")		
		sw.writeLine(version)
		sw.writeLine(side)
		sw.writeLine(name)
		sw.writeLine(auto_string)
		sw.writeLine(on)
		sw.writeLine(off)
		sw.writeLine(auto_rods)
		sw.writeLine(auto_rf)
	sw.close()
end

function load_config()
	sr = fs.open("config.txt", "r")
		version = tonumber(sr.readLine())
		side = sr.readLine()
		name = sr.readLine()
		auto_string = sr.readLine()
		on = tonumber(sr.readLine())
		off = tonumber(sr.readLine())
		auto_rods = sr.readLine()
		auto_rf = tonumber(sr.readLine())
	sr.close()
end

--test if the entered monitor and reactor can be wrapped
	function test_configs()
		term.clear()
		draw_line_term(1, 1, 55, colors.blue)
		draw_text_term(10, 1, "BigReactor Controls v"..version, colors.white, colors.blue)
		draw_line_term(1, 19, 55, colors.blue)
		draw_text_term(10, 19, "by jaranvil aka jared314", colors.white, colors.blue)

		draw_text_term(1, 3, "Wrapping peripherals...", colors.blue, colors.black)
		draw_text_term(2, 5, "wrap montior...", colors.white, colors.black)
		sleep(0.1)
		if pcall(test_monitor_connection) then 
			draw_text_term(18, 5, "success", colors.lime, colors.black)
		else
			draw_text_term(1, 4, "Error:", colors.red, colors.black)
			draw_text_term(1, 8, "Could not connect to monitor on "..side.." side", colors.red, colors.black)
			draw_text_term(1, 9, "Valid sides are 'left', 'right', 'top', 'bottom' and 'back'", colors.white, colors.black)
			draw_text_term(1, 11, "Press Enter to continue...", colors.gray, colors.black)
			wait = read()
			setup_wizard()
		end
		sleep(0.1)
		draw_text_term(2, 6, "wrap reactor...", colors.white, colors.black)
		sleep(0.1)
		if pcall(test_reactor_connection) then 
			draw_text_term(18, 6, "success", colors.lime, colors.black)
		else
			draw_text_term(1, 8, "Error:", colors.red, colors.black)
			draw_text_term(1, 9, "Could not connect to "..name, colors.red, colors.black)
			draw_text_term(1, 10, "Reactor must be connected with networking cable and wired modem", colors.white, colors.black)
			draw_text_term(1, 12, "Press Enter to continue...", colors.gray, colors.black)
			wait = read()
			setup_wizard()
		end
		sleep(0.1)
		draw_text_term(2, 8, "saving settings to file...", colors.white, colors.black)	

		save_config()

		sleep(0.1)
		draw_text_term(1, 10, "Setup Complete!", colors.lime, colors.black)	
		sleep(1)

		auto = auto_string == "true"
		call_homepage() 

end
----------------SETUP-------------------------------

function setup_wizard()
	term.clear()
	draw_text_term(1, 1, "BigReactor Controls v"..version, colors.lime, colors.black)
	draw_text_term(1, 2, "Peripheral setup wizard", colors.white, colors.black)
	draw_text_term(1, 4, "Step 1:", colors.lime, colors.black)
	draw_text_term(1, 5, "-Place 3x3 advanced monitors next to computer.", colors.white, colors.black)
	draw_text_term(1, 7, "Step 2:", colors.lime, colors.black)
	draw_text_term(1, 8, "-Place a wired modem on this computer and on the ", colors.white, colors.black)
	draw_text_term(1, 9, " computer port of the reactor.", colors.white, colors.black)
	draw_text_term(1, 10, "-connect modems with network cable.", colors.white, colors.black)
	draw_text_term(1, 11, "-right click modems to activate.", colors.white, colors.black)
	draw_text_term(1, 13, "Press Enter when ready...", colors.gray, colors.black)
	
	wait = read()
	
	term.clear()
	draw_text_term(1, 1, "Peripheral Setup", colors.lime, colors.black)
	draw_text_term(1, 3, "What side is your monitor on?", colors.yellow, colors.black)

	term.setTextColor(colors.white) 
	term.setCursorPos(1,4)
	side = read()

	term.clear()
	draw_text_term(1, 1, "Peripheral Setup", colors.lime, colors.black)
	draw_text_term(1, 3, "What is the reactor's name?", colors.yellow, colors.black)
	draw_text_term(1, 4, "type 'default' for  'BigReactors-Reactor_0'", colors.gray, colors.black)

	term.setTextColor(colors.white) 
	term.setCursorPos(1,5)
	name = read()

	if name == "default" then name = "BigReactors-Reactor_0" end
	auto_string = false
	on = 0
	off = 99
	auto_rods = false
	auto_rf = 0

	test_configs()
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