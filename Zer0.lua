--[[
v6
-Added FH Pred and HPred
-Added *some* dash checks checks
-Added new irelia harass
-Misc other changes
]]--

_G.zeroConfig = {
	UseUpdater = true,
	AutoDownload = true,
	Version = 7
}

local UpdateHost = "raw.github.com"
local UpdatePath = "/azer0/0BoL/master/Version/Zer0.Version?rand=" .. math.random(1, 10000)
local UpdatePath2 = "/azer0/0BoL/master/Zer0.lua?rand=" .. math.random(1, 10000)
local UpdateFile = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local VersionURL = "http://"..UpdateHost..UpdatePath
local UpdateURL = "http://"..UpdateHost..UpdatePath2

function AutoUpdaterPrint(msg)
	print("<font color=\"#FF794C\"><b>Zer0 Bundle</b></font> <font color=\"#FFDFBF\"><b>"..msg.."</b></font>")
end

local hasBeenUpdated = false

if _G.zeroConfig.UseUpdater then
	local sData = GetWebResult(UpdateHost, UpdatePath)
	if sData then
		local sVer = type(tonumber(sData)) == "number" and tonumber(sData) or nil
		if sVer and sVer > _G.zeroConfig.Version then
			AutoUpdaterPrint("New update found [v" .. sVer .. "].")
			AutoUpdaterPrint("Please do not reload until complete.")
			DownloadFile(UpdateURL, UpdateFile, function () AutoUpdaterPrint("Successfully updated. (".._G.zeroConfig.Version.." => "..sVer.."), press F9 twice to use the updated version.") end)
			hasBeenUpdated = true
		else
			AutoUpdaterPrint("No update needed, your using the latest version.")
		end
	end
end

if hasBeenUpdated then
	return
end

local supportedChamps = {
	["Irelia"] = true,
	["Taliyah"] = true,
	["Ryze"] = true,
	["Heimerdinger"] = false,
	["Lux"] = false
}

if not supportedChamps[myHero.charName] then
	print("<font color=\"#FF794C\"><b>Zer0 Bundle</b></font> <font color=\"#FFDFBF\"><b>Champion [".. myHero.charName .."] not currently supported.</b></font>")
	return
else
	print("<font color=\"#FF794C\"><b>Zer0 Bundle</b></font> <font color=\"#FFDFBF\"><b>Thank you for using AZer0 Scripts.</b></font>")
	print("<font color=\"#FF794C\"><b>Zer0 Bundle</b></font> <font color=\"#FFDFBF\"><b>Visit our website at: http://40.76.208.14/</b></font>")
end

