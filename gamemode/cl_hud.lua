surface.CreateFont( "bl_teamfont", {
	font = "DermaLarge",
	extended = false,
	size = 128,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

surface.CreateFont( "bl_namefont", {
	font = "DermaLarge",
	extended = false,
	size = 26,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

surface.CreateFont( "bl_teamnamefont", {
	font = "DermaLarge",
	extended = false,
	size = 18,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

surface.CreateFont( "bl_descfont", {
	font = "DermaLarge",
	extended = false,
	size = 78,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

surface.CreateFont( "bl_deathfont", {
	font = "DermaLarge",
	extended = false,
	size = 88,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

surface.CreateFont( "bl_ammofont", {
	font = "DermaLarge",
	extended = false,
	size = 108,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

surface.CreateFont( "bl_timefont", {
	font = "DermaLarge",
	extended = false,
	size = 72,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

surface.CreateFont( "bl_specialfont", {
	font = "DermaLarge",
	extended = false,
	size = 64,
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

function GM:HUDAmmoPickedUp(itemName, count)
	return false
end

local humanHealth = Material("bloodlust/hud/human")
local vampireHealth = Material("bloodlust/hud/vampire")
local humanBlood = Material("bloodlust/hud/humanblood")
local vampireBlood = Material("bloodlust/hud/vampireblood")

hook.Add("HUDPaint", "BL_HUDPaint", function()
	if not LocalPlayer():Alive() then return end
	
	--HEALTH
	local curHealth = LocalPlayer():Health()
	local maxHealth = LocalPlayer():GetMaxHealth()
	surface.SetDrawColor( 255, 255, 255, 255 )
	
	local x, y, width, height = ScrW() / 24 - 50, ScrH() / 2 + 350, 188, 188
	local imagePixelSize = 64
	--local bloodImageBorder = 4
	
	if LocalPlayer():Alive() and LocalPlayer():Team() ~= TEAM_SPECTATOR or (LocalPlayer():Team() == TEAM_HUMAN or LocalPlayer():Team() == TEAM_HUNTER) then
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

	--AMMO
	if LocalPlayer():Alive() and LocalPlayer():GetActiveWeapon() and LocalPlayer():GetActiveWeapon():Clip1() ~= nil and LocalPlayer():GetActiveWeapon():Clip1() >= 0 then
		local ammo = LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType()
		local ammoCount = LocalPlayer():GetAmmoCount(ammo)
		surface.SetFont( "bl_ammofont" )
		surface.SetTextColor( 170, 0, 0 )
		surface.SetTextPos( ScrW() / 1.15, ScrW() / 2 ) 
		surface.DrawText(tostring(LocalPlayer():GetActiveWeapon():Clip1()) .. "/" .. tostring(ammoCount))
	end
	
	--TIMER
	if timer.Exists("bl_sunrisetime") then
		surface.SetFont( "bl_timefont" )
		surface.SetTextColor( 170, 0, 0 )
		surface.SetTextPos( ScrW() / 4 - 300, ScrW() / 2 + 50 )
		
		surface.DrawText(string.FormattedTime(timer.TimeLeft("bl_sunrisetime"), "%2i:%02i" ))
	end
end)

function NewRoundMenu()
	local team = net.ReadInt(8)
	local special = net.ReadString() or "None"
	local description = ""
	
	timer.Create("bl_sunrisetime", GAMEMODE.ConVars.TimeLimit:GetInt(), 1, function()
	end)
	
	local roundPnl = vgui.Create("DPanel")
	roundPnl:SetSize(ScrW(), ScrH())
	roundPnl.Paint = function(pnl, w, h)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, w, h)
	end

	if special ~= "None" then
	
		local specialAlert = vgui.Create("DLabel", roundPnl)
		specialAlert:SetFont("bl_specialfont")
		specialAlert:SetText(translate.Get("SpecialRound"))
		specialAlert:SetPos(ScrW() / 2 - 185, ScrH() / 2 - 450)
		specialAlert:SizeToContents()
		local specialLabel = vgui.Create("DLabel", roundPnl)
		specialLabel:SetFont("bl_specialfont")
		
		
		local specialDescLabel = vgui.Create("DLabel", roundPnl)
		specialDescLabel:SetFont("bl_specialfont")
		specialDescLabel:SetPos(ScrW() / 2 - 225, ScrH() / 2 - 375)
		specialDescLabel:SetText(translate.Get(special))
		
		specialLabel:SetText(translate.Get(special .. "Desc"))
		
		specialLabel:SetPos(ScrW() / 2 - 600, ScrH() / 2 - 250)
		
		specialLabel:SizeToContents()
		specialDescLabel:SizeToContents()
	end

	local teamnameLabel = vgui.Create("DLabel", roundPnl)
	teamnameLabel:SetFont("bl_teamfont")
	
	local descLabel = vgui.Create("DLabel", roundPnl)
	descLabel:SetFont("bl_descfont")
	if team == TEAM_HUMAN then
		teamnameLabel:SetText(translate.Get("Human"))
		description = translate.Get("HumanDesc")
		descLabel:SetPos(ScrW() / 2 - 225, ScrH() - 450)
	elseif team == TEAM_HUNTER then
		teamnameLabel:SetText(translate.Get("Hunter"))
		description = translate.Get("HunterDesc")
		descLabel:SetPos(ScrW() / 2 - 325, ScrH() - 450)
	elseif team == TEAM_VAMPIRE then
		teamnameLabel:SetText(translate.Get("Vampire"))
		description = translate.Get("VampireDesc")
		descLabel:SetPos(ScrW() / 2 - 400, ScrH() - 450)
	end
	teamnameLabel:SetPos(ScrW() / 2 - 400, ScrH() / 3)
	teamnameLabel:SizeToContents()
	
	descLabel:SetText(description)
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

	deathPnl:AlphaTo(255, 0.5, 1, function() end)

	timer.Simple(6, function()
		deathPnl:AlphaTo(0, 0.1, 1, function() end)
	end)
end

local CLIENT_MALE_NAMES = {
	"Jeff",
	"David",
	"Johnny"
}

local CLIENT_FEMALE_NAMES = {
	"Catherine",
	"Kate",
	"Lisa"
}

function GM:HUDDrawTargetID()
	local tr = util.GetPlayerTrace( LocalPlayer() )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end
	if (!trace.HitNonWorld) then return end
	
	if not LocalPlayer():Alive() then return end
	
	local text = "NOBODY"
	local team = "Human"
		
	if (trace.Entity:IsPlayer()) then
		text = trace.Entity:Nick()
		if LocalPlayer():Team() == TEAM_VAMPIRE then
			if trace.Entity:Team() == TEAM_VAMPIRE then
				team = "Vampire"
			elseif trace.Entity:Team() == TEAM_GHOUL then
				team = "Ghoul"
			end
		
		elseif LocalPlayer():Team() == TEAM_GHOUL then
			if trace.Entity:Team() == TEAM_VAMPIRE then
				team = "Vampire"
			elseif trace.Entity:Team() == TEAM_GHOUL then
				team = "Ghoul"
			end
		end
	else
		return
	end
		
	surface.SetFont( "TargetID" )
	local w, h = surface.GetTextSize( text )
		
	local MouseX, MouseY = gui.MousePos()
		
	if ( MouseX == 0 && MouseY == 0 ) then
		MouseX = ScrW() / 2
		MouseY = ScrH() / 2
	end
		
	local x = MouseX
	local y = MouseY

	x = x - w / 2
	y = y + 30

	draw.SimpleText( text, "TargetID", x+1, y+1, Color(255, 255, 255, 255) )
	
	y = y + h + 5
	
	draw.SimpleText( team, "TargetIDSmall", x+1, y+1, Color(255, 255, 255, 255) )
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
