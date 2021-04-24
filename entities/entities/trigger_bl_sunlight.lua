
ENT.Type = "brush"
ENT.Base = "base_brush"

function ENT:KeyValue(key, value)
	if key == "CaughtUndead" then
		self:StoreOutput(key, value)
	end
end

function ENT:AcceptInput(name, activator, caller)
	print("?")
	print(name)
	if name == "SunlightCheck" then


		self:TriggerOutput("CaughtUndead", activator)

		return true
	end
end