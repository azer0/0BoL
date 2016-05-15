
_G.Powered = {
	Version = 103,
	TargetManager = nil,
	DisplayManager = nil,
	CastManager = nil,
	OrbWalkManager = nil,
	MainMenu = nil,
	PredictionManager = nil,
	ChampionManager = nil,

	CurrentChamp = {
		tsRange = 1000,
		dmgType = DAMAGE_MAGIC,
		Q = {
			range = 0,
			speed = 0,
			width = 0,
			delay = 0.25
		},
		W = {
			range = 0,
			speed = 0,
			width = 0,
			delay = 0.25
		},
		E = {
			range = 0,
			speed = 0,
			width = 0,
			delay = 0.25
		},
		R = {
			range = 0,
			speed = 0,
			width = 0,
			delay = 0.25
		}
	},

	loadedOrbwalkers = {},

	ScriptTitle = "Soraka - The Star Child",

	FHPred = nil,
	VPred = nil
}

local find, len = string.find, string.len
local gsub, byte, sub = string.gsub, string.byte, string.sub
local random, round = math.random, math.round

class("MyTargeting")
function MyTargeting:__init()
	self.target = nil
	self.targetSelector = TargetSelector(TARGET_LESS_CAST, _G.Powered.CurrentChamp.tsRange, _G.Powered.CurrentChamp.dmgType)
end

function MyTargeting:OnWndMsg(button, misc)
	if button == WM_LBUTTONDOWN then
		Click = 10
		targetonly = nil

		for _, target in pairs(GetEnemyHeroes()) do
			if ValidTarget(target) then
				if GetDistance(target, mousePos) <= Click or targetonly == nil then
					Click = GetDistance(target, mousePos)
					targetonly = target

					if targetonly and Click < target.boundingRadius * 2 then
						if self.target and targetonly.charName == self.target.charName then
							self.target = nil
							_G.Powered.DisplayManager:ToScreen("Target removed. [T: " .. self.target.charName .. "] [R: Clicked]", false)
						else
							self.target = targetonly
							_G.Powered.DisplayManager:ToScreen("Target selected. [T: ".. self.target.charName .."] [R: Clicked]", false)
						end
					end
				end
			end
		end
	end
end

function MyTargeting:GetTarget()
	if self.target ~= nil then
		if self.target.dead then
			self.target = nil
			_G.Powered.DisplayManager:ToScreen("Target removed. [T: " .. self.target.charName .. "] [R: Dead]", false)
		elseif GetDistance(self.target, myHero) <= _G.Powered.CurrentChamp.tsRange then
			return self.target
		else
			self.target = nil
		end
	elseif _G.AutoCarry and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then
		return _G.AutoCarry.Attack_Crosshair.target
	else
		self.targetSelector:update()
		return self.targetSelector.target
	end
end

class("DisplayManager")
function DisplayManager:__init()
	self.shouldDebug = true
end

function DisplayManager:ToScreen(message, isDebug)
	if self.shouldDebug == false and isDebug then
		return
	end
	fontColor = "3393FF"
	if isDebug then
		fontColor = "EC33FF"
	end
	print("<font color=\"#FF5733\">[Powered " .. myHero.charName .. "]</font> <font color=\"" .. fontColor .. "\">" .. message .. "</font>")
end

class("MyCastManager")
function MyCastManager:__init()
	self.spellData = {
		Q = 0,
		W = 0,
		E = 0,
		R = 0
	}
	self.loaded = true
end

function MyCastManager:CheckSpell(spell)
	if spell == _Q or spell == _W or spell == _E or spell == _R then return end
	spellInfo = myHero:GetSpellData(spell)
	if spellInfo ~= nil then
		self.spellData[spellInfo.name] = 0
	else
		_G.Powered.DisplayManager:ToScreen("Error: Could not find spell data for requested spell.", true)
	end
end

function MyCastManager:CastSpell(spell)
	if spell ~= nil then
		self:CheckSpell(spell)

		spellString = self:SpellToString(spell)
		if self:CanCast(spellString) then
			CastSpell(spell)
			self.spellData[spellString] = os.clock() + 120
		end
	else
		_G.Powered.DisplayManager:ToScreen("Error: CastManager:CastSpell missing required params.", true)
	end
end

