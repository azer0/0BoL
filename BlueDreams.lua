if myHero.charName ~= "Taric" then return end

local scriptInfo = {
	doWeUpdate = true,
	doWeDownload = true,
	Version = 1
}

function LibDownloaderPrint(msg)
	print("<font color=\"#FF794C\"><b>Blue Dreams</b></font> <font color=\"#FFDFBF\"><b>"..msg.."</b></font>")
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
	local UpdatePath = "/azer0/0BoL/master/Version/BlueDreams.Version?rand=" .. math.random(1, 10000)
	local UpdatePath2 = "/azer0/0BoL/master/BlueDreams.lua?rand=" .. math.random(1, 10000)
	local UpdateFile = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
	local VersionURL = "http://"..UpdateHost..UpdatePath
	local UpdateURL = "http://"..UpdateHost..UpdatePath2

	function AutoUpdaterPrint(msg)
		print("<font color=\"#FF794C\"><b>Blue Dreams</b></font> <font color=\"#FFDFBF\"><b>"..msg.."</b></font>")
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
local targetManager = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1000, DAMAGE_MAGIC, true)
targetManager.name = myHero.name

local aaRange = 125
local taricQ = {
	lastCast = 0,
	charges = 0,
	lastCharge = 0,
	chargeTime = 14,
	lastLevel = 0,
	nextCharge = 0
}
local taricW = {
	onTarget = nil,
	lastCast = 0
}

local taricSkillInfo = {
	["Q"] = {
		range = 380,
		manual = false
	}
}

function OnDraw()
	if taricSkillInfo["Q"].manual == false and myHero:CanUseSpell(_Q) == READY then
		DrawText3D("Please Cast 1 Q Manually!", myHero.x - 175, myHero.y, myHero.z - 70, 24, ARGB(255, 255, 255, 255))
	end
end

function OnLoad()
	local lib = ZLib("BlueDreams", "BlueDreams")
	_G.ZLib.prediction:AddSpellData("E", "skillshot", "line", 600, 60, 0.85, 1500)
	DelayAction(function()
		_G.ZLib.prediction:BindSpell("e", {shotType = "skillshot", skillType = "line", delay = 0.85, range = 600, width = 60, speed = 1500}, "TR")
		--_G.ZLib.prediction:BindSpell("e", {shotType = "skillshot", skillType = "line", delay = 0.85, range = 600, width = 60, speed = 1500}, "DP")
	end, 8)
	DelayAction(function()
		_G.ZLib.printDisplay:Notice("Please note this is a early alpha version")
		if scriptInfo.doWeUpdate then
			_G.ZLib.printDisplay:Notice("Updates are enabled! When a new version is out it will be downloaded")
		end
		_G.ZLib.printDisplay:Notice("Thank you for using Blue Dreams [Taric]")
	end, 10)
	_G.ZLib.prediction:AddToMenu()
	CreateMenu()
end

