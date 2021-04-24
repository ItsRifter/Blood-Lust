surface.CreateFont( "bl_scoretitlefont", {
	font = "DermaLarge",
	extended = false,
	size = 58,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

surface.CreateFont( "bl_playerfont", {
	font = "DermaLarge",
	extended = false,
	size = 16,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

function scoreboard(shouldEnable)
	if shouldEnable then
		scoreFrame = vgui.Create("DFrame")
		scoreFrame:SetTitle("")
		scoreFrame:ShowCloseButton(false)
		scoreFrame:SetSize(ScrW() / 1.35, ScrH() / 1.5)
		scoreFrame:SetPos(ScrW() / 8, ScrH() / 12)
		scoreFrame:MakePopup()
		scoreFrame.Paint = function(pnl, w, h)
			--Fill
			surface.SetDrawColor(Color(105, 0, 0, 255))
			surface.DrawRect(0, 0, w, h)
			
			--Top border
			surface.SetDrawColor(Color(60, 10, 10, 255))
			surface.DrawRect(0, 0, w, h / 12)
			
			--Bottom border
			surface.SetDrawColor(Color(60, 10, 10, 255))
			surface.DrawRect(0, ScrH() / 1.675, w, h)		
		end
		
		local scoreTitle = vgui.Create("DLabel", scoreFrame)
		scoreTitle:SetText("BLOOD LUST v" ..GAMEMODE.Version)
		scoreTitle:SetFont("bl_scoretitlefont")
		scoreTitle:SizeToContents()
		
		local playerList = vgui.Create("DIconLayout", scoreFrame)
		playerList:SetPos(0, 95)
		playerList:SetSize(scoreFrame:GetWide(), 720)
		playerList:SetSpaceY(5)
		playerList:SetSpaceX(5)
		
		for _, ply in pairs(player.GetAll()) do 
			local playerPanel = playerList:Add("DPanel")
			playerPanel:SetSize(172, 64)
			playerPanel.Paint = function(pnl, w, h)
				surface.SetDrawColor(Color(165, 0, 0, 255))
				surface.DrawRect(0, 0, w, h)
			end
			
			local playerName = vgui.Create("DLabel", playerPanel)
			playerName:SetText(ply:Nick())
			playerName:SetFont("bl_playerfont")
			playerName:SizeToContents()
			playerName:SetPos(65, 0)
			
			local playerPing = vgui.Create("DLabel", playerPanel)
			if not ply:IsBot() then
				playerPing:SetText(ply:Ping())
				playerPing:SetPos(152, 45)
			else
				playerPing:SetText("BOT")
				playerPing:SetPos(148, 45)
			end
			playerPing:SetFont("bl_playerfont")
			playerPing:SizeToContents()
			
			
			local playerAvatar = vgui.Create("AvatarImage", playerPanel)
			playerAvatar:SetSize(64, 64)
			playerAvatar:SetPlayer(ply, 64)
			
			local avatarBtn = vgui.Create("DImageButton", playerAvatar)
			avatarBtn:SetSize(64, 64)
			avatarBtn.DoClick = function()
				ply:ShowProfile()
			end
		end
		
	else
		scoreFrame:Remove()
	end
end

function GM:ScoreboardShow()
	scoreboard(true)
	return false
end

function GM:ScoreboardHide()
	scoreboard(false)
end