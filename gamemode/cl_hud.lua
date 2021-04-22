surface.CreateFont( "bl_teamfont", {
	font = "October Crow",
	extended = false,
	size = 128,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

surface.CreateFont( "bl_descfont", {
	font = "October Crow",
	extended = false,
	size = 78,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

surface.CreateFont( "bl_deathfont", {
	font = "October Crow",
	extended = false,
	size = 88,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )


local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true
}

hook.Add("HUDShouldDraw", "HideHUD", function(name)
	if (hide[name]) then
		return false
	end
end)

local humanHealth = Material("bloodlust/hud/human")
local vampireHealth = Material("bloodlust/hud/vampire")
local humanBlood = Material("bloodlust/hud/humanblood")
local vampireBlood = Material("bloodlust/hud/vampireblood")

hook.Add("HUDPaint", "BL_HUDPaint", function()
	local curHealth = LocalPlayer():Health()
	local maxHealth = LocalPlayer():GetMaxHealth()
	surface.SetDrawColor( 255, 255, 255, 255 )
	
	local x, y, width, height = ScrW() / 24 - 50, ScrH() / 2 + 350, 188, 188
	local imagePixelSize = 64
	--local bloodImageBorder = 4
	
	if LocalPlayer():Team() == TEAM_HUMAN or LocalPlayer():Team() == TEAM_HUNTER then
		surface.SetMaterial(humanHealth)
		surface.DrawTexturedRect(x, y, width, height)

		local barHeight = math.Remap(curHealth, 0, maxHealth, height * 4 / imagePixelSize, height * 64 / imagePixelSize)
		surface.SetMaterial(humanBlood)
		surface.DrawTexturedRectUV(x, y + height - barHeight, width, barHeight, 0, 1-barHeight/height, 1, 1)
		
	elseif LocalPlayer():Team() == TEAM_VAMPIRE or LocalPlayer():Team() == TEAM_GHOUL then
		surface.SetMaterial(vampireHealth)
		surface.DrawTexturedRect(x, y, width, height)

		local barHeight = math.Remap(curHealth, 0, maxHealth, height * 4 / imagePixelSize, height * 64 / imagePixelSize)
		surface.SetMaterial(vampireBlood)
		surface.DrawTexturedRectUV(x, y + height - barHeight, width, barHeight, 0, 1-barHeight/height, 1, 1)
	end

end)

function NewRoundMenu()
	local team = net.ReadInt(8)
	local description = ""
	
	local roundPnl = vgui.Create("DPanel")
	roundPnl:SetSize(ScrW(), ScrH())
	roundPnl.Paint = function(pnl, w, h)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, w, h)
	end
	
	local label1 = vgui.Create("DLabel", roundPnl)
	label1:SetText("You are a")
	label1:SetFont("bl_teamfont")
	label1:SetPos(ScrW() / 2 - 225, ScrH() / 6)
	label1:SizeToContents()
	
	local teamnameLabel = vgui.Create("DLabel", roundPnl)
	teamnameLabel:SetFont("bl_teamfont")
	if team == TEAM_HUMAN then
		teamnameLabel:SetText(" HUMAN")
		description = "   Survive the night, don't get bitten\n              and trust the hunter"
	elseif team == TEAM_HUNTER then
		teamnameLabel:SetText(" HUNTER")
		description = "             Find and kill the vampire\n                  take care hunter"
	elseif team == TEAM_VAMPIRE then
		teamnameLabel:SetText("VAMPIRE")
		description = "                 Feed off the living\n        don't get killed by the hunter"
	end
	teamnameLabel:SetPos(ScrW() / 2 - 185, ScrH() / 3)
	teamnameLabel:SizeToContents()
	
	local descLabel = vgui.Create("DLabel", roundPnl)
	descLabel:SetFont("bl_descfont")
	descLabel:SetText(description)
	descLabel:SetPos(ScrW() / 2 - 600, ScrH() - 450)
	descLabel:SizeToContents()
	
	timer.Simple(6, function()
		roundPnl:Remove()
	end)
end

function GM:DrawDeathNotice(x, y)
	return false
end

local ragdoll = nil
net.Receive("bl_clientragdoll", function()
	ragdoll = net.ReadEntity()
end)

function DeathMenu()
	local attName = net.ReadString()
	local attTeam = net.ReadInt(4)
	local deathTeam = net.ReadInt(4)

	local deathPnl = vgui.Create("DPanel")
	deathPnl:SetSize(ScrW(), ScrH())
	deathPnl:SetAlpha(0)
	deathPnl.Paint = function(pnl, w, h)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, w, h)
	end
	

	
	deathPnl:AlphaTo(255, 0.5, 1, function() 	
		local deathLabel = vgui.Create("DLabel", deathPnl)
		deathLabel:SetPos(ScrW() / 2 - 100, ScrH() / 2)
		deathLabel:SetText("YOU DIED")
		deathLabel:SetFont("bl_deathfont")
		deathLabel:SizeToContents()
	end)
	

	timer.Simple(11, function()
		deathPnl:AlphaTo(0, 0.1, 1, function()
			deathPnl:Remove()
		end)
	end)
end



hook.Add( "CalcView", "bl_deathview", function( ply, origin, angles, fov )
	
	if ply:Alive() then return end

	if not IsValid(ragdoll) then return end

	local deathView = {
		origin = ragdoll:GetAttachment(1).Pos, 
		angles = ragdoll:GetAttachment(1).Angle, 
		fov = 90, 
		znear = 1,
	}

	return deathView
end)

-- Receive a message from the gamemode
net.Receive("bl_messagesay", function()
	local messageTable = net.ReadTable()
	chat.AddText(unpack(messageTable))
end)
-- Receive the sound path from the gamemode
net.Receive("bl_playsound", function()
	local soundPath = net.ReadString()
	surface.PlaySound(soundPath)
end)

net.Receive("bl_roundstart", NewRoundMenu)
net.Receive("bl_playerdeath", DeathMenu)
