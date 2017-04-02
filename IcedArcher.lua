if myHero.charName ~= "Ashe" then return end

local scriptInfo = {
	doWeUpdate = false,
	doWeDownload = true,
	Version = 1
}

function LibDownloaderPrint(msg)
	print("<font color=\"#FF794C\"><b>Iced Archer</b></font> <font color=\"#FFDFBF\"><b>"..msg.."</b></font>")
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
	local UpdatePath = "/azer0/0BoL/master/Version/IcedArcher.Version?rand=" .. math.random(1, 10000)
	local UpdatePath2 = "/azer0/0BoL/master/IcedArcher.lua?rand=" .. math.random(1, 10000)
	local UpdateFile = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
	local VersionURL = "http://"..UpdateHost..UpdatePath
	local UpdateURL = "http://"..UpdateHost..UpdatePath2

	function AutoUpdaterPrint(msg)
		print("<font color=\"#FF794C\"><b>Iced Archer</b></font> <font color=\"#FFDFBF\"><b>"..msg.."</b></font>")
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
local targetManager = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1200, DAMAGE_PHYSICAL, true)

targetManager.name = myHero.name

local aaRange = 600

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
	local QDmg = {myHero.totalDamage*0.23, myHero.totalDamage*0.24, myHero.totalDamage*0.25, myHero.totalDamage*0.26, myHero.totalDamage*0.27}
	local QDmgMod = 1
	local DmgRaw = QDmg[Qlvl] + myHero.totalDamage * QDmgMod
	local Dmg = myHero:CalcDamage(unit, DmgRaw)
	return Dmg
end

function GetWDamage(unit)
	local Wlvl = myHero:GetSpellData(_W).level
	if Wlvl < 1 then return 0 end
	local WDmg = {20, 35, 50, 65, 80}
	local WDmgMod = 1
	local DmgRaw = WDmg[Wlvl] + myHero.totalDamage * WDmgMod
	local Dmg = myHero:CalcDamage(unit, DmgRaw)
	return Dmg
end

function GetRDamage(unit)
	local Rlvl = myHero:GetSpellData(_R).level
	if Rlvl < 1 then return 0 end
	local RDmg = {250, 425, 600}
	local RDmgMod = 1
	local DmgRaw = RDmg[Rlvl] + myHero.ap * RDmgMod
	local Dmg = myHero:CalcMagicDamage(unit, DmgRaw)
	return Dmg
end

function OnDraw()
	for i, enemy in pairs(GetEnemyHeroes()) do
		if enemy and enemy.visible and not enemy.dead then
			local myDmg = myHero:CalcDamage(enemy, myHero.totalDamage)
			if myHero:CanUseSpell(_Q) == READY then
				myDmg = myDmg + GetQDamage(enemy)
			end
			if myHero:CanUseSpell(_W) == READY then
				myDmg = myDmg + GetWDamage(enemy)
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
	local lib = ZLib("IcedArcher", "Iced Archer")
	_G.ZLib.prediction:AddSpellData("W", "skillshot", "cone", 1200, 57, 0.5, 2000)
	_G.ZLib.prediction:AddSpellData("R", "skillshot", "line", 25000, 100, 0.5, 1600)
	
	_G.ZLib.prediction:AddAntiDash("R", "skillshot", "line", 1600, 100, 0.5, 1600)
	_G.ZLib.prediction:AddInterrupt("R", "skillshot", "line", 1600, 100, 0.5, 1600)
	
	DelayAction(function()
		_G.ZLib.prediction:BindSpell("w", {shotType = "skillshot", skillType = "cone", delay = 0.5, range = 1200, width = 57, speed = 2000}, "TR")
		_G.ZLib.prediction:BindSpell("r", {shotType = "skillshot", skillType = "line", delay = 0.5, range = 1200, width = 100, speed = 1600}, "TR")
	end, 8)
	
	DelayAction(function()
		_G.ZLib.printDisplay:Notice("Please note this is a early alpha version")
		if scriptInfo.doWeUpdate then
			_G.ZLib.printDisplay:Notice("Updates are enabled! When a new version is out it will be downloaded")
		end
		_G.ZLib.printDisplay:Notice("Thank you for using Iced Archer [Ashe]")
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
		_G.ZLib.menu.Harass:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, false)
		_G.ZLib.menu.Harass:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, true)
		_G.ZLib.menu.Harass:addParam("lane", "Harass in Lane Clear", SCRIPT_PARAM_ONOFF, true)
		_G.ZLib.menu.Harass:addParam("auto", "Auto Harass", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("J"))
	
	_G.ZLib.menu:addSubMenu(">> Jungle Clear Settings <<", "Jungle")
		_G.ZLib.menu.Jungle:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.ZLib.menu.Jungle:addParam("qMana", "Use Q Above Mana %", SCRIPT_PARAM_SLICE, 25, 0, 100, 0)
		_G.ZLib.menu.Jungle:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, true)
		_G.ZLib.menu.Jungle:addParam("wMana", "Use W Above Mana %", SCRIPT_PARAM_SLICE, 25, 0, 100, 0)
