AddCSLuaFile()

SWEP.Author = "SuperSponer"
SWEP.PrintName = "Wooden Stake"
SWEP.Base = "weapon_base"
SWEP.Instructions = "Aim for the heart"

SWEP.UseHands = false
SWEP.WorldModel = ""
SWEP.ViewModel = "models/weapons/bloodlust/v_stake.mdl"
SWEP.WorldModel = "models/weapons/bloodlust/w_stake.mdl"

SWEP.Slot = 0
SWEP.SlotPos = 0
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
SWEP.Primary.Damage = 35
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
	
	local tr = {}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 125 )
	tr.filter = self.Owner
	tr.mask = MASK_SHOT
	
	local trace = util.TraceLine( tr )
	
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	if ( trace.Hit and not trace.HitWorld ) then

		if trace.Entity:IsPlayer() then
			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
			pl:EmitSound(stabSound)
			
			bullet = {}
			bullet.Num    = 1
			bullet.Src    = self.Owner:GetShootPos()
			bullet.Dir    = self.Owner:GetAimVector()
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 0
			bullet.Force  = 1
			bullet.Damage = self.Primary.Damage
			self.Owner:FireBullets(bullet)
			pl:EmitSound(stabSound)

		elseif trace.Entity and trace.Entity.player and trace.Entity.team and (trace.Entity.team == TEAM_VAMPIRE or trace.Entity.team == TEAM_GHOUL) then
			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
			pl:SetAnimation(PLAYER_ATTACK1)
			
			pl:EmitSound(stabSound)
			
			if trace.Entity.player:Team() == TEAM_SPECTATOR then 
				self:SetNextPrimaryFire(CurTime() + self:SequenceDuration() + 0.5)
				pl:LagCompensation(false)
				return 
			end
			
			trace.Entity.player:SetTeam(TEAM_SPECTATOR)
			if string.find(trace.Entity:GetModel(), "female") then
				trace.Entity:EmitSound("bloodlust/vampirefemaledeath.wav")
			else
				trace.Entity:EmitSound("bloodlust/vampiremaledeath.wav")
			end
			trace.Entity:Ignite(6, 0)
			GAMEMODE:RoundCheck()
		elseif trace.Entity and trace.Entity.player then
			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
			pl:SetAnimation(PLAYER_ATTACK1)
			
			pl:EmitSound(stabSound)
		end
	else
		self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)
		pl:SetAnimation(PLAYER_ATTACK1)
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