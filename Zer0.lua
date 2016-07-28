--Credits:
--Taliyah
---0x3A for the Taliyah worked ground tracking idea
---UndercoverRiotEmployee for ideas

--HiranN - the skill shot data i reworked into my table

--Change Log
--Version 1643
---Ashe
----Fixed a error with her Q and W hopefully, i had trouble re-producing it
---Soraka
----Fixed healing percent calculation
----Adjusted Q skill shot data
---Taliyah
----Improved some logic, more to come
--Version 1642
---Taliyah
----Fixed some of the missing W logic
----Added lane clear mode with support for Q,E. W will be soon
----Fixed a typpo making E not cast

require "VPrediction"

--Config
_G.ZeroConfig = {
	printEnemyDashes = true,
	shouldWeDebug = false,
	scriptName = "Zer0 Bundle",
	menu = nil,
	ZVersion = 1643
}

--DATA
_G.DataStore = {
	ChampionL = nil,
	Champion = nil
}

ColorCodes = {
	["Yellow"] = ARGB(0xFF,0xFF,0xFF,0x00),
	["Red"] = ARGB(0xFF,0xFF,0x00,0x00),
	["Green"] = ARGB(0xFF,0x00,170,0x00),
	["White"] = ARGB(0xFF,0xFF,0xFF,0xFF),
	["Gray"] = ARGB(255,128,128,128),
	["Blue"] = ARGB(0,0,255,255)
}

WardInfo = {
	["YellowTrinket"] = {
		length = 60,
		color = ColorCodes.Yellow,
		spell = "trinkettotemlvl1"
	},
	["BlueTrinket"] = {
		length = 0,
		color = ColorCodes.Blue,
		spell = "trinketorblvl3"
	},
	["SightWard"] = {
		length = 150,
		color = ColorCodes.Yellow,
		spell = "itemghostward"
	},
	["VisionWard"] = {
		length = 0,
		color = ColorCodes.Gray,
		spell = "visionward"
	}
}

BadSpotInfo = {
	["TeemoMushroom"] = {
		length = 600,
		color = ColorCodes.Red,
		spell = "bantamtrap"
	},
	["CaitlynTrap"] = {
		length = 90,
		color = ColorCodes.Red,
		spell = "caitlynyordletrap"
	},
	["ShacoBox"] = {
		length = 60,
		color = ColorCodes.Red,
		spell = "jackinthebox"
	}
}

AllChampions = {
	["Aatrox"] = {
		name = "Aatrox",
		skillData = {
			["AatroxE"] = {
				name = "Blade of Torment",
				spellName = "AatroxE",
				projectileName = "AatroxBladeofTorment_mis.troy",
				projectileSpeed = 1200,
				projectileRange = 1075,
				projectileRadius = 100,
				projectileType = "line",
				spellDelay = 250,
				selfCast = false,
				buffAA = false
			},
			["AatroxW"] = {
				name = "AatroxW",
				spellName = "AatroxW",
				projectileName = nil,
				projectileSpeed = nil,
				projectileRange = nil,
				projectileRadius = nil,
				projectileType = nil,
				selfCast = true,
				buffAA = true
			},
			["AatroxQ"] = {
				name = "AatroxQ",
				spellName = "AatroxQ",
				projectileName = "AatroxQ.troy",
				projectileSpeed = 450,
				projectileRange = 650,
				projectileRadius = 145,
				projectileType = "circle",
				selfCast = false,
				buffAA = false
			},
			["AatroxR"] = {
				name = "AatroxR",
				spellName = "AatroxR",
				projectileName = nil,
				projectileSpeed = nil,
				projectileRange = 125,
				projectileRadius = nil,
				projectileType = nil,
				selfCast = true,
				buffAA = true
			}
		}
	},

	["Ahri"] = {
		name = "Ahri",
		skillData = {
			["AhriOrbofDeception"] = {
				name = "Orb of Deception",
				spellName = "AhriOrbofDeception",
				projectileName = "Ahri_Orb_mis.troy",
				projectileSpeed = 1750,
				projectileRange = 800,
				projectileRadius = 100,
				projectileType = "line",
				spellDelay = 250,
				selfCast = false,
				buffAA = false
			},
			["AhriOrbofDeception2"] = {
				name = "Orb of Deception Return",
				spellName = "AhriOrbofDeception!",
				projectileName = "Ahri_Orb_mis_02.troy",
				projectileSpeed = 915,
				projectileRange = 800,
				projectileRadius = 100,
				projectileType = "line",
				spellDelay = 0,
				selfCast = false,
				buffAA = false
			},
			["AhriSeduce"] = {
				name = "Charm",
				spellName = "AhriSeduce",
				projectileName = "Ahri_Charm_mis.troy",
				projectileSpeed = 1600,
				projectileRange = 1075,
				projectileRadius = 60,
				projectileType = "line",
				selfCast = false,
				buffAA = false
			},
			["AhriFoxFire"] = {
				name = "Fox Fire",
				spellName = "AhriFoxFire",
				projectileName = "AatroxQ.troy",
				projectileSpeed = 1400,
				projectileRange = 750,
				projectileRadius = nil,
				projectileType = nil,
				selfCast = true,
				buffAA = false
			}
		}
	},

	--alistar

	["Amumu"] = {
		name = "Amumu",
		skillData = {
			["BandageToss"] = {
				name = "Bandage Toss",
				spellName = "BandageToss",
				projectileName = "Bandage_beam.troy",
				projectileSpeed = 2000,
				projectileRange = 1100,
				projectileRadius = 80,
				projectileType = "line",
				spellDelay = 250,
				selfCast = false,
				buffAA = false
			},
			["Tantrum"] = {
				name = "Tantrum",
				spellName = "Tantrum",
				projectileName = nil,
				projectileSpeed = nil,
				projectileRange = 200,
				projectileRadius = nil,
				projectileType = "circle",
				spellDelay = 250,
				selfCast = true,
				buffAA = false
			}
		}
	},
}

local BaseArmor = {  --Credit: PewPewPew
	Aatrox = {Base=24.384, PerLvl=3.8,},
	Ahri = {Base=20.88, PerLvl=3.5,},
	Akali = {Base=26.38, PerLvl=3.5,},
	Alistar = {Base=24.38, PerLvl=3.5,},
	Amumu = {Base=23.544, PerLvl=3.8,},
	Anivia = {Base=21.22, PerLvl=4,},
	Annie = {Base=19.22, PerLvl=4,},
	Ashe = {Base=21.212, PerLvl=3.4,},
	AurelionSol = {Base=19, PerLvl=3.6,},
	Azir = {Base=19.04, PerLvl=3,},
	Bard = {Base=25, PerLvl=4,},
	Blitzcrank = {Base=24.38, PerLvl=4,},
	Brand = {Base=21.88, PerLvl=3.5,},
	Braum = {Base=26.72, PerLvl=4.5,},
	Caitlyn = {Base=22.88, PerLvl=3.5,},
	Cassiopeia = {Base=25, PerLvl=3.5,},
	Chogath = {Base=28.88, PerLvl=3.5,},
	Corki = {Base=23.38, PerLvl=3.5,},
	Darius = {Base=29.88, PerLvl=4,},
	Diana = {Base=26.048, PerLvl=3.6,},
	DrMundo = {Base=26.88, PerLvl=3.5,},
	Draven = {Base=25.544, PerLvl=3.3,},
	Ekko = {Base=27, PerLvl=3,},
	Elise = {Base=22.128, PerLvl=3.35,},
	Evelynn = {Base=26.5, PerLvl=3.8,},
	Ezreal = {Base=21.88, PerLvl=3.5,},
	Fiddlesticks = {Base=20.88, PerLvl=3.5,},
	Fiora = {Base=24, PerLvl=3.5,},
	Fizz = {Base=22.412, PerLvl=3.4,},
	Galio = {Base=26.88, PerLvl=3.5,},
	Gangplank = {Base=26, PerLvl=3,},
	Garen = {Base=27.536, PerLvl=3,},
	Gnar = {Base=23, PerLvl=2.5,},
	Gragas = {Base=26.048, PerLvl=3.6,},
	Graves = {Base=24.376, PerLvl=3.4,},
	Hecarim = {Base=26.72, PerLvl=4,},
	Heimerdinger = {Base=19.04, PerLvl=3,},
	Illaoi = {Base=26, PerLvl=3.8,},
	Irelia = {Base=25.3, PerLvl=3.75,},
	Janna = {Base=19.384, PerLvl=3.8,},
	JarvanIV = {Base=29.048, PerLvl=3.6,},
	Jax = {Base=27.04, PerLvl=3,},
	Jayce = {Base=22.38, PerLvl=3.5,},
	Jhin = {Base=20, PerLvl=3.5,},
	Jinx = {Base=22.88, PerLvl=3.5,},
	Kalista = {Base=19.012, PerLvl=3.5,},
	Karma = {Base=20.384, PerLvl=3.8,},
	Karthus = {Base=20.88, PerLvl=3.5,},
	Kassadin = {Base=23.376, PerLvl=3.2,},
	Katarina = {Base=26.88, PerLvl=3.5,},
	Kayle = {Base=26.88, PerLvl=3.5,},
	Kennen = {Base=24.3, PerLvl=3.75,},
	Khazix = {Base=27, PerLvl=3,},
	Kindred = {Base=27, PerLvl=3.25,},
	KogMaw = {Base=19.88, PerLvl=3.5,},
	Leblanc = {Base=21.88, PerLvl=3.5,},
	LeeSin = {Base=24.216, PerLvl=3.7,},
	Leona = {Base=27.208, PerLvl=3.6,},
	Lissandra = {Base=20.216, PerLvl=3.7,},
	Lucian = {Base=24.04, PerLvl=3,},
	Lulu = {Base=19.216, PerLvl=3.7,},
	Lux = {Base=18.72, PerLvl=4,},
	Malphite = {Base=28.3, PerLvl=3.75,},
	Malzahar = {Base=21.88, PerLvl=3.5,},
	Maokai = {Base=28.72, PerLvl=4,},
	MasterYi = {Base=24.04, PerLvl=3,}, 
	MissFortune = {Base=24.04, PerLvl=3,},
	Mordekaiser = {Base=20, PerLvl=3.75,},
	Morgana = {Base=25.384, PerLvl=3.8,},
	Nami = {Base=19.72, PerLvl=4,},
	Nasus = {Base=24.88, PerLvl=3.5,},
	Nautilus = {Base=26.46, PerLvl=3.75,},
	Nidalee = {Base=22.88, PerLvl=3.5,},
	Nocturne = {Base=26.88, PerLvl=3.5,},
	Nunu = {Base=26.38, PerLvl=3.5,},
	Olaf = {Base=26.04, PerLvl=3,},
	Orianna = {Base=17.04, PerLvl=3,},
	Pantheon = {Base=27.652, PerLvl=3.9,},
	Poppy = {Base=29, PerLvl=3.5,},
	Quinn = {Base=23.38, PerLvl=3.5,},
	Rammus = {Base=31.384, PerLvl=4.3,},
	RekSai = {Base=28.3, PerLvl=3.75,},
	Renekton = {Base=25.584, PerLvl=3.8,},
	Rengar = {Base=25.88, PerLvl=3.5,},
	Riven = {Base=24.376, PerLvl=3.2,},
	Rumble = {Base=25.88, PerLvl=3.5,},
	Ryze = {Base=21.552, PerLvl=3,},
	Sejuani = {Base=29.54, PerLvl=3,},
	Shaco = {Base=24.88, PerLvl=3.5,},
	Shen = {Base=25	, PerLvl=2.6,},
	Shyvana = {Base=27.628, PerLvl=3.35,},
	Singed = {Base=27.88, PerLvl=3.5,},
	Sion = {Base=23.04, PerLvl=3,},
	Sivir = {Base=22.21, PerLvl=3.25,},
	Skarner = {Base=29.384, PerLvl=3.8,},
	Sona = {Base=20.544, PerLvl=3.3,},
	Soraka = {Base=23.384, PerLvl=3.8,},
	Swain = {Base=22.72, PerLvl=4,},
	Syndra = {Base=24.712, PerLvl=3.4,},
	TahmKench = {Base=27, PerLvl=3.5,},
	Taliyah = {Base=20, PerLvl=3,},
	Talon = {Base=26.88, PerLvl=3.5,},
	Taric = {Base=25, PerLvl=3.4,},
	Teemo = {Base=24.3, PerLvl=3.75,},
	Thresh = {Base=16, PerLvl=0,},
	Tristana = {Base=22.0, PerLvl=3,},
	Trundle = {Base=27.536, PerLvl=2.7,},
	Tryndamere = {Base=24.108, PerLvl=3.1,},
	TwistedFate = {Base=20.542, PerLvl=3.15,},
	Twitch = {Base=23.04, PerLvl=3,},
	Udyr = {Base=25.47, PerLvl=4,},
	Urgot = {Base=24.544, PerLvl=3.3,},
	Varus = {Base=23.212, PerLvl=3,},
	Vayne = {Base=19.012, PerLvl=3.4,},
	Veigar = {Base=22.55, PerLvl=3.75,},
	VelKoz = {Base=21.88, PerLvl=3.5,},
	Vi = {Base=25.88, PerLvl=3.5,},
	Viktor = {Base=22.72, PerLvl=4,},
	Vladimir = {Base=23	, PerLvl=3.3,},
	Volibear = {Base=26.38, PerLvl=3.5,},
	Warwick = {Base=25.88, PerLvl=3.5,},
	MonkeyKing = {Base=24.88, PerLvl=3.5,},
	Xerath = {Base=21.88, PerLvl=3.5,},
	XinZhao = {Base=25.88, PerLvl=3.5,},
	Yasuo = {Base=24.712, PerLvl=3.4,},
	Yorick = {Base=25.048, PerLvl=3.6,},
	Zac = {Base=23.88, PerLvl=3.5,},
	Zed = {Base=26.88, PerLvl=3.5,},
	Ziggs = {Base=21.544, PerLvl=3.3,},
	Zilean = {Base=19.134, PerLvl=3.8,},
	Zyra = {Base=20.04, PerLvl=3,},
}

local BaseMR =  --Credit: Roach
{
	Aatrox = { Base = 32.10, PerLevel = 1.25 },
	Ahri = { Base = 30.00, PerLevel = 0.00 },
	Akali = { Base = 32.10, PerLevel = 1.25 },
	Alistar = { Base = 32.10, PerLevel = 1.25 },
	Amumu = { Base = 32.10, PerLevel = 1.25 },
	Anivia = { Base = 30.00, PerLevel = 0.00 },
	Annie = { Base = 30.00, PerLevel = 0.00 },
	Ashe = { Base = 30.00, PerLevel = 0.00 },
	AurelionSol = { Base = 30.00, PerLevel = 0.00 },
	Azir = { Base = 30.00, PerLevel = 0.00 },
	Bard = { Base = 30.00, PerLevel = 0.00 },
	Blitzcrank = { Base = 32.10, PerLevel = 1.25 },
	Brand = { Base = 30.00, PerLevel = 0.00 },
	Braum = { Base = 32.10, PerLevel = 1.25 },
	Caitlyn = { Base = 30.00, PerLevel = 0.00 },
	Cassiopeia = { Base = 30.00, PerLevel = 0.00 },
	ChoGath = { Base = 32.10, PerLevel = 1.25 },
	Corki = { Base = 30.00, PerLevel = 0.00 },
	Darius = { Base = 32.10, PerLevel = 1.25 },
	Diana = { Base = 32.10, PerLevel = 1.25 },
	DrMundo = { Base = 32.10, PerLevel = 1.25 },
	Draven = { Base = 30.00, PerLevel = 0.00 },
	Ekko = { Base = 32.00, PerLevel = 1.25 },
	Elise = { Base = 30.00, PerLevel = 0.00 },
	Evelynn = { Base = 32.10, PerLevel = 1.25 },
	Ezreal = { Base = 30.00, PerLevel = 0.00 },
	Fiddlesticks = { Base = 30.00, PerLevel = 0.00 },
	Fiora = { Base = 32.10, PerLevel = 1.25 },
	Fizz = { Base = 32.10, PerLevel = 1.25 },
	Galio = { Base = 32.10, PerLevel = 1.25 },
	Gangplank = { Base = 32.10, PerLevel = 1.25 },
	Garen = { Base = 32.10, PerLevel = 1.25 },
	Gnar = { Base = 30.00, PerLevel = 0.00 },
	Gragas = { Base = 32.10, PerLevel = 1.25 },
	Graves = { Base = 30.00, PerLevel = 0.00 },
	Hecarim = { Base = 32.10, PerLevel = 1.25 },
	Heimerdinger = { Base = 30.00, PerLevel = 0.00 },
	Illaoi = { Base = 32.10, PerLevel = 1.25 },
	Irelia = { Base = 32.10, PerLevel = 1.25 },
	Janna = { Base = 30.00, PerLevel = 0.00 },
	JarvanIV = { Base = 32.10, PerLevel = 1.25 },
	Jax = { Base = 32.10, PerLevel = 1.25 },
	Jayce = { Base = 30.00, PerLevel = 0.00 },
	Jhin = { Base = 30.00, PerLevel = 0.00 },
	Jinx = { Base = 30.00, PerLevel = 0.00 },
	Kalista = { Base = 30.00, PerLevel = 0.00 },
	Karma = { Base = 30.00, PerLevel = 0.00 },
	Karthus = { Base = 30.00, PerLevel = 0.00 },
	Kassadin = { Base = 30.00, PerLevel = 0.00 },
	Katarina = { Base = 32.10, PerLevel = 1.25 },
	Kayle = { Base = 30.00, PerLevel = 0.00 },
	Kennen = { Base = 30.00, PerLevel = 0.00 },
	KhaZix = { Base = 32.10, PerLevel = 1.25 },
	Kindred = { Base = 30.00, PerLevel = 0.00 },
	KogMaw = { Base = 30.00, PerLevel = 0.00 },
	LeBlanc = { Base = 30.00, PerLevel = 0.00 },
	LeeSin = { Base = 32.10, PerLevel = 1.25 },
	Leona = { Base = 32.10, PerLevel = 1.25 },
	Lissandra = { Base = 30.00, PerLevel = 0.00 },
	Lucian = { Base = 30.00, PerLevel = 0.00 },
	Lulu = { Base = 30.00, PerLevel = 0.00 },
	Lux = { Base = 30.00, PerLevel = 0.00 },
	Malphite = { Base = 32.10, PerLevel = 1.25 },
	Malzahar = { Base = 30.00, PerLevel = 0.00 },
	Maokai = { Base = 32.10, PerLevel = 1.25 },
	MasterYi = { Base = 32.10, PerLevel = 1.25 },
	MissFortune = { Base = 30.00, PerLevel = 0.00 },
	MonkeyKing = { Base = 32.10, PerLevel = 1.25 },
	Mordekaiser = { Base = 32.10, PerLevel = 1.25 },
	Morgana = { Base = 30.00, PerLevel = 0.00 },
	Nami = { Base = 30.00, PerLevel = 0.00 },
	Nasus = { Base = 32.10, PerLevel = 1.25 },
	Nautilus = { Base = 32.10, PerLevel = 1.25 },
	Nidalee = { Base = 30.00, PerLevel = 0.00 },
	Nocturne = { Base = 32.10, PerLevel = 1.25 },
	Nunu = { Base = 32.10, PerLevel = 1.25 },
	Olaf = { Base = 32.10, PerLevel = 1.25 },
	Orianna = { Base = 30.00, PerLevel = 0.00 },
	Pantheon = { Base = 32.10, PerLevel = 1.25 },
	Poppy = { Base = 32.00, PerLevel = 1.25 },
	Quinn = { Base = 30.00, PerLevel = 0.00 },
	Rammus = { Base = 32.10, PerLevel = 1.25 },
	RekSai = { Base = 32.10, PerLevel = 1.25 },
	Renekton = { Base = 32.10, PerLevel = 1.25 },
	Rengar = { Base = 32.10, PerLevel = 1.25 },
	Riven = { Base = 32.10, PerLevel = 1.25 },
	Rumble = { Base = 32.10, PerLevel = 1.25 },
	Ryze = { Base = 30.00, PerLevel = 0.00 },
	Sejuani = { Base = 32.10, PerLevel = 1.25 },
	Shaco = { Base = 32.10, PerLevel = 1.25 },
	Shen = { Base = 32.10, PerLevel = 1.25 },
	Shyvana = { Base = 32.10, PerLevel = 1.25 },
	Singed = { Base = 32.10, PerLevel = 1.25 },
	Sion = { Base = 32.10, PerLevel = 1.25 },
	Sivir = { Base = 30.00, PerLevel = 0.00 },
	Skarner = { Base = 32.10, PerLevel = 1.25 },
	Sona = { Base = 30.00, PerLevel = 0.00 },
	Soraka = { Base = 30.00, PerLevel = 0.00 },
	Swain = { Base = 30.00, PerLevel = 0.00 },
	Syndra = { Base = 30.00, PerLevel = 0.00 },
	TahmKench = { Base = 32.10, PerLevel = 1.25 },
	Taliyah = { Base = 30.00, PerLevel = 0.00 },
	Talon = { Base = 32.10, PerLevel = 1.25 },
	Taric = { Base = 32.10, PerLevel = 1.25 },
	Teemo = { Base = 30.00, PerLevel = 0.00 },
	Thresh = { Base = 30.00, PerLevel = 0.00 },
	Tristana = { Base = 30.00, PerLevel = 0.00 },
	Trundle = { Base = 32.10, PerLevel = 1.25 },
	Tryndamere = { Base = 32.10, PerLevel = 1.25 },
	TwistedFate = { Base = 30.00, PerLevel = 0.00 },
	Twitch = { Base = 30.00, PerLevel = 0.00 },
	Udyr = { Base = 32.10, PerLevel = 1.25 },
	Urgot = { Base = 30.00, PerLevel = 0.00 },
	Varus = { Base = 30.00, PerLevel = 0.00 },
	Vayne = { Base = 30.00, PerLevel = 0.00 },
	Veigar = { Base = 30.00, PerLevel = 0.00 },
	VelKoz = { Base = 30.00, PerLevel = 0.00 },
	Vi = { Base = 32.10, PerLevel = 1.25 },
	Viktor = { Base = 30.00, PerLevel = 0.00 },
	Vladimir = { Base = 30.00, PerLevel = 0.00 },
	Volibear = { Base = 32.10, PerLevel = 1.25 },
	Warwick = { Base = 32.10, PerLevel = 1.25 },
	Xerath = { Base = 30.00, PerLevel = 0.00 },
	XinZhao = { Base = 32.10, PerLevel = 1.25 },
	Yasuo = { Base = 30.00, PerLevel = 0.00 },
	Yorick = { Base = 32.10, PerLevel = 1.25 },
	Zac = { Base = 32.10, PerLevel = 1.25 },
	Zed = { Base = 32.10, PerLevel = 1.25 },
	Ziggs = { Base = 30.00, PerLevel = 0.00 },
	Zilean = { Base = 30.00, PerLevel = 0.00 },
	Zyra = { Base = 30.00, PerLevel = 0.00 }
}

