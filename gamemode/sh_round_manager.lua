AddCSLuaFile()

GAME_PREROUND, GAME_ACTIVE, GAME_POSTROUND = 1, 2, 3

GAME_HUMANWIN, GAME_VAMPIREWIN, GAME_RESTART, GAME_ABORT = 1, 2, 3, 4


if SERVER then		
	--Return the current round's status
	function GM:GetRoundStatus()
		if self.GameState then
			return self.GameState
		else
			return GAME_PREROUND
		end
	end
	
	GM.GameTime = 0
	GM.GameCount = -1
	GM.GameState = GM:GetRoundStatus() or GAME_PREROUND
	GM.GameIdle = true
	GM.ActivePlayers = {}
	
	GM.SpecialRoundTbl = {
		"HuntersVsVampires",
	}
	
	
	
	function GM:RoundCheck()
		if self.GameState == GAME_ACTIVE then
			-- Check for surviving humans
			if team.NumPlayers(TEAM_HUMAN) + team.NumPlayers(TEAM_HUNTER) < 1 then
				self:RoundEnd(GAME_VAMPIREWIN)
			-- Check for vampires
			elseif team.NumPlayers(TEAM_VAMPIRE) + team.NumPlayers(TEAM_GHOUL) < 1 then
				-- Vampires fled
				self:RoundEnd(GAME_HUMANWIN)
			end
		elseif self.GameState == GAME_PREROUND then
			-- Check for any active players
			if #player.GetAll() >= 2 and self.GameIdle then
				self.GameIdle = false
				self:BroadcastMessage(Color(255, 255, 255), "Enough players connected, Starting game...")
				self.GameCount = self.ConVars.MaxRounds:GetInt()
				timer.Simple(8, function()
					self:RoundRestart()
				end)
			end
		end
	end

	function GM:SpecialRoundStart(roundType)
		if roundType == "HuntersVsVampires" then
			for _, v in pairs(player.GetAll()) do
				if v:Team() == TEAM_HUMAN then break end
				
				local vampire = team.GetPlayers(TEAM_HUMAN)[math.random(team.NumPlayers(TEAM_HUMAN))]
				vampire:SetTeam(TEAM_VAMPIRE)
				vampire:Spawn()
				timer.Simple(0.1, function()
					vampire:Give("weapon_bl_fangs")
				end)
				
				local hunter = team.GetPlayers(TEAM_HUMAN)[math.random(team.NumPlayers(TEAM_HUMAN))]
				hunter:SetTeam(TEAM_HUNTER)
				hunter:Spawn()
				timer.Simple(0.1, function()
					hunter:Give("weapon_crossbow")
					hunter:Give("weapon_bl_stake")
				end)
			end
		end
		
		
	end

	function GM:RoundRestart()
		--Clean up and restart
		game.CleanUpMap()
		
		--Reset the table and insert active players into the table
		if GAMEMODE.ActivePlayers then
			table.Empty(GAMEMODE.ActivePlayers)
			for k, pl in pairs(player.GetAll()) do
				table.insert(GAMEMODE.ActivePlayers, pl)
			end
		else
			GAMEMODE.ActivePlayers = {}
		end
		
		--Set teams and respawn the player
		for _, pl in pairs(player.GetAll()) do
			pl:SetTeam(TEAM_HUMAN)
			pl:UnSpectate()
			pl:Spawn()
		end
		
		--If there are more than 2 humans, 
		if #player.GetAll() >= 2 then
			timer.Simple(0.1, function()
				self.GameState = GAME_ACTIVE
				self:BroadcastSound("bloodlust/roundstart.wav", ply)
			end)
			
			local specialRound = "None"
			
			if self.ConVars.SpecialChance:GetInt() >= math.random(1, 100) then
				specialRound = self.SpecialRoundTbl[math.random(#self.SpecialRoundTbl)]
			end
			
			self:RoundTime(self.ConVars.TimeLimit:GetInt())
			if self.SpecialRoundTbl[specialRound] then
				self:SpecialRoundStart(specialRound)
			else
				local vampire = team.GetPlayers(TEAM_HUMAN)[math.random(team.NumPlayers(TEAM_HUMAN))]
				vampire:SetTeam(TEAM_VAMPIRE)
				vampire:Spawn()
				timer.Simple(0.1, function()
					vampire:Give("weapon_bl_fangs")
				end)
				
				local hunter = team.GetPlayers(TEAM_HUMAN)[math.random(team.NumPlayers(TEAM_HUMAN))]
				hunter:SetTeam(TEAM_HUNTER)
				hunter:Spawn()
				timer.Simple(0.1, function()
					hunter:Give("weapon_crossbow")
					hunter:Give("weapon_bl_stake")
				end)
			end
		else
			self.GameState = GAME_PREROUND
			self.GameIdle = true
			self:BroadcastMessage(Color(255, 255, 255), "There isn't enough players to start the round...")
		end
		for _, pl in pairs(player.GetAll()) do
			net.Start("bl_roundstart")
				net.WriteInt(pl:Team(), 8)
				net.WriteString(specialRound or "None")
			net.Send(pl)
		end
	end
	
	function GM:RoundTime(time)
		timer.Create("bl_roundtimer", time, 1, function()
			-- If round was active, stop and set hiders as champions
			if self.RoundState == GAME_ACTIVE then
				self:RoundEnd(GAME_HUMANWIN)
			-- If round was over, start a new one
			elseif self.RoundState == GAME_POSTROUND then
				self:RoundRestart()
			end
		end)
	end
	
	function GM:RoundEnd(state)
		--Main states
		self.GameState = GAME_POSTROUND
		self.GameCount = self.GameCount - 1
		if state == GAME_HUMANWIN then
			print("HUMANS WIN")
			self:BroadcastMessage(Color(255, 210, 150), "Humans have survived the night!")
			self:BroadcastSound("bloodlust/humanwin.wav")
		elseif state == GAME_VAMPIREWIN then
			print("VAMPIRES WIN")
			self:BroadcastMessage(Color(165, 5, 5), "Vampires have conquered the humans!")
			self:BroadcastSound("bloodlust/vampirewin.wav")
		else
			--Other states if main states are not met
			if state == GAME_RESTART then
				print("RESTARTING ROUND...")
				self:BroadcastMessage(Color(255, 255, 255), "The round is being restarted")
			elseif state == GAME_ABORT then
				print("ROUND ABORTED")
				self:BroadcastMessage(Color(255, 210, 150), "The vampires fled")
			end
		end
		
		for _, pl in pairs(player.GetAll()) do
			CancelRespawn(pl)
			pl:UnLock()
		end
		
		timer.Simple(7, function()
			if self.GameCount >= 2 then
				self:BroadcastMessage(Color(255, 255, 255), self.GameCount .. " Rounds until map change")
				self:RoundRestart()
			elseif self.GameCount == 1 then
				self:BroadcastMessage(Color(255, 255, 255), "LAST ROUND")
				self:RoundRestart()
			elseif self.GameCount < 1 then
				self:BroadcastMessage(Color(255, 255, 255), "Game Over")
				self:BroadcastSound("bloodlust/endgame.wav")
				MapVote.Start(15, false, 6, "bl_")
			end
		end)
	end
	
end