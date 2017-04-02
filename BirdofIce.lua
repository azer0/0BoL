if myHero.charName ~= "Anivia" then return end

local scriptInfo = {
	doWeUpdate = false,
	doWeDownload = true,
	Version = 1
}

function LibDownloaderPrint(msg)
	print("<font color=\"#FF794C\"><b>Bird of Ice</b></font> <font color=\"#FFDFBF\"><b>"..msg.."</b></font>")
end
	
if scriptInfo.doWeDownload then
	local toDownload = {
		--Librarys
		["0Library"] = "https://raw.githubusercontent.com/azer0/0BoL/master/0Library.lua",
		--Predictions
		["FHPrediction"] = "http://api.funhouse.me/download-lua.php",
		["TRPrediction"] = "https://raw.githubusercontent.com/Project4706/BoL/master/TRPrediction.lua",
		["DPrediction"] = "https://raw.githubusercontent.com/Nader-Sl/BoLStudio/master/Scripts/Common/DivinePred.lua",
		["VPrediction"] = "https://raw.githubusercontent.com/SidaBoL/Chaos/master/VPrediction.lua",
	}

	local isDownloading = false
	local downloadCount = 0

	function FileDownloaded()
		downloadCount = downloadCount - 1
		if downloadCount == 0 then
			isDownloading = false
			LibDownloaderPrint("<font color=\"#6699FF\">Download(s) complete. Please press F9 twice to reload.</font>")
		end
	end

	for libName, libUrl in pairs(toDownload) do
		if FileExist(LIB_PATH .. libName .. ".lua") then
			require(libName)
		else
			isDownloading = true
			downloadCount = downloadCount + 1
			LibDownloaderPrint("<font color=\"#6699FF\">Downloading " .. libName .. ".</font>")
			DownloadFile(libUrl, LIB_PATH .. libName .. ".lua", FileDownloaded)
		end
	end
	
	if isDownloading then
		LibDownloaderPrint("<font color=\"#6699FF\">Please double F9 after downloads are done.</font>")
		--return
	end
else
	require("0Library")
	require("VPrediction")
	require("FHPrediction")
	require("TRPrediction")
	LibDownloaderPrint("<font color=\"#6699FF\">Loaded required librarys.</font>")
end

if scriptInfo.doWeUpdate then
	local UpdateHost = "raw.github.com"
	local UpdatePath = "/azer0/0BoL/master/Version/BirdofIce.Version?rand=" .. math.random(1, 10000)
	local UpdatePath2 = "/azer0/0BoL/master/BirdofIce.lua?rand=" .. math.random(1, 10000)
	local UpdateFile = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
	local VersionURL = "http://"..UpdateHost..UpdatePath
	local UpdateURL = "http://"..UpdateHost..UpdatePath2

	function AutoUpdaterPrint(msg)
		print("<font color=\"#FF794C\"><b>Bird of Ice</b></font> <font color=\"#FFDFBF\"><b>"..msg.."</b></font>")
	end

	local hasBeenUpdated = false

	local sData = GetWebResult(UpdateHost, UpdatePath)
	if sData then
		local sVer = type(tonumber(sData)) == "number" and tonumber(sData) or nil
		if sVer and sVer > scriptInfo.Version then
			AutoUpdaterPrint("New update found [v" .. sVer .. "].")
			AutoUpdaterPrint("Please do not reload until complete.")
			DownloadFile(UpdateURL, UpdateFile, function () AutoUpdaterPrint("Successfully updated. ("..scriptInfo.Version.." => "..sVer.."), press F9 twice to use the updated version.") end)
			hasBeenUpdated = true
		end
	end

	if hasBeenUpdated then
		return
	end
end

local minionMan = minionManager(MINION_ENEMY, 1000, myHero, MINION_SORT_HEALTH_ASC)
local jungleManager = minionManager(MINION_JUNGLE, 1000, myHero, MINION_SORT_HEALTH_ASC)
local targetManager = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1200, DAMAGE_MAGIC, true)

targetManager.name = myHero.name

local aaRange = 600
local aniviaQ = {
	missle = nil,
	active = false
}
local aniviaR = {
	missle = nil,
	active = false
}
local aniviaBuff = {}

