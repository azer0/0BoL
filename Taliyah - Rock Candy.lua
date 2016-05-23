if myHero.charName ~= "Taliyah" then return end

--To Do:
---when enemy tries to leave E knock them back in with W
---knock enemys away on flee


-- Bol Tools Tracker --
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQQfAAAAAwAAAEQAAACGAEAA5QAAAJ1AAAGGQEAA5UAAAJ1AAAGlgAAACIAAgaXAAAAIgICBhgBBAOUAAQCdQAABhkBBAMGAAQCdQAABhoBBAOVAAQCKwICDhoBBAOWAAQCKwACEhoBBAOXAAQCKwICEhoBBAOUAAgCKwACFHwCAAAsAAAAEEgAAAEFkZFVubG9hZENhbGxiYWNrAAQUAAAAQWRkQnVnc3BsYXRDYWxsYmFjawAEDAAAAFRyYWNrZXJMb2FkAAQNAAAAQm9sVG9vbHNUaW1lAAQQAAAAQWRkVGlja0NhbGxiYWNrAAQGAAAAY2xhc3MABA4AAABTY3JpcHRUcmFja2VyAAQHAAAAX19pbml0AAQSAAAAU2VuZFZhbHVlVG9TZXJ2ZXIABAoAAABzZW5kRGF0YXMABAsAAABHZXRXZWJQYWdlAAkAAAACAAAAAwAAAAAAAwkAAAAFAAAAGABAABcAAIAfAIAABQAAAAxAQACBgAAAHUCAAR8AgAADAAAAAAQSAAAAU2VuZFZhbHVlVG9TZXJ2ZXIABAcAAAB1bmxvYWQAAAAAAAEAAAABAQAAAAAAAAAAAAAAAAAAAAAEAAAABQAAAAAAAwkAAAAFAAAAGABAABcAAIAfAIAABQAAAAxAQACBgAAAHUCAAR8AgAADAAAAAAQSAAAAU2VuZFZhbHVlVG9TZXJ2ZXIABAkAAABidWdzcGxhdAAAAAAAAQAAAAEBAAAAAAAAAAAAAAAAAAAAAAUAAAAHAAAAAQAEDQAAAEYAwACAAAAAXYAAAUkAAABFAAAATEDAAMGAAABdQIABRsDAAKUAAADBAAEAXUCAAR8AgAAFAAAABA4AAABTY3JpcHRUcmFja2VyAAQSAAAAU2VuZFZhbHVlVG9TZXJ2ZXIABAUAAABsb2FkAAQMAAAARGVsYXlBY3Rpb24AAwAAAAAAQHpAAQAAAAYAAAAHAAAAAAADBQAAAAUAAAAMAEAAgUAAAB1AgAEfAIAAAgAAAAQSAAAAU2VuZFZhbHVlVG9TZXJ2ZXIABAgAAAB3b3JraW5nAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAEBAAAAAAAAAAAAAAAAAAAAAAAACAAAAA0AAAAAAAYyAAAABgBAAB2AgAAaQEAAF4AAgEGAAABfAAABF0AKgEYAQQBHQMEAgYABAMbAQQDHAMIBEEFCAN0AAAFdgAAACECAgUYAQQBHQMEAgYABAMbAQQDHAMIBEMFCAEbBQABPwcICDkEBAt0AAAFdgAAACEAAhUYAQQBHQMEAgYABAMbAQQDHAMIBBsFAAA9BQgIOAQEARoFCAE/BwgIOQQEC3QAAAV2AAAAIQACGRsBAAIFAAwDGgEIAAUEDAEYBQwBWQIEAXwAAAR8AgAAOAAAABA8AAABHZXRJbkdhbWVUaW1lcgADAAAAAAAAAAAECQAAADAwOjAwOjAwAAQGAAAAaG91cnMABAcAAABzdHJpbmcABAcAAABmb3JtYXQABAYAAAAlMDIuZgAEBQAAAG1hdGgABAYAAABmbG9vcgADAAAAAAAgrEAEBQAAAG1pbnMAAwAAAAAAAE5ABAUAAABzZWNzAAQCAAAAOgAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAA4AAAATAAAAAAAIKAAAAAEAAABGQEAAR4DAAIEAAAAhAAiABkFAAAzBQAKAAYABHYGAAVgAQQIXgAaAR0FBAhiAwQIXwAWAR8FBAhkAwAIXAAWARQGAAFtBAAAXQASARwFCAoZBQgCHAUIDGICBAheAAYBFAQABTIHCAsHBAgBdQYABQwGAAEkBgAAXQAGARQEAAUyBwgLBAQMAXUGAAUMBgABJAYAAIED3fx8AgAANAAAAAwAAAAAAAPA/BAsAAABvYmpNYW5hZ2VyAAQLAAAAbWF4T2JqZWN0cwAECgAAAGdldE9iamVjdAAABAUAAAB0eXBlAAQHAAAAb2JqX0hRAAQHAAAAaGVhbHRoAAQFAAAAdGVhbQAEBwAAAG15SGVybwAEEgAAAFNlbmRWYWx1ZVRvU2VydmVyAAQGAAAAbG9vc2UABAQAAAB3aW4AAAAAAAMAAAAAAAEAAQEAAAAAAAAAAAAAAAAAAAAAFAAAABQAAAACAAICAAAACkAAgB8AgAABAAAABAoAAABzY3JpcHRLZXkAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFAAAABUAAAACAAUKAAAAhgBAAMAAgACdgAABGEBAARfAAICFAIAAjIBAAQABgACdQIABHwCAAAMAAAAEBQAAAHR5cGUABAcAAABzdHJpbmcABAoAAABzZW5kRGF0YXMAAAAAAAIAAAAAAAEBAAAAAAAAAAAAAAAAAAAAABYAAAAlAAAAAgATPwAAAApAAICGgEAAnYCAAAqAgICGAEEAxkBBAAaBQQAHwUECQQECAB2BAAFGgUEAR8HBAoFBAgBdgQABhoFBAIfBQQPBgQIAnYEAAcaBQQDHwcEDAcICAN2BAAEGgkEAB8JBBEECAwAdggABFgECAt0AAAGdgAAACoCAgYaAQwCdgIAACoCAhgoAxIeGQEQAmwAAABdAAIAKgMSHFwAAgArAxIeGQEUAh4BFAQqAAIqFAIAAjMBFAQEBBgBBQQYAh4FGAMHBBgAAAoAAQQIHAIcCRQDBQgcAB0NAAEGDBwCHw0AAwcMHAAdEQwBBBAgAh8RDAFaBhAKdQAACHwCAACEAAAAEBwAAAGFjdGlvbgAECQAAAHVzZXJuYW1lAAQIAAAAR2V0VXNlcgAEBQAAAGh3aWQABA0AAABCYXNlNjRFbmNvZGUABAkAAAB0b3N0cmluZwAEAwAAAG9zAAQHAAAAZ2V0ZW52AAQVAAAAUFJPQ0VTU09SX0lERU5USUZJRVIABAkAAABVU0VSTkFNRQAEDQAAAENPTVBVVEVSTkFNRQAEEAAAAFBST0NFU1NPUl9MRVZFTAAEEwAAAFBST0NFU1NPUl9SRVZJU0lPTgAECwAAAGluZ2FtZVRpbWUABA0AAABCb2xUb29sc1RpbWUABAYAAABpc1ZpcAAEAQAAAAAECQAAAFZJUF9VU0VSAAMAAAAAAADwPwMAAAAAAAAAAAQJAAAAY2hhbXBpb24ABAcAAABteUhlcm8ABAkAAABjaGFyTmFtZQAECwAAAEdldFdlYlBhZ2UABA4AAABib2wtdG9vbHMuY29tAAQXAAAAL2FwaS9ldmVudHM/c2NyaXB0S2V5PQAECgAAAHNjcmlwdEtleQAECQAAACZhY3Rpb249AAQLAAAAJmNoYW1waW9uPQAEDgAAACZib2xVc2VybmFtZT0ABAcAAAAmaHdpZD0ABA0AAAAmaW5nYW1lVGltZT0ABAgAAAAmaXNWaXA9AAAAAAACAAAAAAABAQAAAAAAAAAAAAAAAAAAAAAmAAAAKgAAAAMACiEAAADGQEAAAYEAAN2AAAHHwMAB3YCAAArAAIDHAEAAzADBAUABgACBQQEA3UAAAscAQADMgMEBQcEBAIABAAHBAQIAAAKAAEFCAgBWQYIC3UCAAccAQADMgMIBQcECAIEBAwDdQAACxwBAAMyAwgFBQQMAgYEDAN1AAAIKAMSHCgDEiB8AgAASAAAABAcAAABTb2NrZXQABAgAAAByZXF1aXJlAAQHAAAAc29ja2V0AAQEAAAAdGNwAAQIAAAAY29ubmVjdAADAAAAAAAAVEAEBQAAAHNlbmQABAUAAABHRVQgAAQSAAAAIEhUVFAvMS4wDQpIb3N0OiAABAUAAAANCg0KAAQLAAAAc2V0dGltZW91dAADAAAAAAAAAAAEAgAAAGIAAwAAAPyD15dBBAIAAAB0AAQKAAAATGFzdFByaW50AAQBAAAAAAQFAAAARmlsZQAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAABAAAAAAAAAAAAAAAAAAAAAAA="), nil, "bt", _ENV))()
TrackerLoad("lhjPspIzCO7cXUBi")
-- Bol Tools Tracker --

