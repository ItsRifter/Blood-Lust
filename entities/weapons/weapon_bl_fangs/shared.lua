AddCSLuaFile()

SWEP.Author = "SuperSponer"
SWEP.PrintName = "Fangs"
SWEP.Instructions = "Bite humans"

SWEP.UseHands = false
SWEP.WorldModel = ""
SWEP.ViewModel = ""

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

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.ShouldDropOnDie = false

function SWEP:Initialize()
	self:SetHoldType("knife")
end


function SWEP:PrimaryAttack()
	if CLIENT then return end
	
	local biteSound = Sound("bloodlust/bite_" .. math.random(1, 4) .. ".wav")
	
	local pl = self:GetOwner()
	
	pl:LagCompensation(true)
	
	local shootPos = pl:GetShootPos()
	local endShootPos = shootPos + pl:GetAimVector() * 70
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
	
	if ent and ent:IsPlayer() and ent:Team() and (ent:Team() == TEAM_HUMAN or ent:Team() == TEAM_HUNTER) and ent:Alive() then
		local dmgInfo = DamageInfo()
		
		pl:SetAnimation(PLAYER_ATTACK1)
		pl:EmitSound(biteSound)
		ent:SetHealth(ent:Health() - 45)
		
		if ent:Health() < 1 then
			ent:Kill()
			ent.killer = pl
		end
		
	elseif ent and ent.blood and ent.blood >= 1 then
		pl:EmitSound(biteSound)
		if pl:Health() >= pl:GetMaxHealth() then
			pl:SetHealth(pl:GetMaxHealth())
		end
		pl:SetHealth(pl:Health() + 10)
		ent.blood = ent.blood - 10
	elseif ent and ent.blood and ent.blood < 1 then
		pl:ChatPrint("This body is dried of blood")
	else
		pl:SetAnimation(PLAYER_ATTACK1)
	end
	
	self:SetNextPrimaryFire(CurTime() + 2)
	
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