function GetHPBarPos(enemy)
  enemy.barData = {PercentageOffset = {x = -0.05, y = 0}}
  local barPos = GetUnitHPBarPos(enemy)
  local barPosOffset = GetUnitHPBarOffset(enemy)
  local barOffset = { x = enemy.barData.PercentageOffset.x, y = enemy.barData.PercentageOffset.y }
  local barPosPercentageOffset = { x = enemy.barData.PercentageOffset.x, y = enemy.barData.PercentageOffset.y }
  local BarPosOffsetX = -50
  local BarPosOffsetY = 46
  local CorrectionY = 39
  local StartHpPos = 31 
  barPos.x = math.floor(barPos.x + (barPosOffset.x - 0.5 + barPosPercentageOffset.x) * BarPosOffsetX + StartHpPos)
  barPos.y = math.floor(barPos.y + (barPosOffset.y - 0.5 + barPosPercentageOffset.y) * BarPosOffsetY + CorrectionY)
  local StartPos = Vector(barPos.x , barPos.y, 0)
  local EndPos = Vector(barPos.x + 108 , barPos.y , 0)    
  return Vector(StartPos.x, StartPos.y, 0), Vector(EndPos.x, EndPos.y, 0)
end

function GetQDamage(unit)
	local Qlvl = myHero:GetSpellData(_Q).level
	if Qlvl < 1 then return 0 end
	return 25 * Qlvl + 35 + .4 * myHero.ap
end

function GetEDamage(unit)
	local Elvl = myHero:GetSpellData(_E).level
	if Elvl < 1 then return 0 end
	if IsEBuffed(unit) then
		return (30 * Elvl + 25 + .5 * myHero.ap) * 2
	else
		return 30 * Elvl + 25 + .5 * myHero.ap
	end
end

function GetRDamage(unit)
	local Rlvl = myHero:GetSpellData(_R).level
	if Rlvl < 1 then return 0 end
	return 40 * Rlvl + 40 + .25 * myHero.ap
end

function OnDraw()
	for i, enemy in pairs(GetEnemyHeroes()) do
		if enemy and enemy.visible and not enemy.dead then
			local myDmg = myHero:CalcDamage(enemy, myHero.totalDamage)
			if myHero:CanUseSpell(_Q) == READY then
				myDmg = myDmg + GetQDamage(enemy)
			end
			if myHero:CanUseSpell(_E) == READY then
				myDmg = myDmg + GetEDamage(enemy)
			end
			if myHero:CanUseSpell(_R) == READY then
				myDmg = myDmg + GetRDamage(enemy)
			end
			
			textLabel = nil
			local line = 2
			local linePosA  = {x = 0, y = 0 }
			local linePosB  = {x = 0, y = 0 }
			local TextPos   = {x = 0, y = 0 }
			
			local p = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
			if OnScreen(p.x, p.y) then
				if myDmg >= enemy.health then
					myDmg = enemy.health - 1
					textLabel = "Killable"
				else
					textLabel = "Damage"
				end
				myDmg = math.round(myDmg)
				
				local StartPos, EndPos = GetHPBarPos(enemy)
				local Real_X = StartPos.x + 24
				local Offs_X = (Real_X + ((enemy.health - myDmg) / enemy.maxHealth) * (EndPos.x - StartPos.x - 2))
				if Offs_X < Real_X then Offs_X = Real_X end 
				
				local mytrans = 350 - math.round(255*((enemy.health-myDmg)/enemy.maxHealth))
				if mytrans >= 255 then mytrans=254 end
				local my_bluepart = math.round(400*((enemy.health-myDmg)/enemy.maxHealth))
				if my_bluepart >= 255 then my_bluepart=254 end
				
				linePosA.x = Offs_X-150
				linePosA.y = (StartPos.y-(30+(line*15)))    
				linePosB.x = Offs_X-150
				linePosB.y = (StartPos.y-10)
				TextPos.x = Offs_X-148
				TextPos.y = (StartPos.y-(30+(line*15)))
				
				DrawLine(linePosA.x, linePosA.y, linePosB.x, linePosB.y , 2, ARGB(mytrans, 255, my_bluepart, 0))
				DrawText(tostring(myDmg).." "..tostring(textLabel), 15, TextPos.x, TextPos.y , ARGB(mytrans, 255, my_bluepart, 0))
			end
		end
	end
end

