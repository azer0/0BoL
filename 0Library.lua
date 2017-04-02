local zLibVer = 5

local UpdateHost = "raw.github.com"
local UpdatePath = "/azer0/0BoL/master/Version/0Library.Version?rand=" .. math.random(1, 10000)
local UpdatePath2 = "/azer0/0BoL/master/0Library.lua?rand=" .. math.random(1, 10000)
local UpdateFile = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local VersionURL = "http://"..UpdateHost..UpdatePath
local UpdateURL = "http://"..UpdateHost..UpdatePath2

function AutoUpdaterPrint(msg)
	print("<font color=\"#FF794C\"><b>0 Library</b></font> <font color=\"#FFDFBF\"><b>"..msg.."</b></font>")
end

local hasBeenUpdated = false

local sData = GetWebResult(UpdateHost, UpdatePath)
if sData then
	local sVer = type(tonumber(sData)) == "number" and tonumber(sData) or nil
	if sVer and sVer > zLibVer then
		AutoUpdaterPrint("New update found [v" .. sVer .. "].")
		AutoUpdaterPrint("Please do not reload until complete.")
		DownloadFile(UpdateURL, UpdateFile, function () AutoUpdaterPrint("Successfully updated. ("..zLibVer.." => "..sVer.."), press F9 twice to use the updated version.") end)
		hasBeenUpdated = true
	end
end

if hasBeenUpdated then
	return
end

------------------------------------------------------------------------------------------------------
--
--START: Utility Functions
--
function tableLength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

local function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end
--
--End: Utility Functions
--
------------------------------------------------------------------------------------------------------
class("ZLib")
function ZLib:__init(scriptShort, scriptName)
	_G.ZLib = {
		name = scriptName,
		short = scriptShort,
		menu = scriptConfig(scriptShort, scriptName),
		myData = ZChampData(myHero),
		printDisplay = ZPrintDisplay(scriptName),
		prediction = ZPrediction(),
		unit = ZUnitChecks(),
		orbwalk = nil,
		spellData = {},
		antiDash = {},
		interrupt = {},
		shieldData = {},
		heal = ZHealManager(),
		skillShot = ZSkillShotCheck(),
		notification = nil
	}
	
	_G.ZLib.notification = ZNotifications()
	
	AddTickCallback(function() self:OnTick() end)
	AddDrawCallback(function() self:OnDraw() end)
	DelayAction(function()
		_G.ZLib.orbwalk = ZOrbWalk()
	end, 8)
end

function ZLib:OnTick()
	if _G.ZLib.orbwalk ~= nil then
		_G.ZLib.orbwalk:FindOrbWalk()
	end
	_G.ZLib.prediction:OnTick()
end

function ZLib:OnDraw()
	_G.ZLib.prediction:OnDraw()
	_G.ZLib.notification:OnDraw()
end
------------------------------------------------------------------------------------------------------
--
--START: Champ Data (ZChampData)
--
class("ZChampData")
function ZChampData:__init(champ)
	self.champion = champ
end

function ZChampData:Kills()
	return self.champion:GetInt("CHAMPIONS_KILLED")
end

function ZChampData:Deaths()
	return self.champion:GetInt("NUM_DEATHS")
end

function ZChampData:Assists()
	return self.champion:GetInt("ASSISTS")
end

function ZChampData:Creeps()
	return self.champion:GetInt("MINIONS_KILLED")
end

function ZChampData:Gold()
	return self.champion.gold
end
--
--End: Champ Data (ZChampData)
--
------------------------------------------------------------------------------------------------------
--
--START: Print Display (ZPrintDisplay)
--
class("ZPrintDisplay")
function ZPrintDisplay:__init(myPrefix)
	self.showDebug = true
	self.hideSpam = true
	self.prefix = myPrefix
	self.spam = nil
	
	self:Custom("Loaded [v" .. zLibVer .. "]")
end

function ZPrintDisplay:Error(message)
	if self.showDebug == false then return end
	if self.spam == message then return end
	self.spam = message
	print("<font color=\"#FF794C\">[<b>" .. self.prefix .. "</b>]</font> <font color=\"#FFCE33\">" .. message .. ".</font>")
end

function ZPrintDisplay:Bad(message)
	if self.spam == message then return end
	self.spam = message
	print("<font color=\"#FF794C\">[<b>" .. self.prefix .. "</b>]</font> <font color=\"#FFCE33\">" .. message .. ".</font>")
end

function ZPrintDisplay:Notice(message)
	if self.spam == message then return end
	self.spam = message
	print("<font color=\"#FF794C\">[<b>" .. self.prefix .. "</b>]</font> <font color=\"#3FFF33\">" .. message .. ".</font>")
end

function ZPrintDisplay:Loaded(message)
	if self.spam == message then return end
	self.spam = message
	print("<font color=\"#FF794C\">[<b>" .. self.prefix .. "</b>]</font> <font color=\"#3FFF33\">" .. message .. ".</font>")
end

function ZPrintDisplay:Custom(prefix, message)
	if self.spam == message then return end
	self.spam = message
	print("<font color=\"#FF794C\">[<b>" .. prefix .. "</b>]</font> <font color=\"#3FFF33\">" .. message .. ".</font>")
end
--
--End: Print Display (ZPrintDisplay)
--
------------------------------------------------------------------------------------------------------
--
--START: Prediction (ZPrediction)
--
class("ZPrediction")
function ZPrediction:__init()
	self.predLastLoaded = {
		["hp"] = false,
		["location"] = false,
		["valid"] = false,
		["q"] = false,
		["w"] = false,
		["e"] = false,
		["r"] = false
	}
	self.predLoaded = {
		["vpred"] = false,
		["fhpred"] = false,
		["trpred"] = false,
		["spred"] = false,
		["dpred"] = false
	}
	self.spellBinds = {
		["TR"] = {
			["q"] = nil,
			["w"] = nil,
			["e"] = nil,
			["r"] = nil
		},
		["DP"] = {
			["q"] = nil,
			["w"] = nil,
			["e"] = nil,
			["r"] = nil
		}
	}
	self.DP = nil
end

