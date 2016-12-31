if myHero.charName ~= "Cassiopeia" then return end

--[[
v24
-Twaeked E slightly
-Fixed a small logic error
-Removed some print spam

v23
-Fixed a error in auto E
-Tweaked last hit settings
-Added menu option (in Advanced) to auto E champs
-Added perma shows for auto E settings

v22
-Added HPred Support
-Fixed a error in lane clear
-Tweaked last hitting with E
-Fixed some menu labels
-Added Q/W/E/R range drawings

v21
-Fixed a error in the target selector

v20
-Added W to Lane Clear mode

v19
-Fixed VPred hit chance from hard coded versions
-Added W to Harass Mode for target
-Added BoL Tools tracker
-Added # of enemys hit to use R to combo menu
-Added R Pred chance to advanced menu
]]--

_G.zeroConfig = {
	UseUpdater = true,
	AutoDownload = true,
	HideAllDraws = false,
	HideAllPrint = false
}

local scriptData = {
	Version = 24
}

--[[
DO NOT EDIT BELOW THIS LINE
]]--

local MyChampData = {
	name = "Cassiopeia",
	pretty = "Cassiopeia",
	["Q"] = {
		name = "CassiopeiaNoxiousBlast",
		pretty = "Noxious Blast",
		speed = math.huge,
		delay = 0.75,
		range = 850,
		width = 100,
		collision = false,
		aoe = true,
		type = "circular",
		APDamage = function(source, target)
			return 45 + 30 * source:GetSpellData(_Q).level + 0.45 * source.ap
		end
	},
	["W"] = {
		name = "CassiopeiaMiasma",
		pretty = "Miasma",
		speed = 2500,
		delay = 0.5,
		range = 925,
		width = 90,
		collision = false,
		aoe = true,
		type = "circular",
		APDamage = function(source, target)
			return 5 + 5 * source:GetSpellData(_W).level + 0.1 * source.ap
		end
	},
	["E"] = {
		name = "CassiopeiaTwinFang",
		pretty = "Twin Fang",
		range = 700,
		type = "target",
		APDamage = function(source, target)
				return 30 + 25 * source:GetSpellData(_E).level + 0.55 * source.ap
		end
	},
	["R"] = {
		name = "CassiopeiaPetrifyingGaze",
		pretty = "Petrifying Gaze",
		speed = math.huge,
		delay = 0.5,
		range = 825,
		width = 410,
		collision = false,
		aoe = true,
		type = "cone",
		APDamage = function(source, target)
			return 50 + 10 * source:GetSpellData(_R).level + 0.5 * source.ap
		end
	}
}

local HP_Q = nil
local HP_W = nil
local HP_R = nil

--
--START REQUIRED DOWNLOAD
--
local toDownload = {
	["HPrediction"] = "https://raw.githubusercontent.com/BolHTTF/BoL/master/HTTF/Common/HPrediction.lua",
	["VPrediction"] = "https://raw.githubusercontent.com/SidaBoL/Chaos/master/VPrediction.lua"
}

local isDownloading = false
local downloadCount = 0

function LibDownloaderPrint(msg)
	print("<font color=\"#FF794C\"><b>0 Cassiopeia</b></font> <font color=\"#FFDFBF\"><b>"..msg.."</b></font>")
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
--
--END REQUIRED DOWNLOAD
--
-----------------------------------------------
--
--START AUTO UPDATER
--
local UpdateHost = "raw.github.com"
local UpdatePath = "/azer0/0BoL/master/Version/0Cass.Version?rand=" .. math.random(1, 10000)
local UpdatePath2 = "/azer0/0BoL/master/0Cass.lua?rand=" .. math.random(1, 10000)
local UpdateFile = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local VersionURL = "http://"..UpdateHost..UpdatePath
local UpdateURL = "http://"..UpdateHost..UpdatePath2

function AutoUpdaterPrint(msg)
	print("<font color=\"#FF794C\"><b>0 Cassiopeia</b></font> <font color=\"#FFDFBF\"><b>"..msg.."</b></font>")
end

local hasBeenUpdated = false

if _G.zeroConfig.UseUpdater then
	local sData = GetWebResult(UpdateHost, UpdatePath)
	if sData then
		local sVer = type(tonumber(sData)) == "number" and tonumber(sData) or nil
		if sVer and sVer > scriptData.Version then
			AutoUpdaterPrint("New update found [v" .. sVer .. "].")
			AutoUpdaterPrint("Please do not reload until complete.")
			DownloadFile(UpdateURL, UpdateFile, function () AutoUpdaterPrint("Successfully updated. ("..scriptData.Version.." => "..sVer.."), press F9 twice to use the updated version.") end)
			hasBeenUpdated = true
		else
			AutoUpdaterPrint("No update needed, your using the latest version.")
		end
	end
end

if hasBeenUpdated then
	return
end

--
--END AUTO UPDATER
--

assert(load(Base64Decode("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"), nil, "bt", _ENV))()
TrackerLoad("RkBGTDPdXq4IEj8w")

-----------------------------------------------
--
--START PRINT FUNCTIONS
--
function GeneralPrint(msg)
	print("<font color=\"#FF794C\"><b>0 Cassiopeia</b></font> <font color=\"#FFDFBF\"><b>"..msg.."</b></font>")
end

function ErrorPrint(msg)
	print("<font color=\"#FF794C\"><b>0 Cassiopeia</b></font> <font color=\"#FFDFBF\"><b>"..msg.."</b></font>")
end

