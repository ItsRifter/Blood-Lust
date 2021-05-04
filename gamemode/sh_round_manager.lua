AddCSLuaFile()

GAME_PREROUND, GAME_ACTIVE, GAME_POSTROUND = 1, 2, 3

GAME_HUMANWIN, GAME_VAMPIREWIN, GAME_RESTART, GAME_ABORT = 1, 2, 3, 4

--Return the current round's status
function GM:GetRoundStatus()
	if self.GameState then
		return self.GameState
	else
		return GAME_PREROUND
	end
end

if SERVER then		
	
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
			for _, pl in pairs(player.GetAll()) do
				if pl:Team() ~= TEAM_HUMAN then break end
				local vampire = team.GetPlayers(TEAM_HUMAN)[math.random(team.NumPlayers(TEAM_HUMAN))]
				if not vampire then break end
				vampire:SetTeam(TEAM_VAMPIRE)
				vampire:Spawn()
				timer.Simple(0.1, function()
					vampire:Give("weapon_bl_fangs")
				end)
				
				local hunter = team.GetPlayers(TEAM_HUMAN)[math.random(team.NumPlayers(TEAM_HUMAN))]
				if not hunter then break end
				hunter:SetTeam(TEAM_HUNTER)
				hunter:Spawn()
				timer.Simple(0.1, function()
					hunter:Give("weapon_crossbow")
					hunter:Give("weapon_bl_stake")
				end)
				
				
			end
			specialRound = "None"
		end
		for _, pl in pairs(player.GetAll()) do
			net.Start("bl_roundstart")
				net.WriteInt(pl:Team(), 8)
				net.WriteString(roundType)
			net.Send(pl)
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
			pl:UnLock()
			pl:Spawn()
		end
		
		--If there are more than 2 humans, 
		if #player.GetAll() >= 2 then
			timer.Simple(0.1, function()
				self.GameState = GAME_ACTIVE
				self:BroadcastSound("bloodlust/roundstart.wav", ply)
			end)
			
			local specialRound = "None"
			local chance = math.random(1, 100)
			if self.ConVars.SpecialChance:GetInt() >= chance then
				specialRound = self.SpecialRoundTbl[math.random(#self.SpecialRoundTbl)]
			end

			if specialRound ~= "None" then
				self:SpecialRoundStart(specialRound)
				return
			else
				local vampire = team.GetPlayers(TEAM_HUMAN)[math.random(team.NumPlayers(TEAM_HUMAN))]
				vampire:SetTeam(TEAM_VAMPIRE)
				vampire:Spawn()
				vampire:SetNWInt("bl_bloodpoints", 2)
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
				net.WriteString("None")
			net.Send(pl)
		end
		
		timer.Create("bl_roundtimer", GAMEMODE.ConVars.TimeLimit:GetInt(), 1, function()
			-- If round was active, stop and set hiders as champions
			if self:GetRoundStatus() == GAME_ACTIVE then
				self:RoundEnd(GAME_HUMANWINTIME)
			-- If round was over, start a new one
			elseif self:GetRoundStatus() == GAME_POSTROUND then
				self:RoundRestart()
			end
		end)
		
	end
	
	function GM:RoundEnd(state)
		timer.Remove("bl_roundtimer")
		
		--Main states
		self.GameState = GAME_POSTROUND
		self.GameCount = self.GameCount - 1
		if state == GAME_HUMANWIN then
			print("HUMANS WIN")
			self:BroadcastMessage(Color(255, 210, 150), "Humans have survived the night!")
			self:BroadcastSound("bloodlust/humanwin.wav")
		elseif state == GAME_HUMANWINTIME then
			print("HUMANS WIN")
			self:BroadcastMessage(Color(255, 210, 150), "The sun is rising, Humans have survived!")
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
				self.GameCount = self.GameCount + 1
			elseif state == GAME_ABORT then
				print("ROUND ABORTED")
				self:BroadcastMessage(Color(255, 210, 150), "The vampires fled, Humans win!")
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
			elseif self.GameCount <= 0 then
				self:BroadcastMessage(Color(255, 255, 255), "Game Over")
				self:BroadcastSound("bloodlust/endgame.wav")
				MapVote.Start(15, false, 12, "bl_")
			end
		end)
	end
	
end