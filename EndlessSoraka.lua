if myHero.charName ~= "Soraka" then return end

require "VPrediction"

class("Soraka")
	function Soraka:__init(util, base, orbwalk)
		if myHero.charName ~= "Soraka" then
			return
		end
		
		self.spellQ = { name = myHero:GetSpellData(_Q).name, range = 770, delay = 0.5, speed = 1500, width = 110 }
		self.spellW = { name = myHero:GetSpellData(_W).name, range = 539, delay = 0.5, speed = 1000, width = 0, healing = { 70, 110, 150, 190, 230 }, extraAp = 35 }
		self.spellE = { name = myHero:GetSpellData(_E).name, range = 880, delay = 0.6, speed = 2000, width = 25 }
		self.spellR = { name = myHero:GetSpellData(_R).name, delay = 0.5, range = math.huge }
		
		self.bestHealTarget = nil
		self.healEngine = nil
		self.utility = util
		self.base = base
		self.orbWalk = orbwalk
		self.aaRange = myHero.range
		self.menu = scriptConfig("[Endless Soraka]", "EndlessSoraka")
		self.vp = VPrediction()
		self.castThisTick = false
		self.recalling = false
		self.friendlyTowersRange = 0
		self.friendlyTowers = {}
		
		self.Interrupt = {
			["Katarina"] = {charName = "Katarina", stop = {name = "Death lotus", spellName = "KatarinaR", ult = true }},
			["Nunu"] = {charName = "Nunu", stop = {name = "Absolute Zero", spellName = "AbsoluteZero", ult = true }},
			["Malzahar"] = {charName = "Malzahar", stop = {name = "Nether Grasp", spellName = "AlZaharNetherGrasp", ult = true}},
			["Caitlyn"] = {charName = "Caitlyn", stop = {name = "Ace in the hole", spellName = "CaitlynAceintheHole", ult = true, projectileName = "caitlyn_ult_mis.troy"}},
			["FiddleSticks"] = {charName = "FiddleSticks", stop = {name = "Crowstorm", spellName = "Crowstorm", ult = true}},
			["Galio"] = {charName = "Galio", stop = {name = "Idole of Durand", spellName = "GalioIdolOfDurand", ult = true}},
			["Janna"] = {charName = "Janna", stop = {name = "Monsoon", spellName = "ReapTheWhirlwind", ult = true}},
			["MissFortune"] = {charName = "MissFortune", stop = {name = "Bullet time", spellName = "MissFortuneBulletTime", ult = true}},
			["MasterYi"] = {charName = "MasterYi", stop = {name = "Meditate", spellName = "Meditate", ult = false}},
			["Pantheon"] = {charName = "Pantheon", stop = {name = "Skyfall", spellName = "PantheonRJump", ult = true}},
			["Shen"] = {charName = "Shen", stop = {name = "Stand united", spellName = "ShenStandUnited", ult = true}},
			["Urgot"] = {charName = "Urgot", stop = {name = "Position Reverser", spellName = "UrgotSwap2", ult = true}},
			["Warwick"] = {charName = "Warwick", stop = {name = "Infinite Duress", spellName = "InfiniteDuress", ult = true}},
		}
		
		self.friendlyMinionMan = minionManager(MINION_ALLY, self.spellW["range"], myHero, MINION_SORT_HEALTH_ASC)
		self.minionMan = minionManager(MINION_ENEMY, self.aaRange, myHero, MINION_SORT_HEALTH_ASC)
		self.jungleMan = minionManager(MINION_JUNGLE, self.aaRange, myHero, MINION_SORT_HEALTH_ASC)
		
		for i = 1, objManager.iCount do
			local turret = objManager:getObject(i)
			if turret and turret.valid and turret.team == myHero.team and turret.type == "obj_AI_Turret" and not string.find(turret.name, "TurretShrine") then
				table.insert(self.friendlyTowers, turret)
			end
		end
		
		self:SetupMenu()
		
		AddApplyBuffCallback(function (source, target, buff)
			self:OnApplyBuff(source, target, buff)
		end)
		
		AddRemoveBuffCallback(function (source, buff)
			self:OnRemoveBuff(source, buff)
		end)
		
		AddAnimationCallback(function(unit, animation)
			self:OnAnimation(unit, animation)
		end)
		
		AddTickCallback(function()
		
			if self.menu.keys.showWards then
				self.base:MagWardOnTick()
			end
			
			if self.recalling then return end
			
			if self.menu.keys.Carry then
				self:OnTickSupport()
			elseif self.menu.keys.Flee then
				self:OnTickFlee()
			else
				self:OnTickOther()
			end
			
		end)
		
		AddDrawCallback(function()
		
			if self.menu.keys.showWards then
				self.base:MagWardOnDraw()
			end
			
			self:OnDraw()
			
		end)
		
		AddProcessSpellCallback(function(unit, spell)
			self:OnProcessSpell(unit, spell)
		end)
		
		self.utility:post("All call backs set up.", 99)
		
		self.loaded = true
	end
	
	function Soraka:DetermineWHeal()
		return (self.spellW.healing[myHero:GetSpellData(_W).level]) + (0.35 * myHero.ap)
	end
	
	function Soraka:SetHealEngine(engine)
		self.healEngine = engine
	end

	function Soraka:OnProcessSpell(unit, spell)
		self.orbWalk:OnProcessSpell(unit, spell)
		if self.menu.e.UnderInterrupt and (myHero:CanUseSpell(_E) == 0) then
			if unit and self.Interrupt[unit.charName] ~= nil and self.menu.e["e" .. self.Interrupt[unit.charName]["stop"]["spellName"]] and unit:GetDistance(myHero) < self.spellE["range"] then
				local CastPosition, HitChance, Position = self.vp:GetCircularCastPosition(unit, self.spellE["delay"], self.spellE["width"], self.spellE["range"], self.spellE["speed"], myHero, false)
				if CastPosition and HitChance >= 2 and GetDistance(CastPosition) < self.spellE["range"] then
					CastSpell(_E, CastPosition.x, CastPosition.z)
					self.castThisTick = true
				end
			end
		end
	end

	function Soraka:OnApplyBuff(source, target, buff)
		if source ~= nil and buff and source.isMe and buff.name:lower() == "recall" or buff.name:lower() == "summonerteleport" or buff.name:lower() == "recallimproved" then
			self.recalling = true
		end
	end

	function Soraka:OnRemoveBuff(source, buff)
		if source ~= nil and buff and source.isMe and buff.name:lower() == "recall" or buff.name:lower() == "summonerteleport" or buff.name:lower() == "recallimproved" then
			self.recalling = false
		end
	end

	function Soraka:OnAnimation(unit, animation)
		self.orbWalk:OnAnimation(unit, animation)
	end

	function Soraka:OnTickOther()
		self.castThisTick = false
		
		spellQC = (myHero:CanUseSpell(_Q) == 0)
		spellWC = (myHero:CanUseSpell(_W) == 0)
		spellEC = (myHero:CanUseSpell(_E) == 0)
		spellRC = (myHero:CanUseSpell(_R) == 0)
		
		myHpPerc = (myHero.health / myHero.maxHealth) * 100
		myManaPerc = (myHero.mana / myHero.maxMana) * 100
		
		passedWCondition = false
		passedWTarget = nil
		passedRCondition = false
		
		if (spellWC and (self.menu.endlesssoraka.Heal or self.menu.carry.UseW) and not self.menu.w.UseW and myHpPerc > self.menu.w.HP and self.menu.endlesssoraka.Heal) and not self.castThisTick or (spellRC and not self.castThisTick and self.menu.endlesssoraka.Ult) then
			for i, target in pairs(GetAllyHeroes()) do
				if target and not target.dead and myHero:GetDistance(target) < self.spellQ["range"] and self.menu.w["heal" .. target.charName] and self.menu.endlesssoraka.Heal then
					tHpPerc = (target.health / target.maxHealth) * 100
					if spellWC and tHpPerc < 85 then
						passedWCondition = true
						if passedWTarget ~= nil then
							if passedWTarget.health > target.health then
								passedWTarget = target
							end
						else
							passedWTarget = target
						end
					end
					if spellRC and tHpPerc < 25 and self.menu.r["heal" .. target.charName] and self.menu.endlesssoraka.Ult then
						eInRange = 0
						for i, eHero in pairs(GetEnemyHeroes()) do
							if eHero and not eHero.dead and target:GetDistance(eHero) < 400 then
								eInRange = eInRange + 1
							end
						end
						if eInRange > 0 then
							passedRCondition = true
						end
					end
				end
			end
			
			if not self.castThisTick and passedWCondition and passedWTarget ~= nil and not passedWTarget.dead and myHero:GetDistance(passedWTarget) < self.spellQ["range"] and self.menu.endlesssoraka.Heal then
				CastSpell(_W, passedWTarget)
				self.castThisTick = true
			end
		end
		
		if spellRC and not self.castThisTick and self.menu.endlesssoraka.Ult and myHpPerc < 10 then
			CastSpell(_W, passedWTarget)
			self.castThisTick = true
		end
	end
	
	function Soraka:OnTickSupport()
		
		if GetTickCount() % 6 ~= 5 then return end
		
		self.castThisTick = false
		
		self.friendlyTowers = 0
		for i = 1, self.friendlyTowers do
			tower = self.friendlyTowers[i]
			if tower and tower.team == myHero.team and GetDistance(tower) < self.spellE["range"] then
				self.friendlyTowers = self.friendlyTowers + 1
			end
		end
		
		spellQC = (myHero:CanUseSpell(_Q) == 0)
		spellWC = (myHero:CanUseSpell(_W) == 0)
		spellEC = (myHero:CanUseSpell(_E) == 0)
		spellRC = (myHero:CanUseSpell(_R) == 0)
		
		myHpPerc = (myHero.health / myHero.maxHealth) * 100
		myManaPerc = (myHero.mana / myHero.maxMana) * 100
		
		enemyPositions = {}
		setEnemyPos = false
		
		if (spellWC and (self.menu.endlesssoraka.Heal or self.menu.carry.UseW) and not self.menu.w.UseW and myHpPerc > self.menu.w.HP) and not self.castThisTick or spellRC and not self.castThisTick then
			passedWCondition = false
			passedWTarget = nil
			passedRCondition = false
			
			for i, target in pairs(GetAllyHeroes()) do
				if target and not target.dead then
					tHpPerc = (target.health / target.maxHealth) * 100
					if spellWC and tHpPerc < 85 and myHero:GetDistance(target) < self.spellW["range"] and self.menu.w["heal" .. target.charName] then
						passedWCondition = true
						if passedWTarget ~= nil then
							if passedWTarget.health > target.health then
								passedWTarget = target
							end
						else
							passedWTarget = target
						end
					end
					if spellRC and tHpPerc < 25 and self.menu.r["heal" .. target.charName] then
						eInRange = 0
						for i, eHero in pairs(GetEnemyHeroes()) do
							if eHero and not eHero.dead and target:GetDistance(eHero) < 400 then
								eInRange = eInRange + 1
							end
						end
						if eInRange > 0 then
							passedRCondition = true
						end
					end
				end
			end
			
			if not self.castThisTick and passedRCondition and spellRC then
				CastSpell(_R)
				self.castThisTick = true
			end
			
			if not self.castThisTick and passedWCondition and passedWTarget ~= nil and not passedWTarget.dead and myHero:GetDistance(passedWTarget) < self.spellQ["range"] then
				CastSpell(_W, passedWTarget)
				self.castThisTick = true
			end
			
			if not self.castThisTick and spellRC and myHpPerc < 40 then
				eInRange = 0
				for i, eHero in pairs(GetEnemyHeroes()) do
					if eHero and not eHero.dead and target:GetDistance(eHero) < eHero.range then
						eInRange = eInRange + 1
					end
				end
				
				if not self.castThisTick and spellRC and (myHpPerc < 10 and eInRange > 0 or eInRange > 1 and myHpPerc < 30) then
					CastSpell(_R)
					self.castThisTick = true
				end
			end
		end
		
		if spellQC and not self.castThisTick or spellEC and not self.castThisTick then
			for i, target in pairs(GetEnemyHeroes()) do
				if ValidTarget(target, self.spellQ["range"] + 250) and not target.dead then
					if spellQC and self.menu.q.HP > myHpPerc and not self.castThisTick and self.menu.q["q" .. target.charName] then
						local CastPosition, HitChance, Position = self.vp:GetCircularCastPosition(target, self.spellQ["delay"], self.spellQ["width"], self.spellQ["range"], self.spellQ["speed"], myHero, false)
						if CastPosition and HitChance >= 2 and GetDistance(CastPosition) < self.spellQ["range"] then
							CastSpell(_Q, CastPosition.x, CastPosition.z)
							self.castThisTick = true
						end
					end
				end
				if self.menu.e.InCombo and ValidTarget(target, self.spellE["range"] + 250) and not target.dead then
					if spellEC and not self.castThisTick and self.menu.e["e" .. target.charName] then
						local CastPosition, HitChance, Position = self.vp:GetCircularCastPosition(target, self.spellE["delay"], self.spellE["width"], self.spellE["range"], self.spellE["speed"], myHero, false)
						if CastPosition and HitChance >= 2 and GetDistance(CastPosition) < self.spellE["range"] then
							CastSpell(_E, CastPosition.x, CastPosition.z)
							self.castThisTick = true
						end
					end
				end
				
				if self.menu.e.UnderTower and not self.castThisTick then
					for i = 1, self.friendlyTowers do
						tower = self.friendlyTowers[i]
						if tower and tower.team == myHero.team and target:GetDistance(tower) < 300 then
							if ValidTarget(target, self.spellE["range"] + 250) and not target.dead then
								if spellEC and not self.castThisTick and self.menu.e["e" .. target.charName] then
									local CastPosition, HitChance, Position = self.vp:GetCircularCastPosition(target, self.spellE["delay"], self.spellE["width"], self.spellE["range"], self.spellE["speed"], myHero, false)
									if CastPosition and HitChance >= 2 and GetDistance(CastPosition) < self.spellE["range"] then
										CastSpell(_E, CastPosition.x, CastPosition.z)
									end
								end
							end
						end
					end
				end
			end
		end
		
		self.orbWalk:Walk()
		if self.menu.endlesssoraka.AA then
			for i, target in pairs(GetEnemyHeroes()) do
				if ValidTarget(target, self.orbWalk.AARange) then
					self.orbWalk:Attack(target)
					break
				end
			end
		end
		
	end

	function Soraka:OnTickFlee()
		self.castThisTick = false
		
		spellQC = (myHero:CanUseSpell(_Q) == 0)
		spellWC = (myHero:CanUseSpell(_W) == 0)
		spellEC = (myHero:CanUseSpell(_E) == 0)
		spellRC = (myHero:CanUseSpell(_R) == 0)
		
		myHpPerc = (myHero.health / myHero.maxHealth) * 100
		myManaPerc = (myHero.mana / myHero.maxMana) * 100
	
		self.orbWalk:Walk()
		
		for i, target in pairs(GetEnemyHeroes()) do
			if spellQC and self.menu.q.HP > myHpPerc and not self.castThisTick and self.menu.q["q" .. target.charName] and self.menu.flee.UseQ then
				local CastPosition, HitChance, Position = self.vp:GetCircularCastPosition(target, self.spellQ["delay"], self.spellQ["width"], self.spellQ["range"], self.spellQ["speed"], myHero, false)
				if CastPosition and HitChance >= 2 and GetDistance(CastPosition) < self.spellQ["range"] then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
					self.castThisTick = true
				end
			end
			if spellEC and not self.castThisTick and self.menu.e["e" .. target.charName] and self.menu.flee.UseE then
				local CastPosition, HitChance, Position = self.vp:GetCircularCastPosition(target, self.spellE["delay"], self.spellE["width"], self.spellE["range"], self.spellE["speed"], myHero, false)
				if CastPosition and HitChance >= 2 and GetDistance(CastPosition) < self.spellE["range"] then
					CastSpell(_E, CastPosition.x, CastPosition.z)
					self.castThisTick = true
				end
			end
		end
	end

	function Soraka:OnDraw()
	
		if self.menu.draw.AA then
			DrawCircle3D(myHero.pos.x, myHero.pos.y, myHero.pos.z, myHero.range + myHero.boundingRadius, 2, ARGB(80, 32,178,100))
		end
		if self.menu.draw.Q and (myHero:CanUseSpell(_Q) == 0) then
			DrawCircle3D(myHero.pos.x, myHero.pos.y, myHero.pos.z, self.spellQ["range"] + (self.spellQ["width"] / 2), 2, ARGB(80, 32,178,100))
		end
		if self.menu.draw.E and (myHero:CanUseSpell(_E) == 0) then
			DrawCircle3D(myHero.pos.x, myHero.pos.y, myHero.pos.z, self.spellE["range"] + (self.spellE["width"] / 2), 2, ARGB(80, 32,178,100))
		end
		if self.menu.draw.W and (myHero:CanUseSpell(_W) == 0) then
			DrawCircle3D(myHero.pos.x, myHero.pos.y, myHero.pos.z, self.spellW["range"], 2, ARGB(80, 32,178,100))
		end
		
	end

	function Soraka:SetupMenu()
		self.menu:addSubMenu("[Endless Soraka]", "endlesssoraka")
			self.menu.endlesssoraka:addParam("Heal", "Always Heal [W]", SCRIPT_PARAM_ONOFF, true)
			self.menu.endlesssoraka:addParam("Ult", "Always Ult [R]", SCRIPT_PARAM_ONOFF, true)
			self.menu.endlesssoraka:addParam("Silance", "Always Silance [E]", SCRIPT_PARAM_ONOFF, true)
			self.menu.endlesssoraka:addParam("AA", "Auto Attack", SCRIPT_PARAM_ONOFF, true)
			self.menu.endlesssoraka:addParam("Humanizer", "Enable Humanizer", SCRIPT_PARAM_ONOFF, true)
			self.menu.endlesssoraka:addParam("DoubleHumanizer", "Enable Strict Humanizer", SCRIPT_PARAM_ONOFF, false)
			self.menu.endlesssoraka:addParam("info","", SCRIPT_PARAM_INFO, "")
		self.menu:addSubMenu("[Auto Carry]", "carry")
			self.menu.carry:addParam("UseQ", "Use Q Ability", SCRIPT_PARAM_ONOFF, true)
			self.menu.carry:addParam("UseW", "Use W Ability", SCRIPT_PARAM_ONOFF, true)
			self.menu.carry:addParam("UseE", "Use E Ability", SCRIPT_PARAM_ONOFF, true)
			self.menu.carry:addParam("UseR", "Use R Ability", SCRIPT_PARAM_ONOFF, true)
			self.menu.carry:addParam("ConserveManaLowLevel", "Conserve Mana - Low Level", SCRIPT_PARAM_ONOFF, true)
			self.menu.carry:addParam("ConserveManaAll", "Conserve Mana - All Levels", SCRIPT_PARAM_ONOFF, false)
		self.menu:addSubMenu("[Flee Mode]", "flee")
			self.menu.flee:addParam("UseQ", "Use Q Ability", SCRIPT_PARAM_ONOFF, false)
			self.menu.flee:addParam("UseE", "Use E Ability", SCRIPT_PARAM_ONOFF, true)
			self.menu.flee:addParam("UseR", "Use R Ability", SCRIPT_PARAM_ONOFF, false)
		self.menu:addSubMenu("[Starcall]", "q")
			self.menu.q:addParam("UseQ", "Globally Disable Q Ability", SCRIPT_PARAM_ONOFF, false)
			self.menu.q:addParam("HP", "Use Q Below % HP", SCRIPT_PARAM_SLICE, 95, 1, 100, 95)
			self.menu.q:addParam("Mana", "Use Q Above Mana %", SCRIPT_PARAM_SLICE, 5, 1, 100, 5)
			self.menu.q:addParam("info","-------------------------", SCRIPT_PARAM_INFO, "")
			self.menu.q:addParam("info", "Q Targets", SCRIPT_PARAM_INFO, "")
			for _, option in ipairs(GetEnemyHeroes()) do 
				self.menu.q:addParam("q" .. option.charName, "" .. option.charName, SCRIPT_PARAM_ONOFF, true)
			end
		self.menu:addSubMenu("[Astral Infusion]", "w")
			self.menu.w:addParam("UseW", "Globally Disable W Ability", SCRIPT_PARAM_ONOFF, false)
			self.menu.w:addParam("HP", "Use W Above % HP", SCRIPT_PARAM_SLICE, 5, 1, 100, 95)
			self.menu.w:addParam("HPAlly", "On Ally Below %", SCRIPT_PARAM_SLICE, 5, 1, 100, 95)
			self.menu.w:addParam("Mana", "Use W Above Mana %", SCRIPT_PARAM_SLICE, 5, 1, 100, 5)
			self.menu.w:addParam("info","-------------------------", SCRIPT_PARAM_INFO, "")
			self.menu.w:addParam("Minions", "Use W On Friendly Minions", SCRIPT_PARAM_ONOFF, true)
			self.menu.w:addParam("MinionsMana", "Use W Above Mana %", SCRIPT_PARAM_SLICE, 5, 1, 100, 5)
			self.menu.w:addParam("MinionsHP", "Use W Above HP %", SCRIPT_PARAM_SLICE, 90, 1, 100, 5)
			self.menu.w:addParam("info","-------------------------", SCRIPT_PARAM_INFO, "")
			self.menu.w:addParam("info", "Heal Targets", SCRIPT_PARAM_INFO, "")
			for _, option in ipairs(GetAllyHeroes()) do 
				self.menu.w:addParam("heal" .. option.charName, "" .. option.charName, SCRIPT_PARAM_ONOFF, true)
			end
		self.menu:addSubMenu("[Equinox]", "e")
			self.menu.e:addParam("UseE", "Globally Disable E Ability", SCRIPT_PARAM_ONOFF, false)
			self.menu.e:addParam("Mana", "Use E Above Mana %", SCRIPT_PARAM_SLICE, 5, 1, 100, 5)
			self.menu.e:addParam("UnderTower", "E Under Tower", SCRIPT_PARAM_ONOFF, true)
			self.menu.e:addParam("InCombo", "E In Combo", SCRIPT_PARAM_ONOFF, false)
			self.menu.e:addParam("UnderInterrupt", "E Interupt", SCRIPT_PARAM_ONOFF, true)
			self.menu.e:addParam("info","-------------------------", SCRIPT_PARAM_INFO, "")
			self.menu.e:addParam("info", "E Targets", SCRIPT_PARAM_INFO, "")
			for _, option in ipairs(GetEnemyHeroes()) do
				self.menu.e:addParam("e" .. option.charName, "" .. option.charName, SCRIPT_PARAM_ONOFF, true)
			end
			self.menu.e:addParam("info","-------------------------", SCRIPT_PARAM_INFO, "")
			self.menu.e:addParam("info", "E Interupt", SCRIPT_PARAM_INFO, "")
			for _, option in ipairs(GetEnemyHeroes()) do
				if self.Interrupt[option.charName] ~= nil then
					self.menu.e:addParam("e" .. self.Interrupt[option.charName]["stop"]["spellName"], "Interrupt " .. self.Interrupt[option.charName]["stop"]["name"], SCRIPT_PARAM_ONOFF, true)
				end
			end
		self.menu:addSubMenu("[Wish]", "r")
			self.menu.r:addParam("UseR", "Globally Disable R Ability", SCRIPT_PARAM_ONOFF, false)
			self.menu.r:addParam("Mana", "Use R Above Mana %", SCRIPT_PARAM_SLICE, 5, 1, 100, 5)
			self.menu.r:addParam("HP", "Use R When Ally (or self) Below %", SCRIPT_PARAM_SLICE, 20, 1, 100, 5)
			self.menu.r:addParam("info","-------------------------", SCRIPT_PARAM_INFO, "")
			self.menu.r:addParam("info", "Heal Targets", SCRIPT_PARAM_INFO, "")
			for _, option in ipairs(GetAllyHeroes()) do 
				self.menu.r:addParam("heal" .. option.charName, "" .. option.charName, SCRIPT_PARAM_ONOFF, true)
			end
		self.menu:addSubMenu("[Keybinds]", "keys")
			self.menu.keys:addParam("Carry", "Auto Carry", SCRIPT_PARAM_ONKEYDOWN, false, GetKey(" "))
				self.menu.keys:permaShow("Carry")
			self.menu.keys:addParam("Flee", "Flee Helper", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("X"))
				self.menu.keys:permaShow("Flee")
			self.menu.keys:addParam("info","", SCRIPT_PARAM_INFO, "")
			self.menu.keys:addParam("showWards", "Ward Helper", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("0"))
				self.menu.keys:permaShow("showWards")
			
		self.menu:addSubMenu("[Drawing]", "draw")
			self.menu.draw:addParam("AA", "Auto Attack Range", SCRIPT_PARAM_ONOFF, true)
			self.menu.draw:addParam("Q", "Q Range", SCRIPT_PARAM_ONOFF, true)
			self.menu.draw:addParam("W", "W Range", SCRIPT_PARAM_ONOFF, true)
			self.menu.draw:addParam("E", "E Range", SCRIPT_PARAM_ONOFF, true)
	end
	
	function Soraka:CanAct()
		if self.menu.endlesssoraka.Humanizer then
			if self.menu.endlesssoraka.DoubleHumanizer then
				if os.clock() >= (self.lastAction + 0.1 + math.random(0.25,0.4)) then
					return true
				else
					return false
				end
			else
				if os.clock() >= (self.lastAction + 0.25 + math.random(0,0.2)) then
					return true
				else
					return false
				end
			end
		else
			return true
		end
	end
	
