local zLibVer = 1

class("ZLib")
function ZLib:__init(scriptShort, scriptName)
	_G.ZLib = {
		menu = scriptConfig(scriptShort, scriptName),
		myData = ZChampData(myHero),
		printDisplay = ZPrintDisplay(scriptName),
		prediction = ZPrediction(),
		unit = ZUnitChecks(),
		orbwalk = nil,
		spellData = {},
		antiDash = {}
	}
	
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

function ZPrintDisplay:Loaded(message)
	if self.spam == message then return end
	self.spam = message
	print("<font color=\"#FF794C\">[<b>" .. self.prefix .. "</b>]</font> <font color=\"#3FFF33\">" .. message .. ".</font>")
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
		["spred"] = false
	}
	self.spellBinds = {
		["TR"] = {
			["q"] = nil,
			["w"] = nil,
			["e"] = nil,
			["r"] = nil
		}
	}
end

function ZPrediction:BindSpell(slot, info, pred)
	if slot and info and pred and info.shotType == "skillshot" then
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

function ZPrediction:Predict(spell, target, allowCol)
	if not allowCol then allowCol = false end
	if spell and target and _G.ZLib.spellData[myHero.charName][spell] and _G.ZLib.spellData[myHero.charName][spell].shotType == "skillshot" then
		--Q
		if spell == "Q" and _G.ZLib.menu.zPred.qPred == 1 then
			local pos, hc, info = FHPrediction.GetPrediction("Q", target)
			if pos and hc and hc > 0 and ((not allowCol and not info.collision) or allowCol) then
				return {
					castPos = pos,
					hitChance = hc,
					pred = "FH"
				}
			end
		elseif spell == "Q" and _G.ZLib.menu.zPred.qPred == 2 then
			local CastPosition, HitChance, Collision = TRPrediction:GetPrediction(self.spellBinds["TR"]["q"], target, myHero)
			if CastPosition and HitChance and ((not allowCol and not Collision) or allowCol) and ((_G.ZLib.menu.zPred.qTR == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.qTR == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.qTR == 3 and HitChance >= 2)) then
				return {
					castPos = CastPosition,
					hitChance = HitChance,
					pred = "TR"
				}
			end
		elseif spell == "Q" and s_G.ZLib.menu.zPred.qPred == 3 then
			if _G.ZLib.spellData[myHero.charName]["Q"].skillType == "line" then
				local CastPosition, HitChance = VPrediction:GetLineCastPosition(target, _G.ZLib.spellData[myHero.charName]["Q"].delay, _G.ZLib.spellData[myHero.charName]["Q"].width, _G.ZLib.spellData[myHero.charName]["Q"].range, _G.ZLib.spellData[myHero.charName]["Q"].speed, myHero, allowCol)
				if CastPosition and HitChance and ((_G.ZLib.menu.zPred.qVP == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.qVP == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.qVP == 3 and HitChance >= 2)) then
					return {
						castPos = CastPosition,
						hitChance = HitChance,
						pred = "VP"
					}
				end
			elseif _G.ZLib.spellData[myHero.charName]["Q"].skillType == "circle" then
				local CastPosition, HitChance = VPrediction:GetCircularCastPosition(target, _G.ZLib.spellData[myHero.charName]["Q"].delay, _G.ZLib.spellData[myHero.charName]["Q"].width, _G.ZLib.spellData[myHero.charName]["Q"].range, _G.ZLib.spellData[myHero.charName]["Q"].speed, myHero, allowCol)
				if CastPosition and HitChance and ((_G.ZLib.menu.zPred.qVP == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.qVP == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.qVP == 3 and HitChance >= 2)) then
					return {
						castPos = CastPosition,
						hitChance = HitChance,
						pred = "VP"
					}
				end
			elseif _G.ZLib.spellData[myHero.charName]["Q"].skillType == "cone" then
				local CastPosition, HitChance = VPrediction:GetCircularCastPosition(target, _G.ZLib.spellData[myHero.charName]["Q"].delay, _G.ZLib.spellData[myHero.charName]["Q"].width, _G.ZLib.spellData[myHero.charName]["Q"].range, _G.ZLib.spellData[myHero.charName]["Q"].speed, myHero, allowCol)
				if CastPosition and HitChance and ((_G.ZLib.menu.zPred.qVP == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.qVP == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.qVP == 3 and HitChance >= 2)) then
					return {
						castPos = CastPosition,
						hitChance = HitChance,
						pred = "VP"
					}
				end
			end
		--W
		elseif spell == "W" and _G.ZLib.menu.zPred.wPred == 1 then
			local pos, hc, info = FHPrediction.GetPrediction("W", target)
			if pos and hc and hc > 0 and ((not allowCol and not info.collision) or allowCol) then
				return {
					castPos = pos,
					hitChance = hc,
					pred = "FH"
				}
			end
		elseif spell == "W" and _G.ZLib.menu.zPred.wPred == 2 then
			local CastPosition, HitChance, Collision = TRPrediction:GetPrediction(self.spellBinds["TR"]["w"], target, myHero)
			if CastPosition and HitChance and ((not allowCol and not Collision) or allowCol) and ((_G.ZLib.menu.zPred.wTR == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.wTR == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.wTR == 3 and HitChance >= 2)) then
				return {
					castPos = CastPosition,
					hitChance = HitChance,
					pred = "TR"
				}
			end
		elseif spell == "W" and _G.ZLib.menu.zPred.wPred == 3 then
			if _G.ZLib.spellData[myHero.charName]["W"].skillType == "line" then
				local CastPosition, HitChance = VPrediction:GetLineCastPosition(target, _G.ZLib.spellData[myHero.charName]["W"].delay, _G.ZLib.spellData[myHero.charName]["W"].width, _G.ZLib.spellData[myHero.charName]["W"].range, _G.ZLib.spellData[myHero.charName]["W"].speed, myHero, allowCol)
				if CastPosition and HitChance and ((_G.ZLib.menu.zPred.wVP == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.wVP == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.wVP == 3 and HitChance >= 2)) then
					return {
						castPos = CastPosition,
						hitChance = HitChance,
						pred = "VP"
					}
				end
			elseif _G.ZLib.spellData[myHero.charName]["W"].skillType == "circle" then
				local CastPosition, HitChance = VPrediction:GetCircularCastPosition(target, _G.ZLib.spellData[myHero.charName]["W"].delay, _G.ZLib.spellData[myHero.charName]["W"].width, _G.ZLib.spellData[myHero.charName]["W"].range, _G.ZLib.spellData[myHero.charName]["W"].speed, myHero, allowCol)
				if CastPosition and HitChance and ((_G.ZLib.menu.zPred.wVP == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.wVP == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.wVP == 3 and HitChance >= 2)) then
					return {
						castPos = CastPosition,
						hitChance = HitChance,
						pred = "VP"
					}
				end
			elseif _G.ZLib.spellData[myHero.charName]["W"].skillType == "cone" then
				local CastPosition, HitChance = VPrediction:GetCircularCastPosition(target, _G.ZLib.spellData[myHero.charName]["W"].delay, _G.ZLib.spellData[myHero.charName]["W"].width, _G.ZLib.spellData[myHero.charName]["W"].range, _G.ZLib.spellData[myHero.charName]["W"].speed, myHero, allowCol)
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
			local pos, hc, info = FHPrediction.GetPrediction("E", target)
			if pos and hc and hc > 0 and ((not allowCol and not info.collision) or allowCol) then
				return {
					castPos = pos,
					hitChance = hc,
					pred = "FH"
				}
			end
		elseif spell == "E" and _G.ZLib.menu.zPred.ePred == 2 then
			local CastPosition, HitChance, Collision = TRPrediction:GetPrediction(self.spellBinds["TR"]["e"], target, myHero)
			if CastPosition and HitChance and ((not allowCol and not Collision) or allowCol) and ((_G.ZLib.menu.zPred.eTR == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.eTR == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.eTR == 3 and HitChance >= 2)) then
				return {
					castPos = CastPosition,
					hitChance = HitChance,
					pred = "TR"
				}
			end
		elseif spell == "E" and _G.ZLib.menu.zPred.ePred == 3 then
			if _G.ZLib.spellData[myHero.charName]["E"].skillType == "line" then
				local CastPosition, HitChance = VPrediction:GetLineCastPosition(target, _G.ZLib.spellData[myHero.charName]["E"].delay, _G.ZLib.spellData[myHero.charName]["E"].width, _G.ZLib.spellData[myHero.charName]["E"].range, _G.ZLib.spellData[myHero.charName]["E"].speed, myHero, allowCol)
				if CastPosition and HitChance and ((_G.ZLib.menu.zPred.eVP == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.eVP == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.eVP == 3 and HitChance >= 2)) then
					return {
						castPos = CastPosition,
						hitChance = HitChance,
						pred = "VP"
					}
				end
			elseif _G.ZLib.spellData[myHero.charName]["E"].skillType == "circle" then
				local CastPosition, HitChance = VPrediction:GetCircularCastPosition(target, _G.ZLib.spellData[myHero.charName]["E"].delay, _G.ZLib.spellData[myHero.charName]["E"].width, _G.ZLib.spellData[myHero.charName]["E"].range, _G.ZLib.spellData[myHero.charName]["E"].speed, myHero, allowCol)
				if CastPosition and HitChance and ((_G.ZLib.menu.zPred.eVP == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.eVP == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.eVP == 3 and HitChance >= 2)) then
					return {
						castPos = CastPosition,
						hitChance = HitChance,
						pred = "VP"
					}
				end
			elseif _G.ZLib.spellData[myHero.charName]["E"].skillType == "cone" then
				local CastPosition, HitChance = VPrediction:GetCircularCastPosition(target, _G.ZLib.spellData[myHero.charName]["E"].delay, _G.ZLib.spellData[myHero.charName]["E"].width, _G.ZLib.spellData[myHero.charName]["E"].range, _G.ZLib.spellData[myHero.charName]["E"].speed, myHero, allowCol)
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
			local pos, hc, info = FHPrediction.GetPrediction("R", target)
			if pos and hc and hc > 0 and ((not allowCol and not info.collision) or allowCol) then
				return {
					castPos = pos,
					hitChance = hc,
					pred = "FH"
				}
			end
		elseif spell == "R" and _G.ZLib.menu.zPred.rPred == 2 then
			local CastPosition, HitChance, Collision = TRPrediction:GetPrediction(self.spellBinds["TR"]["r"], target, myHero)
			if CastPosition and HitChance and ((not allowCol and not Collision) or allowCol) and ((_G.ZLib.menu.zPred.rTR == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.rTR == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.rTR == 3 and HitChance >= 2)) then
				return {
					castPos = CastPosition,
					hitChance = HitChance,
					pred = "TR"
				}
			end
		elseif spell == "R" and _G.ZLib.menu.zPred.rPred == 3 then
			if _G.ZLib.spellData[myHero.charName]["E"].skillType == "line" then
				local CastPosition, HitChance = VPrediction:GetLineCastPosition(target, _G.ZLib.spellData[myHero.charName]["R"].delay, _G.ZLib.spellData[myHero.charName]["R"].width, _G.ZLib.spellData[myHero.charName]["R"].range, _G.ZLib.spellData[myHero.charName]["R"].speed, myHero, allowCol)
				if CastPosition and HitChance and ((_G.ZLib.menu.zPred.rVP == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.rVP == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.rVP == 3 and HitChance >= 2)) then
					return {
						castPos = CastPosition,
						hitChance = HitChance,
						pred = "VP"
					}
				end
			elseif _G.ZLib.spellData[myHero.charName]["R"].skillType == "circle" then
				local CastPosition, HitChance = VPrediction:GetCircularCastPosition(target, _G.ZLib.spellData[myHero.charName]["R"].delay, _G.ZLib.spellData[myHero.charName]["R"].width, _G.ZLib.spellData[myHero.charName]["R"].range, _G.ZLib.spellData[myHero.charName]["R"].speed, myHero, allowCol)
				if CastPosition and HitChance and ((_G.ZLib.menu.zPred.rVP == 1 and HitChance >= 1) or (_G.ZLib.menu.zPred.rVP == 2 and HitChance >= 1.5) or (_G.ZLib.menu.zPred.rVP == 3 and HitChance >= 2)) then
					return {
						castPos = CastPosition,
						hitChance = HitChance,
						pred = "VP"
					}
				end
			elseif _G.ZLib.spellData[myHero.charName]["R"].skillType == "cone" then
				local CastPosition, HitChance = VPrediction:GetCircularCastPosition(target, _G.ZLib.spellData[myHero.charName]["R"].delay, _G.ZLib.spellData[myHero.charName]["R"].width, _G.ZLib.spellData[myHero.charName]["R"].range, _G.ZLib.spellData[myHero.charName]["R"].speed, myHero, allowCol)
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
end

