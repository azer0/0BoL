if myHero.charName ~= "Taliyah" then return end

--To Do:
---when enemy tries to leave E knock them back in with W
---knock enemys away on flee

require 'VPrediction'
VPred = VPrediction()

config = {
	version = 1002,
	name = "Rock Candy",
	charName = "Taliyah",
	prettyName = "<font color=\"#FF5733\">[<u>Rock Candy</u>]</font>",
	isDebug = true,

	defaultFontColor = "3393FF",
	debugFontColor = "EC33FF"
}

myData = {
	lastMessage = nil,
	isSurfing = false,
	onWorkedGround = false,
	usedGround = {},
	menu = nil,
	orbWalks = {
		SAC = {
			enabled = false,
			used = false,
			ready = false
		},
		PEWALK = {
			enabled = false,
			used = false
		},
		PEWALK = {
			enabled = false,
			used = false
		},
		NEBELWOLFI = {
			enabled = false,
			used = false
		},
		SX = {
			enabled = false,
			used = false
		},
		SELECTED = nil
	},
	spells = {
		Q = {
			ready = false,
			lastCast = 0
		},
		W = {
			ready = false,
			lastCast = 0,
			readyForTwo = false
		},
		E = {
			ready = false,
			lastCast = 0
		},
		R = {
			ready = false,
			lastCast = 0
		}
	},
	targetSelector = nil,
	minionSelector = nil
}

--Champion Modes
function LaneClearMode()
	myData.minionSelector:update()

	if myData.menu.LaneClearManager.E and CanCastE() then
		local BestPos, BestHit = GetCircleAOEFarmPosition(570, 330)
		if BestHit >= 3 then
			CastE(BestPos.x, BestPos.z)
		end
	end

	for _, minions in ipairs(myData.minionSelector.objects) do
		if ValidTarget(minions) then
			if myData.menu.LaneClearManager.Q and CanCastQ() and myData.onWorkedGround then
				local CastPosition, HitChance = VPred:GetLineCastPosition(minions, 0.2, 130, 910, 1200, myHero, true)
				if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 910 then
					CastQ(CastPosition.x, CastPosition.z)
				end
			end

			if myData.menu.LaneClearManager.W and CanCastW() then
				local CastPosition, HitChance = VPred:GetCircularAOECastPosition(minions, 0.3, 150, 900, 1000, myHero, false)
				if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 910 then
					CastW(CastPosition.x, CastPosition.z)
					DelayAction(function() CastW2(myHero.x, myHero.z) end, .6)
				end
			end
		end
	end
end

function HarassMode()
	myData.targetSelector:update()

	target = myData.targetSelector.target

	if target and ValidTarget(target) then

		--Q Logics
		if myData.menu.HarassManager.Q and CanCastQ() and not myData.onWorkedGround then
			local CastPosition, HitChance = VPred:GetLineCastPosition(target, 0.2, 130, 910, 1200, myHero, true)
			if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 850 then
				CastQ(CastPosition.x, CastPosition.z)
			end
		end

		if myData.menu.HarassManager.Q and CanCastQ() and myData.onWorkedGround then
			local CastPosition, HitChance = VPred:GetLineCastPosition(target, 0.2, 130, 910, 1200, myHero, true)
			if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 910 then
				CastQ(CastPosition.x, CastPosition.z)
			end
		end

		--E Logics
		if myData.menu.HarassManager.E and CanCastE() then
			local CastPosition, HitChance = VPred:GetCircularAOECastPosition(target, 0.2, 330, 570, 1700, myHero, false)
			if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 700 then
				CastE(CastPosition.x, CastPosition.z)
			end
		end

		--W Logics
		if myData.menu.HarassManager.W and CanCastW() then
			local CastPosition, HitChance = VPred:GetCircularAOECastPosition(target, 0.3, 150, 900, 1000, myHero, false)
			if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 910 then
				CastW(CastPosition.x, CastPosition.z)
				if target.health > myHero.health then
					newPos = DoYouEvenExtend(myHero, CastPosition, 80)
					DelayAction(function() CastW2(newPos.x, newPos.z) end, .5)
				else
					DelayAction(function() CastW2(myHero.x, myHero.z) end, .5)
				end
			end
		end
	else

		for _,v in pairs(GetEnemyHeroes()) do
			if ValidTarget(v, 1000) then
				--Q Logics
				if myData.menu.HarassManager.Q and CanCastQ() and not myData.onWorkedGround then
					local CastPosition, HitChance = VPred:GetLineCastPosition(v, 0.2, 130, 910, 1200, myHero, true)
					if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 850 then
						CastQ(CastPosition.x, CastPosition.z)
					end
				end

				if myData.menu.HarassManager.Q and CanCastQ() and myData.onWorkedGround then
					local CastPosition, HitChance = VPred:GetLineCastPosition(v, 0.2, 130, 910, 1200, myHero, true)
					if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 910 then
						CastQ(CastPosition.x, CastPosition.z)
					end
				end

				--E Logics
				if myData.menu.HarassManager.E and CanCastE() then
					local CastPosition, HitChance = VPred:GetCircularAOECastPosition(v, 0.2, 330, 570, 1700, myHero, false)
					if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 700 then
						CastE(CastPosition.x, CastPosition.z)
					end
				end

				--W Logics
				if myData.menu.HarassManager.W and CanCastW() then
					local CastPosition, HitChance = VPred:GetCircularAOECastPosition(v, 0.3, 150, 900, 1000, myHero, false)
					if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 910 then
						CastW(CastPosition.x, CastPosition.z)
						if v.health > myHero.health then
							newPos = DoYouEvenExtend(myHero, CastPosition, 80)
							DelayAction(function() CastW2(newPos.x, newPos.z) end, .5)
						else
							DelayAction(function() CastW2(myHero.x, myHero.z) end, .5)
						end
					end
				end
			end
		end

	end