function OnLoad()
	local lib = ZLib("BirdofIce", "Bird of Ice")
	_G.ZLib.prediction:AddSpellData("Q", "skillshot", "line", 1200, 110, 0.25, 850)
	_G.ZLib.prediction:AddSpellData("R", "skillshot", "cirlce", 615, 350, 0.1, math.huge)
	
	_G.ZLib.prediction:AddInterrupt("Q", "skillshot", "line", 1200, 110, 0.25, 850)
	
	DelayAction(function()
		--_G.ZLib.prediction:BindSpell("w", {shotType = "skillshot", skillType = "cone", delay = 0.5, range = 1200, width = 57, speed = 2000}, "TR")
		--_G.ZLib.prediction:BindSpell("r", {shotType = "skillshot", skillType = "line", delay = 0.5, range = 1200, width = 100, speed = 1600}, "TR")
	end, 8)
	
	DelayAction(function()
		_G.ZLib.printDisplay:Notice("Please note this is a early alpha version")
		if scriptInfo.doWeUpdate then
			_G.ZLib.printDisplay:Notice("Updates are enabled! When a new version is out it will be downloaded")
		end
		_G.ZLib.printDisplay:Notice("Thank you for using Bird of Ice [Anivia]")
	end, 10)
	
	DelayAction(function()
		_G.ZLib.printDisplay:Notice("For a full list of my scripts visit me on the forum")
		_G.ZLib.printDisplay:Notice("Have a request or idea? Let me know")
	end, 15)
	
	DelayAction(function()
		_G.ZLib.notification:NewBlock("Welcome!", "Welcome To " .. _G.ZLib.name .. "!", 90)
	end, 8)
	_G.ZLib.prediction:AddToMenu()
	CreateMenu()
end

function CreateMenu()
	_G.ZLib.menu:addSubMenu(">> Combo Settings <<", "Combo")
		_G.ZLib.menu.Combo:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.ZLib.menu.Combo:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, true)
		_G.ZLib.menu.Combo:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
		_G.ZLib.menu.Combo:addParam("r", "Use R", SCRIPT_PARAM_ONOFF, true)
		_G.ZLib.menu.Combo:addParam("rRange", "R Max Range", SCRIPT_PARAM_SLICE, 750, 200, 2500, 0)
		
	_G.ZLib.menu:addSubMenu(">> Harass Settings <<", "Harass")
		_G.ZLib.menu.Harass:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.ZLib.menu.Harass:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
		_G.ZLib.menu.Harass:addParam("lane", "Harass in Lane Clear", SCRIPT_PARAM_ONOFF, true)
		_G.ZLib.menu.Harass:addParam("auto", "Auto Harass", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("J"))
	
	_G.ZLib.menu:addSubMenu(">> Jungle Clear Settings <<", "Jungle")
		_G.ZLib.menu.Jungle:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.ZLib.menu.Jungle:addParam("qMana", "Use Q Above Mana %", SCRIPT_PARAM_SLICE, 25, 0, 100, 0)
		_G.ZLib.menu.Jungle:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
		_G.ZLib.menu.Jungle:addParam("eMana", "Use E Above Mana %", SCRIPT_PARAM_SLICE, 25, 0, 100, 0)
		_G.ZLib.menu.Jungle:addParam("r", "Use R", SCRIPT_PARAM_ONOFF, true)
		_G.ZLib.menu.Jungle:addParam("rMana", "Use R Above Mana %", SCRIPT_PARAM_SLICE, 25, 0, 100, 0)
end

function OnTick()
	AutoBuyStarting()
	DetonateQ()
	_G.ZLib.prediction:CounterDash()
	
	if _G.ZLib.orbwalk and _G.ZLib.orbwalk.oneLoaded then
		if _G.ZLib.orbwalk:CurrentMode() == "Carry" then ComboMode() return end
		if _G.ZLib.orbwalk:CurrentMode() == "Harass" then HarassMode() return end
		if _G.ZLib.orbwalk:CurrentMode() == "Lane" then
			LaneClearMode()
			JungleClearMode()
			if _G.ZLib.menu.Harass.lane then
				HarassMode()
			end
			return
		end
	end
	
	if _G.ZLib.menu.Harass.auto then HarassMode() end
end