function MiscPrint(msg)
	if antiSpam ~= msg then
		print("<font color=\"#FF794C\"><b>0 Cassiopeia</b></font> <font color=\"#FFDFBF\"><b>".. msg .."</b></font>")
		antiSpam = msg
	end
end

function TARGB(t)
	return ARGB(t[1], t[2], t[3], t[4])
end
--
--END PRINT FUNCTIONS
--
-----------------------------------------------
--
--START DRAW FUNCTIONS
--
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

function DrawLine3D2(x1, y1, z1, x2, y2, z2, width, color)
    local p = WorldToScreen(D3DXVECTOR3(x1, y1, z1))
    local px, py = p.x, p.y
    local c = WorldToScreen(D3DXVECTOR3(x2, y2, z2))
    local cx, cy = c.x, c.y
    DrawLine(cx, cy, px, py, width or 1, color or 4294967295)
end
--
--END DRAW FUNCTIONS
--
-----------------------------------------------
--
--START ORB WALK
--
local sacDetected = false
local sacPDetected = false
local pewDetected = false
local nebiDetected = false
local s1Detected = false
local sxDetected = false

function RegisterOrbWalks()
	if _G.Reborn_Loaded or _G.Reborn_Initialised or _G.AutoCarry ~= nil then
		sacDetected = true
		GeneralPrint("SAC:R detected.")
	elseif _G.S1OrbLoading or _G.S1mpleOrbLoaded then
		s1Detected = true
		GeneralPrint("Simple Orb Walk detected.")
	elseif SAC then
		sacPDetected = true
		GeneralPrint("SAC:P detected.")
	elseif _Pewalk then
		pewDetected = true
		GeneralPrint("PeWalk detected.")
	elseif _G.NebelwolfisOrbWalkerInit then
		nebiDetected = true
		GeneralPrint("Nebelwolfid Orb Walk detected.")
	elseif FileExist(LIB_PATH .. "SxOrbWalk.lua") then
		sxDetected = true
		require("SxOrbWalk")
		GeneralPrint("SXOrbWalk detected.")
	else
		GeneralPrint("No known orbwalk detected. Please make sure to set up your keys to match the orb walkers keys.")
	end
end

function OrbWalkResetAA()
	if sacDetected then
		_G.AutoCarry.Orbwalker:ResetAttackTimer()
	end
end
--
--END ORB WALK
--
-----------------------------------------------
--
--START PREDICTION
--
local vPredDetected = false
local hPredDetected = false
local dPredDetected = false
local kPredDetected = false
local fhPredDetected = false

local VP = VPrediction()
local HPred = nil
local DPred = nil
local KPred = nil

function RegisterPredictions()
	vPredDetected = true
	
	if FileExist(LIB_PATH.."DivinePred.luac") and FileExist(LIB_PATH.."DivinePred.lua") then
		dPredDetected = true
		require "DivinePred"
		DPred = DivinePred()
		if DP.VERSION < 3.5 then
			GeneralPrint("Devine Prediction seems to be out of date, please update it if you plan on using it.")
		end
	end
	--[[
	if FileExist(LIB_PATH.."HPrediction.lua") then
		hPredDetected = true
		require 'HPrediction'
		HPred = HPrediction()
		if not _G.HPrediction_Version then
			GeneralPrint("HPrediction seems to be out of date, please update it if you plan on using it.")
		else
			HP_Q = HPSkillshot({delay = MyChampData["Q"].delay, range = MyChampData["Q"].range, speed = MyChampData["Q"].speed, type = "DelayCircle", width = MyChampData["Q"].width, radius = MyChampData["Q"].radius})
			HP_W = HPSkillshot({delay = MyChampData["W"].delay, range = MyChampData["W"].range, speed = MyChampData["W"].speed, type = "DelayCircle", width = MyChampData["W"].width, radius = MyChampData["Q"].radius})
			HP_R = HPSkillshot({delay = MyChampData["R"].delay, range = MyChampData["R"].range, speed = MyChampData["R"].speed, type = "Triangle", width = MyChampData["R"].width, radius = MyChampData["Q"].radius})
		end
	end
	if FileExist(LIB_PATH.."KPrediction.lua") then
		kPredDetected = true
		require 'KPrediction'
		KPred = KPrediction()
	end
	if FileExist(LIB_PATH.."FHPrediction.lua") then
		fhPredDetected = true
		require("FHPrediction")
		if not FHPrediction then
			GeneralPrint("There was a error using Fun House Prediction. If you are not using it disregard this.")
		end
	end
	]]--
end

RegisterPredictions()
--
--END PREDICTION
--
-----------------------------------------------
--
--START Script Config
--

local mainMenu = nil

