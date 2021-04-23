AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_hud.lua")

include("shared.lua")
include("sv_player_manager.lua")
include("sv_server_cmds.lua")
include("sv_resource.lua")

util.AddNetworkString("bl_messagesay")
util.AddNetworkString("bl_playsound")
util.AddNetworkString("bl_roundstart")
util.AddNetworkString("bl_playerdeath")
util.AddNetworkString("bl_clientragdoll")

function GM:BroadcastMessage(...)
	
	if table.HasValue(..., ply) then
		net.Start("bl_messagesay")
			net.WriteTable({...})
		net.Send(ply)
	else
		net.Start("bl_messagesay")
			net.WriteTable({...})
		net.Broadcast()
	end
end

function GM:BroadcastSound(soundPath, ply)
	if ply then
		net.Start("bl_playsound")
			net.WriteString(soundPath)
		net.Broadcast(ply)
	else
		net.Start("bl_playsound")
			net.WriteString(soundPath)
		net.Broadcast()
	end
end