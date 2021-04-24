
ENT.Type = "point"
ENT.Base = "base_point"

local Side_ANY = 0

ENT.Side = Side_ANY

function ENT:KeyValue(key, value)
	if key == "OnPass" or key == "OnFail" then
		self:StoreOutput(key, value)
	elseif key == "Side" then
		self.Side = tonumber(value)
		if not self.Side then
			ErrorNoHalt("bl_logic_side: bad value for Side key, not a number\n")
			self.Side = Side_ANY
		end
	end
end


function ENT:AcceptInput(name, activator)
	if name == "HolyReveal" then
		if IsValid(activator) and activator:IsPlayer() then
			local activator_role = activator:Team()

			if self.Role == ROLE_ANY or self.Role == activator_role then
				print(2, activator, "passed logic_role test of", self:GetName())
				self:TriggerOutput("OnPass", activator)
			else
				print(2, activator, "failed logic_role test of", self:GetName())
				self:TriggerOutput("OnFail", activator)
			end
		end

		return true
	end
end