function MyCastManager:CastSpellTarget(spell, target)
	if spell ~= nil and target ~= nil then
		self:CheckSpell(spell)

		spellString = self:SpellToString(spell)
		if self:CanCast(spellString) then
			CastSpell(spell, target)

		end
	else
		_G.Powered.DisplayManager:ToScreen("Error: CastManager:CastSpellTarget missing required params.", true)
	end
end

function MyCastManager:CastSpellPosition(spell, posx, posz)
	if spell ~= nil and posx ~= nil and posz ~= nil then
		self:CheckSpell(spell)

		spellString = self:SpellToString(spell)
		if self:CanCast(spellString) then
			CastSpell(spell, posx, posz)
		end
	else
		_G.Powered.DisplayManager:ToScreen("Error: CastManager:CastSpellPosition missing required params.", true)
	end
end

function MyCastManager:SpellToString(spell)
	if spell == _Q then
		return "Q"
	elseif spell == _W then
		return "W"
	elseif spell == _E then
		return "E"
	elseif spell == _R then
		return "R"
	else
		spellInfo = myHero:GetSpellData(spell)
		if spellInfo ~= nil then
			return spellInfo.name
		end
	end
end

function MyCastManager:CanCast(spell)
	if self.spellData[spell] == 0 then
		return true
	else
		if os.clock() <= self.spellData[spell] then
			return true
		end
	end
	return false
end

class("OrbWalkManager")
function OrbWalkManager:__init()
	if _G.Reborn_Loaded or _G.Reborn_Initialised or _G.AutoCarry ~= nil then
		table.insert(_G.Powered.loadedOrbwalkers, "SAC")
	end

	if _G.MMA_IsLoaded then
		table.insert(_G.Powered.loadedOrbwalkers, "MMA")
	end

	if _G._Pewalk then
		table.insert(_G.Powered.loadedOrbwalkers, "Pewalk")
	end

	if FileExist(LIB_PATH .. "/Nebelwolfi's Orb Walker.lua") then
		table.insert(_G.Powered.loadedOrbwalkers, "NOW")
	end

	if FileExist(LIB_PATH .. "/Big Fat Orbwalker.lua") then
		table.insert(_G.Powered.loadedOrbwalkers, "Big Fat Walk")
	end

	if FileExist(LIB_PATH .. "/SOW.lua") then
		table.insert(_G.Powered.loadedOrbwalkers, "SOW")
	end

	if FileExist(LIB_PATH .. "/SxOrbWalk.lua") then
		table.insert(_G.Powered.loadedOrbwalkers, "SxOrbWalk")
	end

	self.selected = nil
	self.orbWalkReady = false

	self:MakeMenu()

	self:Load()
end

function OrbWalkManager:MakeMenu()
	_G.Powered.MainMenu:addSubMenu("-> Orbwalk Manager <-", "OrbWalkManager")
		_G.Powered.MainMenu.OrbWalkManager:addParam("Orbwalker", "OrbWalker", SCRIPT_PARAM_LIST, 1, _G.Powered.loadedOrbwalkers)
		_G.Powered.MainMenu.OrbWalkManager:addParam("info", "Using :", SCRIPT_PARAM_INFO, _G.Powered.loadedOrbwalkers[_G.Powered.MainMenu.OrbWalkManager.Orbwalker])
end

