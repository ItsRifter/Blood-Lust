function GM:PlayerInitialSpawn(ply)
	if self:GetRoundStatus() == GAME_ACTIVE then
		ply:SetTeam(TEAM_SPECTATOR)
	end
end

function GM:PlayerSpawn(ply)
	ply:StripWeapons()
	ply:RemoveAllAmmo()
	
	if self.GameState == GAME_PREROUND or self.GameState == GAME_POSTROUND then
		if math.random(0, 1) == 0 then
			ply:SetModel("models/player/group01/female_0" .. math.random(6) .. ".mdl")
		else
			ply:SetModel("models/player/group01/male_0" .. math.random(9) .. ".mdl")
		end
	end

	if ply:Team() == TEAM_SPECTATOR then
		ply:Spectate(OBS_MODE_IN_EYE)
		ply:SetNoDraw(true)
		ply:AllowFlashlight(false)
	else
		ply:UnSpectate()
	end
	
	ply:Give("bl_hands")
	
	self:RoundCheck()
end

function GM:CanPlayerSuicide(ply)
	return false
end

function GM:PlayerDisconnected(ply)
	ply:SetTeam(0)
	if (ply:Team() == TEAM_VAMPIRE and team.NumPlayers(TEAM_VAMPIRE) < 1) or (ply:Team() == TEAM_GHOUL and team.NumPlayers(TEAM_GHOUL) < 1) then
		self:BroadcastMessage(Color(255, 210, 150), "The vampires fled")
		self:EndRound(GAME_ABORT)
	end
	table.RemoveByValue(activePlayers, ply)
	self:RoundCheck()
end

function GM:DoPlayerDeath(ply, att, dmgInfo)
	if att:IsPlayer() then
		net.Start("bl_playerdeath")
			net.WriteString(att:Nick())
			net.WriteInt(att:Team(), 4)
			net.WriteInt(ply:Team(), 4)
		net.Send(ply)
	else
		net.Start("bl_playerdeath")
			net.WriteString("Suicide")
			net.WriteInt(5, 4)
			net.WriteInt(ply:Team(), 4)
		net.Send(ply)
	end
	ply:CreateRagdoll()
	
	if ply:Team() == TEAM_VAMPIRE and att and att:IsPlayer() and att:GetActiveWeapon():GetClass() == "weapon_crossbow" then
		ply:SetTeam(TEAM_SPECTATOR)
		ply:GetRagdollEntity():Ignite(6, 0)
	elseif ply:Team() == TEAM_VAMPIRE then
		local resurrectPos = ply:GetPos()
		timer.Create("bl_resurrect", 8, 1, function()
			ply:Spawn()
			ply:SetPos(resurrectPos)
		end)
	elseif ply:Team() == TEAM_HUMAN and (att and att:IsPlayer() and att:Team() == TEAM_VAMPIRE) then
		ply:Lock()
		local resurrectPos = ply:GetPos()
		for _, wep in pairs(ply:GetWeapons()) do
			if wep:GetClass() == "bl_hands" then break end
			ply:DropWeapon(wep)
		end
		ply:SetTeam(TEAM_GHOUL)
		timer.Simple(11, function()
			
			ply:ChatPrint("You are now a ghoul")
			ply:Spawn()
			ply:SetPos(resurrectPos)
			ply:UnLock()
			ply:Give("weapon_crowbar")
		end)
	elseif ply:Team() == TEAM_HUMAN and (att:IsPlayer() and att:Team() == TEAM_HUNTER) then
		for _, wep in pairs(att:GetWeapons()) do
			if wep:GetClass() == "bl_hands" then continue end
			att:DropWeapon(wep)
		end
		ply:SetTeam(TEAM_SPECTATOR)
	else
		ply:SetTeam(TEAM_SPECTATOR)
	end
	
	self:RoundCheck()
end

function GM:PlayerShouldTakeDamage(ply, att)
	if ply:Team() == TEAM_VAMPIRE and (att:IsPlayer() and att:Team() == TEAM_VAMPIRE) then
		return false
	elseif ply:Team() == TEAM_GHOUL and (att:IsPlayer() and att:Team() == TEAM_GHOUL) then
		return false
	elseif ply:Team() == TEAM_VAMPIRE and (att:IsPlayer() and att:Team() == TEAM_GHOUL) then
		return false
	elseif ply:Team() == TEAM_GHOUL and (att:IsPlayer() and att:Team() == TEAM_VAMPIRE) then
		return false
	end
		
	return true
end

local activePlayers = {}

local specEnt = 1
hook.Add("KeyPress", "SpecKey", function(ply, key)
	if ply:Team() ~= TEAM_SPECTATOR then return end
	if #activePlayers <= 0 then return end
	
	if ply:KeyPressed(IN_ATTACK) then
		specEnt = specEnt + 1
		if specEnt > #activePlayers then
			specEnt = 1
		end
		if activePlayers[specEnt]:Alive() then
			ply:SpectateEntity(activePlayers[specEnt])
		else
			specEnt = specEnt + 1
		end
	elseif ply:KeyPressed(IN_ATTACK2) then
		specEnt = specEnt - 1
		if specEnt < 1 then
			specEnt = #activePlayers
		end
		if activePlayers[specEnt]:Alive() then
			ply:SpectateEntity(activePlayers[specEnt])
		else
			specEnt = specEnt - 1
		end
		ply:SpectateEntity(activePlayers[specEnt])
	end
end)