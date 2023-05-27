-- ========================================================
-- @File    : uw_role_role_data.lua
-- @Brief   : 角色展示数据
-- ========================================================

local  tbRoleItemData = Class("UMG.SubWidget")
tbRoleItemData.Index = 0
tbRoleItemData.ShowPos = 0
tbRoleItemData.bSelect = false
tbRoleItemData.SelectId = 0
tbRoleItemData.SelectChange = "SELECT_CHANGE"
tbRoleItemData.LevelChange = "LEVEL_CHANGE"
tbRoleItemData.Icon = 0
tbRoleItemData.DefaultFree = -1
tbRoleItemData.tbUnLockMat = nil
tbRoleItemData.Template = nil
tbRoleItemData.DefaultWeaponGPDL = nil
tbRoleItemData.nLv = 0
tbRoleItemData.sName = ""
--- 1:解锁，2：未解锁
tbRoleItemData.nTagLock = 0
--- 来源 1:主界面进 2:编队 3:预览展示 4:试玩角色 5:肉鸽活动增益角色预览 6:编队试玩角色选择
tbRoleItemData.nForm = 0
--- 父界面名
tbRoleItemData.ParentUIName = ""
--- 是否处于爬塔编队
tbRoleItemData.bTowerFormation = false
--- 是否是boss挑战界面
tbRoleItemData.bUIBoss = false
--- 显示血条血量
tbRoleItemData.ShowHP = nil

function tbRoleItemData:SetInForm(InForm)
    self.nForm = InForm
end

function tbRoleItemData:Init(InIndex, InSelect, InTemplate, InClick, InCard)
    self.Index = InIndex
    self.ShowPos = InIndex
    self.bSelect = InSelect
    self.Click = InClick

    if InCard then
        self.pCard = InCard
        self.Template = UE4.UItem.FindTemplateForID(InCard:TemplateId())
    elseif InTemplate then
        self.Template = InTemplate
        self.pCard = RoleCard.GetItem({InTemplate.Genre, InTemplate.Detail, InTemplate.Particular, InTemplate.Level})
    end

    local tbgdpln = nil
    local function CardId()
        if self.pCard then
            self.nTagLock = 1
            self.nLv = self.pCard:EnhanceLevel()
            return self.pCard:Id()
        else
            self.nTagLock = 2
            self.nLv = 1
            return 0
        end
    end
    self.SelectId = CardId()
    self.Icon = self.Template.Icon
    -- self.DefaultFree = self.Template.ForFree
    self.DefaultWeaponGPDL = self.Template.DefaultWeaponGPDL
    self.sName = self.Template.I18N
    tbgdpln = self.Template.PiecesGDPLN

    local function gdpln()
        if tbgdpln:Length()>1 then
            return tbgdpln:Get(1), tbgdpln:Get(2), tbgdpln:Get(3), tbgdpln:Get(4),tbgdpln:Get(5)
        end
    end

    local g,d,p,l,n = gdpln()
    local function COLOR(InG,InD,InP,InL,InN)
        if InN and InN > me:GetItemCount(InG,InD,InP,InL) then
            return {1,0,0,1}
        else
            return {0,0,0,1}
        end
    end
    self.tbUnLockMat = {
        N = n or 'max',
        Need = me:GetItemCount(g,d,p,l),
        Color = COLOR(g,d,p,l,n)
    }
end

function tbRoleItemData:SetSelect(InSelect)
    if self.bSelect ~= InSelect then
        self.bSelect = InSelect
        EventSystem.TriggerTarget(self, self.SelectChange)
    end
end

function tbRoleItemData:UpdateLevel()
    if self.pCard then
        self.nLv = self.pCard:EnhanceLevel()
        EventSystem.TriggerTarget(self, self.LevelChange)
    end
end

function tbRoleItemData:OnDestruct()
    EventSystem.Remove(self.SelectChange)
    EventSystem.Remove(self.LevelChange)
end

return tbRoleItemData