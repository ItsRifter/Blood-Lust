AddCSLuaFile()

SWEP.Author = "SuperSponer"
SWEP.Base = "weapon_base"
SWEP.PrintName = "Winchester"
SWEP.Instructions = "Shoot"

SWEP.UseHands = true
SWEP.WorldModel = "models/weapons/bloodlust/w_annabelle.mdl"
SWEP.ViewModel = "models/weapons/bloodlust/v_annabelle.mdl"

SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.SetHoldType = "shotgun"
SWEP.Primary.Damage = 35
SWEP.Primary.ClipSize = 14
SWEP.Primary.DefaultClip = 14
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "357"
SWEP.Primary.NumShots = 1
SWEP.Primary.Spread = 2
SWEP.Primary.Cone = 0.17
SWEP.Primary.Delay = 0.45
SWEP.Primary.Recoil = 2.6

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.ShouldDropOnDie = true

SWEP.NextBullet = 0
SWEP.CockAction = false
SWEP.IsReloading = false

local fireSound = Sound("weapons/shotgun/shotgun_fire6.wav")

function SWEP:Initialize()
	self:SetHoldType("shotgun")
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() or self.IsReloading then return end
	
	local pl = self:GetOwner()
	
	pl:LagCompensation(true)

	local bullet = {}
	bullet.num = self.Primary.NumShots
	bullet.Src = pl:GetShootPos()
	bullet.Dir = pl:GetAimVector()
	bullet.Spread = self.Primary.Cone, self.Primary.Cone
	bullet.Tracer = 0
	bullet.Damage = self.Primary.Damage
	bullet.AmmoType = self.Primary.Ammo
	
	self.Owner:FireBullets(bullet)
	self:ShootEffects()
	
	self:EmitSound(fireSound)
	
	local rnda = self.Primary.Recoil * -1 
	local rndb = self.Primary.Recoil * math.random(-1, 1) 
	pl:ViewPunch(Angle( rnda,rndb,rnda )) 
	
	self:TakePrimaryAmmo(1)
	self:SetNextPrimaryFire(CurTime() + self:SequenceDuration() + self.Primary.Delay)
	self:SendWeaponAnim(ACT_SHOTGUN_PUMP)
	
	pl:LagCompensation(false)
end

function SWEP:Think()

	if self.Owner:KeyReleased(IN_RELOAD) and self:Clip1() < self.Primary.ClipSize and self.IsReloading then
		
		self.IsReloading = false
		if self.CockAction then
			timer.Simple(0.01, function()
				self:EmitSound("weapons/shotgun/shotgun_cock.wav", 100, 100, 0.45)
				self.CockAction = false
				self:SendWeaponAnim(ACT_VM_RELOAD)
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
	if self.NextBullet > CurTime() then return end
	timer.Simple(0.08, function()
		if self.Owner:GetAmmoCount(self.Primary.Ammo) >= 1 then
			self.Owner:EmitSound("weapons/shotgun/shotgun_reload" .. math.random(1, 3) .. ".wav")
			self:SetClip1(self:Clip1() + 1)
			self.Owner:RemoveAmmo(1, self.Primary.Ammo)
			if self:Clip1() >= self.Primary.ClipSize then
				self.IsReloading = false
				self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
				timer.Simple(0.01, function()
					if self.CockAction then
						self:EmitSound("weapons/shotgun/shotgun_cock.wav", 100, 100, 0.45)
						self.CockAction = false
					end
				end)
			end
		else
			self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
		end
	end)

	self.NextBullet = CurTime() + 0.96
end

function SWEP:SecondaryAttack()
	return
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
end

local crosshair = Material("bloodlust/crosshair/crosshair")

function SWEP:DoDrawCrosshair(x, y)
	surface.SetDrawColor(255, 255, 255, 255)	
	surface.SetMaterial(crosshair)
	surface.DrawTexturedRect(x - 32, y - 32, 48, 64)
	return true
end