end

function ComboMode()
	myData.targetSelector:update()

	target = myData.targetSelector.target

	if target and ValidTarget(target) then

		--Q Logics
		if myData.menu.ComboManager.Q and CanCastQ() and not myData.onWorkedGround then
			local CastPosition, HitChance = VPred:GetLineCastPosition(target, 0.2, 130, 910, 1200, myHero, true)
			if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 850 then
				CastQ(CastPosition.x, CastPosition.z)
			end
		end

		if myData.menu.ComboManager.Q and CanCastQ() and myData.onWorkedGround then
			local CastPosition, HitChance = VPred:GetLineCastPosition(target, 0.2, 130, 910, 1200, myHero, true)
			if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 910 then
				CastQ(CastPosition.x, CastPosition.z)
			end
		end

		--E Logics
		if myData.menu.ComboManager.E and CanCastE() then
			local CastPosition, HitChance = VPred:GetCircularAOECastPosition(target, 0.2, 330, 570, 1700, myHero, false)
			if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 700 then
				CastE(CastPosition.x, CastPosition.z)
			end
		end

		--W Logics
		if myData.menu.ComboManager.W and CanCastW() then
			local CastPosition, HitChance = VPred:GetCircularAOECastPosition(target, 0.3, 150, 900, 1000, myHero, false)
			if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 910 then
				CastW(CastPosition.x, CastPosition.z)
				if target.health > myHero.health then
					newPos = DoYouEvenExtend(myHero, CastPosition, 80)
					DelayAction(function() CastW2(newPos.x, newPos.z) end, .5)
				else
					DelayAction(function() CastW2(myHero.x, myHero.z) end, .5)
				end
			end
		end
	else

		for _,v in pairs(GetEnemyHeroes()) do
			if ValidTarget(v, 1000) then
				--Q Logics
				if myData.menu.ComboManager.Q and CanCastQ() and not myData.onWorkedGround then
					local CastPosition, HitChance = VPred:GetLineCastPosition(v, 0.2, 130, 910, 1200, myHero, true)
					if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 850 then
						CastQ(CastPosition.x, CastPosition.z)
					end
				end

				if myData.menu.ComboManager.Q and CanCastQ() and myData.onWorkedGround then
					local CastPosition, HitChance = VPred:GetLineCastPosition(v, 0.2, 130, 910, 1200, myHero, true)
					if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 910 then
						CastQ(CastPosition.x, CastPosition.z)
					end
				end

				--E Logics
				if myData.menu.ComboManager.E and CanCastE() then
					local CastPosition, HitChance = VPred:GetCircularAOECastPosition(v, 0.2, 330, 570, 1700, myHero, false)
					if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 700 then
						CastE(CastPosition.x, CastPosition.z)
					end
				end

				--W Logics
				if myData.menu.ComboManager.W and CanCastW() then
					local CastPosition, HitChance = VPred:GetCircularAOECastPosition(v, 0.3, 150, 900, 1000, myHero, false)
					if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 910 then
						CastW(CastPosition.x, CastPosition.z)
						if v.health > myHero.health then
							newPos = DoYouEvenExtend(myHero, CastPosition, 80)
							DelayAction(function() CastW2(newPos.x, newPos.z) end, .5)
						else
							DelayAction(function() CastW2(myHero.x, myHero.z) end, .5)
						end
					end
				end
			end
		end

	end
