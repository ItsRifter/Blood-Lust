local MALE_NAMES = {
	"Jeff",
	"David",
	"Johnny"
}

local FEMALE_NAMES = {
	"Catherine",
	"Kate",
	"Lisa"
}

function GM:PlayerInitialSpawn(ply)
	if self:GetRoundStatus() == GAME_ACTIVE then
		ply:SetTeam(TEAM_SPECTATOR) 
		ply:Spectate(OBS_MODE_IN_EYE)
	end
	self:RoundCheck()
end
function GM:PlayerSpawn(ply)	
	if ply:Team() == TEAM_SPECTATOR then
		ply:Spectate(OBS_MODE_IN_EYE)
	end
	ply:StripWeapons()
	ply:RemoveAllAmmo()
	ply:SetRunSpeed(300)
	if self.GameState == GAME_PREROUND or self.GameState == GAME_POSTROUND then
		if math.random(0, 1) == 0 then
			ply:SetModel("models/player/group01/female_0" .. math.random(6) .. ".mdl")
			ply.Name = FEMALE_NAMES[math.random(#FEMALE_NAMES)]
		else
			ply:SetModel("models/player/group01/male_0" .. math.random(9) .. ".mdl")
			ply.Name = MALE_NAMES[math.random(#MALE_NAMES)]
		end
	end
	
	ply:SetCanZoom(false)
	ply:AllowFlashlight(true)
	
	ply:Give("weapon_bl_hands")
end

function GM:CanPlayerSuicide(ply)
	return false
end

function GM:PlayerDisconnected(ply)
	ply:SetTeam(0)
	table.RemoveByValue(GAMEMODE.ActivePlayers, ply)
	if team.NumPlayers(TEAM_VAMPIRE) < 1 and team.NumPlayers(TEAM_GHOUL) < 1 then
		self:RoundEnd(GAME_ABORT)
		return
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
	
	return ragdoll
end

local RESTRICT_VAMPIRE = {
	["weapon_crossbow"] = true
	
}
local waitNextUse = 0
function GM:PlayerUse(ply, ent)
	if not ply:Alive() then return end
	
	if waitNextUse > CurTime() then return end
	if ent and ent and ent:GetClass() == "prop_ragdoll" and ent.player then
		GAMEMODE:BroadcastMessage(Color(255, 255, 255), "Here Lies " .. ent.player:Nick(), ply)
		waitNextUse = CurTime() + 3
	end
end

local RESTRICT_DROPPING = {
	["weapon_bl_hands"] = true,
	["weapon_bl_fangs"] = true
}

function GM:KeyPress( ply, key )
	if key == IN_ZOOM then
		if RESTRICT_DROPPING[ply:GetActiveWeapon():GetClass()] then 
			return
		else
			ply:DropWeapon(ply:GetActiveWeapon())
		end
	end
end
function GM:PlayerCanPickupWeapon(ply, weapon)
	if (ply:Team() == TEAM_VAMPIRE or ply:Team() == TEAM_GHOUL) and RESTRICT_VAMPIRE[weapon:GetClass()] then return false end
	
	if ply:HasWeapon(weapon:GetClass()) then return false end
	return true
end

function BeginResurrection(ply, body)
	ply:Lock()
	timer.Create("bl_resurrect", GAMEMODE.ConVars.ResTime:GetInt(), 1, function()
		if GAMEMODE:GetRoundStatus() ~= GAME_ACTIVE then return end
		if (ply:Team() == TEAM_VAMPIRE or ply:Team() == TEAM_GHOUL) then
			if string.find(ply:GetModel(), "female") then
				body:EmitSound("bloodlust/resurrectfemale.wav", 150, 100)
			else
				body:EmitSound("bloodlust/resurrectmale.wav", 150, 100)
			end
			ply:Spawn()
			ply:UnLock()
			ply:SetHealth(20)
			timer.Simple(0.1, function()
				ply:SetPos(body:GetPos())
				ply:Give("weapon_bl_fangs")
				body:Remove()
			end)
		end
	end)
end

function BeginTransformation(ply, body)
	ply:Lock()
	timer.Create("bl_transform", GAMEMODE.ConVars.TurnTime:GetInt(), 1, function()
		if GAMEMODE:GetRoundStatus() ~= GAME_ACTIVE then return end
		
		ply:SetTeam(TEAM_GHOUL)
		ply:Spawn()
		
		timer.Simple(0.1, function()
			ply:SetPos(body:GetPos())
			ply:Give("weapon_bl_fangs")
			body:Remove()
			ply:UnLock()
		end)
		GAMEMODE:RoundCheck()
	end)
end

function CancelRespawn(ply)
	timer.Remove("bl_resurrect")
	timer.Remove("bl_transform")
end

hook.Add("Tick", "bl_ammocheck", function()
	for k, pl in pairs(player.GetAll()) do
		
		if pl:GetAmmoCount(3) >= GAMEMODE.ConVars.PistolMax:GetInt() then
			pl:SetAmmo(GAMEMODE.ConVars.PistolMax:GetInt(), 3)
		end
		
		if pl:GetAmmoCount(7) >= GAMEMODE.ConVars.BuckshotMax:GetInt() then
			pl:SetAmmo(GAMEMODE.ConVars.BuckshotMax:GetInt(), 7)
		end
		
		if pl:GetAmmoCount(5) >= GAMEMODE.ConVars.RifleMax:GetInt() then
			pl:SetAmmo(GAMEMODE.ConVars.RifleMax:GetInt(), 5)
		end
	end
end)

local function AmmoCheck(ply, ammo)
	--Colt/Pistol ammo
	if ammo:GetClass() == "item_ammo_pistol" and ply:GetAmmoCount(3) >= GAMEMODE.ConVars.PistolMax:GetInt() then
		return false
	end
	
	--Buckshot/Shotgun ammo
	if ammo:GetClass() == "item_box_buckshot" and ply:GetAmmoCount(7) >= GAMEMODE.ConVars.BuckshotMax:GetInt() then
		return false
	end
	
	--Rifle/357 ammo
	if ammo:GetClass() == "item_ammo_357_large" and ply:GetAmmoCount(5) >= GAMEMODE.ConVars.RifleMax:GetInt() then
		return false
	end
	
	return true
end


function GM:PlayerCanPickupItem(ply, item)
	return AmmoCheck(ply, item)
end

local NO_DEATH_DROP_WEPS = {
	["weapon_bl_fangs"] = true
}

function GM:DoPlayerDeath(ply, att, dmgInfo)
	
	ply.body = CreateRagdollBody(ply, ply:Team())
	ply:Flashlight(false)
	ply:AllowFlashlight(false)
	
	for _, wep in pairs(ply:GetWeapons()) do
		if NO_DEATH_DROP_WEPS[wep:GetClass()] then ply:StripWeapon(wep:GetClass()) break end
		ply:DropWeapon(wep)
	end
	
	if ply:Team() == TEAM_VAMPIRE or ply:Team() == TEAM_GHOUL then
		BeginResurrection(ply, ply.body)
		return
	end
	if ply:Team() == TEAM_HUMAN and att:IsPlayer() and att:Team() == TEAM_VAMPIRE and att:GetActiveWeapon():GetClass() == "weapon_bl_fangs" then
		BeginTransformation(ply, ply.body)
		return
	end
	
	if (ply:Team() == TEAM_HUMAN or ply:Team() == TEAM_HUNTER) and att:IsPlayer() and (att:Team() ~= TEAM_VAMPIRE or att:Team() ~= TEAM_GHOUL) then
		net.Start("bl_playerdeath")
		net.Send(ply)
		
		ply:SetTeam(TEAM_SPECTATOR)
		timer.Simple(0.1, function()
			ply:Spectate(OBS_MODE_IN_EYE)
			ply:SetNoDraw(true)
			ply:AllowFlashlight(false)
		end)
	elseif not att:IsPlayer() then
		ply:SetTeam(TEAM_SPECTATOR)
		timer.Simple(0.1, function()
			ply:Spectate(OBS_MODE_IN_EYE)
			ply:SetNoDraw(true)
			ply:AllowFlashlight(false)
		end)
	end
	
	
	self:RoundCheck()
end

local specEnt = 1
hook.Add("KeyPress", "SpecKey", function(ply, key)
	if ply:Team() ~= TEAM_SPECTATOR then return end
	if #GAMEMODE.ActivePlayers <= 0 then return end
	
	if ply:KeyPressed(IN_ATTACK) then
		specEnt = specEnt + 1
		if specEnt > #GAMEMODE.ActivePlayers then
			specEnt = 1
		end
		if GAMEMODE.ActivePlayers[specEnt]:Team() ~= TEAM_SPECTATOR then
			ply:SpectateEntity(GAMEMODE.ActivePlayers[specEnt])
		else
			specEnt = specEnt + 1
		end
	elseif ply:KeyPressed(IN_ATTACK2) then
		specEnt = specEnt - 1
		if specEnt < 1 then
			specEnt = #GAMEMODE.ActivePlayers
		end
		if GAMEMODE.ActivePlayers[specEnt]:Team() ~= TEAM_SPECTATOR then
			ply:SpectateEntity(GAMEMODE.ActivePlayers[specEnt])
		else
			specEnt = specEnt - 1
		end
		ply:SpectateEntity(GAMEMODE.ActivePlayers[specEnt])
	end
end)