function OrbWalkManager:Load()
	if _G.Powered.loadedOrbwalkers[_G.Powered.MainMenu.OrbWalkManager.Orbwalker] == "SAC" then
		self.selected = _G.Powered.loadedOrbwalkers[_G.Powered.MainMenu.OrbWalkManager.Orbwalker]
		if _G.Reborn_Loaded and _G.Reborn_Initialised then
			self.orbWalkReady = true
			_G.Powered.DisplayManager:ToScreen("Intigrated with SAC:R.", false)
		else
			_G.Powered.DisplayManager:ToScreen("Waiting for intigration with SAC:R.", false)
			DelayAction(function() self.orbWalkReady = true _G.Powered.DisplayManager:ToScreen("Intigrated with SAC:R.", false) end, 10)
		end
	elseif _G.Powered.loadedOrbwalkers[_G.Powered.MainMenu.OrbWalkManager.Orbwalker] == "MMA" then
		self.selected = _G.Powered.loadedOrbwalkers[_G.Powered.MainMenu.OrbWalkManager.Orbwalker]
		self.orbWalkReady = true
		_G.Powered.DisplayManager:ToScreen("Intigrated with MMA.", false)
	elseif _G.Powered.loadedOrbwalkers[_G.Powered.MainMenu.OrbWalkManager.Orbwalker] == "Pewalk" then
		self.selected = _G.Powered.loadedOrbwalkers[_G.Powered.MainMenu.OrbWalkManager.Orbwalker]
		self.orbWalkReady = true
	elseif _G.Powered.loadedOrbwalkers[_G.Powered.MainMenu.OrbWalkManager.Orbwalker] == "NOW" then
		self.selected = _G.Powered.loadedOrbwalkers[_G.Powered.MainMenu.OrbWalkManager.Orbwalker]
		require "Nebelwolfi's Orb Walker"
		_G.NOWi = NebelwolfisOrbWalkerClass()
		self.orbWalkReady = true
		_G.Powered.DisplayManager:ToScreen("Intigrated with Nebelwolfi's.", false)
	elseif _G.Powered.loadedOrbwalkers[_G.Powered.MainMenu.OrbWalkManager.Orbwalker] == "Big Fat Walk" then
		self.selected = _G.Powered.loadedOrbwalkers[_G.Powered.MainMenu.OrbWalkManager.Orbwalker]
		require "Big Fat Orbwalker"
		self.orbWalkReady = true
		_G.Powered.DisplayManager:ToScreen("Intigrated with Big Fat Orbwalker.", false)
	elseif _G.Powered.loadedOrbwalkers[_G.Powered.MainMenu.OrbWalkManager.Orbwalker] == "SOW" then
		self.selected = _G.Powered.loadedOrbwalkers[_G.Powered.MainMenu.OrbWalkManager.Orbwalker]
		require "SOW"
		menu.OrbWalkManager:addSubMenu("SOW", "SOW")
		_G.SOWi = SOW(_G.VP)
		SOW:LoadToMenu(_G.Powered.MainMenu.OrbWalkManager)
		self.orbWalkReady = true
		_G.Powered.DisplayManager:ToScreen("Intigrated with SOW.", false)
	elseif _G.Powered.loadedOrbwalkers[_G.Powered.MainMenu.OrbWalkManager.Orbwalker] == "SxOrbWalk" then
		self.selected = _G.Powered.loadedOrbwalkers[_G.Powered.MainMenu.OrbWalkManager.Orbwalker]
		require "SxOrbWalk"
		menu.OrbWalkManager:addSubMenu("SxOrbWalk", "SxOrbWalk")
		SxOrb:LoadToMenu(_G.Powered.MainMenu.OrbWalkManager)
		self.orbWalkReady = true
		_G.Powered.DisplayManager:ToScreen("Intigrated with SxOrbWalk.", false)
	elseif _G.Powered.loadedOrbwalkers[_G.Powered.MainMenu.OrbWalkManager.Orbwalker] == "S1mpleOrbWalker" then
		self.selected = _G.Powered.loadedOrbwalkers[_G.Powered.MainMenu.OrbWalkManager.Orbwalker]
		require "S1mpleOrbWalker"
		DelayAction(function()
 		   _G.S1mpleOrbWalker:AddToMenu(_G.Powered.MainMenu.OrbWalkManager)
 		   self.orbWalkReady = true
 		   _G.Powered.DisplayManager:ToScreen("Intigrated with S1mple OrbWalker.", false)
	    end, 1)
	end
end

function OrbWalkManager:Mode()
	if self.selected == "SAC" and self.orbWalkReady then
		if _G.AutoCarry.Keys.AutoCarry then return "Combo" end
		if _G.AutoCarry.Keys.MixedMode then return "Harass" end
		if _G.AutoCarry.Keys.LaneClear then return "Laneclear" end
		if _G.AutoCarry.Keys.LastHit then return "Lasthit" end
	end
end