local ItemsToUse = {
	"BilgewaterCutlass",
	"YoumusBlade",
	"HextechGunblade",
	"ItemSwordOfFeastAndFamine",
	"QuicksilverSash",
	"ItemDervishBlade"
}

local PotionsToUse = {
	"ItemCrystalFlask",
	"RegenerationPotion",
	"ItemMiniRegenPotion",
	"ItemCrystalFlaskJungle",
	"ItemDarkCrystalFlask"
}

local BuffsDontAttack = {
	"undyingrage",
	"sionpassivezombie",
	"aatroxpassivedeath",
	"chronoshift",
	"judicatorintervention"
}

--Champion Classes
class("ChampionLoader")
function ChampionLoader:__init()
	
end

function ChampionLoader:CanUseChamp()
	if myHero.charName == "Taliyah" then
		return true
	elseif myHero.charName == "Lux" then
		return true
	elseif myHero.charName == "Ashe" then
		return true
	elseif myHero.charName == "Soraka" then
		return true
	elseif myHero.charName == "Teemo" then
		return true
	elseif myHero.charName == "Ahri" then
		return true
	end
	return false
end

function ChampionLoader:GetChampO()
	if myHero.charName == "Taliyah" then
		return ChampionTaliyah()
	elseif myHero.charName == "Lux" then
		return ChampionLux()
	elseif myHero.charName == "Ashe" then
		return ChampionAshe()
	elseif myHero.charName == "Soraka" then
		return ChampionSoraka()
	elseif myHero.charName == "Teemo" then
		return ChampionTeemo()
	elseif myHero.charName == "Ahri" then
		return ChampionAhri()
	end
	return nil
end

--
--
--TALIYAH
--
--
local onWorkedGround = false
local usedGround = {}
class("ChampionTaliyah")
function ChampionTaliyah:__init()
	self.ver = 1002

	PrintPretty("Credits To: UndercoverRiotEmployee [Ideas]", true, false)

	self.menu = scriptConfig("Zer0 Bundle - Taliyah", "003dataTaliyah")
	self.menu:addSubMenu("-> Extra Keys <-", "keys")
		self.menu.keys:addParam("flee", "Flee Mode", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte( 'T' ))

	self.menu:addSubMenu("-> Combo Logic <-", "combo")
		self.menu.combo:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		self.menu.combo:addParam("Qnew", "Use Q on Un-Worked Ground", SCRIPT_PARAM_ONOFF, true)
		self.menu.combo:addParam("Qused", "Use Q on Worked Ground", SCRIPT_PARAM_ONOFF, true)
		self.menu.combo:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
		self.menu.combo:addParam("Waway", "W away when more HP", SCRIPT_PARAM_ONOFF, true)
		self.menu.combo:addParam("Wtoward", "W toward when less HP", SCRIPT_PARAM_ONOFF, true)
		self.menu.combo:addParam("Wmine", "W into E", SCRIPT_PARAM_ONOFF, true)
		self.menu.combo:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
		self.menu.combo:addParam("Ignite", "Use Ignite", SCRIPT_PARAM_ONOFF, true)

	self.menu:addSubMenu("-> Harass Logic <-", "harass")
		self.menu.harass:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		self.menu.harass:addParam("Qnew", "Use Q on Un-Worked Ground", SCRIPT_PARAM_ONOFF, false)
		self.menu.harass:addParam("Qused", "Use Q on Worked Ground", SCRIPT_PARAM_ONOFF, true)
		self.menu.harass:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
		self.menu.harass:addParam("Waway", "W away when more HP", SCRIPT_PARAM_ONOFF, true)
		self.menu.harass:addParam("Wtoward", "W toward when less HP", SCRIPT_PARAM_ONOFF, true)
		self.menu.harass:addParam("Wmine", "W into E", SCRIPT_PARAM_ONOFF, true)
		self.menu.harass:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)

	self.menu:addSubMenu("-> Harass 2 Logic <-", "lasthit")
		self.menu.lasthit:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, false)
		self.menu.lasthit:addParam("Qnew", "Use Q on Un-Worked Ground", SCRIPT_PARAM_ONOFF, false)
		self.menu.lasthit:addParam("Qused", "Use Q on Worked Ground", SCRIPT_PARAM_ONOFF, false)
		self.menu.lasthit:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, false)
		self.menu.lasthit:addParam("Waway", "W away when more HP", SCRIPT_PARAM_ONOFF, false)
		self.menu.lasthit:addParam("Wtoward", "W toward when less HP", SCRIPT_PARAM_ONOFF, false)
		self.menu.lasthit:addParam("Wmine", "W into E", SCRIPT_PARAM_ONOFF, false)
		self.menu.lasthit:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, false)

	self.menu:addSubMenu("-> Lane Clear Logic <-", "laneclear")
		self.menu.laneclear:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		self.menu.laneclear:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
		self.menu.laneclear:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)

	self.menu:addSubMenu("-> Dash Logic <-", "dash")
		for _,v in pairs(GetEnemyHeroes()) do
				if v then
					self.menu.dash:addParam(v.charName, v.charName, SCRIPT_PARAM_ONOFF, true)
				end
			end
	self.menu:addSubMenu("-> Draw <-", "draw")
		self.menu.draw:addParam("target", "Draw Target", SCRIPT_PARAM_ONOFF, true)
		self.menu.draw:addParam("worked", "Draw Worked Ground", SCRIPT_PARAM_ONOFF, true)
		self.menu.draw:addParam("damage", "Predicted Damage", SCRIPT_PARAM_ONOFF, true)

	self.menu:addSubMenu("-> Debug <-", "debug")
		self.menu.debug:addParam("dash", "Hide Dash Prints", SCRIPT_PARAM_ONOFF, false)


	_G.UPL:AddSpell(_Q, { speed = 1400, delay = 0.2, range = 910, width = 120, collision = true, aoe = false, type = "linear" })
	_G.UPL:AddSpell(_W, { speed = 1000, delay = 0.5, range = 900, width = 125, collision = false, aoe = true, type = "circular" })
	_G.UPL:AddSpell(_E, { speed = 800, delay = math.huge, range = 570, width = 330, collision = false, aoe = true, type = "cone" })

	self.ts = TargetSelector(TARGET_LESS_CAST, 910, DAMAGE_MAGIC, true)
	self.autoKillTs = TargetSelector(TARGET_LOW_HP, 910, DAMAGE_MAGIC, true)
	self.jungleMinions = minionManager(MINION_JUNGLE, 910, myHero, MINION_SORT_MAXHEALTH_DEC)
	self.enemyMinions = minionManager(MINION_ENEMY, 910, myHero, MINION_SORT_HEALTH_ASC)

	self.spellManager = SpellMaster()

	AddDrawCallback(function() self:OnDraw() end)
	AddTickCallback(function() self:OnTick() end)
	AddNewPathCallback(function(unit, startPos, endPos, isDash ,dashSpeed,dashGravity, dashDistance) self:OnNewPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance) end)
	AddProcessSpellCallback(function(object, spell) self:OnProcessSpell(object, spell) end)
end

function ChampionTaliyah:OnTick()
	--print()
	onWorkedGround = false
	for i, worked in pairs(usedGround) do
		if worked.expire <= os.clock() then
			table.remove(usedGround, i)
		else
			if worked and worked.obje and worked.obje.pos and myHero:GetDistance(worked.obje) <= 425 then
				onWorkedGround = true
			end
		end
	end
	if not myHero or myHero.health < 1 or myHero.dead then
		return
	end

	self.ts:update()


	--check for flee mode, use E behind us to slow enemys use W if they are not up our ass
	if self.menu.keys.flee then
		self:FleeMode()
		return
	end

	--check mode, combo, lane clear, harass, last hit
	if UOL:GetOrbWalkMode() == "Combo" then
		self:ComboMode()
	elseif UOL:GetOrbWalkMode() == "Harass" then
		self:HarassMode()
	elseif UOL:GetOrbWalkMode() == "LaneClear" then
		self:LaneClearMode()
	elseif UOL:GetOrbWalkMode() == "LastHit" then
		self:LastHitMode()
	end
end

function ChampionTaliyah:OnDraw()
	if self.menu.draw.target and self.ts.target ~= nil then
		DrawCircle3D(self.ts.target.x, self.ts.target.y, self.ts.target.z, 175, 4, ARGB(80, 32,178,100), 52)
	end

	if self.menu.draw.worked and onWorkedGround then
		sPos = WorldToScreen(D3DXVECTOR3(myHero.x,myHero.y,myHero.z))
		DrawText("On Worked Ground", 20, sPos.x - 75, sPos.y + 25, ARGB(150,255,255,255))
	end

	if self.menu.draw.damage then
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
						['AniviaEgg'] = -0.1,
						["Annie"] = -0.25
					}
					barOffset.x = t[v.charName] or 0
				end
				local baseX = barPos.x - 69 + barOffset.x * 150
				local baseY = barPos.y + barOffset.y * 50 + 12.5

				if v.charName == "Jhin" then 
					baseY = baseY - 12
				end
				
				local myDamage = 0
				local comboNeeded = nil
				if (self.menu.combo.W and self.spellManager:CanCast("W")) and (self.menu.combo.Q and self.spellManager:CanCast("Q")) and (self.menu.combo.E and self.spellManager:CanCast("E")) then
					myDamage = self:Damage("Q") + self:Damage("W") + self:Damage("E")
					comboNeeded = "Full"
				end
				if (self.menu.combo.W and self.spellManager:CanCast("W")) and (self.menu.combo.Q and self.spellManager:CanCast("Q")) then
					myDamage = self:Damage("Q") + self:Damage("W")
					comboNeeded = "Q-W"
				end
				if (self.menu.combo.E and self.spellManager:CanCast("E")) and (self.menu.combo.Q and self.spellManager:CanCast("Q")) then
					myDamage = self:Damage("Q") + self:Damage("E")
					comboNeeded = "Q-E"
				end
				if (self.menu.combo.E and self.spellManager:CanCast("E")) and (self.menu.combo.W and self.spellManager:CanCast("W")) then
					myDamage = self:Damage("W") + self:Damage("E")
					comboNeeded = "W-E"
				end
				if (self.menu.combo.E and self.spellManager:CanCast("E")) then
					myDamage = self:Damage("E")
					comboNeeded = "E"
				end
				if (self.menu.combo.W and self.spellManager:CanCast("W")) then
					myDamage = self:Damage("W")
					comboNeeded = "W"
				end
				if (self.menu.combo.Q and self.spellManager:CanCast("Q")) then
					myDamage = self:Damage("Q")
					comboNeeded = "Q"
				end

				local dmgperc = myDamage/v.health*100
				local enemyhpperc = v.health/v.maxHealth
				
				if dmgperc < 100 then
					DrawLine(baseX, baseY-10, baseX+(1.05*dmgperc)*enemyhpperc, baseY-10, 15, ARGB(180,2.55*dmgperc,0,-255+2.55*dmgperc))
				else
					if comboNeeded then
						DrawLine(baseX, baseY-10, baseX+105*enemyhpperc, baseY-10, 15, ARGB(180,255,0,0))
						DrawText("Killable - " .. comboNeeded, 18, baseX + 45, baseY-60, ARGB(180,2.55*dmgperc,0,-255+2.55*dmgperc))
					end
				end
				
			end
		end
	end
end

function ChampionTaliyah:OnProcessSpell(object, spell)
	if object == myHero and spell.name == "TaliyahW" and self.wTarget then
		local targetsInRange = 0
		local chosenTarget = nil
		for _, e in ipairs(GetEnemyHeroes()) do
			if e and not e.dead and e.health > 0 and GetDistance(e.pos, self.wTarget.pos) <= 125 then
				targetsInRange = targetsInRange + 1
				if chosenTarget == nil then
					chosenTarget = e
				elseif (GetDistance(e.pos, self.wTarget.pos) > GetDistance(chosenTarget.pos, self.wTarget.pos)) or (chosenTarget.health > e.health) then
					chosenTarget = e
				end
			end
		end
		if chosenTarget == nil and self.wTarget then
			DelayAction(function() self.spellManager:CastSpellPosition(self.wTarget.pos, _W) end, 2)
			self.wTarget = nil
		else
			if (chosenTarget.health > 0) and not chosenTarget.dead then
				if (CountAllyInRange(800, myHero) > CountEnemyInRange(800, chosenTarget)) then
					DelayAction(function() 
						nEndPos = DoYouEvenExtend(myHero, chosenTarget, 60)
						if nEndPos then
							self.spellManager:CastSpellPosition(nEndPos, _W)
							self.wTarget = nil
						end
					end, 1.25)
				elseif chosenTarget.health >= myHero.health and self.menu.combo.Waway then
					DelayAction(function() 
						nEndPos = DoYouEvenExtend(chosenTarget, myHero, 60)
						if nEndPos then
							self.spellManager:CastSpellPosition(nEndPos, _W)
							self.wTarget = nil
						end
					end, 1.25)
					PrintPretty("Casting [W2] on " .. chosenTarget.charName .. " to [Push].", true, true)
				elseif chosenTarget.health < myHero.health and self.menu.combo.Wtoward then
					DelayAction(function() 
						nEndPos = DoYouEvenExtend(myHero, chosenTarget, 60)
						if nEndPos then
							self.spellManager:CastSpellPosition(nEndPos, _W)
							self.wTarget = nil
						end
					end, 1.25)
					PrintPretty("Casting [W2] on " .. chosenTarget.charName .. " to [Pull].", true, true)
				end
			end
		end
	end
end

function ChampionTaliyah:OnNewPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance)
	if unit == nil or endPos == nil or not self.spellManager:CanCast("E") or not isDash or unit.team == myHero.team or unit.type ~= myHero.type then
		return
	end

	if GetDistance(endPos, myHero.pos) < 570 then
		CastSpell(_E, endPos.x, endPos.z)
		PrintPretty("Casting [E] for dash from [" .. unit.charName .. "]", self.menu.debug.dash, true)
	end
end

function ChampionTaliyah:FleeMode()

end

function ChampionTaliyah:LaneClearMode()
	self.enemyMinions:update()
	if self.enemyMinions.target and self.enemyMinions.target.health > 0 and not self.enemyMinions.target.dead then
		if self.spellManager:CanCast("Q") and self.menu.laneclear.Q and self.enemyMinions.target.health <= self:Damage("Q") and onWorkedGround then
			castPosQ, hitChanceQ, heroPosQ = UPL:Predict(_Q, myHero, self.enemyMinions.target)
			if castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance then
				self.spellManager:CastSpellPosition(castPosQ, _Q)
			end
		end
	end

	if self.spellManager:CanCast("W") and self.menu.laneclear.E then
		bestPos, bestHit = GetFarmPosition(550, 250, self.enemyMinions.objects)
		if bestPos and bestHit >= 3 and GetDistance(bestPos, myHero.pos) <=  550 then
			self.spellManager:CastSpellPosition(bestPos, _E)
		end
	end
end

function ChampionTaliyah:ComboMode()
	if self.ts.target == nil or self.ts.target:GetDistance(myHero) >= 910 or self.ts.target.dead or self.ts.target.health < 1 or not ValidTarget(self.ts.target, 910) then
		return
	end

	if myHero:GetDistance(self.ts.target) <= 530 then
		local totalDamage = 0
		local comboText = ""

		if self.spellManager:CanCast(_Q) then
			totalDamage = totalDamage + self:Damage("Q")
			comboText = "Q"
		end
		if self.spellManager:CanCast(_W) then
			totalDamage = totalDamage + self:Damage("W")
			comboText = comboText .. "W"
		end
		if self.spellManager:CanCast(_E) then
			totalDamage = totalDamage + self:Damage("E")
			comboText = comboText .. "E"
		end

		if self.ts.target.health + (self.ts.target.health * .1) < totalDamage then
			if comboText == "QW" and self.spellManager:CanCast(_Q) and self.spellManager:CanCast(_W) then
				castPosQ, hitChanceQ, heroPosQ = UPL:Predict(_Q, myHero, self.ts.target)
				castPosW, hitChanceW, heroPosW = UPL:Predict(_W, myHero, self.ts.target)
				if (castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance) and (castPosW and hitChanceW >= _G.ZeroConfig.menu["Prediction"..myHero.charName].WHitChance) then
					self.spellManager:CastSpellPosition(castPosQ, _Q)
					self.spellManager:CastSpellPosition(castPosW, _W)
					self.wTarget = self.ts.target
				end
			elseif comboText == "QE" and self.spellManager:CanCast(_Q) and self.spellManager:CanCast(_E) then
				castPosQ, hitChanceQ, heroPosQ = UPL:Predict(_Q, myHero, self.ts.target)
				castPosE, hitChanceE, heroPosE = UPL:Predict(_E, myHero, self.ts.target)
				if (castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance) and (castPosE and hitChanceE >= _G.ZeroConfig.menu["Prediction"..myHero.charName].EHitChance) then
					self.spellManager:CastSpellPosition(castPosQ, _Q)
					self.spellManager:CastSpellPosition(castPosW, _E)
				end
			elseif comboText == "WE" and self.spellManager:CanCast(_W) and self.spellManager:CanCast(_E) then
				castPosQ, hitChanceQ, heroPosQ = UPL:Predict(_Q, myHero, self.ts.target)
				castPosW, hitChanceW, heroPosW = UPL:Predict(_W, myHero, self.ts.target)
				if (castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance) and (castPosE and hitChanceE >= _G.ZeroConfig.menu["Prediction"..myHero.charName].EHitChance) then
					self.spellManager:CastSpellPosition(castPosW, _E)
					self.spellManager:CastSpellPosition(castPosW, _W)
					self.wTarget = self.ts.target
				end
			elseif comboText == "QWE" and self.spellManager:CanCast(_Q) and self.spellManager:CanCast(_W) and self.spellManager:CanCast(_E) then
				castPosQ, hitChanceQ, heroPosQ = UPL:Predict(_Q, myHero, self.ts.target)
				castPosW, hitChanceW, heroPosW = UPL:Predict(_W, myHero, self.ts.target)
				castPosE, hitChanceE, heroPosE = UPL:Predict(_E, myHero, self.ts.target)
				if (castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance) and (castPosW and hitChanceW >= _G.ZeroConfig.menu["Prediction"..myHero.charName].WHitChance) and (castPosE and hitChanceE >= _G.ZeroConfig.menu["Prediction"..myHero.charName].EHitChance) then
					self.spellManager:CastSpellPosition(castPosQ, _Q)
					self.spellManager:CastSpellPosition(castPosE, _E)
					self.spellManager:CastSpellPosition(castPosW, _W)
					self.wTarget = self.ts.target
				end
			end
		end
	end

	if self.menu.combo.E and self.spellManager:CanCast("E") and GetDistance(myHero, self.ts.target) <= 570 then
		castPosE, hitChanceE, heroPosE = UPL:Predict(_E, myHero, self.ts.target)
		if castPosE and hitChanceE >= _G.ZeroConfig.menu["Prediction"..myHero.charName].EHitChance then
			self.spellManager:CastSpellPosition(castPosE, _E)
			if self.menu.combo.W and self.spellManager:CanCast("W") and self.menu.combo.Wmine then
				castPosW, hitChanceW, heroPosW = UPL:Predict(_W, myHero, self.ts.target)
				if castPosW and hitChanceW >= _G.ZeroConfig.menu["Prediction"..myHero.charName].WHitChance then
					self.spellManager:CastSpellPosition(castPosW, _W)
					self.wTarget = self.ts.target
				end
			end
		end
	end

	if self.menu.combo.Q and GetDistance(myHero, self.ts.target) <= 910 then
		if self.menu.combo.Qnew and not onWorkedGround then
			castPosQ, hitChanceQ, heroPosQ = UPL:Predict(_Q, myHero, self.ts.target)
			if castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance then
				self.spellManager:CastSpellPosition(castPosQ, _Q)
			end
		elseif self.menu.combo.Qused and onWorkedGround then
			castPosQ, hitChanceQ, heroPosQ = UPL:Predict(_Q, myHero, self.ts.target)
			if castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance then
				self.spellManager:CastSpellPosition(castPosQ, _Q)
			end
		end
	end

	if self.menu.combo.W and self.spellManager:CanCast("W") then
		castPosW, hitChanceW, heroPosW = UPL:Predict(_W, myHero, self.ts.target)
		if castPosW and hitChanceW >= _G.ZeroConfig.menu["Prediction"..myHero.charName].WHitChance then
			self.spellManager:CastSpellPosition(castPosW, _W)
			self.wTarget = self.ts.target
		end
	end

	--check for valid target in range
		--check if we can kill
		--check if they are close enough to be W'd into a E and check pred on W if we can cast E then W
		--check if they are slowed/stunned/rooted and can be hit by a full cast Q if so cast Q
		--check if we are on worked ground and target can be hit by a single Q
		--check if we need to peel the target off of ourselves or a ally (hp based and number of enemy/ally around) use W to peel
		--check if we can pull/push them into a bad situation using our W
		--check if they are close enough to be hit by our E and E if they are
	--else
		--loop through all enemys within max range (910) and check if valid, alive, etc
			--check if we can kill
			--check if they are close enough to be W'd into a E and check pred on W if we can cast E then W
			--check if they are slowed/stunned/rooted and can be hit by a full cast Q if so cast Q
			--check if we are on worked ground and target can be hit by a single Q
			--check if we need to peel the target off of ourselves or a ally (hp based and number of enemy/ally around) use W to peel
			--check if we can pull/push them into a bad situation using our W
			--check if they are close enough to be hit by our E and E if they are