end

--Menu
function MakeMenu()
	myData.menu:addSubMenu("-> Combo Manager <-", "ComboManager")
		myData.menu.ComboManager:addParam("Q", "Use Q in Combo Mode", SCRIPT_PARAM_ONOFF, true)
		myData.menu.ComboManager:addParam("W", "Use W in Combo Mode", SCRIPT_PARAM_ONOFF, true)
		myData.menu.ComboManager:addParam("E", "Use E in Combo Mode", SCRIPT_PARAM_ONOFF, true)
	myData.menu:addSubMenu("-> Lane Clear Manager <-", "LaneClearManager")
		myData.menu.LaneClearManager:addParam("Q", "Use Q in Combo Mode", SCRIPT_PARAM_ONOFF, true)
		myData.menu.LaneClearManager:addParam("W", "Use W in Combo Mode", SCRIPT_PARAM_ONOFF, true)
		myData.menu.LaneClearManager:addParam("E", "Use E in Combo Mode", SCRIPT_PARAM_ONOFF, true)
	myData.menu:addSubMenu("-> Harass Manager <-", "HarassManager")
		myData.menu.HarassManager:addParam("Q", "Use Q in Combo Mode", SCRIPT_PARAM_ONOFF, true)
		myData.menu.HarassManager:addParam("W", "Use W in Combo Mode", SCRIPT_PARAM_ONOFF, true)
		myData.menu.HarassManager:addParam("E", "Use E in Combo Mode", SCRIPT_PARAM_ONOFF, true)
end

--On_____ Section

function OnDraw()
	DrawCircle(myHero.x, myHero.y, myHero.z, 910, 0x111111)
	DrawCircle(myHero.x, myHero.y, myHero.z, 900, 0x111111)
	DrawCircle(myHero.x, myHero.y, myHero.z, 750, 0x111111)

	if myData.onWorkedGround then
		sPos = WorldToScreen(D3DXVECTOR3(myHero.x,myHero.y,myHero.z))
		DrawText("On Worked Ground", 20, sPos.x - 75, sPos.y + 25, ARGB(150,255,255,255))
	end
end

function OnLoad()
	PrintPretty("Welcome to Rock Candy v" .. config.version, false, true)
	PrintPretty("This is still a <b><u>work in progress</u></b> so please report any bugs you may find.", false, true)

	local ToUpdate = {}
    ToUpdate.Version = config.version
    ToUpdate.UseHttps = true
    ToUpdate.Host = "raw.githubusercontent.com"
    ToUpdate.VersionPath = "/azer0/0BoL/master/RockCandy.Version"
    ToUpdate.ScriptPath =  "/azer0/0BoL/master/Taliyah - Rock Candy.lua"
    ToUpdate.SavePath = LIB_PATH.."/Taliyah - Rock Candy - TMP.lua"
    ToUpdate.CallbackUpdate = function(NewVersion,OldVersion) PrettyPrint("Updated to version " .. NewVersion .. ".", false, true) end
    ToUpdate.CallbackNoUpdate = function(OldVersion) PrettyPrint("No update found.", false, true) end
    ToUpdate.CallbackNewVersion = function(NewVersion) PrettyPrint("New version [" .. NewVersion .. "] found.", false, true) end
    ToUpdate.CallbackError = function(NewVersion) PrettyPrint("Error while downloading, please try again.", false, true) end
    ScriptUpdate(ToUpdate.Version,ToUpdate.UseHttps, ToUpdate.Host, ToUpdate.VersionPath, ToUpdate.ScriptPath, ToUpdate.SavePath, ToUpdate.CallbackUpdate,ToUpdate.CallbackNoUpdate, ToUpdate.CallbackNewVersion,ToUpdate.CallbackError)

	myData.menu = scriptConfig(config.name, "001data")
	MakeMenu()

	OnLoadOrbWalk()

	myData.targetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, 930, DAMAGE_MAGIC, true)
	myData.minionSelector = minionManager(MINION_ENEMY, 930, myHero, MINION_SORT_HEALTH_DES)
end