class("OrbWalk")
	function OrbWalk:__init()
		self.lastAA = os.clock()
		self.lastAction = os.clock()
		self.AARange = myHero.range + myHero.boundingRadius
		self.BaseAnimationTime = 0.65
		self.BaseWindUpTime = 3
		
		self.menu = scriptConfig("[Endless OrbWalk]", "EndlessOrbWalk")
		self.menu:addParam("Walk", "Allow Walking", SCRIPT_PARAM_ONOFF, true)
		self.menu:addParam("Attack", "Allow Attacking", SCRIPT_PARAM_ONOFF, true)
		self.menu:addParam("Humanizer", "Enable Humanizer", SCRIPT_PARAM_ONOFF, true)
	end
	
	function OrbWalk:Walk()
		if self:CanMove() and self.menu.Walk and self:CanAct() then
			if GetDistance(mousePos, myHero.pos) < 2500 then
				myHero:MoveTo(mousePos.x, mousePos.z)
				self.lastAction = os.clock()
			else
				local MouseMove = Vector(myHero.x, myHero.y, myHero.z) + (Vector(mousePos.x, mousePos.y, mousePos.z) - Vector(myHero.x, myHero.y, myHero.z)):normalized() * 500
				myHero:MoveTo(MouseMove.x, MouseMove.z)
				self.lastAction = os.clock()
			end
		end
	end
	
	function OrbWalk:Attack(target)
		if ValidTarget(target, self.AARange) and self:CanAttack() and self.menu.Attack and self:CanAct() then
			myHero:Attack(target)
			self.lastAction = os.clock()
		end
	end
	
	function OrbWalk:OnProcessSpell(unit, spell)
		if spell.name:lower():find("attack") then
			if unit.isMe then
				self.BaseAnimationTime = 1 / (spell.animationTime * myHero.attackSpeed)
				self.BaseWindUpTime = 1 / (spell.windUpTime * myHero.attackSpeed)
			end
		end
	end
	
	function OrbWalk:OnAnimation(unit, action)
		if unit.isMe then 
			if action:lower():find("attack") or action:lower():find("crit") then
				self.lastAA = os.clock()
			end
		end
	end
	
	function OrbWalk:CanMove()
		if os.clock() > ((self.lastAA or 0) + (1 / (myHero.attackSpeed * self.BaseWindUpTime))) then
			return true
		else
			return false
		end
	end
	
	function OrbWalk:CanAttack()
		if os.clock() > ((self.lastAA or 0) + (1 / (myHero.attackSpeed * self.BaseAnimationTime)) - (GetLatency()/1000)) then
			return true
		else
			return false
		end
	end
	
	function OrbWalk:CanAct()
		if self.menu.Humanizer then
			if os.clock() >= (self.lastAction + 0.25 + math.random(0,0.2)) then
				return true
			else
				return false
			end
		else
			return true
		end
	end

