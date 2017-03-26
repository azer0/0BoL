if myHero.charName ~= "Blitzcrank" then return end

local scriptInfo = {
	doWeUpdate = true,
	doWeDownload = true,
	Version = 2
}

function LibDownloaderPrint(msg)
		print("<font color=\"#FF794C\"><b>Mr Grabby</b></font> <font color=\"#FFDFBF\"><b>"..msg.."</b></font>")
	end
	
if scriptInfo.doWeDownload then
	local toDownload = {
		--Librarys
		["0Library"] = "https://raw.githubusercontent.com/azer0/0BoL/master/0Library.lua",
		--Predictions
		["FHPrediction"] = "http://api.funhouse.me/download-lua.php",
		["TRPrediction"] = "https://raw.githubusercontent.com/Project4706/BoL/master/TRPrediction.lua",
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
			print(libUrl)
			print(LIB_PATH .. libName .. ".lua")
			isDownloading = true
			downloadCount = downloadCount + 1
			LibDownloaderPrint("<font color=\"#6699FF\">Downloading " .. libName .. ".</font>")
			DownloadFile(libUrl, LIB_PATH .. libName .. ".lua", FileDownloaded)
		end
	end
	
	if isDownloading then
		LibDownloaderPrint("<font color=\"#6699FF\">Please double F9 after downloads are done.</font>")
		return
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
	local UpdatePath = "/azer0/0BoL/master/Version/MrGrabby.Version?rand=" .. math.random(1, 10000)
	local UpdatePath2 = "/azer0/0BoL/master/MrGrabby.lua?rand=" .. math.random(1, 10000)
	local UpdateFile = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
	local VersionURL = "http://"..UpdateHost..UpdatePath
	local UpdateURL = "http://"..UpdateHost..UpdatePath2

	function AutoUpdaterPrint(msg)
		print("<font color=\"#FF794C\"><b>Mr Grabby</b></font> <font color=\"#FFDFBF\"><b>"..msg.."</b></font>")
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
local smiteSlot = nil

function OnLoad()
	local lib = ZLib("MrGrabby", "MrGrabby")
	_G.ZLib.prediction:AddSpellData("Q", "skillshot", "line", 1000, 70, 0.25, 1800)
	_G.ZLib.prediction:AddAntiDash("Q", "skillshot", "line", 1000, 70, 0.25, 1800)
	
	_G.ZLib.prediction:AddToMenu()
	CreateMenu()
	
	smiteSlot = myHero:GetSpellData(SUMMONER_1).name:find("smite") and SUMMONER_1 or myHero:GetSpellData(SUMMONER_2).name:find("smite") and SUMMONER_2 or nil
end

function CreateMenu()
	_G.ZLib.menu:addSubMenu(">> Combo Settings <<", "Combo")
		_G.ZLib.menu.Combo:addSubMenu(">> Q Targets <<", "Targets")
			for i, object in pairs(GetEnemyHeroes()) do
				if object then
					_G.ZLib.menu.Combo.Targets:addParam(object.charName, "Pull " .. object.charName, SCRIPT_PARAM_ONOFF, true)
				end
			end
		_G.ZLib.menu.Combo:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.ZLib.menu.Combo:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, true)
		_G.ZLib.menu.Combo:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
		_G.ZLib.menu.Combo:addParam("r", "Use R", SCRIPT_PARAM_ONOFF, true)
		
	_G.ZLib.menu:addSubMenu(">> Harass Settings <<", "Harass")
		_G.ZLib.menu.Harass:addSubMenu(">> Q Targets <<", "Targets")
			for i, object in pairs(GetEnemyHeroes()) do
				if object then
					_G.ZLib.menu.Harass.Targets:addParam(object.charName, "Pull " .. object.charName, SCRIPT_PARAM_ONOFF, true)
				end
			end
		_G.ZLib.menu.Harass:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
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
	_G.ZLib.menu:addSubMenu(">> Kill Steal Settings <<", "KS")
		_G.ZLib.menu.KS:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.ZLib.menu.KS:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
		_G.ZLib.menu.KS:addParam("r", "Use R", SCRIPT_PARAM_ONOFF, true)
end

function SmiteDamage()
	local SmiteDamage = 0
	if myHero.level <= 4 then
		SmiteDamage = 370 + (myHero.level*20)
	end
	if myHero.level > 4 and myHero.level <= 9 then
		SmiteDamage = 330 + (myHero.level*30)
	end
	if myHero.level > 9 and myHero.level <= 14 then
		SmiteDamage = 240 + (myHero.level*40)
	end
	if myHero.level > 14 then
		SmiteDamage = 100 + (myHero.level*50)
	end
	return SmiteDamage
