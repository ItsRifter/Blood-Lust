AddCSLuaFile()

SWEP.Author = "SuperSponer"
SWEP.PrintName = "Fangs"
SWEP.Instructions = "Bite humans\nBEWARE: Will alert humans of your attacks"

SWEP.UseHands = false
SWEP.WorldModel = ""
SWEP.ViewModel = ""

SWEP.WepSelectIcon = Material("bloodlust/killicons/weapon_bl_fangs.png")
SWEP.BounceWeaponIcon = false

SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.SetHoldType = "melee"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Damage = 65

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.ShouldDropOnDie = false

function SWEP:Initialize()
	self:SetHoldType("knife")
end

function SWEP:PrimaryAttack()
	
	local biteSound = Sound("bloodlust/bite_" .. math.random(1, 4) .. ".wav")
	
	local pl = self:GetOwner()
	
	pl:LagCompensation(true)
	
	local tr = {}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 125 )
	tr.filter = self.Owner
	tr.mask = MASK_SHOT
	local trace = util.TraceLine( tr )
	
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	if ( trace.Hit ) then

		if trace.Entity:IsPlayer() and (trace.Entity:Team() ~= TEAM_VAMPIRE and trace.Entity:Team() ~= TEAM_GHOUL) then
			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
			pl:SetAnimation(PLAYER_ATTACK1)
			pl:EmitSound(biteSound)
			
			bullet = {}
			bullet.Num    = 1
			bullet.Src    = self.Owner:GetShootPos()
			bullet.Dir    = self.Owner:GetAimVector()
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 0
			bullet.Force  = 1
			bullet.Damage = self.Primary.Damage
			self.Owner:FireBullets(bullet)
			self:SetNextPrimaryFire(CurTime() + 1.25)
		elseif trace.Entity.blood and trace.Entity.blood >= 1 then
			pl:EmitSound(biteSound)
			if pl:Health() >= pl:GetMaxHealth() then
				pl:SetHealth(pl:GetMaxHealth())
			end
			self:SetNextPrimaryFire(CurTime() + 1.85)
			pl:SetHealth(pl:Health() + 10)
			trace.Entity.blood = trace.Entity.blood - 10
		elseif trace.Entity.blood and trace.Entity.blood < 1 then
			pl:ChatPrint("This body is dried of blood")
		end
	else
		self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)
		pl:SetAnimation(PLAYER_ATTACK1)
	end
	self:SetNextPrimaryFire(CurTime() + 1.25)
	pl:LagCompensation(false)
end

function SWEP:SecondaryAttack()
	return
end

function SWEP:Deploy()
	if CLIENT then return end
	
	self.Owner:EmitSound("bloodlust/vampireattack.wav", 150, 100)
end

local crosshair = Material("bloodlust/crosshair/crosshair")

function SWEP:DoDrawCrosshair(x, y)
	surface.SetDrawColor(255, 255, 255, 255)	
	surface.SetMaterial(crosshair)
	surface.DrawTexturedRect(x - 32, y - 32, 48, 64)
	return true
end

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	
	-- Set us up the texture
	surface.SetDrawColor( 255, 255, 255, alpha )
	surface.SetMaterial( self.WepSelectIcon )
	
	-- Lets get a sin wave to make it bounce
	local fsin = 20
	
	-- Borders
	y = y + 35
	x = x + 10
	wide = wide - 20
	
	-- Draw that mother
	surface.DrawTexturedRect( x + (fsin), y - (fsin),  wide-fsin*2 , ( wide / 2 ) + (fsin) )
	
	-- Draw weapon info box
	self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
	
end