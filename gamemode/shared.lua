GM.Name = "Blood Lust"
GM.Author = "SuperSponer"
GM.Email = "d_thomas_smith30@hotmail.com"
GM.Website = "N/A"

include("sh_round_manager.lua")
include("sh_translate.lua")

--DO NOT EDIT THIS
GM.Version = "0.2"

function GM:CreateTeams()	
	TEAM_HUMAN = 1
	team.SetUp(TEAM_HUMAN, "Human", Color(255, 214, 163, 255))

	TEAM_VAMPIRE = 2
	team.SetUp(TEAM_VAMPIRE, "Vampire", Color(255, 214, 163, 255))

	TEAM_GHOUL = 3
	team.SetUp(TEAM_GHOUL, "Ghoul", Color(255, 214, 163, 255))

	TEAM_HUNTER = 4
	team.SetUp(TEAM_HUNTER, "Hunter", Color(255, 214, 163, 255))

	team.SetUp(TEAM_SPECTATOR, "Spectator") 
end

GM.ConVars = GM.ConVars or {}
--Player Convars
GM.ConVars.PistolMax = CreateConVar("bl_maxpistol", 21, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "How much players can hold pistol ammo", 1)
GM.ConVars.BuckshotMax = CreateConVar("bl_maxbuckshot", 16, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "How much players can hold shotgun ammo", 1)
GM.ConVars.RifleMax = CreateConVar("bl_maxrifle", 20, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "How much players can hold rifle ammo", 1)
GM.ConVars.ResTime = CreateConVar("bl_restime", 9, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "How much time in seconds do the undead resurrect", 1)
GM.ConVars.TurnTime = CreateConVar("bl_turntime", 12, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "How much time in seconds do humans turn into ghouls", 1)
--Round Convars
GM.ConVars.MaxRounds = CreateConVar("bl_maxrounds", 6, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Rounds until a map change")
GM.ConVars.TimeLimit = CreateConVar("bl_timelimit", 360, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Time before sun rise")
--Team Convars
GM.ConVars.VampireCount = CreateConVar("bl_vampcount", 2, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Initial vampires per round", 1, 2)
GM.ConVars.HunterCount = CreateConVar("bl_huntcount", 2, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Initial hunters per round", 1, 2)
GM.ConVars.MinHunters = CreateConVar("bl_minhunters", 6, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Minimum players needed for more hunters", 1)
GM.ConVars.MinVampires = CreateConVar("bl_minvampires", 5, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Minimum players needed for more vampires", 1)
--Special Round Convars
GM.ConVars.SpecialChance = CreateConVar("bl_specialchance", 65, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "The chance of a special round")