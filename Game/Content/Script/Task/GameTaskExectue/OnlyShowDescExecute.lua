local tbClass = Class()

function tbClass:GetDescription()
	if not self.DataName or not self.FormatByData then
		return Text(self.UIKey)
	end
	local GameTaskActor = self:GetGameTaskActor();
	if IsValid(GameTaskActor) and IsValid(GameTaskActor.TaskDataComponent) then
		return string.format(Text(self.UIKey),GameTaskActor.TaskDataComponent:GetOrAddValue(self.DataName))
	end
end

function tbClass:GetExecuteDescription()
	return self:GetDescription()
end

return tbClass;