end

function ChampionTaliyah:HarassMode()
	if self.ts.target == nil or self.ts.target:GetDistance(myHero) >= 910 or self.ts.target.dead or self.ts.target.health < 1 or not ValidTarget(self.ts.target, 910) then
		--loop through team checks
		return
	end

	if self.menu.harass.E and self.spellManager:CanCast("E") and GetDistance(myHero, self.ts.target) <= 570 then
		--use E
		--check if we can w into it
		castPosE, hitChanceE, heroPosE = UPL:Predict(_E, myHero, self.ts.target)
		if castPosE and hitChanceE >= _G.ZeroConfig.menu["Prediction"..myHero.charName].EHitChance then
			self.spellManager:CastSpellPosition(castPosE, _E)
			if self.menu.harass.W and self.spellManager:CanCast("W") and self.menu.harass.Wmine then
				castPosW, hitChanceW, heroPosW = UPL:Predict(_W, myHero, self.ts.target)
				if castPosW and hitChanceW >= _G.ZeroConfig.menu["Prediction"..myHero.charName].WHitChance then
					self.spellManager:CastSpellPosition(castPosW, _W)
					self.wTarget = self.ts.target
				end
			end
		end
	end

	if self.menu.harass.Q and GetDistance(myHero, self.ts.target) <= 910 then
		if self.menu.harass.Qnew and not onWorkedGround then
			castPosQ, hitChanceQ, heroPosQ = UPL:Predict(_Q, myHero, self.ts.target)
			if castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance then
				self.spellManager:CastSpellPosition(castPosQ, _Q)
			end
		elseif self.menu.harass.Qused and onWorkedGround then
			castPosQ, hitChanceQ, heroPosQ = UPL:Predict(_Q, myHero, self.ts.target)
			if castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance then
				self.spellManager:CastSpellPosition(castPosQ, _Q)
			end
		end
	end

	if self.menu.harass.W and self.spellManager:CanCast("W") then
		castPosW, hitChanceW, heroPosW = UPL:Predict(_W, myHero, self.ts.target)
		if castPosW and hitChanceW >= _G.ZeroConfig.menu["Prediction"..myHero.charName].WHitChance then
			self.spellManager:CastSpellPosition(castPosW, _W)
			self.wTarget = self.ts.target
		end
	end
end

function ChampionTaliyah:LastHitMode()
	if self.ts.target == nil or self.ts.target:GetDistance(myHero) >= 910 or self.ts.target.dead or self.ts.target.health < 1 or not ValidTarget(self.ts.target, 910) then
		--loop through team checks
		return
	end

	if self.menu.lasthit.E and self.spellManager:CanCast("E") and GetDistance(myHero, self.ts.target) <= 570 then
		--use E
		--check if we can w into it
		castPosE, hitChanceE, heroPosE = UPL:Predict(_E, myHero, self.ts.target)
		if castPosE and hitChanceE >= _G.ZeroConfig.menu["Prediction"..myHero.charName].EHitChance then
			self.spellManager:CastSpellPosition(castPosE, _E)
			if self.menu.lasthit.W and self.spellManager:CanCast("W") and self.menu.lasthit.Wmine then
				castPosW, hitChanceW, heroPosW = UPL:Predict(_W, myHero, self.ts.target)
				if castPosW and hitChanceW >= _G.ZeroConfig.menu["Prediction"..myHero.charName].WHitChance then
					self.spellManager:CastSpellPosition(castPosW, _W)
					self.wTarget = self.ts.target
				end
			end
		end
	end

	if self.menu.harass.Q and GetDistance(myHero, self.ts.target) <= 910 then
		if self.menu.lasthit.Qnew and not onWorkedGround then
			castPosQ, hitChanceQ, heroPosQ = UPL:Predict(_Q, myHero, self.ts.target)
			if castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance then
				self.spellManager:CastSpellPosition(castPosQ, _Q)
			end
		elseif self.menu.lasthit.Qused and onWorkedGround then
			castPosQ, hitChanceQ, heroPosQ = UPL:Predict(_Q, myHero, self.ts.target)
			if castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance then
				self.spellManager:CastSpellPosition(castPosQ, _Q)
			end
		end
	end

	if self.menu.lasthit.W and self.spellManager:CanCast("W") then
		castPosW, hitChanceW, heroPosW = UPL:Predict(_W, myHero, self.ts.target)
		if castPosW and hitChanceW >= _G.ZeroConfig.menu["Prediction"..myHero.charName].WHitChance then
			self.spellManager:CastSpellPosition(castPosW, _W)
			self.wTarget = self.ts.target
		end
	end
end

function ChampionTaliyah:Damage(spellText)
	if spellText == "Q" then
		spellLevel = GetSpellData(_Q).level
		levelDamage = {60,80,100,120,140}
		myApScale = myHero.ap * 0.4
		if not onWorkedGround then
			levelDamage = {180,240,300,360,420}
			myApScale = myHero.ap * 1.2
		end
		damage = levelDamage[spellLevel] + myApScale
		return damage
	elseif spellText == "W" then
		spellLevel = GetSpellData(_W).level
		levelDamage = {60,80,100,120,140}
		myApScale = myHero.ap * 0.4
		damage = levelDamage[spellLevel] + myApScale
		return damage
	elseif spellText == "E" then
		spellLevel = GetSpellData(_E).level
		levelDamage = {40,52.5,65,77.5,90}
		myApScale = myHero.ap * 0.2
		damage = levelDamage[spellLevel] + myApScale
		return damage
	end
end

function OnCreateObj(obj)
	if obj and myHero.charName == "Taliyah" then
		if obj.name:find("Taliyah_Base_Q") and not WorkedGroundIsKnown(obj) then
			tmpT = {
				obje = obj,
				expire = os.clock() + 180
			}
			table.insert(usedGround, tmpT)
		end
	end
end

function WorkedGroundIsKnown(obj)
	if myHero.charName == "Taliyah" then
		for i, worked in pairs(usedGround) do
			if worked and worked.obje then
				if worked.obje == obj then
					return true
				end
			else
				table.remove(usedGround, i)
			end
		end
		return false
	end
end