class("PredUtils")
function PredUtils:__init()
	_G.Powered.FHPred = nil
	self.loaded = nil

	_G.Powered.MainMenu:addSubMenu("-> Prediction Manager <-", "PredictionManager")
	_G.Powered.MainMenu.PredictionManager:addParam("pred", "Prediction (require reload)", SCRIPT_PARAM_LIST, 1, {"VPred", "FHPred"})
	
	require "VPrediction"
	_G.Powered.VPred = VPrediction()
	
	predFound = false
	if _G.Powered.MainMenu.PredictionManager.pred == 1 then
		if FileExist(LIB_PATH .. "VPrediction.lua") then
			self.loaded = "VPRED"
			_G.Powered.DisplayManager:ToScreen("Loaded VPrediction.", false)
			predFound = true
		else
			_G.Powered.DisplayManager:ToScreen("Selected prediction [VPrediction] not found. Please downlaod it and reload.", false)
		end
	elseif _G.Powered.MainMenu.PredictionManager.pred == 2 then
		if FileExist(LIB_PATH.."FHPrediction.lua") then
			require("FHPrediction")
			_G.Powered.DisplayManager:ToScreen("Loaded FH Prediction.", false)
			self.loaded = "FHPRED"
			predFound = true
		else
			_G.Powered.DisplayManager:ToScreen("Selected prediction [FHPrediction] not found. Please downlaod it and reload.", false)
		end
	end

	if not predFound then
		_G.PerfDisplay:ToScreen("Please visit http://bol-tools.com to download the required prediction(s). You will then need to double F9 to reload.", false)
	end
end

function PredUtils:PredictLineSkillShot(target, champion, spell, collision)
	if target == nil or champion == nil or spell == nil then return false end
	if self.loaded == "VPRED" then
		local CastPosition, HitChance = _G.Perfect.VPred:GetLineCastPosition(target, _G.Powered.CurrentChamp[spell].delay, _G.Powered.CurrentChamp[spell].width, _G.Powered.CurrentChamp[spell].range, _G.Powered.CurrentChamp[spell].speed, myHero, collision)
		if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < _G.Powered.CurrentChamp[spell].range then
			return {pos = CastPosition, chance = HitChance}
		end
		return
	elseif self.loaded == "FHPRED" then
		local CastPosition, hc, info = FHPrediction.GetPrediction({range = _G.Powered.CurrentChamp[spell].range, speed = _G.Powered.CurrentChamp[spell].speed, delay = _G.Powered.CurrentChamp[spell].delay, radius = _G.Powered.CurrentChamp[spell].width, type = "DelayLine", width = _G.Powered.CurrentChamp[spell].width}, target)
		if hc > 0 and CastPosition ~= nil then
			return {pos = CastPosition, chance = hc}
		end
	end
	return
end

function PredUtils:PredictAOECircleSkillShot(target, champion, spell, collision)
	if target == nil or champion == nil or spell == nil then return false end
	if self.loaded == "VPRED" then
		local mainCastPosition, mainHitChance, points, mainPosition = _G.Perfect.VPred:GetCircularAOECastPosition(target, _G.Powered.CurrentChamp[spell].delay, _G.Powered.CurrentChamp[spell].width, _G.Powered.CurrentChamp[spell].range, _G.Powered.CurrentChamp[spell].speed, myHero, collision)
		if mainCastPosition and mainHitChance and mainHitChance >= 2 and GetDistance(mainCastPosition) < _G.Powered.CurrentChamp[spell].range then
			return {pos = mainCastPosition, chance = mainHitChance}
		end
		return
	elseif self.loaded == "FHPRED" then
		local CastPosition, hc, info = FHPrediction.GetPrediction({range = _G.Powered.CurrentChamp[spell].range, speed = _G.Powered.CurrentChamp[spell].speed, delay = _G.Powered.CurrentChamp[spell].delay, radius = _G.Powered.CurrentChamp[spell].width, type = "DelayLine", width = _G.Powered.CurrentChamp[spell].width}, target)
		if hc > 0 and CastPosition ~= nil then
			return {pos = CastPosition, chance = hc}
		end
	end
	return
end

function PredUtils:PredictHealth(unit, time, delay)
	return _G.Perfect.VPred:GetPredictedHealth(unit, time, delay)
end