function ZPrediction:BindSpell(slot, info, pred)
	if info.shotType == "skillshot" then
		if pred == "TR" then
			self:LoadPrediction("trpred")
			if slot == "q" then
				if info.skillType == "line" then
					self.spellBinds["TR"]["q"] = TR_BindSS({type = 'IsLinear', delay = info.delay, range = info.range, width = info.width, speed = info.speed})
				elseif info.skillType == "circle" then
					self.spellBinds["TR"]["q"] = TR_BindSS({type = 'IsRadial', delay = info.delay, range = info.range, width = info.width, speed = info.speed})
				elseif info.skillType == "cone" then
					self.spellBinds["TR"]["q"] = TR_BindSS({type = 'IsConic', delay = info.delay, range = info.range, width = info.width, speed = info.speed})
				end
			elseif slot == "w" then
				if info.skillType == "line" then
					self.spellBinds["TR"]["w"] = TR_BindSS({type = 'IsLinear', delay = info.delay, range = info.range, width = info.width, speed = info.speed})
				elseif info.skillType == "circle" then
					self.spellBinds["TR"]["w"] = TR_BindSS({type = 'IsRadial', delay = info.delay, range = info.range, width = info.width, speed = info.speed})
				elseif info.skillType == "cone" then
					self.spellBinds["TR"]["w"] = TR_BindSS({type = 'IsConic', delay = info.delay, range = info.range, width = info.width, speed = info.speed})
				end
			elseif slot == "e" then
				print("e")
				if info.skillType == "line" then
					self.spellBinds["TR"]["e"] = TR_BindSS({type = 'IsLinear', delay = info.delay, range = info.range, width = info.width, speed = info.speed})
				elseif info.skillType == "circle" then
					self.spellBinds["TR"]["e"] = TR_BindSS({type = 'IsRadial', delay = info.delay, range = info.range, width = info.width, speed = info.speed})
				elseif info.skillType == "cone" then
					self.spellBinds["TR"]["e"] = TR_BindSS({type = 'IsConic', delay = info.delay, range = info.range, width = info.width, speed = info.speed})
				end
			elseif slot == "r" then
				if info.skillType == "line" then
					self.spellBinds["TR"]["r"] = TR_BindSS({type = 'IsLinear', delay = info.delay, range = info.range, width = info.width, speed = info.speed})
				elseif info.skillType == "circle" then
					self.spellBinds["TR"]["r"] = TR_BindSS({type = 'IsRadial', delay = info.delay, range = info.range, width = info.width, speed = info.speed})
				elseif info.skillType == "cone" then
					self.spellBinds["TR"]["r"] = TR_BindSS({type = 'IsConic', delay = info.delay, range = info.range, width = info.width, speed = info.speed})
				end
			end
		elseif pred == "DP" and self.DP then
			if slot == "q" then
				if info.skillType == "line" then
					local lineQ = self.DP:LineSS(info.speed, info.range, info.width / 2, info.delay, 0)
					self.spellBinds["DP"]["q"] = self.DP:bindSS("spellQ", lineQ, 60)
				elseif info.skillType == "circle" then
					local circleQ = self.DP:CircleSS(info.speed, info.range, info.width / 2, info.delay, 0)
					self.spellBinds["DP"]["q"] = self.DP:bindSS("spellQ", circleQ, 60)
				elseif info.skillType == "cone" then
					local coneQ = self.DP:ConeSS(info.speed, info.range, info.width / 2, info.delay, 0)
					self.spellBinds["DP"]["q"] = self.DP:bindSS("spellQ", coneQ, 60)
				end
			elseif slot == "w" then
				if info.skillType == "line" then
					local lineQ = self.DP:LineSS(info.speed, info.range, info.width / 2, info.delay, 0)
					self.spellBinds["DP"]["w"] = self.DP:bindSS("spellW", lineQ, 60)
				elseif info.skillType == "circle" then
					local circleQ = self.DP:CircleSS(info.speed, info.range, info.width / 2, info.delay, 0)
					self.spellBinds["DP"]["w"] = self.DP:bindSS("spellW", circleQ, 60)
				elseif info.skillType == "cone" then
					local coneQ = self.DP:ConeSS(info.speed, info.range, info.width / 2, info.delay, 0)
					self.spellBinds["DP"]["w"] = self.DP:bindSS("spellW", coneQ, 60)
				end
			elseif slot == "e" then
				if info.skillType == "line" then
					local lineQ = self.DP:LineSS(info.speed, info.range, info.width / 2, info.delay, 0)
					self.spellBinds["DP"]["e"] = self.DP:bindSS("spellE", lineQ, 60)
				elseif info.skillType == "circle" then
					local circleQ = self.DP:CircleSS(info.speed, info.range, info.width / 2, info.delay, 0)
					self.spellBinds["DP"]["e"] = self.DP:bindSS("spellE", circleQ, 60)
				elseif info.skillType == "cone" then
					local coneQ = self.DP:ConeSS(info.speed, info.range, info.width / 2, info.delay, 0)
					self.spellBinds["DP"]["e"] = self.DP:bindSS("spellE", coneQ, 60)
				end
			elseif slot == "r" then
				if info.skillType == "line" then
					local lineQ = self.DP:LineSS(info.speed, info.range, info.width / 2, info.delay, 0)
					self.spellBinds["DP"]["r"] = self.DP:bindSS("spellR", lineQ, 60)
				elseif info.skillType == "circle" then
					local circleQ = self.DP:CircleSS(info.speed, info.range, info.width / 2, info.delay, 0)
					self.spellBinds["DP"]["r"] = self.DP:bindSS("spellR", circleQ, 60)
				elseif info.skillType == "cone" then
					local coneQ = self.DP:ConeSS(info.speed, info.range, info.width / 2, info.delay, 0)
					self.spellBinds["DP"]["r"] = self.DP:bindSS("spellR", coneQ, 60)
				end
			end
		end
	end
end

function ZPrediction:AddSpellData(spell, shotTypeI, skillTypeI, rangeI, widthI, delayI, speedI)
	if spell ~= nil and shotTypeI ~= nil then
		if _G.ZLib.spellData and not _G.ZLib.spellData[myHero.charName] then
			_G.ZLib.spellData[myHero.charName] = {}
			_G.ZLib.printDisplay:Error("Created missing table for char spell info")
		end
		if _G.ZLib.spellData[myHero.charName] then
			_G.ZLib.printDisplay:Error("Adding spell")
			_G.ZLib.spellData[myHero.charName][spell] = {
				shotType = shotTypeI,
				skillType = skillTypeI,
				range = rangeI,
				width = widthI,
				delay = delayI,
				speed = speedI
			}
			_G.ZLib.spellData["loaded"] = true
		end
	else
		_G.ZLib.printDisplay:Error("Spell information missing")
	end
end

