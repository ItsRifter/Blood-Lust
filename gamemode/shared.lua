GM.Name = "Blood Lust"
GM.Author = "SuperSponer"
GM.Email = "d_thomas_smith30@hotmail.com"
GM.Website = "N/A"

include("sh_round_manager.lua")
AddCSLuaFile("sh_round_manager.lua")

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
GM.ConVars.MaxRounds = CreateConVar("bl_maxrounds", 6, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Rounds until a map change")
GM.ConVars.TimeLimit = CreateConVar("bl_timelimit", 360, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Time before sun rise")
GM.ConVars.VampireCount = CreateConVar("bl_vampcount", 2, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Initial vampires per round", 1, 2)
GM.ConVars.HunterCount = CreateConVar("bl_huntcount", 2, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Initial hunters per round", 1, 2)
GM.ConVars.MinHunters = CreateConVar("bl_minhunters", 6, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Minimum players needed for more hunters", 1)
GM.ConVars.MinVampires = CreateConVar("bl_minvampires", 5, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Minimum players needed for more vampires", 1)