class("AutoUpdate")
function AutoUpdate:__init()
	_G.Powered.DisplayManager:ToScreen("Checking for updates...", false)
	self.LocalVersion = _G.Powered.Version
	self.Host = 'raw.githubusercontent.com'
	self.VersionPath = '/azer0/0BoL/master/Version/PoweredSoraka.ver'
	self.ScriptPath = '/azer0/0BoL/master/PoweredSoraka.lua'
	self.LocalPath = SCRIPT_PATH .. '/PoweredSoraka.lua'
	self.CallbackUpdate = function(newVersion, oldVersion)
		_G.Powered.DisplayManager:ToScreen("Updated to version ["..format("%.1f", newVersion).."]. Press F9 twice to reload.", false)
	end
	self.CallbackNoUpdate = function(version)
		_G.Powered.ChampionManager = Champion()
	end
	self.CallbackNewVersion = function(version)
		_G.Powered.DisplayManager:ToScreen("New version ["..format("%.1f", newVersion).."] found. Do not reload until its downloaded.", false)
	end
	self.CallbackError = function(version)
		_G.Powered.DisplayManager:ToScreen("Unable to check for updates.", false)
		_G.Powered.ChampionManager = Champion()
	end

	self.OffsetY = _G.OffsetY and _G.OffsetY or 0
	_G.OffsetY = _G.OffsetY and _G.OffsetY + round(0.08333333333 * WINDOW_H) or round(0.08333333333 * WINDOW_H)

	AddDrawCallback(function()
		self:OnDraw()
	end)

	self:CreateSocket(self.VersionPath)
	self.DownloadStatus = 'Connecting to Server..'
	self.Progress = 0
	AddTickCallback(function()
		self:GetOnlineVersion()
	end)
end

function AutoUpdate:OnDraw()
	if (self.DownloadStatus == 'Downloading Script:' or self.DownloadStatus == 'Downloading Version:') and self.Progress == 100 then
		return
	end

	local LoadingBar =
	{
		X = round(0.91 * WINDOW_W),
		Y = round(0.73 * WINDOW_H) - self.OffsetY,
		Height = round(0.01666666666 * WINDOW_H),
		Width = round(0.171875 * WINDOW_W),
		Border = 1,
		HeaderFontSize = round(0.01666666666 * WINDOW_H),
		ProgressFontSize = round(0.01125 * WINDOW_H),
		BackgroundColor = 0xFFBFC0C2,
		ForegroundColor = 0xFF5A87C8
	}

	DrawText(self.DownloadStatus, LoadingBar.HeaderFontSize, LoadingBar.X - 0.5 * LoadingBar.Width, LoadingBar.Y - LoadingBar.Height - LoadingBar.Border, LoadingBar.BackgroundColor)
	DrawLine(LoadingBar.X, LoadingBar.Y, LoadingBar.X, LoadingBar.Y + LoadingBar.Height, LoadingBar.Width, LoadingBar.BackgroundColor)
	if self.Progress > 0 then
		local Width = 0.01 * ((LoadingBar.Width - 2 * LoadingBar.Border) * self.Progress)
		local Offset = 0.5 * (LoadingBar.Width - Width)
		DrawLine(LoadingBar.X - Offset + LoadingBar.Border, LoadingBar.Y + LoadingBar.Border, LoadingBar.X - Offset + LoadingBar.Border, LoadingBar.Y + LoadingBar.Height - LoadingBar.Border, Width, LoadingBar.ForegroundColor)
	end

	DrawText(self.Progress .. '%', LoadingBar.ProgressFontSize, LoadingBar.X - 2 * LoadingBar.Border, LoadingBar.Y + LoadingBar.Border, self.Progress < 50 and LoadingBar.ForegroundColor or LoadingBar.BackgroundColor)
end

function AutoUpdate:CreateSocket(url)
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

