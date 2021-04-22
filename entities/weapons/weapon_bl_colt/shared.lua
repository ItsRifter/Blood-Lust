AddCSLuaFile()

SWEP.Author = "SuperSponer"
SWEP.Base = "weapon_base"
SWEP.PrintName = "Colt 1911"
SWEP.Instructions = "Shoot"

SWEP.UseHands = true
SWEP.WorldModel = "models/weapons/bloodlust/w_colt.mdl"
SWEP.ViewModel = "models/weapons/bloodlust/v_colt.mdl"

SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.SetHoldType = "pistol"
SWEP.Primary.Damage = 8
SWEP.Primary.ClipSize = 7
SWEP.Primary.DefaultClip = 7
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.NumShots = 1
SWEP.Primary.Spread = 0
SWEP.Primary.Cone = 0
SWEP.Primary.Delay = 0.1


SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.ShouldDropOnDie = true

local fireSound = Sound("bloodlust/colt_fire.wav")

function SWEP:Initialize()
	self:SetHoldType("pistol")
end


function SWEP:PrimaryAttack()
	
	local pl = self:GetOwner()
	
	pl:LagCompensation(true)
	local bullet = {}
	bullet.num = self.Primary.NumShots
	bullet.Src = pl:GetShootPos()
	bullet.Dir = pl:GetAimVector()
	bullet.Spread = Vector(self.Primary.Spread, self.Primary.Spread, 0)
	bullet.Tracer = 0
	bullet.Damage = self.Primary.Damage
	bullet.AmmoType = self.Primary.Ammo
	
	self:FireBullets(bullet)
	self:ShootEffects()
	
	self:EmitSound(fireSound)
	
	self.BaseClass.ShootEffects(self)
	self:TakePrimaryAmmo(1)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	
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