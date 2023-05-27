-- @File    : uw_dungeonschallenge_block.lua
-- @Brief   : 活动选择界面
-- ========================================================
---@class tbClass : ULuaWidget
local tbClass = Class('UMG.SubWidget')

function tbClass:Construct()
    BtnAddEvent(self.Tower, function()
        if self.cfg and self.cfg.FunClick then
            self.cfg.FunClick()
        end
    end)
end

function tbClass:OnListItemObjectSet(pObj)
    self:Init(pObj.Data)
end

function tbClass:Init(cfg)
    self.cfg = cfg
    if cfg.nId then
        local bUnlock, tbTip = FunctionRouter.IsOpenById(cfg.nId)
        if bUnlock then
            WidgetUtils.Collapsed(self.Lock)
        else
            WidgetUtils.SelfHitTestInvisible(self.Lock)
            if self.TxtLimit then
                WidgetUtils.SelfHitTestInvisible(self.TxtLimit)
                self.TxtLimit:SetText(tbTip[1] or '')
            end
        end
    end
    SetBtnTexture(self.Tower, cfg.nPicture)
    self.TxtName:SetText(cfg.sName)
    if cfg.nNameImg then
        SetTexture(self.ImgName, cfg.nNameImg)
    else
        SetTexture(self.ImgName, 1701150)
    end
end

return tbClass