function AutoUpdate:Base64Encode(data)
	local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	return (gsub((gsub(data, '.', function(x)
		local r, b = '', byte(x)
		for i = 8, 1, -1 do
			r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0')
		end

		return r;
	end) .. '0000'), '%d%d%d?%d?%d?%d?', function(x)
		if (#x < 6) then
			return ''
		end

		local c = 0
		for i = 1, 6 do
			c = c + (sub(x, i, i) == '1' and 2 ^ (6 - i) or 0)
		end

		return sub(b, 1 + c, 1 + c)
	end) .. ({ '', '==', '=' })[#data % 3 + 1])
end

function AutoUpdate:GetOnlineVersion()
	if self.GotScriptVersion then
		return
	end

	self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
	if self.Status == 'timeout' and not self.Started then
		self.Started = true
		self.Socket:send("GET " .. self.Url .. " HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
	end

	if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
		self.RecvStarted = true
		self.DownloadStatus = 'Downloading Version:'
		self.Progress = 0
	end

	self.File = self.File .. (self.Receive or self.Snipped)
	if find(self.File, '</size>') then
		if not self.Size then
			self.Size = tonumber(sub(self.File, 6 + find(self.File, '<size>'), find(self.File, '</size>') - 1))
		end

		if find(self.File, '<script>') then
			local _,ScriptFind = find(self.File, '<script>')
			local ScriptEnd = find(self.File, '</script>')
			if ScriptEnd then
				ScriptEnd = ScriptEnd - 1
			end

			local DownloadedSize = len(sub(self.File, 1 + ScriptFind, ScriptEnd or -1))
			self.Progress = round(100 / self.Size * DownloadedSize, 2)
		end
	end

	if find(self.File, '</script>') then
		local a, b = find(self.File, '\r\n\r\n')
		self.File = sub(self.File, a, -1)
		self.NewFile = ''
		for line, content in ipairs(self.File:split('\n')) do
			if len(content) > 5 then
				self.NewFile = self.NewFile .. content
			end
		end

		local HeaderEnd, ContentStart = find(self.File, '<script>')
		local ContentEnd, _ = find(self.File, '</script>')
		if not ContentStart or not ContentEnd then
			if self.CallbackError and type(self.CallbackError) == 'function' then
				self.CallbackError()
			end
		else
			self.OnlineVersion = (Base64Decode(sub(self.File, 1 + ContentStart, ContentEnd - 1)))
			self.OnlineVersion = tonumber(self.OnlineVersion)
			if self.OnlineVersion > self.LocalVersion then
				if self.CallbackNewVersion and type(self.CallbackNewVersion) == 'function' then
					self.CallbackNewVersion(self.OnlineVersion,self.LocalVersion)
				end
				
				self:CreateSocket(self.ScriptPath)
				self.DownloadStatus = 'Connecting to Server..'
				self.Progress = 0
				AddTickCallback(function()
					self:DownloadUpdate()
				end)
			else
				if self.CallbackNoUpdate and type(self.CallbackNoUpdate) == 'function' then
					self.CallbackNoUpdate(self.LocalVersion)
				end
			end
		end

		self.GotScriptVersion = true
	end
end

function AutoUpdate:DownloadUpdate()
	if self.GotScriptUpdate then
		return
	end

	self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
	if self.Status == 'timeout' and not self.Started then
		self.Started = true
		self.Socket:send("GET " .. self.Url .. " HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
	end

	if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
		self.RecvStarted = true
		self.DownloadStatus = 'Downloading Script:'
		self.Progress = 0
	end

	self.File = self.File .. (self.Receive or self.Snipped)
	if find(self.File, '</size>') then
		if not self.Size then
			self.Size = tonumber(sub(self.File, 6 + find(self.File, '<size>'), find(self.File, '</size>') - 1))
		end

		if find(self.File, '<script>') then
			local _, ScriptFind = find(self.File, '<script>')
			local ScriptEnd = find(self.File, '</script>')
			if ScriptEnd then
				ScriptEnd = ScriptEnd - 1
			end

			local DownloadedSize = len(sub(self.File, 1 + ScriptFind, ScriptEnd or -1))
			self.Progress = round(100 / self.Size * DownloadedSize, 2)
		end
	end

	if find(self.File, '</script>') then
		local a, b = find(self.File, '\r\n\r\n')
		self.File = sub(self.File, a, -1)
		self.NewFile = ''
		for line, content in ipairs(self.File:split('\n')) do
			if len(content) > 5 then
				self.NewFile = self.NewFile .. content
			end
		end

		local HeaderEnd, ContentStart = find(self.NewFile, '<script>')
		local ContentEnd, _ = find(self.NewFile, '</script>')
		if not ContentStart or not ContentEnd then
			if self.CallbackError and type(self.CallbackError) == 'function' then
				self.CallbackError()
			end
		else
			local newf = sub(self.NewFile, 1 + ContentStart, ContentEnd - 1)
			local newf = gsub(newf, '\r','')
			if len(newf) ~= self.Size then
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
				local f = io.open(self.LocalPath,"w+b")
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

class("Champion")
function Champion:__init()

end

function OnLoad()
	_G.Powered.DisplayManager = DisplayManager()

	AutoUpdate()

	_G.Powered.MainMenu = scriptConfig("Powered " .. myHero.charName, "Powered")

	_G.Powered.TargetManager = MyTargeting()
	_G.Powered.CastManager = MyCastManager()
	_G.Powered.OrbWalkManager = OrbWalkManager()
	_G.Powered.PredictionManager = PredUtils()
end

function OnWndMsg(key, msg)
	if _G.Powered.TargetManager ~= nil then
		_G.Powered.TargetManager:OnWndMsg(key, msg)
	end
end

function OnTick()
	if _G.Powered.ChampionManager ~= nil then

	end
end