function RegisterMenu()
	mainMenu = scriptConfig("0Cassiopeia", "Cassiopeia")
		mainMenu:addSubMenu(">> Combo Settings <<", "Combo")
			mainMenu.Combo:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
			mainMenu.Combo:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, true)
			mainMenu.Combo:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
			mainMenu.Combo:addParam("r", "Use R", SCRIPT_PARAM_ONOFF, true)
			mainMenu.Combo:addParam("rNumber", "Use R When X Hit", SCRIPT_PARAM_SLICE, 3, 0, 5, 0)
			mainMenu.Combo:addParam("items", "Use Items", SCRIPT_PARAM_ONOFF, true)
			mainMenu.Combo:addParam("ignite", "Use Ignite", SCRIPT_PARAM_ONOFF, true)
			mainMenu.Combo:addParam("key", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey(" "))
		
		mainMenu:addSubMenu(">> Lane Clear Settings <<", "Lane")
			mainMenu.Lane:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
			mainMenu.Lane:addParam("qMana", "Use Q Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
			mainMenu.Lane:addParam("qMinions", "Use Q on X Minions Hit", SCRIPT_PARAM_SLICE, 3, 1, 6, 0)
			mainMenu.Lane:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, true)
			mainMenu.Lane:addParam("wMana", "Use W Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
			mainMenu.Lane:addParam("wMinions", "Use W on X Minions Hit", SCRIPT_PARAM_SLICE, 3, 1, 6, 0)
			mainMenu.Lane:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
			mainMenu.Lane:addParam("eMana", "Use E Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
			mainMenu.Lane:addParam("eMode", "E Mode", SCRIPT_PARAM_LIST, 1, {
				[1] = "Last Hit",
				[2] = "Fast Push",
				[3] = "Lane Push"
			})
			mainMenu.Lane:addParam("key", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
			
		mainMenu:addSubMenu(">> Jungle Clear Settings <<", "Jungle")
			mainMenu.Jungle:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
			mainMenu.Jungle:addParam("qMana", "Use Q Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
			mainMenu.Jungle:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, true)
			mainMenu.Jungle:addParam("wMana", "Use W Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
			mainMenu.Jungle:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
			mainMenu.Jungle:addParam("eMana", "Use E Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
			mainMenu.Jungle:addParam("key", "Jungle Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
			
		mainMenu:addSubMenu(">> Harass Settings <<", "Harass")
			mainMenu.Harass:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
			mainMenu.Harass:addParam("qMana", "Use Q Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
			mainMenu.Harass:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, true)
			mainMenu.Harass:addParam("wMana", "Use Q Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
			mainMenu.Harass:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
			mainMenu.Harass:addParam("qMana", "Use Q Above Mana %", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
			mainMenu.Harass:addParam("key", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("C"))
			
		mainMenu:addSubMenu(">> Auto Kill Settings <<", "Kill")
			mainMenu.Kill:addParam("q", "Use Q", SCRIPT_PARAM_ONOFF, true)
			mainMenu.Kill:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, true)
			mainMenu.Kill:addParam("e", "Use E", SCRIPT_PARAM_ONOFF, true)
			mainMenu.Kill:addParam("r", "Use R", SCRIPT_PARAM_ONOFF, false)
		
		mainMenu:addSubMenu(">> Advanced Settings <<", "Advanced")
			mainMenu.Advanced:addParam("qMinionPred", "Q Prediction", SCRIPT_PARAM_LIST, 1, {
				[1] = "VPrediction",
				[2] = "HPrediction",
				[3] = "FH Prediction",
				[4] = "KPrediction"
			})
			mainMenu.Advanced:addParam("qMinionVPHC", "Q Hit Chance Minion (0-5)", SCRIPT_PARAM_SLICE, 3, 0, 5, 0)
			mainMenu.Advanced:addParam("qMinionHPHC", "Q Hit Chance Minion (0-5) (HPred)", SCRIPT_PARAM_SLICE, 3, 0, 5, 0)
			mainMenu.Advanced:addParam("emptySpace1", "", SCRIPT_PARAM_INFO, "")
			
			mainMenu.Advanced:addParam("qChampsPred", "Q Prediction", SCRIPT_PARAM_LIST, 1, {
				[1] = "VPrediction",
				[2] = "HPrediction",
				[3] = "FH Prediction",
				[4] = "KPrediction"
			})
			mainMenu.Advanced:addParam("qChampsVPHC", "Q Hit Chance Champion (0-5)", SCRIPT_PARAM_SLICE, 3, 0, 5, 0)
			mainMenu.Advanced:addParam("qChampsHPHC", "Q Hit Chance Champion (0-5) (HPred)", SCRIPT_PARAM_SLICE, 3, 0, 5, 0)
			mainMenu.Advanced:addParam("emptySpace2", "", SCRIPT_PARAM_INFO, "")
			
			mainMenu.Advanced:addParam("wMinionPred", "W Prediction", SCRIPT_PARAM_LIST, 1, {
				[1] = "VPrediction",
				[2] = "HPrediction",
				[3] = "FH Prediction",
				[4] = "KPrediction"
			})
			mainMenu.Advanced:addParam("wMinionVPHC", "W Hit Chance Minion (0-5)", SCRIPT_PARAM_SLICE, 3, 0, 5, 0)
			mainMenu.Advanced:addParam("wMinionHPHC", "W Hit Chance Minion (0-5) (HPred)", SCRIPT_PARAM_SLICE, 3, 0, 5, 0)
			mainMenu.Advanced:addParam("emptySpace2", "", SCRIPT_PARAM_INFO, "")
			
			mainMenu.Advanced:addParam("wChampsPred", "Prediction", SCRIPT_PARAM_LIST, 1, {
				[1] = "VPrediction",
				[2] = "HPrediction",
				[3] = "FH Prediction",
				[4] = "KPrediction"
			})
			
			mainMenu.Advanced:addParam("wChampsVPHC", "W Hit Chance Champion (0-5)", SCRIPT_PARAM_SLICE, 3, 0, 5, 0)
			mainMenu.Advanced:addParam("wChampsHPHC", "W Hit Chance Champion (0-5) (HPred)", SCRIPT_PARAM_SLICE, 3, 0, 5, 0)
			mainMenu.Advanced:addParam("emptySpace3", "", SCRIPT_PARAM_INFO, "")
			
			mainMenu.Advanced:addParam("rChampsPred", "Prediction", SCRIPT_PARAM_LIST, 1, {
				[1] = "VPrediction",
				[2] = "HPrediction",
				[3] = "FH Prediction",
				[4] = "KPrediction"
			})
			mainMenu.Advanced:addParam("rChampsVPHC", "R Hit Chance Champion (0-5)", SCRIPT_PARAM_SLICE, 3, 0, 5, 0)
			mainMenu.Advanced:addParam("rChampsHPHC", "R Hit Chance Champion (0-5) (HPred)", SCRIPT_PARAM_SLICE, 3, 0, 5, 0)
			mainMenu.Advanced:addParam("emptySpace4", "", SCRIPT_PARAM_INFO, "")
			
			mainMenu.Advanced:addParam("autoE", "Auto Last Hit (E)", SCRIPT_PARAM_ONOFF, true)
			mainMenu.Advanced:addParam("autoEC", "Auto E Champions", SCRIPT_PARAM_ONOFF, true)
		
			mainMenu.Advanced:permaShow("autoE")
			mainMenu.Advanced:permaShow("autoEC")
			
		mainMenu:addSubMenu(">> Draw Settings <<", "Draw")
			mainMenu.Draw:addParam("damage", "Draw Damage", SCRIPT_PARAM_ONOFF, true)
			mainMenu.Draw:addParam("emptySpace1", "", SCRIPT_PARAM_INFO, "")
			mainMenu.Draw:addParam("ready", "Only Draw Spells When Ready", SCRIPT_PARAM_ONOFF, true)
			mainMenu.Draw:addParam("q", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
			mainMenu.Draw:addParam("w", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
			mainMenu.Draw:addParam("e", "Draw E Range", SCRIPT_PARAM_ONOFF, false)
			mainMenu.Draw:addParam("r", "Draw R Range", SCRIPT_PARAM_ONOFF, false)
		
end
--
--END Script Config
--
-----------------------------------------------
--
--START Vars
--
--BUFF's


--TS
local jungleMinions = minionManager(MINION_JUNGLE, 900, myHero, MINION_SORT_MAXHEALTH_DEC)
local wallJumpJungleMinions = minionManager(MINION_JUNGLE, 900, myHero, MINION_SORT_MAXHEALTH_DEC)
local closeEnemyMinions = minionManager(MINION_ENEMY, 900, myHero, MINION_SORT_MAXHEALTH_DEC)
local ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 900, DAMAGE_MAGIC, true)
ts.name = "Cassiopeia"

local JungleMobs = {}
local JungleFocusMobs = {}
local UnitWithPsn = {}

local myTarget = nil

local antiSpam = nil
--
--END Vars
--
-----------------------------------------------
--
--START Unit Checks
--
function ValidTargetedT(target,range)
    return ValidTarget(target,range) and target.valid and not target.dead 
end

function HaveBuffPsn(unit)
	if UnitWithPsn[unit.networkID] ~= nil then
	    return true
	end
	return false
end

function CalDmg(unit, spell)
    if not unit or not spell then return end
	if unit ~= nil then
    	local SNAMES = spell:upper()
    	local caldmg = math.round
    	if SNAMES == "IGNITE" then
      		return caldmg(IREADY and getDmg("IGNITE", unit, myHero) or 0)
    	elseif SNAMES == "HXG" then
      		return caldmg(hxgReady and getDmg("HXG", unit, myHero) or 0)
    	elseif SNAMES == "RUINEDKING" then
      		return caldmg(botrkReady and getDmg("RUINEDKING", unit, myHero) or 0)
    	elseif SNAMES == "SHEEN" then
      		return caldmg(sheenReady and getDmg("SHEEN", unit, myHero) or 0)
    	elseif SNAMES == "TRINITY" then
      		return caldmg(trinityReady and getDmg("TRINITY", unit, myHero) or 0)
    	elseif SNAMES == "LIANDRYS" then
      		return caldmg(lyandrisReady and getDmg("LIANDRYS", unit, myHero) or 0)
    	end
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

function IsFacing(source, target, lineLength)
	local sourceVector = Vector(source.visionPos.x, source.visionPos.z)
	local sourcePos = Vector(source.x, source.z)
	sourceVector = (sourceVector-sourcePos):normalized()
	sourceVector = sourcePos + (sourceVector*(GetDistance(target, source)))
	return GetDistanceSqr(target, {x = sourceVector.x, z = sourceVector.y}) <= (lineLength and lineLength^2 or 90000)
end
--
--END Unit Checks
--
-----------------------------------------------
--
--START Humanizer
--
local lastECast = os.clock()
local humanETime = 0.5
function CanWeEYet()
	if myHero.level > 14 then
		humanETime = 0.4
	elseif myHero.level > 17 then
		humanETime = 0.3
	end
	if lastECast <= os.clock() then
		return true
	end
	return false
end
--
--END Humanizer
--
-----------------------------------------------
--
--START Util Farming Functions
--
function GetFarmPosition(range, width)
	local BestPos 
	local BestHit = 0
	local objects = closeEnemyMinions.objects
	for i, object in pairs(objects) do
		if object and object.valid and not object.dead and object.visible and object.bTargetable then
			local hit = CountObjectsNearPos(object.pos or object, range, width, objects)
			if hit > BestHit and GetDistanceSqr(object) < range * range then
				BestHit = hit
				BestPos = Vector(object)
				if BestHit == #objects then
					break
				end
			end
		end
	end
	return BestPos, BestHit
end

function CountObjectsNearPos(pos, range, radius, objects)
	local n = 0
	for i, object in pairs(objects) do
		if object and object.valid and not object.dead and object.visible and object.bTargetable and GetDistance(pos, object) <= radius then
			n = n + 1
		end
	end
	return n
end
--
--END Util Farming Functions
--
-----------------------------------------------
--
--START Math Functions
--
function CalcVector(source,target)
	local V = Vector(source.x, source.y, source.z)
	local V2 = Vector(target.x, target.y, target.z)
	local vec = V-V2
	local vec2 = vec:normalized()
	return vec2
end

function Get2DVectorLength(vector)
	return math.sqrt(vector[1]^2 + vector[2]^2)
end

function Get2DVector(p1x, p1y, p2x, p2y)
	return { p2x - p1x, p2y - p1y}
end

function getArrayLength(array)
	local counter = 1
	for i, element in pairs(array) do
		counter = counter + 1
		--print("counted " .. counter)
	end
	return counter
end

function round(num)
	if num >= 0 then
    	return math.floor(num + 0.5)
	else
    	return math.ceil(num - 0.5)
	end
end
--
--END Math Functions
--
-----------------------------------------------
--
--START Evade Functions
--
function IsEvadeMarkedSafe(pos)
	if _G.DancingShoes_Loaded and _G.Evade then
		return _G.DancingShoes_IsSafe(pos.x, pos.z)
	elseif _G.AE and _G.AE_isEvading then
		return _G.isSafePoint(pos)
	else
		return true
	end
end

function CheckSafePointEvade(point)
	if _G.DancingShoes_Loaded and _G.Evade then
		return _G.DancingShoes_IsSafe(point.x, point.z)
	elseif _G.AE and _G.AE_isEvading then
		return _G.isSafePoint(point)
	end
end
--
--END Evade Functions
--
-----------------------------------------------
--
--START On Functions
--
function OnLoad()
	RegisterOrbWalks()
	RegisterMenu()
	
	DelayAction(function()
	    GeneralPrint("Successfully Loaded!")
		GeneralPrint("[v" .. scriptData.Version .. "] SAC:R is currently the only fully supported Orb Walk.")
		GeneralPrint("[v" .. scriptData.Version .. "] VPred is currently the only supported prediction.")
	end, 5)
	DelayAction(function()
		if _G.DancingShoes_Loaded and _G.Evade then
			GeneralPrint("Connected to Dancing Shoes.")
		elseif _G.AE and _G.AE_isEvading then
			GeneralPrint("Connected to ArtificialEvasion.")
		end
	end, 10)
end

function OnTick()
	for i, obj in pairs(UnitWithPsn) do
		if os.clock() >= obj then
			UnitWithPsn[i] = nil
		end
	end
	AutoKillTick()
	
	--if mainMenu.WallJump.key then FleeTick() return end
	
	if mainMenu.Jungle.key then JungleTick() end
	if mainMenu.Lane.key then LaneClearTick() end
	if mainMenu.Combo.key then ComboTick() end
	if mainMenu.Harass.key then HarassTick() end
	--if mainMenu.
	if mainMenu.Advanced.autoEC and myHero:CanUseSpell(_E) == READY then
		local lowestHPInRange = nil
		for i, object in pairs(GetEnemyHeroes()) do
			if ValidTargetedT(object, MyChampData["E"].range) and GetDistance(object) <= MyChampData["E"].range then
				if lowestHPInRange == nil then
					lowestHPInRange = object
				elseif lowestHPInRange and lowestHPInRange.health > object.health  then
					lowestHPInRange = object
				end
			end
		end
		if lowestHPInRange then
			CastSpell(_E, lowestHPInRange)
		end
	end
	
	if mainMenu.Advanced.autoE and myHero:CanUseSpell(_E) == READY then
		--Auto E Minions
		if not mainMenu.Combo.key then
			closeEnemyMinions:update()
			for _, minion in pairs(closeEnemyMinions.objects) do
				if ValidTargetedT(minion, MyChampData["E"].range) and GetDistance(minion) <= MyChampData["E"].range and minion.health < MyChampData["E"].APDamage(myHero, minion) - (MyChampData["E"].APDamage(myHero, minion) / 4.25) then
				--local nT = 0.25 + 1900 / GetDistance(minion.visionPos, myHero.visionPos) + 0.1
				--if ValidTargetedT(minion, MyChampData["E"].range) and GetDistance(minion) <= MyChampData["E"].range and minion.health < VP:GetPredictedHealth(minion, 0.25) then
					CastSpell(_E, minion)
					return
				end
			end
		end
	end
end

function OnDraw()
	local color = ARGB(100, 255, 61, 236)
	
	if mainMenu.Draw.q and (not mainMenu.Draw.ready or (mainMenu.Draw.ready and myHero:CanUseSpell(_Q) == READY)) then
		DrawCircle2(myHero.x, myHero.y, myHero.z, MyChampData["Q"].range, color)
	end
	if mainMenu.Draw.w and (not mainMenu.Draw.ready or (mainMenu.Draw.ready and myHero:CanUseSpell(_W) == READY)) then
		DrawCircle2(myHero.x, myHero.y, myHero.z, MyChampData["W"].range, color)
	end
	if mainMenu.Draw.e and (not mainMenu.Draw.ready or (mainMenu.Draw.ready and myHero:CanUseSpell(_E) == READY)) then
		DrawCircle2(myHero.x, myHero.y, myHero.z, MyChampData["E"].range, color)
	end
	if mainMenu.Draw.r and (not mainMenu.Draw.ready or (mainMenu.Draw.ready and myHero:CanUseSpell(_R) == READY)) then
		DrawCircle2(myHero.x, myHero.y, myHero.z, MyChampData["R"].range, color)
	end
	
	if mainMenu.Draw.damage then
		for i, enemy in pairs(GetEnemyHeroes()) do
			if enemy and enemy.visible and not enemy.dead then
				local myDmg = 0
				if myHero:CanUseSpell(_Q) == READY then
					myDmg = myDmg + MyChampData["Q"].APDamage(myHero, enemy)
				end
				if myHero:CanUseSpell(_W) == READY then
					myDmg = myDmg + MyChampData["W"].APDamage(myHero, enemy)
				end
				if myHero:CanUseSpell(_E) == READY then
					myDmg = myDmg + MyChampData["E"].APDamage(myHero, enemy)
				end
				if myHero:CanUseSpell(_R) == READY then
					myDmg = myDmg + MyChampData["R"].APDamage(myHero, enemy)
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
end

function OnApplyBuff(source, unit, buff)
    if source and unit and buff and source == myHero and buff.name == "cassiopeiaqdebuff" then
		UnitWithPsn[unit.networkID] = os.clock() + (buff.endTime - buff.startTime)
	end
end

function OnRemoveBuff(unit, buff)
    if unit and buff and UnitWithPsn[unit.networkID] then
		UnitWithPsn[unit.networkID] = nil
	end
end

function OnProcessSpell(unit,spell)
	if unit and unit.isMe and spell and spell.name == "CassiopeiaE" then
		lastECast = os.clock() + humanETime - GetLatency() / 2000 - 0.07
    end
end
--
--END On Functions
--
-----------------------------------------------
--
--START Jungle Clear
--
function JungleTick()
	jungleMinions:update()
	for i, object in pairs(jungleMinions.objects) do
		if object then
			if mainMenu.Jungle.q and myHero:CanUseSpell(_Q) == READY and GetDistance(object) <= MyChampData["Q"].range then
				if mainMenu.Advanced.qMinionPred == 1 then
					local CastPosition, HitChance, Position = VP:GetCircularAOECastPosition(object, MyChampData["Q"].delay, MyChampData["Q"].width, MyChampData["Q"].range, MyChampData["Q"].speed, myHero)
					if HitChance and CastPosition and HitChance >= mainMenu.Advanced.qMinionVPHC then
						CastSpell(_Q, CastPosition.x, CastPosition.z)
						return
					end
				elseif mainMenu.Advanced.qMinionPred == 2 then
					local QPos, QHitChance = HPred:GetPredict(HP_Q, unit, myHero, false)
					if QPos and QHitChance and QHitChance >= mainMenu.Advanced.qMinionHPHC then
						CastSpell(_Q, QPos.x, QPos.z)
						return
					end
				end
			end
			
			if mainMenu.Jungle.w and myHero:CanUseSpell(_W) == READY and GetDistance(object) <= MyChampData["W"].range then
				if mainMenu.Advanced.wMinionPred == 1 then
					local CastPosition, HitChance, Position = VP:GetCircularAOECastPosition(object, MyChampData["W"].delay, MyChampData["W"].width, MyChampData["W"].range, MyChampData["W"].speed, myHero)
					if HitChance and CastPosition and HitChance >= mainMenu.Advanced.wMinionVPHC then
						CastSpell(_W, CastPosition.x, CastPosition.z)
						return
					end
				elseif mainMenu.Advanced.wMinionPred == 2 then
					local WPos, WHitChance = HPred:GetPredict(HP_W, unit, myHero, false)
					if WPos and WHitChance and WHitChance >= mainMenu.Advanced.wMinionHPHC then
						CastSpell(_W, WPos.x, WPos.z)
						return
					end
				end
			end
			
			if mainMenu.Jungle.e and CanWeEYet() and myHero:CanUseSpell(_E) == READY and GetDistance(object) <= MyChampData["E"].range then
				CastSpell(_E, object)
				return
			end
		end
	end
end
--
--END Jungle Clear
--
-----------------------------------------------
--
--START Lane Clear
--
function LaneClearTick()
	closeEnemyMinions:update()
	
	if mainMenu.Lane.q and mainMenu.Lane.qMana <= 100*myHero.mana/myHero.maxMana then
		local BestPos, BestHit = GetFarmPosition(MyChampData["Q"].range, MyChampData["Q"].width)
		if BestHit >= mainMenu.Lane.qMinions then 
			CastSpell(_Q, BestPos.x, BestPos.z)
		end
	end
	
	if mainMenu.Lane.w and mainMenu.Lane.wMana <= 100*myHero.mana/myHero.maxMana then
		local BestPos, BestHit = GetFarmPosition(MyChampData["W"].range, MyChampData["W"].width)
		if BestHit >= mainMenu.Lane.wMinions and GetDistance(BestPos) >= 500 then 
			CastSpell(_W, BestPos.x, BestPos.z)
		end
	end
	
	if mainMenu.Lane.e and mainMenu.Lane.eMana <= 100*myHero.mana/myHero.maxMana then
		if myHero:CanUseSpell(_E) == READY then
			local bestETarget = nil
			for i, object in pairs(closeEnemyMinions.objects) do
				if object and object.valid and not object.dead and object.visible and object.bTargetable and GetDistance(object) <= MyChampData["E"].range - 5 then
					if bestETarget == nil then
						bestETarget = object
					else
						if object.health > bestETarget.health then
							bestETarget = object
						elseif object.health <= MyChampData["E"].APDamage(myHero, object) then
							bestETarget = object
							break
						end
					end
				end
			end
			
			if bestETarget ~= nil then
				CastSpell(_E, bestETarget)
			end
		end
	end
end
--
--END Lane Clear
--
-----------------------------------------------
--
--START Combo
--
function ComboTick()
	ts:update()
	
	if mainMenu.Combo.r and myHero:CanUseSpell(_R) == READY then
		local bestCast = nil
		local bestHitChance = nil
		local bestHitCount = nil
		for i, object in pairs(GetEnemyHeroes()) do
			if object and ValidTargetedT(object, MyChampData["R"].range) then
				local CastPosition, HitChance, NumHit = VP:GetConeAOECastPosition(object, MyChampData["R"].delay, MyChampData["R"].width, MyChampData["R"].range, MyChampData["R"].speed, myHero)
				if CastPosition and HitChance and NumHit and GetDistance(CastPosition) <= MyChampData["R"].range and HitChance >= mainMenu.Advanced.rChampsVPHC and NumHit >= mainMenu.Combo.rNumber then
					if bestCast == nil then
						bestCast = CastPosition
						bestHitChance = HitChance
						bestHitCount = NumHit
					elseif bestHitCount < NumHit then
						bestCast = CastPosition
						bestHitChance = HitChance
						bestHitCount = NumHit
					elseif bestHitCount == NumHit and bestHitChance < HitChance then
						bestCast = CastPosition
						bestHitChance = HitChance
						bestHitCount = NumHit
					end
				end
			end
		end
		if bestCast and bestHitChance and bestHitCount then
			CastSpell(_R, bestCast.x, bestCast.z)
			castOnTarget = true
			return
		end
	end
	
	myTarget = ts.target
	local castOnTarget = false
	if myTarget then
		if mainMenu.Combo.q and myHero:CanUseSpell(_Q) == READY and GetDistance(myTarget) <= MyChampData["Q"].range then
			if mainMenu.Advanced.qChampsPred == 1 then
				local CastPosition, HitChance, Position = VP:GetCircularAOECastPosition(myTarget, MyChampData["Q"].delay, MyChampData["Q"].width, MyChampData["Q"].range, MyChampData["Q"].speed, myHero)
				if HitChance and CastPosition and HitChance >= mainMenu.Advanced.qChampsPred then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
					castOnTarget = true
				end
			elseif mainMenu.Advanced.qChampsPred == 2 then
				local QPos, QHitChance = HPred:GetPredict(HP_Q, myTarget, myHero, false)
				if QPos and QHitChance and QHitChance >= mainMenu.Advanced.qChampsHPHC then
					CastSpell(_Q, QPos.x, QPos.z)
				end
			end
		end
		
		if mainMenu.Combo.w and myHero:CanUseSpell(_W) == READY and GetDistance(myTarget) <= MyChampData["W"].range then
			if mainMenu.Advanced.wChampsPred == 1 then
				local CastPosition, HitChance, Position = VP:GetCircularAOECastPosition(myTarget, MyChampData["W"].delay, MyChampData["W"].width, MyChampData["W"].range, MyChampData["W"].speed, myHero)
				if HitChance and CastPosition and HitChance >= mainMenu.Advanced.wChampsPred and GetDistance(CastPosition) >= 495 then
					CastSpell(_W, CastPosition.x, CastPosition.z)
					castOnTarget = true
				end
			elseif mainMenu.Advanced.wChampsPred == 2 then
				local WPos, WHitChance = HPred:GetPredict(HP_W, myTarget, myHero, false)
				if WPos and WHitChance and WHitChance >= mainMenu.Advanced.wChampsHPHC then
					CastSpell(_W, WPos.x, WPos.z)
				end
			end
		end
		
		if mainMenu.Combo.e and CanWeEYet() and myHero:CanUseSpell(_E) == READY and GetDistance(myTarget) <= MyChampData["E"].range then
			CastSpell(_E, myTarget)
			castOnTarget = true
		end
	end
	
	if castOnTarget then return end
	
	for i, object in pairs(GetEnemyHeroes()) do
		if object and object.valid and not object.dead and object.visible and object.bTargetable then
			if mainMenu.Combo.q and myHero:CanUseSpell(_Q) == READY and GetDistance(object) <= MyChampData["Q"].range then
				if mainMenu.Advanced.qChampsPred == 1 then
					local CastPosition, HitChance, Position = VP:GetCircularAOECastPosition(object, MyChampData["Q"].delay, MyChampData["Q"].width, MyChampData["Q"].range, MyChampData["Q"].speed, myHero)
					if HitChance and CastPosition and HitChance >= mainMenu.Advanced.qChampsPred then
						CastSpell(_Q, CastPosition.x, CastPosition.z)
						castOnTarget = true
					end
				elseif mainMenu.Advanced.qChampsPred == 2 then
					local QPos, QHitChance = HPred:GetPredict(HP_Q, object, myHero, false)
					if QPos and QHitChance and QHitChance >= mainMenu.Advanced.qChampsHPHC then
						CastSpell(_Q, QPos.x, QPos.z)
					end
				end
			end
		
			if mainMenu.Combo.w and myHero:CanUseSpell(_W) == READY and GetDistance(object) <= MyChampData["W"].range then
				local CastPosition, HitChance, Position = VP:GetCircularAOECastPosition(object, MyChampData["W"].delay, MyChampData["W"].width, MyChampData["W"].range, MyChampData["W"].speed, myHero)
				if HitChance and CastPosition and HitChance >= mainMenu.Advanced.wChampsPred then
					CastSpell(_W, CastPosition.x, CastPosition.z)
					castOnTarget = true
				end
			end
			
			if mainMenu.Combo.e and CanWeEYet() and myHero:CanUseSpell(_E) == READY and GetDistance(object) <= MyChampData["E"].range - 5 then
				CastSpell(_E, object)
			end
		end
	end
end
--
--END Combo
--
-----------------------------------------------
--
--START Harass
--
function HarassTick()
	ts:update()
	myTarget = ts.target
	if myTarget then
		if mainMenu.Harass.q and mainMenu.Harass.qMana <= 100*myHero.mana/myHero.maxMana and myHero:CanUseSpell(_Q) == READY and GetDistance(myTarget) <= MyChampData["Q"].range then
			local CastPosition, HitChance, Position = VP:GetCircularAOECastPosition(myTarget, MyChampData["Q"].delay, MyChampData["Q"].width, MyChampData["Q"].range, MyChampData["Q"].speed, myHero)
			if HitChance and CastPosition and HitChance >= mainMenu.Advanced.qChampsPred then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
				return
			end
		end
		
		if mainMenu.Harass.w and mainMenu.Harass.wMana <= 100*myHero.mana/myHero.maxMana and myHero:CanUseSpell(_W) == READY and GetDistance(myTarget) <= MyChampData["W"].range then
			local CastPosition, HitChance, Position = VP:GetCircularAOECastPosition(myTarget, MyChampData["W"].delay, MyChampData["W"].width, MyChampData["W"].range, MyChampData["W"].speed, myHero)
			if HitChance and CastPosition and HitChance >= mainMenu.Advanced.wChampsPred then
				CastSpell(_W, CastPosition.x, CastPosition.z)
				return
			end
		end
	end
	
	if castOnTarget then return end
	
	for i, object in pairs(GetEnemyHeroes()) do
		if object and object.valid and not object.dead and object.visible and object.bTargetable then
			if mainMenu.Harass.q and mainMenu.Harass.qMana <= 100*myHero.mana/myHero.maxMana and myHero:CanUseSpell(_Q) == READY and GetDistance(object) <= MyChampData["Q"].range then
				local CastPosition, HitChance, Position = VP:GetCircularAOECastPosition(object, MyChampData["Q"].delay, MyChampData["Q"].width, MyChampData["Q"].range, MyChampData["Q"].speed, myHero)
				if HitChance and CastPosition and HitChance >= mainMenu.Advanced.qChampsPred then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
					return
				end
			end
		
			if mainMenu.Harass.w and mainMenu.Harass.wMana <= 100*myHero.mana/myHero.maxMana and myHero:CanUseSpell(_W) == READY and GetDistance(object) <= MyChampData["W"].range then
				local CastPosition, HitChance, Position = VP:GetCircularAOECastPosition(object, MyChampData["W"].delay, MyChampData["W"].width, MyChampData["W"].range, MyChampData["W"].speed, myHero)
				if HitChance and CastPosition and HitChance >= mainMenu.Advanced.wChampsPred then
					CastSpell(_W, CastPosition.x, CastPosition.z)
					return
				end
			end
		end
	end
end
--
--END Harass
--
-----------------------------------------------
--
--START Auto Kill
--
function KillStealPrint(enemy, ability)
	local msg = "<font color=\"#FF794C\"><b>0 Cassiopeia - KS</b></font> <font color=\"#FFDFBF\"><b>Killing [" .. enemy.charName .. "] using [" .. ability .. "].</b></font>"
	if antiSpam ~= msg then
		print(msg)
		antiSpam = msg
	end
end

function AutoKillTick()
	if mainMenu.Kill.e or mainMenu.Kill.q or mainMenu.Kill.r then
		for i, enemy in ipairs(GetEnemyHeroes()) do
			eDmg = MyChampData["E"].APDamage(myHero, enemy)
			qDmg = MyChampData["Q"].APDamage(myHero, enemy)
			wDmg = MyChampData["W"].APDamage(myHero, enemy)
			
			--KS E
			if mainMenu.Kill.e and myHero:CanUseSpell(_E) == READY and ValidTargetedT(enemy, MyChampData["E"].range) and enemy.health <= eDmg then
				CastSpell(_E, enemy)
				KillStealPrint(enemy, "E")
				return
			end
			
			--KS Q
			if mainMenu.Kill.q and myHero:CanUseSpell(_Q) == READY and ValidTargetedT(enemy, MyChampData["Q"].range) and enemy.health <= eDmg then
				local CastPosition, HitChance, Position = VP:GetCircularAOECastPosition(myTarget, MyChampData["Q"].delay, MyChampData["Q"].width, MyChampData["Q"].range, MyChampData["Q"].speed, myHero)
				if HitChance and CastPosition and HitChance >= 2 then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
					KillStealPrint(enemy, "Q")
					return
				end
			end
			
			--KS W
			if mainMenu.Kill.w and myHero:CanUseSpell(_W) == READY and ValidTargetedT(enemy, MyChampData["W"].range) and enemy.health <= eDmg then
				local CastPosition, HitChance, Position = VP:GetCircularAOECastPosition(myTarget, MyChampData["W"].delay, MyChampData["W"].width, MyChampData["W"].range, MyChampData["W"].speed, myHero)
				if HitChance and CastPosition and HitChance >= 2 then
					CastSpell(_W, CastPosition.x, CastPosition.z)
					KillStealPrint(enemy, "W")
					return
				end
			end
		end
	end
end
--
--END Auto Kill
--