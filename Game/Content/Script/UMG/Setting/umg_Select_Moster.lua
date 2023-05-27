-- ========================================================
-- @File    : umg_Select_Moster.lua
-- @Brief   : 刷怪界面
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.SubWidget")


function tbClass:Construct()
    self.tbCamp = {}
    self.Factory = Model.Use(self);
    local OutMonIds = UE4.TArray(UE4.int32)
    local OutMonAIs = UE4.TArray(UE4.int32)
    local OutMonNames = UE4.TArray(UE4.FString)
    local OutMonCampTypes = UE4.TArray(UE4.int32)
    
    UE4.UGMLibrary.GetAllSpawnMons(OutMonIds, OutMonAIs, OutMonNames, OutMonCampTypes)

    for i = 1, OutMonIds:Length() do   
        local CampType = OutMonCampTypes:Get(i)
        if self.tbCamp[CampType] == nil then
            local uw = UE4.UUMGLibrary.GetWidgetFromName(self, "uw_Select_Moster_Camp_C_" .. CampType)
            if uw then
                self.tbCamp[CampType] = uw
            else
                local strPath = string.format("/Game/UI/UMG/Setting/uw_Select_Moster_Camp.uw_Select_Moster_Camp_C");
                local SoftPath = UE4.UKismetSystemLibrary.MakeSoftClassPath(strPath)    
                local SpecialUI = LoadUIAndSetName(SoftPath, tostring(CampType))
                if not SpecialUI then
                    return
                end
                SpecialUI:SetTitle(CampType)
                self.MonScrollBox:AddChild(SpecialUI)
                self.tbCamp[CampType] = SpecialUI
            end
        end
    end
    for K, SpecialUI in pairs(self.tbCamp) do
        self:DoClearListItems(SpecialUI.MonView)
        self.MonScrollBox:AddChild(SpecialUI)
    end

    
    for i = 1, OutMonIds:Length() do
        local CampType = OutMonCampTypes:Get(i)
        local SpecialUI = self.tbCamp[CampType]
        local tb = {
            MonID = OutMonIds:Get(i),
            MonAI = OutMonAIs:Get(i),
            MonName = OutMonNames:Get(i),
            onClick = function (MonID, MonAI)      
                self:OnClickSpawnMonster(MonID, MonAI)
            end
        }
        local pObj = self.Factory:Create(tb)
        SpecialUI.MonView:AddItem(pObj)

        -- local tbNames = Split(strName, "/")
        -- local lpType = self:GetType(tbNames[1])
        -- if #tbNames >= 2 then
            -- self:ShowOneCategory(lpType, OutMonIds:Get(i), OutMonAIs:Get(i), strName)
        -- end
    end
    
end

function tbClass:OnClickSpawnMonster(MonID, MonAI)
    self.ParamsId = MonID
    self.AIid = MonAI
    self:GM_SpawnMonster();
end


return tbClass