end

function OnTick()
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

function ComboMode()
	targetManager:update()
	
	local castOnTarget = false
	local myTarget = targetManager.target
	
	if myTarget and _G.ZLib.prediction:PredictIsValidDistance(myTarget, 1000) then
		
		if _G.ZLib.menu.Combo.q and _G.ZLib.menu.Combo.Targets[myTarget.charName] and myHero:CanUseSpell(_Q) == READY then
			if _G.ZLib.menu.zPred.qPred == 1 and smiteSlot and myHero:CanUseSpell(smiteSlot) == READY then
				local castPosition, hitChance, spellInfo = FHPrediction.GetPrediction("Q", myTarget)
				if castPosition and hitChance and hitChance >= 0 then
					if info.collision and info.collision.amount == 1 then
						local hitObj = info.collision.objects[1]
						if hitObj.type == "obj_AI_Minion" and GetDistanceSqr(myHero, hitObj) < 600*600 and hitObj.health <= SmiteDamage() then
							CastSpell(_Q, castPosision.x, castPosition.z)
							DelayAction(CastSpell, 0.25, {smiteSlot, hitObj})
						end
					elseif not info.collision then
						CastSpell(_Q, castPosision.x, castPosition.z)
					end
				end
			else
				local spellInfo = _G.ZLib.prediction:Predict("Q", myTarget, false)
				if spellInfo and spellInfo.castPos and GetDistance(myHero, spellInfo.castPos) <= 1000 then
					CastSpell(_Q, spellInfo.castPos.x, spellInfo.castPos.z)
					castOnTarget = true
				end
			end
		end
		
		if _G.ZLib.menu.Combo.e and myHero:CanUseSpell(_E) == READY and GetDistance(myHero, myTarget) <= aaRange then
			CastSpell(_E)
			myHero:Attack(myTarget)
			castOnTarget = true
		end
		
		if _G.ZLib.menu.Combo.r and myHero:CanUseSpell(_R) == READY and _G.ZLib.unit:CountInRange(600, GetEnemyHeroes()) >= 2 and GetDistance(myHero, myTarget) <= 600 then
			CastSpell(_R)
			castOnTarget = true
		end
		
	end
	
	if castOnTarget then return end
	
	for i, unit in pairs(GetEnemyHeroes()) do
		if unit and _G.ZLib.prediction:PredictIsValidDistance(unit, 1000) then
			if _G.ZLib.menu.Combo.q and _G.ZLib.menu.Combo.Targets[myTarget.charName] and myHero:CanUseSpell(_Q) == READY then
				if _G.ZLib.menu.zPred.qPred == 1 and smiteSlot and myHero:CanUseSpell(smiteSlot) == READY then
					local castPosition, hitChance, spellInfo = FHPrediction.GetPrediction("Q", myTarget)
					if castPosition and hitChance and hitChance >= 0 then
						if info.collision and info.collision.amount == 1 then
							local hitObj = info.collision.objects[1]
							if hitObj.type == "obj_AI_Minion" and GetDistanceSqr(myHero, hitObj) < 600*600 and hitObj.health <= SmiteDamage() then
								CastSpell(_Q, castPosision.x, castPosition.z)
								DelayAction(CastSpell, 0.25, {smiteSlot, hitObj})
							end
						elseif not info.collision then
							CastSpell(_Q, castPosision.x, castPosition.z)
						end
					end
				else
					local spellInfo = _G.ZLib.prediction:Predict("Q", myTarget, false)
					if spellInfo and spellInfo.castPos and GetDistanceSqr(myHero, pred.castPos) <= 1000*1000 then
						CastSpell(_Q, spellInfo.castPos.x, spellInfo.castPos.z)
						castOnTarget = true
					end
				end
			end
			
			if _G.ZLib.menu.Combo.e and myHero:CanUseSpell(_E) == READY and GetDistance(myHero, myTarget) <= aaRange then
				CastSpell(_E)
				myHero:Attack(myTarget)
				castOnTarget = true
			end
		end
	end
end