class("ChampionAhri")
function ChampionAhri:__init()
	self.ver = 1001

	self.menu = scriptConfig("Zer0 Bundle - Ahri", "003dataAhri")
	self.menu:addSubMenu("-> Extra Keys <-", "keys")
		self.menu.keys:addParam("flee", "Flee Mode *SOON*", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte( 'T' ))

	self.menu:addSubMenu("-> Combo Logic <-", "combo")
		self.menu.combo:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		self.menu.combo:addParam("Qmana", "% Mana for Q", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
		self.menu.combo:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
		self.menu.combo:addParam("Wmana", "% Mana for W", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
		self.menu.combo:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
		self.menu.combo:addParam("Emana", "% Mana for E", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
		self.menu.combo:addParam("R", "Use R", SCRIPT_PARAM_ONOFF, true)
		self.menu.combo:addParam("Rmana", "% Mana for R", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)

	self.menu:addSubMenu("-> Harass Logic <-", "harass")
		self.menu.harass:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		self.menu.harass:addParam("Qmana", "% Mana for Q", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
		self.menu.harass:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
		self.menu.harass:addParam("Wmana", "% Mana for W", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
		self.menu.harass:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
		self.menu.harass:addParam("Emana", "% Mana for E", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)

	self.menu:addSubMenu("-> Harass 2 Logic <-", "lasthit")
		self.menu.lasthit:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, false)
		self.menu.lasthit:addParam("Qmana", "% Mana for Q", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
		self.menu.lasthit:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, false)
		self.menu.lasthit:addParam("Wmana", "% Mana for W", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
		self.menu.lasthit:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, false)
		self.menu.lasthit:addParam("Emana", "% Mana for E", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)

	self.menu:addSubMenu("-> Lane Clear Logic <-", "laneclear")
		self.menu.laneclear:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		self.menu.laneclear:addParam("Qmana", "% Mana for Q", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
		self.menu.laneclear:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
		self.menu.laneclear:addParam("Wmana", "% Mana for W", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)

	self.menu:addSubMenu("-> Kill Secure <-", "ks")
		self.menu.ks:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		self.menu.ks:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
		self.menu.ks:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
		self.menu.ks:addParam("R", "Use R", SCRIPT_PARAM_ONOFF, true)

	self.menu:addSubMenu("-> Auto R <-", "r")
		self.menu.r:addParam("R", "Use R To Evade", SCRIPT_PARAM_ONOFF, true)

	self.menu:addSubMenu("-> Auto Level Settings <-", "autoLevel")
		self.menu.autoLevel:addParam("on", "Enabled *Requires Reload*", SCRIPT_PARAM_ONOFF, false)
		self.menu.autoLevel:addParam("priority", "Level Priority", SCRIPT_PARAM_LIST, 1, {"AP Q Build", "AP E Build"})

	if self.menu.autoLevel.on then
		local seq = {}
		if self.menu.autoLevel.priority == "AP Q Build" then
			seq = {_W, _Q, _W, _E, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E}
		elseif self.menu.autoLevel.priority == "AP E Build" then
			seq = {_Q, _W, _Q, _E, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}
		end
		AutoLeveler(seq)
	end

	self.menu:addSubMenu("-> Dash Logic <-", "dash")
		for _,v in pairs(GetEnemyHeroes()) do
			if v then
				self.menu.dash:addParam(v.charName, v.charName, SCRIPT_PARAM_ONOFF, true)
			end
		end

	self.menu:addSubMenu("-> Draw <-", "draw")
		self.menu.draw:addParam("target", "Draw Target", SCRIPT_PARAM_ONOFF, true)
		self.menu.draw:addParam("damage", "Predicted Damage", SCRIPT_PARAM_ONOFF, true)
		self.menu.draw:addParam("q", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
		self.menu.draw:addParam("w", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
		self.menu.draw:addParam("e", "Draw E Range", SCRIPT_PARAM_ONOFF, true)

	self.menu:addSubMenu("-> Debug <-", "debug")
		self.menu.debug:addParam("dash", "Hide Dash Prints", SCRIPT_PARAM_ONOFF, false)


	_G.UPL:AddSpell(_Q, { speed = 1600, delay = 0.25, range = 880, width = 85, collision = false, aoe = true, type = "linear" })
	_G.UPL:AddSpell(_E, { speed = 1600, delay = 0.3, range = 975, width = 60, collision = true, aoe = false, type = "linear" })

	self.ts = TargetSelector(TARGET_LESS_CAST, 880, DAMAGE_MAGIC, true)
	self.autoKillTs = TargetSelector(TARGET_LOW_HP, 880, DAMAGE_MAGIC, true)
	self.jungleMinions = minionManager(MINION_JUNGLE, 880, myHero, MINION_SORT_MAXHEALTH_DEC)
	self.enemyMinions = minionManager(MINION_ENEMY, 880, myHero, MINION_SORT_HEALTH_ASC)

	self.spellManager = SpellMaster()

	AddDrawCallback(function() self:OnDraw() end)
	AddTickCallback(function() self:OnTick() end)
	AddNewPathCallback(function(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance) self:OnNewPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance) end)
end

function ChampionAhri:OnNewPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance)
	if unit == nil or endPos == nil or not self.spellManager:CanCast("E") or not isDash or unit.team == myHero.team or unit.type ~= myHero.type then
		return
	end

	if GetDistance(endPos, myHero.pos) < 880 then
		self.spellManager:CastSpellPosition(endPos, _E)
		PrintPretty("Casting [E] for dash from [" .. unit.charName .. "]", self.menu.debug.dash, true)
	end
end

function ChampionAhri:OnTick()
	self.ts:update()
	self.autoKillTs:update()
	self.jungleMinions:update()
	self.enemyMinions:update()

	self:KillSteal()

	if UOL:GetOrbWalkMode() == "Combo" then
		self:ComboMode()
	elseif UOL:GetOrbWalkMode() == "Harass" then
		self:HarassMode()
	elseif UOL:GetOrbWalkMode() == "LaneClear" then
		self:LaneClearMode()
	elseif UOL:GetOrbWalkMode() == "LastHit" then
		self:LastHitMode()
	end
end

function ChampionAhri:ComboMode()
	if not self.ts.target or self.ts.target == nil or GetDistance(myHero.pos, self.ts.target.pos) >= 975 or self.ts.target.dead or self.ts.target.health < 1 or not ValidTarget(self.ts.target, 975) then
		return
	end

	if self.spellManager:CanCast("E") and self.menu.combo.E and ((myHero.mana*100)/myHero.maxMana) > self.menu.combo.Emana then
		castPosE, hitChanceE, heroPositionE = UPL:Predict(_E, myHero, self.ts.target)
		if castPosE and hitChanceE >= _G.ZeroConfig.menu["Prediction"..myHero.charName].EHitChance and GetDistance(myHero.pos, castPosE) <= 975 then
			self.spellManager:CastSpellPosition(castPosE, _E)
		end
	end

	if self.spellManager:CanCast("Q") and self.menu.combo.Q and ((myHero.mana*100)/myHero.maxMana) > self.menu.combo.Qmana then
		castPosQ, hitChanceQ, heroPositionQ = UPL:Predict(_Q, myHero, self.ts.target)
		if castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance and GetDistance(myHero.pos, castPosQ) <= 880 then
			self.spellManager:CastSpellPosition(castPosQ, _Q)
		end
	end

	if self.spellManager:CanCast("W") and self.menu.combo.W and ((myHero.mana*100)/myHero.maxMana) > self.menu.combo.Wmana and GetDistance(myHero, self.ts.target) <= 550 then
		self.spellManager:CastSpell(_W)
	end
end

function ChampionAhri:HarassMode()
	if not self.ts.target or self.ts.target == nil or GetDistance(myHero.pos, self.ts.target.pos) >= 975 or self.ts.target.dead or self.ts.target.health < 1 or not ValidTarget(self.ts.target, 975) then
		return
	end

	if self.spellManager:CanCast("E") and self.menu.harass.E and ((myHero.mana*100)/myHero.maxMana) > self.menu.harass.Emana then
		castPosE, hitChanceE, heroPositionE = UPL:Predict(_E, myHero, self.ts.target)
		if castPosE and hitChanceE >= _G.ZeroConfig.menu["Prediction"..myHero.charName].EHitChance and GetDistance(myHero.pos, castPosE) <= 975 then
			self.spellManager:CastSpellPosition(castPosE, _E)
		end
	end

	if self.spellManager:CanCast("Q") and self.menu.harass.Q and ((myHero.mana*100)/myHero.maxMana) > self.menu.harass.Qmana then
		castPosQ, hitChanceQ, heroPositionQ = UPL:Predict(_Q, myHero, self.ts.target)
		if castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance and GetDistance(myHero.pos, castPosQ) <= 880 then
			self.spellManager:CastSpellPosition(castPosQ, _Q)
		end
	end
end

function ChampionAhri:LastHitMode()
	if not self.ts.target or self.ts.target == nil or GetDistance(myHero.pos, self.ts.target.pos) >= 1250 or self.ts.target.dead or self.ts.target.health < 1 or not ValidTarget(self.ts.target, 1200) then
		return
	end

	if self.spellManager:CanCast("E") and self.menu.lasthit.E and ((myHero.mana*100)/myHero.maxMana) > self.menu.lasthit.Emana then
		castPosE, hitChanceE, heroPositionE = UPL:Predict(_E, myHero, self.ts.target)
		if castPosE and hitChanceE >= _G.ZeroConfig.menu["Prediction"..myHero.charName].EHitChance and GetDistance(myHero.pos, castPosE) <= 1200 then
			self.spellManager:CastSpellPosition(castPosE, _E)
		end
	end

	if self.spellManager:CanCast("Q") and self.menu.lasthit.Q and ((myHero.mana*100)/myHero.maxMana) > self.menu.lasthit.Qmana then
		castPosQ, hitChanceQ, heroPositionQ = UPL:Predict(_Q, myHero, self.ts.target)
		if castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance and GetDistance(myHero.pos, castPosQ) <= 1200 then
			self.spellManager:CastSpellPosition(castPosQ, _Q)
		end
	end
end

function ChampionAhri:LaneClearMode()
	if not self.enemyMinions.target or self.enemyMinions.target == nil or GetDistance(myHero.pos, self.enemyMinions.target.pos) >= 1250 or self.enemyMinions.target.dead or self.enemyMinions.target.health < 1 or not ValidTarget(self.enemyMinions.target, 1200) then
		return
	end

	if self.spellManager:CanCast("W") and self.menu.laneclear.W and ((myHero.mana*100)/myHero.maxMana) > self.menu.laneclear.Wmana and GetDistance(myHero, self.enemyMinions.target) <= 525 then
		self.spellManager:CastSpell(_W)
	end

	if self.spellManager:CanCast("Q") and self.menu.laneclear.Q and ((myHero.mana*100)/myHero.maxMana) > self.menu.laneclear.Qmana then
		castPosQ, hitChanceQ, heroPositionQ = UPL:Predict(_Q, myHero, self.enemyMinions.target)
		if castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance and GetDistance(myHero.pos, castPosQ) <= 880 then
			self.spellManager:CastSpellPosition(castPosQ, _Q)
		end
	end
end

function ChampionAhri:Damage(spell)
	if spell == "Q" then
		spellLevel = GetSpellData(_Q).level
		if spellLevel == 0 then return 0 end
		levelDamage = {40,65,90,115,140}
		myApScale = myHero.ap * .35
		damage = myApScale + levelDamage[spellLevel]
		return damage
	elseif spell == "W" then
		spellLevel = GetSpellData(_W).level
		if spellLevel == 0 then return 0 end
		levelDamage = {40,65,90,115,140}
		myApScale = myHero.ap * .4
		damage = levelDamage[spellLevel] + myApScale
		return damage
	elseif spell == "E" then
		spellLevel = GetSpellData(_E).level
		if spellLevel == 0 then return 0 end
		levelDamage = {60,95,130,165,200}
		myApScale = myHero.ap * .5
		damage = levelDamage[spellLevel] + myApScale
		return damage
	elseif spell == "R" then
		spellLevel = GetSpellData(_R).level
		if spellLevel == 0 then return 0 end
		levelDamage = {70,110,150}
		myApScale = myHero.ap * .3
		damage = levelDamage[spellLevel] + myApScale
		return damage
	end
end

function ChampionAhri:KillSteal()
	if self.autoKillTs.target == nil or self.autoKillTs.target:GetDistance(myHero) >= 875 or self.autoKillTs.target.dead or self.autoKillTs.target.health < 1 or not ValidTarget(self.autoKillTs.target, 875) then
		return
	end

	local damage = {
		q = self:Damage("Q"),
		w = self:Damage("W"),
		e = self:Damage("E"),
		qw = self:Damage("Q") + self:Damage("W"),
		qe = self:Damage("Q") + self:Damage("E"),
		we = self:Damage("W") + self:Damage("E"),
		qwe = self:Damage("W") + self:Damage("Q") + self:Damage("E")
	}

	if damage.w > self.autoKillTs.target.health + (self.autoKillTs.target.health * .1) and self.spellManager:CanCast(_W) and GetDistance(myHero, self.autoKillTs.target) <= 525 then
		self.spellManager:CastSpell(_W)
	elseif damage.q > self.autoKillTs.target.health + (self.autoKillTs.target.health * .1) and self.spellManager:CanCast(_Q) then
		castPosQ, hitChanceQ, heroPositionQ = UPL:Predict(_Q, myHero, self.autoKillTs.target)
		if castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance and myHero:GetDistance(castPosQ) <= 875 then
			self.spellManager:CastSpellPosition(castPosQ, _Q)
		end
	elseif damage.e > self.autoKillTs.target.health + (self.autoKillTs.target.health * .1) and self.spellManager:CanCast(_E) then
		castPosE, hitChanceE, heroPositionE = UPL:Predict(_E, myHero, self.autoKillTs.target)
		if castPosE and hitChanceE >= _G.ZeroConfig.menu["Prediction"..myHero.charName].EHitChance and myHero:GetDistance(castPosE) <= 975 then
			self.spellManager:CastSpellPosition(castPosE, _E)
		end
	elseif damage.qw > self.autoKillTs.target.health + (self.autoKillTs.target.health * .1) and self.spellManager:CanCast(_Q) and self.spellManager:CanCast(_W) and GetDistance(myHero, self.autoKillTs.target) <= 525 then
		castPosQ, hitChanceQ, heroPositionQ = UPL:Predict(_Q, myHero, self.autoKillTs.target)
		if (castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance and myHero:GetDistance(castPosQ) <= 875) then
			self.spellManager:CastSpell(_W)
			self.spellManager:CastSpellPosition(castPosQ, _Q)
		end
	elseif damage.we > self.autoKillTs.target.health + (self.autoKillTs.target.health * .1) and self.spellManager:CanCast(_E) and self.spellManager:CanCast(_W) and GetDistance(myHero, self.autoKillTs.target) <= 525 then
		castPosE, hitChanceE, heroPositionE = UPL:Predict(_E, myHero, self.autoKillTs.target)
		if (castPosE and hitChanceE >= _G.ZeroConfig.menu["Prediction"..myHero.charName].EHitChance and myHero:GetDistance(castPosE) <= 875) then
			self.spellManager:CastSpell(_W)
			self.spellManager:CastSpellPosition(castPosE, _E)
		end
	elseif damage.qwe > self.autoKillTs.target.health + (self.autoKillTs.target.health * .1) and self.spellManager:CanCast(_E) and self.spellManager:CanCast(_W) and self.spellManager:CanCast(_Q) and GetDistance(myHero, self.autoKillTs.target) <= 525 then
		castPosE, hitChanceE, heroPositionE = UPL:Predict(_E, myHero, self.autoKillTs.target)
		castPosQ, hitChanceQ, heroPositionQ = UPL:Predict(_Q, myHero, self.autoKillTs.target)
		if (castPosE and hitChanceE >= _G.ZeroConfig.menu["Prediction"..myHero.charName].EHitChance and myHero:GetDistance(castPosE) <= 875) and (castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance and myHero:GetDistance(castPosQ) <= 875) then
			self.spellManager:CastSpell(_W)
			self.spellManager:CastSpellPosition(castPosE, _E)
			self.spellManager:CastSpellPosition(castPosQ, _Q)
		end
	end
end

function ChampionAhri:OnDraw()
	if self.menu.draw.target and self.ts.target ~= nil and self.ts.target.health > 0 and not self.ts.target.dead then
		DrawCircle3D(self.ts.target.x, self.ts.target.y, self.ts.target.z, 175, 4, ColorCodes.Blue, 52)
	end

	if self.menu.draw.target and self.autoKillTs.target ~= nil and self.autoKillTs.target.health > 0 and not self.autoKillTs.target.dead then
		DrawCircle3D(self.autoKillTs.target.x, self.autoKillTs.target.y, self.autoKillTs.target.z, 175, 4, ColorCodes.Red, 52)
	end

	if self.menu.draw.w and self.spellManager:CanCast("W") then
		DrawCircle3D(myHero.pos.x, myHero.pos.y, myHero.pos.z, 1200, 4, ColorCodes.Gray, 52)
	end

	if self.menu.draw.damage then
		local damage = {
			q = self:Damage("Q"),
			w = self:Damage("W"),
			e = self:Damage("E"),
			qw = self:Damage("Q") + self:Damage("W"),
			qe = self:Damage("Q") + self:Damage("E"),
			we = self:Damage("W") + self:Damage("E"),
			qwe = self:Damage("W") + self:Damage("Q") + self:Damage("E")
		}
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
						['AniviaEgg'] = -0.1,
						["Annie"] = -0.25
					}
					barOffset.x = t[v.charName] or 0
				end
				local baseX = barPos.x - 69 + barOffset.x * 150
				local baseY = barPos.y + barOffset.y * 50 + 12.5

				if v.charName == "Jhin" then 
					baseY = baseY - 12
				end
				
				local myDamage = 0
				local comboNeeded = nil
				if (self.menu.combo.E and self.spellManager:CanCast("E") and self.menu.combo.Q and self.spellManager:CanCast("Q") and self.menu.combo.W and self.spellManager:CanCast("W")) then
					myDamage = damage.qwe
					comboNeeded = "Q-W-E"
				elseif (self.menu.combo.Q and self.spellManager:CanCast("Q") and self.menu.combo.W and self.spellManager:CanCast("W")) then
					myDamage = damage.qw
					comboNeeded = "Q-W"
				elseif (self.menu.combo.E and self.spellManager:CanCast("E") and self.menu.combo.W and self.spellManager:CanCast("W")) then
					myDamage = damage.we
					comboNeeded = "W-E"
				elseif (self.menu.combo.Q and self.spellManager:CanCast("Q") and self.menu.combo.E and self.spellManager:CanCast("E")) then
					myDamage = damage.qe
					comboNeeded = "Q-E"
				elseif (self.menu.combo.W and self.spellManager:CanCast("W")) then
					myDamage = damage.w
					comboNeeded = "W"
				elseif (self.menu.combo.E and self.spellManager:CanCast("E")) then
					myDamage = damage.e
					comboNeeded = "E"
				elseif (self.menu.combo.Q and self.spellManager:CanCast("Q")) then
					myDamage = damage.q
					comboNeeded = "Q"
				end

				local dmgperc = myDamage/v.health*100
				local enemyhpperc = v.health/v.maxHealth
				
				if dmgperc < 100 then
					DrawLine(baseX, baseY-10, baseX+(1.05*dmgperc)*enemyhpperc, baseY-10, 15, ARGB(180,2.55*dmgperc,0,-255+2.55*dmgperc))
				else
					DrawLine(baseX, baseY-10, baseX+105*enemyhpperc, baseY-10, 15, ARGB(180,255,0,0))
					DrawText("Killable - " .. comboNeeded, 18, baseX + 45, baseY-60, ARGB(180,2.55*dmgperc,0,-255+2.55*dmgperc))
				end
				
			end
		end
	end
end

class("ChampionSoraka")
function ChampionSoraka:__init()
	self.ver = 1001

	self.menu = scriptConfig("Zer0 Bundle - Soraka", "003dataSoraka")
	self.menu:addSubMenu("-> Extra Keys <-", "keys")
		self.menu.keys:addParam("flee", "Flee Mode *SOON*", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte( 'T' ))

	self.menu:addSubMenu("-> Combo Logic <-", "combo")
		self.menu.combo:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		self.menu.combo:addParam("Qmana", "% Mana for Q", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
		self.menu.combo:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
		self.menu.combo:addParam("Emana", "% Mana for E", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)

	self.menu:addSubMenu("-> Harass Logic <-", "harass")
		self.menu.harass:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		self.menu.harass:addParam("Qmana", "% Mana for Q", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
		self.menu.harass:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
		self.menu.harass:addParam("Emana", "% Mana for E", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)

	self.menu:addSubMenu("-> Harass 2 Logic <-", "lasthit")
		self.menu.lasthit:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, false)
		self.menu.lasthit:addParam("Qmana", "% Mana for Q", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
		self.menu.lasthit:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, false)
		self.menu.lasthit:addParam("Emana", "% Mana for E", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)

	self.menu:addSubMenu("-> Lane Clear Logic <-", "laneclear")
		self.menu.laneclear:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		self.menu.laneclear:addParam("Qmana", "% Mana for Q", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
		self.menu.laneclear:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
		self.menu.laneclear:addParam("Emana", "% Mana for E", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)

	self.menu:addSubMenu("-> Kill Secure <-", "ks")
		self.menu.ks:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, false)
		self.menu.ks:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, false)

	self.menu:addSubMenu("-> Auto W <-", "w")
		self.menu.w:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
		for _,v in pairs(GetAllyHeroes()) do
			if v then
				self.menu.w:addParam(v.charName, "Heal " .. v.charName, SCRIPT_PARAM_ONOFF, true)
				self.menu.w:addParam(v.charName.."perc", "Heal " .. v.charName .. " Below HP %", SCRIPT_PARAM_SLICE, 80, 0, 100, 0)
				self.menu.w:addParam(v.charName.."mana", "Heal " .. v.charName .. " Above Mana %", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
			end
		end

	self.menu:addSubMenu("-> Auto R <-", "r")
		self.menu.r:addParam("R", "Use R", SCRIPT_PARAM_ONOFF, true)
		for _,v in pairs(GetAllyHeroes()) do
			if v then
				self.menu.r:addParam(v.charName, "Heal " .. v.charName, SCRIPT_PARAM_ONOFF, true)
				self.menu.r:addParam(v.charName.."perc", "Heal " .. v.charName .. " Below HP %", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
				self.menu.r:addParam(v.charName.."mana", "Heal " .. v.charName .. " Above Mana %", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
			end
		end

	self.menu:addSubMenu("-> Auto Level Settings <-", "autoLevel")
		self.menu.autoLevel:addParam("on", "Enabled *Requires Reload*", SCRIPT_PARAM_ONOFF, false)
		self.menu.autoLevel:addParam("priority", "Level Priority", SCRIPT_PARAM_LIST, 1, {"AP W Build", "AP Q Build"})

	if self.menu.autoLevel.on then
		local seq = {}
		if self.menu.autoLevel.priority == "AP W Build" then
			seq = {_W, _Q, _W, _E, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E}
		elseif self.menu.autoLevel.priority == "AP Q Build" then
			seq = {_Q, _W, _Q, _E, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}
		end
		AutoLeveler(seq)
	end

	self.menu:addSubMenu("-> Dash Logic <-", "dash")
		for _,v in pairs(GetEnemyHeroes()) do
			if v then
				self.menu.dash:addParam(v.charName, v.charName, SCRIPT_PARAM_ONOFF, true)
			end
		end

	self.menu:addSubMenu("-> Draw <-", "draw")
		self.menu.draw:addParam("target", "Draw Target", SCRIPT_PARAM_ONOFF, true)
		self.menu.draw:addParam("damage", "Predicted Damage", SCRIPT_PARAM_ONOFF, true)
		self.menu.draw:addParam("q", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
		self.menu.draw:addParam("w", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
		self.menu.draw:addParam("e", "Draw E Range", SCRIPT_PARAM_ONOFF, true)

	self.menu:addSubMenu("-> Debug <-", "debug")
		self.menu.debug:addParam("dash", "Hide Dash Prints", SCRIPT_PARAM_ONOFF, false)


	_G.UPL:AddSpell(_Q, { speed = 1600, delay = 0.5, range = 770, width = 110, collision = false, aoe = true, type = "circular" })
	_G.UPL:AddSpell(_E, { speed = 2000, delay = 0.6, range = 880, width = 25, collision = false, aoe = true, type = "circular" })

	self.ts = TargetSelector(TARGET_LESS_CAST, 880, DAMAGE_MAGIC, true)
	self.autoKillTs = TargetSelector(TARGET_LOW_HP, 880, DAMAGE_MAGIC, true)
	self.jungleMinions = minionManager(MINION_JUNGLE, 880, myHero, MINION_SORT_MAXHEALTH_DEC)
	self.enemyMinions = minionManager(MINION_ENEMY, 880, myHero, MINION_SORT_HEALTH_ASC)

	self.spellManager = SpellMaster()

	--AddDrawCallback(function() self:OnDraw() end)
	AddTickCallback(function() self:OnTick() end)
	AddNewPathCallback(function(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance) self:OnNewPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance) end)
end

function ChampionSoraka:HealAmount(skill)
	if skill == "W" then
		spellLevel = GetSpellData(_W).level
		if spellLevel == 0 then return 0 end
		levelHealing = {80,110,140,170,220}
		myApScale = myHero.ap * .6
		healing = levelHealing[spellLevel] + myApScale
		return healing
	elseif skill == "R" then
		spellLevel = GetSpellData(_R).level
		if spellLevel == 0 then return 0 end
		levelHealing = {150,250,350}
		myApScale = myHero.ap * .55
		healing = levelHealing[spellLevel] + myApScale
		return healing
	end
end

function ChampionSoraka:OnNewPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance)
	if unit == nil or endPos == nil or not self.spellManager:CanCast("E") or not isDash or unit.team == myHero.team or unit.type ~= myHero.type then
		return
	end

	if GetDistance(endPos, myHero.pos) < 880 then
		self.spellManager:CastSpellPosition(endPos, _E)
		PrintPretty("Casting [E] for dash from [" .. unit.charName .. "]", self.menu.debug.dash, true)
	end
end

function ChampionSoraka:OnTick()
	self.ts:update()
	--self.autoKillTs:update()
	--self.jungleMinions:update()
	--self.enemyMinions:update()

	--self:KillSteal()

	if (self.menu.w.W and self.spellManager:CanCast("W")) or (self.menu.r.R and self.spellManager:CanCast("R")) then
		for _,h in ipairs(GetAllyHeroes()) do
			if h and h.health > 0 and not h.dead then
				if self.menu.w.W and self.spellManager:CanCast("W") and self.menu.w[h.charName] and self.menu.w[h.charName.."perc"] >= (h.health*100)/h.maxHealth and (myHero.mana*100)/myHero.maxMana >= self.menu.w[h.charName.."mana"] and GetDistance(h,myHero) <= 540 then
					self.spellManager:CastSpellTarget(h, _W)
					break
				end
				if self.menu.r.R and self.spellManager:CanCast("R") and self.menu.r[h.charName] and self.menu.r[h.charName.."perc"] >= (h.health*100)/h.maxHealth and (myHero.mana*100)/myHero.maxMana >= self.menu.r[h.charName.."mana"] then
					self.spellManager:CastSpell(_R)
					break
				end
			end
		end
	end

	if UOL:GetOrbWalkMode() == "Combo" then
		self:ComboMode()
	elseif UOL:GetOrbWalkMode() == "Harass" then
		self:HarassMode()
	elseif UOL:GetOrbWalkMode() == "LaneClear" then
		self:LaneClearMode()
	elseif UOL:GetOrbWalkMode() == "LastHit" then
		self:LastHitMode()
	end
end

function ChampionSoraka:ComboMode()
	if not self.ts.target or self.ts.target == nil or GetDistance(myHero.pos, self.ts.target.pos) >= 1250 or self.ts.target.dead or self.ts.target.health < 1 or not ValidTarget(self.ts.target, 1200) then
		return
	end

	if self.spellManager:CanCast("E") and self.menu.combo.E and ((myHero.mana*100)/myHero.maxMana) > self.menu.combo.Emana then
		castPosE, hitChanceE, heroPositionE = UPL:Predict(_E, myHero, self.ts.target)
		if castPosE and hitChanceE >= _G.ZeroConfig.menu["Prediction"..myHero.charName].EHitChance and GetDistance(myHero.pos, castPosE) <= 1200 then
			self.spellManager:CastSpellPosition(castPosE, _E)
		end
	end

	if self.spellManager:CanCast("Q") and self.menu.combo.Q and ((myHero.mana*100)/myHero.maxMana) > self.menu.combo.Qmana then
		castPosQ, hitChanceQ, heroPositionQ = UPL:Predict(_Q, myHero, self.ts.target)
		if castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance and GetDistance(myHero.pos, castPosQ) <= 1200 then
			self.spellManager:CastSpellPosition(castPosQ, _Q)
		end
	end
end

function ChampionSoraka:HarassMode()
	if not self.ts.target or self.ts.target == nil or GetDistance(myHero.pos, self.ts.target.pos) >= 1250 or self.ts.target.dead or self.ts.target.health < 1 or not ValidTarget(self.ts.target, 1200) then
		return
	end

	if self.spellManager:CanCast("E") and self.menu.harass.E and ((myHero.mana*100)/myHero.maxMana) > self.menu.harass.Emana then
		castPosE, hitChanceE, heroPositionE = UPL:Predict(_E, myHero, self.ts.target)
		if castPosE and hitChanceE >= _G.ZeroConfig.menu["Prediction"..myHero.charName].EHitChance and GetDistance(myHero.pos, castPosE) <= 1200 then
			self.spellManager:CastSpellPosition(castPosE, _E)
		end
	end

	if self.spellManager:CanCast("Q") and self.menu.harass.Q and ((myHero.mana*100)/myHero.maxMana) > self.menu.harass.Qmana then
		castPosQ, hitChanceQ, heroPositionQ = UPL:Predict(_Q, myHero, self.ts.target)
		if castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance and GetDistance(myHero.pos, castPosQ) <= 1200 then
			self.spellManager:CastSpellPosition(castPosQ, _Q)
		end
	end
end

function ChampionSoraka:LastHitMode()
	if not self.ts.target or self.ts.target == nil or GetDistance(myHero.pos, self.ts.target.pos) >= 1250 or self.ts.target.dead or self.ts.target.health < 1 or not ValidTarget(self.ts.target, 1200) then
		return
	end

	if self.spellManager:CanCast("E") and self.menu.lasthit.E and ((myHero.mana*100)/myHero.maxMana) > self.menu.lasthit.Emana then
		castPosE, hitChanceE, heroPositionE = UPL:Predict(_E, myHero, self.ts.target)
		if castPosE and hitChanceE >= _G.ZeroConfig.menu["Prediction"..myHero.charName].EHitChance and GetDistance(myHero.pos, castPosE) <= 1200 then
			self.spellManager:CastSpellPosition(castPosE, _E)
		end
	end

	if self.spellManager:CanCast("Q") and self.menu.lasthit.Q and ((myHero.mana*100)/myHero.maxMana) > self.menu.lasthit.Qmana then
		castPosQ, hitChanceQ, heroPositionQ = UPL:Predict(_Q, myHero, self.ts.target)
		if castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance and GetDistance(myHero.pos, castPosQ) <= 1200 then
			self.spellManager:CastSpellPosition(castPosQ, _Q)
		end
	end
end

function ChampionSoraka:LaneClearMode()
	
end

class("ChampionAshe")
function ChampionAshe:__init()
	self.ver = 1002

	self.menu = scriptConfig("Zer0 Bundle - Ashe", "003dataAshe")
	self.menu:addSubMenu("-> Extra Keys <-", "keys")
		self.menu.keys:addParam("flee", "Flee Mode *SOON*", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte( 'T' ))

	self.menu:addSubMenu("-> Combo Logic <-", "combo")
		self.menu.combo:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		self.menu.combo:addParam("Qmana", "% Mana for Q", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
		self.menu.combo:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
		self.menu.combo:addParam("Wmana", "% Mana for W", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
		self.menu.combo:addParam("R", "Use R", SCRIPT_PARAM_ONOFF, true)
		self.menu.combo:addParam("Rmana", "% Mana for E", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)

	self.menu:addSubMenu("-> Harass Logic <-", "harass")
		self.menu.harass:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		self.menu.harass:addParam("Qmana", "% Mana for Q", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
		self.menu.harass:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
		self.menu.harass:addParam("Wmana", "% Mana for W", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)

	self.menu:addSubMenu("-> Harass 2 Logic <-", "lasthit")
		self.menu.lasthit:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, false)
		self.menu.lasthit:addParam("Qmana", "% Mana for Q", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
		self.menu.lasthit:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, false)
		self.menu.lasthit:addParam("Wmana", "% Mana for W", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)

	self.menu:addSubMenu("-> Lane Clear Logic <-", "laneclear")
		self.menu.laneclear:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		self.menu.laneclear:addParam("Qmana", "% Mana for Q", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
		self.menu.laneclear:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
		self.menu.laneclear:addParam("Wmana", "% Mana for W", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)

	self.menu:addSubMenu("-> Kill Secure <-", "ks")
		self.menu.ks:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		self.menu.ks:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)

	self.menu:addSubMenu("-> Auto E <-", "e")
		self.menu.e:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
		self.menu.e:addParam("Ebush", "Use E in Bush", SCRIPT_PARAM_ONOFF, true)
		self.menu.e:addParam("Efow", "Use E in FoW", SCRIPT_PARAM_ONOFF, true)
		for _,v in pairs(GetEnemyHeroes()) do
			if v then
				self.menu.e:addParam(v.charName, "Reveal " .. v.charName, SCRIPT_PARAM_ONOFF, true)
			end
		end

	self.menu:addSubMenu("-> Auto Level Settings <-", "autoLevel")
		self.menu.autoLevel:addParam("on", "Enabled *Requires Reload*", SCRIPT_PARAM_ONOFF, false)
		self.menu.autoLevel:addParam("priority", "Level Priority", SCRIPT_PARAM_LIST, 1, {"AD W Build", "AD Q Build"})

	if self.menu.autoLevel.on then
		local seq = {}
		if self.menu.autoLevel.priority == "AD W Build" then
			seq = {_W, _Q, _W, _E, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E}
		elseif self.menu.autoLevel.priority == "AD Q Build" then
			seq = {_Q, _W, _Q, _E, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}
		end
		AutoLeveler(seq)
	end

	self.menu:addSubMenu("-> Dash Logic <-", "dash")
		for _,v in pairs(GetEnemyHeroes()) do
			if v then
				self.menu.dash:addParam(v.charName, v.charName, SCRIPT_PARAM_ONOFF, true)
			end
		end

	self.menu:addSubMenu("-> Draw <-", "draw")
		self.menu.draw:addParam("target", "Draw Target", SCRIPT_PARAM_ONOFF, true)
		self.menu.draw:addParam("damage", "Predicted Damage", SCRIPT_PARAM_ONOFF, true)
		self.menu.draw:addParam("w", "Draw W Range", SCRIPT_PARAM_ONOFF, true)

	self.menu:addSubMenu("-> Debug <-", "debug")
		self.menu.debug:addParam("dash", "Hide Dash Prints", SCRIPT_PARAM_ONOFF, false)


	_G.UPL:AddSpell(_W, { speed = 1600, delay = 0.3, range = 1200, width = 40, collision = true, aoe = false, type = "cone" })
	_G.UPL:AddSpell(_R, { speed = 1550, delay = 0.3, range = 25000, width = 260, collision = true, aoe = false, type = "linear" })

	self.ts = TargetSelector(TARGET_LESS_CAST, 1200, DAMAGE_MAGIC, true)
	self.autoKillTs = TargetSelector(TARGET_LOW_HP, 1200, DAMAGE_MAGIC, true)
	self.jungleMinions = minionManager(MINION_JUNGLE, 1200, myHero, MINION_SORT_MAXHEALTH_DEC)
	self.enemyMinions = minionManager(MINION_ENEMY, 1200, myHero, MINION_SORT_HEALTH_ASC)

	self.spellManager = SpellMaster()

	self.fowTracker = {}
	for _, e in ipairs(GetEnemyHeroes()) do
		if e then
			self.fowTracker[e.charName] = nil
		end
	end

	AddDrawCallback(function() self:OnDraw() end)
	AddTickCallback(function() self:OnTick() end)
	AddNewPathCallback(function(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance) self:OnNewPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance) end)
end

function ChampionAshe:OnTick()
	self.ts:update()
	self.autoKillTs:update()
	self.jungleMinions:update()
	self.enemyMinions:update()

	for _, e in ipairs(GetEnemyHeroes()) do
		if e then
			if e.dead or e.visible then
				self.fowTracker[e.charName] = {
					position = nil,
					seen = 0,
					obj = e
				}
			else
				self.fowTracker[e.charName] = {
					position = e.pos,
					seen = os.clock(),
					obj = e
				}
			end
		end
	end

	if self.spellManager:CanCast("E") then
		for _, cE in ipairs(self.fowTracker) do
			if cE ~= nil and cE.seen ~= 0 and not cE.obj.dead and not cE.obj.visible and cE.seen and cE.position and os.clock() - cE.seen < 2 and cE.obj.endPath then
				local point = NormalizeX(e.endPath, cE.obj, 100)
				if IsWallOfGrass(D3DXVECTOR3(p.x,e.y,p.z)) and self.menu.e.Ebush then
					self.spellManager:CastSpellPosition(cE.obj.pos, _E)
					break
				elseif self.menu.e.Efow then
					self.spellManager:CastSpellPosition(cE.obj.pos, _E)
					break
				end
			end
		end
	end

	self:KillSteal()

	if UOL:GetOrbWalkMode() == "Combo" then
		self:ComboMode()
	elseif UOL:GetOrbWalkMode() == "Harass" then
		self:HarassMode()
	elseif UOL:GetOrbWalkMode() == "LaneClear" then
		self:LaneClearMode()
	elseif UOL:GetOrbWalkMode() == "LastHit" then
		self:LastHitMode()
	end
end

function ChampionAshe:ComboMode()
	if not self.ts.target or self.ts.target == nil or GetDistance(myHero.pos, self.ts.target.pos) >= 1250 or self.ts.target.dead or self.ts.target.health < 1 or not ValidTarget(self.ts.target, 1200) then
		return
	end
	if self.spellManager:CanCast("R") and ((myHero.mana*100)/myHero.maxMana) > self.menu.combo.Rmana and self.menu.combo.R and UnitIsFleeingMe(self.ts.target) and (self.ts.target.maxHealth / 2) > self.ts.target.health then
		castPosR, hitChanceR, heroPositionR = UPL:Predict(_R, myHero, self.ts.target)
		if castPosR and hitChanceR >= _G.ZeroConfig.menu["Prediction"..myHero.charName].RHitChance and GetDistance(myHero.pos, castPosR) <= 15000 then
			self.spellManager:CastSpellPosition(castPosR, _R)
		end
	end

	if self.spellManager:CanCast("W") and self.menu.combo.W and ((myHero.mana*100)/myHero.maxMana) > self.menu.combo.Wmana then
		castPosW, hitChanceW, heroPositionW = UPL:Predict(_W, myHero, self.ts.target)
		if castPosW and hitChanceW >= _G.ZeroConfig.menu["Prediction"..myHero.charName].WHitChance and GetDistance(myHero.pos, castPosW) <= 1200 then
			self.spellManager:CastSpellPosition(castPosW, _W)
		end
	end

	if self.spellManager:CanCast("Q") and self.menu.combo.Q and ((myHero.mana*100)/myHero.maxMana) > self.menu.combo.Qmana then
		if GetDistance(self.ts.target.pos, myHero.pos) <= myHero.range + 20 then
			self.spellManager:CastSpell(_Q)
		end
	end
end

function ChampionAshe:HarassMode()
	if not self.ts.target or self.ts.target == nil or GetDistance(myHero.pos, self.ts.target.pos) >= 1250 or self.ts.target.dead or self.ts.target.health < 1 or not ValidTarget(self.ts.target, 1200) then
		return
	end

	if self.spellManager:CanCast("W") and self.menu.harass.W and ((myHero.mana*100)/myHero.maxMana) > self.menu.harass.Wmana then
		castPosW, hitChanceW, heroPositionW = UPL:Predict(_W, myHero, self.ts.target)
		if castPosW and hitChanceW >= _G.ZeroConfig.menu["Prediction"..myHero.charName].WHitChance and GetDistance(myHero.pos, castPosW) <= 1200 then
			self.spellManager:CastSpellPosition(castPosW, _W)
		end
	end

	if self.spellManager:CanCast("Q") and self.menu.harass.Q and ((myHero.mana*100)/myHero.maxMana) > self.menu.harass.Qmana then
		if GetDistance(self.ts.target.pos, myHero.pos) <= myHero.range then
			self.spellManager:CastSpell(_Q)
		end
	end
end

function ChampionAshe:LaneClearMode()
	if not self.enemyMinions.target or self.enemyMinions.target == nil or GetDistance(myHero.pos, self.enemyMinions.target.pos) >= 1250 or self.enemyMinions.target.dead or self.enemyMinions.target.health < 1 or not ValidTarget(self.enemyMinions.target, 1200) then
		return
	end

	if self.spellManager:CanCast("W") and self.menu.laneclear.W and ((myHero.mana*100)/myHero.maxMana) > self.menu.laneclear.Wmana then
		castPosW, hitChanceW, heroPositionW = UPL:Predict(_W, myHero, self.enemyMinions.target)
		if castPosW and hitChanceW >= _G.ZeroConfig.menu["Prediction"..myHero.charName].WHitChance and GetDistance(myHero.pos, castPosW) <= 1200 then
			self.spellManager:CastSpellPosition(castPosW, _W)
		end
	end

	if self.spellManager:CanCast("Q") and self.menu.laneclear.Q and ((myHero.mana*100)/myHero.maxMana) > self.menu.laneclear.Qmana then
		if GetDistance(self.enemyMinions.target.pos, myHero.pos) <= myHero.range then
			self.spellManager:CastSpell(_Q)
		end
	end
end

function ChampionAshe:LastHitMode()
	if not self.ts.target or self.ts.target == nil or GetDistance(myHero.pos, self.ts.target.pos) >= 1250 or self.ts.target.dead or self.ts.target.health < 1 or not ValidTarget(self.ts.target, 1200) then
		return
	end

	if self.spellManager:CanCast("W") and self.menu.lasthit.W and ((myHero.mana*100)/myHero.maxMana) > self.menu.lasthit.Wmana then
		castPosW, hitChanceW, heroPositionW = UPL:Predict(_W, myHero, self.ts.target)
		if castPosW and hitChanceW >= _G.ZeroConfig.menu["Prediction"..myHero.charName].WHitChance and GetDistance(myHero.pos, castPosW) <= 1200 then
			self.spellManager:CastSpellPosition(castPosW, _W)
		end
	end

	if self.spellManager:CanCast("Q") and self.menu.lasthit.Q and ((myHero.mana*100)/myHero.maxMana) > self.menu.lasthit.Qmana then
		if GetDistance(self.ts.target.pos, myHero.pos) <= myHero.range then
			self.spellManager:CastSpell(_Q)
		end
	end
end

function ChampionAshe:OnNewPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance)
	if unit == nil or endPos == nil or not self.spellManager:CanCast("W") or not isDash or unit.team == myHero.team or unit.type ~= myHero.type then
		return
	end

	if GetDistance(endPos, myHero.pos) < 1200 then
		self.spellManager:CastSpellPosition(endPos, _W)
		PrintPretty("Casting [W] for dash from [" .. unit.charName .. "]", self.menu.debug.dash, true)
	end
end

function ChampionAshe:Damage(spell)
	if spell == "Q" then
		spellLevel = GetSpellData(_Q).level
		if spellLevel == 0 then return 0 end
		levelDamage = {23,24,25,26,27}
		myAdScale = myHero.damage * levelDamage[spellLevel]
		damage = myHero.damage + myAdScale
		return damage
	elseif spell == "W" then
		spellLevel = GetSpellData(_W).level
		if spellLevel == 0 then return 0 end
		levelDamage = {20,35,50,65,80}
		myAdScale = levelDamage[spellLevel]
		damage = myHero.damage + myAdScale
		return damage
	elseif spell == "E" then
		return 0
	elseif spell == "R" then
		spellLevel = GetSpellData(_R).level
		if spellLevel == 0 then return 0 end
		levelDamage = {250,425,600}
		myApScale = myHero.ap
		damage = levelDamage[spellLevel] + myApScale
		return damage
	end
end

function ChampionAshe:KillSteal()
	if self.autoKillTs.target == nil or self.autoKillTs.target:GetDistance(myHero) >= 1250 or self.autoKillTs.target.dead or self.autoKillTs.target.health < 1 or not ValidTarget(self.autoKillTs.target, 1250) then
		return
	end

	local damage = {
		q = self:Damage("Q"),
		w = self:Damage("W"),
		r = self:Damage("R"),
		qw = self:Damage("Q") + self:Damage("W"),
		qr = self:Damage("Q") + self:Damage("R"),
		wr = self:Damage("W") + self:Damage("R"),
		qwr = self:Damage("W") + self:Damage("R") + self:Damage("Q")
	}

	if damage.w > self.autoKillTs.target.health + (self.autoKillTs.target.health * .1) and self.spellManager:CanCast(_W) then
		castPosW, hitChanceW, heroPositionW = UPL:Predict(_W, myHero, self.autoKillTs.target)
		if castPosW and hitChanceW >= _G.ZeroConfig.menu["Prediction"..myHero.charName].WHitChance and myHero:GetDistance(castPosW) <= 1200 then
			self.spellManager:CastSpellPosition(castPosW, _W)
		end
	elseif damage.q > self.autoKillTs.target.health + (self.autoKillTs.target.health * .1) and self.spellManager:CanCast(_Q) then
		castPosQ, hitChanceQ, heroPositionQ = UPL:Predict(_Q, myHero, self.autoKillTs.target)
		if castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance and myHero:GetDistance(castPosQ) <= 1075 then
			self.spellManager:CastSpellPosition(castPosQ, _Q)
		end
	elseif damage.qw > self.autoKillTs.target.health + (self.autoKillTs.target.health * .1) and self.spellManager:CanCast(_Q) and self.spellManager:CanCast(_W) then
		castPosW, hitChanceW, heroPositionW = UPL:Predict(_W, myHero, self.autoKillTs.target)
		if (castPosW and hitChanceW >= _G.ZeroConfig.menu["Prediction"..myHero.charName].WHitChance and myHero:GetDistance(castPosW) <= 1200) then
			self.spellManager:CastSpellPosition(castPosE, _W)
			self.spellManager:CastSpellPosition(castPosQ, _Q)
		end
	elseif damage.wr > self.autoKillTs.target.health + (self.autoKillTs.target.health * .1) and self.spellManager:CanCast(_W) and self.spellManager:CanCast(_R) then
		castPosR, hitChanceR, heroPositionR = UPL:Predict(_R, myHero, self.autoKillTs.target)
		castPosW, hitChanceW, heroPositionW = UPL:Predict(_W, myHero, self.autoKillTs.target)
		if (castPosR and hitChanceR >= _G.ZeroConfig.menu["Prediction"..myHero.charName].RHitChance and myHero:GetDistance(castPosR) <= 3330) and (castPosW and hitChanceW >= _G.ZeroConfig.menu["Prediction"..myHero.charName].WHitChance and myHero:GetDistance(castPosW) <= 1200) then
			self.spellManager:CastSpellPosition(castPosE, _W)
			self.spellManager:CastSpellPosition(castPosQ, _R)
		end
	elseif damage.qr > self.autoKillTs.target.health + (self.autoKillTs.target.health * .1) and self.spellManager:CanCast(_Q) and self.spellManager:CanCast(_R) then
		castPosR, hitChanceR, heroPositionR = UPL:Predict(_R, myHero, self.autoKillTs.target)
		castPosQ, hitChanceQ, heroPositionQ = UPL:Predict(_Q, myHero, self.autoKillTs.target)
		if (castPosR and hitChanceR >= _G.ZeroConfig.menu["Prediction"..myHero.charName].RHitChance and myHero:GetDistance(castPosR) <= 3330) and (castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance and myHero:GetDistance(castPosE) <= 1200) then
			self.spellManager:CastSpellPosition(castPosQ, _Q)
			self.spellManager:CastSpellPosition(castPosQ, _R)
		end
	elseif damage.qwr > self.autoKillTs.target.health + (self.autoKillTs.target.health * .1) and self.spellManager:CanCast(_Q) and self.spellManager:CanCast(_W) and self.spellManager:CanCast(_R) then
		castPosR, hitChanceR, heroPositionR = UPL:Predict(_R, myHero, self.autoKillTs.target)
		castPosW, hitChanceW, heroPositionW = UPL:Predict(_W, myHero, self.autoKillTs.target)
		if (castPosR and hitChanceR >= _G.ZeroConfig.menu["Prediction"..myHero.charName].RHitChance and myHero:GetDistance(castPosR) <= 3330) and (castPosW and hitChanceW >= _G.ZeroConfig.menu["Prediction"..myHero.charName].WHitChance and myHero:GetDistance(castPosW) <= 1200) then
			self.spellManager:CastSpellPosition(castPosQ, _E)
			self.spellManager:CastSpellPosition(castPosQ, _R)
			self.spellManager:CastSpellPosition(castPosQ, _Q)
		end
	end
end

function ChampionAshe:OnDraw()
	if self.menu.draw.target and self.ts.target ~= nil and self.ts.target.health > 0 and not self.ts.target.dead then
		DrawCircle3D(self.ts.target.x, self.ts.target.y, self.ts.target.z, 175, 4, ColorCodes.Blue, 52)
	end

	if self.menu.draw.target and self.autoKillTs.target ~= nil and self.autoKillTs.target.health > 0 and not self.autoKillTs.target.dead then
		DrawCircle3D(self.autoKillTs.target.x, self.autoKillTs.target.y, self.autoKillTs.target.z, 175, 4, ColorCodes.Red, 52)
	end

	if self.menu.draw.w and self.spellManager:CanCast("W") then
		DrawCircle3D(myHero.pos.x, myHero.pos.y, myHero.pos.z, 1200, 4, ColorCodes.Gray, 52)
	end

	if self.menu.draw.damage then
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
						['AniviaEgg'] = -0.1,
						["Annie"] = -0.25
					}
					barOffset.x = t[v.charName] or 0
				end
				local baseX = barPos.x - 69 + barOffset.x * 150
				local baseY = barPos.y + barOffset.y * 50 + 12.5

				if v.charName == "Jhin" then 
					baseY = baseY - 12
				end
				
				local myDamage = 0
				local comboNeeded = nil
				if (self.menu.combo.R and self.spellManager:CanCast("R")) and (self.menu.combo.Q and self.spellManager:CanCast("Q")) and (self.menu.combo.W and self.spellManager:CanCast("W")) then
					myDamage = self:Damage("Q") + self:Damage("R") + self:Damage("W")
					comboNeeded = "Full"
				elseif (self.menu.combo.R and self.spellManager:CanCast("R")) and (self.menu.combo.Q and self.spellManager:CanCast("Q")) then
					myDamage = self:Damage("Q") + self:Damage("R")
					comboNeeded = "Q-R"
				elseif (self.menu.combo.W and self.spellManager:CanCast("W")) and (self.menu.combo.Q and self.spellManager:CanCast("Q")) then
					myDamage = self:Damage("Q") + self:Damage("W")
					comboNeeded = "Q-W"
				elseif (self.menu.combo.W and self.spellManager:CanCast("W")) and (self.menu.combo.R and self.spellManager:CanCast("R")) then
					myDamage = self:Damage("R") + self:Damage("W")
					comboNeeded = "R-W"
				elseif (self.menu.combo.W and self.spellManager:CanCast("W")) then
					myDamage = self:Damage("W")
					comboNeeded = "W"
				elseif (self.menu.combo.R and self.spellManager:CanCast("R")) then
					myDamage = self:Damage("R")
					comboNeeded = "R"
				elseif (self.menu.combo.Q and self.spellManager:CanCast("Q")) then
					myDamage = self:Damage("Q")
					comboNeeded = "Q"
				end

				local dmgperc = myDamage/v.health*100
				local enemyhpperc = v.health/v.maxHealth
				
				if dmgperc < 100 then
					DrawLine(baseX, baseY-10, baseX+(1.05*dmgperc)*enemyhpperc, baseY-10, 15, ARGB(180,2.55*dmgperc,0,-255+2.55*dmgperc))
				else
					DrawLine(baseX, baseY-10, baseX+105*enemyhpperc, baseY-10, 15, ARGB(180,255,0,0))
					DrawText("Killable - " .. comboNeeded, 18, baseX + 45, baseY-60, ARGB(180,2.55*dmgperc,0,-255+2.55*dmgperc))
				end
				
			end
		end
	end
end

class("ChampionTeemo")
function ChampionTeemo:__init()
	self.ver = 1001

	self.menu = scriptConfig("Zer0 Bundle - Teemo", "003dataTeemo")
	self.menu:addSubMenu("-> Extra Keys <-", "keys")
		self.menu.keys:addParam("flee", "Flee Mode *SOON*", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte( 'T' ))

	self.menu:addSubMenu("-> Combo Logic <-", "combo")
		self.menu.combo:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		self.menu.combo:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
		self.menu.combo:addParam("R", "Use R", SCRIPT_PARAM_ONOFF, true)
		self.menu.combo:addParam("Ignite", "Use Ignite", SCRIPT_PARAM_ONOFF, true)

	self.menu:addSubMenu("-> Harass Logic <-", "harass")
		self.menu.harass:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		self.menu.harass:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)

	self.menu:addSubMenu("-> Harass 2 Logic <-", "lasthit")
		self.menu.lasthit:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, false)
		self.menu.lasthit:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, false)

	self.menu:addSubMenu("-> Lane Clear Logic <-", "laneclear")
		self.menu.laneclear:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		self.menu.laneclear:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)

	self.menu:addSubMenu("-> Auto Level Settings <-", "autoLevel")
		self.menu.autoLevel:addParam("on", "Enabled *VIP* *SOON*", SCRIPT_PARAM_ONOFF, false)
		self.menu.autoLevel:addParam("priority", "Level Priority", SCRIPT_PARAM_LIST, 1, {"E, Q, W", "E, W, Q", "Q, E, W", "Q, W, E", "W, E, Q", "W, Q, E"})

	self.menu:addSubMenu("-> Draw <-", "draw")
		self.menu.draw:addParam("target", "Draw Target", SCRIPT_PARAM_ONOFF, true)
		self.menu.draw:addParam("damage", "Predicted Damage", SCRIPT_PARAM_ONOFF, true)
		self.menu.draw:addParam("q", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)

	self.menu:addSubMenu("-> Debug <-", "debug")
		self.menu.debug:addParam("dash", "Hide Dash Prints", SCRIPT_PARAM_ONOFF, false)

	self.ts = TargetSelector(TARGET_LESS_CAST, 580, DAMAGE_MAGIC, true)
	self.autoKillTs = TargetSelector(TARGET_LOW_HP, 580, DAMAGE_MAGIC, true)
	self.jungleMinions = minionManager(MINION_JUNGLE, 580, myHero, MINION_SORT_MAXHEALTH_DEC)
	self.enemyMinions = minionManager(MINION_ENEMY, 500, myHero, MINION_SORT_HEALTH_ASC)

	self.spellManager = SpellMaster()

	AddDrawCallback(function() self:OnDraw() end)
	AddTickCallback(function() self:OnTick() end)
	--AddNewPathCallback(function(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance) self:OnNewPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance) end)
	--AddCastSpellCallback(function() self:CastSpellCB() end)
	--AddProcessSpellCallback(function(object, spell) self:ProcessSpell(object, spell) end)
end

function ChampionTeemo:OnTick()
	self.ts:update()
	self.autoKillTs:update()
	self.jungleMinions:update()
	self.enemyMinions:update()

	if UOL:GetOrbWalkMode() == "Combo" then
		self:ComboMode()
	elseif UOL:GetOrbWalkMode() == "Harass" then
		self:HarassMode()
	elseif UOL:GetOrbWalkMode() == "LaneClear" then
		self:LaneClearMode()
	elseif UOL:GetOrbWalkMode() == "LastHit" then
		self:LastHitMode()
	end
end

function ChampionTeemo:ComboMode()
	if not self.ts.target or self.ts.target == nil or GetDistance(myHero.pos, self.ts.target.pos) >= 580 or self.ts.target.dead or self.ts.target.health < 1 or not ValidTarget(self.ts.target, 580) then
		return
	end

	if self.spellManager:CanCast("Q") and self.menu.combo.Q then
		self.spellManager:CastSpellTarget(self.ts, _Q)
	end
end

function ChampionTeemo:HarassMode()
	if not self.ts.target or self.ts.target == nil or GetDistance(myHero.pos, self.ts.target.pos) >= 580 or self.ts.target.dead or self.ts.target.health < 1 or not ValidTarget(self.ts.target, 580) then
		return
	end

	if self.spellManager:CanCast("Q") and self.menu.harass.Q then
		self.spellManager:CastSpellTarget(self.ts, _Q)
	end
end

function ChampionTeemo:LaneClearMode()
end

function ChampionTeemo:LastHitMode()
	if not self.ts.target or self.ts.target == nil or GetDistance(myHero.pos, self.ts.target.pos) >= 580 or self.ts.target.dead or self.ts.target.health < 1 or not ValidTarget(self.ts.target, 580) then
		return
	end

	if self.spellManager:CanCast("Q") and self.menu.lasthit.Q then
		self.spellManager:CastSpellTarget(self.ts, _Q)
	end
end

function ChampionTeemo:OnDraw()
	if self.menu.draw.target and self.ts.target ~= nil and self.ts.target.health > 0 and not self.ts.target.dead then
		DrawCircle3D(self.ts.target.x, self.ts.target.y, self.ts.target.z, 175, 4, ColorCodes.Blue, 52)
	end

	if self.menu.draw.target and self.autoKillTs.target ~= nil and self.autoKillTs.target.health > 0 and not self.autoKillTs.target.dead then
		DrawCircle3D(self.autoKillTs.target.x, self.autoKillTs.target.y, self.autoKillTs.target.z, 175, 4, ColorCodes.Red, 52)
	end

	if self.menu.draw.q and self.spellManager:CanCast("Q") then
		DrawCircle3D(myHero.pos.x, myHero.pos.y, myHero.pos.z, 580, 4, ColorCodes.Gray, 52)
	end

	if self.menu.draw.damage then
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
						['AniviaEgg'] = -0.1,
						["Annie"] = -0.25
					}
					barOffset.x = t[v.charName] or 0
				end
				local baseX = barPos.x - 69 + barOffset.x * 150
				local baseY = barPos.y + barOffset.y * 50 + 12.5

				if v.charName == "Jhin" then 
					baseY = baseY - 12
				end
				
				local myDamage = 0
				local comboNeeded = nil
				myDamage = myHero:CalcDamage(v, myHero.totalDamage)
				if(self.menu.combo.Q and self.spellManager:CanCast("Q")) and self.spellManager:CanCast("E") then
					myDamage = myDamage + self:Damage("Q", v) + self:Damage("E", v)
					comboNeeded = "Q-E-AA"
				elseif(self.menu.combo.Q and self.spellManager:CanCast("Q")) then
					myDamage = myDamage + self:Damage("Q", v)
					comboNeeded = "Q-AA"
				elseif(self.spellManager:CanCast("E")) then
					myDamage = myDamage + self:Damage("E", v)
					comboNeeded = "E-AA"
				end

				local dmgperc = myDamage/v.health*100
				local enemyhpperc = v.health/v.maxHealth
				
				if dmgperc < 100 then
					DrawLine(baseX, baseY-10, baseX+(1.05*dmgperc)*enemyhpperc, baseY-10, 15, ARGB(180,2.55*dmgperc,0,-255+2.55*dmgperc))
				else
					DrawLine(baseX, baseY-10, baseX+105*enemyhpperc, baseY-10, 15, ARGB(180,255,0,0))
					DrawText("Killable - " .. comboNeeded, 18, baseX + 45, baseY-60, ARGB(180,2.55*dmgperc,0,-255+2.55*dmgperc))
				end
				
			end
		end
	end