function CreateMenu()
	_G.ZLib.menu:addSubMenu(">> Combo Settings <<", "Combo")
		_G.ZLib.menu.Combo:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
		
	_G.ZLib.menu:addSubMenu(">> Harass Settings <<", "Harass")
		_G.ZLib.menu.Harass:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
	--[[	
	_G.ZLib.menu:addSubMenu(">> Lane Clear Settings <<", "Lane")
		_G.ZLib.menu.Lane:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.ZLib.menu.Lane:addParam("qMana", "Use Q Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.ZLib.menu.Lane:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
		_G.ZLib.menu.Lane:addParam("eMana", "Use E Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.ZLib.menu.Lane:addParam("harass", "Harass in Lane Clear", SCRIPT_PARAM_ONOFF, true)
	
	_G.ZLib.menu:addSubMenu(">> Jungle Clear Settings <<", "Jungle")
		_G.ZLib.menu.Jungle:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.ZLib.menu.Jungle:addParam("qMana", "Use Q Above Mana %", SCRIPT_PARAM_SLICE, 25, 0, 100, 0)
		_G.ZLib.menu.Jungle:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
		_G.ZLib.menu.Jungle:addParam("eMana", "Use E Above Mana %", SCRIPT_PARAM_SLICE, 25, 0, 100, 0)
	]]--
end

function QHealAmount()
	if myHero:GetSpellData(_Q).level > 0 then
		return ((10 + 10 * myHero:GetSpellData(_Q).level) + (myHero.ap * .6) + (myHero.maxHealth * 0.125)) * taricQ.charges
	else
		return 0
	end
end

function OnTick()
	--Get Q charge time
	if taricQ.lastCast ~= 0 and taricQ.chargeTime == 0 and myHero:CanUseSpell(_Q) == READY and os.clock() - taricQ.lastCast > 1 then
		taricQ.chargeTime = os.clock() - taricQ.lastCast
		taricQ.lastCharge = os.clock()
		taricQ.nextCharge = os.clock() + taricQ.chargeTime
		taricQ.charges = 1
		print("Charge Time: " .. taricQ.chargeTime)
	end
	--Add Q Charges if needed
	if taricQ.chargeTime ~= 0 and taricQ.nextCharge ~= 0 and taricQ.lastCharge ~= 0 and os.clock() >= taricQ.nextCharge and myHero:CanUseSpell(_Q) == READY and taricQ.charges ~= 3 then
		taricQ.charges = taricQ.charges + 1
		taricQ.lastCharge = os.clock()
		taricQ.nextCharge = os.clock() + taricQ.chargeTime
		print("Charges: " .. taricQ.charges .. " next: " .. taricQ.nextCharge .. " current:" .. os.clock())
	end
	
	AutoBastion()
	AutoHeal()
	
	_G.ZLib.prediction:CounterDash()
	
	if _G.ZLib.orbwalk and _G.ZLib.orbwalk.oneLoaded then
		if _G.ZLib.orbwalk:CurrentMode() == "Carry" then ComboMode() return end
		if _G.ZLib.orbwalk:CurrentMode() == "Harass" then HarassMode() return end
		if _G.ZLib.orbwalk:CurrentMode() == "Lane" then
			LaneClearMode()
			JungleClearMode()
			if _G.ZLib.menu.harass then
				HarassMode()
			end
			return
		end
	end
end

function AutoHeal()
	if myHero:CanUseSpell(_Q) ~= READY then return end
	
	if taricW.onTarget and GetDistance(taricW.onTarget) < 800 and not taricW.onTarget.isMe then
		--taricSkillInfo
		for i = 1, heroManager.iCount do
			local allytarget = heroManager:GetHero(i)
			if allytarget and allytarget.team == myHero.team and not allytarget.dead and allytarget.health ~= allytarget.maxHealth and (allytarget.isMe or allytarget == taricW.onTarget or GetDistance(allytarget) <= taricSkillInfo["Q"].range or GetDistance(allytarget, taricW.onTarget) <= taricSkillInfo["Q"].range) then
				if allytarget.health <= allytarget.maxHealth / 2 and taricQ.charges == 3 then
					CastSpell(_Q)
					break
				elseif allytarget.health <= allytarget.maxHealth / 4 and taricQ.charges >= 2 then
					CastSpell(_Q)
					break
				elseif allytarget.health <= allytarget.maxHealth / 6 and taricQ.charges >= 1 then
					CastSpell(_Q)
					break
				elseif allytarget.health + QHealAmount() < allytarget.maxHealth and taricQ.charges == 3 then
					CastSpell(_Q)
					break
				end
			end
		end
	else
		for i = 1, heroManager.iCount do
			local allytarget = heroManager:GetHero(i)
			if allytarget and allytarget.team == myHero.team and not allytarget.dead and allytarget.health ~= allytarget.maxHealth and (allytarget.isMe or GetDistance(allytarget) <= taricSkillInfo["Q"].range) then
				if allytarget.health <= allytarget.maxHealth / 2 and taricQ.charges == 3 then
					CastSpell(_Q)
					break
				elseif allytarget.health <= allytarget.maxHealth / 4 and taricQ.charges >= 2 then
					CastSpell(_Q)
					break
				elseif allytarget.health <= allytarget.maxHealth / 6 and taricQ.charges >= 1 then
					CastSpell(_Q)
					break
				elseif allytarget.health + QHealAmount() < allytarget.maxHealth and taricQ.charges == 3 then
					CastSpell(_Q)
					break
				end
			end
		end
	end
end

function AutoBastion()
	if myHero:CanUseSpell(_W) ~= READY then return end
	if taricW.onTarget then
		if taricW.onTarget.dead or GetDistance(taricW.onTarget) >= 800 or taricW.onTarget.isMe then
			local bestTarget = nil
			for i = 1, heroManager.iCount do
				local allytarget = heroManager:GetHero(i)
				if allytarget and allytarget.team == myHero.team and not allytarget.dead and GetDistance(allytarget) <= 800 then
					if not bestTarget then
						bestTarget = allytarget
					else
						if allytarget.health < bestTarget.health then
							bestTarget = allytarget
						end
					end
				end
			end
			if bestTarget and bestTarget ~= taricW.onTarget and not bestTarget.dead and GetDistance(bestTarget) <= 800 and bestTarget.health ~= bestTarget.maxHealth then
				CastSpell(_W, bestTarget)
			end
		end
	else
		local bestTarget = nil
		for i = 1, heroManager.iCount do
			local allytarget = heroManager:GetHero(i)
			if allytarget and allytarget.team == myHero.team and not allytarget.dead and GetDistance(allytarget) <= 800 then
				if not bestTarget then
					bestTarget = allytarget
				else
					if allytarget.health < bestTarget.health then
						bestTarget = allytarget
					end
				end
			end
		end
		if bestTarget and bestTarget ~= taricW.onTarget and not bestTarget.dead and GetDistance(bestTarget) <= 800 and bestTarget.health ~= bestTarget.maxHealth then
			CastSpell(_W, bestTarget)
		end
	end
end

function IsBastionValid()
	if taricW.onTarget and GetDistance(taricW.onTarget) <= 800 and not taricW.onTarget.dead and taricW.onTarget.health > 0 then
		return true
	end
	return false
end

function ComboMode()
	targetManager:update()
	
	local castOnTarget = false
	local myTarget = targetManager.target
	
	if myTarget and _G.ZLib.prediction:PredictIsValidDistance(myTarget, 650) then
		
		if _G.ZLib.menu.Combo.e and myHero:CanUseSpell(_E) == READY then
			local spellInfo = _G.ZLib.prediction:Predict("E", myTarget, true)
			if spellInfo and spellInfo.castPos and GetDistance(myHero, spellInfo.castPos) <= 600 then
				CastSpell(_E, spellInfo.castPos.x, spellInfo.castPos.z)
				castOnTarget = true
			end
		end
		
		if _G.ZLib.menu.Combo.e and myHero:CanUseSpell(_E) == READY and IsBastionValid() then
			local spellInfo = _G.ZLib.prediction:Predict("E", myTarget, true, taricW.onTarget)
			if spellInfo and spellInfo.castPos and GetDistance(taricW.onTarget, spellInfo.castPos) <= 600 then
				CastSpell(_E, spellInfo.castPos.x, spellInfo.castPos.z)
				castOnTarget = true
			end
		end
		
	end
	
	if castOnTarget then return end
	
	for i, unit in pairs(GetEnemyHeroes()) do
		if unit and _G.ZLib.prediction:PredictIsValidDistance(unit, 650) then
			if _G.ZLib.menu.Combo.e and myHero:CanUseSpell(_E) == READY then
				local spellInfo = _G.ZLib.prediction:Predict("E", unit, true)
				if spellInfo and spellInfo.castPos and GetDistance(myHero, spellInfo.castPos) <= 600 then
					CastSpell(_E, spellInfo.castPos.x, spellInfo.castPos.z)
					return
				end
			end
			if _G.ZLib.menu.Combo.e and myHero:CanUseSpell(_E) == READY and IsBastionValid() then
				local spellInfo = _G.ZLib.prediction:Predict("E", unit, true, taricW.onTarget)
				if spellInfo and spellInfo.castPos and GetDistance(taricW.onTarget, spellInfo.castPos) <= 600 then
					CastSpell(_E, spellInfo.castPos.x, spellInfo.castPos.z)
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
	
	local castOnTarget = false
	local myTarget = targetManager.target
	
	if myTarget and _G.ZLib.prediction:PredictIsValidDistance(myTarget, 600) then
		if _G.ZLib.menu.Harass.e and myHero:CanUseSpell(_E) == READY then
			local spellInfo = _G.ZLib.prediction:Predict("E", myTarget, true)
			if spellInfo and spellInfo.castPos and GetDistance(myHero, spellInfo.castPos) <= 600 then
				CastSpell(_E, spellInfo.castPos.x, spellInfo.castPos.z)
				castOnTarget = true
			end
		end
	end
	
	if castOnTarget then return end
	
	for i, unit in pairs(GetEnemyHeroes()) do
		if unit and _G.ZLib.prediction:PredictIsValidDistance(unit, 600) then
			if _G.ZLib.menu.Harass.e and myHero:CanUseSpell(_E) == READY then
				local spellInfo = _G.ZLib.prediction:Predict("E", unit, true)
				if spellInfo and spellInfo.castPos and GetDistance(myHero, spellInfo.castPos) <= 600 then
					CastSpell(_E, spellInfo.castPos.x, spellInfo.castPos.z)
					castOnTarget = true
				end
			end
		end
	end
	
end

function LaneClearMode()
	
end

function JungleClearMode()
	jungleManager:update()
end

function OnProcessSpell(unit, spell)
	if unit and spell and unit.isMe then
		if spell.name == "TaricQ" then
			taricSkillInfo["Q"].manual = true
			if taricQ.lastLevel ~= myHero:GetSpellData(_Q).level and myHero:GetSpellData(_Q).level > 0 then
				taricQ.lastLevel = myHero:GetSpellData(_Q).level
				taricQ.chargeTime = 0
			else
				taricQ.nextCharge = os.clock() + taricQ.chargeTime
			end
			taricQ.charges = 0
			taricQ.lastCast = os.clock()
		elseif spell.name == "TaricW" then
			taricW.lastCast = os.clock()
			taricW.onTarget = spell.target
		end
	end
	if _G.ZLib and _G.ZLib.notification then _G.ZLib.notification:ProcessAttack(object, spell) end
end