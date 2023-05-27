-- ========================================================
-- @File    : umg_gacha_choosetip.lua
-- @Brief   : 扭蛋界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    self.List:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
end

function tbClass:OnInit()
    BtnAddEvent(self.BtnOK, function()
        if not self.currentParam or not self.nId then
            return
        end
        local cfg = Gacha.GetCfg(self.nId)
        if not cfg then return end

        local newSelectUP = self.currentParam.gdpl
        local oldSelectUP = cfg:GetSelectUp()
        if oldSelectUP and oldSelectUP[1] == newSelectUP[1] and oldSelectUP[2] == newSelectUP[2] and oldSelectUP[3] == newSelectUP[3] and oldSelectUP[4] == newSelectUP[4] then
            UI.Close(self)
            return
        end
        Gacha.Req_UpSelect(self.nId, self.currentParam.gdpl)
    end)
end


function tbClass:OnOpen(nId)
    WidgetUtils.SelfHitTestInvisible(self.BG)
    self.nId = nId or self.nId
    if not self.nId then return end

    local cfg = Gacha.GetCfg(self.nId)
    if not cfg then return end

    self:DoClearListItems(self.List)

    self.Factory = self.Factory or Model.Use(self)

    local tbShow = Gacha.GetUps(cfg) or {}
    local selectUP = cfg:GetSelectUp()

    self.tbCacheParam = {}

    local nNavigateIndex = 0

    for idx, gdpl in ipairs(tbShow) do
        if gdpl then
            local bSelect = false
            if selectUP and selectUP[1] == gdpl[1] and selectUP[2] == gdpl[2] and selectUP[3] == gdpl[3] and selectUP[4] == gdpl[4] then
                bSelect = true
            end

            local tbParam = {
                gdpl = gdpl,
                bSelect = bSelect,
                OnClick = function(data)
                    self:OnSelectChange(data)
                end,
                SetSelected = function(tbSelf)
                    EventSystem.TriggerTarget(tbSelf, "SET_SELECTED")
                end
            }

            if bSelect then
                self.currentParam = tbParam
                nNavigateIndex = idx - 1
            end

            local pObj = self.Factory:Create(tbParam)
            self.List:AddItem(pObj)

            table.insert(self.tbCacheParam, tbParam)
        end
    end

    if self.currentParam == nil then
        nNavigateIndex = 0
        self:OnSelectChange(self.tbCacheParam[1])
    end

    self.List:NavigateToIndex(nNavigateIndex)
end

function tbClass:OnSelectChange(param)
    if not param then return end

    if self.currentParam == param then
        return
    end

    if self.currentParam then
        self.currentParam.bSelect = false
        self.currentParam:SetSelected()
    end
    self.currentParam = param
    if self.currentParam then
        self.currentParam.bSelect = true
        self.currentParam:SetSelected()
    end
end

function tbClass:OnSelectRsp()
    if self.currentParam and self.currentParam.gdpl then
        local g, d, p, l = table.unpack(self.currentParam.gdpl)
        local pTemplate = UE4.UItem.FindTemplate(g, d, p, l)
        if pTemplate then
            UI.ShowTip(Text('tip.gacha.AssignUp', Text(pTemplate.I18n)))
        end
    end
    UI.Call2('Gacha', 'RefreshSelectUP')
    UI.Close(self)
end

return tbClass