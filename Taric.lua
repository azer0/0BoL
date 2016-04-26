if myHero.charName ~= "Taric" then return end

require "VPrediction"

spells = {
	Q = {
		ready = false,
		range = 300
	},
	W = {
		ready = false,
		range = 1100
	},
	E = {
		ready = false,
		range = 660 - 40
	},
	R = {
		ready = false,
		range = 400
	}
}

local config = nil
local targetSelector = nil
local jungleSelector = nil
local VPred = VPrediction()
local bastionHolder = nil
local bastionLastSwitch = 0
local bastionInRange = false
local inDebugMode = false

local scriptVersion = "0.1.3"

function OnLoad()
	targetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, myHero.range * 2, DAMAGE_MAGIC)
	jungleSelector = minionManager(MINION_JUNGLE, myHero.range, myHero, MINION_SORT_MAXHEALTH_DEC)

	MakeMenu()
	
	VPred = VPrediction()
	PrettyM("Loaded version ".. scriptVersion .. ", good luck.", false)
end

function OnDraw()
	if not config.drawing.enable then return end

	--Self draws
	if spells.Q.ready and config.drawing.drawQ then
		DrawCircle(myHero.x, myHero.y, myHero.z, spells.Q.range, ARGB(255, 255, 255, 255))
	end
	
	if spells.W.ready and config.drawing.drawW then
		DrawCircle(myHero.x, myHero.y, myHero.z, spells.W.range, ARGB(255, 255, 255, 255))
	end
	
	if spells.E.ready and config.drawing.drawE then
		DrawCircle(myHero.x, myHero.y, myHero.z, spells.E.range, ARGB(255, 255, 255, 255))
	end

	if spells.R.ready and config.drawing.drawR then
		DrawCircle(myHero.x, myHero.y, myHero.z, spells.R.range, ARGB(255, 255, 255, 255))
	end
	
	--Bastion draws
	if bastionHolder ~= nil and not bastionHolder.dead then
		--Draw R for bastion
		if spells.R.ready and config.drawing.drawR then
			DrawCircle(bastionHolder.x, bastionHolder.y, bastionHolder.z, spells.R.range, ARGB(255, 255, 255, 255))
		end

		--Draw Q for bastion
		if spells.Q.ready and config.drawing.drawQb then
			DrawCircle(bastionHolder.x, bastionHolder.y, bastionHolder.z, spells.Q.range, ARGB(255, 255, 255, 255))
		end
		
		--Draw W for bastion
		if spells.W.ready and config.drawing.drawWb then
			DrawCircle(bastionHolder.x, bastionHolder.y, bastionHolder.z, spells.W.range, ARGB(255, 255, 255, 255))
		end
		
		--Draw E for bastion
		if spells.E.ready and config.drawing.drawEb then
			DrawCircle(bastionHolder.x, bastionHolder.y, bastionHolder.z, spells.E.range, ARGB(255, 255, 255, 255))
		end
	end
end

function OnTick()
	spells.Q.ready = (myHero:CanUseSpell(_Q) == READY)
	spells.W.ready = (myHero:CanUseSpell(_W) == READY)
	spells.E.ready = (myHero:CanUseSpell(_E) == READY)
	spells.R.ready = (myHero:CanUseSpell(_R) == READY)
	
	bastionInRange = false
	if bastionHolder ~= nil and myHero:GetDistance(bastionHolder) <= spells.W.range then
		bastionInRange = true
	end

	RConditional()
	QConditional()
	WConditional()
	EConditional()
end