function OnTick()
	if myHero.dead then return end

	myData.spells.Q.ready = CanCastQ()
	myData.spells.W.ready = CanCastW()
	myData.spells.E.ready = CanCastE()
	myData.spells.R.ready = CanCastR()

	--Check worked ground
	myData.onWorkedGround = false
	for i, worked in pairs(myData.usedGround) do
		if worked.expire <= os.clock() then
			table.remove(myData.usedGround, i)
		else
			if worked and worked.obje and worked.obje.pos and myHero:GetDistance(worked.obje) <= 425 then
				myData.onWorkedGround = true
			end
		end
	end

	orbMode = GetOrbMode()

	if orbMode == "Laneclear" then
		LaneClearMode()
	elseif orbMode == "Combo" then
		ComboMode()
	elseif orbMode == "Harass" then
		HarassMode()
	end
end

function OnApplyBuff(source, unit, buff)
	if source and unit and buff then
		if source == myHero then
			if buff.name == "taliyahpwallspeedbuff" or buff.name == "taliyahpwallspeedfullyramped" then
				myData.isSurfing = true
			end
		end
	end
end

function OnRemoveBuff(unit, buff)
	if unit and buff then
		if unit == myHero then
			if buff.name == "taliyahpwallspeedbuff" or buff.name == "taliyahpwallspeedfullyramped" then
				myData.isSurfing = false
			end
		end
	end
end

function OnCreateObj(obj)
	if obj then
		if obj.name:find("Taliyah_Base_Q") and not WorkedGroundIsKnown(obj) then
			tmpT = {
				obje = obj,
				expire = os.clock() + 180
			}
			table.insert(myData.usedGround, tmpT)
		end
	end
end

function OnProcessSpell(object, spell)
	if object == myHero and spell.name == "TaliyaW" then
		myData.spells.W.readyForTwo = true
	end
end

function WorkedGroundIsKnown(obj)
	for i, worked in pairs(myData.usedGround) do
		if worked and worked.obje then
			if worked.obje == obj then
				return true
			end
		else
			table.remove(myData.usedGround, i)
		end
	end
	return false
end

--Orb Walker Section

function OnLoadOrbWalk()
	if _G.Reborn_Loaded or _G.Reborn_Initialised or _G.AutoCarry ~= nil then
		myData.orbWalks.SAC.enabled = true
		myData.orbWalks.SELECTED = "SAC"
		DelayAction(function() myData.orbWalks.SAC.ready = true PrintPretty("SAC:R Loaded.", false, true) end, 10)
	end
	if _G._Pewalk then
		myData.orbWalks.PEWALK.enabled = true
		if myData.orbWalks.SELECTED == nil then
			myData.orbWalks.SELECTED = "PEWALK"
		end
	end
	if FileExist(LIB_PATH .. "/Nebelwolfi's Orb Walker.lua") then
		myData.orbWalks.NEBELWOLFI.enabled = true
		if myData.orbWalks.SELECTED == nil then
			myData.orbWalks.SELECTED = "NEBELWOLFI"
			require "Nebelwolfi's Orb Walker"
			_G.NOWi = NebelwolfisOrbWalkerClass()
			myData.menu:addSubMenu("NOW", "NOW")
			_G.NebelwolfisOrbWalkerClass(myData.menu.NOW)
		end
	end
	if FileExist(LIB_PATH .. "/SxOrbWalk.lua") then
		myData.orbWalks.SX.enabled = true
		if myData.orbWalks.SELECTED == nil then
			myData.orbWalks.SELECTED = "SX"
			require "SxOrbWalk"
			myData.menu:addSubMenu("SxOrbWalk", "SxOrbWalk")
    		SxOrb:LoadToMenu(myData.menu.SxOrbWalk)
		end
	end
end

function GetOrbMode()
	if myData.orbWalks.SELECTED == "SAC" and myData.orbWalks.SAC.ready then
		if _G.AutoCarry.Keys.AutoCarry then return "Combo" end
		if _G.AutoCarry.Keys.MixedMode then return "Harass" end
		if _G.AutoCarry.Keys.LaneClear then return "Laneclear" end
		if _G.AutoCarry.Keys.LastHit then return "Lasthit" end
	end
end

--Utility Section
function PrintPretty(message, debug, antiSpam)
	if debug and not config.isDebug then return end

	if antiSpam and lastMessage ~= nil and lastMessage == message then return end

	fontColor = config.defaultFontColor
	if debug then fontColor = config.debugFontColor end

	print(config.prettyName .. " <font color=\"#" .. fontColor .. "\">" .. message .. "</font>")
	myData.lastMessage = message
end