function ComboMode()
	targetManager:update()
	AutoOffR()
	local castOnTarget = false
	local myTarget = targetManager.target
	
	if myTarget and _G.ZLib.prediction:PredictIsValidDistance(myTarget, 1300) and myTarget.health > 6 then
		
		WallIntoUlt(myTarget)
		
		if _G.ZLib.menu.Combo.q and myHero:CanUseSpell(_Q) == READY and not aniviaQ.active then
			local spellInfo = _G.ZLib.prediction:Predict("Q", myTarget, true)
			if spellInfo and spellInfo.castPos and GetDistance(myHero, spellInfo.castPos) <= 1200 then
				CastSpell(_Q, spellInfo.castPos.x, spellInfo.castPos.z)
				castOnTarget = true
				return
			end
		end
		
		if _G.ZLib.menu.Combo.e and myHero:CanUseSpell(_E) == READY and IsEBuffed(myTarget) and _G.ZLib.prediction:PredictIsValidDistance(myTarget, 700) then
			CastSpell(_E, myTarget)
			return
		end
		
		if _G.ZLib.menu.Combo.r and myHero:CanUseSpell(_R) == READY and not aniviaR.active then
			local spellInfo = _G.ZLib.prediction:Predict("R", myTarget, true)
			if spellInfo and spellInfo.castPos and GetDistance(myHero, spellInfo.castPos) <= 615 then
				CastSpell(_R, spellInfo.castPos.x, spellInfo.castPos.z)
				castOnTarget = true
				return
			end
		end
		
	end
	
	if castOnTarget then return end
	
	for i, unit in pairs(GetEnemyHeroes()) do
		if unit and _G.ZLib.prediction:PredictIsValidDistance(unit, 1300) then
			WallIntoUlt(unit)
			
			if _G.ZLib.menu.Combo.q and myHero:CanUseSpell(_Q) == READY and not aniviaQ.active then
				local spellInfo = _G.ZLib.prediction:Predict("Q", unit, true)
				if spellInfo and spellInfo.castPos and GetDistance(myHero, spellInfo.castPos) <= 1200 then
					CastSpell(_Q, spellInfo.castPos.x, spellInfo.castPos.z)
					return
				end
			end
			
			if _G.ZLib.menu.Combo.e and myHero:CanUseSpell(_E) == READY and IsEBuffed(unit) and _G.ZLib.prediction:PredictIsValidDistance(unit, 700) then
				CastSpell(_E, unit)
			end
		end
	end
end

function HarassMode()
	targetManager:update()
	
	local castOnTarget = false
	local myTarget = targetManager.target
	
	if myTarget and _G.ZLib.prediction:PredictIsValidDistance(myTarget, 1300) and myTarget.health > 6 then
		if _G.ZLib.menu.Harass.q and myHero:CanUseSpell(_Q) == READY and not aniviaQ.active then
			local spellInfo = _G.ZLib.prediction:Predict("Q", myTarget, true)
			if spellInfo and spellInfo.castPos and GetDistance(myHero, spellInfo.castPos) <= 1200 then
				CastSpell(_Q, spellInfo.castPos.x, spellInfo.castPos.z)
				castOnTarget = true
				return
			end
		end
		
		if _G.ZLib.menu.Harass.e and myHero:CanUseSpell(_E) == READY and IsEBuffed(myTarget) and _G.ZLib.prediction:PredictIsValidDistance(myTarget, 700) then
			CastSpell(_E, myTarget)
		end
	end
	
	if castOnTarget then return end
	
	for i, unit in pairs(GetEnemyHeroes()) do
		if unit and _G.ZLib.prediction:PredictIsValidDistance(unit, 1300) and unit.health > 6 then
			if _G.ZLib.menu.Harass.q and myHero:CanUseSpell(_Q) == READY and not aniviaQ.active then
				local spellInfo = _G.ZLib.prediction:Predict("Q", unit, true)
				if spellInfo and spellInfo.castPos and GetDistance(myHero, spellInfo.castPos) <= 1200 then
					CastSpell(_Q, spellInfo.castPos.x, spellInfo.castPos.z)
					return
				end
			end
			
			if _G.ZLib.menu.Harass.e and myHero:CanUseSpell(_E) == READY and IsEBuffed(unit) and _G.ZLib.prediction:PredictIsValidDistance(unit, 700) then
				CastSpell(_E, unit)
			end
		end
	end
	
end

function LaneClearMode()
	
end

function JungleClearMode()
	jungleManager:update()
	
	for j, jungle in pairs(jungleManager.objects) do
		if jungle and _G.ZLib.prediction:PredictIsValidDistance(jungle, 700) and not jungle.name:lower():find("plant") and not jungle.name:lower():find("poro") then
			
			if _G.ZLib.menu.Jungle.q and myHero:CanUseSpell(_Q) == READY then
				local spellInfo = _G.ZLib.prediction:Predict("Q", jungle, true)
				if spellInfo and spellInfo.castPos and GetDistance(myHero, spellInfo.castPos) <= 1200 then
					CastSpell(_Q, spellInfo.castPos.x, spellInfo.castPos.z)
					return
				end
			end
			
			if _G.ZLib.menu.Jungle.e and myHero:CanUseSpell(_E) == READY and IsEBuffed(jungle) and _G.ZLib.prediction:PredictIsValidDistance(jungle, 600) then
				CastSpell(_E, jungle)
				return
			end
			
		end
	end
end

function AutoBuyStarting()
	if VIP_USER and GetGameTimer() < 200 and myHero.gold == 500 then
		DelayAction(function()
			BuyItem(1056) --Dorans
		end, 1)
		DelayAction(function()
			BuyItem(2003) --HP Pot
		end, 2)
		DelayAction(function()
			BuyItem(2003) --HP Pot
		end, 3)
		DelayAction(function()
			BuyItem(3340) --Trinket
		end, 4)
	end
