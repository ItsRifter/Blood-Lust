AddCSLuaFile()

SWEP.Author = "SuperSponer"
SWEP.PrintName = "Empty Hands"
SWEP.Instructions = "Your bare hands"

SWEP.WorldModel = ""
SWEP.ViewModel = ""

SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.Spawnable = false
SWEP.AdminSpawnable = true
SWEP.AnimPrefix = "rpg"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.ShouldDropOnDie = false

function SWEP:Initialize()
	self:SetWeaponHoldType("normal")
end

function SWEP:PrimaryAttack()
	return
end

function SWEP:SecondaryAttack()
	return
end

function SWEP:DoDrawCrosshair(x, y)
	return true
end

function SWEP:Deploy()
	if CLIENT then return end
	self.Owner:DrawWorldModel(false)
	self.Owner:DrawViewModel(false)
end