class("HealEngine")
	function HealEngine:__init()
		self.lastCache = 0
		self.lastTarget = nil
		self.currentTarget = nil
		
		self.tankMod = 0
		self.dmgMod = 1.5
		self.suppMod = 1
		
		self.enemyInRangeDistance = 600
		self.enemyInRangeOne = 0.5
		self.enemyInRangeTwo = 1
		self.enemyInRangeThree = 1.5
		self.enemyInRangeFour = 2
		self.enemyInRangeFive = 2.5
		
		self.under70hp = 0.5
		self.under60hp = 1
		self.under50hp = 2
		self.under40hp = 3
		self.under30hp = 4
		self.under20hp = 5
		self.under10hp = 6
		
		self.loaded = true
	end
	
	function HealEngine:CacheAlly()
		if not self.loaded then return end
		--create a cache
	end
	
	function HealEngine:FindHealTargetsUnder(range, hp)
		
	end
	
	function HealEngine:FindHealTarget(range)
		
	end
	
class("Base")
	function Base:__init(utility, drawing)
		self.util = utility
		self.draw = drawing
		self.menu = scriptConfig("[Endless Support]", "EndlessSupport")
		self:SkinChangerOnLoad()
		self:MagWardMenu()
	end
	
	function Base:SkinChangerOnLoad()
		canChange = true
		if myHero.charName == "Soraka" then
			self.menu:addParam("info","------------------", SCRIPT_PARAM_INFO, "")
			self.menu:addParam('changeSkin', 'Change Soraka Skin', SCRIPT_PARAM_ONOFF, false)
			self.menu:addParam('skinID', 'Skin Skin ID', SCRIPT_PARAM_SLICE, 1, 1, 5, 0)
		else
			self.menu:addParam("info","------------------", SCRIPT_PARAM_INFO, "")
			self.menu:addParam('changeSkin', 'Change Skin', SCRIPT_PARAM_ONOFF, false)
			self.menu:addParam('skinID', 'Skin ID', SCRIPT_PARAM_SLICE, 1, 1, 12, 0)
		end
		self.menu:setCallback('changeSkin', function(nV)
			if (nV) then
				SetSkin(myHero, self.menu.skinID)
			else
				SetSkin(myHero, -1)
			end
		end)
		self.menu:setCallback('skinID', function(nV)
			if (self.menu.changeSkin) then
				SetSkin(myHero, nV)
			end
		end)
		if (self.menu.changeSkin) then
			SetSkin(myHero, self.menu.skinID)
		end
	end
	
	function Base:SkinChangerOnUnload()
		if (self.menu.changeSkin) then
			SetSkin(myHero, -1)
		end;
	end
	
	function Base:AutoLevelMenu()
		self.menu:addSubMenu("[Auto Level]", "autoLevel")
		self.menu.wards:addParam("enable", "Enable Auto Level", 1, true)
	end
	
	function Base:AutoLevel()
		
	end
	
	function Base:StreamingMode()
		_G.print = function() end
		_G.PrintChat = function() end
		DisableOverlay()
	end
	
	function Base:MagWardMenu()
		self.menu:addSubMenu("[Magnetic Wards]", "wards")
		self.menu.wards:addParam("draw", "Draw Ward Spots", 1, true)
		self.menu.wards:addParam("enable", "Enable Magnetic Wards", 1, true)
		
		self.wardPos = { 
			{7777,800, 180}, 
			{10386,3041,240}, 
			{7088,3093,240}, 
			{6565,4700,240},
			{12222.328125,1278.7239990234 ,240}, 
			{13197.298828125,2198.5405273438 ,240}, 
			{8599.201171875,4715.81640625 ,240}, 
			{9442.0107421875,5624.416015625 ,240}, 
			{9928.279296875,6522.7236328125 ,240}, 
			{12508.688476563,5201.0532226563 ,240}, 
			{11537.41015625,7124.78515625 ,240},
			{11865.547851563,3901.45703125 ,240}, 
			{12222.715820313,8163.48046875 ,240}, 
			{9973.1962890625,7889.0434570313 ,240}, 
			{5557.1391601563,3511.5476074219 ,240}, 
			{3362.5991210938,7756.443359375 ,240}, 
			{4686.5844726563,10054.62109375 ,240}, 
			{5249.2065429688,9094.015625 ,240}, 
			{4929.78515625,8361.3193359375 ,240},
			{8291.970703125,10240.630859375 ,240},
			{9148.853515625,11434.6015625 ,240},
			{7795.7133789063,11756.650390625 ,240},
			{6248.728515625,10277.24609375 ,240},
			{10180.481445313,4825.6669921875 ,240},
			{9203.9873046875,2125.4926757813 ,240},
			{14109.025390625,6993.201171875 ,240},
			{5670.9155273438,12681.665039063 ,240},
			{7169.763671875,14101.22265625 ,240},
			{819.56982421875,8101.2841796875 ,240},
			{2307.5925292969,9709.6630859375 ,240},
			{4475,11820 ,240},
			{6921,11445 ,240}
		}
	end
	
	function Base:MagWardOnTick()
		if self.menu.wards.enable then
			for _, spots in pairs(self.wardPos) do
				if self.util:mPos3D(mousePos.x, mousePos.z, spots[1], spots[2], spots[3]) then
					AddCastSpellCallback(function(iSlot,startPos,endPos,target)
						if myHero.GetSpellData(myHero, iSlot).name == "TrinketTotemLvl1" or myHero.GetSpellData(myHero, iSlot).name == "VisionWard" or myHero.GetSpellData(myHero, iSlot).name == "TrinketOrbLvl3" or myHero.GetSpellData(myHero, iSlot).name == "ItemGhostWard" then
							endPos.x, endPos.z = spots[1], spots[2]
						end
					end)
				end
			end
		end
	end
	
	function Base:MagWardOnDraw()
		if self.menu.wards.draw then
			for _, spots in pairs(self.wardPos) do
				if self.util:mPos3D(mousePos.x, mousePos.z, spots[1], spots[2], spots[3]) then
					self.draw:DrawCircle2(spots[1], 48, spots[2], spots[3], ARGB(255,0,255,0))
					self.draw:DrawCircle2(spots[1], 48, spots[2], 10, ARGB(255,0,255,0))
				else
					self.draw:DrawCircle2(spots[1], 48, spots[2], spots[3], ARGB(255,255,255,255))
					self.draw:DrawCircle2(spots[1], 48, spots[2], 10, ARGB(255,255,255,255))
				end
			end
		end
	end
	