function DoYouEvenExtend(sP, eP, add, max, min)
	local s1x, s1y, s1z = sP.x, sP.y, sP.z
	local dx, dy, dz = eP.x - s1x, eP.y - s1y, eP.z - s1z
	local d = dx * dx + dy * dy + dz * dz
	local d = add and math.max(max or 0, math.min(min or math.huge, d + add)) or math.max(max or 0, math.min(min or math.huge, d))
	return Vector(s1x + dx * d, s1y + dy * d, s1z * dz * d)
end

function GetCircleAOEFarmPosition(range, width)
	local BestPos 
    local BestHit = 0
    local objects = myData.minionSelector.objects
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
    for i, object in ipairs(objects) do
        if GetDistanceSqr(pos, object) <= radius * radius then
            n = n + 1
        end
    end
    return n
end

--Spell Cast
function CastE(x, z)
	myData.spells.E.lastCast = os.clock()
	CastSpell(_E, x, z)
end

function CanCastE()
	if (myHero:CanUseSpell(_E) == READY) and (myData.spells.E.lastCast + 0.5 <= os.clock() or myData.spells.E.lastCast == 0) then
		return true
	else
		return false
	end
end

function CastQ(x, z)
	myData.spells.Q.lastCast = os.clock()
	CastSpell(_Q, x, z)
end

function CanCastQ()
	if (myHero:CanUseSpell(_Q) == READY) and (myData.spells.Q.lastCast + 0.5 <= os.clock() or myData.spells.Q.lastCast == 0) then
		return true
	else
		return false
	end
end

function CastW(x, z)
	myData.spells.W.lastCast = os.clock()
	CastSpell(_W, x, z)
	myData.spells.W.readyForTwo = true
end

function CastW2(x, z)
	if myData.spells.W.readyForTwo then
		myData.spells.W.lastCast = os.clock()
		CastSpell(_W, x, z)
		readyForTwo = true
	end
end

function CanCastW()
	if (myHero:CanUseSpell(_W) == READY) and (myData.spells.W.lastCast + 0.5 <= os.clock() or myData.spells.W.lastCast == 0) then
		return true
	else
		return false
	end
end

function CastR(x, z)
	myData.spells.R.lastCast = os.clock()
	CastSpell(_R, x, z)
end

function CanCastR()
	if (myHero:CanUseSpell(_R) == READY) and (myData.spells.R.lastCast + 0.5 <= os.clock() or myData.spells.R.lastCast == 0) then
		return true
	else
		return false
	end
end

--Updater
class "ScriptUpdate"
function ScriptUpdate:__init(LocalVersion,UseHttps, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion,CallbackError)
    self.LocalVersion = LocalVersion
    self.Host = Host
    self.VersionPath = '/BoL/TCPUpdater/GetScript'..(UseHttps and '5' or '6')..'.php?script='..self:Base64Encode(self.Host..VersionPath)..'&rand='..math.random(99999999)
    self.ScriptPath = '/BoL/TCPUpdater/GetScript'..(UseHttps and '5' or '6')..'.php?script='..self:Base64Encode(self.Host..ScriptPath)..'&rand='..math.random(99999999)
    self.SavePath = SavePath
    self.CallbackUpdate = CallbackUpdate
    self.CallbackNoUpdate = CallbackNoUpdate
    self.CallbackNewVersion = CallbackNewVersion
    self.CallbackError = CallbackError
    AddDrawCallback(function() self:OnDraw() end)
    self:CreateSocket(self.VersionPath)
    self.DownloadStatus = 'Connect to Server for VersionInfo'
    AddTickCallback(function() self:GetOnlineVersion() end)
end

function ScriptUpdate:print(str)
    print('<font color="#FFFFFF">'..os.clock()..': '..str)
end

function ScriptUpdate:OnDraw()
    if self.DownloadStatus ~= 'Downloading Script (100%)' and self.DownloadStatus ~= 'Downloading VersionInfo (100%)'then
        DrawText('Download Status: '..(self.DownloadStatus or 'Unknown'),50,10,50,ARGB(0xFF,0xFF,0xFF,0xFF))
    end
end

function ScriptUpdate:CreateSocket(url)
    if not self.LuaSocket then
        self.LuaSocket = require("socket")
    else
        self.Socket:close()
        self.Socket = nil
        self.Size = nil
        self.RecvStarted = false
    end
    self.LuaSocket = require("socket")
    self.Socket = self.LuaSocket.tcp()
    self.Socket:settimeout(0, 'b')
    self.Socket:settimeout(99999999, 't')
    self.Socket:connect('sx-bol.eu', 80)
    self.Url = url
    self.Started = false
    self.LastPrint = ""
    self.File = ""