end

function ChampionTeemo:Damage(spellText, unit)
	if spellText == "Q" then
		spellLevel = GetSpellData(_Q).level
		if spellLevel == 0 then return 0 end
		levelDamage = {60,105,150,195,240}
		myApScale = myHero.ap * 0.8
		damage = levelDamage[spellLevel] + myApScale
		return myHero:CalcMagicDamage(unit,damage)
	elseif spellText == "E" then
		spellLevel = GetSpellData(_E).level
		if spellLevel == 0 then return 0 end
		levelDamage = {24, 48, 72, 96, 120}
		myApScale = myHero.ap * 0.4
		damage = levelDamage[spellLevel] + myApScale
		return myHero:CalcMagicDamage(unit,damage)
	end
end

class("ChampionLux")
function ChampionLux:__init()
	self.ver = 1004

	--PrintPretty("Loaded Lux [v" .. self.ver .. "]", true, false)

	self.eState = function() return myHero:GetSpellData(_E).name ~= "LuxLightStrikeKugel" end

	self.menu = scriptConfig("Zer0 Bundle - Lux", "003dataLux")
	self.menu:addSubMenu("-> Extra Keys <-", "keys")
		self.menu.keys:addParam("flee", "Flee Mode *SOON*", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte( 'T' ))

	self.menu:addSubMenu("-> Combo Logic <-", "combo")
		self.menu.combo:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		self.menu.combo:addParam("Qmana", "% Mana for Q", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
		self.menu.combo:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
		self.menu.combo:addParam("Emana", "% Mana for E", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
		self.menu.combo:addParam("R", "Use R", SCRIPT_PARAM_ONOFF, true)
		self.menu.combo:addParam("Ignite", "Use Ignite", SCRIPT_PARAM_ONOFF, true)

	self.menu:addSubMenu("-> Harass Logic <-", "harass")
		self.menu.harass:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		self.menu.harass:addParam("Qmana", "% Mana for Q", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
		self.menu.harass:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
		self.menu.harass:addParam("Emana", "% Mana for E", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)

	self.menu:addSubMenu("-> Harass 2 Logic <-", "lasthit")
		self.menu.lasthit:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, false)
		self.menu.lasthit:addParam("Qmana", "% Mana for Q", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
		self.menu.lasthit:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, false)
		self.menu.lasthit:addParam("Emana", "% Mana for E", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)

	self.menu:addSubMenu("-> Lane Clear Logic <-", "laneclear")
		self.menu.laneclear:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
		self.menu.laneclear:addParam("Qmana", "% Mana for Q", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
		self.menu.laneclear:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
		self.menu.laneclear:addParam("Emana", "% Mana for E", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)

	self.menu:addSubMenu("-> R Settings <-", "r")
		self.menu.r:addParam("r", "Enabled", SCRIPT_PARAM_ONOFF, true)
		self.menu.r:addParam("stunned", "Only R Stunned Targets *SOON*", SCRIPT_PARAM_ONOFF, false)

	self.menu:addSubMenu("-> Auto Level Settings <-", "autoLevel")
		self.menu.autoLevel:addParam("on", "Enabled *VIP* *SOON*", SCRIPT_PARAM_ONOFF, false)
		self.menu.autoLevel:addParam("priority", "Level Priority", SCRIPT_PARAM_LIST, 1, {"E, Q, W", "E, W, Q", "Q, E, W", "Q, W, E", "W, E, Q", "W, Q, E"})

	self.menu:addSubMenu("-> Auto Steal Settings <-", "steal")
		self.menu.steal:addParam("jungle", "Steal Jungle", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte( 'Y' ))
		self.menu.steal:addParam("dragon", "Steal Dragon", SCRIPT_PARAM_ONOFF, true)
		self.menu.steal:addParam("baron", "Steal Baron", SCRIPT_PARAM_ONOFF, true)

	self.menu:addSubMenu("-> Auto Sheild Settings <-", "sheild")
		self.menu.steal:addParam("w", "Use W", SCRIPT_PARAM_ONOFF, true)

	self.menu:addSubMenu("-> Dash Logic <-", "dash")
		for _,v in pairs(GetEnemyHeroes()) do
			if v then
				self.menu.dash:addParam(v.charName, v.charName, SCRIPT_PARAM_ONOFF, true)
			end
		end

	self.menu:addSubMenu("-> Draw <-", "draw")
		self.menu.draw:addParam("target", "Draw Target", SCRIPT_PARAM_ONOFF, true)
		self.menu.draw:addParam("damage", "Predicted Damage", SCRIPT_PARAM_ONOFF, true)
		self.menu.draw:addParam("q", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
		self.menu.draw:addParam("w", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
		self.menu.draw:addParam("e", "Draw E Range", SCRIPT_PARAM_ONOFF, true)

	self.menu:addSubMenu("-> Debug <-", "debug")
		self.menu.debug:addParam("dash", "Hide Dash Prints", SCRIPT_PARAM_ONOFF, false)


	_G.UPL:AddSpell(_Q, { speed = 1200, delay = 0.25, range = 1200, width = 125, collision = true, aoe = false, type = "linear" })
	_G.UPL:AddSpell(_W, { speed = 1630, delay = 0.25, range = 1230, width = 205, collision = false, aoe = false, type = "linear" })
	_G.UPL:AddSpell(_E, { speed = 1300, delay = 0.25, range = 1075, width = 320, collision = false, aoe = true, type = "circular" })
	_G.UPL:AddSpell(_R, { speed = math.huge, delay = 1, range = 3340, width = 245, collision = false, aoe = false, type = "linear" })

	self.ts = TargetSelector(TARGET_LESS_CAST, 1200, DAMAGE_MAGIC, true)
	self.autoKillTs = TargetSelector(TARGET_LOW_HP, 3330, DAMAGE_MAGIC, true)
	self.jungleMinions = minionManager(MINION_JUNGLE, 3330, myHero, MINION_SORT_MAXHEALTH_DEC)
	self.enemyMinions = minionManager(MINION_ENEMY, 1075, myHero, MINION_SORT_HEALTH_ASC)
	self.eCastPos = nil

	self.spellManager = SpellMaster()

	self.Q = (myHero:CanUseSpell(_Q) == READY)
	self.W = (myHero:CanUseSpell(_W) == READY)
	self.E = (myHero:CanUseSpell(_E) == READY)
	self.R = (myHero:CanUseSpell(_R) == READY)

	AddDrawCallback(function() self:OnDraw() end)
	AddTickCallback(function() self:OnTick() end)
	AddNewPathCallback(function(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance) self:OnNewPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance) end)
	AddCastSpellCallback(function() self:CastSpellCB() end)
	AddProcessSpellCallback(function(object, spell) self:ProcessSpell(object, spell) end)
end

function ChampionLux:OnTick()
	self.ts:update()
	self.autoKillTs:update()
	self.jungleMinions:update()
	self.enemyMinions:update()

	self.Q = (myHero:CanUseSpell(_Q) == READY)
	self.W = (myHero:CanUseSpell(_W) == READY)
	self.E = (myHero:CanUseSpell(_E) == READY)
	self.R = (myHero:CanUseSpell(_R) == READY)

	self:KillSteal()
	self:JungleSteal()

	if self:eState() and self.eCastPos ~= nil then
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy) and GetDistance(enemy, self.eCastPos) <= 320 then
				self.spellManager:CastSpell(_E)
			end
		end
		for _, jg in ipairs(self.jungleMinions.objects) do
			if ValidTarget(jg) and GetDistance(jg, self.eCastPos) <= 320 then
				self.spellManager:CastSpell(_E)
			end
		end
		for _, minion in ipairs(self.enemyMinions.objects) do
			if ValidTarget(minion) and GetDistance(minion, self.eCastPos) <= 320 then
				self.spellManager:CastSpell(_E)
			end
		end
	end

	if self.menu.keys.flee then
		self:FleeMode()
		return
	end

	if self.spellManager:CanCast("W") and self.menu.sheild.W then
		for _, fHero in ipairs(GetAllyHeroes()) do
			if fHero and fHero:GetDistance(myHero) <= 1230 and not fHero.dead and fHero.health > 0 and (fHero.maxHealth * fHero.health) / fHero.maxHealth < 25 and endCountEnemyInRange(700, fHero) >= 1 then
				castPosW, hitChanceW, heroPositionW = UPL:Predict(_W, myHero, fHero)
				if castPosW and hitChanceW >= _G.ZeroConfig.menu["Prediction"..myHero.charName].WHitChance and GetDistance(myHero.pos, castPosW) <= 1230 then
					self.spellManager:CastSpellPosition(castPosW, _W)
					PrintPretty("Casting [W] to help [" .. fHero.charName .. "].", true, true)
				end
			end
		end
	end

	if UOL:GetOrbWalkMode() == "Combo" then
		self:ComboMode()
	elseif UOL:GetOrbWalkMode() == "Harass" then
		self:HarassMode()
	elseif UOL:GetOrbWalkMode() == "LaneClear" then
		self:LaneClearMode()
	elseif UOL:GetOrbWalkMode() == "LastHit" then
		self:LastHitMode()
	end
end

function ChampionLux:OnNewPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance)
	if unit == nil or endPos == nil or not self.spellManager:CanCast("Q") or not isDash or unit.team == myHero.team or unit.type ~= myHero.type then
		return
	end

	if GetDistance(endPos, myHero.pos) < 1200 then
		CastSpell(_E, endPos.x, endPos.z)
		self.spellManager:CastSpellPosition(endPos, _Q)
		PrintPretty("Casting [Q] for dash from [" .. unit.charName .. "]", self.menu.debug.dash, true)
	end
end

function ChampionLux:ComboMode()
	if not self.ts.target or self.ts.target == nil or GetDistance(myHero.pos, self.ts.target.pos) >= 1250 or self.ts.target.dead or self.ts.target.health < 1 or not ValidTarget(self.ts.target, 1250) then
		return
	end

	if self.E and self.menu.combo.E and (myHero.mana * myHero.maxMana / 100) >= self.menu.combo.Emana then
		castPosE, hitChanceE, heroPositionE = UPL:Predict(_E, myHero, self.ts.target)
		if castPosE and hitChanceE >= _G.ZeroConfig.menu["Prediction"..myHero.charName].EHitChance and GetDistance(myHero.pos, castPosE) <= 1075 then
			self.spellManager:CastSpellPosition(castPosE, _E)
		end
	end

	if self.Q and self.menu.combo.Q and (myHero.mana * myHero.maxMana / 100) >= self.menu.combo.Qmana then
		castPosQ, hitChanceQ, heroPositionQ = UPL:Predict(_Q, myHero, self.ts.target)
		if castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance and GetDistance(myHero.pos, castPosQ) <= 1200 then
			self.spellManager:CastSpellPosition(castPosQ, _Q)
		end
	end

	if self.R and self.menu.combo.R and self:Damage("R") >= self.ts.target.health then
		castPosR, hitChanceR, heroPositionR = UPL:Predict(_R, myHero, self.ts.target)
		if castPosR and hitChanceR >= _G.ZeroConfig.menu["Prediction"..myHero.charName].RHitChance and GetDistance(myHero.pos, castPosR) <= 3300 then
			self.spellManager:CastSpellPosition(castPosR, _R)
		end
	end
end

function ChampionLux:HarassMode()
	if not self.ts.target or self.ts.target == nil or GetDistance(myHero.pos, self.ts.target.pos) >= 1250 or self.ts.target.dead or self.ts.target.health < 1 or not ValidTarget(self.ts.target, 1250) then
		return
	end

	if self.E and self.menu.harass.E and (myHero.mana * myHero.maxMana / 100) >= self.menu.harass.Emana then
		castPosE, hitChanceE, heroPositionE = UPL:Predict(_E, myHero, self.ts.target)
		if castPosE and hitChanceE >= _G.ZeroConfig.menu["Prediction"..myHero.charName].EHitChance and GetDistance(myHero.pos, castPosE) <= 1075 then
			self.spellManager:CastSpellPosition(castPosE, _E)
		end
	end

	if self.Q and self.menu.harass.Q and (myHero.mana * myHero.maxMana / 100) >= self.menu.harass.Qmana then
		castPosQ, hitChanceQ, heroPositionQ = UPL:Predict(_Q, myHero, self.ts.target)
		if castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance and GetDistance(myHero.pos, castPosQ) <= 1200 then
			self.spellManager:CastSpellPosition(castPosQ, _Q)
		end
	end
end

function ChampionLux:LastHitMode()
	if not self.ts.target or self.ts.target == nil or GetDistance(myHero.pos, self.ts.target.pos) >= 1250 or self.ts.target.dead or self.ts.target.health < 1 or not ValidTarget(self.ts.target, 1250) then
		return
	end

	if self.E and self.menu.lasthit.E and (myHero.mana * myHero.maxMana / 100) >= self.menu.lasthit.Emana then
		castPosE, hitChanceE, heroPositionE = UPL:Predict(_E, myHero, self.ts.target)
		if castPosE and hitChanceE >= _G.ZeroConfig.menu["Prediction"..myHero.charName].EHitChance and GetDistance(myHero.pos, castPosE) <= 1075 then
			self.spellManager:CastSpellPosition(castPosE, _E)
		end
	end

	if self.Q and self.menu.lasthit.Q and (myHero.mana * myHero.maxMana / 100) >= self.menu.lasthit.Qmana then
		castPosQ, hitChanceQ, heroPositionQ = UPL:Predict(_Q, myHero, self.ts.target)
		if castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance and GetDistance(myHero.pos, castPosQ) <= 1200 then
			self.spellManager:CastSpellPosition(castPosQ, _Q)
		end
	end
end

function ChampionLux:LaneClearMode()
	if self.E and self.menu.laneclear.E and (myHero.mana * myHero.maxMana / 100) >= self.menu.laneclear.Emana then
		bestPos, bestHit = GetFarmPosition(1075, 320, self.enemyMinions.objects)
		if bestPos and bestHit >= 3 and GetDistance(bestPos, myHero.pos) <=  1075 then
			self.spellManager:CastSpellPosition(bestPos, _E)
		end
	end
end

function ChampionLux:KillSteal()
	if self.autoKillTs.target == nil or self.autoKillTs.target:GetDistance(myHero) >= 1250 or self.autoKillTs.target.dead or self.autoKillTs.target.health < 1 or not ValidTarget(self.autoKillTs.target, 1250) then
		return
	end

	local damage = {
		q = self:Damage("Q"),
		e = self:Damage("E"),
		r = self:Damage("R"),
		qe = self:Damage("Q") + self:Damage("E"),
		qr = self:Damage("Q") + self:Damage("R"),
		er = self:Damage("E") + self:Damage("R"),
		qer = self:Damage("E") + self:Damage("R") + self:Damage("Q")
	}

	if damage.e > self.autoKillTs.target.health + (self.autoKillTs.target.health * .1) and self.spellManager:CanCast(_E) then
		castPosE, hitChanceE, heroPositionE = UPL:Predict(_E, myHero, self.autoKillTs.target)
		if castPosE and hitChanceE >= _G.ZeroConfig.menu["Prediction"..myHero.charName].EHitChance and myHero:GetDistance(castPosE) <= 1075 then
			self.spellManager:CastSpellPosition(castPosE, _E)
		end
	elseif damage.q > self.autoKillTs.target.health + (self.autoKillTs.target.health * .1) and self.spellManager:CanCast(_Q) then
		castPosQ, hitChanceQ, heroPositionQ = UPL:Predict(_Q, myHero, self.autoKillTs.target)
		if castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance and myHero:GetDistance(castPosQ) <= 1075 then
			self.spellManager:CastSpellPosition(castPosQ, _Q)
		end
	elseif damage.qe > self.autoKillTs.target.health + (self.autoKillTs.target.health * .1) and self.spellManager:CanCast(_Q) and self.spellManager:CanCast(_E) then
		castPosQ, hitChanceQ, heroPositionQ = UPL:Predict(_Q, myHero, self.autoKillTs.target)
		castPosE, hitChanceE, heroPositionE = UPL:Predict(_E, myHero, self.autoKillTs.target)
		if (castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance and myHero:GetDistance(castPosQ) <= 1200) and (castPosE and hitChanceE >= _G.ZeroConfig.menu["Prediction"..myHero.charName].EHitChance and myHero:GetDistance(castPosE) <= 1075) then
			self.spellManager:CastSpellPosition(castPosE, _E)
			self.spellManager:CastSpellPosition(castPosQ, _Q)
		end
	elseif damage.er > self.autoKillTs.target.health + (self.autoKillTs.target.health * .1) and self.spellManager:CanCast(_E) and self.spellManager:CanCast(_R) then
		castPosR, hitChanceR, heroPositionR = UPL:Predict(_R, myHero, self.autoKillTs.target)
		castPosE, hitChanceE, heroPositionE = UPL:Predict(_E, myHero, self.autoKillTs.target)
		if (castPosR and hitChanceR >= _G.ZeroConfig.menu["Prediction"..myHero.charName].RHitChance and myHero:GetDistance(castPosR) <= 3330) and (castPosE and hitChanceE >= _G.ZeroConfig.menu["Prediction"..myHero.charName].EHitChance and myHero:GetDistance(castPosE) <= 1075) then
			self.spellManager:CastSpellPosition(castPosE, _E)
			self.spellManager:CastSpellPosition(castPosQ, _R)
		end
	elseif damage.qr > self.autoKillTs.target.health + (self.autoKillTs.target.health * .1) and self.spellManager:CanCast(_Q) and self.spellManager:CanCast(_R) then
		castPosR, hitChanceR, heroPositionR = UPL:Predict(_R, myHero, self.autoKillTs.target)
		castPosQ, hitChanceQ, heroPositionQ = UPL:Predict(_Q, myHero, self.autoKillTs.target)
		if (castPosR and hitChanceR >= _G.ZeroConfig.menu["Prediction"..myHero.charName].RHitChance and myHero:GetDistance(castPosR) <= 3330) and (castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance and myHero:GetDistance(castPosQ) <= 1200) then
			self.spellManager:CastSpellPosition(castPosQ, _Q)
			self.spellManager:CastSpellPosition(castPosQ, _R)
		end
	elseif damage.qer > self.autoKillTs.target.health + (self.autoKillTs.target.health * .1) and self.spellManager:CanCast(_Q) and self.spellManager:CanCast(_E) and self.spellManager:CanCast(_R) then
		castPosR, hitChanceR, heroPositionR = UPL:Predict(_R, myHero, self.autoKillTs.target)
		castPosE, hitChanceE, heroPositionE = UPL:Predict(_E, myHero, self.autoKillTs.target)
		castPosQ, hitChanceQ, heroPositionQ = UPL:Predict(_Q, myHero, self.autoKillTs.target)
		if (castPosR and hitChanceR >= _G.ZeroConfig.menu["Prediction"..myHero.charName].RHitChance and myHero:GetDistance(castPosR) <= 3330) and (castPosQ and hitChanceQ >= _G.ZeroConfig.menu["Prediction"..myHero.charName].QHitChance and myHero:GetDistance(castPosQ) <= 1200) and (castPosE and hitChanceE >= _G.ZeroConfig.menu["Prediction"..myHero.charName].EHitChance and myHero:GetDistance(castPosE) <= 1075) then
			self.spellManager:CastSpellPosition(castPosQ, _E)
			self.spellManager:CastSpellPosition(castPosQ, _Q)
			self.spellManager:CastSpellPosition(castPosQ, _R)
		end
	end
end

function ChampionLux:CastSpellCB(iSpell, startPos, endPos, targetUnit)
	if iSpell == 2 then
		self.eCastPos = endPos
	end
end

function ChampionLux:ProcessSpell(object, spell)
	if object.team ~= myHero.team and spell.target ~= nil and self.spellManager:CanCast(_W) then
		if spell.target:GetDistance(myHero) <= 1250 and spell.target.health > 0 and not spell.target.dead then
			castPosW, hitChanceW, heroPositionW = UPL:Predict(_W, myHero, spell.target)
			if (castPosW and hitChanceW >= _G.ZeroConfig.menu["Prediction"..myHero.charName].WHitChance and myHero:GetDistance(castPosW) <= 1250) then
				self.spellManager:CastSpellPosition(castPosW, _W)
			end
		end
	end
end

function ChampionLux:JungleSteal()
	if not self.menu.steal.jungle then return end
	self.jungleMinions:update()
	for _, jg in ipairs(self.jungleMinions.objects) do
		if jg and ValidTarget(jg, 3330) and ((self.menu.steal.dragon and jg.name:lower():find("dragon")) or (self.menu.steal.baron and jg.name:lower():find("baron"))) then
			paddedHP = jg.health
			for i, enemy in ipairs(GetEnemyHeroes()) do
				if ValidTarget(enemy) and GetDistance(enemy, jg) <= 800 then
					paddedHP = paddedHP - enemy.totalDamage
				end
			end

			if self.spellManager:CanCast("R") then
				if self:Damage("E")+self:Damage("R") >= paddedHP and self.spellManager:CanCast("E") and myHero:GetDistance(jg) <= 1065 then
					castPosE, hitChanceE, heroPositionE = UPL:Predict(_E, myHero, jg)
					castPosR, hitChanceR, heroPositionR = UPL:Predict(_E, myHero, jg)
					if (castPosE and hitChanceE) and (castPosR and hitChanceR) then
						self.spellManager:CastSpellPosition(castPosE, _E)
						self.spellManager:CastSpellPosition(castPosR, _R)
					end
				elseif self:Damage("R") >= paddedHP and myHero:GetDistance(jg) <= 3330 then
					castPosR, hitChanceR, heroPositionR = UPL:Predict(_E, myHero, jg)
					if (castPosR and hitChanceR) then
						self.spellManager:CastSpellPosition(castPosR, _R)
					end
				end
			end
		end
	end
end

function ChampionLux:Damage(spellText)
	if spellText == "Q" then
		spellLevel = GetSpellData(_Q).level
		if spellLevel == 0 then return 0 end
		levelDamage = {60,110,160,210,260}
		myApScale = myHero.ap * 0.7
		damage = levelDamage[spellLevel] + myApScale
		return damage
	elseif spellText == "W" then
		spellLevel = GetSpellData(_W).level
		if spellLevel == 0 then return 0 end
		levelDamage = {0,0,0,0,0}
		myApScale = myHero.ap * 0
		damage = levelDamage[spellLevel] + myApScale
		return damage
	elseif spellText == "E" then
		spellLevel = GetSpellData(_E).level
		if spellLevel == 0 then return 0 end
		levelDamage = {60,105,150,195,240}
		myApScale = myHero.ap * 0.6
		damage = levelDamage[spellLevel] + myApScale
		return damage
	elseif spellText == "R" then
		spellLevel = GetSpellData(_R).level
		if spellLevel == 0 then return 0 end
		levelDamage = {300,400,500}
		myApScale = myHero.ap * 0.75
		damage = levelDamage[spellLevel] + myApScale
		return damage
	end
end

function ChampionLux:OnDraw()
	if self.menu.draw.target and self.ts.target ~= nil and self.ts.target.health > 0 and not self.ts.target.dead then
		DrawCircle3D(self.ts.target.x, self.ts.target.y, self.ts.target.z, 175, 4, ColorCodes.Blue, 52)
	end

	if self.menu.draw.target and self.autoKillTs.target ~= nil and self.autoKillTs.target.health > 0 and not self.autoKillTs.target.dead then
		DrawCircle3D(self.autoKillTs.target.x, self.autoKillTs.target.y, self.autoKillTs.target.z, 175, 4, ColorCodes.Red, 52)
	end

	if self.menu.draw.q and self.spellManager:CanCast("Q") then
		DrawCircle3D(myHero.pos.x, myHero.pos.y, myHero.pos.z, 1200, 4, ColorCodes.Gray, 52)
	end

	if self.menu.draw.w and self.spellManager:CanCast("W") then
		DrawCircle3D(myHero.pos.x, myHero.pos.y, myHero.pos.z, 1230, 4, ColorCodes.Gray, 52)
	end

	if self.menu.draw.e and self.spellManager:CanCast("E") then
		DrawCircle3D(myHero.pos.x, myHero.pos.y, myHero.pos.z, 1075, 4, ColorCodes.Gray, 52)
	end

	if self.menu.draw.damage then
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
						['AniviaEgg'] = -0.1,
						["Annie"] = -0.25
					}
					barOffset.x = t[v.charName] or 0
				end
				local baseX = barPos.x - 69 + barOffset.x * 150
				local baseY = barPos.y + barOffset.y * 50 + 12.5

				if v.charName == "Jhin" then 
					baseY = baseY - 12
				end
				
				local myDamage = 0
				local comboNeeded = nil
				if (self.menu.combo.R and self.spellManager:CanCast("R")) and (self.menu.combo.Q and self.spellManager:CanCast("Q")) and (self.menu.combo.E and self.spellManager:CanCast("E")) then
					myDamage = self:Damage("Q") + self:Damage("R") + self:Damage("E")
					comboNeeded = "Full"
				elseif (self.menu.combo.R and self.spellManager:CanCast("R")) and (self.menu.combo.Q and self.spellManager:CanCast("Q")) then
					myDamage = self:Damage("Q") + self:Damage("R")
					comboNeeded = "Q-R"
				elseif (self.menu.combo.E and self.spellManager:CanCast("E")) and (self.menu.combo.Q and self.spellManager:CanCast("Q")) then
					myDamage = self:Damage("Q") + self:Damage("E")
					comboNeeded = "Q-E"
				elseif (self.menu.combo.E and self.spellManager:CanCast("E")) and (self.menu.combo.R and self.spellManager:CanCast("R")) then
					myDamage = self:Damage("R") + self:Damage("E")
					comboNeeded = "R-E"
				elseif (self.menu.combo.E and self.spellManager:CanCast("E")) then
					myDamage = self:Damage("E")
					comboNeeded = "E"
				elseif (self.menu.combo.R and self.spellManager:CanCast("R")) then
					myDamage = self:Damage("R")
					comboNeeded = "R"
				elseif (self.menu.combo.Q and self.spellManager:CanCast("Q")) then
					myDamage = self:Damage("Q")
					comboNeeded = "Q"
				end

				local dmgperc = myDamage/v.health*100
				local enemyhpperc = v.health/v.maxHealth
				
				if dmgperc < 100 then
					DrawLine(baseX, baseY-10, baseX+(1.05*dmgperc)*enemyhpperc, baseY-10, 15, ARGB(180,2.55*dmgperc,0,-255+2.55*dmgperc))
				else
					DrawLine(baseX, baseY-10, baseX+105*enemyhpperc, baseY-10, 15, ARGB(180,255,0,0))
					DrawText("Killable - " .. comboNeeded, 18, baseX + 45, baseY-60, ARGB(180,2.55*dmgperc,0,-255+2.55*dmgperc))
				end
				
			end
		end
	end
end

--Classes
class("SpellMaster")
function SpellMaster:__init()
	AddTickCallback(function() self:OnTick() end)
	self.spells = {}
	self.spells.Q = {
		ready = false,
		lastCast = os.clock()
	}
	self.spells.W = {
		ready = false,
		lastCast = os.clock()
	}
	self.spells.E = {
		ready = false,
		lastCast = os.clock()
	}
	self.spells.R = {
		ready = false,
		lastCast = os.clock()
	}
end

function SpellMaster:OnTick()
	self.spells.Q.ready = (myHero:CanUseSpell(_Q) == READY)
	self.spells.W.ready = (myHero:CanUseSpell(_W) == READY)
	self.spells.E.ready = (myHero:CanUseSpell(_E) == READY)
	self.spells.R.ready = (myHero:CanUseSpell(_R) == READY)
	--for k, v in ipairs(self.spells) do
	--	if v.lastCast == nil then
	--		v.lastCast = os.clock()
	--	elseif v.lastCast < os.clock() + 2 then
	--		self.spells[k].ready = false
	--		print("Setting " .. k .. " to false")
	--	end
	--end
end

function SpellMaster:CastSpellPosition(position, spell)
	if position ~= nil and spell ~= nil then
		if spell == _Q then
			self.spells.Q.lastCast = os.clock()
			self.spells.Q.ready = false
		elseif spell == _W then
			self.spells.W.lastCast = os.clock()
			self.spells.W.ready = false
		elseif spell == _E then
			self.spells.E.lastCast = os.clock()
			self.spells.E.ready = false
		elseif spell == _R then
			self.spells.R.lastCast = os.clock()
			self.spells.R.ready = false
		end
		CastSpell(spell, position.x, position.z)
	end
end

function SpellMaster:CastSpellTarget(target, spell)
	if target ~= nil and spell ~= nil then
		if spell == _Q then
			self.spells.Q.lastCast = os.clock()
			self.spells.Q.ready = false
		elseif spell == _W then
			self.spells.W.lastCast = os.clock()
			self.spells.W.ready = false
		elseif spell == _E then
			self.spells.E.lastCast = os.clock()
			self.spells.E.ready = false
		elseif spell == _R then
			self.spells.R.lastCast = os.clock()
			self.spells.R.ready = false
		end
		CastSpell(spell, target)
	end
end

function SpellMaster:CastSpell(spell)
	if position ~= nil and spell ~= nil then
		if spell == _Q then
			self.spells.Q.lastCast = os.clock()
			self.spells.Q.ready = false
		elseif spell == _W then
			self.spells.W.lastCast = os.clock()
			self.spells.W.ready = false
		elseif spell == _E then
			self.spells.E.lastCast = os.clock()
			self.spells.E.ready = false
		elseif spell == _R then
			self.spells.R.lastCast = os.clock()
			self.spells.R.ready = false
		end
		CastSpell(spell)
	end
end

function SpellMaster:CanCast(spell)
	if spell == "Q" then
		return self.spells.Q.ready
	elseif spell == "W" then
		return self.spells.W.ready
	elseif spell == "E" then
		return self.spells.E.ready
	elseif spell == "R" then
		return self.spells.R.ready
	end
end

class("Activator")
function Activator:__init()
	self.summoners = {
		heal = nil,
		exhaust = nil,
		ignite = nil,
		smite = nil
	}

	self.lastPotion = 0
	self.potTime = 0

	self.jungleMinions = minionManager(MINION_JUNGLE, 800, myHero, MINION_SORT_MAXHEALTH_DEC)

	_G.ZeroConfig.menu:addSubMenu("Zer0 Activator", "activate")

	_G.ZeroConfig.menu.activate:addSubMenu("Potions", "potions")
	_G.ZeroConfig.menu.activate.potions:addParam("use", "Use Potions", SCRIPT_PARAM_ONOFF, true)
	_G.ZeroConfig.menu.activate.potions:addParam("MyHealth", "Use Under HP %", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)

	if myHero:GetSpellData(SUMMONER_1).name:lower():find("summonerheal") then
		self.summoners.heal = SUMMONER_1
		_G.ZeroConfig.menu.activate:addSubMenu("Summoner Heal", "heal")
		_G.ZeroConfig.menu.activate.heal:addParam("Heal", "Use Heal", SCRIPT_PARAM_ONOFF, true)
		_G.ZeroConfig.menu.activate.heal:addParam("MyHealth", "Use My HP Under %", SCRIPT_PARAM_SLICE, 30, 0, 100, 0)
		_G.ZeroConfig.menu.activate.heal:addParam("AllyHealth", "Use Ally HP Under %", SCRIPT_PARAM_SLICE, 30, 0, 100, 0)
		for _, a in ipairs(GetAllyHeroes()) do
			if a then
				_G.ZeroConfig.menu.activate.heal:addParam(a.charName, "Use On " .. a.charName, SCRIPT_PARAM_ONOFF, true)
			end
		end
	elseif myHero:GetSpellData(SUMMONER_2).name:lower():find("summonerheal") then
		self.summoners.heal = SUMMONER_2
		_G.ZeroConfig.menu.activate:addSubMenu("Summoner Heal", "heal")
		_G.ZeroConfig.menu.activate.heal:addParam("Heal", "Use Heal", SCRIPT_PARAM_ONOFF, true)
		_G.ZeroConfig.menu.activate.heal:addParam("MyHealth", "Use My HP Under %", SCRIPT_PARAM_SLICE, 30, 0, 100, 0)
		_G.ZeroConfig.menu.activate.heal:addParam("AllyHealth", "Use Ally HP Under %", SCRIPT_PARAM_SLICE, 30, 0, 100, 0)
		for _, a in ipairs(GetAllyHeroes()) do
			if a then
				_G.ZeroConfig.menu.activate.heal:addParam(a.charName, "Use On " .. a.charName, SCRIPT_PARAM_ONOFF, true)
			end
		end
	end

	if myHero:GetSpellData(SUMMONER_1).name:lower():find("summonerdot") then
		self.summoners.ignite = SUMMONER_1
		_G.ZeroConfig.menu.activate:addSubMenu("Summoner Ignite", "ignite")
		_G.ZeroConfig.menu.activate.ignite:addParam("Ignite", "Ignite Mode", SCRIPT_PARAM_LIST, 2, {"Off", "Smart"})
		for _, a in ipairs(GetEnemyHeroes()) do
			if a then
				_G.ZeroConfig.menu.activate.ignite:addParam(a.charName, "Use On " .. a.charName, SCRIPT_PARAM_ONOFF, true)
			end
		end
	elseif myHero:GetSpellData(SUMMONER_2).name:lower():find("summonerdot") then
		self.summoners.ignite = SUMMONER_2
		_G.ZeroConfig.menu.activate:addSubMenu("Summoner Ignite", "ignite")
		_G.ZeroConfig.menu.activate.ignite:addParam("Ignite", "Ignite Mode", SCRIPT_PARAM_LIST, 2, {"Off", "Smart"})
		for _, a in ipairs(GetEnemyHeroes()) do
			if a then
				_G.ZeroConfig.menu.activate.ignite:addParam(a.charName, "Use On " .. a.charName, SCRIPT_PARAM_ONOFF, true)
			end
		end
	end

	if myHero:GetSpellData(SUMMONER_1).name:lower():find("exhaust") then
		self.summoners.exhaust = SUMMONER_1
		_G.ZeroConfig.menu.activate:addSubMenu("Summoner Exhaust", "exhaust")
		_G.ZeroConfig.menu.activate.exhaust:addParam("Exhaust", "Exhaust Mode", SCRIPT_PARAM_LIST, 2, {"Off", "Smart"})
		for _, a in ipairs(GetEnemyHeroes()) do
			if a then
				_G.ZeroConfig.menu.activate.exhaust:addParam(a.charName, "Use On " .. a.charName, SCRIPT_PARAM_ONOFF, true)
			end
		end
	elseif myHero:GetSpellData(SUMMONER_2).name:lower():find("exhaust") then
		self.summoners.exhaust = SUMMONER_2
		_G.ZeroConfig.menu.activate:addSubMenu("Summoner Exhaust", "exhaust")
		_G.ZeroConfig.menu.activate.exhaust:addParam("Exhaust", "Exhaust Mode", SCRIPT_PARAM_LIST, 2, {"Off", "Smart"})
		for _, a in ipairs(GetEnemyHeroes()) do
			if a then
				_G.ZeroConfig.menu.activate.exhaust:addParam(a.charName, "Use On " .. a.charName, SCRIPT_PARAM_ONOFF, true)
			end
		end
	end

	if myHero:GetSpellData(SUMMONER_1).name:lower():find("summonersmiteduel") then
		self.summoners.smite = SUMMONER_1
		_G.ZeroConfig.menu.activate:addSubMenu("Summoner Smite", "smite")
		_G.ZeroConfig.menu.activate.smite:addParam("Smite", "Smite", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte('U'))
		--_G.ZeroConfig.menu.activate:permaShow("Smite")
		_G.ZeroConfig.menu.activate.smite:permaShow("Smite")

		_G.ZeroConfig.menu.activate.smite:addParam("Dragon", "Smite Dragons", SCRIPT_PARAM_ONOFF, true)
		_G.ZeroConfig.menu.activate.smite:addParam("Baron", "Smite Baron", SCRIPT_PARAM_ONOFF, true)
		_G.ZeroConfig.menu.activate.smite:addParam("Blue", "Smite Blue", SCRIPT_PARAM_ONOFF, true)
		_G.ZeroConfig.menu.activate.smite:addParam("Red", "Smite Red", SCRIPT_PARAM_ONOFF, true)
		
	elseif myHero:GetSpellData(SUMMONER_2).name:lower():find("summonersmiteduel") then
		self.summoners.smite = SUMMONER_2
		_G.ZeroConfig.menu.activate:addSubMenu("Summoner Smite", "smite")
		_G.ZeroConfig.menu.activate.smite:addParam("Smite", "Smite", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte('U'))
		--_G.ZeroConfig.menu.activate:permaShow("Smite")
		_G.ZeroConfig.menu.activate.smite:permaShow("Smite")

		_G.ZeroConfig.menu.activate.smite:addParam("Dragon", "Smite Dragons", SCRIPT_PARAM_ONOFF, true)
		_G.ZeroConfig.menu.activate.smite:addParam("Baron", "Smite Baron", SCRIPT_PARAM_ONOFF, true)
		_G.ZeroConfig.menu.activate.smite:addParam("Blue", "Smite Blue", SCRIPT_PARAM_ONOFF, true)
		_G.ZeroConfig.menu.activate.smite:addParam("Red", "Smite Red", SCRIPT_PARAM_ONOFF, true)
	end

	if not self.summoners.smite then
		if myHero:GetSpellData(SUMMONER_1).name:lower():find("summonersmiteplayerganker") then
			self.summoners.smite = SUMMONER_1
			_G.ZeroConfig.menu.activate:addSubMenu("Summoner Smite", "smite")
			_G.ZeroConfig.menu.activate.smite:addParam("Smite", "Smite", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte('U'))
			--_G.ZeroConfig.menu.activate:permaShow("Smite")
			_G.ZeroConfig.menu.activate.smite:permaShow("Smite")

			_G.ZeroConfig.menu.activate.smite:addParam("Dragon", "Smite Dragons", SCRIPT_PARAM_ONOFF, true)
			_G.ZeroConfig.menu.activate.smite:addParam("Baron", "Smite Baron", SCRIPT_PARAM_ONOFF, true)
			_G.ZeroConfig.menu.activate.smite:addParam("Blue", "Smite Blue", SCRIPT_PARAM_ONOFF, true)
			_G.ZeroConfig.menu.activate.smite:addParam("Red", "Smite Red", SCRIPT_PARAM_ONOFF, true)
		elseif myHero:GetSpellData(SUMMONER_2).name:lower():find("summonersmiteplayerganker") then
			self.summoners.smite = SUMMONER_2
			_G.ZeroConfig.menu.activate:addSubMenu("Summoner Smite", "smite")
			_G.ZeroConfig.menu.activate.smite:addParam("Smite", "Smite", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte('U'))
			--_G.ZeroConfig.menu.activate:permaShow("smite")
			_G.ZeroConfig.menu.activate.smite:permaShow("Smite")

			_G.ZeroConfig.menu.activate.smite:addParam("Dragon", "Smite Dragons", SCRIPT_PARAM_ONOFF, true)
			_G.ZeroConfig.menu.activate.smite:addParam("Baron", "Smite Baron", SCRIPT_PARAM_ONOFF, true)
			_G.ZeroConfig.menu.activate.smite:addParam("Blue", "Smite Blue", SCRIPT_PARAM_ONOFF, true)
			_G.ZeroConfig.menu.activate.smite:addParam("Red", "Smite Red", SCRIPT_PARAM_ONOFF, true)
		end
	end

	if not self.summoners.smite then
		if myHero:GetSpellData(SUMMONER_1).name:lower():find("summonersmite") then
			self.summoners.smite = SUMMONER_1
			_G.ZeroConfig.menu.activate:addSubMenu("Summoner Smite", "smite")
			_G.ZeroConfig.menu.activate.smite:addParam("Smite", "Smite", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte('U'))
			_G.ZeroConfig.menu.activate.smite:permaShow("Smite")

			_G.ZeroConfig.menu.activate.smite:addParam("Dragon", "Smite Dragons", SCRIPT_PARAM_ONOFF, true)
			_G.ZeroConfig.menu.activate.smite:addParam("Baron", "Smite Baron", SCRIPT_PARAM_ONOFF, true)
			_G.ZeroConfig.menu.activate.smite:addParam("Blue", "Smite Blue", SCRIPT_PARAM_ONOFF, true)
			_G.ZeroConfig.menu.activate.smite:addParam("Red", "Smite Red", SCRIPT_PARAM_ONOFF, true)
		elseif myHero:GetSpellData(SUMMONER_2).name:lower():find("summonersmite") then
			self.summoners.smite = SUMMONER_2
			_G.ZeroConfig.menu.activate:addSubMenu("Summoner Smite", "smite")
			_G.ZeroConfig.menu.activate.smite:addParam("Smite", "Smite", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte('U'))
			_G.ZeroConfig.menu.activate.smite:permaShow("Smite")

			_G.ZeroConfig.menu.activate.smite:addParam("Dragon", "Smite Dragons", SCRIPT_PARAM_ONOFF, true)
			_G.ZeroConfig.menu.activate.smite:addParam("Baron", "Smite Baron", SCRIPT_PARAM_ONOFF, true)
			_G.ZeroConfig.menu.activate.smite:addParam("Blue", "Smite Blue", SCRIPT_PARAM_ONOFF, true)
			_G.ZeroConfig.menu.activate.smite:addParam("Red", "Smite Red", SCRIPT_PARAM_ONOFF, true)
		end
	end

	DelayAction(function() AddTickCallback(function() self:Tick() end) end, 5)
	DelayAction(function() AddDrawCallback(function() self:SmiteDamageDraw() end) end, 5)

	PrintPretty("Zer0 Activator Loaded...", false, true)
end

function Activator:SmiteTick()
	if myHero and not myHero.dead and myHero.health > 0 and _G.ZeroConfig.menu.activate.smite.Smite then
		for i, jungle in pairs(self.jungleMinions.objects) do
			if jungle and jungle.health ~= jungle.maxHealth and jungle.health > 0 and not jungle.dead and myHero:GetDistance(jungle) <= 560 and ((jungle.charName == "SRU_Blue" and _G.ZeroConfig.menu.activate.smite.Blue) or (jungle.charName == "SRU_Baron" and _G.ZeroConfig.menu.activate.smite.Baron) or (jungle.charName == "SRU_Red" and _G.ZeroConfig.menu.activate.smite.Red) or (jungle.charName:find("SRU_Dragon") and _G.ZeroConfig.menu.activate.smite.Dragon)) then
				if jungle.health <= self:SmiteDmg() then
					CastSpell(self.summoners.smite, jungle)
				end
			end
		end
	end
end

function Activator:SmiteDamageDraw()
	if myHero and not myHero.dead and myHero.health > 0 and self.summoners.smite and myHero:CanUseSpell(self.summoners.smite) and _G.ZeroConfig.menu.activate.smite.Smite then
		for i, jungle in pairs(self.jungleMinions.objects) do
			if jungle and jungle.health ~= jungle.maxHealth and jungle.health > 0 and not jungle.dead and ((jungle.charName == "SRU_Blue" and _G.ZeroConfig.menu.activate.smite.Blue) or (jungle.charName == "SRU_Baron" and _G.ZeroConfig.menu.activate.smite.Baron) or (jungle.charName == "SRU_Red" and _G.ZeroConfig.menu.activate.smite.Red) or (jungle.charName:find("Dragon") and _G.ZeroConfig.menu.activate.smite.Dragon)) then
				local barPos = GetUnitHPBarPos(jungle)
				barPos.x = math.floor(barPos.x - 32)
    			barPos.y = math.floor(barPos.y - 3)
				if jungle.charName:find("Dragon") then
					barPos.x = barPos.x - 31
			        barPos.y = barPos.y - 7
				end
				if jungle.charName == "SRU_Baron" then
					barPos.x = barPos.x - 31
				end
				if jungle.health <= self:SmiteDmg() then
					DrawText("Smitable", 25, barPos.x - 40 , barPos.y - 45, ARGB(255,0,252,255))
				else
					local dmgLeft = round(((jungle.health - self:SmiteDmg()) / jungle.health) * 100, 0)
					DrawText("Killable in " .. dmgLeft .. "%", 25, barPos.x - 40 , barPos.y - 45, ARGB(255,0,252,255))
				end
			end
		end
	end
end


function Activator:SmiteDmg()
	local SmiteDamage
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

function Activator:Tick()
	--Potion checks
	--if (self.lastPotion == 0) or (os.clock() - self.lastPotion < self.potTime) then

	--end

	--self checks
	if self.summoners.heal and _G.ZeroConfig.menu.activate.heal.Heal and ((myHero.health + myHero.shield) * 100 / myHero.maxHealth) <= _G.ZeroConfig.menu.activate.heal.MyHealth and myHero:CanUseSpell(self.summoners.heal) then
		CastSpell(self.summoners.heal, myHero)
	end

	--smite checks
	if self.summoners.smite and myHero:CanUseSpell(self.summoners.smite) then
		self.jungleMinions:update()
		self:SmiteTick()
	end

	for i,v in ipairs(GetAllyHeroes()) do
		if v and ValidTarget(v) and not v.dead and v.health > 0 then
			if self.summoners.heal and _G.ZeroConfig.menu.activate.heal.Heal and _G.ZeroConfig.menu.activate.heal[v.charName] and ((v.health + v.shield) * 100 / v.maxHealth) <= _G.ZeroConfig.menu.activate.heal.AllyHealth then
				CastSpell(self.summoners.heal, v)
			end
		end
	end

	for i,v in ipairs(GetEnemyHeroes()) do
		if v and ValidTarget(v) and not v.dead and v.health > 0 then
			--Ignite Checks
			if self.summoners.ignite and ((v.health + v.shield) * 100 / v.maxHealth) <= 40 + (20 * myHero.level) and v:GetDistance(myHero) <= 600 then
				CastSpell(self.summoners.ignite, v)
			end
		end
	end
end

class("ZAware")
function ZAware:__init()
	self.ready = false
	_G.ZeroConfig.menu:addSubMenu("Awareness", "aware")
		_G.ZeroConfig.menu.aware:addParam("tower", "Draw Tower Range", SCRIPT_PARAM_ONOFF, true)
		_G.ZeroConfig.menu.aware:addParam("gank", "Draw Gank Alerts", SCRIPT_PARAM_ONOFF, true)
		_G.ZeroConfig.menu.aware:addParam("path", "Draw Enemy Paths", SCRIPT_PARAM_ONOFF, true)
	self.wardTracker = WardTracker()
	PrintPretty("Zer0 Awareness Loaded...", false, true)
	DelayAction(function() AddDrawCallback(function() self:OnDraw() end) end, 5)
	self.ready = true
end

function ZAware:OnDraw()
	if not self.ready then return end
	self.wardTracker:Draw()
	if _G.ZeroConfig.menu.aware.gank or _G.ZeroConfig.menu.aware.path then
		local gankAlert = nil
		for _, enemy in ipairs(GetEnemyHeroes()) do
			if enemy and not enemy.dead and enemy.health > 0 and myHero.hasMovePath and enemy.isMoving then
				stepNum = 1
				iPaths = enemy.pathCount
				myLastStep = nil
				for i=enemy.pathIndex, iPaths do
					path = enemy:GetPath(i)
					if GetDistance(path, myHero.pos) < 1000 and not enemy.visible then
						gankAlert = enemy
					end
					if _G.ZeroConfig.menu.aware.path then
						sPos = WorldToScreen(D3DXVECTOR3(path.x, path.y, path.z))
						if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
							DrawCircle(path.x, path.y, path.z, 100, ARGB(255, 255, 255, 255))
							DrawText(enemy.charName .. "["..stepNum.."]", 15, sPos.x - 20, sPos.y, ARGB(150,255,255,255))
							if myLastStep ~= nil then
								 DrawLine3D(path.x,path.y,path.z, myLastStep.x,myLastStep.y,myLastStep.z,2, RGB(66,208,255))
							else
								DrawLine3D(path.x,path.y,path.z, enemy.x,enemy.y,enemy.z,2, RGB(66,208,255))
							end
							myLastStep = path
							stepNum = stepNum + 1
						end
					end
				end
			end
		end

		if _G.ZeroConfig.menu.aware.gank then
			if gankAlert ~= nil then
				DrawText("Approaching Champion: " .. gankAlert.charName .. "[D:" .. GetDistance(gankAlert, myHero) .. "]", 25, 60, 60, ARGB(150,255,255,255))
			end
		end
	end

	if _G.ZeroConfig.menu.aware.tower then
		for _,tower in pairs(GetTurrets()) do
			if tower.object and tower.object.team ~= myHero.team and GetDistance(tower.object) < 1700 then
				DrawCircle3D(tower.object.x, tower.object.y, tower.object.z, 875, 4, ARGB(80, 32,178,100), 52)
			end
		end
	end
end

class("WardTracker")
function WardTracker:__init()
	self.eWardPositions = {}
	_G.ZeroConfig.menu.aware:addParam("trackwards", "Track Wards", SCRIPT_PARAM_ONOFF, true)
end

function WardTracker:OnCreateObj(obj)
	if obj and obj.team ~= myHero.team and obj.name == "TrinketTotemLvl1" or obj.name == "VisionWard" or obj.name == "TrinketOrbLvl3" or obj.name == "ItemGhostWard" or obj.name == "SightWard" then
		wardTimer = GetGameTimer() + 180
		self.eWardPositions[wardTimer] = obj
	end
end

function WardTracker:OnDeleteObj(obj)
	if obj and obj.team ~= myHero.team and obj.name == "TrinketTotemLvl1" or obj.name == "VisionWard" or obj.name == "TrinketOrbLvl3" or obj.name == "ItemGhostWard" or obj.name == "SightWard" then
		for time, ward in pairs(self.eWardPositions) do
			if obj == ward then
				self.eWardPositions[time] = nil
			end
		end
	end
end

function WardTracker:Draw()
	if wardPos ~= nil then
		for time, spots in pairs(wardPos) do
			--@TODO
			if time < os.clock() then
				DrawCircle3D(spots.x, spots.y, spots.z, 90, 4, ARGB(80, 32,178,100), 52)
			else
				wardPos[time] = nil
			end
		end
	end
end

class("AutoLeveler")
function AutoLeveler:__init(order)
	self.humanMin = 1
	self.humanMax = 3

	if order then
		self.order = order
		self.cLevel = myHero.level
		AddTickCallback(function() self:OnTick() end)
	end
end

function AutoLeveler:OnTick()
	if not self.order or not self.cLevel then return end
	if myHero.level > self.cLevel then
		if self.humanMax == 0 then
			LevelSpell(self.order)
		else
			DelayAction(function() LevelSpell(self.order) end, math.random(self.humanMin, self.humanMax))
		end
	end
end

class("Misc")
function Misc:__init()
	PrintPretty("Zer0 Misc Tools Loaded...", false, true)
	_G.ZeroConfig.menu:addSubMenu("Misc", "misc")
		_G.ZeroConfig.menu.misc:addParam("masterySpam", "Show Mastery On Kill", SCRIPT_PARAM_ONOFF, true)

	self.myInfo = {
		kills = 0,
		assists = 0
	}
end

function Misc:OnAnimation(hero, anim)
	if hero.team ~= myHero.team and hero.type == myHero.type and animation == "Death" and _G.ZeroConfig.menu.misc.masterySpam then
		if self.myInfo.kills ~= myHero.kills or self.myInfo.assists ~= myHero.assists then
			DelayAction(function() SendChat("/masterybadge") end, math.random(100, 300)/1000)
			self.myInfo.kills = myHero.kills
			self.myInfo.assists = myHero.assists
		end
	elseif hero.team ~= myHero.team and hero.type == myHero.type and animation == "Death" and not _G.ZeroConfig.menu.misc.masterySpam then
		self.myInfo.kills = myHero.kills
		self.myInfo.assists = myHero.assists
	end
end

--Utility

function GetItemSlot(itemName)
	local slot = nil
	if itemName ~= nil then
		for i=0, 12 do
			if string.lower(myHero:GetSpellData(i).name) == string.lower(name) then
				slot = i
				break
			end
		end
	end
	if (slot ~= nil) then
		return slot
	end
	return nil
end

function GetEnemySpellList()
	for i = 1, heroManager.iCount,1 do
		local hero = heroManager:getHero(i)
		if hero.team ~= player.team then
			if Champions[hero.charName] ~= nil then

			end
		end
	end
end

function CountEnemyInRange(range, from)
	if not range or not from then return 0 end
	local inRange = 0
	for _, e in ipairs(GetEnemyHeroes()) do
		if e and e.health > 0 and not e.dead and from:GetDistance(e) <= range then
			inRange = inRange + 1
		end
	end
	return inRange
end

function CountAllyInRange(range, from)
	if not range or not from then return 0 end
	local inRange = 0
	for _, e in ipairs(GetAllyHeroes()) do
		if e and e.health > 0 and not e.dead and from:GetDistance(e) <= range then
			inRange = inRange + 1
		end
	end
	return inRange
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
      if GetDistance(pos, object) <= radius then
        n = n + 1
      end
    end
    return n
end

function UnitIsFleeingFrom(unit, source)
	if not unit or unit.dead or unit.health < 0 then
		return false
	end

	if not source or source.dead or source.health <= 0 then
		return false
	end

	if unit.path.count > 1 then
		currPath = unit.path:Path(1)
		if currPath then
			if GetDistance(source, currPath) > GetDistance(source, unit) then
				return true
			end
		end
	end
end

function UnitIsFleeingMe(unit)
	if not unit or unit.dead or unit.health < 0 then
		return false
	end

	if not meHero or meHero.dead or meHero.health <= 0 then
		return false
	end

	if unit.path.count > 1 then
		currPath = unit.path:Path(1)
		if currPath then
			if GetDistance(meHero, currPath) > GetDistance(meHero, unit) then
				return true
			end
		end
	end
end

function CanWeSeeThis(point)
	local i = WorldToScreen(D3DXVECTOR3(spot.x, spot.y, spot.z))
	if (x > 0 and x < WINDOW_W) and (y > 0 and y < WINDOW_H) then
		return true
	end
	return false
end

function CalcMR(unit, target) --Credit: Roach
	if BaseMR[target.charName] then
		local bonusMagicPenPercent = unit:getItem(3135) and 0.65 or 1
		local baseMR = BaseMR[target.charName].Base + (BaseMR[target.charName].PerLevel * (target.level - 1))
		local bonusMR = target.magicArmor - baseMR
		
		return 100 / (100 + (((bonusMR * bonusMagicPenPercent) + baseMR) * unit.magicPenPercent) - unit.magicPen)
	end
	
	return 100 / (100 + ((target.magicArmor * unit.magicPenPercent) - unit.magicPen))
end

function CalcArmor(unit, target) --Credit: PewPewPew
	if BaseArmor[target.charName] then
		local ids, bonusArmorPenPercent = {[3035]=.7, [3033]=.55, [3036]=.55}, 1
		for i=ITEM_1, ITEM_6 do
			local item = unit:getItem(i)
			if item and ids[item.id] then
				bonusArmorPenPercent = ids[item.id]
				break
			end
		end
		local baseArmor = BaseArmor[target.charName].Base + (BaseArmor[target.charName].PerLvl * (target.level - 1))
		local bonusArmor = target.armor - baseArmor
		
		return 100 / (100 + (((bonusArmor * bonusArmorPenPercent) + baseArmor) * unit.armorPenPercent) - unit.armorPen)
	end
	return 100 / (100 + ((target.armor * unit.armorPenPercent) - unit.armorPen))
end

function IsHeroAboveHPPercent(hero, percent)
	if hero.health > 0 and percent >= (hero.health/hero.maxHealth) * 100 then
		return true
	end
	return false
end

function IsHeroBelowHPPercent(hero, percent)
	if hero.health > 0 and percent <= (hero.health/hero.maxHealth) * 100 then
		return true
	end
	return false
end

function IsHeroAboveManaPercent(hero, percent)
	if hero.mana > 0 and percent >= (hero.mana/hero.maxMana) * 100 then
		return true
	end
	return false
end

function IsHeroBelowManaPercent(hero, percent)
	if hero.mana > 0 and percent <= (hero.mana/hero.maxMana) * 100 then
		return true
	end
	return false
end

function DoYouEvenExtend(sP, eP, add, max, min)
	local s1x, s1y, s1z = sP.x, sP.y, sP.z
	local dx, dy, dz = eP.x - s1x, eP.y - s1y, eP.z - s1z
	local d = dx * dx + dy * dy + dz * dz
	local d = add and math.max(max or 0, math.min(min or math.huge, d + add)) or math.max(max or 0, math.min(min or math.huge, d))
	return Vector(s1x + dx * d, s1y + dy * d, s1z * dz * d)
end

--Display
antiSpamLastMessage = nil
function PrintPretty(message, debug, antiSpam)
	if debug and not _G.ZeroConfig.shouldWeDebug then return end

	if antiSpam and antiSpamLastMessage ~= nil and antiSpamLastMessage == message then return end

	fontColor = "3393FF"
	if debug then fontColor = "EC33FF" end

	print("<font color=\"#FF5733\">[<u>" .. _G.ZeroConfig.scriptName .. "</u>]</font> <font color=\"#" .. fontColor .. "\">" .. message .. "</font>")
	antiSpamLastMessage = message
end

--Dash Detection
function OnNewPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance)
	if unit.type == myHero.type and unit.team ~= myHero.team and isDash and GetDistance(endPos, myHero.pos) <= 850 then
		if _G.ZeroConfig.printEnemyDashes then
			PrintPretty("Unit [" .. unit.charName .. "] Dash Detected [S:" .. dashSpeed .. "] [G:"..dashGravity.."] [D:"..dashDistance.."]", false, true)
		end
	end
