concommand.Add("bl_debug", function(ply)
	if not ply:IsValid() then return end
	
	net.Start("bl_roundstart")
		net.WriteInt(ply:Team(), 8)
		net.WriteString("None")
	net.Send(ply)

end)

concommand.Add("bl_restart", function(ply)
	if ply:IsValid() then return end
	
	GAMEMODE:RoundEnd(GAME_RESTART)
end)

concommand.Add("bl_check", function(ply)
	if ply:IsValid() then return end
	
	GAMEMODE:RoundCheck()
end)

concommand.Add("bl_state", function(ply)
	if ply:IsValid() then return end
	
	print(GAMEMODE:GetRoundStatus())
end)

concommand.Add("bl_teams", function(ply)
	if ply:IsValid() then return end
	for _, pl in pairs(player.GetAll()) do
		print(pl:Nick() .. ": " .. pl:Team())
	end
end)

concommand.Add("bl_check", function(ply)
	if ply:IsValid() then return end
	GAMEMODE:RoundCheck()
end)

concommand.Add("bl_time", function(ply)
	if ply:IsValid() then return end
	if timer.Exists("bl_roundtimer") then
		print(timer.TimeLeft("bl_roundtimer"))
	else
		print("NO TIMER")
	end
end)