end

function ScriptUpdate:Base64Encode(data)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x)
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

function ScriptUpdate:GetOnlineVersion()
    if self.GotScriptVersion then return end

    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
    end
    if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
        self.RecvStarted = true
        self.DownloadStatus = 'Downloading VersionInfo (0%)'
    end

    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</s'..'ize>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</si'..'ze>')-1))
        end
        if self.File:find('<scr'..'ipt>') then
            local _,ScriptFind = self.File:find('<scr'..'ipt>')
            local ScriptEnd = self.File:find('</scr'..'ipt>')
            if ScriptEnd then ScriptEnd = ScriptEnd - 1 end
            local DownloadedSize = self.File:sub(ScriptFind+1,ScriptEnd or -1):len()
            self.DownloadStatus = 'Downloading VersionInfo ('..math.round(100/self.Size*DownloadedSize,2)..'%)'
        end
    end
    if self.File:find('</scr'..'ipt>') then
        self.DownloadStatus = 'Downloading VersionInfo (100%)'
        local a,b = self.File:find('\r\n\r\n')
        self.File = self.File:sub(a,-1)
        self.NewFile = ''
        for line,content in ipairs(self.File:split('\n')) do
            if content:len() > 5 then
                self.NewFile = self.NewFile .. content
            end
        end
        local HeaderEnd, ContentStart = self.File:find('<scr'..'ipt>')
        local ContentEnd, _ = self.File:find('</sc'..'ript>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            self.OnlineVersion = (Base64Decode(self.File:sub(ContentStart + 1,ContentEnd-1)))
            self.OnlineVersion = tonumber(self.OnlineVersion)
            if self.OnlineVersion > self.LocalVersion then
                if self.CallbackNewVersion and type(self.CallbackNewVersion) == 'function' then
                    self.CallbackNewVersion(self.OnlineVersion,self.LocalVersion)
                end
                self:CreateSocket(self.ScriptPath)
                self.DownloadStatus = 'Connect to Server for ScriptDownload'
                AddTickCallback(function() self:DownloadUpdate() end)
            else
                if self.CallbackNoUpdate and type(self.CallbackNoUpdate) == 'function' then
                    self.CallbackNoUpdate(self.LocalVersion)
                end
            end
        end
        self.GotScriptVersion = true
    end
end

function ScriptUpdate:DownloadUpdate()
    if self.GotScriptUpdate then return end
    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
    end
    if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
        self.RecvStarted = true
        self.DownloadStatus = 'Downloading Script (0%)'
    end

    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</si'..'ze>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</si'..'ze>')-1))
        end
        if self.File:find('<scr'..'ipt>') then
            local _,ScriptFind = self.File:find('<scr'..'ipt>')
            local ScriptEnd = self.File:find('</scr'..'ipt>')
            if ScriptEnd then ScriptEnd = ScriptEnd - 1 end
            local DownloadedSize = self.File:sub(ScriptFind+1,ScriptEnd or -1):len()
            self.DownloadStatus = 'Downloading Script ('..math.round(100/self.Size*DownloadedSize,2)..'%)'
        end
    end
    if self.File:find('</scr'..'ipt>') then
        self.DownloadStatus = 'Downloading Script (100%)'
        local a,b = self.File:find('\r\n\r\n')
        self.File = self.File:sub(a,-1)
        self.NewFile = ''
        for line,content in ipairs(self.File:split('\n')) do
            if content:len() > 5 then
                self.NewFile = self.NewFile .. content
            end
        end
        local HeaderEnd, ContentStart = self.NewFile:find('<sc'..'ript>')
        local ContentEnd, _ = self.NewFile:find('</scr'..'ipt>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            local newf = self.NewFile:sub(ContentStart+1,ContentEnd-1)
            local newf = newf:gsub('\r','')
            if newf:len() ~= self.Size then
                if self.CallbackError and type(self.CallbackError) == 'function' then
                    self.CallbackError()
                end
                return
            end
            local newf = Base64Decode(newf)
            if type(load(newf)) ~= 'function' then
                if self.CallbackError and type(self.CallbackError) == 'function' then
                    self.CallbackError()
                end
            else
                local f = io.open(self.SavePath,"w+b")
                f:write(newf)
                f:close()
                if self.CallbackUpdate and type(self.CallbackUpdate) == 'function' then
                    self.CallbackUpdate(self.OnlineVersion,self.LocalVersion)
                end
            end
        end
        self.GotScriptUpdate = true
    end
end