require 'VPrediction'
VPred = VPrediction()

config = {
	version = 1004,
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
	myMines = {},
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
			lastCast = 0,
			delay = 0.2,
			width = 130,
			range = 910,
			speed = 1200,
			colide = true
		},
		W = {
			ready = false,
			lastCast = 0,
			readyForTwo = false,
			target = nil,
			delay = 0.5,
			width = 150,
			range = 900,
			speed = 1500,
			colide = false
		},
		E = {
			ready = false,
			lastCast = 0,
			delay = math.huge,
			width = 330,
			range = 570,
			speed = 800,
			colide = false
		},
		R = {
			ready = false,
			lastCast = 0,
			delay = 0,
			width = 0,
			range = 0,
			speed = 0,
			colide = false
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
				local CastPosition, HitChance = VPred:GetLineCastPosition(minions, myData.spells.Q.delay, myData.spells.Q.width, myData.spells.Q.range, myData.spells.Q.speed, myHero, myData.spells.Q.colide)
				if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 910 then
					CastQ(CastPosition.x, CastPosition.z)
				end
			end

			if myData.menu.LaneClearManager.W and CanCastW() then
				local CastPosition, HitChance = VPred:GetCircularAOECastPosition(minions, myData.spells.W.delay, myData.spells.W.width, myData.spells.W.range, myData.spells.W.speed, myHero, myData.spells.W.colide)
				if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 910 then
					CastW(CastPosition.x, CastPosition.z)
					DelayAction(function() CastW2(myHero.x, myHero.z) end, .5)
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
		if myData.menu.HarassManager.Qnew and myData.menu.HarassManager.Q and CanCastQ() and not myData.onWorkedGround then
			local CastPosition, HitChance = VPred:GetLineCastPosition(target, myData.spells.Q.delay, myData.spells.Q.width, myData.spells.Q.range, myData.spells.Q.speed, myHero, myData.spells.Q.colide)
			if CastPosition and HitChance and HitChance > 2 and GetDistance(CastPosition) < 850 then
				CastQ(CastPosition.x, CastPosition.z)
			end
		end

		if myData.menu.HarassManager.Q and CanCastQ() and myData.onWorkedGround then
			local CastPosition, HitChance = VPred:GetLineCastPosition(target, myData.spells.Q.delay, myData.spells.Q.width, myData.spells.Q.range, myData.spells.Q.speed, myHero, myData.spells.Q.colide)
			if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 910 then
				CastQ(CastPosition.x, CastPosition.z)
			end
		end

		--E Logics
		if myData.menu.HarassManager.E and CanCastE() then
			local CastPosition, HitChance = VPred:GetCircularAOECastPosition(target, myData.spells.E.delay, myData.spells.E.width, myData.spells.E.range, myData.spells.E.speed, myHero, myData.spells.E.colide)
			if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 700 then
				CastE(CastPosition.x, CastPosition.z)
			end
		end

		--W Logics
		if myData.menu.HarassManager.W and CanCastW() then
			local CastPosition, HitChance = VPred:GetCircularAOECastPosition(target, myData.spells.W.delay, myData.spells.W.width, myData.spells.W.range, myData.spells.W.speed, myHero, myData.spells.W.colide)
			if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 910 then
				if GetDistance(CastPosition, target.pos) < 175 then
					CastW(CastPosition.x, CastPosition.z)
					myData.spells.W.target = target
				end
				--if target.health > myHero.health then
				--	newPos = DoYouEvenExtend(myHero, CastPosition, 80)
				--	DelayAction(function() CastW2(newPos.x, newPos.z) end, .3)
				--else
				--	DelayAction(function() CastW2(myHero.x, myHero.z) end, .3)
				--end
			end
		end
	else

		for _,v in pairs(GetEnemyHeroes()) do
			if ValidTarget(v, 1000) then
				--Q Logics
				if myData.menu.HarassManager.Qnew and myData.menu.HarassManager.Q and CanCastQ() and not myData.onWorkedGround then
					local CastPosition, HitChance = VPred:GetLineCastPosition(v, myData.spells.Q.delay, myData.spells.Q.width, myData.spells.Q.range, myData.spells.Q.speed, myHero, myData.spells.Q.colide)
					if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 850 then
						CastQ(CastPosition.x, CastPosition.z)
					end
				end

				if myData.menu.HarassManager.Q and CanCastQ() and myData.onWorkedGround then
					local CastPosition, HitChance = VPred:GetLineCastPosition(v, myData.spells.Q.delay, myData.spells.Q.width, myData.spells.Q.range, myData.spells.Q.speed, myHero, myData.spells.Q.colide)
					if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 910 then
						CastQ(CastPosition.x, CastPosition.z)
					end
				end

				--E Logics
				if myData.menu.HarassManager.E and CanCastE() then
					local CastPosition, HitChance = VPred:GetCircularAOECastPosition(v, myData.spells.E.delay, myData.spells.E.width, myData.spells.E.range, myData.spells.E.speed, myHero, myData.spells.E.colide)
					if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 700 then
						CastE(CastPosition.x, CastPosition.z)
					end
				end

				--W Logics
				if myData.menu.HarassManager.W and CanCastW() then
					local CastPosition, HitChance = VPred:GetCircularAOECastPosition(v, myData.spells.W.delay, myData.spells.W.width, myData.spells.W.range, myData.spells.W.speed, myHero, myData.spells.W.colide)
					if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 910 then
						if GetDistance(CastPosition, v.pos) < 175 then
							CastW(CastPosition.x, CastPosition.z)
							myData.spells.W.target = v
						end
						--if v.health > myHero.health then
						--	newPos = DoYouEvenExtend(myHero, CastPosition, 80)
						--	DelayAction(function() CastW2(newPos.x, newPos.z) end, .3)
						--else
						--	DelayAction(function() CastW2(myHero.x, myHero.z) end, .3)
						--end
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
		if myData.menu.ComboManager.Qnew and myData.menu.ComboManager.Q and CanCastQ() and not myData.onWorkedGround then
			local CastPosition, HitChance = VPred:GetLineCastPosition(target,myData.spells.Q.delay, myData.spells.Q.width, myData.spells.Q.range, myData.spells.Q.speed, myHero, myData.spells.Q.colide)
			if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 850 then
				CastQ(CastPosition.x, CastPosition.z)
			end
		end

		if myData.menu.ComboManager.Q and CanCastQ() and myData.onWorkedGround then
			local CastPosition, HitChance = VPred:GetLineCastPosition(target, myData.spells.Q.delay, myData.spells.Q.width, myData.spells.Q.range, myData.spells.Q.speed, myHero, myData.spells.Q.colide)
			if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 910 then
				CastQ(CastPosition.x, CastPosition.z)
			end
		end

		--E Logics
		if myData.menu.ComboManager.E and CanCastE() then
			local CastPosition, HitChance = VPred:GetCircularAOECastPosition(target, myData.spells.E.delay, myData.spells.E.width, myData.spells.E.range, myData.spells.E.speed, myHero, myData.spells.E.colide)
			if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 700 then
				CastE(CastPosition.x, CastPosition.z)
			end
		end

		--W Logics
		if myData.menu.ComboManager.W and CanCastW() then
			local CastPosition, HitChance = VPred:GetCircularAOECastPosition(target, myData.spells.W.delay, myData.spells.W.width, myData.spells.W.range, myData.spells.W.speed, myHero, myData.spells.W.colide)
			if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 910 then
				if GetDistance(CastPosition, target.pos) < 175 then
					CastW(CastPosition.x, CastPosition.z)
					myData.spells.W.target = target
				end
				--if target.health > myHero.health then
				--	bestAlly = GetClosestAllyAboveHP(target, 120, target.health)
				--	if bestAlly ~= nil and bestAlly:GetDistance(myHero) > myHero:GetDistance(target) then
				--		DelayAction(function() CastW2(bestAlly.pos.x, bestAlly.pos.z) PrintPretty("Pushing [" .. target.charName .. "] to [" .. bestAlly.charName .. "].", true, true) end, .3)
				--	else
				--		newPos = DoYouEvenExtend(myHero, CastPosition, 120)
				--		DelayAction(function() CastW2(newPos.x, newPos.z) PrintPretty("Pushing [" .. target.charName .. "] [Calculated Push Away].", true, true) end, .3)
				--	end
				--else
				--	DelayAction(function() CastW2(myHero.x, myHero.z) PrintPretty("Pushing [" .. target.charName .. "] to [Me].", true, true) end, .3)
				--end
			end
		end
	else

		for _,v in pairs(GetEnemyHeroes()) do
			if ValidTarget(v, 1000) then
				--Q Logics
				if myData.menu.ComboManager.Qnew and myData.menu.ComboManager.Q and CanCastQ() and not myData.onWorkedGround then
					local CastPosition, HitChance = VPred:GetLineCastPosition(v, myData.spells.Q.delay, myData.spells.Q.width, myData.spells.Q.range, myData.spells.Q.speed, myHero, myData.spells.Q.colide)
					if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 850 then
						CastQ(CastPosition.x, CastPosition.z)
					end
				end

				if myData.menu.ComboManager.Q and CanCastQ() and myData.onWorkedGround then
					local CastPosition, HitChance = VPred:GetLineCastPosition(v, myData.spells.Q.delay, myData.spells.Q.width, myData.spells.Q.range, myData.spells.Q.speed, myHero, myData.spells.Q.colide)
					if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 910 then
						CastQ(CastPosition.x, CastPosition.z)
					end
				end

				--E Logics
				if myData.menu.ComboManager.E and CanCastE() then
					local CastPosition, HitChance = VPred:GetCircularAOECastPosition(v, myData.spells.E.delay, myData.spells.E.width, myData.spells.E.range, myData.spells.E.speed, myHero, myData.spells.E.colide)
					if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 700 then
						CastE(CastPosition.x, CastPosition.z)
					end
				end

				--W Logics
				if myData.menu.ComboManager.W and CanCastW() then
					local CastPosition, HitChance = VPred:GetCircularAOECastPosition(v, myData.spells.W.delay, myData.spells.W.width, myData.spells.W.range, myData.spells.W.speed, myHero, myData.spells.W.colide)
					if CastPosition and HitChance and HitChance >= 2 and GetDistance(CastPosition) < 910 then
						if GetDistance(CastPosition, v.pos) < 175 then
							CastW(CastPosition.x, CastPosition.z)
							myData.spells.W.target = v
						end
						--bestAlly = GetClosestAllyAboveHP(v, 120, v.health)
						--if bestAlly ~= nil and bestAlly:GetDistance(myHero) > myHero:GetDistance(v) then
						--	DelayAction(function() CastW2(bestAlly.pos.x, bestAlly.pos.z) PrintPretty("Pushing [" .. v.charName .. "] to [" .. bestAlly.charName .. "].", true, true) end, .3)
						--else
						--	newPos = DoYouEvenExtend(myHero, CastPosition, 120)
						--	DelayAction(function() CastW2(newPos.x, newPos.z) PrintPretty("Pushing [" .. v.charName .. "] [Calculated Push Away].", true, true) end, .3)
						--end
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
		myData.menu.ComboManager:addParam("Qnew", "Q New Ground", SCRIPT_PARAM_ONOFF, false)
		myData.menu.ComboManager:addParam("Qdirection", "Q Direction", SCRIPT_PARAM_LIST, 3, {"Push","Pull","Smart"})
		myData.menu.ComboManager:addParam("Qmode", "Q Direction", SCRIPT_PARAM_LIST, 2, {"Always","Smart"})
		myData.menu.ComboManager:addParam("W", "Use W in Combo Mode", SCRIPT_PARAM_ONOFF, true)
		myData.menu.ComboManager:addParam("E", "Use E in Combo Mode", SCRIPT_PARAM_ONOFF, true)
	myData.menu:addSubMenu("-> Lane Clear Manager <-", "LaneClearManager")
		myData.menu.LaneClearManager:addParam("Q", "Use Q in Combo Mode", SCRIPT_PARAM_ONOFF, true)
		myData.menu.LaneClearManager:addParam("W", "Use W in Combo Mode", SCRIPT_PARAM_ONOFF, true)
		myData.menu.LaneClearManager:addParam("E", "Use E in Combo Mode", SCRIPT_PARAM_ONOFF, true)
	myData.menu:addSubMenu("-> Harass Manager <-", "HarassManager")
		myData.menu.HarassManager:addParam("Q", "Use Q in Combo Mode", SCRIPT_PARAM_ONOFF, true)
		myData.menu.HarassManager:addParam("Qnew", "Q New Ground", SCRIPT_PARAM_ONOFF, false)
		myData.menu.HarassManager:addParam("W", "Use W in Combo Mode", SCRIPT_PARAM_ONOFF, true)
		myData.menu.HarassManager:addParam("E", "Use E in Combo Mode", SCRIPT_PARAM_ONOFF, true)
	myData.menu:addSubMenu("-> Draw Manager <-", "DrawManager")
		myData.menu.DrawManager:addParam("Q", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
		myData.menu.DrawManager:addParam("W", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
		myData.menu.DrawManager:addParam("E", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
		myData.menu.DrawManager:addParam("worked", "Notify when on worked ground", SCRIPT_PARAM_ONOFF, true)
		myData.menu.DrawManager:addParam("damage", "Draw Damage", SCRIPT_PARAM_ONOFF, true)
	myData.menu:addSubMenu("-> Spell Manager <-", "SpellManager")
end

--On_____ Section

function OnDraw()
	if myData.menu.DrawManager.Q then
		DrawCircle(myHero.x, myHero.y, myHero.z, 910, 0x111111)
	end
	if myData.menu.DrawManager.W then
		DrawCircle(myHero.x, myHero.y, myHero.z, 900, 0x111111)
	end
	if myData.menu.DrawManager.E then
		DrawCircle(myHero.x, myHero.y, myHero.z, 750, 0x111111)
	end

	if myData.menu.DrawManager.worked and myData.onWorkedGround then
		sPos = WorldToScreen(D3DXVECTOR3(myHero.x,myHero.y,myHero.z))
		DrawText("On Worked Ground", 20, sPos.x - 75, sPos.y + 25, ARGB(150,255,255,255))
	end

	if myData.menu.DrawManager.damage then
		for _,v in pairs(GetEnemyHeroes()) do
			if ValidTarget(v) then
				local barPos = GetUnitHPBarPos(v)
				local barOffset = GetUnitHPBarOffset(v)
				do
					local t = {
						["Darius"] = -0.05,
						["Renekton"] = -0.05,
						["Sion"] = -0.05,
						["Thresh"] = 0.03,
						["Jhin"] = -0.06,
						['AniviaEgg'] = -0.1
					}
					barOffset.x = t[v.charName] or 0
				end
				local baseX = barPos.x - 69 + barOffset.x * 150
				local baseY = barPos.y + barOffset.y * 50 + 12.5

				if v.charName == "Jhin" then 
					baseY = baseY - 12
				end
				
				local myDamage = 0
				if (myData.menu.ComboManager.W and CanCastW()) and (myData.menu.ComboManager.Q and CanCastQ()) and (myData.menu.ComboManager.E and CanCastE()) then
					myDamage = FullDamage(v)
				elseif (myData.menu.ComboManager.W and CanCastW()) and (myData.menu.ComboManager.Q and CanCastQ()) then
					myDamage = QDamage(v) + WDamage(v)
				elseif (myData.menu.ComboManager.E and CanCastE()) and (myData.menu.ComboManager.Q and CanCastQ()) then
					myDamage = QDamage(v) + EDamage(v)
				elseif (myData.menu.ComboManager.E and CanCastE()) and (myData.menu.ComboManager.W and CanCastW()) then
					myDamage = WDamage(v) + EDamage(v)
				elseif (myData.menu.ComboManager.E and CanCastE()) then
					myDamage = EDamage(v)
				elseif (myData.menu.ComboManager.W and CanCastW()) then
					myDamage = WDamage(v)
				elseif (myData.menu.ComboManager.Q and CanCastQ()) then
					myDamage = QDamage(v)
				end

				local dmgperc = myDamage/v.health*100
				local enemyhpperc = v.health/v.maxHealth
				
				if dmgperc < 100 then
					DrawLine(baseX, baseY-10, baseX+(1.05*dmgperc)*enemyhpperc, baseY-10, 15, ARGB(180,2.55*dmgperc,0,-255+2.55*dmgperc))
				else
					DrawLine(baseX, baseY-10, baseX+105*enemyhpperc, baseY-10, 15, ARGB(180,255,0,0))
					DrawText("Killable", 18, baseX + 45, baseY-60, ARGB(180,2.55*dmgperc,0,-255+2.55*dmgperc))
				end
				
			end
		end
	end
end

function OnLoad()
	PrintPretty("Welcome to Rock Candy v" .. config.version, false, true)
	PrintPretty("This is still a <b><u>work in progress</u></b> so please report any bugs you may find on the forum.", false, true)

	myData.menu = scriptConfig(config.name, "001data")
	MakeMenu()

	Update()

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

	--Check mines
	for i, mines in pairs(myData.myMines) do
		if mines == nil or mines.pos == nil then
			table.remove(myData.myMines, i)
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
		if obj.name == "TaliyahMine" then
			table.insert(myData.myMines, obj)
		end
	end
end

function OnProcessSpell(object, spell)
	if object == myHero and spell.name == "TaliyahW" then
		myData.spells.W.readyForTwo = true
		if myData.spells.W.target ~= nil then
			target = myData.spells.W.target
			if not target or target == nil or target.dead then return end

			for i, mines in pairs(myData.myMines) do
				if mines and mines.pos and GetDistance(mines.pos, target.pos) < 15 then
					myData.spells.W.readyForTwo = false
					myData.spells.W.target = nil
					return
				end
			end

			if target.health > myHero.health then
				if myData.menu.ComboManager == 1 then
					DelayAction(function() CastW2(myHero.x, myHero.z) PrintPretty("Pushing [" .. target.charName .. "] to [Me].", true, true) end, .4)
				elseif myData.menu.ComboManager == 2 then
					newPos = DoYouEvenExtend(myHero, target, 120)
					DelayAction(function() CastW2(newPos.x, newPos.z) PrintPretty("Pushing [" .. target.charName .. "] [Calculated Push Away].", true, true) end, .4)
				else
					bestAlly = GetClosestAllyAboveHP(target, 120, target.health)
					if bestAlly ~= nil and bestAlly:GetDistance(myHero) > myHero:GetDistance(target) then
						DelayAction(function() CastW2(bestAlly.pos.x, bestAlly.pos.z) PrintPretty("Pushing [" .. target.charName .. "] to [" .. bestAlly.charName .. "].", true, true) end, .4)
					else
						newPos = DoYouEvenExtend(myHero, target, 120)
						DelayAction(function() CastW2(newPos.x, newPos.z) PrintPretty("Pushing [" .. target.charName .. "] [Calculated Push Away].", true, true) end, .4)
					end
				end
			else
				DelayAction(function() CastW2(myHero.x, myHero.z) PrintPretty("Pulling [" .. target.charName .. "] to [Me].", true, true) end, .4)
			end
		end
		myData.spells.W.target = nil
	end
	if object == myHero then
		PrintPretty("Spell Cast [".. spell.name .."]", true, true)
	end
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
	elseif myData.orbWalks.SELECTED == "PEWALK" then
		if _G._Pewalk.GetActiveMode().Carry then return "Combo" end
		if _G._Pewalk.GetActiveMode().Mixed then return "Harass" end
		if _G._Pewalk.GetActiveMode().LaneClear then return "Laneclear" end
		if _G._Pewalk.GetActiveMode().Farm then return "Lasthit" end
	elseif myData.orbWalks.SELECTED == "NEBELWOLFI" then
		if _G.NOWi.Config.k.Combo then return "Combo" end
		if _G.NOWi.Config.k.Harass then return "Harass" end
		if _G.NOWi.Config.k.LaneClear then return "Laneclear" end
		if _G.NOWi.Config.k.LastHit then return "Lasthit" end
	elseif myData.orbWalks.SELECTED == "SX" then
		if _G.SxOrb.isFight then return "Combo" end
		if _G.SxOrb.isHarass then return "Harass" end
		if _G.SxOrb.isLaneClear then return "Laneclear" end
		if _G.SxOrb.isLastHit then return "Lasthit" end
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

function GetClosestAlly(target, maxRange)
	if target and target.visible and not target.dead then
		best = nil
		bestDist = nil
		for _, v in ipairs(GetAllyHeroes()) do
			dist = v:GetDistance(target)
			if v and not v.dead and dist < maxRange then
				if bestDist == nil or bestDist > dist then
					best = v
					bestDist = dist
				end
			end
		end
		return best
	end
	return nil
end

function GetClosestAllyAboveHP(target, maxRange, HP)
	if target and target.visible and not target.dead then
		best = nil
		bestDist = nil
		for _, v in ipairs(GetAllyHeroes()) do
			dist = v:GetDistance(target)
			if v and not v.dead and dist < maxRange and v.health > HP then
				if bestDist == nil or bestDist > dist then
					best = v
					bestDist = dist
				end
			end
		end
		return best
	end
	return nil
end

--Spell Cast
function CastE(x, z)
	myData.spells.E.lastCast = os.clock()
	CastSpell(_E, x, z)
end

function CanCastE()
	if (myHero:CanUseSpell(_E) == READY) and (myData.spells.E.lastCast + 0.75 <= os.clock() or myData.spells.E.lastCast == 0) then
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
	if (myHero:CanUseSpell(_Q) == READY) and (myData.spells.Q.lastCast + 0.75 <= os.clock() or myData.spells.Q.lastCast == 0) then
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
	if (myHero:CanUseSpell(_W) == READY) and (myData.spells.W.lastCast + 0.75 <= os.clock() or myData.spells.W.lastCast == 0) then
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
	if (myHero:CanUseSpell(_R) == READY) and (myData.spells.R.lastCast + 0.75 <= os.clock() or myData.spells.R.lastCast == 0) then
		return true
	else
		return false
	end
end

--Damage calc
function QDamage(target)
	spellLevel = GetSpellData(_Q).level
	levelDamage = {60,80,100,120,140}
	myApScale = myHero.ap * 0.4
	if not myData.onWorkedGround then
		levelDamage = {180,240,300,360,420}
		myApScale = myHero.ap * 1.2
	end
	damage = levelDamage[spellLevel] + myApScale
	return damage
end

function WDamage(target)
	spellLevel = GetSpellData(_W).level
	levelDamage = {60,80,100,120,140}
	myApScale = myHero.ap * 0.4
	damage = levelDamage[spellLevel] + myApScale
	return damage
end

function EDamage(target)
	spellLevel = GetSpellData(_E).level
	levelDamage = {40,52.5,65,77.5,90}
	myApScale = myHero.ap * 0.2
	damage = levelDamage[spellLevel] + myApScale
	return damage
end

function FullDamage(target)
	return QDamage(target) + WDamage(target) + EDamage(target)
end

--Updater

function Update()
    local UpdateHost = "raw.githubusercontent.com"
    local ServerPath = "/azer0/0BoL/master/"
    local ServerFileName = "Taliyah%20-%20Rock%20Candy.lua"
    local ServerVersionFileName = "Version/RockCandy.Version"
    local version = 0.07
 
    DL = Download()
    local ServerVersionDATA = GetWebResult(UpdateHost , ServerPath..ServerVersionFileName)
    if ServerVersionDATA then
        local ServerVersion = tonumber(ServerVersionDATA)
        if ServerVersion then
            if ServerVersion > tonumber(config.version) then
                PrintPretty("Updating to ["..ServerVersion.."] please do NOT reload.", false, true)
                DL:newDL(UpdateHost, ServerPath..ServerFileName, ServerFileName, SCRIPT_PATH, function ()
                    PrintPretty("Update complete! Please press F9 twice.", false, true)
                end)
            else
            	PrintPretty("Server Version ["..ServerVersion.."] Local Version [".. config.version .. "].", false, true)
            end
        else
            PrintPretty("A unexpected error occured, please reload.", false, true)
        end
    else
        PrintPretty("Could not connect to update server.", false, true)
    end
end

class "Download"
function Download:__init()
    socket = require("socket")
    self.aktivedownloads = {}
    self.callbacks = {}
 
    AddTickCallback(function ()
        self:RemoveDone()
    end)
 
    class("Async")
    function Async:__init(host, filepath, localname, drawoffset, localpath)
        self.progress = 0
        self.host = host
        self.filepath = filepath
        self.localname = localname
        self.offset = drawoffset
        self.localpath = localpath
        self.CRLF = '\r\n'
 
        self.headsocket = socket.tcp()
        self.headsocket:settimeout(1)
        self.headsocket:connect(self.host, 80)
        self.headsocket:send('HEAD '..self.filepath..' HTTP/1.1'.. self.CRLF ..'Host: '..self.host.. self.CRLF ..'User-Agent: Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36'.. self.CRLF .. self.CRLF)
 
        self.HEADdata = ""
        self.DLdata = ""
        self.StartedDownload = false
        self.canDL = true
 
        AddTickCallback(function ()
            self:tick()
        end)
        AddDrawCallback(function ()
            self:draw()
        end)
    end
 
    function Async:tick()
        if self.progress == 100 then return end
        if self.HEADcStatus ~= "timeout" and self.HEADcStatus ~= "closed" then
            self.HEADfString, self.HEADcStatus, self.HEADpString = self.headsocket:receive(16);
            if self.HEADfString then
                self.HEADdata = self.HEADdata..self.HEADfString
            elseif self.HEADpString and #self.HEADpString > 0 then
                self.HEADdata = self.HEADdata..self.HEADpString
            end
        elseif self.HEADcStatus == "timeout" then
            self.headsocket:close()
            --Find Lenght
            local begin = string.find(self.HEADdata, "Length: ")
            if begin then
                self.HEADdata = string.sub(self.HEADdata,begin+8)
                local n = 0
                local _break = false
                for i=1, #self.HEADdata do
                    local c = tonumber(string.sub(self.HEADdata,i,i))
                    if c and _break == false then
                        n = n+1
                    else
                        _break = true
                    end
                end
                self.HEADdata = string.sub(self.HEADdata,1,n)
                self.StartedDownload = true
                self.HEADcStatus = "closed"
            end
        end
        if self.HEADcStatus == "closed" and self.StartedDownload == true and self.canDL == true then --Double Check
            self.canDL = false
            self.DLsocket = socket.tcp()
            self.DLsocket:settimeout(1)
            self.DLsocket:connect(self.host, 80)
            --Start Main Download
            self.DLsocket:send('GET '..self.filepath..' HTTP/1.1'.. self.CRLF ..'Host: '..self.host.. self.CRLF ..'User-Agent: Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36'.. self.CRLF .. self.CRLF)
        end
       
        if self.DLsocket and self.DLcStatus ~= "timeout" and self.DLcStatus ~= "closed" then
            self.DLfString, self.DLcStatus, self.DLpString = self.DLsocket:receive(1024);
           
            if ((self.DLfString) or (self.DLpString and #self.DLpString > 0)) then
                self.DLdata = self.DLdata .. (self.DLfString or self.DLpString)
            end
 
        elseif self.DLcStatus and self.DLcStatus == "timeout" then
            self.DLsocket:close()
            self.DLcStatus = "closed"
            self.DLdata = string.sub(self.DLdata,#self.DLdata-tonumber(self.HEADdata)+1)
 
            local file = io.open(self.localpath.."\\"..self.localname, "w+b")
            file:write(self.DLdata)
            file:close()
            self.progress = 100
        end
 
        if self.progress ~= 100 and self.DLdata and #self.DLdata > 0 then
            self.progress = (#self.DLdata/tonumber(self.HEADdata))*100
        end
    end
 
    function Async:draw()
        if self.progress < 100 then
            DrawTextA("Downloading: "..self.localname,15,50,35+self.offset)
            DrawRectangleOutline(49,50+self.offset,250,20, ARGB(255,255,255,255),1)
            if self.progress ~= 100 then
                DrawLine(50,60+self.offset,50+(2.5*self.progress),60+self.offset,18,ARGB(150,255-self.progress*2.5,self.progress*2.5,255-self.progress*2.5))
                DrawTextA(tostring(math.round(self.progress).." %"), 15,150,52+self.offset)
            end
        end
    end
 
end
 
function Download:newDL(host, file, name, path, callback)
    local offset = (#self.aktivedownloads+1)*40
    self.aktivedownloads[#self.aktivedownloads+1] = Async(host, file, name, offset-40, path)
    if not callback then
        callback = (function ()
        end)
    end
 
    self.callbacks[#self.callbacks+1] = callback
 
end
 
function Download:RemoveDone()
    if #self.aktivedownloads == 0 then return end
    local x = {}
    for k, v in pairs(self.aktivedownloads) do
        if math.round(v.progress) < 100 then
            v.offset = k*40-40
            x[#x+1] = v
        else
            self.callbacks[k]()
        end
    end
    self.aktivedownloads = {}
    self.aktivedownloads = x
end