end

function OnTick()
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
	
	local castOnTarget = false
	local myTarget = targetManager.target
	
	if myTarget and _G.ZLib.prediction:PredictIsValidDistance(myTarget, 1200) then
		
		if _G.ZLib.menu.Combo.w and myHero:CanUseSpell(_W) == READY then
			local spellInfo = _G.ZLib.prediction:Predict("W", myTarget, false)
			if spellInfo and spellInfo.castPos and GetDistance(myHero, spellInfo.castPos) <= 1200 then
				CastSpell(_W, spellInfo.castPos.x, spellInfo.castPos.z)
				castOnTarget = true
				return
			end
		end
		
		if _G.ZLib.menu.Combo.r and myHero:CanUseSpell(_R) == READY and GetDistance(myHero, myTarget) <= _G.ZLib.menu.Combo.rRange + 150 then
			if (_G.ZLib.unit:CountInRangeSpot(600, GetAllyHeroes(), myTarget.pos) + 1 >= _G.ZLib.unit:CountInRangeSpot(600, GetEnemyHeroes(), myTarget.pos)) or (myTarget.maxHealth / 2 >= myTarget.health) then
				local spellInfo = _G.ZLib.prediction:Predict("R", myTarget, false)
				if spellInfo and spellInfo.castPos and GetDistance(myHero, spellInfo.castPos) <= _G.ZLib.menu.Combo.rRange then
					CastSpell(_R, spellInfo.castPos.x, spellInfo.castPos.z)
					castOnTarget = true
					return
				end
			end
		end
		
		if _G.ZLib.menu.Combo.q and myHero:CanUseSpell(_Q) == READY and GetDistance(myHero, myTarget) <= 600 then
			CastSpell(_Q)
			castOnTarget = true
			return
		end
		
	end
	
	if castOnTarget then return end
	
	for i, unit in pairs(GetEnemyHeroes()) do
		if unit and _G.ZLib.prediction:PredictIsValidDistance(unit, 1200) then
			if _G.ZLib.menu.Combo.w and myHero:CanUseSpell(_W) == READY then
				local spellInfo = _G.ZLib.prediction:Predict("W", unit, false)
				if spellInfo and spellInfo.castPos and GetDistance(myHero, spellInfo.castPos) <= 1200 then
					CastSpell(_W, spellInfo.castPos.x, spellInfo.castPos.z)
					castOnTarget = true
					return
				end
			end
		end
	end
end

function HarassMode()
	targetManager:update()
	
	local castOnTarget = false
	local myTarget = targetManager.target
	
	if myTarget and _G.ZLib.prediction:PredictIsValidDistance(myTarget, 1200) then
		if _G.ZLib.menu.Harass.w and myHero:CanUseSpell(_W) == READY then
			local spellInfo = _G.ZLib.prediction:Predict("W", myTarget, false)
			if spellInfo and spellInfo.castPos and GetDistance(myHero, spellInfo.castPos) <= 1200 then
				CastSpell(_W, spellInfo.castPos.x, spellInfo.castPos.z)
				castOnTarget = true
				return
			end
		end
	end
	
	if castOnTarget then return end
	
	for i, unit in pairs(GetEnemyHeroes()) do
		if unit and _G.ZLib.prediction:PredictIsValidDistance(unit, 1200) then
			if _G.ZLib.menu.Harass.w and myHero:CanUseSpell(_W) == READY then
				local spellInfo = _G.ZLib.prediction:Predict("W", unit, false)
				if spellInfo and spellInfo.castPos and GetDistance(myHero, spellInfo.castPos) <= 1200 then
					CastSpell(_W, spellInfo.castPos.x, spellInfo.castPos.z)
					castOnTarget = true
					return
				end
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
			
			if _G.ZLib.menu.Jungle.w and myHero:CanUseSpell(_W) == READY then
				local spellInfo = _G.ZLib.prediction:Predict("W", jungle, false)
				if spellInfo and spellInfo.castPos and GetDistance(myHero, spellInfo.castPos) <= 1200 then
					CastSpell(_W, spellInfo.castPos.x, spellInfo.castPos.z)
					castOnTarget = true
					return
				end
			end
			
			if _G.ZLib.menu.Jungle.q and myHero:CanUseSpell(_Q) == READY and _G.ZLib.prediction:PredictIsValidDistance(jungle, 600) then
				CastSpell(_Q)
				return
			end
			
		end
	end
end

