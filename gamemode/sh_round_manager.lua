GAME_PREROUND, GAME_ACTIVE, GAME_POSTROUND = 1, 2, 3

GAME_HUMANWIN, GAME_VAMPIREWIN, GAME_RESTART, GAME_ABORT = 1, 2, 3, 4

GM.GameTime = 0
GM.GameCount = -1
GM.GameState = GM.GameState or GAME_PREROUND
GM.GameIdle = true

if SERVER then

	function GM:GetRoundStatus()
		--Return the current round's status
		return self.GameState
	end
	
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
			if #player.GetAll() >= 3 and self.GameIdle then
				self.GameIdle = false
				self:BroadcastMessage(Color(255, 255, 255), "Enough players connected, Starting game...")
				timer.Simple(5, function()
					self:RoundRestart()
				end)
			end
		end
	end

	function GM:RoundRestart()
		--Clean up and restart
		game.CleanUpMap()
		
		--Reset the table and insert active players into the table
		if activePlayers then
			table.Empty(activePlayers)
			for k, pl in pairs(player.GetAll()) do
				table.insert(activePlayers, pl)
			end
		end
		
		--Set teams and respawn the player
		for _, pl in pairs(player.GetAll()) do
			if pl:Team() == TEAM_VAMPIRE then
				pl:SetTeam(TEAM_HUMAN)
			else
				pl:SetTeam(TEAM_HUMAN)
			end
			pl:Spawn()
		end
		
		--If there are more than 2 humans, 
		if #player.GetAll() >= 3 then
			timer.Simple(0.1, function()
				self.GameState = GAME_ACTIVE
				self.GameCount = self.GameCount + 1
				self:BroadcastSound("bloodlust/roundstart.wav", ply)
			end)
			self:RoundTime(self.ConVars.TimeLimit:GetInt())
			
			--local vampire = team.GetPlayers(TEAM_HUMAN)[math.random(team.NumPlayers(TEAM_HUMAN))]
			local vampire = team.GetPlayers(TEAM_HUMAN)[3]
			vampire:SetTeam(TEAM_VAMPIRE)
			vampire:Spawn()
			timer.Simple(0.1, function()
				vampire:Give("weapon_crowbar")
			end)
			
			if #player.GetAll() >= GAMEMODE.ConVars.MinHunters:GetInt() then
				local hunter = team.GetPlayers(TEAM_HUMAN)[math.random(team.NumPlayers(TEAM_HUMAN))]
				hunter:SetTeam(TEAM_HUNTER)
				hunter:Spawn()
				timer.Simple(0.1, function()
					hunter:Give("weapon_crossbow")
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
		if state == GAME_HUMANWIN then
			print("HUMANS WIN")
			self:BroadcastMessage(Color(255, 210, 150), "Humans have survived the night!")
			self:BroadcastSound("bloodlust/endround.wav")
		elseif state == GAME_VAMPIREWIN then
			print("VAMPIRES WIN")
			self:BroadcastMessage(Color(165, 5, 5), "Vampires have conquered the humans!")
			self:BroadcastSound("bloodlust/endround.wav")
		else
			--Other states if main states are not met
			if state == GAME_RESTART then
				print("RESTARTING ROUND...")
				self:BroadcastMessage(Color(255, 255, 255), "The round is being restarted")
			elseif state == GAME_ABORT then
				print("ROUND ABORTED")
			end
		end
		
		timer.Simple(10, function()
			self:RoundRestart()
		end)
	end
	
end