function HarassMode()
	targetManager:update()
	
	local castOnTarget = false
	local myTarget = targetManager.target
	
	if myTarget and _G.ZLib.prediction:PredictIsValidDistance(myTarget, 1000) then
		
		if _G.ZLib.menu.Harass.q and _G.ZLib.menu.Harass.Targets[myTarget.charName] and myHero:CanUseSpell(_Q) == READY then
			if _G.ZLib.menu.zPred.qPred == 1 and smiteSlot and myHero:CanUseSpell(smiteSlot) == READY then
				local castPosition, hitChance, spellInfo = FHPrediction.GetPrediction("Q", myTarget)
				if castPosition and hitChance and hitChance >= 0 then
					if info.collision and info.collision.amount == 1 then
						local hitObj = info.collision.objects[1]
						if hitObj.type == "obj_AI_Minion" and GetDistanceSqr(myHero, hitObj) < 600*600 and hitObj.health <= SmiteDamage() then
							CastSpell(_Q, castPosision.x, castPosition.z)
							DelayAction(CastSpell, 0.25, {smiteSlot, hitObj})
						end
					elseif not info.collision then
						CastSpell(_Q, castPosision.x, castPosition.z)
					end
				end
			else
				local spellInfo = _G.ZLib.prediction:Predict("Q", myTarget, false)
				if spellInfo and spellInfo.castPos and GetDistanceSqr(myHero, pred.castPos) <= 1000*1000 then
					CastSpell(_Q, spellInfo.castPos.x, spellInfo.castPos.z)
					castOnTarget = true
				end
			end
		end
		
		if _G.ZLib.menu.Harass.e and myHero:CanUseSpell(_E) == READY and GetDistance(myHero, myTarget) <= aaRange then
			CastSpell(_E)
			myHero:Attack(myTarget)
			castOnTarget = true
		end
		
	end
	
	if castOnTarget then return end
	
	for i, unit in pairs(GetEnemyHeroes()) do
		if unit and _G.ZLib.prediction:PredictIsValidDistance(unit, 1000) then
			if _G.ZLib.menu.Harass.q and _G.ZLib.menu.Harass.Targets[myTarget.charName] and myHero:CanUseSpell(_Q) == READY then
				if _G.ZLib.menu.zPred.qPred == 1 and smiteSlot and myHero:CanUseSpell(smiteSlot) == READY then
					local castPosition, hitChance, spellInfo = FHPrediction.GetPrediction("Q", myTarget)
					if castPosition and hitChance and hitChance >= 0 then
						if info.collision and info.collision.amount == 1 then
							local hitObj = info.collision.objects[1]
							if hitObj.type == "obj_AI_Minion" and GetDistanceSqr(myHero, hitObj) < 600*600 and hitObj.health <= SmiteDamage() then
								CastSpell(_Q, castPosision.x, castPosition.z)
								DelayAction(CastSpell, 0.25, {smiteSlot, hitObj})
							end
						elseif not info.collision then
							CastSpell(_Q, castPosision.x, castPosition.z)
						end
					end
				else
					local spellInfo = _G.ZLib.prediction:Predict("Q", myTarget, false)
					if spellInfo and spellInfo.castPos and GetDistance(myHero, pred.castPos) <= 1000 then
						CastSpell(_Q, spellInfo.castPos.x, spellInfo.castPos.z)
						castOnTarget = true
					end
				end
			end
			
			if _G.ZLib.menu.Harass.e and myHero:CanUseSpell(_E) == READY and GetDistance(myHero, myTarget) <= aaRange then
				CastSpell(_E)
				myHero:Attack(myTarget)
				castOnTarget = true
			end
		end
	end
end

function LaneClearMode()
	
end

function JungleClearMode()
	jungleManager:update()
	
	for i, minion in pairs(jungleManager.objects) do
		if minion and _G.ZLib.prediction:PredictIsValidDistance(minion, 850) then
			if _G.ZLib.menu.Jungle.q and _G.ZLib.menu.Jungle.qMana <= 100 * myHero.mana / myHero.maxMana then
				local spellInfo = _G.ZLib.prediction:Predict("Q", minion, false)
				if spellInfo and spellInfo.castPos and GetDistance(myHero, pred.castPos) <= 1000 then
					CastSpell(_Q, spellInfo.castPos.x, spellInfo.castPos.z)
					return
				end
			end
			
			if _G.ZLib.menu.Jungle.e and _G.ZLib.menu.Jungle.eMana <= 100 * myHero.mana / myHero.maxMana and GetDistance(myHero, pred.castPos) <= aaRange then
				CastSpell(_E)
				myHero:Attack(minion)
				return
			end
		end
	end
end