class("ItemUsage")
	function ItemUsage:__init()
		self.lastPotion = 0
		self.lastDefensive = 0
		
		self.heal = nil
		self.exhaust = nil
		
		self.menu = scriptConfig("[Endless Item Usage]", "EndlessItems")
		self.menu:addParam('UseItems', 'Enable Item Usage', SCRIPT_PARAM_ONOFF, true)
		self.menu:addParam("info","------------------", SCRIPT_PARAM_INFO, "")
		self.menu:addParam('UsePotions', 'Enable Potion Usage', SCRIPT_PARAM_ONOFF, true)
		self.menu:addParam('UsePotionCystal', 'Crystal Flask', SCRIPT_PARAM_ONOFF, true)
		self.menu:addParam('UsePotionRegen', 'Regenerate Potion', SCRIPT_PARAM_ONOFF, true)
		self.menu:addParam('UsePotionMiniRegen', 'Mini Regenerate Potion', SCRIPT_PARAM_ONOFF, true)
		self.menu:addParam("info","------------------", SCRIPT_PARAM_INFO, "")
		
		self.menua = scriptConfig("[Endless Summoner Usage]", "EndlessSummoner")
		self.menua:addParam('UseSummoners', 'Enable Summoner Usage', SCRIPT_PARAM_ONOFF, true)
		self.menua:addParam("info","------------------", SCRIPT_PARAM_INFO, "")
		
		--self.menua:addParam('UseExhaust', 'Enable Exhaust Usage', SCRIPT_PARAM_ONOFF, true)
		
		if myHero:GetSpellData(SUMMONER_1).name:find("summonerheal") then
			self.heal = SUMMONER_1
			self.menua:addParam('UseHeal', 'Enable Heal Usage', SCRIPT_PARAM_ONOFF, true)
		elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerheal") then
			self.heal = SUMMONER_2
			self.menua:addParam('UseHeal', 'Enable Heal Usage', SCRIPT_PARAM_ONOFF, true)
		end
	end
	
	function ItemUsage:OnTick()
		--run through engage
		--run through disengage
		--run through sheilding
		if self.menu.UseItems then
		
			myHpPerc = (myHero.health / myHero.maxHealth) * 100
			myManaPerc = (myHero.mana / myHero.maxMana) * 100
			nearMe = self:CountEnemiesNearUnitReg(myHero, 1000)
			
			--Potion usage
			if ((os.clock() - self.lastPotion >= 8 or self.lastPotion == 0) and myHpPerc < 25 and nearMe > 0) or ((os.clock() - self.lastPotion >= 15 or self.lastPotion == 0) and myManaPerc < 10) then
				local potionslot = nil
				if self.menu.UsePotionCystal then
					potionslot = self:GetSlotItemFromName("crystalflask")
				end
				if not potionslot and self.menu.UsePotionRegen then
					potionslot = self:GetSlotItemFromName("RegenerationPotion")
				end
				if not potionslot and self.menu.UsePotionMiniRegen then
					potionslot = self:GetSlotItemFromName("itemminiregenpotion")
				end
				if potionslot and myHero:CanUseSpell(potionslot) then
					CastSpell(potionslot)
					self.lastPotion = os.clock()
				end
			end
			
			--Elixer usage
			
		end
	end
	
	function ItemUsage:SummonerTick()
		if self.menua.UseSummoners then
			
			myHpPerc = (myHero.health / myHero.maxHealth) * 100
			myManaPerc = (myHero.mana / myHero.maxMana) * 100
			nearMe = self:CountEnemiesNearUnitReg(myHero, 1000)
			
			if self.heal and myHero:CanUseSpell(self.heal) and myHpPerc < 20 and nearMe > 0 then
				CastSpell(self.heal, myHero)
			end
			
		end
	end
	
	function ItemUsage:GetSlotItemFromName(itemname)
		local slot
		for i = 6, 12 do
			local item = myHero:GetSpellData(i).name
			if item and item:lower():find(itemname:lower()) and myHero:CanUseSpell(i) == READY then
				slot = i
			end
		end
		return slot
	end
	
	function ItemUsage:GetSlotItem(id, unit)
		unit = unit or myHero

		local name	= ItemNames[id]
		
		for slot = ITEM_1, ITEM_7 do
			local item = unit:GetSpellData(slot).name
			if item and item:lower() == name:lower() and myHero:CanUseSpell(slot) == READY then
				return slot
			end
		end
	end
	
	function ItemUsage:CountEnemiesNearUnitReg(unit, range)
		local count = 0
		for i, enemy in pairs(GetEnemyHeroes()) do
			if not enemy.dead and enemy.visible then
				if  GetDistanceSqr(unit, enemy) < range * range  then 
					count = count + 1 
				end
			end
		end
		return count
	end
	
