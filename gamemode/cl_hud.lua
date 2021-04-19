surface.CreateFont( "bl_teamfont", {
	font = "October Crow", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 128,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

surface.CreateFont( "bl_descfont", {
	font = "October Crow", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 78,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

surface.CreateFont( "bl_deathfont", {
	font = "October Crow", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 112,
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
	local bloodImageBorder = 4
	if LocalPlayer():Team() == TEAM_HUMAN or LocalPlayer():Team() == TEAM_HUNTER then
		surface.SetMaterial(vampireHealth)
		surface.DrawTexturedRect(x, y, width, height)

		local barHeight = math.Remap(curHealth, 0, maxHealth, height * 4 / imagePixelSize, height * 64 / imagePixelSize)
		surface.SetMaterial(vampireBlood)
		surface.DrawTexturedRectUV(x, y + height - barHeight, width, barHeight, 0, 1-barHeight/imagePixelSize, 1, 1)
		
	elseif LocalPlayer():Team() == TEAM_VAMPIRE or LocalPlayer():Team() == TEAM_GHOUL then
		surface.SetMaterial(vampireHealth)
		surface.DrawTexturedRect(x, y, width, height)

		local barHeight = math.Remap(curHealth, 0, maxHealth, height * 4 / imagePixelSize, height * 64 / imagePixelSize)
		surface.SetMaterial(vampireBlood)
		surface.DrawTexturedRectUV(x, y + height - barHeight, width, barHeight, 0, 1-barHeight/imagePixelSize, 1, 1)
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
	
		local label1 = vgui.Create("DLabel", deathPnl)
		label1:SetFont("bl_deathfont")
		label1:SetPos(ScrW() / 2 - 550, ScrH() / 6)
		label1:SetAlpha(0)
		
		local label2 = vgui.Create("DLabel", deathPnl)
		label2:SetFont("bl_deathfont")
		label2:SetPos(ScrW() / 2 - 550, ScrH() / 2 + 150)
		label2:SetAlpha(0)
		
		local attTeamLabel = vgui.Create("DLabel", deathPnl)
		attTeamLabel:SetPos(ScrW() / 2 - 275, ScrH() / 3)
		attTeamLabel:SetFont("bl_teamfont")
		if attTeam == TEAM_HUNTER then
			if deathTeam == TEAM_HUMAN then
				label1:SetText("You were killed in cold blood by")
				label1:SetPos(ScrW() / 2 - 250, ScrH() / 6)
				attTeamLabel:SetText(attName)
				label2:SetText("	  		Your life is over")
			elseif deathTeam == TEAM_VAMPIRE then
				label1:SetText("You were hunt down by")
				attTeamLabel:SetText(attName)
				label2:SetText("      Your reign has ended")
			end
		elseif attTeam == TEAM_VAMPIRE then
			if deathTeam == TEAM_HUMAN then
				label1:SetText("     You were bitten by")
				attTeamLabel:SetText(attName)
				label2:SetText("You will now become a ghoul")
			elseif deathTeam == TEAM_HUNTER then
				label1:SetText("     You were bitten by")
				attTeamLabel:SetText(attName)
				label2:SetText("     Your hunt has ended")
			end
		else
			label1:SetText("You died by natural causes")
			attTeamLabel:SetText("")
			label2:SetText("Your life is over")
			label2:SetPos(ScrW() / 2 - 350, ScrH() / 2 + 150)
		end
		
		label1:AlphaTo(255, 0.1, 1, function() 
			attTeamLabel:AlphaTo(255, 0.5, 1, function() 
				label2:AlphaTo(255, 0.1, 1, function() end)
			end)
		end)
		label1:SizeToContents()
		label2:SizeToContents()
		attTeamLabel:SizeToContents()
	end)
	
	timer.Simple(11, function()
		deathPnl:AlphaTo(0, 0.1, 1, function()
			deathPnl:Remove()
		end)
	end)
end

hook.Add( "CalcView", "CalcView::GmodDeathView", function( player, origin, angles, fov )
	local ragdoll = player:GetRagdollEntity()
	
	if player:Alive() then return end
	
	if !IsValid(ragdoll) then return end

	local camera = ragdoll:GetAttachment( ragdoll:LookupAttachment( "eyes" ) )

	if (!camera) then return end

	local deathView = {
		origin = camera.Pos, 
		angles = camera.Ang, 
		fov = 90, 
		znear = 1
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