function ZPrediction:Predict(spell, target, allowCol, source)
	if not allowCol then allowCol = false end
	local sourceUnit = myHero
	if source then sourceUnit = source end
	
	if spell and target and _G.ZLib.spellData[myHero.charName][spell] and _G.ZLib.spellData[myHero.charName][spell].shotType == "skillshot" then
		--Q
		if spell == "Q" and _G.ZLib.menu.zPred.qPred == 1 then
			if FHPrediction.HasPreset("Q") then
				local pos, hc, info = FHPrediction.GetPrediction("Q", target, sourceUnit)
				if pos and hc and hc > 0 and ((not allowCol and not info.collision) or allowCol) then
					return {
						castPos = pos,
						hitChance = hc,
						pred = "FH"
					}
				end
			else
				local qInfo = {range = _G.ZLib.spellData[myHero.charName][spell].range, speed = _G.ZLib.spellData[myHero.charName][spell].speed, delay = _G.ZLib.spellData[myHero.charName][spell].delay, radius = _G.ZLib.spellData[myHero.charName][spell].width}
				local pos, hc, info = FHPrediction.GetPrediction(qInfo, target, sourceUnit)
				if pos and hc and hc > 0 and ((not allowCol and not info.collision) or allowCol) then
					return {
						castPos = pos,
						hitChance = hc,
						pred = "FH"
					}
				end
			end
		elseif spell == "Q" and _G.ZLib.menu.zPred.qPred == 2 then
			local CastPosition, HitChance, Collision = TRPrediction:GetPrediction(self.spellBinds["TR"]["q"], target, sourceUnit)
			if CastPosition and HitChance and ((not allowCol and not Collision) or allowCol) and ((_G.ZLib.menu.zPred.qTR == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.qTR == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.qTR == 3 and HitChance >= 2)) then
				return {
					castPos = CastPosition,
					hitChance = HitChance,
					pred = "TR"
				}
			end
		elseif spell == "Q" and s_G.ZLib.menu.zPred.qPred == 3 then
			if _G.ZLib.spellData[myHero.charName]["Q"].skillType == "line" then
				local CastPosition, HitChance = VPrediction:GetLineCastPosition(target, _G.ZLib.spellData[myHero.charName]["Q"].delay, _G.ZLib.spellData[myHero.charName]["Q"].width, _G.ZLib.spellData[myHero.charName]["Q"].range, _G.ZLib.spellData[myHero.charName]["Q"].speed, sourceUnit, allowCol)
				if CastPosition and HitChance and ((_G.ZLib.menu.zPred.qVP == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.qVP == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.qVP == 3 and HitChance >= 2)) then
					return {
						castPos = CastPosition,
						hitChance = HitChance,
						pred = "VP"
					}
				end
			elseif _G.ZLib.spellData[myHero.charName]["Q"].skillType == "circle" then
				local CastPosition, HitChance = VPrediction:GetCircularCastPosition(target, _G.ZLib.spellData[myHero.charName]["Q"].delay, _G.ZLib.spellData[myHero.charName]["Q"].width, _G.ZLib.spellData[myHero.charName]["Q"].range, _G.ZLib.spellData[myHero.charName]["Q"].speed, sourceUnit, allowCol)
				if CastPosition and HitChance and ((_G.ZLib.menu.zPred.qVP == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.qVP == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.qVP == 3 and HitChance >= 2)) then
					return {
						castPos = CastPosition,
						hitChance = HitChance,
						pred = "VP"
					}
				end
			elseif _G.ZLib.spellData[myHero.charName]["Q"].skillType == "cone" then
				local CastPosition, HitChance = VPrediction:GetCircularCastPosition(target, _G.ZLib.spellData[myHero.charName]["Q"].delay, _G.ZLib.spellData[myHero.charName]["Q"].width, _G.ZLib.spellData[myHero.charName]["Q"].range, _G.ZLib.spellData[myHero.charName]["Q"].speed, sourceUnit, allowCol)
				if CastPosition and HitChance and ((_G.ZLib.menu.zPred.qVP == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.qVP == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.qVP == 3 and HitChance >= 2)) then
					return {
						castPos = CastPosition,
						hitChance = HitChance,
						pred = "VP"
					}
				end
			end
		elseif spell == "Q" and _G.ZLib.menu.zPred.qPred == 4 then
			local CastPosition, HitChance, Collision = self.DP:GetPrediction(self.spellBinds["TR"]["q"], target, sourceUnit)
			if CastPosition and HitChance and ((not allowCol and not Collision) or allowCol) and ((_G.ZLib.menu.zPred.qTR == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.qTR == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.qTR == 3 and HitChance >= 2)) then
				return {
					castPos = CastPosition,
					hitChance = HitChance,
					pred = "TR"
				}
			end
		--W
		elseif spell == "W" and _G.ZLib.menu.zPred.wPred == 1 then
			if FHPrediction.HasPreset("W") then
				local pos, hc, info = FHPrediction.GetPrediction("W", target, sourceUnit)
				if pos and hc and hc > 0 and ((not allowCol and not info.collision) or allowCol) then
					return {
						castPos = pos,
						hitChance = hc,
						pred = "FH"
					}
				end
			else
				local wInfo = {range = _G.ZLib.spellData[myHero.charName][spell].range, speed = _G.ZLib.spellData[myHero.charName][spell].speed, delay = _G.ZLib.spellData[myHero.charName][spell].delay, radius = _G.ZLib.spellData[myHero.charName][spell].width}
				local pos, hc, info = FHPrediction.GetPrediction(wInfo, target, sourceUnit)
				if pos and hc and hc > 0 and ((not allowCol and not info.collision) or allowCol) then
					return {
						castPos = pos,
						hitChance = hc,
						pred = "FH"
					}
				end
			end
		elseif spell == "W" and _G.ZLib.menu.zPred.wPred == 2 then
			local CastPosition, HitChance, Collision = TRPrediction:GetPrediction(self.spellBinds["TR"]["w"], target, sourceUnit)
			if CastPosition and HitChance and ((not allowCol and not Collision) or allowCol) and ((_G.ZLib.menu.zPred.wTR == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.wTR == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.wTR == 3 and HitChance >= 2)) then
				return {
					castPos = CastPosition,
					hitChance = HitChance,
					pred = "TR"
				}
			end
		elseif spell == "W" and _G.ZLib.menu.zPred.wPred == 3 then
			if _G.ZLib.spellData[myHero.charName]["W"].skillType == "line" then
				local CastPosition, HitChance = VPrediction:GetLineCastPosition(target, _G.ZLib.spellData[myHero.charName]["W"].delay, _G.ZLib.spellData[myHero.charName]["W"].width, _G.ZLib.spellData[myHero.charName]["W"].range, _G.ZLib.spellData[myHero.charName]["W"].speed, sourceUnit, allowCol)
				if CastPosition and HitChance and ((_G.ZLib.menu.zPred.wVP == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.wVP == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.wVP == 3 and HitChance >= 2)) then
					return {
						castPos = CastPosition,
						hitChance = HitChance,
						pred = "VP"
					}
				end
			elseif _G.ZLib.spellData[myHero.charName]["W"].skillType == "circle" then
				local CastPosition, HitChance = VPrediction:GetCircularCastPosition(target, _G.ZLib.spellData[myHero.charName]["W"].delay, _G.ZLib.spellData[myHero.charName]["W"].width, _G.ZLib.spellData[myHero.charName]["W"].range, _G.ZLib.spellData[myHero.charName]["W"].speed, sourceUnit, allowCol)
				if CastPosition and HitChance and ((_G.ZLib.menu.zPred.wVP == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.wVP == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.wVP == 3 and HitChance >= 2)) then
					return {
						castPos = CastPosition,
						hitChance = HitChance,
						pred = "VP"
					}
				end
			elseif _G.ZLib.spellData[myHero.charName]["W"].skillType == "cone" then
				local CastPosition, HitChance = VPrediction:GetCircularCastPosition(target, _G.ZLib.spellData[myHero.charName]["W"].delay, _G.ZLib.spellData[myHero.charName]["W"].width, _G.ZLib.spellData[myHero.charName]["W"].range, _G.ZLib.spellData[myHero.charName]["W"].speed, sourceUnit, allowCol)
				if CastPosition and HitChance and ((_G.ZLib.menu.zPred.wVP == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.wVP == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.wVP == 3 and HitChance >= 2)) then
					return {
						castPos = CastPosition,
						hitChance = HitChance,
						pred = "VP"
					}
				end
			end
		--E
		elseif spell == "E" and _G.ZLib.menu.zPred.ePred == 1 then
			if FHPrediction.HasPreset("E") then
				local pos, hc, info = FHPrediction.GetPrediction("E", target, sourceUnit)
				if pos and hc and hc > 0 and ((not allowCol and not info.collision) or allowCol) then
					return {
						castPos = pos,
						hitChance = hc,
						pred = "FH"
					}
				end
			else
				local eInfo = {range = _G.ZLib.spellData[myHero.charName][spell].range, speed = _G.ZLib.spellData[myHero.charName][spell].speed, delay = _G.ZLib.spellData[myHero.charName][spell].delay, radius = _G.ZLib.spellData[myHero.charName][spell].width}
				local pos, hc, info = FHPrediction.GetPrediction(eInfo, target, sourceUnit)
				if pos and hc and hc > 0 and ((not allowCol and not info.collision) or allowCol) then
					return {
						castPos = pos,
						hitChance = hc,
						pred = "FH"
					}
				end
			end
		elseif spell == "E" and _G.ZLib.menu.zPred.ePred == 2 then
			local CastPosition, HitChance, Collision = TRPrediction:GetPrediction(self.spellBinds["TR"]["e"], target, sourceUnit)
			if CastPosition and HitChance and ((not allowCol and not Collision) or allowCol) and ((_G.ZLib.menu.zPred.eTR == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.eTR == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.eTR == 3 and HitChance >= 2)) then
				return {
					castPos = CastPosition,
					hitChance = HitChance,
					pred = "TR"
				}
			end
		elseif spell == "E" and _G.ZLib.menu.zPred.ePred == 3 then
			if _G.ZLib.spellData[myHero.charName]["E"].skillType == "line" then
				local CastPosition, HitChance = VPrediction:GetLineCastPosition(target, _G.ZLib.spellData[myHero.charName]["E"].delay, _G.ZLib.spellData[myHero.charName]["E"].width, _G.ZLib.spellData[myHero.charName]["E"].range, _G.ZLib.spellData[myHero.charName]["E"].speed, sourceUnit, allowCol)
				if CastPosition and HitChance and ((_G.ZLib.menu.zPred.eVP == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.eVP == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.eVP == 3 and HitChance >= 2)) then
					return {
						castPos = CastPosition,
						hitChance = HitChance,
						pred = "VP"
					}
				end
			elseif _G.ZLib.spellData[myHero.charName]["E"].skillType == "circle" then
				local CastPosition, HitChance = VPrediction:GetCircularCastPosition(target, _G.ZLib.spellData[myHero.charName]["E"].delay, _G.ZLib.spellData[myHero.charName]["E"].width, _G.ZLib.spellData[myHero.charName]["E"].range, _G.ZLib.spellData[myHero.charName]["E"].speed, sourceUnit, allowCol)
				if CastPosition and HitChance and ((_G.ZLib.menu.zPred.eVP == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.eVP == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.eVP == 3 and HitChance >= 2)) then
					return {
						castPos = CastPosition,
						hitChance = HitChance,
						pred = "VP"
					}
				end
			elseif _G.ZLib.spellData[myHero.charName]["E"].skillType == "cone" then
				local CastPosition, HitChance = VPrediction:GetCircularCastPosition(target, _G.ZLib.spellData[myHero.charName]["E"].delay, _G.ZLib.spellData[myHero.charName]["E"].width, _G.ZLib.spellData[myHero.charName]["E"].range, _G.ZLib.spellData[myHero.charName]["E"].speed, sourceUnit, allowCol)
				if CastPosition and HitChance and ((_G.ZLib.menu.zPred.eVP == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.eVP == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.eVP == 3 and HitChance >= 2)) then
					return {
						castPos = CastPosition,
						hitChance = HitChance,
						pred = "VP"
					}
				end
			end
		--R
		elseif spell == "R" and _G.ZLib.menu.zPred.rPred == 1 then
			if FHPrediction.HasPreset("R") then
				local pos, hc, info = FHPrediction.GetPrediction("R", target, sourceUnit)
				if pos and hc and hc > 0 and ((not allowCol and not info.collision) or allowCol) then
					return {
						castPos = pos,
						hitChance = hc,
						pred = "FH"
					}
				end
			else
				local rInfo = {range = _G.ZLib.spellData[myHero.charName][spell].range, speed = _G.ZLib.spellData[myHero.charName][spell].speed, delay = _G.ZLib.spellData[myHero.charName][spell].delay, radius = _G.ZLib.spellData[myHero.charName][spell].width}
				local pos, hc, info = FHPrediction.GetPrediction(rInfo, target, sourceUnit)
				if pos and hc and hc > 0 and ((not allowCol and not info.collision) or allowCol) then
					return {
						castPos = pos,
						hitChance = hc,
						pred = "FH"
					}
				end
			end
		elseif spell == "R" and _G.ZLib.menu.zPred.rPred == 2 then
			local CastPosition, HitChance, Collision = TRPrediction:GetPrediction(self.spellBinds["TR"]["r"], target, sourceUnit)
			if CastPosition and HitChance and ((not allowCol and not Collision) or allowCol) and ((_G.ZLib.menu.zPred.rTR == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.rTR == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.rTR == 3 and HitChance >= 2)) then
				return {
					castPos = CastPosition,
					hitChance = HitChance,
					pred = "TR"
				}
			end
		elseif spell == "R" and _G.ZLib.menu.zPred.rPred == 3 then
			if _G.ZLib.spellData[myHero.charName]["E"].skillType == "line" then
				local CastPosition, HitChance = VPrediction:GetLineCastPosition(target, _G.ZLib.spellData[myHero.charName]["R"].delay, _G.ZLib.spellData[myHero.charName]["R"].width, _G.ZLib.spellData[myHero.charName]["R"].range, _G.ZLib.spellData[myHero.charName]["R"].speed, sourceUnit, allowCol)
				if CastPosition and HitChance and ((_G.ZLib.menu.zPred.rVP == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.rVP == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.rVP == 3 and HitChance >= 2)) then
					return {
						castPos = CastPosition,
						hitChance = HitChance,
						pred = "VP"
					}
				end
			elseif _G.ZLib.spellData[myHero.charName]["R"].skillType == "circle" then
				local CastPosition, HitChance = VPrediction:GetCircularCastPosition(target, _G.ZLib.spellData[myHero.charName]["R"].delay, _G.ZLib.spellData[myHero.charName]["R"].width, _G.ZLib.spellData[myHero.charName]["R"].range, _G.ZLib.spellData[myHero.charName]["R"].speed, sourceUnit, allowCol)
				if CastPosition and HitChance and ((_G.ZLib.menu.zPred.rVP == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.rVP == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.rVP == 3 and HitChance >= 2)) then
					return {
						castPos = CastPosition,
						hitChance = HitChance,
						pred = "VP"
					}
				end
			elseif _G.ZLib.spellData[myHero.charName]["R"].skillType == "cone" then
				local CastPosition, HitChance = VPrediction:GetCircularCastPosition(target, _G.ZLib.spellData[myHero.charName]["R"].delay, _G.ZLib.spellData[myHero.charName]["R"].width, _G.ZLib.spellData[myHero.charName]["R"].range, _G.ZLib.spellData[myHero.charName]["R"].speed, sourceUnit, allowCol)
				if CastPosition and HitChance and ((_G.ZLib.menu.zPred.rVP == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.rVP == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.rVP == 3 and HitChance >= 2)) then
					return {
						castPos = CastPosition,
						hitChance = HitChance,
						pred = "VP"
					}
				end
			end
		end
	elseif spell and target and _G.ZLib.spellData[myHero.charName][spell] and _G.ZLib.spellData[myHero.charName][spell].shotType == "target" then
		return {
			castPos = target,
			hitChance = 1,
			pred = "NONE"
		}
	else
		_G.ZLib.printDisplay:Error("Spell information is missing")
	end
