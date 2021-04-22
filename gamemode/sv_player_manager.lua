function GM:PlayerInitialSpawn(ply)
	if self:GetRoundStatus() == GAME_ACTIVE then
		ply:SetTeam(TEAM_SPECTATOR)
	end
end

function GM:PlayerSpawn(ply)
	ply:StripWeapons()
	ply:RemoveAllAmmo()
	ply:SprintDisable()
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
		ply:AllowFlashlight(true)
	end
	
	ply:Give("weapon_bl_hands")
	
	self:RoundCheck()
end

function GM:CanPlayerSuicide(ply)
	return false
end

function GM:PlayerDisconnected(ply)
	ply:SetTeam(0)
	table.RemoveByValue(activePlayers, ply)
	if team.NumPlayers(TEAM_VAMPIRE) < 1 and team.NumPlayers(TEAM_GHOUL) < 1 then
		self:BroadcastMessage(Color(255, 210, 150), "The vampires fled")
		self:RoundEnd(GAME_ABORT)
	end
	
	
	self:RoundCheck()
end

local function CreateRagdollBody(ply, team)
	local ragdoll = ents.Create("prop_ragdoll")
	ragdoll:SetModel(ply:GetModel())
	ragdoll:SetPos(ply:GetPos())
	ragdoll:SetAngles(ply:GetAngles())
	ragdoll:Spawn()
	
	timer.Simple(0.1, function()
		net.Start("bl_clientragdoll")
			net.WriteEntity(ragdoll)
		net.Send(ply)
	end)
	
	ragdoll.blood = 40
	ragdoll.team = team
	ragdoll.player = ply
	
	ply.body = ragdoll
end

local RESTRICT_VAMPIRE = {
	["weapon_crossbow"] = true,
	["weapon_bl_stake"] = true
	
}

function GM:PlayerCanPickupWeapon(ply, weapon)
	if (ply:Team() == TEAM_VAMPIRE or ply:Team() == TEAM_GHOUL) and RESTRICT_VAMPIRE[weapon] then return false end
	
	if (ply:Team() == TEAM_HUMAN and ply:Team() == TEAM_HUNTER) and ply.cooldown >= CurTime() then return false end
	
	return true
end

function GM:DoPlayerDeath(ply, att, dmgInfo)
	CreateRagdollBody(ply, ply:Team())

	if (ply:Team() == TEAM_VAMPIRE or ply:Team() == TEAM_GHOUL) then
		
		if att:GetActiveWeapon():GetClass() == "weapon_crossbow" then
			
			if string.find(ply:GetModel(), "female") then
				ply:EmitSound("bloodlust/vampirefemaledeath.wav")
			else
				ply:EmitSound("bloodlust/vampiremaledeath.wav")
			end
	
			ply:Freeze(true)
			ply.body:Ignite(6, 0)
			
			timer.Simple(13, function()
				ply:Freeze(false)
			end)
			
			ply:SetTeam(TEAM_SPECTATOR)	
		else
			ply:Freeze(true)
			local resurrectPos = ply.body:GetPos()
			timer.Create("bl_resurrect", 10, 1, function()
				if ply:Team() == TEAM_SPECTATOR or not IsValid(ply.body) then return end
				ply:Spawn()
				ply:SetPos(resurrectPos)
				if string.find(ply:GetModel(), "female") then
					ply:EmitSound("bloodlust/resurrectfemale.wav")
				else
					ply:EmitSound("bloodlust/resurrectmale.wav")
				end
				ply.body:Remove()
				
				timer.Simple(0.1, function()
					ply:Freeze(false)
					ply:Give("weapon_bl_fangs")
				end)
			end)
			return
		end
	elseif ply:Team() == TEAM_HUMAN and ply.killer then		
		ply:Freeze(true)
		local resurrectPos = ply.body:GetPos()
		ply:SetTeam(TEAM_GHOUL)
		
		timer.Simple(12, function()
			ply:ChatPrint("You are now a ghoul")
			ply:Spawn()
			ply:SetPos(resurrectPos)
			ply:Freeze(false)
			if ply.body then
				ply.body:Remove()
			end
			
			timer.Simple(0.1, function()
				ply:Give("weapon_bl_fangs")
			end)
		end)
	elseif ply:Team() == TEAM_HUMAN and att and att:IsPlayer() and (att:Team() == TEAM_HUNTER or att:Team() == TEAM_HUMAN) then
		
		for _, wep in pairs(att:GetWeapons()) do
			if wep:GetClass() == "weapon_bl_hands" then continue end
			att:DropWeapon(wep)
			att.cooldown = CurTime() + 15
			print(att.cooldown)
		end
		
		ply:SetTeam(TEAM_SPECTATOR)
	elseif not att then
		ply:SetTeam(TEAM_SPECTATOR)
	end
	
	net.Start("bl_playerdeath")
	net.Send(ply)
	
	self:RoundCheck()

end

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