function EConditional()
	if spells.E.ready and ((config.allE.comboMode and config.keybinds.comboKey) or (config.allE.harassMode and config.keybinds.harassKey) or (config.allE.laneMode and config.keybinds.laneClearKey) or (config.allE.jungleMode and config.keybinds.jungleClearKey)) then
		for _, eHero in ipairs(GetEnemyHeroes()) do
			if eHero and not eHero.dead and eHero:GetDistance(myHero) < spells.E.range + 50 then
				local MCastPosition, MHitChance, MPosition = VPred:GetLineCastPosition(eHero, 0.9, 150, spells.E.range, 900, myHero, false)

				if bastionInRange and bastionHolder ~= nil and not bastionHolder.dead then
					local CastPosition, HitChance, Position = VPred:GetLineCastPosition(eHero, 0.9, 150, spells.E.range, 900, bastionHolder, false)
					if HitChance >= MHitChance then
						PrettyM("Casting from " .. bastionHolder.charName, true)
						if CastPosition and HitChance >= 2 and GetDistance(CastPosition) < spells.E.range + 25 then
							CastSpell(_E, CastPosition.x, CastPosition.z)
						end
					else
						if MCastPosition and MHitChance >= 2 and GetDistance(MCastPosition) < spells.E.range + 25 then
							CastSpell(_E, MCastPosition.x, MCastPosition.z)
						end
					end
				else
					if MCastPosition and MHitChance >= 2 and GetDistance(MCastPosition) < spells.E.range + 25 then
						CastSpell(_E, MCastPosition.x, MCastPosition.z)
						return
					end
				end
			end
		end
	end
end

function RConditional()
	if spells.R.ready and ((config.allR.comboMode and config.keybinds.comboKey) or (config.allR.harassMode and config.keybinds.harassKey) or (config.allR.laneMode and config.keybinds.laneClearKey) or (config.allR.jungleMode and config.keybinds.jungleClearKey)) then
		if (100*myHero.health/myHero.maxHealth) < 11 then
			CastSpell(_R)
			return
		end
		if bastionHolder ~= nil and bastionInRange and (100*bastionHolder.health/bastionHolder.maxHealth) < 11 then
			CastSpell(_R)
			return
		end
	end
end

function QConditional()
	--Q Conditional checks
	if spells.Q.ready and ((config.allQ.comboMode and config.keybinds.comboKey) or (config.allQ.harassMode and config.keybinds.harassKey) or (config.allQ.laneMode and config.keybinds.laneClearKey) or (config.allQ.jungleMode and config.keybinds.jungleClearKey) or config.allQ.alwaysOn) then
		--High mana conditions - self
		if (100*myHero.health/myHero.maxHealth) < config.allQ.selfHP and (100*myHero.mana/myHero.maxMana) > config.allQ.selfMana then
			CastSpell(_Q)
			return
		end
		
		--Low mana conditions - self
		if (100*myHero.health/myHero.maxHealth) < config.allQ.selfHPl and (100*myHero.mana/myHero.maxMana) > config.allQ.selfManal then
			CastSpell(_Q)
			return
		end

		--Friend checks
		if config.allQ.checkBastion and bastionHolder ~= nil and bastionInRange and not bastionHolder.dead then
			--High mana conditions - bastion
			if (100*bastionHolder.health/bastionHolder.maxHealth) < config.allQ.friendHP and (100*myHero.mana/myHero.maxMana) > config.allQ.friendMana then
				CastSpell(_Q)
				return
			end
			
			--Low mana conditions - bastion
			if (100*bastionHolder.health/bastionHolder.maxHealth) < config.allQ.friendHPl and (100*myHero.mana/myHero.maxMana) > config.allQ.friendManal then
				CastSpell(_Q)
				return
			end
		end

		if config.allQ.checkTeam then
			for _, aHero in ipairs(GetAllyHeroes()) do
				if aHero and ValidTarget(aHero) and not aHero.dead then
					if (myHero:GetDistance(aHero) <= spells.Q.range) or (bastionInRange and bastionHolder:GetDistance(aHero) <= spells.Q.range) then
						if (100*aHero.health/aHero.maxHealth) < config.allQ.friendHP and (100*myHero.mana/myHero.maxMana) > config.allQ.friendMana then
							CastSpell(_Q)
							return
						end
						if (100*aHero.health/aHero.maxHealth) < config.allQ.friendHPl and (100*myHero.mana/myHero.maxMana) > config.allQ.friendManal then
							CastSpell(_Q)
							return
						end
					end
				end
			end
		end
	end
end