function ZPrediction:AddToMenu()
	_G.ZLib.menu:addSubMenu(">> Prediction Settings <<", "zPred")
	if _G.ZLib.spellData[myHero.charName]["Q"] and _G.ZLib.spellData[myHero.charName]["Q"].shotType == "skillshot" then
		_G.ZLib.menu.zPred:addParam("qPred", "Q Prediction", SCRIPT_PARAM_LIST, 1, {
			[1] = "FH Prediction",
			[2] = "TR Prediction",
			[3] = "V Prediction"
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
			[3] = "V Prediction"
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
			[3] = "V Prediction"
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
			[3] = "V Prediction"
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
		[3] = "V Prediction"
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
	
	_G.ZLib.menu.zPred:addParam("dashPred", "Dash Prediction", SCRIPT_PARAM_LIST, 1, {
		[1] = "FH Prediction"
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
							elseif spell.spellSlot == "W" then
								CastSpell(_W, pos.x, pos.z)
							elseif spell.spellSlot == "E" then
								CastSpell(_E, pos.x, pos.z)
							elseif spell.spellSlot == "R" then
								CastSpell(_R, pos.x, pos.z)
							end
						end
					end
				end
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
--
--End: Unit Checks (ZUnitChecks)
--
------------------------------------------------------------------------------------------------------