end

function OnLoad()
	PrintPretty("Zer0 Bundle Loading....", false, true)

	_G.DataStore.ChampionL = ChampionLoader()

	_G.ZeroConfig.menu = scriptConfig("Zer0 Bundle", "003data")

	_G.ZeroConfig.menu:addParam("awareness", "Zer0 Awareness**", SCRIPT_PARAM_ONOFF, false)
	_G.ZeroConfig.menu:addParam("activator", "Zer0 Activator**", SCRIPT_PARAM_ONOFF, false)
	_G.ZeroConfig.menu:addParam("autoLevel", "Zer0 Auto-Level**", SCRIPT_PARAM_ONOFF, false)
	_G.ZeroConfig.menu:addParam("misc", "Zer0 Misc**", SCRIPT_PARAM_ONOFF, false)

	if _G.ZeroConfig.menu.awareness then
		ZAware()
	end

	if _G.ZeroConfig.menu.activator then
		Activator()
	end

	if _G.ZeroConfig.menu.misc then
		Misc()
	end

	if _G.DataStore.ChampionL ~= nil and _G.DataStore.ChampionL:CanUseChamp() then
		_G.ZeroConfig.menu:addParam(myHero.charName, "Zer0 " .. myHero.charName, SCRIPT_PARAM_ONOFF, false)
		if _G.ZeroConfig.menu[myHero.charName] then
			if not _G.UPLloaded then
				if FileExist(LIB_PATH .. "/UPL.lua") then
					require("UPL")
					_G.UPL = UPL()
					UPL:AddToMenu(_G.ZeroConfig.menu)
					PrintPretty("UPL Loaded.", false, true)
				else 
					PrintPretty("Downloading UPL please do not press F9.", false, true)
					DelayAction(function() DownloadFile("https://raw.github.com/nebelwolfi/BoL/master/Common/UPL.lua".."?rand="..math.random(1,10000), LIB_PATH.."UPL.lua", function () PrintPretty("Successfully downloaded UPL. Press F9 twice.", false, true) end) end, 3)
					return
				end
			end

			if not _G.UOLloaded then
				if FileExist(LIB_PATH .. "/UOL.lua") then
					require("UOL")
					UOL:AddToMenu(scriptConfig("OrbWalker", "OrbWalker"))
					PrintPretty("UOL Loaded.", false, true)
				else 
					PrintPretty("Downloading UOL please do not press F9.", false, true)
					DelayAction(function() DownloadFile("https://raw.github.com/nebelwolfi/BoL/master/Common/UOL.lua".."?rand="..math.random(1,10000), LIB_PATH.."UOL.lua", function () PrintPretty("Successfully downloaded UOL. Press F9 twice.", false, true) end) end, 10)
					return
				end
			end

			PrintPretty("Loading Zer0 " .. myHero.charName, false, true)
			_G.DataStore.Champion = _G.DataStore.ChampionL:GetChampO()
			if _G.DataStore.Champion ~= nil then
				PrintPretty("Loaded Zer0 " .. myHero.charName .. " [v" .. _G.DataStore.Champion.ver .. "]...", false, true)
			end
		end
	end

	_G.ZeroConfig.menu:addParam("spacer", "", SCRIPT_PARAM_INFO, "")
	_G.ZeroConfig.menu:addParam("spacera", "If you enable a option please", SCRIPT_PARAM_INFO, "")
	_G.ZeroConfig.menu:addParam("spacera", "double F9 to reload.", SCRIPT_PARAM_INFO, "")
	_G.ZeroConfig.menu:addParam("spacerb", "** Means Beta", SCRIPT_PARAM_INFO, "")

	PrintPretty("Zer0 Bundle Loaded....", false, true)
end



function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end