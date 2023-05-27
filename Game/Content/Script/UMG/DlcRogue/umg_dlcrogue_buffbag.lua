-- ========================================================
-- @File    : umg_dlcrogue_buffbag.lua
-- @Brief   : 小肉鸽活动buff背包界面
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    self:DoClearListItems(self.ListBuff)
    self.Factory = Model.Use(self)
    self.tbIndex = {}
    self.tbBuffItem = {}
    self.BtnTpis:InitHelpImages(30)
end

function tbClass:OnOpen()
    self.ListBuff:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self.Title:SetCustomEvent(UI.CloseTopChild)

    local tbBuff = RogueLogic.GetBuffAndGoodsBuff()
    self:UpdateBuffList(tbBuff)
    if #tbBuff == 0 then
        WidgetUtils.Collapsed(self.BuffTDetail)
    else
        WidgetUtils.SelfHitTestInvisible(self.BuffTDetail)
    end
end

---刷新Buff列表
function tbClass:UpdateBuffList(tbBuff)
    local tbGroupBuff = {}
    for id, v in pairs(tbBuff) do
        v.nGroup = v.nGroup or 0
        tbGroupBuff[v.nGroup] = tbGroupBuff[v.nGroup] or {}
        tbGroupBuff[v.nGroup][id] = v
    end
    self:DoClearListItems(self.ListBuff)

    self.SelectID = nil
    self.tbBuffItem = {}
    for _, tbGroup in pairs(tbGroupBuff) do
        for id, v in ipairs(tbGroup) do
            if not self.SelectID then
                self.SelectID = id
            end
            if self.SelectID == id then
                self.BuffTDetail:UpdatePanel(v)
            end
            local tbInfo = {
                BuffInfo = v,
                bSelect = self.SelectID == id,
                funClick = function ()
                    if self.SelectID == id then
                        return
                    end
                    if self.tbBuffItem[self.SelectID] then
                        self.tbBuffItem[self.SelectID]:SetSelect(false)
                    end
                    if self.tbBuffItem[id] then
                        self.tbBuffItem[id]:SetSelect(true)
                    end
                    self.SelectID = id
                    self.BuffTDetail:UpdatePanel(v)
                end
            }
            local pObj = self.Factory:Create(tbInfo)
            self.ListBuff:AddItem(pObj)
            self.tbBuffItem[id] = pObj.Data
        end
    end
end

function tbClass:OnClose()
end

return tbClass
