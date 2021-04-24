surface.CreateFont( "bl_skillpointsfont", {
	font = "DermaLarge",
	extended = false,
	size = 26,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

function VampireSkills()
	
	local skillFrame = vgui.Create("DFrame")
	skillFrame:SetSize(ScrW() / 1.75, ScrH() / 2)
	skillFrame:SetTitle("")
	skillFrame:MakePopup()
	skillFrame:Center()
	
	local curPoints = vgui.Create("DLabel", skillFrame)
	curPoints:SetText("BLOOD POINTS: " .. LocalPlayer():GetNWInt("bl_bloodpoints"))
	curPoints:SetFont("bl_skillpointsfont")
	curPoints:SetPos(0, 30)
	curPoints:SizeToContents()
	
	
end

function GM:OnContextMenuOpen()
	if LocalPlayer():Team() == TEAM_VAMPIRE then
		VampireSkills()
	end
	return false
end