class("Drawing")
	function Drawing:__init()
		_G.oldDrawCircle = rawget(_G, 'DrawCircle')
		_G.DrawCircle = DrawCircle2
	end
	
	function Drawing:DrawCircle2(x, y, z, radius, color)
		local vPos1 = Vector(x, y, z)
		local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
		local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
		local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
		if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
			self:DrawCircleNextLvl(x, y, z, radius, 1, color, 150) 
		end
	end
	
	function Drawing:DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
		radius = radius or 300
		quality = math.max(8,self:Round(180/math.deg((math.asin((chordlength/(2*radius)))))))
		quality = 2 * math.pi / quality
		radius = radius*.92
		local points = {}
		for theta = 0, 2 * math.pi + quality, quality do
			local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
			points[#points + 1] = D3DXVECTOR2(c.x, c.y)
		end
		DrawLines2(points, width or 1, color or 4294967295)
	end
	
	function Drawing:Round(num) 
		if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
	end
	
class("Utilitys")
	function Utilitys:__init()
		self.loaded = true
		self.noSpam = nil
		self.debug = true
		self.orbWalk = "custom"
	end
	
	function Utilitys:post(msg, f)
		if self.noSpam ~= msg and msg ~= nil then
			sourceClass = nil
			if f == 0 then
				sourceClass = "Endless Core"
			elseif f == 1 then
				sourceClass = "Endless Bundle"
			elseif f == 2 then
				sourceClass = "Endless Engine"
			elseif f == 3 then
				sourceClass = "Endless Updater"
			elseif f == 10 then
				sourceClass = "Endless Soraka"
			elseif f == 99 then
				sourceClass = "DEBUG"
			end
			if (f == 99 and self.debug == true) or (f ~= 99 and sourceClass ~= nil) then 
				print("[" .. sourceClass .. "] " .. msg)
			end
		end
	end
	
	function Utilitys:mPos3D(cx,cz,x,z,r)
		if (math.pow(cx-x,2)+math.pow(cz-z,2)<math.pow(r,2)) then
			return true
		else
			return false
		end
	end
	
	function Utilitys:IsOtherOrbWalkerLoaded() --Credit to S1mple
		DelayAction(function ()
			if _G.Reborn_Loaded or _G.AutoCarry then
				self.orbWalk = "SAC:R"
			elseif _G.MMA_Loaded or _G.MMA_Version then
				self.orbWalk = "MMA"
			elseif _G.NebelwolfisOrbWalkerInit or _G.NebelwolfisOrbWalkerLoaded then
				self.orbWalk = "NOW"
			elseif _Pewalk then
				self.orbWalk = "PEW"
			elseif _G.SxOrb or SxOrb then
				self.orbWalk = "SxOrb"
			elseif _G.S1OrbLoaded then
				self.orbWalk = "S1mpleOrbWalk"
			else
				self.orbWalk = "custom"
			end
		end,0.5)
	end

class("AutoUpdate")
	function AutoUpdate:__init(utility)
		self.loaded = false
		self.autoUpdate = false
		self.localVer = 1001
		self.utils = utility
	end

	function AutoUpdate:FindUpdates()
		if not self.autoUpdate then return end
		
	end

local myInstanceChar, myInstanceHeal, myInstanceBase, myUtilInstance, myDrawInstance, myOrbWalk, myItemUsage, myAutoUpdater = nil, nil, nil, nil, nil, nil, nil, nil
local hasLoadedChar = false

local scriptVersion = 1001
local autoUpdate = true

function OnLoad()
	myUtilInstance = Utilitys()
	myAutoUpdater = AutoUpdate(myUtilInstance)
	myUtilInstance:IsOtherOrbWalkerLoaded()
	myDrawInstance = Drawing()
	myInstanceBase = Base(myUtilInstance, myDrawInstance)
	if not myUtilInstance or myUtilInstance.orbWalk == nil or myUtilInstance.orbWalk == "custom" then
		myOrbWalk = OrbWalk()
	end
	myItemUsage = ItemUsage()
	
	if myHero.charName == "Soraka" then
		myInstanceChar = Soraka(myUtilInstance, myInstanceBase, myOrbWalk)
		hasLoadedChar = true
		myUtilInstance:post("Soraka - The Endless Healer Loaded.", 1)
	end
	
	if hasLoadedChar and myInstanceChar ~= nil then
		myInstanceHeal = HealEngine()
		if myInstanceHeal ~= nil and myInstanceHeal.loaded then
			myInstanceChar:SetHealEngine(myInstanceHeal)
			myUtilInstance:post("Loaded.", 2)
		else
			myUtilInstance:post("Failed to load.", 2)
		end
		--myInstanceChar:SetBase(myInstanceBase)
	end
	
	myUtilInstance:post("Endless Suport Bundle by AZer0", 0)
	myUtilInstance:post("Please make sure to disable all other Orb Walkers.", 0)
end

function OnUnLoad()
	if myInstanceBase ~= nil then
		myInstanceBase:SkinChangerOnUnload()
	end
end

function OnTick()
	myItemUsage:OnTick()
	myItemUsage:SummonerTick()
end