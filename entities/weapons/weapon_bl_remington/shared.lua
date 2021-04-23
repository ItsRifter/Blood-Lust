AddCSLuaFile()

SWEP.Author = "SuperSponer"
SWEP.Base = "weapon_base"
SWEP.PrintName = "Remington 870"
SWEP.Instructions = "Shoot"

SWEP.UseHands = true
SWEP.WorldModel = "models/weapons/bloodlust/w_shotgun.mdl"
SWEP.ViewModel = "models/weapons/bloodlust/v_shotgun.mdl"

SWEP.Slot = 4
SWEP.SlotPos = 0
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.SetHoldType = "shotgun"
SWEP.Primary.Damage = 9
SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "buckshot"
SWEP.Primary.NumShots = 6
SWEP.Primary.Spread = 5
SWEP.Primary.Cone = 0.17
SWEP.Primary.Delay = 0.35
SWEP.Primary.Recoil = 1.8

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.ShouldDropOnDie = true

SWEP.NextSlug = 0
SWEP.CockAction = false
SWEP.IsReloading = false

function SWEP:Initialize()
	self:SetHoldType("shotgun")
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	
	self.Owner:LagCompensation(true)
	
	local fireSound = Sound("bloodlust/shotgun_fire" .. math.random(6, 7) .. ".wav")
	
	local pl = self:GetOwner()
	local shell = {}
	shell.num = self.Primary.NumShots
	shell.Src = pl:GetShootPos()
	shell.Dir = pl:GetAimVector()
	shell.Spread = self.Primary.Cone, self.Primary.Cone
	shell.Tracer = 0
	shell.Damage = self.Primary.Damage
	shell.AmmoType = self.Primary.Ammo
	
	self:ShootBullet(self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone)
	self:ShootEffects()
	
	self:EmitSound(fireSound)
	
	local rnda = self.Primary.Recoil * -1 
	local rndb = self.Primary.Recoil * math.random(-1, 1) 
	self.Owner:ViewPunch(Angle( rnda,rndb,rnda )) 
	
	self:TakePrimaryAmmo(1)
	self:SetNextPrimaryFire(CurTime() + self:SequenceDuration() + self.Primary.Delay)
	self:SendWeaponAnim(ACT_SHOTGUN_PUMP)
	
	timer.Simple(0.05, function()
		self.Owner:EmitSound("bloodlust/shotgun_cock.wav", 100, 100, 0.45)
	end)
	
	self.Owner:LagCompensation(false)
end

function SWEP:Think()

	if self.Owner:KeyReleased(IN_RELOAD) and self:Clip1() < self.Primary.ClipSize and self.IsReloading then
		self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
		self.IsReloading = false
		if self.CockAction then
			timer.Simple(0.01, function()
				self:EmitSound("bloodlust/shotgun_cock.wav", 100, 100, 0.45)
				self.CockAction = false
			end)
		end
	end
end

function SWEP:Reload()
	
	if self:Clip1() == self.Primary.ClipSize then return end
	if self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then return end
	if self:Clip1() <= 0 then
		self.CockAction = true
	end
	self.IsReloading = true
	if self.NextSlug > CurTime() then return end
	self:SendWeaponAnim(ACT_VM_RELOAD)
	timer.Simple(0.08, function()
		
		if self.Owner:GetAmmoCount(self.Primary.Ammo) >= 1 then
			self.Owner:EmitSound("bloodlust/shotgun_reload" .. math.random(1, 3) .. ".wav")
			self:SetClip1(self:Clip1() + 1)
			self.Owner:RemoveAmmo(1, self.Primary.Ammo)
			if self:Clip1() >= self.Primary.ClipSize then
				self.IsReloading = false
				self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
				timer.Simple(0.01, function()
					if self.CockAction then
						self:EmitSound("bloodlust/shotgun_cock.wav", 100, 100, 0.45)
						self.CockAction = false
					end
				end)
			end
		else
			self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
		end
	end)

	self.NextSlug = CurTime() + 0.4
end

function SWEP:SecondaryAttack()
	return
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	self.State = "Ready"
end

local crosshair = Material("bloodlust/crosshair/crosshair")

function SWEP:DoDrawCrosshair(x, y)
	surface.SetDrawColor(255, 255, 255, 255)	
	surface.SetMaterial(crosshair)
	surface.DrawTexturedRect(x - 32, y - 32, 48, 64)
	return true
end