end

function ZPrediction:LoadPrediction(pred)
	if pred then
		if self.predLoaded[pred] == false then
			if pred == "vpred" then
				require("VPrediction")
				self.predLoaded[pred] = true
			elseif pred == "fhpred" then
				require("FHPrediction")
				self.predLoaded[pred] = true
			elseif pred == "trpred" then
				require("TRPrediction")
				self.predLoaded[pred] = true
			elseif pred == "spred" then
				require("SPrediction")
				self.predLoaded[pred] = true
			elseif pred == "dpred" then
				require("DivinePred")
				self.DP = DivinePred()
				self.predLoaded[pred] = true
			else
				_G.ZLib.printDisplay:Error("Selected prediction not known")
			end
		end
	else
		_G.ZLib.printDisplay:Error("Missing prediction")
	end
end

function ZPrediction:OnTick()
	if not _G.ZLib.spellData["loaded"] or not _G.ZLib.menu.zPred or not _G.ZLib.menu then return end

	if ((_G.ZLib.menu.zPred.qPred == 1) or (_G.ZLib.menu.zPred.wPred == 1) or (_G.ZLib.menu.zPred.ePred == 1) or (_G.ZLib.menu.zPred.rPred == 1) or (_G.ZLib.menu.zPred.hpPred == 1) or (_G.ZLib.menu.zPred.locPred == 1) or (_G.ZLib.menu.zPred.validPred == 1)) and not self.predLoaded["fhpred"] then
		self:LoadPrediction("fhpred")
	end
	
	if ((_G.ZLib.menu.zPred.qPred == 2) or (_G.ZLib.menu.zPred.wPred == 2) or (_G.ZLib.menu.zPred.ePred == 2) or (_G.ZLib.menu.zPred.rPred == 2) or (_G.ZLib.menu.zPred.hpPred == 2) or (_G.ZLib.menu.zPred.locPred == 2) or (_G.ZLib.menu.zPred.validPred == 2)) and not self.predLoaded["trpred"] then
		self:LoadPrediction("trpred")
	end
	
	if ((_G.ZLib.menu.zPred.qPred == 3) or (_G.ZLib.menu.zPred.wPred == 3) or (_G.ZLib.menu.zPred.ePred == 3) or (_G.ZLib.menu.zPred.rPred == 3) or (_G.ZLib.menu.zPred.hpPred == 3) or (_G.ZLib.menu.zPred.locPred == 3) or (_G.ZLib.menu.zPred.validPred == 3)) and not self.predLoaded["vpred"] then
		self:LoadPrediction("vpred")
	end
	
	if ((_G.ZLib.menu.zPred.qPred == 4) or (_G.ZLib.menu.zPred.wPred == 4) or (_G.ZLib.menu.zPred.ePred == 4) or (_G.ZLib.menu.zPred.rPred == 4) or (_G.ZLib.menu.zPred.hpPred == 4) or (_G.ZLib.menu.zPred.locPred == 4) or (_G.ZLib.menu.zPred.validPred == 4)) and not self.predLoaded["dpred"] then
		self:LoadPrediction("dpred")
	end
end

