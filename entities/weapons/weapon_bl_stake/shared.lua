AddCSLuaFile()

SWEP.Author = "SuperSponer"
SWEP.PrintName = "Wooden Stake"
SWEP.Instructions = "Aim for the heart"

SWEP.UseHands = false
SWEP.WorldModel = ""
SWEP.ViewModel = "models/weapons/bloodlust/v_stake.mdl"

SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.Spawnable = false
SWEP.AdminSpawnable = true

SWEP.SetHoldType = "melee"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.ShouldDropOnDie = true

local swooshSound = Sound("Weapon_Crowbar.Single")
local stabSound = Sound("physics/flesh/flesh_impact_bullet3.wav")

function SWEP:Initialize()
	self:SetHoldType("melee")
end

function SWEP:PrimaryAttack()
	if CLIENT then return end
	
	local pl = self:GetOwner()
	
	pl:LagCompensation(true)
	
	local shootPos = pl:GetShootPos()
	local endShootPos = shootPos + pl:GetAimVector() * 90
	local tmin = Vector(1, 1, 1 ) * -10 
	local tmax = Vector(1, 1, 1 ) * 10
	
	local tr = util.TraceHull( {
		start = shootPos,
		endpos = endShootPos,
		filter = pl,
		mask = MASK_SHOT_HULL,
		mins = tmin,
		maxs = tmax,
	} )
	
	local ent = tr.Entity
	
	if IsValid(ent) and ent:IsPlayer() then
		self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
		pl:SetAnimation(PLAYER_ATTACK1)

		pl:EmitSound(stabSound)
		ent:SetHealth(ent:Health() - 25)
		
		if ent:Health() < 1 then
			ent:Kill()
		end
	elseif ent and ent.player and ent.team and (ent.team == TEAM_VAMPIRE or ent.team == TEAM_GHOUL) then
		self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
		pl:SetAnimation(PLAYER_ATTACK1)
		
		pl:EmitSound(stabSound)
		
		if ent.player:Team() == TEAM_SPECTATOR then 
			self:SetNextPrimaryFire(CurTime() + self:SequenceDuration() + 0.5)
			pl:LagCompensation(false)
			return 
		end
		
		ent.player:SetTeam(TEAM_SPECTATOR)
		if string.find(ent:GetModel(), "female") then
			ent:EmitSound("bloodlust/vampirefemaledeath.wav")
		else
			ent:EmitSound("bloodlust/vampiremaledeath.wav")
		end
		ent:Ignite(6, 0)
		GAMEMODE:RoundCheck()
	else
		self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)
		pl:EmitSound(swooshSound)
	end
	
	self:SetNextPrimaryFire(CurTime() + self:SequenceDuration() + 0.5)
	
	pl:LagCompensation(false)
end

function SWEP:SecondaryAttack()
	return
end

function SWEP:Deploy()
end

local crosshair = Material("bloodlust/crosshair/crosshair")

function SWEP:DoDrawCrosshair(x, y)
	surface.SetDrawColor(255, 255, 255, 255)	
	surface.SetMaterial(crosshair)
	surface.DrawTexturedRect(x - 32, y - 32, 48, 64)
	return true
end