function WConditional()
	if spells.W.ready and ((config.allW.comboMode and config.keybinds.comboKey) or (config.allW.harassMode and config.keybinds.harassKey) or (config.allW.laneMode and config.keybinds.laneClearKey) or (config.allW.jungleMode and config.keybinds.jungleClearKey)) then
		if config.allW.wLogic == 1 then
			if (bastionHolder == nil and spells.W.ready and (bastionLastSwitch == 0 or bastionLastSwitch - os.clock() > 10)) or (bastionInRange == false and spells.W.ready and (bastionLastSwitch == 0 or bastionLastSwitch - os.clock() > 10)) then
				lowestHPAlly = nil
				lowestHP = 0
				for _, aHero in ipairs(GetAllyHeroes()) do
					if aHero and not aHero.dead and myHero:GetDistance(aHero) <= spells.W.range and aHero.visible and bastionHolder ~= aHero then
						if lowestHPAlly == nil then
							lowestHPAlly = aHero
							lowestHP = (100*aHero.health/aHero.maxHealth)
						else
							if lowestHPAlly ~= nil and (100*aHero.health/aHero.maxHealth) < lowestHP then
								lowestHPAlly = aHero
								lowestHP = (100*aHero.health/aHero.maxHealth)
							end
						end
					end
				end
				if lowestHPAlly ~= nil then
					CastSpell(_W, lowestHPAlly)
					return
				end
			end
		elseif config.allW.wLogic == 2 then
			if spells.W.ready and (bastionLastSwitch == 0 or bastionLastSwitch - os.clock() > 10) then
				lowestHPU = nil
				lowestHP = 101

				mostAllysInRangeU = nil
				mostAllysInRange = 0

				mostEnemysInRangeU = nil
				mostEnemysInRange = 0

				defaultAlly = nil

				cAllyPos = {}
				for _, aHero in ipairs(GetAllyHeroes()) do
					if aHero and not aHero.dead then
						cAllyPos[aHero.charName] = aHero.pos
					end
				end

				cEnemyPos = {}
				for _, eHero in ipairs(GetEnemyHeroes()) do
					if eHero and not eHero.dead then
						cEnemyPos[eHero.charName] = eHero.pos
					end
				end

				for _, aHero in ipairs(GetAllyHeroes()) do
					if aHero and not aHero.dead and aHero:GetDistance(myHero) <= spells.W.range and aHero ~= myHero then
						if defaultAlly == nil then
							defaultAlly = aHero
						end
						allysInRange = 0
						enemyInRange = 0
						for _, aaHero in ipairs(cAllyPos) do
							if aHero:GetDistance(aaHero) < spells.Q.range then
								allysInRange = allysInRange + 1
							end
						end
						for _, aeHero in ipairs(cEnemyPos) do
							if aHero:GetDistance(aeHero) < spells.Q.range then
								enemyInRange = enemyInRange + 1
							end
						end

						if lowestHPU == nil or lowestHP < aHero.health then
							lowestHPU = aHero
							lowestHP = aHero.health
						end

						if mostAllysInRangeU == nil or mostAllysInRange < allysInRange then
							mostAllysInRangeU = aHero
							mostAllysInRange = allysInRange
						end

						if mostEnemysInRangeU == nil or mostEnemysInRange < enemyInRange then
							mostEnemysInRangeU = aHero
							mostEnemysInRange = enemyInRange
						end
					end
				end

				if lowestHPU == mostEnemysInRangeU or lowestHPU == mostAllysInRangeU then
					CastSpell(_W, lowestHPU)
				elseif lowestHPU:GetDistance(mostAllysInRangeU) < spells.Q.range then
					CastSpell(_W, mostAllysInRangeU)
				elseif bastionHolder == nil then
					if lowestHPU ~= nil then
						CastSpell(_W, lowestHPU)
					elseif mostEnemysInRangeU ~= nil then
						CastSpell(_W, mostEnemysInRangeU)
					elseif mostAllysInRangeU ~= nil then
						CastSpell(_W, mostAllysInRangeU)
					end
				end
			end
		end
	end
