-- ========================================================
-- @File    : RandSocketEmitEmitter.lua
-- @Brief   : 随机插槽释放emitter
-- @Author  : Duan
-- @Date    : 2020-11-12
-- ========================================================

---@class USkillEmitter_RandSocketEmitEmitter:USkillEmitter
local RandSocketEmitEmitter = Class()

function RandSocketEmitEmitter:OnEmitSearch()
   -- EmitterSearcher:OnEmitSearch(self);
end


function RandSocketEmitEmitter:OnEmit()  
    self.SocketArrayResult = self:RandomSocket()
end

---@param CheckerInfo FEmitterDataInfo 发生器的信息数组
function RandSocketEmitEmitter:OnEmitBegin()
    --- Param1 : 跟踪Socket名

    self.AllSocket = self:GetStringArrayValue(0); 
    self.RandomCount = self:GetParamintValue(1); 
end


function RandSocketEmitEmitter:RandomSocket()
    if self.AllSocket:Length() <= self.RandomCount then
        return self.AllSocket
    end
    local Result = UE4.TArray(UE4.FString)
    for i = 1, self.RandomCount do
        local Length = self.AllSocket:Length()
        local Index = math.random(1, Length)
        Result:Add(self.AllSocket:Get(Index));
        self.AllSocket:Remove(Index);
    end
    
    return Result;
end

function RandSocketEmitEmitter:GetRandomSocket(Emitter)
    if  self.SocketArrayResult and self.SocketArrayResult:Length() > 0 then
        local SocketName = self.SocketArrayResult:Get(1)
        self.SocketArrayResult:Remove(1);
        return SocketName;
    end
    return UE4.FString("")
end

function RandSocketEmitEmitter:EmitterDestroyLua()
    self:Destroy()
end

return RandSocketEmitEmitter