_G.azBundle = {
	ChampionData = nil,
	Champion = nil,
	PrintManager = nil,
	MenuManager = nil,
	Orbwalk = nil,
	EvadeManager = nil,
	AwareManager = nil,
	MiscManager = nil,
	ItemDmgManager = nil,
	PredManager = nil
}
--[[-----------------------------------------------------
-----------------------CHAMP DATA------------------------
-----------------------------------------------------]]--
class("ChampionData")
function ChampionData:__init()
	self.SkillQ = {}
	self.SkillW = {}
	self.SkillE = {}
	self.SkillR = {}
	self.fhQ = nil
	self.fhW = nil
	self.fhE = nil
	self.fhR = nil
	
	self.charName = nil
	self.scriptName = nil
	
	if myHero.charName == "Irelia" then
		self.SkillQ = {
			range = 650,
			delay = 0.25,
			type = "target",
			colMinion = false,
			colChamp = false,
			Damage = function(source, target)
				if not source then
					source = myHero
				end
				spellLevel = myHero:GetSpellData(_Q).level
				levelDamage = {60,80,100,120,140}
				myApScale = myHero.ap * 0.4
				damage = levelDamage[spellLevel] + myApScale
				return damage
			end
		}
		self.SkillW = {
			type = "target",
			colMinion = false,
			colChamp = false,
			Damage = function(source, target)
				spellLevel = source:GetSpellData(_W).level
				levelDamage = {60,80,100,120,140}
				myApScale = source.ap * 0.4
				damage = levelDamage[spellLevel] + myApScale
				return damage
			end
		}
		self.SkillE = {
			range = 425,
			delay = 0.25,
			type = "target",
			colMinion = false,
			colChamp = false,
			Damage = function(source, target)
				spellLevel = source:GetSpellData(_E).level
				levelDamage = {40,52.5,65,77.5,90}
				myApScale = source.ap * 0.2
				damage = levelDamage[spellLevel] + myApScale
				return damage
			end
		}
		self.SkillR = {
			range = 1200,
			delay = 80,
			speed = 1600,
			width = 25,
			type = "line",
			aoe = false,
			colMinion = false,
			colChamp = false,
			Damage = function(source, target) return (source:GetSpellData(_R).level * 40 + 40 + source.ap * 0.5 + source.addDamage * 0.6) * 3 end
		}
		
		self.charName = "Irelia"
		self.scriptName = "Night Blade"
		
	elseif myHero.charName == "Taliyah" then
		self.SkillQ = {
			range = 910,
			delay = 0.2,
			width = 130,
			speed = 1200,
			type = "line",
			aoe = false,
			colMinion = true,
			colChamp = true,
			Damage = function(source, target)
				spellLevel = source:GetSpellData(_Q).level
				levelDamage = {60,80,100,120,140}
				myApScale = source.ap * 0.4
				damage = levelDamage[spellLevel] + myApScale
				return damage
			end
		}
		self.SkillW = {
			range = 900,
			delay = 0.5,
			width = 150,
			speed = 1500,
			type = "circle",
			aoe = true,
			colMinion = false,
			colChamp = false,
			Damage = function(source, target)
				spellLevel = source:GetSpellData(_W).level
				levelDamage = {60,80,100,120,140}
				myApScale = source.ap * 0.4
				damage = levelDamage[spellLevel] + myApScale
				return damage
			end
		}
		self.SkillE = {
			range = 570,
			delay = math.huge,
			width = 330,
			speed = 800,
			type = "circle",
			aoe = true,
			colMinion = false,
			colChamp = false,
			Damage = function(source, target)
				spellLevel = source:GetSpellData(_E).level
				levelDamage = {40,52.5,65,77.5,90}
				myApScale = source.ap * 0.2
				damage = levelDamage[spellLevel] + myApScale
				return damage
			end
		}
		self.SkillR = {
			range = 2000,
			Damage = function(source, target) return (source:GetSpellData(_R).level * 40 + 40 + source.ap * 0.5 + source.addDamage * 0.6) * 3 end
		}
		
		self.fhW = {
			range = 615,
			speed = 1500,
			radius = 75,
			delay = 0.5,
			collision = false,
			aoe = true,
			type = SkillshotCircle
		}	
		self.fhE = {
			range = 570,
			speed = 800,
			radius = 165,
			delay = 0.8,
			collision = false,
			aoe = true,
			type = SkillshotCircle
		}
		
		self.charName = "Taliyah"
		self.scriptName = "Rock Candy"
		
	elseif myHero.charName == "Ryze" then
		self.SkillQ = {
			range = 1000,
			delay = 0.25,
			width = 55,
			speed = 1700,
			type = "line",
			aoe = false,
			colMinion = true,
			colChamp = true,
			Damage = function(source, target)
				spellLevel = source:GetSpellData(_Q).level
				return source:CalcMagicDamage(target, 60 + 25 * (spellLevel-1) + source.ap * 0.45 + source.maxMana * 0.03)
			end
		}
		self.SkillW = {
			range = 615,
			delay = 0.25,
			type = "target",
			aoe = false,
			colMinion = false,
			colChamp = false,
			Damage = function(source, target)
				spellLevel = source:GetSpellData(_W).level
				return source:CalcMagicDamage(target, 80 + 20 * (spellLevel-1) + source.ap * 0.2 + source.maxMana * 0.01)
			end
		}
		self.SkillE = {
			range = 615,
			delay = 0.25,
			type = "target",
			aoe = false,
			colMinion = false,
			colChamp = false,
			Damage = function(source, target)
				spellLevel = source:GetSpellData(_W).level
				return source:CalcMagicDamage(target, 50 + 25 * (spellLevel-1) + source.ap * 0.3 + source.maxMana * 0.02)
			end
		}
		self.SkillR = {
			range = function(source)
				if source and source:GetSpellData(_E).level == 1 then
					return 1500
				elseif source and source:GetSpellData(_E).level == 2 then
					return 3000
				else
					return 0
				end end,
			Damage = function(source, target) return 0 end
		}
		self.charName = "Ryze"
		self.scriptName = "Overload"
		
	elseif myHero.charName == "Heimerdinger" then
		self.SkillQ = {
			range = 300,
			type = "target",
			aoe = false,
			colMinion = false,
			colChamp = false,
			Damage = function(source, target)
				spellLevel = source:GetSpellData(_Q).level
				return source:CalcMagicDamage(target, 60 + 25 * (spellLevel-1) + source.ap * 0.45 + source.maxMana * 0.03)
			end
		}
		self.SkillW = {
			range = 1100,
			width = 20,
			speed = 3000,
			delay = 0.5,
			type = "line",
			aoe = false,
			colMinion = true,
			colChamp = true,
			Damage = function(source, target)
				spellLevel = source:GetSpellData(_W).level
				return source:CalcMagicDamage(target, 80 + 20 * (spellLevel-1) + source.ap * 0.2 + source.maxMana * 0.01)
			end
		}
		self.SkillE = {
			range = 925,
			width = 135,
			speed = 1200,
			delay = 0.25,
			type = "circle",
			aoe = true,
			colMinion = false,
			colChamp = false,
			Damage = function(source, target)
				spellLevel = source:GetSpellData(_W).level
				return source:CalcMagicDamage(target, 50 + 25 * (spellLevel-1) + source.ap * 0.3 + source.maxMana * 0.02)
			end
		}
		self.SkillE2 = {
			range = 925 + 500,
			width = 250,
			speed = 1200,
			delay = 0.25,
			type = "circle",
			aoe = true,
			colMinion = false,
			colChamp = false,
			Damage = function(source, target)
				spellLevel = source:GetSpellData(_W).level
				return source:CalcMagicDamage(target, 50 + 25 * (spellLevel-1) + source.ap * 0.3 + source.maxMana * 0.02)
			end
		}
		self.SkillR = {
			range = 0,
			Damage = function(source, target) return 0 end
		}
		
		self.charName = "Heimerdinger"
		self.scriptName = "The Gates"
	end
	
	self.InteruptSpellList = {
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
	
	self.DashSpellList = {
		"AatroxQ", -- Aatrox Q
		"AhriTumble", -- Ahri R
		"AkaliShadowDance", -- Akali R
		"Arcane Shift", -- Ezreal E
		"BandageToss", -- Amumu Q
		"blindmonkqtwo", -- Lee Sin Q
		"CarpetBomb", -- Corki W
		"Crowstorm", -- Fiddlesticks R
		"Drain", -- Fiddlesticks W
		"slashCast", -- Trynd E
		"Cutthroat", -- Talon E
		"Death Mark", --Zed R
		"DianaTeleport", -- Diana R
		"Distortion", -- Leblanc W
		"EliseSpiderQCast", -- Elise Q
		"FioraQ", -- Fiora Q
		"FizzPiercingStrike", -- Fizz Q
		"Glacial Path", -- Lissandra E
		"GragasE", -- Gragas E
		"GravesMove", -- Graves E
		"Headbutt", -- Alistar W
		"HecarimUlt", -- Hecarim R
		"IreliaGatotsu", -- Irelia Q
		"jarvanAddition", -- Jarvan Dash
		"JarvanIVDragonStrike", -- Jarvan Q
		"jarvanivcataclysmattack", -- Jarvan R
		"JarvanIVCataclysmAttack", -- Jarvan R
		"JaxLeapStrike", -- Jax Q
		"JayceToTheSkies", -- Jayce Q
		"KhazixE", -- Kha'Zix E
		"khazixeevo", -- Kha'Zix E evolved
		"khazixelong", -- Kha'Zix E evolved
		"LastBreath", -- Yasuo R
		"LeblancSlide", -- Leblanc W
		"LeblancSlideM", -- Leblanc R
		"LeonaZenithBlade", -- Leona E
		"Living Shadow", --Zed W
		"LucianE", -- Lucian E
		"MaokaiTrunkLine", -- Maokai W
		"MonkeyKingNimbus", -- Wukong E
		"NautilusAnchorDrag", -- Nautilus Q
		"PantheonW", -- Pantheon W
		"Pantheon_GrandSkyfall_Jump", -- Pantheon R
		"PoppyHeroicCharge", -- Poppy E
		"Pounce", -- Nidalee W
		"RenektonSliceAndDice", -- Renekton E
		"Riftwalk", -- Kassadin R
		"RivenFeint", -- Riven E
		"RivenTriCleave", -- Riven E
		"RocketJump", -- Tristana W
		"SejuaniArcticAssault", -- Sejuani Q
		"ShadowStep", -- Katarina E
		"ShenShadowDash", -- Shen E
		"Shunpo", -- Katarina E
		"ShyvanaTransformCast", -- Shyvana R
		"Slash", -- Tryndamere E
		"UFSlash", -- Malphite R
		"QuinnE", -- Quinn E
		"ViQ", -- Vi Q
		"XenZhaoSweep", -- Xin Zhao E
		"YasuoDashWrapper" -- Yasuo E
	}
end

function ChampionData:CanInterupt(spell)
	for i, sS in pairs(self.InteruptSpellList) do
		if sS and spell == sS then
			return true
		end
	end
	return false
end

function ChampionData:IsDash(spell)
	for i, sS in pairs(self.DashSpellList) do
		if sS and spell == sS then
			return true
		end
	end
	return false
end

_G.azBundle.ChampionData = ChampionData()
--[[-----------------------------------------------------
-----------------------/CHAMP DATA-----------------------
-----------------------------------------------------]]--

--[[-----------------------------------------------------
----------------------PREDICTION-------------------------
-----------------------------------------------------]]--
class("PredictionManager")
function PredictionManager:__init()
	--type = "line",
	--aoe = false,
	--colMinion = false,
	--colChamp = false,
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Prediction Settings <<", "Prediction")
		if self:NeedsPred(_G.azBundle.ChampionData.SkillQ.type) then
			_G.azBundle.MenuManager.menu.Prediction:addSubMenu(">> Q Settings <<", "Q")
				_G.azBundle.MenuManager.menu.Prediction.Q:addParam("pred", "Prediction", SCRIPT_PARAM_LIST, 1, {
					[1] = "VPrediction",
					[2] = "FH Prediction",
					[3] = "HPrediction"
				})
				
				_G.azBundle.MenuManager.menu.Prediction.Q:addParam("emptySpace1", "", SCRIPT_PARAM_INFO, "")
				_G.azBundle.MenuManager.menu.Prediction.Q:addParam("vpredMinion", "V Pred Minion Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
				_G.azBundle.MenuManager.menu.Prediction.Q:addParam("vpredChamp", "V Pred Champion Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
				
				_G.azBundle.MenuManager.menu.Prediction.Q:addParam("emptySpace2", "", SCRIPT_PARAM_INFO, "")
				_G.azBundle.MenuManager.menu.Prediction.Q:addParam("fhPred", "FH Prediction", SCRIPT_PARAM_INFO, "Auto Mode")
				
				_G.azBundle.MenuManager.menu.Prediction.Q:addParam("emptySpace3", "", SCRIPT_PARAM_INFO, "")
				_G.azBundle.MenuManager.menu.Prediction.Q:addParam("hpredMinion", "H Pred Minion Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
				_G.azBundle.MenuManager.menu.Prediction.Q:addParam("hpredChamp", "H Pred Champion Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
		end
		
		if self:NeedsPred(_G.azBundle.ChampionData.SkillW.type) then
			_G.azBundle.MenuManager.menu.Prediction:addSubMenu(">> W Settings <<", "W")
				_G.azBundle.MenuManager.menu.Prediction.W:addParam("pred", "Prediction", SCRIPT_PARAM_LIST, 1, {
					[1] = "VPrediction",
					[2] = "FH Prediction",
					[3] = "HPrediction"
				})
				
				_G.azBundle.MenuManager.menu.Prediction.W:addParam("emptySpace1", "", SCRIPT_PARAM_INFO, "")
				_G.azBundle.MenuManager.menu.Prediction.W:addParam("vpredMinion", "V Pred Minion Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
				_G.azBundle.MenuManager.menu.Prediction.W:addParam("vpredChamp", "V Pred Champion Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
				
				_G.azBundle.MenuManager.menu.Prediction.W:addParam("emptySpace2", "", SCRIPT_PARAM_INFO, "")
				_G.azBundle.MenuManager.menu.Prediction.W:addParam("fhPred", "FH Prediction", SCRIPT_PARAM_INFO, "Auto Mode")
				
				_G.azBundle.MenuManager.menu.Prediction.W:addParam("emptySpace3", "", SCRIPT_PARAM_INFO, "")
				_G.azBundle.MenuManager.menu.Prediction.W:addParam("hpredMinion", "H Pred Minion Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
				_G.azBundle.MenuManager.menu.Prediction.W:addParam("hpredChamp", "H Pred Champion Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
		end
		
		if self:NeedsPred(_G.azBundle.ChampionData.SkillE.type) then
			_G.azBundle.MenuManager.menu.Prediction:addSubMenu(">> E Settings <<", "E")
				_G.azBundle.MenuManager.menu.Prediction.E:addParam("pred", "Prediction", SCRIPT_PARAM_LIST, 1, {
					[1] = "VPrediction",
					[2] = "FH Prediction",
					[3] = "HPrediction"
				})
				
				_G.azBundle.MenuManager.menu.Prediction.E:addParam("emptySpace1", "", SCRIPT_PARAM_INFO, "")
				_G.azBundle.MenuManager.menu.Prediction.E:addParam("vpredMinion", "V Pred Minion Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
				_G.azBundle.MenuManager.menu.Prediction.E:addParam("vpredChamp", "V Pred Champion Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
				
				_G.azBundle.MenuManager.menu.Prediction.E:addParam("emptySpace2", "", SCRIPT_PARAM_INFO, "")
				_G.azBundle.MenuManager.menu.Prediction.E:addParam("fhPred", "FH Prediction", SCRIPT_PARAM_INFO, "Auto Mode")
				
				_G.azBundle.MenuManager.menu.Prediction.E:addParam("emptySpace3", "", SCRIPT_PARAM_INFO, "")
				_G.azBundle.MenuManager.menu.Prediction.E:addParam("hpredMinion", "H Pred Minion Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
				_G.azBundle.MenuManager.menu.Prediction.E:addParam("hpredChamp", "H Pred Champion Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
		end
		
		if self:NeedsPred(_G.azBundle.ChampionData.SkillR.type) then
			_G.azBundle.MenuManager.menu.Prediction:addSubMenu(">> R Settings <<", "R")
				_G.azBundle.MenuManager.menu.Prediction.R:addParam("pred", "Prediction", SCRIPT_PARAM_LIST, 1, {
					[1] = "VPrediction",
					[2] = "FH Prediction",
					[3] = "HPrediction"
				})
				
				_G.azBundle.MenuManager.menu.Prediction.R:addParam("emptySpace1", "", SCRIPT_PARAM_INFO, "")
				_G.azBundle.MenuManager.menu.Prediction.R:addParam("vpredMinion", "V Pred Minion Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
				_G.azBundle.MenuManager.menu.Prediction.R:addParam("vpredChamp", "V Pred Champion Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
				
				_G.azBundle.MenuManager.menu.Prediction.R:addParam("emptySpace2", "", SCRIPT_PARAM_INFO, "")
				_G.azBundle.MenuManager.menu.Prediction.R:addParam("fhPred", "FH Prediction", SCRIPT_PARAM_INFO, "Auto Mode")
				
				_G.azBundle.MenuManager.menu.Prediction.R:addParam("emptySpace3", "", SCRIPT_PARAM_INFO, "")
				_G.azBundle.MenuManager.menu.Prediction.R:addParam("hpredMinion", "H Pred Minion Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
				_G.azBundle.MenuManager.menu.Prediction.R:addParam("hpredChamp", "H Pred Champion Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
		end

		_G.azBundle.MenuManager.menu.Prediction:addParam("healthPred", "Health Prediction", SCRIPT_PARAM_LIST, 2, {
			[1] = "VPrediction",
			[2] = "FH Prediction",
			[3] = "None"
		})
		
		_G.azBundle.MenuManager.menu.Prediction:addParam("locationPred", "Location Prediction", SCRIPT_PARAM_LIST, 1, {
			[1] = "FH Prediction",
			[2] = "None"
		})
		--local hpQ = HPSkillshot({type = "DelayLine", range = spell.range, speed = spell.speed, width = spell.width, delay = spell.delay, collisionM = spell.collision, collisionH = spell.collision})
		--return HPSkillshot({type = "PromptLine", range = spell.range, width = spell.width, delay = spell.delay})
		--return HPSkillshot({type = "DelayCircle", range = spell.range, speed = spell.speed, radius = .5*spell.width, delay = spell.delay})
		--return HPSkillshot({type = "PromptCircle", range = spell.range, radius = .5*spell.width, delay = spell.delay})
		
		self.hpQ = nil
		self.hpW = nil
		self.hpE = nil
		self.hpR = nil
		
		if not FHPrediction and FileExist(LIB_PATH .. "FHPrediction.lua") then require("FHPrediction") end
end

function PredictionManager:NeedsPred(spellType)
	if spellType == "cone" or spellType == "circle" or spellType == "line" then
		return true
	end
	return false
end

function PredictionManager:PredictHealth(target, when)
	if VP and _G.azBundle.MenuManager.menu.Prediction.healthPred == 1 then
		return VP:GetPredictedHealth(target, when)
	elseif FH and _G.azBundle.MenuManager.menu.Prediction.healthPred == 2 then
		return FHPrediction.PredictHealth(target, when)
	elseif _G.azBundle.MenuManager.menu.Prediction.healthPred == 3 then
		return target.health
	elseif VP then
		return VP:GetPredictedHealth(target, when)
	else
		return target.health
	end
end

function PredictionManager:PredictPosition(target, when)
	if FH and _G.azBundle.MenuManager.menu.Prediction.locationPred == 1 then
		return FH:PredictPosition(target, when)
	elseif _G.azBundle.MenuManager.menu.Prediction.locationPred == 2 then
		return target.pos
	else
		return target.pos
	end
end

function PredictionManager:IsDashing(target, spell)
	if FH and _G.azBundle.MenuManager.menu.Prediction.locationPred == 1 then
		local dashing, pos = FHPrediction.IsUnitDashing(ts.target, "Q")
		if dashing and pos then
			return pos
		end
	end
	return false
end

function PredictionManager:CastQ(myT, isMinion, colision)
	if not ValidTarget(myT) then
		return
	end
	if _G.azBundle.MenuManager.menu.Prediction.Q.pred == 1 then
		--VPred
		if not VP then VP = VPrediction() end
		if _G.azBundle.ChampionData.SkillQ.type == "line" then
			if not _G.azBundle.ChampionData.SkillQ.aoe then
				local CastPosition, HitChance, Position = VP:GetLineCastPosition(myT, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, colision)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.Q.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.Q.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillQ.range ^ 2 then
						CastSpell(_Q, CastPosition.x, CastPosition.z)
						return true
					end
				end
			else
				local CastPosition, HitChance, Position = VP:GetLineAOECastPosition(myT, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.Q.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.Q.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillQ.range ^ 2 then
						CastSpell(_Q, CastPosition.x, CastPosition.z)
						return true
					end
				end
			end
		elseif _G.azBundle.ChampionData.SkillQ.type == "circle" then
			if not _G.azBundle.ChampionData.SkillQ.aoe then
				local CastPosition, HitChance, Position = VP:GetCircularCastPosition(myT, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, colision)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.Q.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.Q.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillQ.range ^ 2 then
						CastSpell(_Q, CastPosition.x, CastPosition.z)
						return true
					end
				end
			else
				local CastPosition, HitChance, Position = VP:GetCircularAOECastPosition(myT, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.Q.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.Q.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillQ.range ^ 2 then
						CastSpell(_Q, CastPosition.x, CastPosition.z)
						return true
					end
				end
			end
		end
	elseif _G.azBundle.MenuManager.menu.Prediction.Q.pred == 2 then
		local pos, hc, info = nil, nil, nil
		if _G.azBundle.ChampionData.fhQ then
			pos, hc, info = FHPrediction.GetPrediction(_G.azBundle.ChampionData.fhQ, myT)
		else
			pos, hc, info = FHPrediction.GetPrediction("Q", myT)
		end
		if pos and hc and info and hc > 0 and GetDistanceSqr(pos) <= _G.azBundle.ChampionData.SkillQ.range ^ 2 and ((colision and not info.collision) or (not colision)) then
			CastSpell(_Q, pos.x, pos.z)
			return true
		end
	elseif _G.azBundle.MenuManager.menu.Prediction.Q.pred == 3 then
		if not HP then HP = HPrediction() end
		if not self.hpQ and _G.azBundle.ChampionData.SkillQ.type == "line" then self.hpQ = HPSkillshot({type = "DelayLine", range = _G.azBundle.ChampionData.SkillQ.range, speed = _G.azBundle.ChampionData.SkillQ.speed, width = _G.azBundle.ChampionData.SkillQ.width, delay = _G.azBundle.ChampionData.SkillQ.delay, collisionM = colision, collisionH = colision}) end
		
		local CastPosition, HitChance, Position = HP:GetPredict(self.hpQ, myT, myHero, _G.azBundle.ChampionData.SkillQ.colMinion)
		if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.Q.hpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.Q.hpredChamp)) then
			if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillQ.range ^ 2 then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
				return true
			end
		end
	end
end

function PredictionManager:CastW(myT, isMinion, colision)
	if not ValidTarget(myT, _G.azBundle.ChampionData.SkillW.range + 50) then
		return
	end
	if _G.azBundle.MenuManager.menu.Prediction.W.pred == 1 then
		--VPred
		if not VP then VP = VPrediction() end
		if _G.azBundle.ChampionData.SkillW.type == "line" then
			if not _G.azBundle.ChampionData.SkillW.aoe then
				local CastPosition, HitChance, Position = VP:GetLineCastPosition(myT, _G.azBundle.ChampionData.SkillW.delay, _G.azBundle.ChampionData.SkillW.width, _G.azBundle.ChampionData.SkillW.range, _G.azBundle.ChampionData.SkillW.speed, myHero, colision)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.W.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.W.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillW.range ^ 2 then
						CastSpell(_W, CastPosition.x, CastPosition.z)
						return true
					end
				end
			else
				local CastPosition, HitChance, Position = VP:GetLineAOECastPosition(myT, _G.azBundle.ChampionData.SkillW.delay, _G.azBundle.ChampionData.SkillW.width, _G.azBundle.ChampionData.SkillW.range, _G.azBundle.ChampionData.SkillW.speed, myHero)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.W.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.W.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillW.range ^ 2 then
						CastSpell(_W, CastPosition.x, CastPosition.z)
						return true
					end
				end
			end
		elseif _G.azBundle.ChampionData.SkillW.type == "circle" then
			if not _G.azBundle.ChampionData.SkillW.aoe then
				local CastPosition, HitChance, Position = VP:GetCircularCastPosition(myT, _G.azBundle.ChampionData.SkillW.delay, _G.azBundle.ChampionData.SkillW.width, _G.azBundle.ChampionData.SkillW.range, _G.azBundle.ChampionData.SkillW.speed, myHero, colision)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.W.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.W.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillW.range ^ 2 then
						CastSpell(_W, CastPosition.x, CastPosition.z)
						return true
					end
				end
			else
				local CastPosition, HitChance, Position = VP:GetCircularAOECastPosition(myT, _G.azBundle.ChampionData.SkillW.delay, _G.azBundle.ChampionData.SkillW.width, _G.azBundle.ChampionData.SkillW.range, _G.azBundle.ChampionData.SkillW.speed, myHero)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.W.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.W.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillW.range ^ 2 then
						CastSpell(_W, CastPosition.x, CastPosition.z)
						return true
					end
				end
			end
		end
	elseif _G.azBundle.MenuManager.menu.Prediction.W.pred == 2 then
		local pos, hc, info = nil, nil, nil
		if _G.azBundle.ChampionData.fhW then
			pos, hc, info = FHPrediction.GetPrediction(_G.azBundle.ChampionData.fhW, myT)
		else
			pos, hc, info = FHPrediction.GetPrediction("W", myT)
		end
		if pos and hc and info and hc > 0 and GetDistanceSqr(pos) <= _G.azBundle.ChampionData.SkillW.range ^ 2 and ((colision and not info.collision) or (not colision)) then
			CastSpell(_W, pos.x, pos.z)
			return true
		end
	elseif _G.azBundle.MenuManager.menu.Prediction.W.pred == 3 then
		if not HP then HP = HPrediction() end
		if not self.hpW and _G.azBundle.ChampionData.SkillW.type == "line" then self.hpW = HPSkillshot({type = "DelayLine", range = _G.azBundle.ChampionData.SkillW.range, speed = _G.azBundle.ChampionData.SkillW.speed, width = _G.azBundle.ChampionData.SkillW.width, delay = _G.azBundle.ChampionData.SkillW.delay, collisionM = colision, collisionH = colision}) end
		
		local CastPosition, HitChance, Position = HP:GetPredict(self.hpW, myT, myHero, _G.azBundle.ChampionData.SkillW.colMinion)
		if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.W.hpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.W.hpredChamp)) then
			if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillW.range ^ 2 then
				CastSpell(_W, CastPosition.x, CastPosition.z)
				return true
			end
		end
	end
end

function PredictionManager:CastE(myT, isMinion, colision)
	if not ValidTarget(myT, _G.azBundle.ChampionData.SkillE.range + 50) then
		return
	end
	if _G.azBundle.MenuManager.menu.Prediction.E.pred == 1 then
		--VPred
		if not VP then VP = VPrediction() end
		if _G.azBundle.ChampionData.SkillE.type == "line" then
			if not _G.azBundle.ChampionData.SkillE.aoe then
				local CastPosition, HitChance, Position = VP:GetLineCastPosition(myT, _G.azBundle.ChampionData.SkillE.delay, _G.azBundle.ChampionData.SkillE.width, _G.azBundle.ChampionData.SkillE.range, _G.azBundle.ChampionData.SkillE.speed, myHero, colision)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.E.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.E.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillE.range ^ 2 then
						CastSpell(_E, CastPosition.x, CastPosition.z)
						return true
					end
				end
			else
				local CastPosition, HitChance, Position = VP:GetLineAOECastPosition(myT, _G.azBundle.ChampionData.SkillE.delay, _G.azBundle.ChampionData.SkillE.width, _G.azBundle.ChampionData.SkillE.range, _G.azBundle.ChampionData.SkillE.speed, myHero)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.E.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.E.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillE.range ^ 2 then
						CastSpell(_E, CastPosition.x, CastPosition.z)
						return true
					end
				end
			end
		elseif _G.azBundle.ChampionData.SkillE.type == "circle" then
			if not _G.azBundle.ChampionData.SkillE.aoe then
				local CastPosition, HitChance, Position = VP:GetCircularCastPosition(myT, _G.azBundle.ChampionData.SkillE.delay, _G.azBundle.ChampionData.SkillE.width, _G.azBundle.ChampionData.SkillE.range, _G.azBundle.ChampionData.SkillE.speed, myHero, colision)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.E.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.E.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillE.range ^ 2 then
						CastSpell(_E, CastPosition.x, CastPosition.z)
						return true
					end
				end
			else
				local CastPosition, HitChance, Position = VP:GetCircularAOECastPosition(myT, _G.azBundle.ChampionData.SkillE.delay, _G.azBundle.ChampionData.SkillE.width, _G.azBundle.ChampionData.SkillE.range, _G.azBundle.ChampionData.SkillE.speed, myHero)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.E.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.E.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillE.range ^ 2 then
						CastSpell(_E, CastPosition.x, CastPosition.z)
						return true
					end
				end
			end
		end
	elseif _G.azBundle.MenuManager.menu.Prediction.E.pred == 2 then
		local pos, hc, info = nil, nil, nil
		if _G.azBundle.ChampionData.fhE then
			pos, hc, info = FHPrediction.GetPrediction(_G.azBundle.ChampionData.fhE, myT)
		else
			pos, hc, info = FHPrediction.GetPrediction("E", myT)
		end
		if pos and hc and info and hc > 0 and GetDistanceSqr(pos) <= _G.azBundle.ChampionData.SkillE.range ^ 2 and ((colision and not info.collision) or (not colision)) then
			CastSpell(_E, pos.x, pos.z)
			return true
		end
	elseif _G.azBundle.MenuManager.menu.Prediction.E.pred == 3 then
		if not HP then HP = HPrediction() end
		if not self.hpE and _G.azBundle.ChampionData.SkillE.type == "line" then self.hpE = HPSkillshot({type = "DelayLine", range = _G.azBundle.ChampionData.SkillE.range, speed = _G.azBundle.ChampionData.SkillE.speed, width = _G.azBundle.ChampionData.SkillE.width, delay = _G.azBundle.ChampionData.SkillE.delay, collisionM = colision, collisionH = colision}) end
		
		local CastPosition, HitChance, Position = HP:GetPredict(self.hpE, myT, myHero, _G.azBundle.ChampionData.SkillE.colMinion)
		if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.E.hpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.E.hpredChamp)) then
			if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillE.range ^ 2 then
				CastSpell(_E, CastPosition.x, CastPosition.z)
				return true
			end
		end
	end
end

function PredictionManager:CastR(myT, isMinion, colision)
	if not ValidTarget(myT, _G.azBundle.ChampionData.SkillR.range + 50) then
		return
	end
	if _G.azBundle.MenuManager.menu.Prediction.R.pred == 1 then
		--VPred
		if not VP then VP = VPrediction() end
		if _G.azBundle.ChampionData.SkillR.type == "line" then
			if not _G.azBundle.ChampionData.SkillR.aoe then
				local CastPosition, HitChance, Position = VP:GetLineCastPosition(myT, _G.azBundle.ChampionData.SkillR.delay, _G.azBundle.ChampionData.SkillR.width, _G.azBundle.ChampionData.SkillR.range, _G.azBundle.ChampionData.SkillR.speed, myHero, colision)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.R.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.R.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillR.range ^ 2 then
						CastSpell(_R, CastPosition.x, CastPosition.z)
						return true
					end
				end
			else
				local CastPosition, HitChance, Position = VP:GetLineAOECastPosition(myT, _G.azBundle.ChampionData.SkillR.delay, _G.azBundle.ChampionData.SkillR.width, _G.azBundle.ChampionData.SkillR.range, _G.azBundle.ChampionData.SkillR.speed, myHero)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.R.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.R.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillR.range ^ 2 then
						CastSpell(_R, CastPosition.x, CastPosition.z)
						return true
					end
				end
			end
		elseif _G.azBundle.ChampionData.SkillR.type == "circle" then
			if not _G.azBundle.ChampionData.SkillR.aoe then
				local CastPosition, HitChance, Position = VP:GetCircularCastPosition(myT, _G.azBundle.ChampionData.SkillR.delay, _G.azBundle.ChampionData.SkillR.width, _G.azBundle.ChampionData.SkillR.range, _G.azBundle.ChampionData.SkillR.speed, myHero, colision)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.R.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.R.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillR.range ^ 2 then
						CastSpell(_R, CastPosition.x, CastPosition.z)
						return true
					end
				end
			else
				local CastPosition, HitChance, Position = VP:GetCircularAOECastPosition(myT, _G.azBundle.ChampionData.SkillR.delay, _G.azBundle.ChampionData.SkillR.width, _G.azBundle.ChampionData.SkillR.range, _G.azBundle.ChampionData.SkillR.speed, myHero)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.R.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.R.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillR.range ^ 2 then
						CastSpell(_R, CastPosition.x, CastPosition.z)
						return true
					end
				end
			end
		end
	elseif _G.azBundle.MenuManager.menu.Prediction.R.pred == 2 then
		local pos, hc, info = nil, nil, nil
		if _G.azBundle.ChampionData.fhR then
			pos, hc, info = FHPrediction.GetPrediction(_G.azBundle.ChampionData.fhR, myT)
		else
			pos, hc, info = FHPrediction.GetPrediction("R", myT)
		end
		if pos and hc and info and hc > 0 and GetDistanceSqr(pos) <= _G.azBundle.ChampionData.SkillR.range ^ 2 and ((colision and not info.collision) or (not colision)) then
			CastSpell(_R, pos.x, pos.z)
			return true
		end
	elseif _G.azBundle.MenuManager.menu.Prediction.R.pred == 3 then
		if not HP then HP = HPrediction() end
		if not self.hpR and _G.azBundle.ChampionData.SkillR.type == "line" then self.hpR = HPSkillshot({type = "DelayLine", range = _G.azBundle.ChampionData.SkillR.range, speed = _G.azBundle.ChampionData.SkillR.speed, width = _G.azBundle.ChampionData.SkillR.width, delay = _G.azBundle.ChampionData.SkillR.delay, collisionM = colision, collisionH = colision}) end
		
		local CastPosition, HitChance, Position = HP:GetPredict(self.hpR, myT, myHero, _G.azBundle.ChampionData.SkillR.colMinion)
		if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.R.hpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.R.hpredChamp)) then
			if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillR.range ^ 2 then
				CastSpell(_R, CastPosition.x, CastPosition.z)
				return true
			end
		end
	end
end

function PredictionManager:CheckQ(myT, isMinion, colision)
	if not ValidTarget(myT) then
		return
	end
	if _G.azBundle.MenuManager.menu.Prediction.Q.pred == 1 then
		--VPred
		if not VP then VP = VPrediction() end
		if _G.azBundle.ChampionData.SkillQ.type == "line" then
			if not _G.azBundle.ChampionData.SkillQ.aoe then
				local CastPosition, HitChance, Position = VP:GetLineCastPosition(myT, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, colision)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.Q.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.Q.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillQ.range ^ 2 then
						return true
					end
				end
			else
				local CastPosition, HitChance, Position = VP:GetLineAOECastPosition(myT, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.Q.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.Q.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillQ.range ^ 2 then
						return true
					end
				end
			end
		elseif _G.azBundle.ChampionData.SkillQ.type == "circle" then
			if not _G.azBundle.ChampionData.SkillQ.aoe then
				local CastPosition, HitChance, Position = VP:GetCircularCastPosition(myT, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, colision)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.Q.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.Q.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillQ.range ^ 2 then
						return true
					end
				end
			else
				local CastPosition, HitChance, Position = VP:GetCircularAOECastPosition(myT, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.Q.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.Q.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillQ.range ^ 2 then
						return true
					end
				end
			end
		end
	elseif _G.azBundle.MenuManager.menu.Prediction.Q.pred == 2 then
		local pos, hc, info = nil, nil, nil
		if _G.azBundle.ChampionData.fhQ then
			pos, hc, info = FHPrediction.GetPrediction(_G.azBundle.ChampionData.fhQ, myT)
		else
			pos, hc, info = FHPrediction.GetPrediction("Q", myT)
		end
		if pos and hc and info and hc > 0 and GetDistanceSqr(pos) <= _G.azBundle.ChampionData.SkillQ.range ^ 2 and ((colision and not info.collision) or (not colision)) then
			return true
		end
	elseif _G.azBundle.MenuManager.menu.Prediction.Q.pred == 3 then
		if not HP then HP = HPrediction() end
		if not self.hpQ and _G.azBundle.ChampionData.SkillQ.type == "line" then self.hpQ = HPSkillshot({type = "DelayLine", range = _G.azBundle.ChampionData.SkillQ.range, speed = _G.azBundle.ChampionData.SkillQ.speed, width = _G.azBundle.ChampionData.SkillQ.width, delay = _G.azBundle.ChampionData.SkillQ.delay, collisionM = colision, collisionH = colision}) end
		
		local CastPosition, HitChance, Position = HP:GetPredict(self.hpQ, myT, myHero, _G.azBundle.ChampionData.SkillQ.colMinion)
		if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.Q.hpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.Q.hpredChamp)) then
			if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillQ.range ^ 2 then
				return true
			end
		end
	end
end

function PredictionManager:CheckW(myT, isMinion, colision)
	if not ValidTarget(myT, _G.azBundle.ChampionData.SkillW.range + 50) then
		return
	end
	if _G.azBundle.MenuManager.menu.Prediction.W.pred == 1 then
		--VPred
		if not VP then VP = VPrediction() end
		if _G.azBundle.ChampionData.SkillW.type == "line" then
			if not _G.azBundle.ChampionData.SkillW.aoe then
				local CastPosition, HitChance, Position = VP:GetLineCastPosition(myT, _G.azBundle.ChampionData.SkillW.delay, _G.azBundle.ChampionData.SkillW.width, _G.azBundle.ChampionData.SkillW.range, _G.azBundle.ChampionData.SkillW.speed, myHero, colision)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.W.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.W.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillW.range ^ 2 then
						return true
					end
				end
			else
				local CastPosition, HitChance, Position = VP:GetLineAOECastPosition(myT, _G.azBundle.ChampionData.SkillW.delay, _G.azBundle.ChampionData.SkillW.width, _G.azBundle.ChampionData.SkillW.range, _G.azBundle.ChampionData.SkillW.speed, myHero)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.W.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.W.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillW.range ^ 2 then
						return true
					end
				end
			end
		elseif _G.azBundle.ChampionData.SkillW.type == "circle" then
			if not _G.azBundle.ChampionData.SkillW.aoe then
				local CastPosition, HitChance, Position = VP:GetCircularCastPosition(myT, _G.azBundle.ChampionData.SkillW.delay, _G.azBundle.ChampionData.SkillW.width, _G.azBundle.ChampionData.SkillW.range, _G.azBundle.ChampionData.SkillW.speed, myHero, colision)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.W.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.W.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillW.range ^ 2 then
						return true
					end
				end
			else
				local CastPosition, HitChance, Position = VP:GetCircularAOECastPosition(myT, _G.azBundle.ChampionData.SkillW.delay, _G.azBundle.ChampionData.SkillW.width, _G.azBundle.ChampionData.SkillW.range, _G.azBundle.ChampionData.SkillW.speed, myHero)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.W.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.W.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillW.range ^ 2 then
						return true
					end
				end
			end
		end
	elseif _G.azBundle.MenuManager.menu.Prediction.W.pred == 2 then
		local pos, hc, info = nil, nil, nil
		if _G.azBundle.ChampionData.fhW then
			pos, hc, info = FHPrediction.GetPrediction(_G.azBundle.ChampionData.fhW, myT)
		else
			pos, hc, info = FHPrediction.GetPrediction("W", myT)
		end
		if pos and hc and info and hc > 0 and GetDistanceSqr(pos) <= _G.azBundle.ChampionData.SkillW.range ^ 2 and ((colision and not info.collision) or (not colision)) then
			return true
		end
	elseif _G.azBundle.MenuManager.menu.Prediction.W.pred == 3 then
		if not HP then HP = HPrediction() end
		if not self.hpW and _G.azBundle.ChampionData.SkillW.type == "line" then self.hpW = HPSkillshot({type = "DelayLine", range = _G.azBundle.ChampionData.SkillW.range, speed = _G.azBundle.ChampionData.SkillW.speed, width = _G.azBundle.ChampionData.SkillW.width, delay = _G.azBundle.ChampionData.SkillW.delay, collisionM = colision, collisionH = colision}) end
		
		local CastPosition, HitChance, Position = HP:GetPredict(self.hpW, myT, myHero, _G.azBundle.ChampionData.SkillW.colMinion)
		if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.W.hpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.W.hpredChamp)) then
			if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillW.range ^ 2 then
				return true
			end
		end
	end
end

function PredictionManager:CheckE(myT, isMinion, colision)
	if not ValidTarget(myT, _G.azBundle.ChampionData.SkillE.range + 50) then
		return
	end
	if _G.azBundle.MenuManager.menu.Prediction.E.pred == 1 then
		--VPred
		if not VP then VP = VPrediction() end
		if _G.azBundle.ChampionData.SkillE.type == "line" then
			if not _G.azBundle.ChampionData.SkillE.aoe then
				local CastPosition, HitChance, Position = VP:GetLineCastPosition(myT, _G.azBundle.ChampionData.SkillE.delay, _G.azBundle.ChampionData.SkillE.width, _G.azBundle.ChampionData.SkillE.range, _G.azBundle.ChampionData.SkillE.speed, myHero, colision)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.E.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.E.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillE.range ^ 2 then
						return true
					end
				end
			else
				local CastPosition, HitChance, Position = VP:GetLineAOECastPosition(myT, _G.azBundle.ChampionData.SkillE.delay, _G.azBundle.ChampionData.SkillE.width, _G.azBundle.ChampionData.SkillE.range, _G.azBundle.ChampionData.SkillE.speed, myHero)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.E.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.E.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillE.range ^ 2 then
						return true
					end
				end
			end
		elseif _G.azBundle.ChampionData.SkillE.type == "circle" then
			if not _G.azBundle.ChampionData.SkillE.aoe then
				local CastPosition, HitChance, Position = VP:GetCircularCastPosition(myT, _G.azBundle.ChampionData.SkillE.delay, _G.azBundle.ChampionData.SkillE.width, _G.azBundle.ChampionData.SkillE.range, _G.azBundle.ChampionData.SkillE.speed, myHero, colision)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.E.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.E.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillE.range ^ 2 then
						return true
					end
				end
			else
				local CastPosition, HitChance, Position = VP:GetCircularAOECastPosition(myT, _G.azBundle.ChampionData.SkillE.delay, _G.azBundle.ChampionData.SkillE.width, _G.azBundle.ChampionData.SkillE.range, _G.azBundle.ChampionData.SkillE.speed, myHero)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.E.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.E.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillE.range ^ 2 then
						return true
					end
				end
			end
		end
	elseif _G.azBundle.MenuManager.menu.Prediction.E.pred == 2 then
		local pos, hc, info = nil, nil, nil
		if _G.azBundle.ChampionData.fhE then
			pos, hc, info = FHPrediction.GetPrediction(_G.azBundle.ChampionData.fhE, myT)
		else
			pos, hc, info = FHPrediction.GetPrediction("E", myT)
		end
		if pos and hc and info and hc > 0 and GetDistanceSqr(pos) <= _G.azBundle.ChampionData.SkillE.range ^ 2 and ((colision and not info.collision) or (not colision)) then
			return true
		end
	elseif _G.azBundle.MenuManager.menu.Prediction.E.pred == 3 then
		if not HP then HP = HPrediction() end
		if not self.hpE and _G.azBundle.ChampionData.SkillE.type == "line" then self.hpE = HPSkillshot({type = "DelayLine", range = _G.azBundle.ChampionData.SkillE.range, speed = _G.azBundle.ChampionData.SkillE.speed, width = _G.azBundle.ChampionData.SkillE.width, delay = _G.azBundle.ChampionData.SkillE.delay, collisionM = colision, collisionH = colision}) end
		
		local CastPosition, HitChance, Position = HP:GetPredict(self.hpE, myT, myHero, _G.azBundle.ChampionData.SkillE.colMinion)
		if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.E.hpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.E.hpredChamp)) then
			if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillE.range ^ 2 then
				return true
			end
		end
	end
end

function PredictionManager:CheckR(myT, isMinion, colision)
	if not ValidTarget(myT, _G.azBundle.ChampionData.SkillR.range + 50) then
		return
	end
	if _G.azBundle.MenuManager.menu.Prediction.R.pred == 1 then
		--VPred
		if not VP then VP = VPrediction() end
		if _G.azBundle.ChampionData.SkillR.type == "line" then
			if not _G.azBundle.ChampionData.SkillR.aoe then
				local CastPosition, HitChance, Position = VP:GetLineCastPosition(myT, _G.azBundle.ChampionData.SkillR.delay, _G.azBundle.ChampionData.SkillR.width, _G.azBundle.ChampionData.SkillR.range, _G.azBundle.ChampionData.SkillR.speed, myHero, colision)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.R.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.R.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillR.range ^ 2 then
						return true
					end
				end
			else
				local CastPosition, HitChance, Position = VP:GetLineAOECastPosition(myT, _G.azBundle.ChampionData.SkillR.delay, _G.azBundle.ChampionData.SkillR.width, _G.azBundle.ChampionData.SkillR.range, _G.azBundle.ChampionData.SkillR.speed, myHero)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.R.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.R.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillR.range ^ 2 then
						return true
					end
				end
			end
		elseif _G.azBundle.ChampionData.SkillR.type == "circle" then
			if not _G.azBundle.ChampionData.SkillR.aoe then
				local CastPosition, HitChance, Position = VP:GetCircularCastPosition(myT, _G.azBundle.ChampionData.SkillR.delay, _G.azBundle.ChampionData.SkillR.width, _G.azBundle.ChampionData.SkillR.range, _G.azBundle.ChampionData.SkillR.speed, myHero, colision)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.R.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.R.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillR.range ^ 2 then
						return true
					end
				end
			else
				local CastPosition, HitChance, Position = VP:GetCircularAOECastPosition(myT, _G.azBundle.ChampionData.SkillR.delay, _G.azBundle.ChampionData.SkillR.width, _G.azBundle.ChampionData.SkillR.range, _G.azBundle.ChampionData.SkillR.speed, myHero)
				if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.R.vpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.R.vpredChamp)) then
					if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillR.range ^ 2 then
						return true
					end
				end
			end
		end
	elseif _G.azBundle.MenuManager.menu.Prediction.R.pred == 2 then
		local pos, hc, info = nil, nil, nil
		if _G.azBundle.ChampionData.fhR then
			pos, hc, info = FHPrediction.GetPrediction(_G.azBundle.ChampionData.fhR, myT)
		else
			pos, hc, info = FHPrediction.GetPrediction("R", myT)
		end
		if pos and hc and info and hc > 0 and GetDistanceSqr(pos) <= _G.azBundle.ChampionData.SkillR.range ^ 2 and ((colision and not info.collision) or (not colision)) then
			return true
		end
	elseif _G.azBundle.MenuManager.menu.Prediction.R.pred == 3 then
		if not HP then HP = HPrediction() end
		if not self.hpR and _G.azBundle.ChampionData.SkillR.type == "line" then self.hpR = HPSkillshot({type = "DelayLine", range = _G.azBundle.ChampionData.SkillR.range, speed = _G.azBundle.ChampionData.SkillR.speed, width = _G.azBundle.ChampionData.SkillR.width, delay = _G.azBundle.ChampionData.SkillR.delay, collisionM = colision, collisionH = colision}) end
		
		local CastPosition, HitChance, Position = HP:GetPredict(self.hpR, myT, myHero, _G.azBundle.ChampionData.SkillR.colMinion)
		if CastPosition and HitChance and ((isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.R.hpredMinion) or (not isMinion and HitChance >= _G.azBundle.MenuManager.menu.Prediction.R.hpredChamp)) then
			if GetDistanceSqr(CastPosition) <= _G.azBundle.ChampionData.SkillR.range ^ 2 then
				return true
			end
		end
	end
end
--[[-----------------------------------------------------
----------------------/PREDICTION------------------------
-----------------------------------------------------]]--

--[[-----------------------------------------------------
-----------------------ORBWALKER-------------------------
-----------------------------------------------------]]--
class("OrbwalkManager")
function OrbwalkManager:__init()
	self.sacDetected = false
	self.sacPDetected = false
	self.pewDetected = false
	self.nebiDetected = false
	self.s1Detected = false
	self.sxDetected = false
	self.isSacReady = false
	
	if _G.Reborn_Loaded or _G.Reborn_Initialised or _G.AutoCarry ~= nil then
		_G.azBundle.PrintManager:General("SAC:R detected.")
		DelayAction(function()
			self.sacDetected = true
			self.isSacReady = true
		end, 5)
	elseif _G.S1OrbLoading or _G.S1mpleOrbLoaded then
		self.s1Detected = true
		G.azBundle.PrintManager:General("Simple Orb Walk detected.")
	elseif SAC then
		self.sacPDetected = true
		G.azBundle.PrintManager:General("SAC:P detected.")
	elseif _Pewalk then
		self.pewDetected = true
		G.azBundle.PrintManager:General("PeWalk detected.")
	elseif _G.NebelwolfisOrbWalkerInit then
		self.nebiDetected = true
		G.azBundle.PrintManager:General("Nebelwolfid Orb Walk detected.")
	elseif FileExist(LIB_PATH .. "SxOrbWalk.lua") then
		self.sxDetected = true
		require("SxOrbWalk")
		G.azBundle.PrintManager:General("SXOrbWalk detected.")
	else
		G.azBundle.PrintManager:General("No known orbwalk detected. Please make sure to set up your keys to match the orb walkers keys.")
	end
end

function OrbwalkManager:ResetAA()
	if self.sacDetected then
		_G.AutoCarry.Orbwalker:ResetAttackTimer()
	elseif self.nebiDetected then
		_G.NebelwolfisOrbWalker:ResetAA()
	elseif self.sxDetected then
		_G.SxOrb:ResetAA()
	end
end

function OrbwalkManager:DisableOrbWalkAttacks()
	if self.sacDetected and self.isSacReady then
		_G.AutoCarry.MyHero:AttacksEnabled(false)
	elseif self.pewDetected then
		 _Pewalk.AllowAttack(false)
	elseif self.sxDetected then
		 _G.SxOrb:DisableAttacks()
	elseif self.nebiDetected then
		 _G.NebelwolfisOrbWalker:SetOrb(false)
	end
	DelayAction(function()
		EnableOrbWalkAttacks()
	end, 1.75)
end

function OrbwalkManager:EnableOrbWalkAttacks()
	if self.sacDetected and self.isSacReady then
		_G.AutoCarry.MyHero:AttacksEnabled(true)
	elseif self.pewDetected then
		 _Pewalk.AllowAttack(true)
	elseif self.sxDetected then
		 _G.SxOrb:EnableAttacks()
	elseif self.nebiDetected then
		 _G.NebelwolfisOrbWalker:SetOrb(true)
	end
end

function OrbwalkManager:DisableOrbWalkMove()
	if self.sacDetected and self.isSacReady then
		_G.AutoCarry.MyHero:MovementEnabled(false)
	elseif self.pewDetected then
		 _Pewalk.AllowMove(false)
	elseif self.sxDetected then
		 _G.SxOrb:DisableMove()
	elseif self.nebiDetected then
		 _G.NebelwolfisOrbWalker:SetOrb(false)
	end
	DelayAction(function()
		EnableOrbWalkMove()
	end, 1.75)
end

function OrbwalkManager:EnableOrbWalkMove()
	if self.sacDetected and self.isSacReady then
		_G.AutoCarry.MyHero:MovementEnabled(true)
	elseif self.pewDetected then
		 _Pewalk.AllowMove(true)
	elseif self.sxDetected then
		 _G.SxOrb:EnableMove()
	elseif self.nebiDetected then
		 _G.NebelwolfisOrbWalker:SetOrb(true)
	end
end

function OrbwalkManager:Mode()
	if _G.azBundle.MenuManager.menu.Combo.key then
		return "Combo"
	end
	if _G.azBundle.MenuManager.menu.Harass.key then
		return "Harass"
	end
	if _G.azBundle.MenuManager.menu.LaneClear.key then
		return "LaneClear"
	end
	if _G.azBundle.MenuManager.menu.LastHit.key then
		return "LastHit"
	end
end

function OrbwalkManager:Target()
	if self.sacDetected then
		return _G.AutoCarry.SkillsCrosshair.target
	elseif self.nebiDetected then
		return _G.NebelwolfisOrbWalker:GetTarget()
	elseif self.pewDetected then
		return _Pewalk.GetTarget()
	elseif self.sxDetected then
		return SxOrb:EnableAttacks()
	else
		return nil
	end
end
--[[-----------------------------------------------------
-----------------------/ORBWALKER------------------------
-----------------------------------------------------]]--

--[[-----------------------------------------------------
---------------------LIB DOWNLOAD------------------------
-----------------------------------------------------]]--
local toDownload = {
	["HPrediction"] = "https://raw.githubusercontent.com/BolHTTF/BoL/master/HTTF/Common/HPrediction.lua",
	["VPrediction"] = "https://raw.githubusercontent.com/SidaBoL/Chaos/master/VPrediction.lua",
	["FHPrediction"] = "http://api.funhouse.me/download-lua.php"
}

local isDownloading = false
local downloadCount = 0

function LibDownloaderPrint(msg)
	print("<font color=\"#FF794C\"><b>" .. _G.azBundle.ChampionData.scriptName .. "</b></font> <font color=\"#FFDFBF\"><b>"..msg.."</b></font>")
end

function FileDownloaded()
	downloadCount = downloadCount - 1
	if downloadCount == 0 then
		isDownloading = false
		LibDownloaderPrint("<font color=\"#6699FF\">Downloads complete. Please press F9 twice to reload.</font>")
	end
end

for libName, libUrl in pairs(toDownload) do
	if FileExist(LIB_PATH .. libName .. ".lua") then
		require(libName)
	else
		isDownloading = true
		downloadCount = downloadCount + 1
		LibDownloaderPrint("<font color=\"#6699FF\">Downloading " .. libName .. ".</font>")
		DownloadFile(libUrl, LIB_PATH .. libUrl .. ".lua", FileDownloaded)
	end
end

if isDownloading then return end

VP = VPrediction()
HP = HPrediction()
--[[-----------------------------------------------------
--------------------/LIB DOWNLOAD------------------------
-----------------------------------------------------]]--

--[[-----------------------------------------------------
--------------------------MATH---------------------------
-----------------------------------------------------]]--
function round(num)
	if num >= 0 then
    	return math.floor(num + 0.5)
	else
    	return math.ceil(num - 0.5)
	end
end

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

function GetFarmPosition(range, width, minions)
    local BestPos 
    local BestHit = 0
    local objects = minions
    for i, object in pairs(objects) do
      local hit = CountObjectsNearPos(object.pos or object, range, width, objects)
      if hit > BestHit and GetDistanceSqr(object) < range * range then
        BestHit = hit
        BestPos = Vector(object)
        if BestHit == #objects then
          break
        end
      end
    end
    return BestPos, BestHit
end

function CountObjectsNearPos(pos, range, radius, objects)
    local n = 0
    for i, object in pairs(objects) do
      if GetDistanceSqr(pos, object) <= radius * radius then
        n = n + 1
      end
    end
    return n
end

function HasBuff(unit, buffname)

    for i = 1, unit.buffCount do
        local tBuff = unit:getBuff(i)
        if tBuff.valid and BuffIsValid(tBuff) and tBuff.name == buffname then
            return true
        end
    end
    return false

end

function CalcVector(source,target)
	local V = Vector(source.x, source.y, source.z)
	local V2 = Vector(target.x, target.y, target.z)
	local vec = V-V2
	local vec2 = vec:normalized()
	return vec2
end

function DrawLine3D2(x1, y1, z1, x2, y2, z2, width, color)
    local p = WorldToScreen(D3DXVECTOR3(x1, y1, z1))
    local px, py = p.x, p.y
    local c = WorldToScreen(D3DXVECTOR3(x2, y2, z2))
    local cx, cy = c.x, c.y
    DrawLine(cx, cy, px, py, width or 1, color or 4294967295)
end

function CountObjectsOnLineSegment(StartPos, EndPos, width, objects)
    local n = 0
    for i, object in ipairs(objects) do
        local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(StartPos, EndPos, object)
        if isOnSegment and GetDistanceSqr(pointSegment, object) < width * width then
            n = n + 1
        end
    end
    return n
end

function IsManaLow(per)
	if per == nil then return false end
	return ((myHero.mana / myHero.maxMana * 100) <= per)
end

function GetWallData(sPos, ePos, limitCheck)
	distance = GetDistance(sPos, ePos)
	Boolean = false
	fPos = 0
	lPos = 0
	for i = 0, distance, 10 do
		tempPos = Extends(sPos, ePos, i)
		if(IsWall(D3DXVECTOR3(tempPos.x, tempPos.y, tempPos.z)) and fPos == 0)then
			fPos = tempPos
		end
		lPos = tempPos
		if(not IsWall(D3DXVECTOR3(lPos.x, lPos.y, lPos.z)) and fPos ~= 0)then
			if(i < limitCheck)then Boolean = true end
			break
		end
	end
	if(fPos ==0 ) then fPos = Vector(0, 0, 0) end
	_r = {
		fPos = fPos,
		lPos = lPos,
		IsOverWall = Boolean,
		distance = GetDistance(fPos, lPos)
	}
	return _r
end

function GetWallPoint(startPos, endPos)
	distance = GetDistance(startPos, endPos)
	for i = 0, distance, 10 do
		tempPos = Extends(startPos, endPos, i)
		if(IsWall(D3DXVECTOR3(tempPos.x, tempPos.y, tempPos.z)))then
			return Extends(tempPos, startPos, -35)
		end
	end
end

function IsOverWall(sPos, ePos)
	distance = GetDistance(sPos, ePos)
	fPos = 0
	lPos = 0
	for i = 0, distance, 10 do
		tempPos = Extends(sPos, ePos, i)
		if(IsWall(D3DXVECTOR3(tempPos.x, tempPos.y, tempPos.z)) and fPos == 0)then
			fPos = tempPos
		end
		lPos = tempPos
		if(not IsWall(D3DXVECTOR3(lPos.x, lPos.y, lPos.z)) and fPos ~= 0)then
			return true
		end
	end
	return false
end

function GetWallLength(sPos, ePos)
	distance = GetDistance(sPos, ePos)
	fPos = 0
	lPos = 0
	for i = 0, distance, 10 do
		tempPos = Extends(sPos, ePos, i)
		if(IsWall(D3DXVECTOR3(tempPos.x, tempPos.y, tempPos.z)) and fPos == 0)then
			fPos = tempPos
		end
		lPos = tempPos
		if(not IsWall(D3DXVECTOR3(lPos.x, lPos.y, lPos.z)) and fPos ~= 0)then
			break
		end
	end
	if(fPos ==0 ) then fPos = Vector(0, 0, 0) end
	return GetDistance(fPos, lPos)
end

function GetFirstWallPoint(sPos, ePos)
	distance = GetDistance(sPos, ePos)
	for i = 0, distance, 10 do
		tempPos = Extends(sPos, ePos, i)
		if(IsWall(D3DXVECTOR3(tempPos.x, tempPos.y, tempPos.z)))then
			return Extends(tempPos, sPos, -35)
		end
	end
	return Vector(0, 0, 0)
end
--[[-----------------------------------------------------
--------------------------/MATH--------------------------
-----------------------------------------------------]]--

--[[-----------------------------------------------------
------------------------DRAWINGS-------------------------
-----------------------------------------------------]]--
function DrawMyArrow(from, to, color)
	DrawLineBorder3D(from.x, myHero.y, from.z, to.x, myHero.y, to.z, 2, color, 1)
end

function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
	radius = radius or 300
	quality = math.max(8, round(180 / math.deg((math.asin((chordlength / (2 * radius)))))))
	quality = 2 * math.pi / quality
	radius = radius * .92
    local points = {}
    for theta = 0, 2 * math.pi + quality, quality do
		local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
		points[#points + 1] = D3DXVECTOR2(c.x, c.y)
    end
	DrawLines2(points, width or 1, color or 4294967295)
end

function DrawCircle2(x, y, z, radius, color)
	local vPos1 = Vector(x, y, z)
	local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
	local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
	local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
	if OnScreen({x = sPos.x,y = sPos.y}, {x = sPos.x,y = sPos.y}) then
    	DrawCircleNextLvl(x, y, z, radius, 1, color, 75)
	end
end

function RGBColor(menu)
	return ARGB(menu[1], menu[2], menu[3], menu[4])
end
--[[-----------------------------------------------------
------------------------/DRAWINGS------------------------
-----------------------------------------------------]]--

--[[-----------------------------------------------------
---------------------PRINT MANAGER-----------------------
-----------------------------------------------------]]--
class("PrintManager")
function PrintManager:__init(scriptName)
	self.name = scriptName
	self.antiSpam = nil
end

function PrintManager:General(msg)
	if self.antiSpam == msg then return end
	self.antiSpam = msg
	print("<font color=\"#FF794C\"><b>" .. self.name .. "</b></font> <font color=\"#FFDFBF\"><b>" .. msg .. "</b></font>")
end

function PrintManager:Evade(msg)
	if self.antiSpam == msg then return end
	self.antiSpam = msg
	print("<font color=\"#FF794C\"><b>" .. self.name .. " - Evade</b></font> <font color=\"#FFDFBF\"><b>" .. msg .. "</b></font>")
end

_G.azBundle.PrintManager = PrintManager(_G.azBundle.ChampionData.scriptName)
--[[-----------------------------------------------------
----------------------/PRINT MANAGER---------------------
-----------------------------------------------------]]--

--[[-----------------------------------------------------
----------------------MENU MANAGER-----------------------
-----------------------------------------------------]]--
class("MenuManager")
function MenuManager:__init(scriptName)
	self.menu = scriptConfig("0" .. myHero.charName, " >> " .. scriptName .. " << ")
end
--[[-----------------------------------------------------
-----------------------/MENU MANAGER---------------------
-----------------------------------------------------]]--

--[[-----------------------------------------------------
--------------------TARGET SELECTOR----------------------
-----------------------------------------------------]]--
class("MyTarget")
function MyTarget:__init(champRange, minionRange, jungleRange, dmgType)
	self.range = {
		Champion = champRange,
		Minion = minionRange,
		Jungle = jungleRange
	}
	
	self.jungle = minionManager(MINION_JUNGLE, self.range.Jungle, myHero, MINION_SORT_MAXHEALTH_DEC)
	self.minion = minionManager(MINION_ENEMY, self.range.Minion, myHero, MINION_SORT_MAXHEALTH_DEC)
	self.champion = TargetSelector(TARGET_LESS_CAST_PRIORITY, self.range.Champion, dmgType, true)
end
--[[-----------------------------------------------------
---------------------/TARGET SELECTOR--------------------
-----------------------------------------------------]]--

--[[-----------------------------------------------------
---------------------EVADE MANAGER-----------------------
-----------------------------------------------------]]--
class("EvadeManager")
function EvadeManager:__init()
	self.dashSpell = {}
	
	self.evadeSkillShotQue = {}
	self.evadeSkillShotObjectQue = {}
	self.evadeCount = 1
	self.evadeDistanceMultiplicator = 1.25
	self.humanizerMultiplicator = 1
	self.dangerDamage = 0.6
	self.deltaTime = 0
	self.hasShownEvadeMessage = false
	
	if myHero.charName == "Irelia" then
		self.isUsing = true
	end
	
	self.ChampData = {
		["Aatrox"] = {
			Name = "Aatrox",
			SkillData = {
				["AatroxQ"] = {spellname = "AatroxE", spellSlot = "E", radius = 100, maxDistance = 1075, delay = 250, speed = 1200, shotType = "Line", projName = "AatroxBladeofTorment_mis.troy", canWall = true, canDash = true},
				["AatroxE"] = {spellname = "AatroxQ", spellSlot = "Q", radius = 145, maxDistance = 650, delay = 250, speed = 450, shotType = "Line", projName = "AatroxQ.troy", canWall = true, canDash = true}
			}
		},
		["Ahri"] = {
			Name = "Ahri",
			SkillData = {
				["AhriOrbofDeception"] = {spellname = "AhriOrbofDeception", spellSlot = "Q", radius = 100, maxDistance = 800, delay = 250, speed = 1750, shotType = "Line", projName = "Ahri_Orb_mis.troy", canWall = true, canDash = true},
				["AhriSeduce"] = {spellname = "Charm", spellSlot = "E", radius = 60, maxDistance = 1075, delay = 250, speed = 1600, shotType = "Line", projName = "AatroxQ.troy", single = true, canWall = true, canDash = true}
			}
		},
		["Amumu"] = {
			Name = "Amumu",
			SkillData = {
				["BandageToss"] = {spellname = "BandageToss", spellSlot = "Q", radius = 80, maxDistance = 1100, delay = 250, speed = 2000, shotType = "Line", projName = "Bandage_beam.troy", single = true, canWall = true, canDash = true}
			}
		},
		["Anivia"] = {
			Name = "Anivia",
			SkillData = {
				["FlashFrostSpell"] = {spellname = "FlashFrostSpell", spellSlot = "Q", radius = 110, maxDistance = 1100, delay = 250, speed = 850, shotType = "Line", projName = "cryo_FlashFrost_mis.troy", canWall = true, canDash = true},
				["Frostbite"] = {spellname = "Frostbite", spellSlot = "E", radius = 150, maxDistance = 700, delay = 250, speed = 1500, shotType = "Line", canWall = true, canDash = true}
			}
		},
		["Akali"] = {
			Name = "Akali",
			SkillData = {
				["AkaliQ"] = {spellname = "AkaliQ", spellSlot = "Q", radius = 0, maxDistance = 600, delay = 0, speed = 1000, shotType = "Line", canWall = true, canDash = false}
			}
		},
		["Ashe"] = {
			Name = "Ashe",
			SkillData = {
				["EnchantedCrystalArrow"] = {spellname = "EnchantedCrystalArrow", spellSlot = "Q", radius = 130, maxDistance = 25000, delay = 250, speed = 1600, projName = "EnchantedCrystalArrow_mis.troy", shotType = "Line", single = true, canWall = true, canDash = false},
				["Volley"] = {spellname = "Volley", spellSlot = "W", radius = 200, maxDistance = 1200, delay = 250, speed = 1850, projName = "EnchantedCrystalArrow_mis.troy", shotType = "Cone", single = true, canWall = true, canDash = false}
			}
		},
		["Annie"] = {
			Name = "Annie",
			SkillData = {
				["Disintegrate"] = {spellname = "Disintegrate", spellSlot = "Q", radius = 0, maxDistance = 625, delay = 0, speed = 0, shotType = "Line", canWall = true, canDash = true},
				["Incinerate"] = {spellname = "Incinerate", spellSlot = "W", radius = 200, maxDistance = 625, delay = 250, speed = 0, shotType = "Line", canWall = true, canDash = true},
				["InfernalGuardian"] = {spellname = "InfernalGuardian", spellSlot = "R", radius = 290, maxDistance = 625, delay = 0, speed = 0, shotType = "Circle", canWall = false, canDash = true}
			}
		},
		["Blitzcrank"] = {
			Name = "Blitzcrank",
			SkillData = {
				["RocketGrab"] = {spellname = "RocketGrabMissile", spellSlot = "Q", radius = 70, maxDistance = 1050, delay = 250, speed = 1800, shotType = "Line", projName = "FistGrab_mis.troy", single = true, canWall = true, canDash = true}
			}
		},
		["Brand"] = {
			Name = "Brand",
			SkillData = {
				["BrandBlaze"] = {spellname = "BrandBlaze", spellSlot = "Q", radius = 80, maxDistance = 900, delay = 250, speed = 1600, shotType = "Line", projName = "BrandBlaze_mis.troy", canWall = true, canDash = true},
				["BrandWildfire"] = {spellname = "BrandWildfire", spellSlot = "R", radius = 150, maxDistance = 1100, delay = 250, speed = 1000, shotType = "Line", projName = "BrandWildfire_mis.troy", canWall = true, canDash = false}
			}
		},
		["Caitlyn"] = {
			Name = "Caitlyn",
			SkillData = {
				["CaitlynPiltoverPeacemaker"] = {spellname = "CaitlynPiltoverPeacemaker", spellSlot = "Q", radius = 90, maxDistance = 1300, delay = 625, speed = 2200, shotType = "Line", projName = "caitlyn_Q_mis.troy", canWall = true, canDash = true},
				["CaitlynHeadshotMissile"] = {spellname = "CaitlynHeadshotMissile", spellSlot = "R", radius = 100, maxDistance = 3000, delay = 250, speed = 1000, shotType = "Line", single = true, projName = "caitlyn_ult_mis.troy", canWall = true, canDash = false}
			}
		},
		["Chogath"] = {
			Name = "Chogath",
			SkillData = {
				["Rupture"] = {spellname = "Rupture", spellSlot = "Q", radius = 125, maxDistance = 950, delay = 875, speed = 2200, shotType = "Circle", canWall = false, canDash = true}
			}
		},
		["Corki"] = {
			Name = "Corki",
			SkillData = {
				["PhosphorusBomb"] = {spellname = "PhosphorusBomb", spellSlot = "Q", radius = 250, maxDistance = 825, delay = 750, speed = 2000, shotType = "Circle", canWall = true, canDash = true},
				["GGun"] = {spellname = "GGun", spellSlot = "E", radius = 200, maxDistance = 600, delay = 750, speed = 2000, shotType = "Cone", canWall = true, canDash = true},
				["MissileBarrage"] = {spellname = "MissileBarrage", spellSlot = "R", radius = 40, maxDistance = 1300, delay = 250, speed = 2000, shotType = "Line", single = true, canWall = true, canDash = true},
				["MissileBarrageBig"] = {spellname = "MissileBarrageBig", spellSlot = "R", radius = 60, maxDistance = 1600, delay = 250, speed = 2000, shotType = "Line", single = true, canWall = true, canDash = true}
			}
		},
		["Cassiopeia"] = {
			Name = "Cassiopeia",
			SkillData = {
				["CassiopeiaNoxiousBlast"] = {spellname = "CassiopeiaNoxiousBlast", spellSlot = "Q", radius = 250, maxDistance = 850, delay = 250, speed = 500, shotType = "Circle", canWall = true, canDash = true}
			}
		},
		["Darius"] = {
			Name = "Darius",
			SkillData = {
				["DariusAxeGrabCone"] = {spellname = "DariusAxeGrabCone", spellSlot = "E", radius = 200, maxDistance = 570, delay = 320, speed = 2000, shotType = "Cone", canWall = true, canDash = true}
			}
		},
		["Diana"] = {
			Name = "Diana",
			SkillData = {
				["DianaArc"] = {spellname = "DianaArc", spellSlot = "Q", radius = 200, maxDistance = 830, delay = 250, speed = 2000, shotType = "Circle", canWall = true, canDash = true}
			}
		},
		["Draven"] = {
			Name = "Draven",
			SkillData = {
				["DravenDoubleShot"] = {spellname = "DravenDoubleShot", spellSlot = "E", radius = 130, maxDistance = 1100, delay = 250, speed = 1400, shotType = "Line", projName = "Draven_E_mis.troy", canWall = true, canDash = true},
				["DravenRCast"] = {spellname = "DravenDoubleShot", spellSlot = "R", radius = 160, maxDistance = 25000, delay = 500, speed = 1400, shotType = "Line", canWall = true, canDash = true}
			}
		},
		["Elise"] = {
			Name = "Elise",
			SkillData = {
				["EliseHumanE"] = {spellname = "EliseHumanE", spellSlot = "E", radius = 70, maxDistance = 1100, delay = 250, speed = 1450, shotType = "Line", projName = "Elise_human_E_mis.troy", canWall = true, canDash = true},
				["EliseHumanQ"] = {spellname = "EliseHumanQ", spellSlot = "Q", radius = 80, maxDistance = 625, delay = 250, speed = 1600, shotType = "Line", canWall = true, canDash = true},
				["EliseHumanW"] = {spellname = "EliseHumanW", spellSlot = "W", radius = 100, maxDistance = 950, delay = 250, speed = 1450, shotType = "Line", canWall = true, canDash = true}
			}
		},
		["Ezreal"] = {
			Name = "Ezreal",
			SkillData = {
				["EzrealMysticShot"] = {spellname = "EzrealMysticShot", spellSlot = "Q", radius = 80, maxDistance = 1100, delay = 250, speed = 2000, shotType = "Line", projName = "Ezreal_mysticshot_mis.troy", canWall = true, canDash = true},
				["EzrealEssenceFlux"] = {spellname = "EzrealEssenceFlux", spellSlot = "W", radius = 80, maxDistance = 900, delay = 250, speed = 1500, shotType = "Line", projName = "Ezreal_essenceflux_mis.troy", canWall = true, canDash = true},
				["EzrealTrueshotBarrage"] = {spellname = "EzrealTrueshotBarrage", spellSlot = "R", radius = 160, maxDistance = 20000, delay = 1000, speed = 2000, projName = "Ezreal_TrueShot_mis.troy", shotType = "Line", canWall = true, canDash = true}
			}
		},
		["Heimerdinger"] = {
			Name = "Heimerdinger",
			SkillData = {
				["HextechMicroRockets"] = {spellname = "HextechMicroRockets", spellSlot = "W", radius = 80, maxDistance = 1100, delay = 250, speed = 1200, shotType = "Line", single = true, canWall = true, canDash = true},
				["CH-2ElectronStormGrenade"] = {spellname = "CH-2ElectronStormGrenade", spellSlot = "E", radius = 80, maxDistance = 925, delay = 250, speed = 1750, shotType = "Line", canWall = true, canDash = true}
			}
		},
		["FiddleSticks"] = {
			Name = "FiddleSticks",
			SkillData = {
				["DarkWind"] = {spellname = "DarkWind", spellSlot = "E", radius = 0, maxDistance = 750, delay = 0, speed = 1500, shotType = "Line", single = true, canWall = true, canDash = true}
			}
		},
		["Fizz"] = {
			Name = "Fizz",
			SkillData = {
				["FizzMarinerDoom"] = {spellname = "FizzMarinerDoom", spellSlot = "R", radius = 80, maxDistance = 1275, delay = 0, speed = 1350, shotType = "Line", projName = "Fizz_UltimateMissile.troy", single = true, canWall = true, canDash = true}
			}
		},
		["Galio"] = {
			Name = "Galio",
			SkillData = {
				["GalioResoluteSmite"] = {spellname = "GalioResoluteSmite", spellSlot = "Q", radius = 200, maxDistance = 2000, delay = 250, speed = 850, shotType = "Line", projName = "galio_concussiveBlast_mis.troy", single = true, canWall = true, canDash = true}
			}
		},
		["Gragas"] = {
			Name = "Gragas",
			SkillData = {
				["GragasBarrelRoll"] = {spellname = "GragasBarrelRoll", spellSlot = "Q", radius = 100, maxDistance = 950, delay = 250, speed = 1000, shotType = "Line", projName = "gragas_barrelroll_mis.troy", single = true, canWall = true, canDash = true}
			}
		},
		["Graves"] = {
			Name = "Graves",
			SkillData = {
				["GravesClusterShot"] = {spellname = "GravesClusterShot", spellSlot = "Q", radius = 60, maxDistance = 900, delay = 250, speed = 1750, shotType = "Line", projName = "Graves_ClusterShot_mis.troy", canWall = true, canDash = true},
				["GravesChargeShot"] = {spellname = "GravesChargeShot", spellSlot = "R", radius = 100, maxDistance = 1000, delay = 250, speed = 1500, shotType = "Line", projName = "Graves_ChargedShot_mis.troy", canWall = true, canDash = true}
			}
		},
		["Irelia"] = {
			Name = "Irelia",
			SkillData = {
				["IreliaTranscendentBlades"] = {spellname = "IreliaTranscendentBlades", spellSlot = "R", radius = 120, maxDistance = 1200, delay = 250, speed = 1600, shotType = "Line", projName = "Irelia_ult_dagger_mis.troy", canWall = true, canDash = true}
			}
		},
		["Janna"] = {
			Name = "Janna",
			SkillData = {
				["HowlingGale"] = {spellname = "HowlingGale", spellSlot = "Q", radius = 150, maxDistance = 1100, delay = 250, speed = 1600, shotType = "Line", projName = "HowlingGale_mis.troy", canWall = true, canDash = true}
			}
		},
		["Jayce"] = {
			Name = "Jayce",
			SkillData = {
				["JayceToTheSkies"] = {spellname = "JayceToTheSkies", spellSlot = "Q", radius = 150, maxDistance = 600, delay = 250, speed = 2500, shotType = "Line", canWall = true, canDash = true},
				["JayceShockBlast"] = {spellname = "JayceShockBlast", spellSlot = "Q", radius = 70, maxDistance = 1050, delay = 250, speed = 1450, shotType = "Line", projName = "JayceOrbLightning.troy", canWall = true, canDash = true},
			}
		},
		["Jinx"] = {
			Name = "Jinx",
			SkillData = {
				["JinxWMissile"] = {spellname = "JinxWMissile", spellSlot = "W", radius = 70, maxDistance = 1450, speed = 3300, delay = 600, shotType = "Line", single = true, canWall = true, canDash = true},
				["JinxRWrapper"] = {spellname = "JinxRWrapper", spellSlot = "R", radius = 120, maxDistance = 20000, speed = 2200, delay = 600, single = true, shotType = "Line", canWall = true, canDash = true}
			}
		},
		["Karthus"] = {
			Name = "Karthus",
			SkillData = {
				["LayWaste"] = {spellname = "LayWaste", spellSlot = "Q", radius = 140, maxDistance = 875, speed = 1000, delay = 750, projName = "LayWaste_point.troy", shotType = "Line", single = true, canWall = true, canDash = true}
			}
		},
		["Karma"] = {
			Name = "Karma",
			SkillData = {
				["KarmaQ"] = {spellname = "KarmaQ", spellSlot = "Q", radius = 90, maxDistance = 950, speed = 1700, delay = 250, shotType = "Line", canWall = true, canDash = true}
			}
		},
		["Kassadin"] = {
			Name = "Kassadin",
			SkillData = {
				["NullSphere"] = {spellname = "NullSphere", spellSlot = "Q", radius = 0, maxDistance = 650, speed = 0, delay = 250, shotType = "Line", canWall = true, canDash = false},
				["ForcePulse"] = {spellname = "ForcePulse", spellSlot = "E", radius = 200, maxDistance = 700, speed = 0, delay = 250, shotType = "Cone", canWall = false, canDash = false}
			}
		},
		["Katarina"] = {
			Name = "Katarina",
			SkillData = {
				["KatarinaR"] = {spellname = "KatarinaR", spellSlot = "R", radius = 0, maxDistance = 550, speed = 0, delay = 250, shotType = "Line", canWall = true, canDash = true},
				["KatarinaQ"] = {spellname = "KatarinaQ", spellSlot = "Q", radius = 0, maxDistance = 675, speed = 0, delay = 250, shotType = "Line", canWall = true, canDash = false}
			}
		},
		["Kennen"] = {
			Name = "Kennen",
			SkillData = {
				["KennenShurikenHurlMissile1"] = {spellname = "KennenShurikenHurlMissile1", spellSlot = "Q", radius = 50, maxDistance = 1050, speed = 1700, delay = 180, shotType = "Line", canWall = true, canDash = true}
			}
		},
		["Khazix"] = {
			Name = "Khazix",
			SkillData = {
				["KhazixQ"] = {spellname = "KhazixQ", spellSlot = "Q", radius = 0, maxDistance = 375, speed = 0, delay = 250, shotType = "Line", canWall = true, canDash = true},
				["KhazixW"] = {spellname = "KhazixW", spellSlot = "W", radius = 0, maxDistance = 375, speed = 1700, delay = 250, shotType = "Line", canWall = true, canDash = true}
			}
		},
		["KogMaw"] = {
			Name = "KogMaw",
			SkillData = {
				["CausticSpittle"] = {spellname = "CausticSpittle", spellSlot = "Q", radius = 45, maxDistance = 625, speed = 0, delay = 250, shotType = "Line", canWall = true, canDash = true},
				["KogMawVoidOozeMissile"] = {spellname = "KogMawVoidOozeMissile", spellSlot = "E", radius = 100, maxDistance = 1200, speed = 1450, delay = 250, shotType = "Line", canWall = true, canDash = true},
				["KogMawLivingArtillery"] = {spellname = "KogMawVoidOozeMissile", spellSlot = "R", radius = 100, maxDistance = 2200, speed = 0, delay = 850, shotType = "Circle", canWall = false, canDash = true}
			}
		},
		["LeeSin"] = {
			Name = "LeeSin",
			SkillData = {
				["BlindMonkQOne"] = {spellname = "BlindMonkQOne", spellSlot = "Q", radius = 70, maxDistance = 975, speed = 1800, delay = 250, shotType = "Line", single = true, canWall = true, canDash = true}
			}
		},
		["Leona"] = {
			Name = "Leona",
			SkillData = {
				["LeonaZenithBlade"] = {spellname = "LeonaZenithBlade", spellSlot = "E", radius = 80, maxDistance = 900, speed = 2000, delay = 250, shotType = "Line", canWall = false, canDash = true},
				["LeonaSolarFlare"] = {spellname = "LeonaSolarFlare", spellSlot = "R", radius = 300, maxDistance = 1200, speed = 2000, delay = 250, shotType = "Circle", canWall = false, canDash = true}
			}
		},
		["Lissandra"] = {
			Name = "Lissandra",
			SkillData = {
				["LissandraQ"] = {spellname = "LissandraQ", spellSlot = "Q", radius = 75, maxDistance = 725, speed = 1400, delay = 250, shotType = "Line", canWall = true, canDash = true},
				["LissandraE"] = {spellname = "LissandraE", spellSlot = "E", radius = 140, maxDistance = 1500, speed = 850, delay = 250, shotType = "Line", canWall = false, canDash = false}
			}
		},
		["Lissandra"] = {
			Name = "Lissandra",
			SkillData = {
				["LissandraQ"] = {spellname = "LissandraQ", spellSlot = "Q", radius = 75, maxDistance = 725, speed = 1400, delay = 250, shotType = "Line", aoE = true, canWall = true, canDash = true},
				["LissandraE"] = {spellname = "LissandraE", spellSlot = "E", radius = 140, maxDistance = 1500, speed = 850, delay = 250, shotType = "Line", aoE = true, canWall = false, canDash = false}
			}
		},
		["Lucian"] = {
			Name = "Lucian",
			SkillData = {
				["LucianQ"] = {spellname = "LucianQ", spellSlot = "Q", radius = 65, maxDistance = 570, speed = 0, delay = 350, shotType = "Line", canWall = true, canDash = false},
				["LucianW"] = {spellname = "LucianW", spellSlot = "W", radius = 80, maxDistance = 1000, speed = 1600, delay = 300, shotType = "Line", canWall = false, canDash = true}
			}
		},
		["Lux"] = {
			Name = "Lux",
			SkillData = {
				["LuxLightBinding"] = {spellname = "LuxLightBinding", spellSlot = "Q", radius = 80, maxDistance = 1175, delay = 250, speed = 1200, shotType = "Line", targets = 2, canWall = true, canDash = true},
				["LuxLightStrikeKugel"] = {spellname = "LuxLightStrikeKugel", spellSlot = "E", radius = 275, maxDistance = 1175, delay = 250, speed = 1400, shotType = "Circle", aoE = true, canWall = true, canDash = true},
				["LuxMaliceCannon"] = {spellname = "LuxMaliceCannon", spellSlot = "R", radius = 200, maxDistance = 3500, shotType = "Line", aoE = true, canWall = false, canDash = true}
			}
		},
		["Maokai"] = {
			Name = "Maokai",
			SkillData = {
				["MaokaiTrunkLine"] = {spellname = "MaokaiTrunkLine", spellSlot = "Q", radius = 110, maxDistance = 600, speed = 1200, delay = 350, shotType = "Line", single = true, canWall = true, canDash = true}
			}
		},
		["Morgana"] = {
			Name = "Morgana",
			SkillData = {
				["DarkBindingMissile"] = {spellname = "DarkBindingMissile", spellSlot = "Q", radius = 80, maxDistance = 1300, speed = 1200, delay = 250, projName = "DarkBinding_mis.troy", shotType = "Line", single = true, canWall = true, canDash = true},
				["TormentedSoil"] = {spellname = "TormentedSoil", spellSlot = "W", radius = 175, maxDistance = 975, speed = 0, delay = 250, shotType = "Circle", aoE = true, canWall = false, canDash = true}
			}
		},
		["DrMundo"] = {
			Name = "DrMundo",
			SkillData = {
				["InfectedCleaverMissile"] = {spellname = "InfectedCleaverMissile", spellSlot = "Q", radius = 75, maxDistance = 1000, speed = 2000, delay = 250, shotType = "Line", single = true, canWall = true, canDash = true}
			}
		},
		["Nami"] = {
			Name = "Nami",
			SkillData = {
				["NamiQ"] = {spellname = "NamiQ", spellSlot = "Q", radius = 100, maxDistance = 875, speed = 0, delay = 850, shotType = "Circle", projName = "Nami_Q_mis.troy", canWall = true, canDash = true}
			}
		},
		["Nasus"] = {
			Name = "Nasus",
			SkillData = {
				["NasusE"] = {spellname = "NasusE", spellSlot = "E", radius = 400, maxDistance = 650, speed = 0, delay = 200, shotType = "Circle", canWall = false, canDash = true}
			}
		},
		["Nautilus"] = {
			Name = "Nautilus",
			SkillData = {
				["NautilusAnchorDrag"] = {spellname = "NautilusAnchorDrag", spellSlot = "Q", radius = 80, maxDistance = 1080, speed = 2000, delay = 200, shotType = "Line", single = true, canWall = true, canDash = true}
			}
		},
		["Nidalee"] = {
			Name = "Nidalee",
			SkillData = {
				["JavelinToss"] = {spellname = "JavelinToss", spellSlot = "Q", radius = 60, maxDistance = 1500, speed = 1300, delay = 125, shotType = "Line", single = true, canWall = true, canDash = true}
			}
		},
		["Nocturne"] = {
			Name = "Nocturne",
			SkillData = {
				["NocturneDuskbringer"] = {spellname = "NocturneDuskbringer", spellSlot = "Q", radius = 60, maxDistance = 1200, speed = 1400, delay = 250, projName = "NocturneDuskbringer_mis.troy", shotType = "Line", canWall = true, canDash = true}
			}
		},
		["Olaf"] = {
			Name = "Olaf",
			SkillData = {
				["OlafAxeThrow"] = {spellname = "OlafAxeThrow", spellSlot = "Q", radius = 90, maxDistance = 1000, speed = 1600, delay = 250, projName = "olaf_axe_mis.troy", shotType = "Line", canWall = true, canDash = true}
			}
		},
		["Orianna"] = {
			Name = "Orianna",
			SkillData = {
				["OrianaIzunaCommand"] = {spellname = "OrianaIzunaCommand", spellSlot = "Q", radius = 80, maxDistance = 825, speed = 1200, delay = 250, shotType = "Line", canWall = true, canDash = true}
			}
		},
		["Pantheon"] = {
			Name = "Pantheon",
			SkillData = {
				["SpearShot"] = {spellname = "SpearShot", spellSlot = "Q", radius = 0, maxDistance = 600, speed = 1200, delay = 250, shotType = "Line", canWall = true, canDash = false},
				["Pantheon_Heartseeker"] = {spellname = "SpearShot", spellSlot = "Q", radius = 200, maxDistance = 600, speed = 2000, delay = 250, shotType = "Line", canWall = true, canDash = true}
			}
		},
		["Quinn"] = {
			Name = "Quinn",
			SkillData = {
				["QuinnQ"] = {spellname = "QuinnQ", spellSlot = "Q", radius = 80, maxDistance = 1050, speed = 1550, delay = 250, shotType = "Line", single = true, projName = "Quinn_Q_missile.troy", canWall = true, canDash = true}
			}
		},
		["Rumble"] = {
			Name = "Rumble",
			SkillData = {
				["RumbleGrenade"] = {spellname = "RumbleGrenade", spellSlot = "E", radius = 90, maxDistance = 800, speed = 2000, delay = 250, shotType = "Line", canWall = true, canDash = true},
				["Flamespitter"] = {spellname = "Flamespitter", spellSlot = "Q", radius = 90, maxDistance = 650, speed = 0, delay = 250, shotType = "Cone", canWall = true, canDash = true}
			}
		},
		["Ryze"] = {
			Name = "Ryze",
			SkillData = {
				["RyzeQ"] = {spellname = "RyzeQ", spellSlot = "Q", radius = 50, maxDistance = 900, shotType = "Line", canWall = true, canDash = true}
			}
		},
		["Zyra"] = {
			Name = "Zyra",
			SkillData = {
				["ZyraGraspingRoots"] = {spellname = "ZyraGraspingRoots", spellSlot = "E", radius = 70, maxDistance = 1150, speed = 1150, delay = 250, shotType = "Line", canWall = true, canDash = true}
			}
		},
		["TwistedFate"] = {
			Name = "TwistedFate",
			SkillData = {
				["WildCards"] = {spellname = "WildCards", spellSlot = "E", radius = 40, maxDistance = 1450, speed = 1000, delay = 250, shotType = "Line", canWall = true, canDash = true}
			}
		},
		["Swain"] = {
			Name = "Swain",
			SkillData = {
				["SwainShadowGrasp"] = {spellname = "SwainShadowGrasp", spellSlot = "E", radius = 180, maxDistance = 900, speed = 1000, delay = 250, shotType = "Circle", canWall = false, canDash = true}
			}
		},
		["Sivir"] = {
			Name = "Sivir",
			SkillData = {
				["SivirQ"] = {spellname = "SivirQ", spellSlot = "E", radius = 101, maxDistance = 1175, speed = 1350, delay = 250, shotType = "Line", canWall = true, canDash = true}
			}
		},
		["Zed"] = {
			Name = "Zed",
			SkillData = {
				["ZedShuriken"] = {spellname = "ZedShuriken", spellSlot = "Q", radius = 50, maxDistance = 925, speed = 1700, delay = 250, shotType = "Line", canWall = true, canDash = true}
			}
		},
		["Leblanc"] = {
			Name = "Leblanc",
			SkillData = {
				["LeblancSoulShackle"] = {spellname = "LeblancSoulShackle", spellSlot = "Q", radius = 70, maxDistance = 960, speed = 1600, delay = 250, shotType = "Line", canWall = true, canDash = true},
				["LeblancSoulShackleM"] = {spellname = "LeblancSoulShackleM", spellSlot = "Q", radius = 70, maxDistance = 960, speed = 1600, delay = 250, shotType = "Line", canWall = true, canDash = true}
			}
		},
		["Lulu"] = {
			Name = "Lulu",
			SkillData = {
				["LuluQ"] = {spellname = "LuluQ", spellSlot = "Q", radius = 50, maxDistance = 1000, speed = 1450, delay = 250, shotType = "Line", canWall = true, canDash = true}
			}
		},
		["Thresh"] = {
			Name = "Thresh",
			SkillData = {
				["ThreshQ"] = {spellname = "ThreshQ", spellSlot = "Q", radius = 65, maxDistance = 1100, speed = 1900, delay = 500, shotType = "Line", canWall = true, canDash = true}
			}
		},
		["Shen"] = {
			Name = "Shen",
			SkillData = {
				["ShenShadowDash"] = {spellname = "ShenShadowDash", spellSlot = "Q", radius = 50, maxDistance = 575, speed = 3000, delay = 0, shotType = "Line", canWall = false, canDash = true}
			}
		},
		["Varus"] = {
			Name = "Varus",
			SkillData = {
				["VarusQ"] = {spellname = "VarusQ", spellSlot = "Q", radius = 70, maxDistance = 1600, speed = 1900, delay = 0, shotType = "Line", canWall = true, canDash = true},
				["VarusE"] = {spellname = "VarusE", spellSlot = "E", radius = 275, maxDistance = 925, speed = 1500, delay = 250, shotType = "Circle", canWall = false, canDash = true},
				["VarusR"] = {spellname = "VarusR", spellSlot = "R", radius = 100, maxDistance = 1250, speed = 1950, delay = 250, shotType = "Line", canWall = true, canDash = true}
			}
		},
		["Xerath"] = {
			Name = "Xerath",
			SkillData = {
				["XerathArcanopulse"] = {spellname = "XerathArcanopulse", spellSlot = "Q", radius = 100, maxDistance = 1025, speed = math.huge, delay = 1375, shotType = "Line", canWall = true, canDash = true},
				["xeratharcanopulseextended"] = {spellname = "xeratharcanopulseextended", spellSlot = "Q", radius = 100, maxDistance = 1625, speed = math.huge, delay = 1375, shotType = "Line", canWall = true, canDash = true},
				["VarusR"] = {spellname = "VarusR", spellSlot = "R", radius = 100, maxDistance = 1250, speed = 1950, delay = 250, shotType = "Line", canWall = true, canDash = true}
			}
		},
		["Viktor"] = {
			Name = "Viktor",
			SkillData = {
				["ViktorDeathRay"] = {spellname = "ViktorDeathRay", spellSlot = "Q", radius = 80, maxDistance = 700, speed = 780, delay = 500, shotType = "Line", canWall = true, canDash = true}
			}
		},
		["Ziggs"] = {
			Name = "Ziggs",
			SkillData = {
				["ZiggsQ"] = {spellname = "ZiggsQ", spellSlot = "Q", radius = 155, maxDistance = 2000, speed = 3000, delay = 250, shotType = "Line", canWall = true, canDash = true},
				["ZiggsW"] = {spellname = "ZiggsW", spellSlot = "W", radius = 210, maxDistance = 2000, speed = 3000, delay = 250, shotType = "Circle", canWall = false, canDash = true},
				["ZiggsE"] = {spellname = "ZiggsE", spellSlot = "E", radius = 235, maxDistance = 2000, speed = 3000, delay = 250, shotType = "Circle", canWall = false, canDash = true}
			}
		},
		["Bard"] = {
			Name = "Bard",
			SkillData = {
				["BardQ"] = {spellname = "BardQ", spellSlot = "Q", radius = 60, maxDistance = 950, shotType = "Line", canWall = true, canDash = true}
			}
		},
		["Veigar"] = {
			Name = "Veigar",
			SkillData = {
				["VeigarBalefulStrike"] = {spellname = "VeigarBalefulStrike", spellSlot = "Q", radius = 70, maxDistance = 950, shotType = "Line", canWall = true, canDash = true},
				["VeigarDarkMatter"] = {spellname = "VeigarDarkMatter", spellSlot = "W", radius = 225, maxDistance = 900, delay = 250, shotType = "Line", canWall = false, canDash = true}
			}
		}
	}

end

function EvadeManager:AddDashSpell(spell, spellFriendly, castType, info, target, prefKill)
	if spell and castType and range and delay then
		self.dashSpell = {
			slot = spell,
			pretty = spellFriendly,
			type = castType,
			spellInfo = info,
			targetType = "enemy",
			preferKill = prefKill
		}
	end
	
	_G.azBundle.PrintManager:General("Added dash spell [" .. spellFriendly .. "].")
	
	
end

function EvadeManager:OnDeleteObj(object)
	if not self.isUsing then return end
	if object == nil or object.spellName == nil or object.spellName == "" or object.spellName:find("ChaosMinion") or object.spellName:find("Turret_Order") or object.spellName:find("OrderMinion") or self.evadeCount <= 1 then return end
	for i, skillshot in pairs(self.evadeSkillShotQue) do
		if object.spellName:find(skillshot.spellname) then
			self.evadeSkillShotQue[i] = nil
			self.evadeSkillShotObjectQue[i] = nil
			self.evadeCount = self.evadeCount - 1
			return
		end
	end
end

function EvadeManager:AutoExpireEvades()
	if not self.isUsing then return end
	if self.evadeCount <= 1 then return end
	for i, skillshot in pairs(self.evadeSkillShotObjectQue) do
		if skillshot.when + (3600 * 2) < os.clock() then
			print("Removing [" .. self.evadeSkillShotQue[i].spellname .. "] from Que.")
			self.evadeSkillShotQue[i] = nil
			self.evadeSkillShotObjectQue[i] = nil
			self.evadeCount = self.evadeCount - 1
		end
	end
end

function EvadeManager:EvadeTick()
	if self.evadeCount <= 1 then return end
	if self.deltaTime == 0 then
		self.deltaTime = GetTickCount()
	end
	if GetTickCount() == self.deltaTime * ( self.humanizerMultiplicator * 1000 ) then
		for i, spell in pairs(self.evadeSkillShotQue) do
			if spell.shotType == "Line" then
				print("Evading " .. spell.spellname)
				EvadeLineShot(self.evadeSkillShotQue[i], self.evadeSkillShotObjectQue[i])
				self.deltaTime = 0
				return
			end
		end
	end
end

function EvadeManager:DashHandler(unit,spell)
	print("checking spell " .. spell.name)
	if not self.isUsing then return end
	local selectedDash = nil
	if myHero.charName == "Irelia" then
		selectedDash = {
			slot = _Q,
			pretty = "Q",
			type = "target",
			spellInfo = _G.azBundle.ChampionData.SkillQ,
			targetType = "enemy",
			preferKill = true
		}
	else
		return
	end
	
	if (_G.DancingShoes_Loaded and _G.Evade) or (_G.AE and _G.AE_isEvading) then
		if self.hasShownEvadeMessage == false then
			_G.azBundle.PrintManager:Evade("Disabling internal evade due to external evade script.")
			self.hasShownEvadeMessage = true
		end
	end
	if unit.team ~= myHero.team and not myHero.dead and not (unit.type == "obj_AI_Minion" and unit.type == "obj_AI_Turret") and unit.type == ("AIHeroClient" or myHero.type) then
		skillShotData = nil
		if self.ChampData[unit.charName] ~= nil and self.ChampData[unit.charName].SkillData[spell.name] ~= nil then
			skillShotData = self.ChampData[unit.charName].SkillData[spell.name]
		end
		print("found data for " .. spell.name)
		if skillShotData and ((_G.Evadeee_Enabled and _G.Evadeee_Loaded and _G.Evadeee_impossibleToEvade) or not _G.Evadeee_Enabled) then --and mainMenu.Evade[unit.charName .. skillShotData.spellSlot].dash then
			self.evadeSkillShotQue[self.evadeCount] = skillShotData
			self.evadeSkillShotObjectQue[self.evadeCount] = {name = skillShotData.spellname, startPos = Vector(spell.startPos), endPos = Vector(spell.endPos), when = os.clock()}
			self.evadeCount = self.evadeCount + 1
			print("1")
			for i=1, heroManager.iCount do
				print("2")
				local allytarget = heroManager:GetHero(i)
				if allytarget.isMe then
					print("2")
					local allyHitBox = allytarget.boundingRadius or 65
					local whoWillGetHit = false
					print("3")
					if skillShotData.shotType == "Line" and single then
						whoWillGetHit = checkhitlinepoint(unit, spell.endPos, skillShotData.radius, skillShotData.maxDistance, allytarget, allyHitBox)
					elseif skillShotData.shotType == "Line" then
						whoWillGetHit = checkhitlinepass(unit, spell.endPos, skillShotData.radius, skillShotData.maxDistance, allytarget, allyHitBox)
					elseif skillShotData.shotType == "AoE" then
						whoWillGetHit = checkhitaoe(unit, spell.endPos, skillShotData.radius, skillShotData.maxDistance, allytarget, allyHitBox)
					elseif skillShotData.shotType == "Cone" then
						whoWillGetHit = checkhitcone(unit, spell.endPos, skillShotData.radius, skillShotData.maxDistance, allytarget, allyHitBox)
					elseif skillShotData.shotType == "Wall" then
						whoWillGetHit = checkhitwall(unit, spell.endPos, skillShotData.radius, skillShotData.maxDistance, allytarget, allyHitBox)
					elseif skillShotData.shotType == "AdvLine" then
						whoWillGetHit = checkhitlinepass(unit, spell.endPos, skillShotData.radius, skillShotData.maxDistance, allytarget, allyHitBox) or checkhitlinepass(unit, Vector(unit)*2-spell.endPos, skillShotData.radius, skillShotData.maxDistance, allytarget, allyHitBox)
					end
					print("4")
					if whoWillGetHit then
						_G.azBundle.PrintManager:Evade("Detected [" .. allytarget.charName .. "] will get hit by [" .. spell.name .. "].")
						if allytarget.isMe then
							if skillShotData.canDash then -- and mainMenu.Evade[unit.charName .. skillShotData.spellSlot].dash then
								
								if selectedDash.type == "target" and selectedDash.targetType == "enemy" and selectedDash.preferKill then
									print("d1")
									local bestDashTarget = nil
									for eI, enemyI in pairs(GetEnemyHeroes()) do
										if enemyI and ValidTarget(enemyI, selectedDash.spellInfo.range) then -- and enemyI.health < selectedDash.spellInfo:Damage(myHero, enemyI) and not UnderTurret(enemyI.pos) then
											local stillGetHit = nil
											if skillShotData.shotType == "Line" then
												if single then
													stillGetHit = checkhitlinepoint(unit, spell.endPos, skillShotData.radius, skillShotData.maxDistance, enemyI.pos, myHero.boundingRadius)
												else
													stillGetHit = checkhitlinepass(unit, spell.endPos, skillShotData.radius, skillShotData.maxDistance, enemyI.pos, myHero.boundingRadius)
												end
											elseif skillShotData.shotType == "AoE" then
												stillGetHit = checkhitaoe(unit, spell.endPos, skillShotData.radius, skillShotData.maxDistance, enemyI.pos, myHero.boundingRadius)
											elseif skillShotData.shotType == "Cone" then
												stillGetHit = checkhitcone(unit, spell.endPos, skillShotData.radius, skillShotData.maxDistance, enemyI.pos, myHero.boundingRadius)
											elseif skillShotData.shotType == "Wall" then
												stillGetHit = checkhitwall(unit, spell.endPos, skillShotData.radius, skillShotData.maxDistance, enemyI.pos, myHero.boundingRadius)
											elseif skillShotData.shotType == "AdvLine" then
												stillGetHit = checkhitwall(unit, spell.endPos, skillShotData.radius, skillShotData.maxDistance, enemyI.pos, myHero.boundingRadius) or checkhitlinepass(unit, Vector(unit)*2-spell.endPos, skillShotData.radius, skillShotData.maxDistance, enemyI.pos, myHero.boundingRadius)
											end
											
											if stillGetHit then 
												bestDashTarget = enemyI
												break
											end
										end
									end
									if not bestDashTarget then
										for mI, minionI in pairs(_G.azBundle.Champion.target.minion.objects) do
											if minionI and ValidTarget(minionI, selectedDash.spellInfo.range) and minionI.health < selectedDash.spellInfo:Damage(myHero, minionI) then
												local stillGetHit = nil
												if skillShotData.shotType == "Line" then
													if single then
														stillGetHit = checkhitlinepoint(unit, spell.endPos, skillShotData.radius, skillShotData.maxDistance, minionI.pos, myHero.boundingRadius)
													else
														stillGetHit = checkhitlinepass(unit, spell.endPos, skillShotData.radius, skillShotData.maxDistance, minionI.pos, myHero.boundingRadius)
													end
												elseif skillShotData.shotType == "AoE" then
													stillGetHit = checkhitaoe(unit, spell.endPos, skillShotData.radius, skillShotData.maxDistance, minionI.pos, myHero.boundingRadius)
												elseif skillShotData.shotType == "Cone" then
													stillGetHit = checkhitcone(unit, spell.endPos, skillShotData.radius, skillShotData.maxDistance, minionI.pos, myHero.boundingRadius)
												elseif skillShotData.shotType == "Wall" then
													stillGetHit = checkhitwall(unit, spell.endPos, skillShotData.radius, skillShotData.maxDistance, minionI.pos, myHero.boundingRadius)
												elseif skillShotData.shotType == "AdvLine" then
													stillGetHit = checkhitwall(unit, spell.endPos, skillShotData.radius, skillShotData.maxDistance, minionI.pos, myHero.boundingRadius) or checkhitlinepass(unit, Vector(unit)*2-spell.endPos, skillShotData.radius, skillShotData.maxDistance, minionI.pos, myHero.boundingRadius)
												end
												
												if stillGetHit then 
													bestDashTarget = minionI
													break
												end
											end
										end
									end
									if not bestDashTarget then
										for jI, jungleI in pairs(_G.azBundle.Champion.target.jungle.objects) do
											if minionI and ValidTarget(jungleI, selectedDash.spellInfo.range) and jungleI.health < selectedDash.spellInfo:Damage(myHero, jungleI) then
												local stillGetHit = nil
												if skillShotData.shotType == "Line" then
													if single then
														stillGetHit = checkhitlinepoint(unit, spell.endPos, skillShotData.radius, skillShotData.maxDistance, jungleI.pos, myHero.boundingRadius)
													else
														stillGetHit = checkhitlinepass(unit, spell.endPos, skillShotData.radius, skillShotData.maxDistance, jungleI.pos, myHero.boundingRadius)
													end
												elseif skillShotData.shotType == "AoE" then
													stillGetHit = checkhitaoe(unit, spell.endPos, skillShotData.radius, skillShotData.maxDistance, jungleI.pos, myHero.boundingRadius)
												elseif skillShotData.shotType == "Cone" then
													stillGetHit = checkhitcone(unit, spell.endPos, skillShotData.radius, skillShotData.maxDistance, jungleI.pos, myHero.boundingRadius)
												elseif skillShotData.shotType == "Wall" then
													stillGetHit = checkhitwall(unit, spell.endPos, skillShotData.radius, skillShotData.maxDistance, jungleI.pos, myHero.boundingRadius)
												elseif skillShotData.shotType == "AdvLine" then
													stillGetHit = checkhitwall(unit, spell.endPos, skillShotData.radius, skillShotData.maxDistance, jungleI.pos, myHero.boundingRadius) or checkhitlinepass(unit, Vector(unit)*2-spell.endPos, skillShotData.radius, skillShotData.maxDistance, jungleI.pos, myHero.boundingRadius)
												end
												
												if stillGetHit then 
													bestDashTarget = jungleI
													break
												end
											end
										end
									end
									if bestDashTarget then
										CastSpell(selectedDash.slot, bestDashTarget)
										_G.azBundle.PrintManager:Evade("Dashing to [" .. bestDashTarget.charName .. "] to avoid [" .. self.ChampData[unit.charName].Name .. " " .. skillShotData.spellSlot .. "].")
										return
									end
								end
							end
							_G.azBundle.PrintManager:Evade("Unable to avoid [" .. self.ChampData[unit.charName].Name .. " " .. skillShotData.spellSlot .. "].")
						end
					end
				end
			end
		end
	end
end

function EvadeManager:EvadeDraw()
	if not self.isUsing then return end
	for i, skillshot in pairs(self.evadeSkillShotObjectQue) do
		if self.evadeSkillShotObjectQue[i] ~= nil and self.evadeSkillShotQue[i] ~= nil then
			if(self.evadeSkillShotQue[i].shotType == "Circle") then
			   DrawCircle3D(skillshot.endPos.x,skillshot.endPos.y,skillshot.endPos.z)
			elseif self.evadeSkillShotQue[i].shotType == "Line" then
				DrawLineBorder3D(skillshot.startPos.x, skillshot.startPos.y, skillshot.startPos.z, skillshot.endPos.x, skillshot.endPos.y, skillshot.endPos.z, self.evadeSkillShotQue[i].radius * 2, ARGB(255,255,255,255), 1)
			end
		end
	end
end

--[[-----------------------------------------------------
----------------------/EVADE MANAGER---------------------
-----------------------------------------------------]]--

--[[-----------------------------------------------------
----------------------UNIT CHECKS------------------------
-----------------------------------------------------]]--
class("UnitChecks")
function UnitChecks:__init()
	
end

--[[-----------------------------------------------------
---------------------/UNIT CHECKS-----------------------
-----------------------------------------------------]]--

--[[-----------------------------------------------------
-----------------------AWARE-----------------------------
-----------------------------------------------------]]--
class("AwareManager")
function AwareManager:__init()
	_G.azBundle.MenuManager.menu:addSubMenu(">> Awareness Settings <<", "Aware")
		
		_G.azBundle.MenuManager.menu.Aware:addSubMenu(">> Gank Alert Settings <<", "Gank")
			_G.azBundle.MenuManager.menu.Aware.Gank:addParam("enable", "Use Gank Tracker", SCRIPT_PARAM_ONOFF, true)
			_G.azBundle.MenuManager.menu.Aware.Gank:addParam("emptySpace1", "", SCRIPT_PARAM_INFO, "")
			_G.azBundle.MenuManager.menu.Aware.Gank:addParam("range", "Max Scan Range", SCRIPT_PARAM_SLICE, 5000,50,10000,0)
			_G.azBundle.MenuManager.menu.Aware.Gank:addParam("emptySpace2", "", SCRIPT_PARAM_INFO, "")
			_G.azBundle.MenuManager.menu.Aware.Gank:addParam("lineWidth", "Line Width", SCRIPT_PARAM_SLICE, 3,1,10,0)
			_G.azBundle.MenuManager.menu.Aware.Gank:addParam("drawLine", "Draw Line", SCRIPT_PARAM_ONOFF, true)
			_G.azBundle.MenuManager.menu.Aware.Gank:addParam("emptySpace3", "", SCRIPT_PARAM_INFO, "")
			_G.azBundle.MenuManager.menu.Aware.Gank:addParam("fontSize", "Font Size", SCRIPT_PARAM_SLICE, 18,1,30,0)
			_G.azBundle.MenuManager.menu.Aware.Gank:addParam("fontColor", "Font Color", SCRIPT_PARAM_COLOR, {255, 255, 255, 255})
			_G.azBundle.MenuManager.menu.Aware.Gank:addParam("drawText", "Draw Text", SCRIPT_PARAM_ONOFF, true)
			_G.azBundle.MenuManager.menu.Aware.Gank:addParam("emptySpace4", "", SCRIPT_PARAM_INFO, "")
			for _, enemy in pairs(GetEnemyHeroes()) do
				if enemy then
					_G.azBundle.MenuManager.menu.Aware.Gank:addParam("enable" .. enemy.charName, "Enable For " .. enemy.charName, SCRIPT_PARAM_ONOFF, true)
				end
			end
		
		_G.azBundle.MenuManager.menu.Aware:addSubMenu(">> Cooldown Tracking Settings <<", "CD")
			_G.azBundle.MenuManager.menu.Aware.CD:addParam("enable", "Use Gank Tracker", SCRIPT_PARAM_ONOFF, true)
			_G.azBundle.MenuManager.menu.Aware.CD:addParam("emptySpace1", "", SCRIPT_PARAM_INFO, "")
			for _, enemy in pairs(GetEnemyHeroes()) do
				if enemy then
					_G.azBundle.MenuManager.menu.Aware.CD:addParam("enable" .. enemy.charName, "Enable For " .. enemy.charName, SCRIPT_PARAM_ONOFF, true)
				end
			end
			_G.azBundle.MenuManager.menu.Aware.CD:addParam("emptySpace2", "", SCRIPT_PARAM_INFO, "")
			for _, enemy in pairs(GetAllyHeroes()) do
				if enemy then
					_G.azBundle.MenuManager.menu.Aware.CD:addParam("allyEnable" .. enemy.charName, "Enable For " .. enemy.charName, SCRIPT_PARAM_ONOFF, true)
				end
			end
	
	self.ChampInfo = {}
	for i, enemy in ipairs(GetEnemyHeroes()) do
		self.ChampInfo[enemy.charName] = {
			CD = {
				["Q"] = false,
				["W"] = false,
				["E"] = false,
				["R"] = false,
				["S1"] = false,
				["S2"] = false
			}
		}
	end
	
	self.setup = true
end

function AwareManager:Tick()
	for _, enemy in pairs(GetEnemyHeroes()) do
		if _G.azBundle.MenuManager.menu.Aware.CD.enable and _G.azBundle.MenuManager.menu.Aware.CD["enable" .. enemy.charName] then
			if enemy:GetSpellData(_Q).level > 0 then
				self.ChampInfo[enemy.charName].CD["Q"] = math.ceil(enemy:GetSpellData(_Q).currentCd)
			end
			if enemy:GetSpellData(_W).level > 0 then
				self.ChampInfo[enemy.charName].CD["W"] = math.ceil(enemy:GetSpellData(_W).currentCd)
			end
			if enemy:GetSpellData(_E).level > 0 then
				self.ChampInfo[enemy.charName].CD["E"] = math.ceil(enemy:GetSpellData(_E).currentCd)
			end
			if enemy:GetSpellData(_R).level > 0 then
				self.ChampInfo[enemy.charName].CD["R"] = math.ceil(enemy:GetSpellData(_R).currentCd)
			end
			self.ChampInfo[enemy.charName].CD["S1"] = math.ceil(enemy:GetSpellData(SUMMONER_1).currentCd)
			self.ChampInfo[enemy.charName].CD["S2"] = math.ceil(enemy:GetSpellData(SUMMONER_2).currentCd)
		end
	end
end

function AwareManager:Draw()
	if not self.setup then return end
	
	for _, enemy in pairs(GetEnemyHeroes()) do
		if enemy and ValidTarget(enemy, _G.azBundle.MenuManager.menu.Aware.Gank.range) then
			local eDist = GetDistance(enemy)
			if _G.azBundle.MenuManager.menu.Aware.Gank.enable and _G.azBundle.MenuManager.menu.Aware.Gank["enable" .. enemy.charName] and (_G.azBundle.MenuManager.menu.Aware.Gank.drawLine or _G.azBundle.MenuManager.menu.Aware.Gank.drawText) then
				local drawColor = nil
				if eDist >= 4000 then
					drawColor = ARGB(255, 0, 255, 0)
				elseif eDist >= 2500 then
					drawColor = ARGB(255, 255, 215, 0)
				elseif eDist < 2500 then
					drawColor = ARGB(255,255,0,0)
				end
				
				if drawColor then
					if _G.azBundle.MenuManager.menu.Aware.Gank.drawLine then
						DrawLine3D2(enemy.x, enemy.y, enemy.z, myHero.x, myHero.y, myHero.z, _G.azBundle.MenuManager.menu.Aware.Gank.lineWidth, drawColor)
					end
					if _G.azBundle.MenuManager.menu.Aware.Gank.drawText then
						local vec = CalcVector(myHero,enemy) * -250
						DrawText3D(enemy.charName .. ": " .. math.round(GetDistance(enemy, myHero)), vec.x+myHero.x, vec.y+myHero.y, vec.z+myHero.z, _G.azBundle.MenuManager.menu.Aware.Gank.fontSize, _G.azBundle.MenuManager.menu.Aware.Gank.fontColor)
					end
				end
			end
		end
			
		if enemy and ValidTarget(enemy) and _G.azBundle.MenuManager.menu.Aware.CD and _G.azBundle.MenuManager.menu.Aware.CD["enable" .. enemy.charName] then
			local barPos = GetUnitHPBarPos(enemy)
			local off = GetUnitHPBarOffset(enemy)
			local y = barPos.y + (off.y * 53) + 2
			local xOff = ({['AniviaEgg'] = -0.1,['Darius'] = -0.05,['Renekton'] = -0.05,['Sion'] = -0.05,['Thresh'] = -0.03,})[enemy.charName]
			local x = barPos.x + ((xOff or 0) * 140) + 50
			if OnScreen(barPos.x, barPos.y) and not enemy.dead and enemy.visible then
				if self.ChampInfo[enemy.charName].CD["Q"] ~= false then
					DrawText("Q: " .. self.ChampInfo[enemy.charName].CD["Q"], 15, x-118.875, y+15, 0xFFFFFFFF)
				else
					DrawText("Q: X", 15, x-118.875, y+15, 0xFFFFFFFF)
				end
				
				if self.ChampInfo[enemy.charName].CD["W"] ~= false then
					DrawText("W: " .. self.ChampInfo[enemy.charName].CD["W"], 15, x-88.875, y+15, 0xFFFFFFFF)
				else
					DrawText("W: X", 15, x-88.875, y+15, 0xFFFFFFFF)
				end
				
				if self.ChampInfo[enemy.charName].CD["E"] ~= false then
					DrawText("E: " .. self.ChampInfo[enemy.charName].CD["E"], 15, x-58.875, y+15, 0xFFFFFFFF)
				else
					DrawText("E: X", 15, x-58.875, y+15, 0xFFFFFFFF)
				end
				
				if self.ChampInfo[enemy.charName].CD["R"] ~= false then
					DrawText("R: " .. self.ChampInfo[enemy.charName].CD["R"], 15, x-28.875, y+15, 0xFFFFFFFF)
				else
					DrawText("R: X", 15, x-28.875, y+15, 0xFFFFFFFF)
				end
				s1Label = "H"
				if enemy:GetSpellData(SUMMONER_1).name == "SummonerDot" then
					s1Label = "I"
				elseif enemy:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
					s1Label = "F"
				elseif enemy:GetSpellData(SUMMONER_1).name == "SummonerExhaust" then
					s1Label = "E"
				elseif enemy:GetSpellData(SUMMONER_1).name == "SummonerHaste" then
					s1Label = "G"
				elseif enemy:GetSpellData(SUMMONER_1).name == "SummonerHeal" then
					s1Label = "H"
				elseif enemy:GetSpellData(SUMMONER_1).name == "SummonerBarrier" then
					s1Label = "B"
				elseif enemy:GetSpellData(SUMMONER_1).name == "SummonerTeleport" then
					s1Label = "T"
				else
					print(enemy:GetSpellData(SUMMONER_1).name)
				end
				
				s2Label = "H"
				if enemy:GetSpellData(SUMMONER_2).name == "SummonerDot" then
					s2Label = "I"
				elseif enemy:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
					s2Label = "F"
				elseif enemy:GetSpellData(SUMMONER_2).name == "SummonerExhaust" then
					s2Label = "E"
				elseif enemy:GetSpellData(SUMMONER_2).name == "SummonerHaste" then
					s2Label = "G"
				elseif enemy:GetSpellData(SUMMONER_2).name == "SummonerHeal" then
					s2Label = "H"
				elseif enemy:GetSpellData(SUMMONER_2).name == "SummonerBarrier" then
					s2Label = "B"
				elseif enemy:GetSpellData(SUMMONER_2).name == "SummonerTeleport" then
					s2Label = "T"
				else
					print(enemy:GetSpellData(SUMMONER_2).name)
				end
				DrawText(s1Label .. ": " .. self.ChampInfo[enemy.charName].CD["S1"], 15, x-155, y, 0xFFFFFFFF)
				DrawText(s2Label .. ": " .. self.ChampInfo[enemy.charName].CD["S2"], 15, x-155, y+15, 0xFFFFFFFF)
			end
		end
	end
end
--[[-----------------------------------------------------
-----------------------/AWARE----------------------------
-----------------------------------------------------]]--

--[[-----------------------------------------------------
----------------------ITEM DMG---------------------------
-----------------------------------------------------]]--
class("ItemDmgManager")
function ItemDmgManager:__init()
	self.sheenProc = false
	
	self.itemInfo = {
		["Sheen"] = {
			ready = false,
			slot = nil,
			seen = false,
			buffed = false,
			id = 3057
		},
		["TriForce"] = {
			ready = false,
			slot = nil,
			seen = false,
			id = 3078
		},
		["Lichbane"] = {
			ready = false,
			slot = nil,
			seen = false,
			id = 3100
		},
		["BoRK"] = {
			ready = false,
			slot = nil,
			seen = false,
			id = 3153,
			range = 450
		}
	}
end

function ItemDmgManager:SheenItem()
	if self.itemInfo["Sheen"].seen then
		return "S"
	elseif self.itemInfo["TriForce"].seen then
		return "T"
	elseif self.itemInfo["Lichbane"].seen then
		return "L"
	end
end

function ItemDmgManager:Tick()
	--------------
	--START: SHEEN
	self.itemInfo["Sheen"].slot = GetInventorySlotItem(self.itemInfo["Sheen"].id)
	
	if self.itemInfo["Sheen"].slot then
		if not self.itemInfo["Sheen"].seen then
			_G.azBundle.PrintManager:General("Item [Sheen] found and added to damage calculations.")
			self.itemInfo["Sheen"].seen = true
		end
	else
		if self.itemInfo["Sheen"].seen then
			_G.azBundle.PrintManager:General("Item [Sheen] sold and removed from damage calculations.")
			self.itemInfo["Sheen"].seen = false
		end 
	end
	
	if self.itemInfo["Sheen"].slot ~= nil and myHero:CanUseSpell(self.itemInfo["Sheen"].slot) == READY then
		self.itemInfo["Sheen"].ready = true
	end
	--END: SHEEN
	
	--------------
	--START: TRIFORCE
	self.itemInfo["TriForce"].slot = GetInventorySlotItem(self.itemInfo["TriForce"].id)
	
	if self.itemInfo["TriForce"].slot then
		if not self.itemInfo["TriForce"].seen then
			_G.azBundle.PrintManager:General("Item [Trinity Force] found and added to damage calculations.")
			self.itemInfo["TriForce"].seen = true
		end
	else
		if self.itemInfo["TriForce"].seen then
			_G.azBundle.PrintManager:General("Item [Trinity Force] sold and removed from damage calculations.")
			self.itemInfo["TriForce"].seen = false
		end 
	end
	
	if self.itemInfo["TriForce"].slot ~= nil and myHero:CanUseSpell(self.itemInfo["TriForce"].slot) == READY then
		self.itemInfo["TriForce"].ready = true
	end
	--END: TRIFORCE
	
	--------------
	--START: LICHBANE
	self.itemInfo["Lichbane"].slot = GetInventorySlotItem(self.itemInfo["Lichbane"].id)
	
	if self.itemInfo["Lichbane"].slot then
		if not self.itemInfo["Lichbane"].seen then
			_G.azBundle.PrintManager:General("Item [Lich Bane] found and added to damage calculations.")
			self.itemInfo["Lichbane"].seen = true
		end
	else
		if self.itemInfo["Lichbane"].seen then
			_G.azBundle.PrintManager:General("Item [Lich Bane] sold and removed from damage calculations.")
			self.itemInfo["Lichbane"].seen = false
		end 
	end
	
	if self.itemInfo["Lichbane"].slot ~= nil and myHero:CanUseSpell(self.itemInfo["Lichbane"].slot) == READY then
		self.itemInfo["Lichbane"].ready = true
	end
	--END: LICHBANE
	
	--------------
	--START: Blade of the Ruined King
	self.itemInfo["BoRK"].slot = GetInventorySlotItem(self.itemInfo["BoRK"].id)
	
	if self.itemInfo["BoRK"].slot then
		if not self.itemInfo["BoRK"].seen then
			_G.azBundle.PrintManager:General("Item [Blade of the Ruined King] found and added to damage calculations.")
			self.itemInfo["BoRK"].seen = true
		end
	else
		if itemInfo["BoRK"].seen then
			_G.azBundle.PrintManager:General("Item [Blade of the Ruined King] sold and removed from damage calculations.")
			self.itemInfo["BoRK"].seen = false
		end 
	end
	
	if itemInfo["BoRK"].slot ~= nil and myHero:CanUseSpell(itemInfo["BoRK"].slot) == READY then
		self.itemInfo["BoRK"].ready = true
	end
	--END: Blade of the Ruined King
	--------------
end

function ItemDmgManager:OnApplyBuff(source, unit, buff)
	if source.isMe and buff.name == "sheen" then
		self.sheenProc = true
	end
end

function ItemDmgManager:OnRemoveBuff(unit, buff)
	if source.isMe and buff.name == "sheen" then
		self.sheenProc = true
	end
end

function ItemDmgManager:LudensEcho(target)
	if not self.sheenProc then return 0 end
	local totalAP = myHero.ap * (1 + myHero.apPercent)
	local LudensDMG = (totalAP * 0.1) + 100
	return player:CalcMagicDamage(target, LudensDMG)
end

function ItemDmgManager:Cutlass(target)
	return player:CalcMagicDamage(target, 100)
end

function ItemDmgManager:Gunblade(target)
	local totalAP = myHero.ap * (1 + myHero.apPercent)
	local GunbladeDMG = (totalAP * 0.3) + 250
	return player:CalcMagicDamage(target, GunbladeDMG)
end

function ItemDmgManager:GLP800(target)
	local totalAP = myHero.ap * (1 + myHero.apPercent)
	local BaseDamage = { 100, 106, 112, 118, 124, 130, 136, 141, 147, 153, 159, 165, 171, 176, 182, 188, 194, 200}
	local GLP800DMG = BaseDamage[myHero.level] + (totalAP * 0.35)
	return player:CalcMagicDamage(target, GLP800DMG)
end

function ItemDmgManager:Protobelt(target)
	local totalAP = myHero.ap * (1 + myHero.apPercent)
	local BaseDamage = { 75, 79, 83, 88, 92, 97, 101, 106, 110, 115, 119, 124, 128, 132, 137, 141, 146, 150}
	local HextechProtobelt01DMG = BaseDamage[myHero.level] + (totalAP * 0.35)
	return player:CalcMagicDamage(target, HextechProtobelt01DMG)
end

function ItemDmgManager:Iceborn(target)
	if not self.sheenProc then return 0 end
	local AD = 1 * (myHero.damage)
	return player:CalcDamage(target, AD)
end

function ItemDmgManager:Sheen(target)
	if not self.sheenProc and self.itemInfo["Sheen"].seen then return 0 end
	local AD = 1 * (myHero.damage)
	return player:CalcDamage(target, AD)
end

function ItemDmgManager:TriForce(target)
	if not self.sheenProc and self.itemInfo["TriForce"].seen then return 0 end
	local AD = 2 * (myHero.damage)
	return player:CalcDamage(target, AD)
end

function ItemDmgManager:LichBane(target)
	if not self.sheenProc and self.itemInfo["Lichbane"].seen then return 0 end
	local AD = (myHero.damage)
	local AP = myHero.ap * (1 + myHero.apPercent)
	local LichBaneDamage = ((AP * 0.5) + (AD * 0.75))
	return player:CalcMagicDamage(target, LichBaneDamage)
end
--[[-----------------------------------------------------
---------------------/ITEM DMG---------------------------
-----------------------------------------------------]]--

--[[-----------------------------------------------------
------------------------MISC-----------------------------
-----------------------------------------------------]]--
class("MiscManager")
function MiscManager:__init()
	_G.azBundle.MenuManager.menu:addSubMenu(">> Misc Settings <<", "Misc")
		_G.azBundle.MenuManager.menu.Misc:addParam("onKill", "Show on kill", SCRIPT_PARAM_LIST, 1, {
			[1] = "Mastery",
			[2] = "Laugh",
			[3] = "Dance",
			[4] = "None"
		})
		_G.azBundle.MenuManager.menu.Misc:addParam("pink", "Auto Pink on Invis", SCRIPT_PARAM_ONOFF, true)
		
	self.lastKills = myHero.kills
	self.BuffNames = {"rengarr", "monkeykingdecoystealth", "talonshadowassaultbuff", "vaynetumblefade", "twitchhideinshadows", "khazixrstealth", "akaliwstealth"}
	--AddNewPathCallback(function(unit, startPos, endPos, isDash ,dashSpeed,dashGravity, dashDistance)
    --    self:
    --end)
end

function MiscManager:Tick()
	if myHero.kills > self.lastKills then
		if _G.azBundle.MenuManager.menu.Misc.onKill == 1 then
			SendChat("/masterybadge")
		elseif _G.azBundle.MenuManager.menu.Misc.onKill == 2 then
			SendChat("/l")
		elseif _G.azBundle.MenuManager.menu.Misc.onKill == 3 then
			DoEmote(3)
		end
		self.lastKills = myHero.kills
	end
	
	if _G.azBundle.MenuManager.menu.Misc.pink then
		
	end
end
--[[-----------------------------------------------------
------------------------/MISC----------------------------
-----------------------------------------------------]]--

--[[-----------------------------------------------------
-------------------------IRELIA--------------------------
-----------------------------------------------------]]--
class("ChampIrelia")
function ChampIrelia:__init()
	_G.azBundle.PrintManager:General("Loaded.")
	
	self.ChampData = {
		useAutoMode = true,
		useFleeMode = true,
		useInteruptable = true,
		useProcessSpell = true,
		useApplyBuff = true,
		useRemoveBuff = true,
		useAntiDash = false
	}
	
	self.target = MyTarget(1200, 650, 650, DAMAGE_PHYSICAL)
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Combo Settings <<", "Combo")
		_G.azBundle.MenuManager.menu.Combo:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Combo:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Combo:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Combo:addParam("r", "Use R", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Combo:addParam("qGap", "Use Q to Gapclose", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Combo:addParam("qTower", "Q Engage Under Tower", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("K"))
		_G.azBundle.MenuManager.menu.Combo:addParam("key", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey(" "))
		
	_G.azBundle.MenuManager.menu:addSubMenu(">> Harass Settings <<", "Harass")
		_G.azBundle.MenuManager.menu.Harass:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Harass:addParam("qMana", "Use Q Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.Harass:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Harass:addParam("wMana", "Use W Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.Harass:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Harass:addParam("eMana", "Use E Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.Harass:addParam("key", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("C"))
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Lane Clear Settings <<", "LaneClear")
		_G.azBundle.MenuManager.menu.LaneClear:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.LaneClear:addParam("qMana", "Use Q Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.LaneClear:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, false)
		_G.azBundle.MenuManager.menu.LaneClear:addParam("wMana", "Use W Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.LaneClear:addParam("key", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Jungle Clear Settings <<", "JungleClear")
		_G.azBundle.MenuManager.menu.JungleClear:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.JungleClear:addParam("qMana", "Use Q Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.JungleClear:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, false)
		_G.azBundle.MenuManager.menu.JungleClear:addParam("wMana", "Use W Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.JungleClear:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, false)
		_G.azBundle.MenuManager.menu.JungleClear:addParam("eMana", "Use E Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.JungleClear:addParam("key", "Jungle Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Last Hit Settings <<", "LastHit")
		_G.azBundle.MenuManager.menu.LastHit:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.LastHit:addParam("qMana", "Use Q Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.LastHit:addParam("key", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("X"))
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Flee Settings <<", "Flee")
		_G.azBundle.MenuManager.menu.Flee:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Flee:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Flee:addParam("key", "Flee Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("T"))
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Auto Settings <<", "Auto")
		_G.azBundle.MenuManager.menu.Auto:addParam("autoLHQ", "Auto Last Hit with Q", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("J"))
		_G.azBundle.MenuManager.menu.Auto:addParam("autoStunE", "Auto Stun with E", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("L"))
		_G.azBundle.MenuManager.menu.Auto:addParam("levelSequance", "Auto Level Sequance", SCRIPT_PARAM_LIST, 1, {
			[1] = "Q-W-E-Max W-Max Q",
			[2] = "E-W-Q-Max W-Max Q",
			[3] = "W-Q-E-Max W-Max Q",
			
			[4] = "Q-W-E-Max Q-Max W",
			[5] = "E-W-Q-Max Q-Max W",
			[6] = "W-Q-E-Max Q-Max W",
			
			[7] = "Q-W-E-Max E-Max W",
			[8] = "E-W-Q-Max E-Max W",
			[9] = "W-Q-E-Max E-Max W",
		})
	
	self.levelSequances = {
		[1] = {1,2,3,2,2,4,2,1,2,1,4,1,1,3,3,4,3,3},
		[2] = {3,1,2,2,2,4,2,1,2,1,4,1,1,3,3,4,3,3},
		[3] = {2,1,3,2,2,4,2,1,2,1,4,1,1,3,3,4,3,3},
		[4] = {1,2,3,1,1,4,1,2,1,2,4,2,2,3,3,4,3,3},
		[5] = {3,2,1,1,1,4,1,2,1,2,4,2,2,3,3,4,3,3},
		[6] = {2,1,3,1,1,4,1,2,1,2,4,2,2,3,3,4,3,3},
		[7] = {1,2,3,3,3,4,3,1,3,2,4,1,1,1,2,4,2,2},
		[8] = {3,2,1,3,3,4,3,1,3,2,4,1,1,1,2,4,2,2},
		[9] = {2,1,3,3,3,4,3,1,3,2,4,1,1,1,2,4,2,2}
	}
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Draw Settings <<", "Draw")
		_G.azBundle.MenuManager.menu.Draw:addParam("q", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Draw:addParam("qColor", "Q Range Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
		_G.azBundle.MenuManager.menu.Draw:addParam("e", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Draw:addParam("eColor", "E Range Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
		_G.azBundle.MenuManager.menu.Draw:addParam("w", "Draw W Range", SCRIPT_PARAM_ONOFF, false)
		_G.azBundle.MenuManager.menu.Draw:addParam("wColor", "W Range Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
		_G.azBundle.MenuManager.menu.Draw:addParam("r", "Draw R Range", SCRIPT_PARAM_ONOFF, false)
		_G.azBundle.MenuManager.menu.Draw:addParam("rColor", "R Range Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
		_G.azBundle.MenuManager.menu.Draw:addParam("eStun", "Draw E Stun", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Draw:addParam("target", "Draw Target", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Draw:addParam("targetColor", "Target Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
		_G.azBundle.MenuManager.menu.Draw:addParam("damage", "Draw Damage", SCRIPT_PARAM_ONOFF, true)
		
	_G.azBundle.MenuManager.menu:addSubMenu(">> Evade Settings <<", "Evade")
		_G.azBundle.MenuManager.menu.Evade:addParam("drawSkills", "Draw Skills", SCRIPT_PARAM_ONOFF, false)
		for i, enemy in pairs(GetEnemyHeroes()) do
		if enemy and _G.azBundle.EvadeManager.ChampData[enemy.charName] ~= nil and _G.azBundle.EvadeManager.ChampData[enemy.charName].SkillData ~= nil then
			for a, spell in pairs(_G.azBundle.EvadeManager.ChampData[enemy.charName].SkillData) do
				_G.azBundle.MenuManager.menu.Evade:addSubMenu(">> " .. _G.azBundle.EvadeManager.ChampData[enemy.charName].Name .. " " .. spell.spellSlot .. " Settings <<", enemy.charName .. spell.spellSlot)
					_G.azBundle.MenuManager.menu.Evade[enemy.charName .. spell.spellSlot]:addParam("dash", "Dash Evade Spell", SCRIPT_PARAM_ONOFF, spell.canDash)
			end
		end
	end
		
	_G.azBundle.MenuManager.menu.Combo:permaShow("qTower")
	_G.azBundle.MenuManager.menu.Auto:permaShow("autoLHQ")
	_G.azBundle.MenuManager.menu.Auto:permaShow("autoStunE")
end

function ChampIrelia:AARange()
	return myHero.range + myHero.boundingRadius
end

function ChampIrelia:ComboMode()
	self.target.champion:update()
	
	local myTarget = self.target.champion.target
	if myTarget and ValidTarget(myTarget, 1200) then
		
		if _G.azBundle.MenuManager.menu.Combo.qGap and myHero:CanUseSpell(_Q) == READY and GetDistance(myTarget) > _G.azBundle.ChampionData.SkillQ.range and not UnderTurret(myTarget) then
			self.target.minion:update()
			for m, minion in pairs(self.target.minion.objects) do
				if minion and ValidTarget(minion, _G.azBundle.ChampionData.SkillQ.range) and minion.health < _G.azBundle.ChampionData.SkillQ.Damage(myHero, minion) and GetDistance(minion, myTarget) <= _G.azBundle.ChampionData.SkillQ.range then
					CastSpell(_Q, minion)
					break
				end
			end
		end
		
		if _G.azBundle.MenuManager.menu.Combo.q and myHero:CanUseSpell(_Q) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillQ.range and not UnderTurret(myTarget) then
			if GetDistance(myTarget) >= self:AARange() * 2 then
				if _G.azBundle.MenuManager.menu.Combo.w and myHero:CanUseSpell(_W) == READY then
					CastSpell(_W)
				end
				CastSpell(_Q, myTarget)
				myHero:Attack(myTarget)
			elseif myTarget.health < _G.azBundle.ChampionData.SkillQ.Damage(myHero, myTarget) then
				if _G.azBundle.MenuManager.menu.Combo.w and myHero:CanUseSpell(_W) == READY then
					CastSpell(_W)
				end
				CastSpell(_Q, myTarget)
			end
		end
		
		if _G.azBundle.MenuManager.menu.Combo.w and myHero:CanUseSpell(_W) == READY and GetDistance(myTarget) <= self:AARange() * 1.25 then
			CastSpell(_W)
			myHero:Attack(myTarget)
		end
		
		if _G.azBundle.MenuManager.menu.Combo.e and myHero:CanUseSpell(_E) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillE.range then
			if 100 * myTarget.health / myTarget.maxHealth > 100 * myHero.health / myHero.maxHealth then
				CastSpell(_E, myTarget)
			elseif (100 * myTarget.health / myTarget.maxHealth) * 1.5 < 100 * myHero.health / myHero.maxHealth then
				CastSpell(_E, myTarget)
			end
		end
		
		if _G.azBundle.MenuManager.menu.Combo.r and myHero:CanUseSpell(_R) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillQ.range * 1.5 then
			if 100 * myTarget.health / myTarget.maxHealth < 40 then
				_G.azBundle.PredManager:CastR(myTarget, false)
			end
		end
		
	end
end

function ChampIrelia:LaneClearMode()
	self.target.minion:update()
	
	if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY and 100 * myHero.mana / myHero.maxMana > _G.azBundle.MenuManager.menu.LaneClear.qMana then
		for m, minion in pairs(self.target.minion.objects) do
			if minion and ValidTarget(minion, _G.azBundle.ChampionData.SkillQ.range) and minion.health < _G.azBundle.ChampionData.SkillQ.Damage(myHero, minion) then
				CastSpell(_Q, minion)
			end
		end
	end
	
	if _G.azBundle.MenuManager.menu.LaneClear.w and myHero:CanUseSpell(_W) == READY and 100 * myHero.mana / myHero.maxMana > _G.azBundle.MenuManager.menu.LaneClear.wMana then
		for m, minion in pairs(self.target.minion.objects) do
			if minion and ValidTarget(minion, self:AARange()) then
				CastSpell(_W)
				return
			end
		end
	end
end

function ChampIrelia:JungleClearMode()
	self.target.jungle:update()
	
	for m, minion in pairs(self.target.jungle.objects) do
		if minion and _G.azBundle.MenuManager.menu.JungleClear.q and myHero:CanUseSpell(_Q) == READY and 100 * myHero.mana / myHero.maxMana > _G.azBundle.MenuManager.menu.JungleClear.qMana and ValidTarget(minion, _G.azBundle.ChampionData.SkillQ.range) and minion.health < _G.azBundle.ChampionData.SkillQ.Damage(myHero, minion) then
			CastSpell(_Q, minion)
		end
		
		if minion and _G.azBundle.MenuManager.menu.JungleClear.w and myHero:CanUseSpell(_W) == READY and 100 * myHero.mana / myHero.maxMana > _G.azBundle.MenuManager.menu.JungleClear.wMana and ValidTarget(minion, self:AARange()) then
			CastSpell(_W)
		end
		
		if minion and _G.azBundle.MenuManager.menu.JungleClear.e and myHero:CanUseSpell(_E) == READY and 100 * minion.health / minion.maxHealth > 100 * myHero.health / myHero.maxHealth and 100 * myHero.mana / myHero.maxMana > _G.azBundle.MenuManager.menu.JungleClear.wMana and ValidTarget(minion, _G.azBundle.ChampionData.SkillE.range) then
			CastSpell(_E, minion)
		end
	end
end

function ChampIrelia:HarassMode()
	self.target.champion:update()
	self.target.minion:update()
	self.target.jungle:update()
	--[[
	if (_G.azBundle.MenuManager.menu.Harass.q and myHero:CanUseSpell(_Q) == READY and 100 * myHero.mana / myHero.maxMana > _G.azBundle.MenuManager.menu.Harass.qMana) and ((_G.azBundle.MenuManager.menu.Harass.w and myHero:CanUseSpell(_W) == READY and 100 * myHero.mana / myHero.maxMana > _G.azBundle.MenuManager.menu.Harass.wMana) or (_G.azBundle.MenuManager.menu.Harass.e and myHero:CanUseSpell(_E) == READY and 100 * myHero.mana / myHero.maxMana > _G.azBundle.MenuManager.menu.Harass.eMana)) then
		local dashToMinion = nil
		local dashAwayMinion = nil
		local enemyHarassTarget = nil
		
		for m, minion in pairs(self.target.minion.objects) do
			if minion and ValidTarget(minion) and minion.health < _G.azBundle.ChampionData.SkillQ.Damage(myHero, minion) then
				if dashToMinion == nil and ValidTarget(minion, _G.azBundle.ChampionData.SkillQ.range) then
					local eInRange = nil
					for e, enemy in pairs(GetEnemyHeroes()) do
						if enemy and ValidTarget(enemy) and GetDistance(enemy, minion) <= myHero.range + myHero.boundingRadius then
							eInRange = enemy
							print("Set E as " .. eInRange.charName)
							break
						end
					end
					
					if eInRange then
						dashToMinion = minion
						print("set dash to minion")
					end
				end
				
				if dashToMinion and dashToMinion ~= minion and not dashAwayMinion and minion and GetDistance(minion, dashToMinion) <= _G.azBundle.ChampionData.SkillQ.range and GetDistance(minion, enemyHarassTarget) >= myHero.range + myHero.boundingRadius then
					dashAwayMinion = minion
					print("Set dash away minion")
					print("TO: " .. dashToMinion.charName .. " -- AWAY: " .. dashAwayMinion.charName .. " -- E: " .. enemyHarassTarget.charName)
					return
				end
			end
		end
		if dashToMinion and dashAwayMinion and enemyHarassTarget then
			CastSpell(_Q, dashToMinion)
			CastSpell(_W)
			CastSpell(_E, enemyHarassTarget)
			DelayAction(function()
				myHero:Attack(enemyHarassTarget)
			end, 0.1)
			DelayAction(function()
				CastSpell(_Q, dashToMinion)
			end, 0.4)
			return
		end
	end
	]]--
	if (_G.azBundle.MenuManager.menu.Harass.q and myHero:CanUseSpell(_Q) == READY and 100 * myHero.mana / myHero.maxMana > _G.azBundle.MenuManager.menu.Harass.qMana) and ((_G.azBundle.MenuManager.menu.Harass.w and myHero:CanUseSpell(_W) == READY and 100 * myHero.mana / myHero.maxMana > _G.azBundle.MenuManager.menu.Harass.wMana) or (_G.azBundle.MenuManager.menu.Harass.e and myHero:CanUseSpell(_E) == READY and 100 * myHero.mana / myHero.maxMana > _G.azBundle.MenuManager.menu.Harass.eMana)) then
	
		local qKillable = {}
		local qKI = 1
		local qKillableInFive = {}
		local qKIFI = 1
		local extendedQRange = _G.azBundle.ChampionData.SkillQ.range + _G.azBundle.ChampionData.SkillQ.range / 2
		
		for m, minion in pairs(self.target.minion.objects) do
			if minion and ValidTarget(minion, extendedQRange) then
				if minion.health < _G.azBundle.ChampionData.SkillQ.Damage(myHero, minion) then
					qKillable[qKI] = minion
					qKI = qKI + 1
				elseif _G.azBundle.PredManager:PredictHealth(minion, 0.5) < _G.azBundle.ChampionData.SkillQ.Damage(myHero, minion) then
					qKillableInFive[qKIFI] = minion
					qKIFI = qKIFI + 1
				end
			end
		end
		
		for m, champ in pairs(self.target.champion.objects) do
			if champ and ValidTarget(champ, extendedQRange) then
				if champ.health < _G.azBundle.ChampionData.SkillQ.Damage(myHero, champ) then
					qKillable[qKI] = champ
					qKI = qKI + 1
				elseif _G.azBundle.PredManager:PredictHealth(champ, 0.5) < _G.azBundle.ChampionData.SkillQ.Damage(myHero, champ) then
					qKillableInFive[qKIFI] = champ
					qKIFI = qKIFI + 1
				end
			end
		end
		
		for m, jungle in pairs(self.target.jungle.objects) do
			if jungle and ValidTarget(jungle, extendedQRange) then
				if jungle.health < _G.azBundle.ChampionData.SkillQ.Damage(myHero, jungle) then
					qKillable[qKI] = jungle
					qKI = qKI + 1
				elseif _G.azBundle.PredManager:PredictHealth(jungle, 0.5) < _G.azBundle.ChampionData.SkillQ.Damage(myHero, jungle) then
					qKillableInFive[qKIFI] = jungle
					qKIFI = qKIFI + 1
				end
			end
		end
		
		local dashToTarget = nil
		local dashAwayTarget = nil
		local enemyHarassTarget = nil
		
		for i, killable in pairs(qKillable) do
			if killable then
				if dashToTarget == nil and enemyHarassTarget == nil and GetDistanceSqr(killable) <= _G.azBundle.ChampionData.SkillQ.range*_G.azBundle.ChampionData.SkillQ.range then
					for e, enemy in pairs(GetEnemyHeroes()) do
						if enemy and ValidTarget(enemy) and GetDistanceSqr(killable, enemy) <= self:AARange() * self:AARange() then
							enemyHarassTarget = enemy
							dashToTarget = killable
							break
						end
					end
				end
			end
		end
		
		if dashToTarget and enemyHarassTarget then
			for i, killable in pairs(qKillableInFive) do
				if killable then
					if dashAwayTarget == nil and GetDistanceSqr(killable, dashToTarget) <= _G.azBundle.ChampionData.SkillQ.range*_G.azBundle.ChampionData.SkillQ.range and GetDistanceSqr(enemyHarassTarget, dashAwayTarget) > self:AARange() * self:AARange() then
						dashAwayTarget = killable
					end
				end
			end
		end
		
		if dashToTarget and dashAwayTarget and enemyHarassTarget then
			CastSpell(_Q, dashToTarget)
			CastSpell(_W)
			CastSpell(_E, enemyHarassTarget)
			DelayAction(function()
				myHero:Attack(enemyHarassTarget)
			end, 0.1)
			DelayAction(function()
				CastSpell(_Q, dashAwayTarget)
			end, 0.4)
			return
		end
	
	end

	local myT = self.target.champion.target
	
	if myT and ValidTarget(myT, self:AARange()) then
		CastSpell(_W)
	end
	
	if myT and ValidTarget(myT, self:AARange()) and 100 * myHero.health / myHero.maxHealth < 100* myT.health / myT.maxHealth then
		CastSpell(_E, myT)
	end
	--[[
	if _G.azBundle.MenuManager.menu.Harass.q and myHero:CanUseSpell(_Q) == READY and 100 * myHero.mana / myHero.maxMana > _G.azBundle.MenuManager.menu.Harass.qMana then
		for m, minion in pairs(self.target.minion.objects) do
			if minion and ValidTarget(minion, _G.azBundle.ChampionData.SkillQ.range) and minion.health < _G.azBundle.ChampionData.SkillQ.Damage(myHero, minion) then
				CastSpell(_Q, minion)
			end
		end
	end
	]]--
end

function ChampIrelia:LastHitMode()
	self.target.champion:update()
	self.target.minion:update()
	
	if _G.azBundle.MenuManager.menu.LastHit.q and myHero:CanUseSpell(_Q) == READY and 100 * myHero.mana / myHero.maxMana > _G.azBundle.MenuManager.menu.LastHit.qMana then
		for m, minion in pairs(self.target.minion.objects) do
			if minion and ValidTarget(minion, _G.azBundle.ChampionData.SkillQ.range) and minion.health < _G.azBundle.ChampionData.SkillQ.Damage(myHero, minion) then
				CastSpell(_Q, minion)
			end
		end
	end
end

function ChampIrelia:FleeMode()
	if _G.azBundle.MenuManager.menu.Flee.q and myHero:CanUseSpell(_E) == READY then
		for e, enemy in pairs(GetEnemyHeroes()) do
			if enemy and ValidTarget(enemy, _G.azBundle.ChampionData.SkillE.range) and 100 * enemy.health / enemy.maxHealth > 100 * myHero.health / myHero.maxHealth then
				CastSpell(_E, enemy)
			end
		end
	end

	if _G.azBundle.MenuManager.menu.Flee.q and myHero:CanUseSpell(_Q) == READY then
		self.target.minion:update()
		self.target.jungle:update()
		
		local furthestTarget = nil
		for m, minion in pairs(self.target.minion.objects) do
			if minion and ValidTarget(minion, _G.azBundle.ChampionData.SkillQ.range) then
				if furthestTarget then
					if GetDistance(furthestTarget, mousePos) < GetDistance(myHero, mousePos) then
						furthestTarget = minion
					end
				else
					furthestTarget = minion
				end
			end
		end
		
		for j, jungle in pairs(self.target.jungle.objects) do
			if jungle and ValidTarget(jungle, _G.azBundle.ChampionData.SkillQ.range) then
				if furthestTarget then
					if GetDistance(furthestTarget, mousePos) < GetDistance(myHero, mousePos) then
						furthestTarget = jungle
					end
				else
					furthestTarget = jungle
				end
			end
		end
		
		if furthestTarget then
			CastSpell(_Q, furthestTarget)
		end
	else
		myHero:MoveTo(mousePos.x, mousePos.z)
	end
end

function ChampIrelia:AutoMode()
	if _G.azBundle.MenuManager.menu.Auto.autoLHQ and myHero:CanUseSpell(_Q) == READY then
		self.target.minion:update()
		for m, minion in pairs(self.target.minion.objects) do
			if minion and ValidTarget(minion, _G.azBundle.ChampionData.SkillQ.range) and minion.health < _G.azBundle.ChampionData.SkillQ.Damage(myHero, minion) then
				CastSpell(_Q, minion)
			end
		end
	end
	
	if _G.azBundle.MenuManager.menu.Auto.autoStunE and myHero:CanUseSpell(_E) == READY then
		for e, enemy in pairs(GetEnemyHeroes()) do
			if enemy and ValidTarget(enemy, _G.azBundle.ChampionData.SkillE.range) and 100 * enemy.health / enemy.maxHealth > 100 * myHero.health / myHero.maxHealth then
				CastSpell(_E, enemy)
			end
		end
	end
end

function ChampIrelia:Draw()
	--minion.health < _G.azBundle.ChampionData.SkillQ.Damage(myHero, minion)
	for m, minion in pairs(self.target.minion.objects) do
		if minion and ValidTarget(minion, 2000) and minion.health <= _G.azBundle.ChampionData.SkillQ.Damage(myHero, minion) then
			DrawCircle2(minion.x, minion.y, minion.z, 75, ARGB(255, 255, 255, 255))
		end
	end
	
	if _G.azBundle.MenuManager.menu.Draw.q and myHero:CanUseSpell(_Q) == READY then
		DrawCircle2(myHero.x, myHero.y, myHero.z, _G.azBundle.ChampionData.SkillQ.range, RGBColor(_G.azBundle.MenuManager.menu.Draw.qColor))
	end
	
	if _G.azBundle.MenuManager.menu.Draw.w and myHero:CanUseSpell(_W) == READY then
		DrawCircle2(myHero.x, myHero.y, myHero.z, _G.azBundle.ChampionData.SkillW.range, RGBColor(_G.azBundle.MenuManager.menu.Draw.wColor))
	end
	
	if _G.azBundle.MenuManager.menu.Draw.e and myHero:CanUseSpell(_E) == READY then
		DrawCircle2(myHero.x, myHero.y, myHero.z, _G.azBundle.ChampionData.SkillE.range, RGBColor(_G.azBundle.MenuManager.menu.Draw.eColor))
	end
	
	if _G.azBundle.MenuManager.menu.Draw.r and myHero:CanUseSpell(_R) == READY then
		DrawCircle2(myHero.x, myHero.y, myHero.z, _G.azBundle.ChampionData.SkillR.range, RGBColor(_G.azBundle.MenuManager.menu.Draw.rColor))
	end
	
	if _G.azBundle.MenuManager.menu.Draw.e and myHero:CanUseSpell(_E) == READY then
		DrawCircle2(myHero.x, myHero.y, myHero.z, _G.azBundle.ChampionData.SkillE.range, ARGB(255, 255, 255, 255))
		for e, enemy in pairs(GetEnemyHeroes()) do
			if enemy and ValidTarget(enemy, 800) and 100 * enemy.health / enemy.maxHealth > 100 * myHero.health / myHero.maxHealth then
				DrawText3D("Can Stun Target [" .. 100 * enemy.health / enemy.maxHealth .. "%]", enemy.x - 80, enemy.y, enemy.z - 70, 14, ARGB(255, 255, 255, 255))
			end
		end
	end
end

function ChampIrelia:OnDash(unit, spell)
	
end

function ChampIrelia:OnInteruptable(unit, spell)
	
end

function ChampIrelia:ProcessSpell(unit, spell)
	
end

function ChampIrelia:ApplyBuff(source, unit, buff)

end

function ChampIrelia:RemoveBuff(source, unit, buff)

end

function ChampIrelia:SetupEvade()
	--_G.azBundle.EvadeManager:AddDashSpell(_Q, "Q", "target", _G.azBundle.ChampionData.SkillQ, "enemy", true)
end

function ChampIrelia:GetDamage(target)
	local myDmg = 0
	if myHero:CanUseSpell(_Q) == READY then
		myDmg = myDmg + _G.azBundle.ChampionData.SkillQ.Damage(myHero, target)
	end
	if myHero:CanUseSpell(_W) == READY then
		myDmg = myDmg + _G.azBundle.ChampionData.SkillW.Damage(myHero, target)
	end
	if myHero:CanUseSpell(_E) == READY then
		myDmg = myDmg + _G.azBundle.ChampionData.SkillE.Damage(myHero, target)
	end
	if myHero:CanUseSpell(_R) == READY then
		myDmg = myDmg + _G.azBundle.ChampionData.SkillR.Damage(myHero, target)
	end
	local sheenItem = _G.azBundle.ItemDmgManager:SheenItem()
	if sheenItem then
		if sheenItem == "S" then
			myDmg = myDmg + _G.azBundle.ItemDmgManager:Sheen(target)
		elseif sheenItem == "T" then
			myDmg = myDmg + _G.azBundle.ItemDmgManager:TriForce(target)
		elseif sheenItem == "T" then
			myDmg = myDmg + _G.azBundle.ItemDmgManager:LichBane(target)
		end
	end
	return myDmg
end
--[[-----------------------------------------------------
-------------------------/IRELIA-------------------------
-----------------------------------------------------]]--

--[[-----------------------------------------------------
-------------------------TALIYAH-------------------------
-----------------------------------------------------]]--
class("ChampTaliyah")
function ChampTaliyah:__init()
	assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQQfAAAAAwAAAEQAAACGAEAA5QAAAJ1AAAGGQEAA5UAAAJ1AAAGlgAAACIAAgaXAAAAIgICBhgBBAOUAAQCdQAABhkBBAMGAAQCdQAABhoBBAOVAAQCKwICDhoBBAOWAAQCKwACEhoBBAOXAAQCKwICEhoBBAOUAAgCKwACFHwCAAAsAAAAEEgAAAEFkZFVubG9hZENhbGxiYWNrAAQUAAAAQWRkQnVnc3BsYXRDYWxsYmFjawAEDAAAAFRyYWNrZXJMb2FkAAQNAAAAQm9sVG9vbHNUaW1lAAQQAAAAQWRkVGlja0NhbGxiYWNrAAQGAAAAY2xhc3MABA4AAABTY3JpcHRUcmFja2VyAAQHAAAAX19pbml0AAQSAAAAU2VuZFZhbHVlVG9TZXJ2ZXIABAoAAABzZW5kRGF0YXMABAsAAABHZXRXZWJQYWdlAAkAAAACAAAAAwAAAAAAAwkAAAAFAAAAGABAABcAAIAfAIAABQAAAAxAQACBgAAAHUCAAR8AgAADAAAAAAQSAAAAU2VuZFZhbHVlVG9TZXJ2ZXIABAcAAAB1bmxvYWQAAAAAAAEAAAABAQAAAAAAAAAAAAAAAAAAAAAEAAAABQAAAAAAAwkAAAAFAAAAGABAABcAAIAfAIAABQAAAAxAQACBgAAAHUCAAR8AgAADAAAAAAQSAAAAU2VuZFZhbHVlVG9TZXJ2ZXIABAkAAABidWdzcGxhdAAAAAAAAQAAAAEBAAAAAAAAAAAAAAAAAAAAAAUAAAAHAAAAAQAEDQAAAEYAwACAAAAAXYAAAUkAAABFAAAATEDAAMGAAABdQIABRsDAAKUAAADBAAEAXUCAAR8AgAAFAAAABA4AAABTY3JpcHRUcmFja2VyAAQSAAAAU2VuZFZhbHVlVG9TZXJ2ZXIABAUAAABsb2FkAAQMAAAARGVsYXlBY3Rpb24AAwAAAAAAQHpAAQAAAAYAAAAHAAAAAAADBQAAAAUAAAAMAEAAgUAAAB1AgAEfAIAAAgAAAAQSAAAAU2VuZFZhbHVlVG9TZXJ2ZXIABAgAAAB3b3JraW5nAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAEBAAAAAAAAAAAAAAAAAAAAAAAACAAAAA0AAAAAAAYyAAAABgBAAB2AgAAaQEAAF4AAgEGAAABfAAABF0AKgEYAQQBHQMEAgYABAMbAQQDHAMIBEEFCAN0AAAFdgAAACECAgUYAQQBHQMEAgYABAMbAQQDHAMIBEMFCAEbBQABPwcICDkEBAt0AAAFdgAAACEAAhUYAQQBHQMEAgYABAMbAQQDHAMIBBsFAAA9BQgIOAQEARoFCAE/BwgIOQQEC3QAAAV2AAAAIQACGRsBAAIFAAwDGgEIAAUEDAEYBQwBWQIEAXwAAAR8AgAAOAAAABA8AAABHZXRJbkdhbWVUaW1lcgADAAAAAAAAAAAECQAAADAwOjAwOjAwAAQGAAAAaG91cnMABAcAAABzdHJpbmcABAcAAABmb3JtYXQABAYAAAAlMDIuZgAEBQAAAG1hdGgABAYAAABmbG9vcgADAAAAAAAgrEAEBQAAAG1pbnMAAwAAAAAAAE5ABAUAAABzZWNzAAQCAAAAOgAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAA4AAAATAAAAAAAIKAAAAAEAAABGQEAAR4DAAIEAAAAhAAiABkFAAAzBQAKAAYABHYGAAVgAQQIXgAaAR0FBAhiAwQIXwAWAR8FBAhkAwAIXAAWARQGAAFtBAAAXQASARwFCAoZBQgCHAUIDGICBAheAAYBFAQABTIHCAsHBAgBdQYABQwGAAEkBgAAXQAGARQEAAUyBwgLBAQMAXUGAAUMBgABJAYAAIED3fx8AgAANAAAAAwAAAAAAAPA/BAsAAABvYmpNYW5hZ2VyAAQLAAAAbWF4T2JqZWN0cwAECgAAAGdldE9iamVjdAAABAUAAAB0eXBlAAQHAAAAb2JqX0hRAAQHAAAAaGVhbHRoAAQFAAAAdGVhbQAEBwAAAG15SGVybwAEEgAAAFNlbmRWYWx1ZVRvU2VydmVyAAQGAAAAbG9vc2UABAQAAAB3aW4AAAAAAAMAAAAAAAEAAQEAAAAAAAAAAAAAAAAAAAAAFAAAABQAAAACAAICAAAACkAAgB8AgAABAAAABAoAAABzY3JpcHRLZXkAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFAAAABUAAAACAAUKAAAAhgBAAMAAgACdgAABGEBAARfAAICFAIAAjIBAAQABgACdQIABHwCAAAMAAAAEBQAAAHR5cGUABAcAAABzdHJpbmcABAoAAABzZW5kRGF0YXMAAAAAAAIAAAAAAAEBAAAAAAAAAAAAAAAAAAAAABYAAAAlAAAAAgATPwAAAApAAICGgEAAnYCAAAqAgICGAEEAxkBBAAaBQQAHwUECQQECAB2BAAFGgUEAR8HBAoFBAgBdgQABhoFBAIfBQQPBgQIAnYEAAcaBQQDHwcEDAcICAN2BAAEGgkEAB8JBBEECAwAdggABFgECAt0AAAGdgAAACoCAgYaAQwCdgIAACoCAhgoAxIeGQEQAmwAAABdAAIAKgMSHFwAAgArAxIeGQEUAh4BFAQqAAIqFAIAAjMBFAQEBBgBBQQYAh4FGAMHBBgAAAoAAQQIHAIcCRQDBQgcAB0NAAEGDBwCHw0AAwcMHAAdEQwBBBAgAh8RDAFaBhAKdQAACHwCAACEAAAAEBwAAAGFjdGlvbgAECQAAAHVzZXJuYW1lAAQIAAAAR2V0VXNlcgAEBQAAAGh3aWQABA0AAABCYXNlNjRFbmNvZGUABAkAAAB0b3N0cmluZwAEAwAAAG9zAAQHAAAAZ2V0ZW52AAQVAAAAUFJPQ0VTU09SX0lERU5USUZJRVIABAkAAABVU0VSTkFNRQAEDQAAAENPTVBVVEVSTkFNRQAEEAAAAFBST0NFU1NPUl9MRVZFTAAEEwAAAFBST0NFU1NPUl9SRVZJU0lPTgAECwAAAGluZ2FtZVRpbWUABA0AAABCb2xUb29sc1RpbWUABAYAAABpc1ZpcAAEAQAAAAAECQAAAFZJUF9VU0VSAAMAAAAAAADwPwMAAAAAAAAAAAQJAAAAY2hhbXBpb24ABAcAAABteUhlcm8ABAkAAABjaGFyTmFtZQAECwAAAEdldFdlYlBhZ2UABA4AAABib2wtdG9vbHMuY29tAAQXAAAAL2FwaS9ldmVudHM/c2NyaXB0S2V5PQAECgAAAHNjcmlwdEtleQAECQAAACZhY3Rpb249AAQLAAAAJmNoYW1waW9uPQAEDgAAACZib2xVc2VybmFtZT0ABAcAAAAmaHdpZD0ABA0AAAAmaW5nYW1lVGltZT0ABAgAAAAmaXNWaXA9AAAAAAACAAAAAAABAQAAAAAAAAAAAAAAAAAAAAAmAAAAKgAAAAMACiEAAADGQEAAAYEAAN2AAAHHwMAB3YCAAArAAIDHAEAAzADBAUABgACBQQEA3UAAAscAQADMgMEBQcEBAIABAAHBAQIAAAKAAEFCAgBWQYIC3UCAAccAQADMgMIBQcECAIEBAwDdQAACxwBAAMyAwgFBQQMAgYEDAN1AAAIKAMSHCgDEiB8AgAASAAAABAcAAABTb2NrZXQABAgAAAByZXF1aXJlAAQHAAAAc29ja2V0AAQEAAAAdGNwAAQIAAAAY29ubmVjdAADAAAAAAAAVEAEBQAAAHNlbmQABAUAAABHRVQgAAQSAAAAIEhUVFAvMS4wDQpIb3N0OiAABAUAAAANCg0KAAQLAAAAc2V0dGltZW91dAADAAAAAAAAAAAEAgAAAGIAAwAAAPyD15dBBAIAAAB0AAQKAAAATGFzdFByaW50AAQBAAAAAAQFAAAARmlsZQAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAABAAAAAAAAAAAAAAAAAAAAAAA="), nil, "bt", _ENV))()
	TrackerLoad("40RMmbgW5zhYM1As")
	
	self.ChampData = {
		useAutoMode = true,
		useFleeMode = true,
		useInteruptable = true,
		useProcessSpell = true,
		useApplyBuff = false,
		useRemoveBuff = false,
		usePreTick = true,
		useCreateObj = true,
		useAntiDash = true
	}
	
	self.target = MyTarget(950, 950, 950, DAMAGE_MAGIC)
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Combo Settings <<", "Combo")
		_G.azBundle.MenuManager.menu.Combo:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Combo:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Combo:addParam("wMore", "Use W More Often", SCRIPT_PARAM_ONOFF, false)
		_G.azBundle.MenuManager.menu.Combo:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Combo:addParam("key", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey(" "))
		
	_G.azBundle.MenuManager.menu:addSubMenu(">> Harass Settings <<", "Harass")
		_G.azBundle.MenuManager.menu.Harass:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Harass:addParam("qMana", "Use Q Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.Harass:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Harass:addParam("wMana", "Use W Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.Harass:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Harass:addParam("eMana", "Use E Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.Harass:addParam("key", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("C"))
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Lane Clear Settings <<", "LaneClear")
		_G.azBundle.MenuManager.menu.LaneClear:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.LaneClear:addParam("qMana", "Use Q Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.LaneClear:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, false)
		_G.azBundle.MenuManager.menu.LaneClear:addParam("wMana", "Use W Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.LaneClear:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.LaneClear:addParam("eMana", "Use E Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.LaneClear:addParam("key", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Jungle Clear Settings <<", "JungleClear")
		_G.azBundle.MenuManager.menu.JungleClear:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.JungleClear:addParam("qMana", "Use Q Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.JungleClear:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, false)
		_G.azBundle.MenuManager.menu.JungleClear:addParam("wMana", "Use W Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.JungleClear:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, false)
		_G.azBundle.MenuManager.menu.JungleClear:addParam("eMana", "Use E Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.JungleClear:addParam("key", "Jungle Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Last Hit Settings <<", "LastHit")
		_G.azBundle.MenuManager.menu.LastHit:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.LastHit:addParam("qMana", "Use Q Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.LastHit:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.LastHit:addParam("wMana", "Use W Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.LastHit:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.LastHit:addParam("eMana", "Use E Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.LastHit:addParam("key", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("X"))
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Flee Settings <<", "Flee")
		_G.azBundle.MenuManager.menu.Flee:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Flee:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Flee:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Flee:addParam("key", "Flee Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("T"))
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Dash Settings <<", "Dash")
		
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Auto Settings <<", "Auto")
		_G.azBundle.MenuManager.menu.Auto:addParam("levelSequance", "Auto Level Sequance", SCRIPT_PARAM_LIST, 4, {
			[1] = "Q-W-E-Max W-Max Q",
			[2] = "E-W-Q-Max W-Max Q",
			[3] = "W-Q-E-Max W-Max Q",
			
			[4] = "Q-W-E-Max Q-Max W",
			[5] = "E-W-Q-Max Q-Max W",
			[6] = "W-Q-E-Max Q-Max W",
			
			[7] = "Q-W-E-Max E-Max W",
			[8] = "E-W-Q-Max E-Max W",
			[9] = "W-Q-E-Max E-Max W",
		})
	
	self.levelSequances = {
		[1] = {1,2,3,2,2,4,2,1,2,1,4,1,1,3,3,4,3,3},
		[2] = {3,1,2,2,2,4,2,1,2,1,4,1,1,3,3,4,3,3},
		[3] = {2,1,3,2,2,4,2,1,2,1,4,1,1,3,3,4,3,3},
		[4] = {1,2,3,1,1,4,1,2,1,2,4,2,2,3,3,4,3,3},
		[5] = {3,2,1,1,1,4,1,2,1,2,4,2,2,3,3,4,3,3},
		[6] = {2,1,3,1,1,4,1,2,1,2,4,2,2,3,3,4,3,3},
		[7] = {1,2,3,3,3,4,3,1,3,2,4,1,1,1,2,4,2,2},
		[8] = {3,2,1,3,3,4,3,1,3,2,4,1,1,1,2,4,2,2},
		[9] = {2,1,3,3,3,4,3,1,3,2,4,1,1,1,2,4,2,2}
	}
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Draw Settings <<", "Draw")
		_G.azBundle.MenuManager.menu.Draw:addParam("q", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Draw:addParam("qColor", "Q Range Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
		_G.azBundle.MenuManager.menu.Draw:addParam("e", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Draw:addParam("eColor", "E Range Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
		_G.azBundle.MenuManager.menu.Draw:addParam("w", "Draw W Range", SCRIPT_PARAM_ONOFF, false)
		_G.azBundle.MenuManager.menu.Draw:addParam("wColor", "W Range Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
		_G.azBundle.MenuManager.menu.Draw:addParam("r", "Draw R Range", SCRIPT_PARAM_ONOFF, false)
		_G.azBundle.MenuManager.menu.Draw:addParam("rColor", "R Range Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
		_G.azBundle.MenuManager.menu.Draw:addParam("target", "Draw Target", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Draw:addParam("targetColor", "Target Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
		_G.azBundle.MenuManager.menu.Draw:addParam("damage", "Draw Damage", SCRIPT_PARAM_ONOFF, true)
	
	--_G.azBundle.MenuManager.menu.Auto:permaShow("autoStunE")
	
	self.onWorkedGround = false
	self.usedGround = {}
	self.wTarget = nil
	
	_G.azBundle.PrintManager:General("Loaded.")
end

function ChampTaliyah:PreTick()
	self.onWorkedGround = false
	for i, worked in pairs(self.usedGround) do
		if worked.expire <= os.clock() then
			table.remove(self.usedGround, i)
		else
			if worked and worked.obje and worked.obje.pos and myHero:GetDistance(worked.obje) <= 425 then
				self.onWorkedGround = true
			end
		end
	end
end

function ChampTaliyah:AARange()
	return myHero.range + myHero.boundingRadius
end

function ChampTaliyah:ComboMode()
	self.target.champion:update()
	
	local castOnTarget = false
	
	local myTarget = self.target.champion.target
	if myTarget and ValidTarget(myTarget, 910) then
		if _G.azBundle.MenuManager.menu.Combo.q and myHero:CanUseSpell(_Q) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillQ.range and not self.onWorkedGround then
			_G.azBundle.PredManager:CastQ(myTarget, false, true)
			castOnTarget = true
		end
		if _G.azBundle.MenuManager.menu.Combo.q and myHero:CanUseSpell(_Q) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillQ.range and self.onWorkedGround then
			_G.azBundle.PredManager:CastQ(myTarget, false, true)
			castOnTarget = true
		end
		if _G.azBundle.MenuManager.menu.Combo.e and myHero:CanUseSpell(_E) == READY and _G.azBundle.MenuManager.menu.Combo.w and myHero:CanUseSpell(_W) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillW.range and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillE.range and _G.azBundle.PredManager:CheckE(myTarget, false, false) and _G.azBundle.PredManager:checkW(myTarget, false, false) then
			_G.azBundle.PredManager:CastE(en, false, false)
			_G.azBundle.PredManager:CastW(en, false, false)
			castOnTarget = true
		end
		if _G.azBundle.MenuManager.menu.Combo.e and myHero:CanUseSpell(_E) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillE.range then
			_G.azBundle.PredManager:CastE(myTarget, false, false)
			castOnTarget = true
		end
		if _G.azBundle.MenuManager.menu.Combo.w and myHero:CanUseSpell(_W) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillW.range and 100*myHero.health/myHero.maxHealth <= 30 and _G.azBundle.MenuManager.menu.Combo.wMore then
			_G.azBundle.PredManager:CastW(myTarget, false, false)
			castOnTarget = true
		end
	end
	
	if castOnTarget then return end
	
	for _, en in pairs(GetEnemyHeroes()) do
		if en and ValidTarget(en, 910) then
			if _G.azBundle.MenuManager.menu.Combo.q and myHero:CanUseSpell(_Q) == READY and GetDistance(en) <= _G.azBundle.ChampionData.SkillQ.range and not self.onWorkedGround then
				_G.azBundle.PredManager:CastQ(en, false, true)
			end
			if _G.azBundle.MenuManager.menu.Combo.q and myHero:CanUseSpell(_Q) == READY and GetDistance(en) <= _G.azBundle.ChampionData.SkillQ.range and self.onWorkedGround then
				_G.azBundle.PredManager:CastQ(en, false, true)
			end
			if _G.azBundle.MenuManager.menu.Combo.e and myHero:CanUseSpell(_E) == READY and _G.azBundle.MenuManager.menu.Combo.w and myHero:CanUseSpell(_W) == READY and GetDistance(en) <= _G.azBundle.ChampionData.SkillW.range and GetDistance(en) <= _G.azBundle.ChampionData.SkillE.range and _G.azBundle.PredManager:CheckE(en, false, false) and _G.azBundle.PredManager:checkW(en, false, false) then
				_G.azBundle.PredManager:CastE(en, false, false)
				_G.azBundle.PredManager:CastW(en, false, false)
			end
			if _G.azBundle.MenuManager.menu.Combo.e and myHero:CanUseSpell(_E) == READY and GetDistance(en) <= _G.azBundle.ChampionData.SkillE.range then
				_G.azBundle.PredManager:CastE(en, false, false)
			end
		end
	end
end

function ChampTaliyah:LaneClearMode()
	self.target.minion:update()
	
	for m, minion in pairs(self.target.minion.objects) do
		if minion then
			if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY and self.onWorkedGround and ValidTarget(minion, _G.azBundle.ChampionData.SkillQ.range) then
				_G.azBundle.PredManager:CastQ(minion, true, true)
			end
			
			if _G.azBundle.MenuManager.menu.LaneClear.w and myHero:CanUseSpell(_W) == READY and ValidTarget(minion, _G.azBundle.ChampionData.SkillW.range) then
				bestPos, bestHit = GetFarmPosition(550, 250, self.target.minion.objects)
				if bestPos and bestHit and bestHit >= 3 then
					CastSpell(_W, bestPos.x, bestPos.z)
				end
			end
			
			if _G.azBundle.MenuManager.menu.LaneClear.e and myHero:CanUseSpell(_E) == READY and ValidTarget(minion, _G.azBundle.ChampionData.SkillE.range) then
				bestPos, bestHit = GetFarmPosition(_G.azBundle.ChampionData.SkillE.range, _G.azBundle.ChampionData.SkillE.width, self.target.minion.objects)
				if bestPos and bestHit and bestHit >= 3 then
					CastSpell(_E, bestPos.x, bestPos.z)
				end
			end
		end
	end
end

function ChampTaliyah:JungleClearMode()
	self.target.jungle:update()
	
	for m, minion in pairs(self.target.jungle.objects) do
		if minion and ValidTarget(minion, _G.azBundle.ChampionData.SkillQ.range) then
			if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY and self.onWorkedGround then
				_G.azBundle.PredManager:CastQ(minion, true, true)
			end
			
			if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY and not self.onWorkedGround then
				_G.azBundle.PredManager:CastQ(minion, true, true)
			end
			
			if _G.azBundle.MenuManager.menu.LaneClear.w and myHero:CanUseSpell(_W) == READY then
				_G.azBundle.PredManager:CastW(minion, true, false)
			end
			
			if _G.azBundle.MenuManager.menu.LaneClear.e and myHero:CanUseSpell(_E) == READY then
				_G.azBundle.PredManager:CastE(minion, true, false)
			end
		end
	end
end

function ChampTaliyah:HarassMode()
	self.target.champion:update()
	self.target.minion:update()
	
	local myTarget = self.target.champion.target
	if myTarget and ValidTarget(myTarget, 910) then
		
		if _G.azBundle.MenuManager.menu.Combo.q and myHero:CanUseSpell(_Q) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillQ.range and not self.onWorkedGround then
			_G.azBundle.PredManager:CastQ(myTarget, false, true)
		end
		
		if _G.azBundle.MenuManager.menu.Combo.q and myHero:CanUseSpell(_Q) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillQ.range and self.onWorkedGround then
			_G.azBundle.PredManager:CastQ(myTarget, false, true)
		end
		
		if _G.azBundle.MenuManager.menu.Combo.w and myHero:CanUseSpell(_W) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillW.range then
			if _G.azBundle.MenuManager.menu.Combo.e and myHero:CanUseSpell(_E) == READY and GetDistance(CastPosition) <= _G.azBundle.ChampionData.SkillE.range then
				_G.azBundle.PredManager:CastE(myTarget, false, false)
			end
			_G.azBundle.PredManager:CastW(myTarget, false, false)
		end
		
		if _G.azBundle.MenuManager.menu.Combo.e and myHero:CanUseSpell(_E) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillE.range then
			_G.azBundle.PredManager:CastE(myTarget, false, false)
		end
		
	end
end

function ChampTaliyah:LastHitMode()
	self.target.champion:update()
	self.target.minion:update()
	
	for m, minion in pairs(self.target.minion.objects) do
		if minion and ValidTarget(minion, _G.azBundle.ChampionData.SkillQ.range) then
			if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY and self.onWorkedGround then
				_G.azBundle.PredManager:CastQ(minion, true)
			end
			
			if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY and not self.onWorkedGround then
				_G.azBundle.PredManager:CastQ(minion, true)
			end
			
			if _G.azBundle.MenuManager.menu.LaneClear.w and myHero:CanUseSpell(_W) == READY then
				_G.azBundle.PredManager:CastW(minion, true)
			end
			
			if _G.azBundle.MenuManager.menu.LaneClear.e and myHero:CanUseSpell(_E) == READY then
				_G.azBundle.PredManager:CastE(minion, true)
			end
		end
	end
end

function ChampTaliyah:FleeMode()
	
end

function ChampTaliyah:AutoMode()
	
end

function ChampTaliyah:Draw()
	if _G.azBundle.MenuManager.menu.Draw.q and myHero:CanUseSpell(_Q) == READY then
		DrawCircle2(myHero.x, myHero.y, myHero.z, _G.azBundle.ChampionData.SkillQ.range, RGBColor(_G.azBundle.MenuManager.menu.Draw.qColor))
	end
	
	if _G.azBundle.MenuManager.menu.Draw.w and myHero:CanUseSpell(_W) == READY then
		DrawCircle2(myHero.x, myHero.y, myHero.z, _G.azBundle.ChampionData.SkillW.range, RGBColor(_G.azBundle.MenuManager.menu.Draw.wColor))
	end
	
	if _G.azBundle.MenuManager.menu.Draw.e and myHero:CanUseSpell(_E) == READY then
		DrawCircle2(myHero.x, myHero.y, myHero.z, _G.azBundle.ChampionData.SkillE.range, RGBColor(_G.azBundle.MenuManager.menu.Draw.eColor))
	end
	
	if self.onWorkedGround then
		DrawText3D("On Worked Ground", myHero.x - 100, myHero.y, myHero.z - 70, 18, ARGB(255, 255, 255, 255))
	end
end

function ChampTaliyah:OnDash(unit, spell)
	if unit and spell and spell.endPos then
		if myHero:CanUseSpell(_E) == READY and GetDistance(spell.endPos) <= _G.azBundle.ChampionData.SkillE.range then
			CastSpell(_E, spell.endPos.x, spell.endPos.z)
		end
		if myHero:CanUseSpell(_W) == READY and GetDistance(spell.endPos) <= _G.azBundle.ChampionData.SkillW.range then
			CastSpell(_W, spell.endPos.x, spell.endPos.z)
		end
	end
end

function ChampTaliyah:OnInteruptable(unit, spell)
	if unit and spell then
		if myHero:CanUseSpell(_E) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillE.range then
			CastSpell(_E, spell.endPos.x, spell.endPos.z)
		end
		if myHero:CanUseSpell(_W) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillW.range then
			CastSpell(_W, spell.endPos.x, spell.endPos.z)
		end
	end
end

function ChampTaliyah:ProcessSpell(unit, spell)
	if object == myHero and spell.name == "TaliyahW" and self.wTarget then
		local teamInRange = 0
		local enemyInRange = 0
		local chosenTarget = nil
		
		for _, e in ipairs(GetEnemyHeroes()) do
			if e and ValidTarget(e) and GetDistance(e.pos, self.wTarget) <= 125 then
				enemyInRange = enemyInRange + 1
				if chosenTarget == nil then
					chosenTarget = e
				elseif chosenTarget.health > e.health then
					chosenTarget = e
				end
			end
		end
		
		for _, a in ipairs(GetAllyHeroes()) do
			if a and GetDistance(a) <= 250 then
				teamInRange = teamInRange + 1
			end
		end
		
		if chosenTarget and enemyInRange > 0 then
			if teamInRange >= enemyInRange then
				DelayAction(function()
					CastSpell(_W, myHero.x, myHero.z)
					print("casting W2")
				end, 0.75)
			elseif 100*chosenTarget.health/chosenTarget.maxHealth < 25 then
				DelayAction(function()
					CastSpell(_W, myHero.x, myHero.z)
					print("casting W2")
				end, 0.75)
			elseif teamInRange == 0 and enemyInRange == 1 and 100*chosenTarget.health/chosenTarget.maxHealth < 100*myHero.health/myHero.maxHealth then
				DelayAction(function()
					CastSpell(_W, myHero.x, myHero.z)
					print("casting W2")
				end, 0.75)
			elseif teamInRange == 0 and enemyInRange == 1 and 100*chosenTarget.health/chosenTarget.maxHealth > 100*myHero.health/myHero.maxHealth then
				DelayAction(function()
					CastSpell(_W, chosenTarget.x, chosenTarget.z)
					print("casting W2 away")
				end, 0.75)
			else
				DelayAction(function()
					CastSpell(_W, chosenTarget.x, chosenTarget.z)
					print("casting W2 away")
				end, 0.75)
			end
		end
	end
end

function ChampTaliyah:ApplyBuff(source, unit, buff)

end

function ChampTaliyah:RemoveBuff(source, unit, buff)

end

function ChampTaliyah:CreateObj(obj)
	if obj then
		if obj.name:find("Taliyah_Base_Q") and not self:WorkedGroundIsKnown(obj) then
			tmpT = {
				obje = obj,
				expire = os.clock() + 180
			}
			table.insert(self.usedGround, tmpT)
		end
	end
end

function ChampTaliyah:WorkedGroundIsKnown(obj)
	for i, worked in pairs(self.usedGround) do
		if worked and worked.obje then
			if worked.obje == obj then
				return true
			end
		else
			table.remove(self.usedGround, i)
		end
	end
	return false
end

function ChampTaliyah:SetupEvade()
	--_G.azBundle.EvadeManager:AddDashSpell(_Q, "Q", "target", _G.azBundle.ChampionData.SkillQ, "enemy", true)
end

function ChampTaliyah:GetDamage(target)
	local myDmg = 0
	if myHero:CanUseSpell(_Q) == READY then
		myDmg = myDmg + _G.azBundle.ChampionData.SkillQ.Damage(myHero, target)
	end
	if myHero:CanUseSpell(_W) == READY then
		myDmg = myDmg + _G.azBundle.ChampionData.SkillW.Damage(myHero, target)
	end
	if myHero:CanUseSpell(_E) == READY then
		myDmg = myDmg + _G.azBundle.ChampionData.SkillE.Damage(myHero, target)
	end
	local sheenItem = _G.azBundle.ItemDmgManager:SheenItem()
	if sheenItem then
		if sheenItem == "S" then
			myDmg = myDmg + _G.azBundle.ItemDmgManager:Sheen(target)
		elseif sheenItem == "T" then
			myDmg = myDmg + _G.azBundle.ItemDmgManager:TriForce(target)
		elseif sheenItem == "T" then
			myDmg = myDmg + _G.azBundle.ItemDmgManager:LichBane(target)
		end
	end
	return myDmg
end

function ChampTaliyah:CastWTwo(target)
	if target then
		--CastSpell(_W, myHero.x, myHero.z)
		
	end
end
--[[-----------------------------------------------------
-------------------------/TALIYAH------------------------
-----------------------------------------------------]]--

--[[-----------------------------------------------------
--------------------------RYZE---------------------------
-----------------------------------------------------]]--
class("ChampRyze")
function ChampRyze:__init()
	_G.azBundle.PrintManager:General("Loaded.")
	
	self.ChampData = {
		useAutoMode = true,
		useFleeMode = false,
		useInteruptable = true,
		useProcessSpell = false,
		useApplyBuff = true,
		useRemoveBuff = false,
		usePreTick = false,
		useCreateObj = true,
		useAntiDash = true
	}
	
	self.target = MyTarget(1000, 1000, 1000, DAMAGE_MAGIC)
		
	_G.azBundle.MenuManager.menu:addSubMenu(">> Combo Settings <<", "Combo")
		_G.azBundle.MenuManager.menu.Combo:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Combo:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Combo:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Combo:addParam("key", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey(" "))
		
	_G.azBundle.MenuManager.menu:addSubMenu(">> Harass Settings <<", "Harass")
		_G.azBundle.MenuManager.menu.Harass:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Harass:addParam("qMana", "Use Q Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.Harass:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Harass:addParam("wMana", "Use W Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.Harass:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Harass:addParam("eMana", "Use E Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.Harass:addParam("key", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("C"))
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Lane Clear Settings <<", "LaneClear")
		_G.azBundle.MenuManager.menu.LaneClear:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.LaneClear:addParam("qMana", "Use Q Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.LaneClear:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, false)
		_G.azBundle.MenuManager.menu.LaneClear:addParam("wMana", "Use W Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.LaneClear:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.LaneClear:addParam("eMana", "Use E Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.LaneClear:addParam("key", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Jungle Clear Settings <<", "JungleClear")
		_G.azBundle.MenuManager.menu.JungleClear:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.JungleClear:addParam("qMana", "Use Q Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.JungleClear:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, false)
		_G.azBundle.MenuManager.menu.JungleClear:addParam("wMana", "Use W Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.JungleClear:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, false)
		_G.azBundle.MenuManager.menu.JungleClear:addParam("eMana", "Use E Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.JungleClear:addParam("key", "Jungle Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Last Hit Settings <<", "LastHit")
		_G.azBundle.MenuManager.menu.LastHit:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.LastHit:addParam("qMana", "Use Q Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.LastHit:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.LastHit:addParam("wMana", "Use W Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.LastHit:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.LastHit:addParam("eMana", "Use E Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.LastHit:addParam("key", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("X"))
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Flee Settings <<", "Flee")
		_G.azBundle.MenuManager.menu.Flee:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Flee:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Flee:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Flee:addParam("key", "Flee Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("T"))
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Auto Settings <<", "Auto")
		_G.azBundle.MenuManager.menu.Auto:addParam("autoW", "Auto Root in Comfort Zone", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("J"))
		_G.azBundle.MenuManager.menu.Auto:addParam("levelSequance", "Auto Level Sequance", SCRIPT_PARAM_LIST, 10, {
			[1] = "Q-W-E-Max W-Max Q",
			[2] = "E-W-Q-Max W-Max Q",
			[3] = "W-Q-E-Max W-Max Q",
			
			[4] = "Q-W-E-Max Q-Max W",
			[5] = "E-W-Q-Max Q-Max W",
			[6] = "W-Q-E-Max Q-Max W",
			
			[7] = "Q-W-E-Max E-Max W",
			[8] = "E-W-Q-Max E-Max W",
			[9] = "W-Q-E-Max E-Max W",
			
			[10] = "E-Q-W-Max Q-Max W",
		})
	
	self.levelSequances = {
		[1] = {1,2,3,2,2,4,2,1,2,1,4,1,1,3,3,4,3,3},
		[2] = {3,1,2,2,2,4,2,1,2,1,4,1,1,3,3,4,3,3},
		[3] = {2,1,3,2,2,4,2,1,2,1,4,1,1,3,3,4,3,3},
		[4] = {1,2,3,1,1,4,1,2,1,2,4,2,2,3,3,4,3,3},
		[5] = {3,2,1,1,1,4,1,2,1,2,4,2,2,3,3,4,3,3},
		[6] = {2,1,3,1,1,4,1,2,1,2,4,2,2,3,3,4,3,3},
		[7] = {1,2,3,3,3,4,3,1,3,2,4,1,1,1,2,4,2,2},
		[8] = {3,2,1,3,3,4,3,1,3,2,4,1,1,1,2,4,2,2},
		[9] = {2,1,3,3,3,4,3,1,3,2,4,1,1,1,2,4,2,2},
		[10] = {3,1,2,1,1,4,1,2,1,2,4,2,2,3,3,4,3,3}
	}
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Draw Settings <<", "Draw")
		_G.azBundle.MenuManager.menu.Draw:addParam("q", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Draw:addParam("qColor", "Q Range Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
		_G.azBundle.MenuManager.menu.Draw:addParam("e", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Draw:addParam("eColor", "E Range Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
		_G.azBundle.MenuManager.menu.Draw:addParam("w", "Draw W Range", SCRIPT_PARAM_ONOFF, false)
		_G.azBundle.MenuManager.menu.Draw:addParam("wColor", "W Range Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
		_G.azBundle.MenuManager.menu.Draw:addParam("r", "Draw R Range", SCRIPT_PARAM_ONOFF, false)
		_G.azBundle.MenuManager.menu.Draw:addParam("rColor", "R Range Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
		_G.azBundle.MenuManager.menu.Draw:addParam("target", "Draw Target", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Draw:addParam("targetColor", "Target Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
		_G.azBundle.MenuManager.menu.Draw:addParam("damage", "Draw Damage", SCRIPT_PARAM_ONOFF, true)
	
	_G.azBundle.MenuManager.menu.Auto:permaShow("autoW")
	
	self.runeCount = 0
end

function ChampRyze:PreTick()
	
end

function ChampRyze:AARange()
	return myHero.range + myHero.boundingRadius
end

function ChampRyze:ComboMode()
	self.target.champion:update()
	
	local myTarget = self.target.champion.target
	if myTarget and ValidTarget(myTarget, 1000) then
		
		if _G.azBundle.MenuManager.menu.Combo.q and myHero:CanUseSpell(_Q) == READY then
				_G.azBundle.PredManager:CastQ(myTarget, false)
			end

			if _G.azBundle.MenuManager.menu.Combo.e and myHero:CanUseSpell(_E) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillE.range then
				CastSpell(_E, myTarget)
			end
			
			if _G.azBundle.MenuManager.menu.Combo.q and myHero:CanUseSpell(_Q) == READY then
				_G.azBundle.PredManager:CastQ(myTarget, false)
			end
			
			if _G.azBundle.MenuManager.menu.Combo.w and myHero:CanUseSpell(_W) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillW.range then
				CastSpell(_W, myTarget)
			end
			
			if _G.azBundle.MenuManager.menu.Combo.q and myHero:CanUseSpell(_Q) == READY then
				_G.azBundle.PredManager:CastQ(myTarget, false)
			end
			
			if _G.azBundle.MenuManager.menu.Combo.e and myHero:CanUseSpell(_E) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillE.range then
				CastSpell(_E, myTarget)
			end
			
			if _G.azBundle.MenuManager.menu.Combo.q and myHero:CanUseSpell(_Q) == READY then
				_G.azBundle.PredManager:CastQ(myTarget, false)
			end
		
	end
end

function ChampRyze:LaneClearMode()
	self.target.minion:update()
	
	local bestEBuff = nil
	local bestEBuffCount = 0
	
	local bestQETarget = nil
	local bestQETargetCount = 0
	
	local bestOtherTarget = nil
	local bestOtherTargetCount = 0
	
	for m, minion in pairs(self.target.minion.objects) do
		if minion then
			
			if bestEBuff and GetDistanceSqr(minion) <= _G.azBundle.ChampionData.SkillE.range*_G.azBundle.ChampionData.SkillE.range then
				local tmpCount = 0
				for m, minion in pairs(self.target.minion.objects) do
					if minion and ValidTarget(minion) then
						tmpCount = tmpCount + 1
					end
				end
				if HasBuff(minion, "RyzeE") and tmpCount > bestEBuffCount then
					bestEBuff = minion
					bestEBuffCount = tmpCount
				end
			else
				local tmpCount = 0
				for m, minion in pairs(self.target.minion.objects) do
					if minion and ValidTarget(minion) and GetDistanceSqr(minion, bestEBuff) <= 100*100 then
						tmpCount = tmpCount + 1
					end
				end
				if HasBuff(minion, "RyzeE") and GetDistance(minion) <= _G.azBundle.ChampionData.SkillE.range and tmpCount > 0 then
					bestEBuff = minion
					bestEBuffCount = tmpCount
				end
			end
			
			if bestQETarget and GetDistanceSqr(minion) <= _G.azBundle.ChampionData.SkillQ.range*_G.azBundle.ChampionData.SkillQ.range then
				local tmpCount = 0
				for m, minion in pairs(self.target.minion.objects) do
					if minion and ValidTarget(minion) and GetDistance(minion, bestQETarget) <= 250 then
						tmpCount = tmpCount + 1
					end
				end
				local CastPosition, HitChance = VP:GetLineCastPosition(minion, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, true)
				if HasBuff(minion, "RyzeE") and GetDistance(minion) <= _G.azBundle.ChampionData.SkillE.range and tmpCount > bestQETargetCount and HitChance >= 2 then
					bestQETarget = minion
					bestQETargetCount = tmpCount
				end
			else
				local tmpCount = 0
				for m, minion in pairs(self.target.minion.objects) do
					if minion and ValidTarget(minion) and GetDistance(minion, bestQETarget) <= 250 then
						tmpCount = tmpCount + 1
					end
				end
				local CastPosition, HitChance = VP:GetLineCastPosition(minion, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, true)
				if HasBuff(minion, "RyzeE") and GetDistance(minion) <= _G.azBundle.ChampionData.SkillE.range and tmpCount > 0 and HitChance >= 2 then
					bestQETarget = minion
					bestQETargetCount = tmpCount
				end
			end
			
			if bestOtherTarget and GetDistanceSqr(minion) <= _G.azBundle.ChampionData.SkillQ.range*_G.azBundle.ChampionData.SkillQ.range then
				local tmpCount = 0
				for m, minion in pairs(self.target.minion.objects) do
					if minion and ValidTarget(minion) and GetDistance(minion, bestOtherTarget) <= 250 then
						tmpCount = tmpCount + 1
					end
				end
				if GetDistance(minion) <= _G.azBundle.ChampionData.SkillE.range and tmpCount > bestOtherTargetCount then
					bestOtherTarget = minion
					bestOtherTargetCount = tmpCount
				end
			else
				local tmpCount = 0
				for m, minion in pairs(self.target.minion.objects) do
					if minion and ValidTarget(minion) and GetDistance(minion, bestOtherTarget) <= 250 then
						tmpCount = tmpCount + 1
					end
				end
				if GetDistance(minion) <= _G.azBundle.ChampionData.SkillE.range and tmpCount > 0 then
					bestOtherTarget = minion
					bestOtherTargetCount = tmpCount
				end
			end
		end
	end
	
	if bestEBuff and bestEBuffCount > 0 then
		if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY then
			_G.azBundle.PredManager:CastQ(bestEBuff, true)
		end

		if _G.azBundle.MenuManager.menu.LaneClear.e and myHero:CanUseSpell(_E) == READY and GetDistance(bestEBuff) <= _G.azBundle.ChampionData.SkillE.range then
			CastSpell(_E, bestEBuff)
		end
		
		if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY then
			_G.azBundle.PredManager:CastQ(bestEBuff, true)
		end
		
		if _G.azBundle.MenuManager.menu.LaneClear.w and myHero:CanUseSpell(_W) == READY and GetDistance(bestEBuff) <= _G.azBundle.ChampionData.SkillW.range then
			CastSpell(_W, bestEBuff)
		end
		
		if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY then
			_G.azBundle.PredManager:CastQ(bestEBuff, true)
		end
		
		if _G.azBundle.MenuManager.menu.LaneClear.e and myHero:CanUseSpell(_E) == READY and GetDistance(bestEBuff) <= _G.azBundle.ChampionData.SkillE.range then
			CastSpell(_E, bestEBuff)
		end
		
		if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY then
			_G.azBundle.PredManager:CastQ(bestEBuff, true)
		end
		return
	end
	
	if bestQETarget and bestQETargetCount > 0 then
		if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY then
			_G.azBundle.PredManager:CastQ(bestQETarget, true)
		end

		if _G.azBundle.MenuManager.menu.LaneClear.e and myHero:CanUseSpell(_E) == READY and GetDistance(bestQETarget) <= _G.azBundle.ChampionData.SkillE.range then
			CastSpell(_E, bestQETarget)
		end
		
		if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY then
			_G.azBundle.PredManager:CastQ(bestQETarget, true)
		end
		
		if _G.azBundle.MenuManager.menu.LaneClear.w and myHero:CanUseSpell(_W) == READY and GetDistance(bestQETarget) <= _G.azBundle.ChampionData.SkillW.range then
			CastSpell(_W, bestQETarget)
		end
		
		if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY then
			_G.azBundle.PredManager:CastQ(bestQETarget, true)
		end
		
		if _G.azBundle.MenuManager.menu.LaneClear.e and myHero:CanUseSpell(_E) == READY and GetDistance(bestQETarget) <= _G.azBundle.ChampionData.SkillE.range then
			CastSpell(_E, bestQETarget)
		end
		
		if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY then
			_G.azBundle.PredManager:CastQ(bestQETarget, true)
		end
		return
	end

	if bestOtherTarget and bestOtherTargetCount > 0 then
		if _G.azBundle.MenuManager.menu.LaneClear.e and myHero:CanUseSpell(_E) == READY and GetDistance(bestOtherTarget) <= _G.azBundle.ChampionData.SkillE.range then
			CastSpell(_E, bestOtherTarget)
		end
	end

	for m, minion in pairs(self.target.minion.objects) do
		if minion then
			if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY then
				_G.azBundle.PredManager:CastQ(minion, true)
			end

			if _G.azBundle.MenuManager.menu.LaneClear.e and myHero:CanUseSpell(_E) == READY and GetDistance(bestEBuff) <= _G.azBundle.ChampionData.SkillE.range then
				CastSpell(_E, bestEBuff)
			end
			
			if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY then
				_G.azBundle.PredManager:CastQ(minion, true)
			end
			
			if _G.azBundle.MenuManager.menu.LaneClear.w and myHero:CanUseSpell(_W) == READY and GetDistance(bestEBuff) <= _G.azBundle.ChampionData.SkillW.range then
				CastSpell(_W, bestEBuff)
			end
			
			if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY then
				_G.azBundle.PredManager:CastQ(minion, true)
			end
			
			if _G.azBundle.MenuManager.menu.LaneClear.e and myHero:CanUseSpell(_E) == READY and GetDistance(bestEBuff) <= _G.azBundle.ChampionData.SkillE.range then
				CastSpell(_E, bestEBuff)
			end
			
			if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY then
				_G.azBundle.PredManager:CastQ(minion, true)
			end
		end
	end
end

function ChampRyze:JungleClearMode()
	self.target.jungle:update()
	
	for m, minion in pairs(self.target.jungle.objects) do
		if minion and ValidTarget(minion, _G.azBundle.ChampionData.SkillQ.range) then
			if _G.azBundle.MenuManager.menu.JungleClear.q and myHero:CanUseSpell(_Q) == READY then
				_G.azBundle.PredManager:CastQ(minion, true)
			end

			if _G.azBundle.MenuManager.menu.JungleClear.e and myHero:CanUseSpell(_E) == READY and GetDistance(minion) <= _G.azBundle.ChampionData.SkillE.range then
				CastSpell(_E, minion)
			end
			
			if _G.azBundle.MenuManager.menu.JungleClear.q and myHero:CanUseSpell(_Q) == READY then
				_G.azBundle.PredManager:CastQ(minion, true)
			end
			
			if _G.azBundle.MenuManager.menu.JungleClear.w and myHero:CanUseSpell(_W) == READY and GetDistance(minion) <= _G.azBundle.ChampionData.SkillW.range then
				CastSpell(_W, minion)
			end
			
			if _G.azBundle.MenuManager.menu.JungleClear.q and myHero:CanUseSpell(_Q) == READY then
				_G.azBundle.PredManager:CastQ(minion, true)
			end
			
			if _G.azBundle.MenuManager.menu.JungleClear.e and myHero:CanUseSpell(_E) == READY and GetDistance(minion) <= _G.azBundle.ChampionData.SkillE.range then
				CastSpell(_E, minion)
			end
			
			if _G.azBundle.MenuManager.menu.JungleClear.q and myHero:CanUseSpell(_Q) == READY then
				_G.azBundle.PredManager:CastQ(minion, true)
			end
		end
	end
end

function ChampRyze:HarassMode()
	self.target.champion:update()
	self.target.minion:update()
	
	local myTarget = self.target.champion.target
	if myTarget and ValidTarget(myTarget, 1000) then
		
		if _G.azBundle.MenuManager.menu.Harass.q and myHero:CanUseSpell(_Q) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillQ.range then
			_G.azBundle.PredManager:CastQ(myTarget, false)
		end
		
		if _G.azBundle.MenuManager.menu.Harass.w and myHero:CanUseSpell(_W) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillW.range then
			if _G.azBundle.MenuManager.menu.Combo.w and myHero:CanUseSpell(_W) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillW.range then
				CastSpell(_W, myTarget)
			end
		end
		
		if _G.azBundle.MenuManager.menu.Harass.q and myHero:CanUseSpell(_Q) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillQ.range then
			_G.azBundle.PredManager:CastQ(myTarget, false)
		end
		
		if _G.azBundle.MenuManager.menu.Harass.e and myHero:CanUseSpell(_E) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillE.range then
			CastSpell(_E, myTarget)
		end
		
		if _G.azBundle.MenuManager.menu.Harass.q and myHero:CanUseSpell(_Q) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillQ.range then
			_G.azBundle.PredManager:CastQ(myTarget, false)
		end
		
		if _G.azBundle.MenuManager.menu.Harass.e and myHero:CanUseSpell(_E) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillE.range then
			CastSpell(_E, myTarget)
		end
		
		if _G.azBundle.MenuManager.menu.Harass.q and myHero:CanUseSpell(_Q) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillQ.range then
			_G.azBundle.PredManager:CastQ(myTarget, false)
		end
		
	end
end

function ChampRyze:LastHitMode()
	self.target.champion:update()
	self.target.minion:update()
	
	for m, minion in pairs(self.target.minion.objects) do
		if minion and ValidTarget(minion, _G.azBundle.ChampionData.SkillQ.range) then
			if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY then
				
			end
			
			if _G.azBundle.MenuManager.menu.LaneClear.w and myHero:CanUseSpell(_W) == READY then
				
			end
			
			if _G.azBundle.MenuManager.menu.LaneClear.e and myHero:CanUseSpell(_E) == READY then
				
			end
		end
	end
end

function ChampRyze:FleeMode()
	
end

function ChampRyze:AutoMode()
	
end

function ChampRyze:Draw()
	if _G.azBundle.MenuManager.menu.Draw.q and myHero:CanUseSpell(_Q) == READY then
		DrawCircle2(myHero.x, myHero.y, myHero.z, _G.azBundle.ChampionData.SkillQ.range, RGBColor(_G.azBundle.MenuManager.menu.Draw.qColor))
	end
	
	if _G.azBundle.MenuManager.menu.Draw.w and myHero:CanUseSpell(_W) == READY then
		DrawCircle2(myHero.x, myHero.y, myHero.z, _G.azBundle.ChampionData.SkillW.range, RGBColor(_G.azBundle.MenuManager.menu.Draw.wColor))
	end
	
	if _G.azBundle.MenuManager.menu.Draw.e and myHero:CanUseSpell(_E) == READY then
		DrawCircle2(myHero.x, myHero.y, myHero.z, _G.azBundle.ChampionData.SkillE.range, RGBColor(_G.azBundle.MenuManager.menu.Draw.eColor))
	end
end

function ChampRyze:OnDash(unit, spell)
	if unit and unit.team ~= myHero.team and myHero:CanUseSpell(_E) == READY and GetDistance(unit) <= _G.azBundle.ChampionData.SkillE.range then
		CastSpell(_E, unit)
	end
end

function ChampRyze:OnInteruptable(unit, spell)
	if unit and unit.team ~= myHero.team and myHero:CanUseSpell(_E) == READY and GetDistance(unit) <= _G.azBundle.ChampionData.SkillE.range then
		CastSpell(_E, unit)
	end
end

function ChampRyze:ProcessSpell(unit, spell)
	
end

function ChampRyze:ApplyBuff(source, unit, buff)
	if source and unit and buff and source.isMe and unit.isMe then
		if buff.name == "ryzeqiconnocharge" then
			self.runeCount = 0
		elseif buff.name == "ryzeqiconhalfcharge" then
			self.runeCount = 1
		elseif buff.name == "ryzeqiconfullcharge" then
			self.runeCount = 2
		end
	end
end

function ChampRyze:RemoveBuff(source, unit, buff)

end

function ChampRyze:CreateObj(obj)
	
end

function ChampRyze:SetupEvade()
	--_G.azBundle.EvadeManager:AddDashSpell(_Q, "Q", "target", _G.azBundle.ChampionData.SkillQ, "enemy", true)
end

function ChampRyze:GetDamage(target)
	local myDmg = 0
	if myHero:CanUseSpell(_Q) == READY then
		myDmg = myDmg + _G.azBundle.ChampionData.SkillQ.Damage(myHero, target)
	end
	if myHero:CanUseSpell(_W) == READY then
		myDmg = myDmg + _G.azBundle.ChampionData.SkillW.Damage(myHero, target)
	end
	if myHero:CanUseSpell(_E) == READY then
		myDmg = myDmg + _G.azBundle.ChampionData.SkillE.Damage(myHero, target)
	end
	local sheenItem = _G.azBundle.ItemDmgManager:SheenItem()
	if sheenItem then
		if sheenItem == "S" then
			myDmg = myDmg + _G.azBundle.ItemDmgManager:Sheen(target)
		elseif sheenItem == "T" then
			myDmg = myDmg + _G.azBundle.ItemDmgManager:TriForce(target)
		elseif sheenItem == "T" then
			myDmg = myDmg + _G.azBundle.ItemDmgManager:LichBane(target)
		end
	end
	return myDmg
end
--[[-----------------------------------------------------
--------------------------/RYZE--------------------------
-----------------------------------------------------]]--

--[[-----------------------------------------------------
-------------------------HEIMER--------------------------
-----------------------------------------------------]]--
class("ChampHeimer")
function ChampHeimer:__init()
	_G.azBundle.PrintManager:General("Loaded.")
	
	self.ChampData = {
		useAutoMode = true,
		useFleeMode = false,
		useInteruptable = true,
		useProcessSpell = false,
		useApplyBuff = true,
		useRemoveBuff = false,
		usePreTick = false,
		useCreateObj = true,
		useAntiDash = true
	}
	
	self.target = MyTarget(1100, 1100, 1100, DAMAGE_MAGIC)
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Combo Settings <<", "Combo")
		_G.azBundle.MenuManager.menu.Combo:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Combo:addParam("rq", "Use R Q", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Combo:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Combo:addParam("rw", "Use R W", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Combo:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Combo:addParam("re", "Use R E", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Combo:addParam("r", "Use R", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Combo:addParam("key", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey(" "))
		
	_G.azBundle.MenuManager.menu:addSubMenu(">> Harass Settings <<", "Harass")
		_G.azBundle.MenuManager.menu.Harass:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Harass:addParam("qMana", "Use Q Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.Harass:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Harass:addParam("wMana", "Use W Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.Harass:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Harass:addParam("eMana", "Use E Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.Harass:addParam("key", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("C"))
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Lane Clear Settings <<", "LaneClear")
		_G.azBundle.MenuManager.menu.LaneClear:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.LaneClear:addParam("qMana", "Use Q Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.LaneClear:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, false)
		_G.azBundle.MenuManager.menu.LaneClear:addParam("wMana", "Use W Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.LaneClear:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.LaneClear:addParam("eMana", "Use E Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.LaneClear:addParam("key", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Jungle Clear Settings <<", "JungleClear")
		_G.azBundle.MenuManager.menu.JungleClear:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.JungleClear:addParam("qMana", "Use Q Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.JungleClear:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, false)
		_G.azBundle.MenuManager.menu.JungleClear:addParam("wMana", "Use W Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.JungleClear:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, false)
		_G.azBundle.MenuManager.menu.JungleClear:addParam("eMana", "Use E Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.JungleClear:addParam("key", "Jungle Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Last Hit Settings <<", "LastHit")
		_G.azBundle.MenuManager.menu.LastHit:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.LastHit:addParam("qMana", "Use Q Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.LastHit:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.LastHit:addParam("wMana", "Use W Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.LastHit:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.LastHit:addParam("eMana", "Use E Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
		_G.azBundle.MenuManager.menu.LastHit:addParam("key", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("X"))
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Flee Settings <<", "Flee")
		_G.azBundle.MenuManager.menu.Flee:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Flee:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Flee:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Flee:addParam("key", "Flee Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("T"))
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Auto Settings <<", "Auto")
		_G.azBundle.MenuManager.menu.Auto:addParam("autoQ", "Auto Tower in Comfort Zone", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("J"))
		_G.azBundle.MenuManager.menu.Auto:addParam("levelSequance", "Auto Level Sequance", SCRIPT_PARAM_LIST, 4, {
			[1] = "Q-W-E-Max W-Max Q",
			[2] = "E-W-Q-Max W-Max Q",
			[3] = "W-Q-E-Max W-Max Q",
			
			[4] = "Q-W-E-Max Q-Max W",
			[5] = "E-W-Q-Max Q-Max W",
			[6] = "W-Q-E-Max Q-Max W",
			
			[7] = "Q-W-E-Max E-Max W",
			[8] = "E-W-Q-Max E-Max W",
			[9] = "W-Q-E-Max E-Max W",
			
			[10] = "E-Q-W-Max Q-Max W",
		})
	
	self.levelSequances = {
		[1] = {1,2,3,2,2,4,2,1,2,1,4,1,1,3,3,4,3,3},
		[2] = {3,1,2,2,2,4,2,1,2,1,4,1,1,3,3,4,3,3},
		[3] = {2,1,3,2,2,4,2,1,2,1,4,1,1,3,3,4,3,3},
		[4] = {1,2,3,1,1,4,1,2,1,2,4,2,2,3,3,4,3,3},
		[5] = {3,2,1,1,1,4,1,2,1,2,4,2,2,3,3,4,3,3},
		[6] = {2,1,3,1,1,4,1,2,1,2,4,2,2,3,3,4,3,3},
		[7] = {1,2,3,3,3,4,3,1,3,2,4,1,1,1,2,4,2,2},
		[8] = {3,2,1,3,3,4,3,1,3,2,4,1,1,1,2,4,2,2},
		[9] = {2,1,3,3,3,4,3,1,3,2,4,1,1,1,2,4,2,2},
		[10] = {3,1,2,1,1,4,1,2,1,2,4,2,2,3,3,4,3,3}
	}
	
	_G.azBundle.MenuManager.menu:addSubMenu(">> Draw Settings <<", "Draw")
		_G.azBundle.MenuManager.menu.Draw:addParam("q", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Draw:addParam("qColor", "Q Range Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
		_G.azBundle.MenuManager.menu.Draw:addParam("e", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Draw:addParam("eColor", "E Range Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
		_G.azBundle.MenuManager.menu.Draw:addParam("w", "Draw W Range", SCRIPT_PARAM_ONOFF, false)
		_G.azBundle.MenuManager.menu.Draw:addParam("wColor", "W Range Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
		_G.azBundle.MenuManager.menu.Draw:addParam("r", "Draw R Range", SCRIPT_PARAM_ONOFF, false)
		_G.azBundle.MenuManager.menu.Draw:addParam("rColor", "R Range Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
		_G.azBundle.MenuManager.menu.Draw:addParam("target", "Draw Target", SCRIPT_PARAM_ONOFF, true)
		_G.azBundle.MenuManager.menu.Draw:addParam("targetColor", "Target Color", SCRIPT_PARAM_COLOR, {255, 41, 41, 41})
		_G.azBundle.MenuManager.menu.Draw:addParam("damage", "Draw Damage", SCRIPT_PARAM_ONOFF, true)
	
	_G.azBundle.MenuManager.menu.Auto:permaShow("autoQ")
end

function ChampHeimer:PreTick()
	
end

function ChampHeimer:AARange()
	return myHero.range + myHero.boundingRadius
end

function ChampHeimer:ComboMode()
	self.target.champion:update()
	
	local myTarget = self.target.champion.target
	if myTarget and ValidTarget(myTarget, 1000) then
		
		if _G.azBundle.MenuManager.menu.Combo.q and myHero:CanUseSpell(_Q) == READY then
				local CastPosition, HitChance = VP:GetLineCastPosition(myTarget, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, false)
				if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < _G.azBundle.ChampionData.SkillQ.range then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			end

			if _G.azBundle.MenuManager.menu.Combo.e and myHero:CanUseSpell(_E) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillE.range then
				CastSpell(_E, myTarget)
			end
			
			if _G.azBundle.MenuManager.menu.Combo.q and myHero:CanUseSpell(_Q) == READY then
				local CastPosition, HitChance = VP:GetLineCastPosition(myTarget, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, false)
				if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < _G.azBundle.ChampionData.SkillQ.range then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			end
			
			if _G.azBundle.MenuManager.menu.Combo.w and myHero:CanUseSpell(_W) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillW.range then
				CastSpell(_W, myTarget)
			end
			
			if _G.azBundle.MenuManager.menu.Combo.q and myHero:CanUseSpell(_Q) == READY then
				local CastPosition, HitChance = VP:GetLineCastPosition(myTarget, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, false)
				if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < _G.azBundle.ChampionData.SkillQ.range then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			end
			
			if _G.azBundle.MenuManager.menu.Combo.e and myHero:CanUseSpell(_E) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillE.range then
				CastSpell(_E, myTarget)
			end
			
			if _G.azBundle.MenuManager.menu.Combo.q and myHero:CanUseSpell(_Q) == READY then
				local CastPosition, HitChance = VP:GetLineCastPosition(myTarget, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, false)
				if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < _G.azBundle.ChampionData.SkillQ.range then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			end
		
	end
end

function ChampHeimer:LaneClearMode()
	self.target.minion:update()
	
	local bestEBuff = nil
	local bestEBuffCount = 0
	
	local bestQETarget = nil
	local bestQETargetCount = 0
	
	local bestOtherTarget = nil
	local bestOtherTargetCount = 0
	
	for m, minion in pairs(self.target.minion.objects) do
		if minion then
			
			if bestEBuff and GetDistanceSqr(minion) <= _G.azBundle.ChampionData.SkillE.range*_G.azBundle.ChampionData.SkillE.range then
				local tmpCount = 0
				for m, minion in pairs(self.target.minion.objects) do
					if minion and ValidTarget(minion) then
						tmpCount = tmpCount + 1
					end
				end
				if HasBuff(minion, "RyzeE") and tmpCount > bestEBuffCount then
					bestEBuff = minion
					bestEBuffCount = tmpCount
				end
			else
				local tmpCount = 0
				for m, minion in pairs(self.target.minion.objects) do
					if minion and ValidTarget(minion) and GetDistanceSqr(minion, bestEBuff) <= 100*100 then
						tmpCount = tmpCount + 1
					end
				end
				if HasBuff(minion, "RyzeE") and GetDistance(minion) <= _G.azBundle.ChampionData.SkillE.range and tmpCount > 0 then
					bestEBuff = minion
					bestEBuffCount = tmpCount
				end
			end
			
			if bestQETarget and GetDistanceSqr(minion) <= _G.azBundle.ChampionData.SkillQ.range*_G.azBundle.ChampionData.SkillQ.range then
				local tmpCount = 0
				for m, minion in pairs(self.target.minion.objects) do
					if minion and ValidTarget(minion) and GetDistance(minion, bestQETarget) <= 250 then
						tmpCount = tmpCount + 1
					end
				end
				local CastPosition, HitChance = VP:GetLineCastPosition(minion, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, true)
				if HasBuff(minion, "RyzeE") and GetDistance(minion) <= _G.azBundle.ChampionData.SkillE.range and tmpCount > bestQETargetCount and HitChance >= 2 then
					bestQETarget = minion
					bestQETargetCount = tmpCount
				end
			else
				local tmpCount = 0
				for m, minion in pairs(self.target.minion.objects) do
					if minion and ValidTarget(minion) and GetDistance(minion, bestQETarget) <= 250 then
						tmpCount = tmpCount + 1
					end
				end
				local CastPosition, HitChance = VP:GetLineCastPosition(minion, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, true)
				if HasBuff(minion, "RyzeE") and GetDistance(minion) <= _G.azBundle.ChampionData.SkillE.range and tmpCount > 0 and HitChance >= 2 then
					bestQETarget = minion
					bestQETargetCount = tmpCount
				end
			end
			
			if bestOtherTarget and GetDistanceSqr(minion) <= _G.azBundle.ChampionData.SkillQ.range*_G.azBundle.ChampionData.SkillQ.range then
				local tmpCount = 0
				for m, minion in pairs(self.target.minion.objects) do
					if minion and ValidTarget(minion) and GetDistance(minion, bestOtherTarget) <= 250 then
						tmpCount = tmpCount + 1
					end
				end
				if GetDistance(minion) <= _G.azBundle.ChampionData.SkillE.range and tmpCount > bestOtherTargetCount then
					bestOtherTarget = minion
					bestOtherTargetCount = tmpCount
				end
			else
				local tmpCount = 0
				for m, minion in pairs(self.target.minion.objects) do
					if minion and ValidTarget(minion) and GetDistance(minion, bestOtherTarget) <= 250 then
						tmpCount = tmpCount + 1
					end
				end
				if GetDistance(minion) <= _G.azBundle.ChampionData.SkillE.range and tmpCount > 0 then
					bestOtherTarget = minion
					bestOtherTargetCount = tmpCount
				end
			end
		end
	end
	
	if bestEBuff and bestEBuffCount > 0 then
		if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY then
			local CastPosition, HitChance = VP:GetLineCastPosition(bestEBuff, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, true)
			if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < _G.azBundle.ChampionData.SkillQ.range then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end

		if _G.azBundle.MenuManager.menu.LaneClear.e and myHero:CanUseSpell(_E) == READY and GetDistance(bestEBuff) <= _G.azBundle.ChampionData.SkillE.range then
			CastSpell(_E, bestEBuff)
		end
		
		if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY then
			local CastPosition, HitChance = VP:GetLineCastPosition(bestEBuff, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, true)
			if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < _G.azBundle.ChampionData.SkillQ.range then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
		
		if _G.azBundle.MenuManager.menu.LaneClear.w and myHero:CanUseSpell(_W) == READY and GetDistance(bestEBuff) <= _G.azBundle.ChampionData.SkillW.range then
			CastSpell(_W, bestEBuff)
		end
		
		if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY then
			local CastPosition, HitChance = VP:GetLineCastPosition(bestEBuff, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, true)
			if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < _G.azBundle.ChampionData.SkillQ.range then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
		
		if _G.azBundle.MenuManager.menu.LaneClear.e and myHero:CanUseSpell(_E) == READY and GetDistance(bestEBuff) <= _G.azBundle.ChampionData.SkillE.range then
			CastSpell(_E, bestEBuff)
		end
		
		if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY then
			local CastPosition, HitChance = VP:GetLineCastPosition(bestEBuff, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, true)
			if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < _G.azBundle.ChampionData.SkillQ.range then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
		return
	end
	
	if bestQETarget and bestQETargetCount > 0 then
		if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY then
			local CastPosition, HitChance = VP:GetLineCastPosition(bestQETarget, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, true)
			if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < _G.azBundle.ChampionData.SkillQ.range then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end

		if _G.azBundle.MenuManager.menu.LaneClear.e and myHero:CanUseSpell(_E) == READY and GetDistance(bestQETarget) <= _G.azBundle.ChampionData.SkillE.range then
			CastSpell(_E, bestQETarget)
		end
		
		if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY then
			local CastPosition, HitChance = VP:GetLineCastPosition(bestQETarget, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, true)
			if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < _G.azBundle.ChampionData.SkillQ.range then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
		
		if _G.azBundle.MenuManager.menu.LaneClear.w and myHero:CanUseSpell(_W) == READY and GetDistance(bestQETarget) <= _G.azBundle.ChampionData.SkillW.range then
			CastSpell(_W, bestQETarget)
		end
		
		if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY then
			local CastPosition, HitChance = VP:GetLineCastPosition(bestQETarget, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, true)
			if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < _G.azBundle.ChampionData.SkillQ.range then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
		
		if _G.azBundle.MenuManager.menu.LaneClear.e and myHero:CanUseSpell(_E) == READY and GetDistance(bestQETarget) <= _G.azBundle.ChampionData.SkillE.range then
			CastSpell(_E, bestQETarget)
		end
		
		if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY then
			local CastPosition, HitChance = VP:GetLineCastPosition(bestQETarget, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, true)
			if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < _G.azBundle.ChampionData.SkillQ.range then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
		return
	end

	if bestOtherTarget and bestOtherTargetCount > 0 then
		if _G.azBundle.MenuManager.menu.LaneClear.e and myHero:CanUseSpell(_E) == READY and GetDistance(bestOtherTarget) <= _G.azBundle.ChampionData.SkillE.range then
			CastSpell(_E, bestOtherTarget)
		end
	end

	for m, minion in pairs(self.target.minion.objects) do
		if minion then
			if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY then
				local CastPosition, HitChance = VP:GetLineCastPosition(bestEBuff, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, true)
				if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < _G.azBundle.ChampionData.SkillQ.range then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			end

			if _G.azBundle.MenuManager.menu.LaneClear.e and myHero:CanUseSpell(_E) == READY and GetDistance(bestEBuff) <= _G.azBundle.ChampionData.SkillE.range then
				CastSpell(_E, bestEBuff)
			end
			
			if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY then
				local CastPosition, HitChance = VP:GetLineCastPosition(bestEBuff, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, true)
				if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < _G.azBundle.ChampionData.SkillQ.range then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			end
			
			if _G.azBundle.MenuManager.menu.LaneClear.w and myHero:CanUseSpell(_W) == READY and GetDistance(bestEBuff) <= _G.azBundle.ChampionData.SkillW.range then
				CastSpell(_W, bestEBuff)
			end
			
			if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY then
				local CastPosition, HitChance = VP:GetLineCastPosition(bestEBuff, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, true)
				if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < _G.azBundle.ChampionData.SkillQ.range then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			end
			
			if _G.azBundle.MenuManager.menu.LaneClear.e and myHero:CanUseSpell(_E) == READY and GetDistance(bestEBuff) <= _G.azBundle.ChampionData.SkillE.range then
				CastSpell(_E, bestEBuff)
			end
			
			if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY then
				local CastPosition, HitChance = VP:GetLineCastPosition(bestEBuff, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, true)
				if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < _G.azBundle.ChampionData.SkillQ.range then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			end
		end
	end
end

function ChampHeimer:JungleClearMode()
	self.target.jungle:update()
	
	for m, minion in pairs(self.target.jungle.objects) do
		if minion and ValidTarget(minion, _G.azBundle.ChampionData.SkillQ.range) then
			if _G.azBundle.MenuManager.menu.JungleClear.q and myHero:CanUseSpell(_Q) == READY then
				local CastPosition, HitChance = VP:GetLineCastPosition(minion, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, true)
				if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < _G.azBundle.ChampionData.SkillQ.range then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			end

			if _G.azBundle.MenuManager.menu.JungleClear.e and myHero:CanUseSpell(_E) == READY and GetDistance(minion) <= _G.azBundle.ChampionData.SkillE.range then
				CastSpell(_E, minion)
			end
			
			if _G.azBundle.MenuManager.menu.JungleClear.q and myHero:CanUseSpell(_Q) == READY then
				local CastPosition, HitChance = VP:GetLineCastPosition(minion, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, true)
				if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < _G.azBundle.ChampionData.SkillQ.range then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			end
			
			if _G.azBundle.MenuManager.menu.JungleClear.w and myHero:CanUseSpell(_W) == READY and GetDistance(minion) <= _G.azBundle.ChampionData.SkillW.range then
				CastSpell(_W, minion)
			end
			
			if _G.azBundle.MenuManager.menu.JungleClear.q and myHero:CanUseSpell(_Q) == READY then
				local CastPosition, HitChance = VP:GetLineCastPosition(minion, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, true)
				if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < _G.azBundle.ChampionData.SkillQ.range then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			end
			
			if _G.azBundle.MenuManager.menu.JungleClear.e and myHero:CanUseSpell(_E) == READY and GetDistance(minion) <= _G.azBundle.ChampionData.SkillE.range then
				CastSpell(_E, minion)
			end
			
			if _G.azBundle.MenuManager.menu.JungleClear.q and myHero:CanUseSpell(_Q) == READY then
				local CastPosition, HitChance = VP:GetLineCastPosition(minion, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, true)
				if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < _G.azBundle.ChampionData.SkillQ.range then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			end
		end
	end
end

function ChampHeimer:HarassMode()
	self.target.champion:update()
	self.target.minion:update()
	
	local myTarget = self.target.champion.target
	if myTarget and ValidTarget(myTarget, 1000) then
		
		if _G.azBundle.MenuManager.menu.Harass.q and myHero:CanUseSpell(_Q) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillQ.range then
			local CastPosition, HitChance = VP:GetLineCastPosition(myTarget, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, false)
			if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < _G.azBundle.ChampionData.SkillQ.range then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
		
		if _G.azBundle.MenuManager.menu.Harass.w and myHero:CanUseSpell(_W) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillW.range then
			if _G.azBundle.MenuManager.menu.Combo.w and myHero:CanUseSpell(_W) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillW.range then
				CastSpell(_W, myTarget)
			end
		end
		
		if _G.azBundle.MenuManager.menu.Harass.q and myHero:CanUseSpell(_Q) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillQ.range then
			local CastPosition, HitChance = VP:GetLineCastPosition(myTarget, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, false)
			if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < _G.azBundle.ChampionData.SkillQ.range then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
		
		if _G.azBundle.MenuManager.menu.Harass.e and myHero:CanUseSpell(_E) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillE.range then
			CastSpell(_E, myTarget)
		end
		
		if _G.azBundle.MenuManager.menu.Harass.q and myHero:CanUseSpell(_Q) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillQ.range then
			local CastPosition, HitChance = VP:GetLineCastPosition(myTarget, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, false)
			if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < _G.azBundle.ChampionData.SkillQ.range then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
		
		if _G.azBundle.MenuManager.menu.Harass.e and myHero:CanUseSpell(_E) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillE.range then
			CastSpell(_E, myTarget)
		end
		
		if _G.azBundle.MenuManager.menu.Harass.q and myHero:CanUseSpell(_Q) == READY and GetDistance(myTarget) <= _G.azBundle.ChampionData.SkillQ.range then
			local CastPosition, HitChance = VP:GetLineCastPosition(myTarget, _G.azBundle.ChampionData.SkillQ.delay, _G.azBundle.ChampionData.SkillQ.width, _G.azBundle.ChampionData.SkillQ.range, _G.azBundle.ChampionData.SkillQ.speed, myHero, false)
			if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < _G.azBundle.ChampionData.SkillQ.range then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
		
	end
end

function ChampHeimer:LastHitMode()
	self.target.champion:update()
	self.target.minion:update()
	
	for m, minion in pairs(self.target.minion.objects) do
		if minion and ValidTarget(minion, _G.azBundle.ChampionData.SkillQ.range) then
			if _G.azBundle.MenuManager.menu.LaneClear.q and myHero:CanUseSpell(_Q) == READY then
				
			end
			
			if _G.azBundle.MenuManager.menu.LaneClear.w and myHero:CanUseSpell(_W) == READY then
				
			end
			
			if _G.azBundle.MenuManager.menu.LaneClear.e and myHero:CanUseSpell(_E) == READY then
				
			end
		end
	end
end

function ChampHeimer:FleeMode()
	
end

function ChampHeimer:AutoMode()
	
end

function ChampHeimer:Draw()
	if _G.azBundle.MenuManager.menu.Draw.q and myHero:CanUseSpell(_Q) == READY then
		DrawCircle2(myHero.x, myHero.y, myHero.z, _G.azBundle.ChampionData.SkillQ.range, RGBColor(_G.azBundle.MenuManager.menu.Draw.qColor))
	end
	
	if _G.azBundle.MenuManager.menu.Draw.w and myHero:CanUseSpell(_W) == READY then
		DrawCircle2(myHero.x, myHero.y, myHero.z, _G.azBundle.ChampionData.SkillW.range, RGBColor(_G.azBundle.MenuManager.menu.Draw.wColor))
	end
	
	if _G.azBundle.MenuManager.menu.Draw.e and myHero:CanUseSpell(_E) == READY then
		DrawCircle2(myHero.x, myHero.y, myHero.z, _G.azBundle.ChampionData.SkillE.range, RGBColor(_G.azBundle.MenuManager.menu.Draw.eColor))
	end
end

function ChampHeimer:OnDash(unit, spell)
	if unit and unit.team ~= myHero.team and myHero:CanUseSpell(_E) == READY and GetDistance(unit) <= _G.azBundle.ChampionData.SkillE.range then
		CastSpell(_E, unit)
	end
end

function ChampHeimer:OnInteruptable(unit, spell)
	if unit and unit.team ~= myHero.team and myHero:CanUseSpell(_E) == READY and GetDistance(unit) <= _G.azBundle.ChampionData.SkillE.range then
		CastSpell(_E, unit)
	end
end

function ChampHeimer:ProcessSpell(unit, spell)
	
end

function ChampHeimer:ApplyBuff(source, unit, buff)
	if source and unit and buff and source.isMe and unit.isMe then
		if buff.name == "ryzeqiconnocharge" then
			self.runeCount = 0
		elseif buff.name == "ryzeqiconhalfcharge" then
			self.runeCount = 1
		elseif buff.name == "ryzeqiconfullcharge" then
			self.runeCount = 2
		end
	end
end

function ChampHeimer:RemoveBuff(source, unit, buff)

end

function ChampHeimer:CreateObj(obj)
	
end

function ChampHeimer:SetupEvade()
	--_G.azBundle.EvadeManager:AddDashSpell(_Q, "Q", "target", _G.azBundle.ChampionData.SkillQ, "enemy", true)
end

function ChampHeimer:GetDamage(target)
	local myDmg = 0
	if myHero:CanUseSpell(_Q) == READY then
		myDmg = myDmg + _G.azBundle.ChampionData.SkillQ.Damage(myHero, target)
	end
	if myHero:CanUseSpell(_W) == READY then
		myDmg = myDmg + _G.azBundle.ChampionData.SkillW.Damage(myHero, target)
	end
	if myHero:CanUseSpell(_E) == READY then
		myDmg = myDmg + _G.azBundle.ChampionData.SkillE.Damage(myHero, target)
	end
	local sheenItem = _G.azBundle.ItemDmgManager:SheenItem()
	if sheenItem then
		if sheenItem == "S" then
			myDmg = myDmg + _G.azBundle.ItemDmgManager:Sheen(target)
		elseif sheenItem == "T" then
			myDmg = myDmg + _G.azBundle.ItemDmgManager:TriForce(target)
		elseif sheenItem == "T" then
			myDmg = myDmg + _G.azBundle.ItemDmgManager:LichBane(target)
		end
	end
	return myDmg
end
--[[-----------------------------------------------------
-------------------------/HEIMER-------------------------
-----------------------------------------------------]]--

function OnLoad()
	_G.azBundle.PrintManager:General("Welcome to AZer0 Bundle.")
	
	_G.azBundle.MenuManager = MenuManager(_G.azBundle.ChampionData.scriptName)
	_G.azBundle.EvadeManager = EvadeManager()
	_G.azBundle.Orbwalk = OrbwalkManager()
	_G.azBundle.AwareManager = AwareManager()
	_G.azBundle.MiscManager = MiscManager()
	_G.azBundle.ItemDmgManager = ItemDmgManager()
	
	local champLoaded = false
	if myHero.charName == "Irelia" then
		_G.azBundle.Champion = ChampIrelia()
		_G.azBundle.Champion:SetupEvade()
		champLoaded = true
	elseif myHero.charName == "Taliyah" then
		_G.azBundle.Champion = ChampTaliyah()
		champLoaded = true
	elseif myHero.charName == "Ryze" then
		_G.azBundle.Champion = ChampRyze()
		champLoaded = true
	elseif myHero.charName == "Heimerdinger" then
		_G.azBundle.Champion = ChampHeimer()
		champLoaded = true
	else
		_G.azBundle.PrintManager:General("There was a error loading your champion.")
	end
	
	if champLoaded then
		_G.azBundle.PredManager = PredictionManager()
	end
end

function OnProcessSpell(unit, spell)
	if _G.azBundle.Champion.ChampData.useInteruptable and unit and not unit.isMe and unit.team ~= myHero.team and spell and _G.azBundle.ChampionData:CanInterupt(spell) then
		_G.azBundle.Champion:OnInteruptable(unit, spell)
	end
	
	if _G.azBundle.Champion.ChampData.useInteruptable and unit and not unit.isMe and unit.team ~= myHero.team and spell and _G.azBundle.ChampionData:IsDash(spell) then
		_G.azBundle.Champion:OnDash(unit, spell)
	end
	
	if _G.azBundle.EvadeManager then
		_G.azBundle.EvadeManager:DashHandler(unit, spell)
	end
end

function OnApplyBuff(source, unit, buff)
	if _G.azBundle.Champion.ChampData.useApplyBuff and source and unit and buff then
		_G.azBundle.Champion:ApplyBuff(source, unit, buff)
	end
	
	if _G.azBundle.ItemDmgManager and source and unit and buff then
		_G.azBundle.ItemDmgManager:OnApplyBuff(source, unit, buff)
	end
end

function OnRemoveBuff(unit, buff)
	if _G.azBundle.Champion.ChampData.useRemoveBuff and unit and buff then
		_G.azBundle.Champion:RemoveBuff(unit, buff)
	end
	
	if _G.azBundle.ItemDmgManager and source and unit and buff then
		_G.azBundle.ItemDmgManager:OnRemoveBuff(unit, buff)
	end
end

function OnDeleteObj(object)
	if _G.azBundle.EvadeManager then
		_G.azBundle.EvadeManager:OnDeleteObj(object)
	end
end

function OnDraw()
	if _G.azBundle.EvadeManager then
		_G.azBundle.EvadeManager:EvadeDraw()
	end
	
	if _G.azBundle.AwareManager then
		_G.azBundle.AwareManager:Draw()
	end

	if _G.azBundle.Champion then
		_G.azBundle.Champion:Draw()
	end
	
	if _G.azBundle.MenuManager and _G.azBundle.MenuManager.menu.Draw.target then
		if _G.azBundle.Champion.target.champion.target and ValidTarget(_G.azBundle.Champion.target.champion.target, 1200) then
			DrawCircle2(_G.azBundle.Champion.target.champion.target.x, _G.azBundle.Champion.target.champion.target.y, _G.azBundle.Champion.target.champion.target.z, 65, RGBColor(_G.azBundle.MenuManager.menu.Draw.targetColor))
			DrawText3D(">> TARGET <<", _G.azBundle.Champion.target.champion.target.pos.x-100, _G.azBundle.Champion.target.champion.target.pos.y-50, _G.azBundle.Champion.target.champion.target.pos.z, 20, 0xFFFFFFFF)
		end
	end
	
	if _G.azBundle.MenuManager and _G.azBundle.MenuManager.menu.Draw.damage then
		for i, enemy in pairs(GetEnemyHeroes()) do
			if enemy and enemy.visible and not enemy.dead then
				local myDmg = _G.azBundle.Champion:GetDamage(enemy)
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
	
end

function OnTick()
	if _G.azBundle.EvadeManager then
		_G.azBundle.EvadeManager:AutoExpireEvades()
		_G.azBundle.EvadeManager:EvadeTick()
	end
	
	if _G.azBundle.AwareManager then
		_G.azBundle.AwareManager:Tick()
	end
	
	if _G.azBundle.MiscManager then
		_G.azBundle.MiscManager:Tick()
	end
	
	if _G.azBundle.Champion then
		if _G.azBundle.MenuManager and _G.azBundle.Champion and _G.azBundle.MenuManager.menu.Auto.levelSequance  then
			autoLevelSetSequence(_G.azBundle.Champion.levelSequances[_G.azBundle.MenuManager.menu.Auto.levelSequance])
		end
		
		if _G.azBundle.MenuManager.menu.Flee.key then
			_G.azBundle.Champion:FleeMode()
		end
		
		if _G.azBundle.Champion.ChampData.usePreTick then
			_G.azBundle.Champion:PreTick()
		end
		
		local currentMode = _G.azBundle.Orbwalk.Mode()
		if currentMode == "Combo" then
			_G.azBundle.Champion:ComboMode()
			return
		end
		if currentMode == "Harass" then
			_G.azBundle.Champion:HarassMode()
			return
		end
		if currentMode == "LaneClear" then
			_G.azBundle.Champion:LaneClearMode()
			_G.azBundle.Champion:JungleClearMode()
			return
		end
		if currentMode == "LastHit" then
			_G.azBundle.Champion:LastHitMode()
			return
		end
	end
	
	if _G.azBundle.Champion and _G.azBundle.Champion.ChampData.useAutoMode then
		_G.azBundle.Champion:AutoMode()
	end
end

function OnCreateObj(obj)
	if _G.azBundle.Champion and _G.azBundle.Champion.ChampData.useCreateObj then
		_G.azBundle.Champion:CreateObj(obj)
	end
end