end

function MakeMenu()
	config = scriptConfig("Taric", "zTaric")
	config:addTS(targetSelector)

	config:addSubMenu("[Keybinds]", "keybinds")
		config.keybinds:addParam("comboKey", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		config.keybinds:addParam("harassKey", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("C"))
		config.keybinds:addParam("laneClearKey", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
		config.keybinds:addParam("jungleClearKey", "Jungle Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
		config.keybinds:addParam("fleeKey", "Flee Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("T"))

	config:addSubMenu("[Q Logic]", "allQ")
		config.allQ:addParam("alwaysOn", "Always On", SCRIPT_PARAM_ONOFF, true)
		config.allQ:addParam("comboMode", "Enable in Combo", SCRIPT_PARAM_ONOFF, true)
		config.allQ:addParam("laneMode", "Enable in Lane Clear", SCRIPT_PARAM_ONOFF, true)
		config.allQ:addParam("jungleMode", "Enable in Jungle Clear", SCRIPT_PARAM_ONOFF, true)
		config.allQ:addParam("harassMode", "Enable in Harass", SCRIPT_PARAM_ONOFF, true)

		config.allQ:addParam("info2", "------------------------------", SCRIPT_PARAM_INFO, "")
		config.allQ:addParam("info1", "Me - High Mana Conditions", SCRIPT_PARAM_INFO, "")
		config.allQ:addParam("selfHP", "Use on self below HP %: ", SCRIPT_PARAM_SLICE, 50, 1, 100, 0)
		config.allQ:addParam("selfMana", "Use on self above mana %: ", SCRIPT_PARAM_SLICE, 50, 1, 100, 0)
		config.allQ:addParam("info2", "Me - Low Health Conditions", SCRIPT_PARAM_INFO, "")
		config.allQ:addParam("selfHPl", "Use on self below HP %: ", SCRIPT_PARAM_SLICE, 30, 1, 100, 0)
		config.allQ:addParam("selfManal", "Use on self above mana %: ", SCRIPT_PARAM_SLICE, 5, 1, 100, 0)

		config.allQ:addParam("info2", "------------------------------", SCRIPT_PARAM_INFO, "")
		config.allQ:addParam("info1", "Team - High Mana Conditions", SCRIPT_PARAM_INFO, "")
		config.allQ:addParam("friendHP", "Use on friend below HP %: ", SCRIPT_PARAM_SLICE, 50, 1, 100, 0)
		config.allQ:addParam("friendMana", "Use on friend above mana %: ", SCRIPT_PARAM_SLICE, 50, 1, 100, 0)
		config.allQ:addParam("info2", "Team - Low Health Conditions", SCRIPT_PARAM_INFO, "")
		config.allQ:addParam("friendHPl", "Use on friend below HP %: ", SCRIPT_PARAM_SLICE, 30, 1, 100, 0)
		config.allQ:addParam("friendManal", "Use on friend above mana %: ", SCRIPT_PARAM_SLICE, 5, 1, 100, 0)
		config.allQ:addParam("info2", "------------------------------", SCRIPT_PARAM_INFO, "")

		config.allQ:addParam("checkBastion", "Use Q Logic on Bastion Target", SCRIPT_PARAM_ONOFF, true)
		config.allQ:addParam("checkTeam", "Use Q Logic on Team", SCRIPT_PARAM_ONOFF, true)

	config:addSubMenu("[W Logic]", "allW")
		config.allW:addParam("comboMode", "Enable in Combo", SCRIPT_PARAM_ONOFF, true)
		config.allW:addParam("laneMode", "Enable in Lane Clear", SCRIPT_PARAM_ONOFF, true)
		config.allW:addParam("jungleMode", "Enable in Jungle Clear", SCRIPT_PARAM_ONOFF, true)
		config.allW:addParam("harassMode", "Enable in Harass", SCRIPT_PARAM_ONOFF, true)
		config.allW:addParam("info1", "------------------------------", SCRIPT_PARAM_INFO, "")
		config.allW:addParam("wLogic", "Logic Mode", SCRIPT_PARAM_LIST, 2, {"Always", "Smart"})
		config.allW:addParam("info1", "------------------------------", SCRIPT_PARAM_INFO, "")
		for _, aHero in ipairs(GetAllyHeroes()) do
			config.allW:addParam("hero" .. aHero.charName, "On ".. aHero.charName, SCRIPT_PARAM_ONOFF, true)
		end

	config:addSubMenu("[E Logic]", "allE")
		config.allE:addParam("comboMode", "Enable in Combo", SCRIPT_PARAM_ONOFF, true)
		config.allE:addParam("laneMode", "Enable in Lane Clear", SCRIPT_PARAM_ONOFF, true)
		config.allE:addParam("jungleMode", "Enable in Jungle Clear", SCRIPT_PARAM_ONOFF, true)
		config.allE:addParam("harassMode", "Enable in Harass", SCRIPT_PARAM_ONOFF, true)
		config.allE:addParam("info2", "------------------------------", SCRIPT_PARAM_INFO, "")

		config.allE:addParam("hitChance", "Min VPred Chance: ", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
		config.allE:addParam("bastion", "Enable Shots From Bastion", SCRIPT_PARAM_ONOFF, true)
		
	config:addSubMenu("[R Logic]", "allR")
		config.allR:addParam("comboMode", "Enable in Combo", SCRIPT_PARAM_ONOFF, true)
		config.allR:addParam("laneMode", "Enable in Lane Clear", SCRIPT_PARAM_ONOFF, true)
		config.allR:addParam("jungleMode", "Enable in Jungle Clear", SCRIPT_PARAM_ONOFF, true)
		config.allR:addParam("harassMode", "Enable in Harass", SCRIPT_PARAM_ONOFF, true)

	config:addSubMenu("[Drawing]", "drawing")
		config.drawing:addParam("enable", "Enable Draws", SCRIPT_PARAM_ONOFF, false)
		config.drawing:addParam("info2", "------------------------------", SCRIPT_PARAM_INFO, "")
		config.drawing:addParam("drawQ", "Draw Q Range - Self", SCRIPT_PARAM_ONOFF, false)
		config.drawing:addParam("drawW", "Draw W Range - Self", SCRIPT_PARAM_ONOFF, false)
		config.drawing:addParam("drawE", "Draw E Range - Self", SCRIPT_PARAM_ONOFF, true)
		config.drawing:addParam("drawR", "Draw R Range - Self", SCRIPT_PARAM_ONOFF, false)
		config.drawing:addParam("info2", "------------------------------", SCRIPT_PARAM_INFO, "")
		config.drawing:addParam("drawQb", "Draw Q Range - Bastion", SCRIPT_PARAM_ONOFF, false)
		config.drawing:addParam("drawWb", "Draw W Range - Bastion", SCRIPT_PARAM_ONOFF, false)
		config.drawing:addParam("drawEb", "Draw E Range - Bastion", SCRIPT_PARAM_ONOFF, true)
		config.drawing:addParam("drawRb", "Draw R Range - Bastion", SCRIPT_PARAM_ONOFF, false)

	
	config:addParam("info1", "Version: " .. scriptVersion, SCRIPT_PARAM_INFO, "")
	config:addParam("info1", "**Please note this version", SCRIPT_PARAM_INFO, "")
	config:addParam("info1", "of the script does not contain", SCRIPT_PARAM_INFO, "")
	config:addParam("info1", "auto update.**", SCRIPT_PARAM_INFO, "")
end

function OnApplyBuff(source, target, buff)
	if source == myHero and buff.name == "TaricW" then
		if target and target ~= myHero then
			bastionHolder = target
			bastionLastSwitch = os.clock()
			PrettyM("Bastion applied to " .. target.charName, true)
		end
	end
end

function PrettyM(message, isDebug)
	if isDebug and not inDebugMode then return end
	print("<font color=\"#415cf6\"><b>[<u>Zer0 Taric</u>]</b></font> <font color=\"#01cc9c\"><b>" .. message .. "</b></font>")
end