end

function OnCreateObj(object)
	if object.name ~= nil then
		if object.name:lower() == "anivia_base_q_aoe_mis.troy" then
			aniviaQ.missle = object
			aniviaQ.active = true
		elseif object.name:lower() == "anivia_base_r_aoe_green.troy" then
			aniviaR.missle = object
			aniviaR.active = true
		end
	end
end

function OnDeleteObj(object)
	if object.name ~= nil then
		if object.name:lower() == "anivia_base_q_aoe_mis.troy" then
			aniviaQ.missle = nil
			aniviaQ.active = false
		elseif object.name:lower() == "anivia_base_r_aoe_green.troy" then
			aniviaR.missle = nil
			aniviaR.active = false
		end
	end
end

function GetAngle(from, p1, p2)
	local p1Z = p1.z - from.z
	local p1X = p1.x - from.x
	local p1Angle = math.atan2(p1Z , p1X) * 180 / math.pi
	
	local p2Z = p2.z - from.z
	local p2X = p2.x - from.x
	local p2Angle = math.atan2(p2Z , p2X) * 180 / math.pi
	
	return math.sqrt((p1Angle - p2Angle) ^ 2)
end

function OnNewPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance)
	if isDash and startPos and endPos and dashSpeed and dashDistance and myHero:CanUseSpell(_W) == READY and (GetDistance(startPos) < 800 or GetDistance(endPos) < 800) then
		local castPosition = nil
		if dashSpeed * 0.55 > GetDistance(startPos, endPos) then
			castPosition = Vector(startPos) + (Vector(endPos) - Vector(startPos)):normalized() * 0.55 * dashSpeed
		else
			castPosition = Vector(startPos) + (Vector(endPos) - Vector(startPos)):normalized() * (dashDistance + 50)
		end
		
		if GetAngle(myHero, startPos, castPosition) < 45 and GetDistance(castPosition) > 50 and GetDistance(castPosition) < 500 then
			CastSpell(_W, castPosition.x, castPosition.z)
			if myHero:CanUseSpell(_Q) == READY then
				CastSpell(_Q, castPosition.x, castPosition.z)
			end
			if myHero:CanUseSpell(_R) == READY then
				CastSpell(_R, castPosition.x, castPosition.z)
			end
		end
	end
end

function DetonateQ()
	if aniviaQ.missle and aniviaQ.active then
		for i, unit in pairs(GetEnemyHeroes()) do
			if _G.ZLib.prediction:PredictIsValid(unit) and unit.maxHealth > 6 then
				if GetDistance(unit, aniviaQ.missle) < 150 then
					DelayAction(function()
						CastSpell(_Q)
					end, 0.15)
					return
				end
			end
		end
		
		
	end
end

function WallIntoUlt(unit)
	if unit and unit.type == myHero.type and unit.team ~= myHero.team then
		if unit.hasMovePath and unit.path.count > 1 and aniviaR.missle and myHero:CanUseSpell(_W) == READY and GetDistance(unit) < 800 then
			local path = unit.path:Path(2)
			if GetDistance(path, aniviaR.missle) > 210 and GetDistance(unit, aniviaR.missle) < 175  then
				local p1 = Vector(unit) + (Vector(path) - Vector(unit)):normalized() * 0.6 * unit.ms
				if GetDistance(p1) < 1000 and GetDistance(aniviaR.missle, p1) > 150 and GetDistance(aniviaR.missle, p1) < 250 and GetDistance(unit, path) > GetDistance(unit, p1) then
					CastSpell(_W, p1.x, p1.z)
				end
			end
		end
	end
end

function OnUpdateBuff(unit, buff, stacks)
	if unit and buff and buff.name:lower() == "chilled" then
		aniviaBuff[unit.networkID] = { os.clock() + 1.5, unit, buff}
	end
end

function AutoOffR()
	if aniviaR.active then
		local countInR = 0
		for i, unit in pairs(GetEnemyHeroes()) do
			if _G.ZLib.prediction:PredictIsValid(unit) and unit.maxHealth > 6 then
				if GetDistance(unit, aniviaR.missle) < 615 then
					countInR = countInR + 1
				end
			end
		end
		if countInR == 0 then
			CastSpell(_R)
		end
	end
end

function IsEBuffed(unit)
	if aniviaBuff[unit.networkID] ~= nil and aniviaBuff[unit.networkID][1] > os.clock() then
		return true
	end
	return false
end