function ZPrediction:AddToMenu()
	_G.ZLib.menu:addSubMenu(">> Prediction Settings <<", "zPred")
	if _G.ZLib.spellData[myHero.charName]["Q"] and _G.ZLib.spellData[myHero.charName]["Q"].shotType == "skillshot" then
		_G.ZLib.menu.zPred:addParam("qPred", "Q Prediction", SCRIPT_PARAM_LIST, 1, {
			[1] = "FH Prediction",
			[2] = "TR Prediction",
			[3] = "V Prediction",
			--[4] = "D Prediction"
		})
		_G.ZLib.menu.zPred:addParam("qVP", "Q V Pred Hitchance", SCRIPT_PARAM_LIST, 2, {
			[1] = "Low",
			[2] = "Medium",
			[3] = "High"
		})
		_G.ZLib.menu.zPred:addParam("qTR", "Q TR Pred Hitchance", SCRIPT_PARAM_LIST, 2, {
			[1] = "Low",
			[2] = "Medium",
			[3] = "High"
		})
		_G.ZLib.menu.zPred:addParam("qRange", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
		_G.ZLib.menu.zPred:addParam("space", "-------------------", SCRIPT_PARAM_INFO, "")
	end
	if _G.ZLib.spellData[myHero.charName]["W"] and _G.ZLib.spellData[myHero.charName]["W"].shotType == "skillshot" then
		_G.ZLib.menu.zPred:addParam("wPred", "W Prediction", SCRIPT_PARAM_LIST, 1, {
			[1] = "FH Prediction",
			[2] = "TR Prediction",
			[3] = "V Prediction",
			--[4] = "D Prediction"
		})
		_G.ZLib.menu.zPred:addParam("wVP", "W V Pred Hitchance", SCRIPT_PARAM_LIST, 2, {
			[1] = "Low",
			[2] = "Medium",
			[3] = "High"
		})
		_G.ZLib.menu.zPred:addParam("wTR", "W TR Pred Hitchance", SCRIPT_PARAM_LIST, 2, {
			[1] = "Low",
			[2] = "Medium",
			[3] = "High"
		})
		_G.ZLib.menu.zPred:addParam("wRange", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
		_G.ZLib.menu.zPred:addParam("space1", "-------------------", SCRIPT_PARAM_INFO, "")
	end
	if _G.ZLib.spellData[myHero.charName]["E"] and _G.ZLib.spellData[myHero.charName]["E"].shotType == "skillshot" then
		_G.ZLib.menu.zPred:addParam("ePred", "E Prediction", SCRIPT_PARAM_LIST, 1, {
			[1] = "FH Prediction",
			[2] = "TR Prediction",
			[3] = "V Prediction",
			--[4] = "D Prediction"
		})
		_G.ZLib.menu.zPred:addParam("eVP", "E V Pred Hitchance", SCRIPT_PARAM_LIST, 2, {
			[1] = "Low",
			[2] = "Medium",
			[3] = "High"
		})
		_G.ZLib.menu.zPred:addParam("eTR", "E TR Pred Hitchance", SCRIPT_PARAM_LIST, 2, {
			[1] = "Low",
			[2] = "Medium",
			[3] = "High"
		})
		_G.ZLib.menu.zPred:addParam("eRange", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
		_G.ZLib.menu.zPred:addParam("space2", "-------------------", SCRIPT_PARAM_INFO, "")
	end
	if _G.ZLib.spellData[myHero.charName]["R"] and _G.ZLib.spellData[myHero.charName]["R"].shotType == "skillshot" then
		_G.ZLib.menu.zPred:addParam("rPred", "R Prediction", SCRIPT_PARAM_LIST, 1, {
			[1] = "FH Prediction",
			[2] = "TR Prediction",
			[3] = "V Prediction",
			--[4] = "D Prediction"
		})
		_G.ZLib.menu.zPred:addParam("rVP", "R V Pred Hitchance", SCRIPT_PARAM_LIST, 2, {
			[1] = "Low",
			[2] = "Medium",
			[3] = "High"
		})
		_G.ZLib.menu.zPred:addParam("rTR", "R TR Pred Hitchance", SCRIPT_PARAM_LIST, 2, {
			[1] = "Low",
			[2] = "Medium",
			[3] = "High"
		})
		_G.ZLib.menu.zPred:addParam("rRange", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
		_G.ZLib.menu.zPred:addParam("space3", "-------------------", SCRIPT_PARAM_INFO, "")
	end
	
	_G.ZLib.menu.zPred:addParam("hpPred", "HP Prediction", SCRIPT_PARAM_LIST, 1, {
		[1] = "FH Prediction",
		[2] = "TR Prediction",
		[3] = "V Prediction",
		--[4] = "D Prediction"
	})
	_G.ZLib.menu.zPred:addParam("space4", "-------------------", SCRIPT_PARAM_INFO, "")
	
	_G.ZLib.menu.zPred:addParam("locPred", "Location Prediction", SCRIPT_PARAM_LIST, 1, {
		[1] = "TR Prediction"
	})
	_G.ZLib.menu.zPred:addParam("space5", "-------------------", SCRIPT_PARAM_INFO, "")
	
	_G.ZLib.menu.zPred:addParam("validPred", "Valid Prediction", SCRIPT_PARAM_LIST, 1, {
		[1] = "FH Prediction",
		[2] = "TR Prediction",
		[3] = "V Prediction"
	})
	
	_G.ZLib.menu.zPred:addParam("space6", "-------------------", SCRIPT_PARAM_INFO, "")
	
	_G.ZLib.menu.zPred:addParam("dashPred", "Dash Prediction", SCRIPT_PARAM_LIST, 2, {
		[1] = "FH Prediction",
		[2] = "Internal"
	})
end

function ZPrediction:OnDraw()
	local color = ARGB(100, 255, 61, 236)
	if _G.ZLib.spellData[myHero.charName] then
		if _G.ZLib.spellData[myHero.charName]["Q"] ~= nil and _G.ZLib.spellData[myHero.charName]["Q"].shotType and _G.ZLib.spellData[myHero.charName]["Q"].shotType == "skillshot" then
			DrawCircle(myHero.x, myHero.y, myHero.z, _G.ZLib.spellData[myHero.charName]["Q"].range, color)
		end
		if _G.ZLib.spellData[myHero.charName]["W"] ~= nil and _G.ZLib.spellData[myHero.charName]["W"].shotType and _G.ZLib.spellData[myHero.charName]["W"].shotType == "skillshot" then
			DrawCircle(myHero.x, myHero.y, myHero.z, _G.ZLib.spellData[myHero.charName]["W"].range, color)
		end
		if _G.ZLib.spellData[myHero.charName]["E"] ~= nil and _G.ZLib.spellData[myHero.charName]["E"].shotType and _G.ZLib.spellData[myHero.charName]["E"].shotType == "skillshot" then
			DrawCircle(myHero.x, myHero.y, myHero.z, _G.ZLib.spellData[myHero.charName]["E"].range, color)
		end
		if _G.ZLib.spellData[myHero.charName]["R"] ~= nil and _G.ZLib.spellData[myHero.charName]["R"].shotType and _G.ZLib.spellData[myHero.charName]["R"].shotType == "skillshot" then
			DrawCircle(myHero.x, myHero.y, myHero.z, _G.ZLib.spellData[myHero.charName]["R"].range, color)
		end
	end
end

function ZPrediction:PredictIsValidDistance(target, distance)
	if _G.ZLib.menu.zPred.locPred == 1 then
		return TRPrediction:IsValidTarget(target, distance)
	end
end

function ZPrediction:PredictIsValid(target)
	if _G.ZLib.menu.zPred.locPred == 1 then
		return TRPrediction:IsValidTarget(target)
	end
end

function ZPrediction:AddAntiDash(spell, shotTypeI, skillTypeI, rangeI, widthI, delayI, speedI)
	if spell ~= nil and shotTypeI ~= nil then
		if _G.ZLib.antiDash and not _G.ZLib.antiDash[myHero.charName] then
			_G.ZLib.antiDash[myHero.charName] = {}
		end
		if _G.ZLib.antiDash[myHero.charName] then
			_G.ZLib.antiDash[myHero.charName][spell] = {
				shotType = shotTypeI,
				skillType = skillTypeI,
				range = rangeI,
				width = widthI,
				delay = delayI,
				speed = speedI,
				spellSlot = spell
			}
			_G.ZLib.antiDash["loaded"] = true
		end
	else
		_G.ZLib.printDisplay:Error("Spell information missing")
	end
end

function ZPrediction:AddInterrupt(spell, shotTypeI, skillTypeI, rangeI, widthI, delayI, speedI)
	if spell ~= nil and shotTypeI ~= nil then
		if _G.ZLib.interrupt and not _G.ZLib.interrupt[myHero.charName] then
			_G.ZLib.interrupt[myHero.charName] = {}
		end
		if _G.ZLib.interrupt[myHero.charName] then
			_G.ZLib.interrupt[myHero.charName][spell] = {
				shotType = shotTypeI,
				skillType = skillTypeI,
				range = rangeI,
				width = widthI,
				delay = delayI,
				speed = speedI,
				spellSlot = spell
			}
			_G.ZLib.interrupt["loaded"] = true
		end
	else
		_G.ZLib.printDisplay:Error("Spell information missing")
	end
end

function ZPrediction:ProcessAttack(object, spell)
	if not _G.ZLib.interrupt["loaded"] or not object or not spell then return end
	
	local badList = {
		["KatarinaR"] = true,
		["AlZaharNetherGrasp"] = true,
		["TwistedFateR"] = true,
		["VelkozR"] = true,
		["InfiniteDuress"] = true,
		["JhinR"] = true,
		["CaitlynAceintheHole"] = true,
		["UrgotSwap2"] = true,
		["LucianR"] = true,
		["GalioIdolOfDurand"] = true,
		["MissFortuneBulletTime"] = true,
		["XerathLocusPulse"] = true
	}
	
	if badList[spell.name] then
		for s, mSpell in pairs(_G.ZLib.interrupt[myHero.charName]) do
			if mSpell and mSpell.spellSlot and spell.range and GetDistance(myHero, enemy) <= 1600 and ((spell.spellSlot == "Q" and myHero:CanUseSpell(_Q) == READY) or (spell.spellSlot == "W" and myHero:CanUseSpell(_W) == READY) or (spell.spellSlot == "E" and myHero:CanUseSpell(_E) == READY) or (spell.spellSlot == "R" and myHero:CanUseSpell(_R) == READY)) then
				if spell.spellSlot == "Q" then
					local spellInfo = _G.ZLib.prediction:Predict("Q", object, false)
					if spellInfo and spellInfo.castPos and GetDistance(myHero, spellInfo.castPos) <= spell.range then
						CastSpell(_Q, spellInfo.castPos.x, spellInfo.castPos.z)
						return
					end
				elseif spell.spellSlot == "W" then
					local spellInfo = _G.ZLib.prediction:Predict("W", object, false)
					if spellInfo and spellInfo.castPos and GetDistance(myHero, spellInfo.castPos) <= spell.range then
						CastSpell(_W, spellInfo.castPos.x, spellInfo.castPos.z)
						return
					end
				elseif spell.spellSlot == "E" then
					local spellInfo = _G.ZLib.prediction:Predict("E", object, false)
					if spellInfo and spellInfo.castPos and GetDistance(myHero, spellInfo.castPos) <= spell.range then
						CastSpell(_E, spellInfo.castPos.x, spellInfo.castPos.z)
						return
					end
				elseif spell.spellSlot == "R" then
					local spellInfo = _G.ZLib.prediction:Predict("R", object, false)
					if spellInfo and spellInfo.castPos and GetDistance(myHero, spellInfo.castPos) <= spell.range then
						CastSpell(_R, spellInfo.castPos.x, spellInfo.castPos.z)
						return
					end
				end
			end
		end
	end
end

function ZPrediction:CounterDash()
	if not _G.ZLib.antiDash["loaded"] then return end
	
	if _G.ZLib.menu.zPred.dashPred == 1 then
		for i, enemy in pairs(GetEnemyHeroes()) do
			if enemy and not enemy.dead then
				for s, spell in pairs(_G.ZLib.antiDash[myHero.charName]) do
					if spell and spell.spellSlot and spell.range and GetDistanceSqr(myHero, enemy) < (spell.range * spell.range) * 2 and ((spell.spellSlot == "Q" and myHero:CanUseSpell(_Q) == READY) or (spell.spellSlot == "W" and myHero:CanUseSpell(_W) == READY) or (spell.spellSlot == "E" and myHero:CanUseSpell(_E) == READY) or (spell.spellSlot == "R" and myHero:CanUseSpell(_R) == READY)) then
						local dashing, pos = FHPrediction.IsUnitDashing(enemy, spell.spellSlot)
						if dashing and pos and GetDistanceSqr(myHero, pos) <= spell.range * spell.range then
							if spell.spellSlot == "Q" then
								CastSpell(_Q, pos.x, pos.z)
								return
							elseif spell.spellSlot == "W" then
								CastSpell(_W, pos.x, pos.z)
								return
							elseif spell.spellSlot == "E" then
								CastSpell(_E, pos.x, pos.z)
								return
							elseif spell.spellSlot == "R" then
								CastSpell(_R, pos.x, pos.z)
								return
							end
						end
					end
				end
			end
		end
	elseif _G.ZLib.menu.zPred.dashPred == 2 then
		
	end
end

function ZPrediction:OnNewPath(unit, startpos, endpos, isDash, dashSpeed)
	if not _G.ZLib.antiDash["loaded"] then return end
	
	if _G.ZLib.menu.zPred.dashPred == 2 and unit and startpos and endpos and isDash and dashSpeed then
		local travelTime = GetDistance(startpos, endpos) / dashSpeed
		for s, spell in pairs(_G.ZLib.antiDash[myHero.charName]) do
			if spell and spell.spellSlot and spell.range and GetDistanceSqr(myHero, enemy) < (spell.range * spell.range) * 2 and ((spell.spellSlot == "Q" and myHero:CanUseSpell(_Q) == READY) or (spell.spellSlot == "W" and myHero:CanUseSpell(_W) == READY) or (spell.spellSlot == "E" and myHero:CanUseSpell(_E) == READY) or (spell.spellSlot == "R" and myHero:CanUseSpell(_R) == READY)) then
				
			end
		end
	end
end
--
--End: Prediction (ZPrediction)
--
------------------------------------------------------------------------------------------------------
--
--START: Orb Walk (ZOrbWalk)
--
class("ZOrbWalk")
function ZOrbWalk:__init()
	self.orbWalker = nil
	self.oneLoaded = false
	_G.ZLib.menu:addSubMenu(">> Orb Walk Settings <<", "zOrb")
end

function ZOrbWalk:FindOrbWalk()
	if self.orbWalker ~= nil then return end
	
	if _G.Reborn_Initialised or _G.Reborn_Loaded then
		self.orbWalker = "SAC:R"
		_G.ZLib.printDisplay:Loaded("Detected Orb Walk [SAC:R]")
		--_G.ZLib.menu.zOrb:addParam("space", "Using SAC:R keys.", SCRIPT_PARAM_INFO, "")
		_G.ZLib.menu.zOrb:addParam("combo", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey(" "))
		_G.ZLib.menu.zOrb:addParam("lasthit", "Last Hit Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("X"))
		_G.ZLib.menu.zOrb:addParam("harass", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("C"))
		_G.ZLib.menu.zOrb:addParam("laneclear", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
		self.oneLoaded = true
	elseif _G.MMA_IsLoaded then
		self.orbWalker = "MMA"
		_G.ZLib.printDisplay:Loaded("Detected Orb Walk [MMA]")
		_G.ZLib.menu.zOrb:addParam("space", "Using MMA keys.", SCRIPT_PARAM_INFO, "")
		self.oneLoaded = true
	elseif _Pewalk then
		self.orbWalker = "Pewalk"
		_G.ZLib.printDisplay:Loaded("Detected Orb Walk [Pewalk]")
		_G.ZLib.menu.zOrb:addParam("space", "Using Pewalk keys.", SCRIPT_PARAM_INFO, "")
		self.oneLoaded = true
	else
		if FileExist(LIB_PATH.."SxOrbWalk.lua") then
			require("SxOrbWalk")
			self.orbWalker = "Sx"
			SxOrb:LoadToMenu(_G.ZLib.menu.zOrb)
			_G.ZLib.printDisplay:Loaded("Detected Orb Walk [Sx]")
			_G.ZLib.menu.zOrb:addParam("space", "Using Sx keys.", SCRIPT_PARAM_INFO, "")
			self.oneLoaded = true
		else
			_G.ZLib.printDisplay:Bad("There is no valid Orb Walker")
			_G.ZLib.menu.zOrb:addParam("combo", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey(" "))
			_G.ZLib.menu.zOrb:addParam("lasthit", "Last Hit Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("X"))
			_G.ZLib.menu.zOrb:addParam("harass", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("C"))
			_G.ZLib.menu.zOrb:addParam("laneclear", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
		end
	end
end

function ZOrbWalk:CurrentMode()
	if self.orbWalker == "SAC:R" and _G.AutoCarry and _G.AutoCarry.Keys then
		if _G.ZLib.menu.zOrb.combo then
			return "Carry"
		elseif _G.ZLib.menu.zOrb.harass then
			return "Harass"
		elseif _G.ZLib.menu.zOrb.laneclear then
			return "Lane"
		elseif _G.ZLib.menu.zOrb.lasthit then
			return "Harass"
		end
	elseif self.orbWalker == "MMA" then
		if _G.MMA_IsOrbwalking() then
			return "Carry"
		elseif _G.MMA_IsDualCarrying() then
			return "Harass"
		elseif _G.MMA_IsLaneClearing() then
			return "Lane"
		end
	elseif self.orbWalker == "Pewalk" then
		if _G._Pewalk.GetActiveMode().Carry then
			return "Carry"
		elseif _G._Pewalk.GetActiveMode().Mixed then
			return "Harass"
		elseif _G._Pewalk.GetActiveMode().LaneClear then
			return "Lane"
		end
	elseif self.orbWalker == "Sx" then
		if _G.SxOrb.isFight then
			return "Carry"
		elseif _G.SxOrb.isHarass then
			return "Harass"
		elseif _G.SxOrb.isLaneClear then
			return "Lane"
		end
	else
		if _G.ZLib.menu.zOrb.combo then
			return "Carry"
		elseif _G.ZLib.menu.zOrb.harass then
			return "Harass"
		elseif _G.ZLib.menu.zOrb.laneclear then
			return "Lane"
		elseif _G.ZLib.menu.zOrb.lasthit then
			return "Harass"
		end
	end
	return "None"
end
--
--End: Orb Walk (ZOrbWalk)
--
------------------------------------------------------------------------------------------------------
--
--START: Targeting (ZTargeting)
--
class("ZTargeting")
function ZTargeting:__init()
	_G.ZLib.menu:addSubMenu(">> Targeting Settings <<", "zTargeting")
end
--
--End: Targeting (ZTargeting)
--
------------------------------------------------------------------------------------------------------
--
--START: Unit Checks (ZUnitChecks)
--
class("ZUnitChecks")
function ZUnitChecks:__init()
	
end

function ZUnitChecks:CountInRange(range, units)
	local uCount = 0
	if range and units then
		for i, unit in pairs(units) do
			if unit and _G.ZLib.prediction:PredictIsValidDistance(unit, range) then
				uCount = uCount + 1
			end
		end
	end
	return uCount
end

function ZUnitChecks:CountInRangeSpot(range, units, point)
	local uCount = 0
	if range and units then
		for i, unit in pairs(units) do
			if unit and GetDistance(unit, point) <= range then
				uCount = uCount + 1
			end
		end
	end
	return uCount
end
--
--End: Unit Checks (ZUnitChecks)
--
------------------------------------------------------------------------------------------------------
--
--START: Heal/Shield Manager (ZHealManager)
--
class("ZHealManager")
function ZHealManager:__init()
	self.spellsAdded = 0
end
--[[
Shot Type:
skillshot
target

Skill Type:
line
circle
target
]]--
function ZHealManager:AddHeal(spell, shotTypeI, skillTypeI, rangeI, widthI, speedI, canMinion, canHero, canTower, canMe, isSheild, blockAA, blockSpell, blockAD, blockAP)
	if spell ~= nil and shotTypeI ~= nil then
		--_G.ZLib.shieldData
		_G.ZLib.shieldData[spell] = {
			shotType = shotTypeI,
			skillType = skillTypeI,
			range = rangeI,
			width = widthI,
			delay = delayI,
			speed = speedI,
			targets = {
				minion = canMinion,
				hero = canHero,
				tower = canTower,
				me = canMe
			},
			blocks = {
				aa = blockAA,
				spell = blockSpell,
				ad = blockAD,
				ap = blockAP
			}
			
		}
		self.spellsAdded = self.spellsAdded + 1
	end
end

function ZHealManager:ProcessAttack(object, spell)
	if self.spellsAdded > 0 and object and spell and spell.target then
		for i, spells in pairs(_G.ZLib.shieldData) do
			local theSpell = nil
			if i == "Q" then theSpell = _Q
			elseif i == "W" then theSpell = _W
			elseif i == "E" then theSpell = _E
			elseif i == "R" then theSpell = _R end
			
			if theSpell and myHero:CanUseSpell(theSpell) == READY and GetDistance(spell.target) <= spells.range and spells.shotType == "target" then
				if object.team ~= myHero.team and spell.name:lower():find("attack") and spells.blocks.aa then
					if spells.targets.tower and spell.target.type == "obj_AI_Turret" and (100*spell.target.health/spell.target.maxHealth) < 100 then
						CastSpell(theSpell, object)
					elseif spells.targets.hero and spell.target.team == myHero.team then
						CastSpell(theSpell, object)
					end
				end
			elseif theSpell and myHero:CanUseSpell(theSpell) == READY and spell.shotType ~= "target" then
				
			end
		end
	end
end
--
--End: Heal/Shield Manager (ZHealManager)
--
------------------------------------------------------------------------------------------------------
--
--START: Skill Shot Check (ZSkillShotCheck)
--
class("ZSkillShotCheck")
function ZSkillShotCheck:__init()
	self.allSkillData = {
		["Ahri"] = {
			["AhriOrbofDeception"] = { pretty = "Orb of Deception", slot = "Q",  range = 880, width = 100, speed = 450, delay = 250, shape = "line", name = "AhriOrbofDeception", projectile = "Ahri_Orb_mis.troy", isCC = false, collision = { minion = false, hero = false }, dmgType = "AP" },
			["AhriSeduce"] = { pretty = "Charm", slot = "E", range = 1000, width = 60, speed = 1200, delay = 250, shape = "line", name = "AhriSeduce", projectile = "Ahri_Charm_mis.troy", isCC = true, collision = { minion = true, hero = true }, dmgType = "AP"}
		},
		["Amumu"] = {
			["BandageToss"] = { pretty = "Bandage Toss", slot = "Q", range = 1100, width = 80, speed = 2000, delay = 250, shape = "line", name = "BandageToss", projectile = "Bandage_beam.troy", isCC = true, collision = { minion = true, hero = true }, dmgType = "AP"}
		},
		["Anivia"] = {
			["FlashFrostSpell"] = { pretty = "Flash Frost", slot = "Q", range = 1100, width = 110, speed = 850, delay = 250, shape = "line", name = "FlashFrostSpell", projectile = "cryo_FlashFrost_mis.troy", isCC = true, collision = { minion = false, hero = false }, dmgType = "AP"}
		},
		["Ashe"] = {
			["AsheQ"] = { pretty = "Rangers Focus", aaBuff = true, slot = "Q" },
			["Volley"] = { pretty = "Volley", slot = "W", range = 0, width = 0, speed = 0, delay = 0, shape = "cone", name = "Volley", projectile = "", isCC = false, collision = { minion = true, hero = true }, dmgType = "AD"},
			["AsheSpiritOfTheHawk"] = { pretty = "Hawkshot", slot = "E", range = 0, width = 0, speed = 0, delay = 0, shape = "line", name = "AsheSpiritOfTheHawk", projectile = "", isCC = false, collision = { minion = false, hero = false }},
			["EnchantedCrystalArrow"] = { pretty = "Crystal Arrow", slot = "R", range = math.huge, width = 0, speed = 0, delay = 0, shape = "line", name = "EnchantedCrystalArrow", projectile = "", isCC = true, collision = { minion = false, hero = true }, dmgType = "AD"}
		},
		["Vayne"] = {
			pretty = "Vayne",
			["VayneTumble"] = { pretty = "Tumble", isDash = true, slot = "Q" }
		},
		["Jax"] = {
			pretty = "Jax",
			["JaxLeapStrike"] = { pretty = "Leap Strike", slot = "Q", isDash = true },
			["JaxEmpowerTwo"] = { pretty = "Empower", slot = "W" },
			["JaxCounterStrike"] = { pretty = "Counter Strike", isCC = true, slot = "E" },
			["JaxRelentlessAssault"] = { pretty = "Grandmasters Might", slot = "R" }
		}
	}
	
	self.summoners = {
		["SummonerHeal"] = { pretty = "Heal" },
		["SummonerHaste"] = { pretty = "Ghost" },
		["SummonerBoost"] = { pretty = "Cleanse" },
		["SummonerExhaust"] = { pretty = "Exhaust" },
		["SummonerTeleport"] = { pretty = "Teleport" },
		["SummonerBarrier"] = { pretty = "Barrier" },
		["recall"] = { pretty = "Recall"}
	}
	
	self.items = {
		["ItemDarkCrystalFlask"] = { pretty = "Corrupting Potion" }
	}
end
--
--End: Skill Shot Check (ZSkillShotCheck)
--
------------------------------------------------------------------------------------------------------
--
--START: Pretty Notifications (ZNotifications) --Credit To: BlueCore for the origional code (temp until i make my own way)
--
class("ZNotifications")
function ZNotifications:__init()
	self.displayParams = {
		length = 276,
		width = 66,
		position = {(WINDOW_W*0.995), (WINDOW_H*0.1)},
		showTime = 0.5
	}
	self.blocks = {}
	self.noSpam = nil
	_G.ZLib.menu:addSubMenu(">> Display Settings <<", "zDisplay")
	_G.ZLib.menu.zDisplay:addParam("notification", "Show Notifications", SCRIPT_PARAM_ONOFF, true)
end

function ZNotifications:OnDraw()
	if _G.ZLib.menu.zDisplay.notification == false then return end

	if tableLength(self.blocks) > round((WINDOW_H / 108), 0) then
		table.remove(self.blocks, 1)
	end
	
	local inGameTime = GetGameTimer()
	
	for i, v in pairs(self.blocks) do
		if v[3] + v[4] + self.displayParams.showTime <= inGameTime then
			table.remove(self.blocks, i)
		end
		
		v[5] = self.displayParams.position[1]
		v[6] = self.displayParams.position[2] + (self.displayParams.width + 6) * (i - 1)
		
		if self.displayParams.showTime + v[4] >= inGameTime then
            local percent = ((v[4] + self.displayParams.showTime) - inGameTime)/self.displayParams.showTime
            v[5] = self.displayParams.position[1] + self.displayParams.length * percent
        end
		
		if v[3] + v[4] <= inGameTime and v[3] + v[4] + self.displayParams.showTime > inGameTime then
            local percent = (inGameTime - (v[4]+v[3]))/self.displayParams.showTime
            v[5] = self.displayParams.position[1] + self.displayParams.length * percent
        end
		
		self:ShowBlock(v[5], v[6], v[1], v[2])
 	end
end

function ZNotifications:ShowBlock(x, y, header, text)
	local lenghtHeader = GetTextArea(header, 25).x - 240
	local lenghtContext = GetTextArea(text, 20).x - 250
	local extraLenght = lenghtHeader > lenghtContext and lenghtHeader or lenghtContext
	local tileLenght = self:CursorIsOverTile(x, y) and self.displayParams.length + (extraLenght > 0 and extraLenght or 0) or self.displayParams.length
	
	local borderColor = self:CursorIsOverTile(x, y) and ARGB(255,93,86,58) or ARGB(255*0.5,93,86,58)
	local borderThickness = 4
	local borderYOffset = (self.displayParams.width * 0.5)
	DrawLine(x - tileLenght, y - borderYOffset, x, y - borderYOffset, borderThickness, borderColor)
	DrawLine(x - tileLenght, y + borderYOffset, x, y + borderYOffset, borderThickness, borderColor)
	DrawLine(x - tileLenght + (borderThickness * 0.5), y - borderYOffset + (borderThickness * 0.5), x - tileLenght + (borderThickness * 0.5), y + borderYOffset - (borderThickness * 0.5), borderThickness, borderColor)
	DrawLine(x - (borderThickness * 0.5), y - borderYOffset + (borderThickness * 0.5), x - (borderThickness * 0.5), y + borderYOffset - (borderThickness * 0.5), borderThickness, borderColor)
	
	local mainColor = self:CursorIsOverTile(x, y) and ARGB(255,12,19,18) or ARGB(255*0.5,12,19,18)
	local mainBorderOffset = (borderThickness*0.5)
	DrawLine(x - tileLenght + borderThickness, y, x - borderThickness, y, self.displayParams.width - borderThickness, mainColor)
	
	local boxColor = ARGB(255, 35,65,63)
	local boxHeight = 24
	local boxWidth = 24
	local boxYOffset = (self.displayParams.width*0.5-boxHeight*0.5)
	if self:CursorisOverBox(x, y) then
		DrawLine(x - boxWidth - borderThickness, y - boxYOffset + mainBorderOffset, x - borderThickness, y - boxYOffset + mainBorderOffset, boxHeight, boxColor)
	end
	
	local headerYOffset = 30;
	local fixedHeader = (not self:CursorIsOverTile(x, y) and GetTextArea(header, 25).x > 240) and header:sub(1, 20).." ..." or header
	DrawText(fixedHeader, 25, x - tileLenght + borderThickness*2, y - headerYOffset, ARGB(255, 127, 255, 212))
	
	local contextYOffsetLine1 = 5
	local fixedContext = (not self:CursorIsOverTile(x, y) and GetTextArea(text, 20).x > 250) and text:sub(1, 25).." ..." or text
	DrawText(fixedContext, 20, x - tileLenght + borderThickness*2, y + contextYOffsetLine1, ARGB(255, 250, 235, 215))
	
	DrawText("x",33,x - boxWidth, y -boxYOffset*2 +5,ARGB(255,143,188,143))
end

function ZNotifications:CursorIsOverTile(posX, posY)
	local cursor = GetCursorPos()
	local x = posX - cursor.x
	local y = posY - cursor.y
	return (x < self.displayParams.length and x > 0) and (y < 30 and y > -45)
end

function ZNotifications:CursorisOverBox(posX, posY)
	local cursor = GetCursorPos()
	local x = posX - cursor.x
	local y = posY - cursor.y
	return (x < 28 and x > 0) and (y < 24 and y > -10)
end

function ZNotifications:OnWndMsg(msg, wParam)
	if msg ~= 513 then return end
	for i, v in pairs(self.blocks) do
		if self:CursorisOverBox(v[5], v[6]) then
			v[3] = GetGameTimer() - v[4];
		end
	end
end

function ZNotifications:NewBlock(header, message, length)
	self.blocks[tableLength(self.blocks) +1] = {header, message, length, GetGameTimer(), self.displayParams.position[1], self.displayParams.position[2]}
end

function ZNotifications:ProcessAttack(object, spell)
	if object and spell and object.type == myHero.type then
		local prettyName = spell.name
		local prettyChamp = object.charName
		local myTitle = nil
		local myContent = nil
		
		local mType = "N"
		
		if  _G.ZLib.skillShot.allSkillData[object.charName] and  _G.ZLib.skillShot.allSkillData[object.charName].pretty then
			prettyChamp = _G.ZLib.skillShot.allSkillData[object.charName].pretty
		end
		
		if _G.ZLib.skillShot.summoners[spell.name] and _G.ZLib.skillShot.summoners[spell.name].pretty then
			prettyName = _G.ZLib.skillShot.summoners[spell.name].pretty
			myContent = "Summoner spell " .. prettyName .. " used by " .. prettyChamp
			mType = "S"
		elseif _G.ZLib.skillShot.items[spell.name] and _G.ZLib.skillShot.items[spell.name].pretty then
			prettyName = _G.ZLib.skillShot.items[spell.name].pretty
			myContent = "Item " .. prettyName .. " used by " .. prettyChamp
			mType = "I"
		elseif _G.ZLib.skillShot.allSkillData[object.charName] and _G.ZLib.skillShot.allSkillData[object.charName][spell.name] and _G.ZLib.skillShot.allSkillData[object.charName][spell.name].pretty then
			prettyName = _G.ZLib.skillShot.allSkillData[object.charName][spell.name].pretty
			if _G.ZLib.skillShot.allSkillData[object.charName][spell.name].isDash then
				myContent = "Dash spell " .. prettyName .. " used by " .. prettyChamp
			elseif _G.ZLib.skillShot.allSkillData[object.charName][spell.name].isCC then
				myContent = "CC spell " .. prettyName .. " used by " .. prettyChamp
			elseif _G.ZLib.skillShot.allSkillData[object.charName][spell.name].shape then
				myContent = "Skill spell " .. prettyName .. " used by " .. prettyChamp
			end
			mType = "P"
		end
		
		if myTitle == nil then
			myTitle = prettyChamp
		end
		if myContent == nil then
			myContent = "Spell " .. prettyName .. " used by " .. prettyChamp
		end
		
		if _G.ZLib.skillShot.allSkillData[object.charName] and _G.ZLib.skillShot.allSkillData[object.charName][spell.name] and _G.ZLib.skillShot.allSkillData[object.charName][spell.name].slot then
			myContent = myContent .. " [" .. _G.ZLib.skillShot.allSkillData[object.charName][spell.name].slot .. "]"
		end
		if self.noSpam ~= myContent and mType == "S" then
			self.noSpam = myContent
			self:NewBlock(myTitle, myContent, 6)
		end
	end
end
--
--End: Pretty Notifications (ZNotifications) --Credit To: BlueCore for the origional code (temp until i make my own way)
--
------------------------------------------------------------------------------------------------------

function OnWndMsg(msg,wParam)
	if _G.ZLib.notification then _G.ZLib.notification:OnWndMsg(msg, wParam) end
end

function OnProcessSpell(unit, spell)
	if _G.ZLib and _G.ZLib.notification then _G.ZLib.notification:ProcessAttack(unit, spell) end
	if _G.ZLib and _G.ZLib.prediction then _G.ZLib.prediction:ProcessAttack(unit, spell) end
end