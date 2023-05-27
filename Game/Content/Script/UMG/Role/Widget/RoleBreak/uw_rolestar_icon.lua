-- ========================================================
-- @File    : uw_rolestar_icon.lua
-- @Brief   : 角色突破品质表现
-- @Author  :
-- @Date    :
-- ========================================================

local RoleStar = Class("UMG.SubWidget")

function RoleStar:Construct()
    self.ShowAnim = EventSystem.OnTarget(RBreak, RBreak.ShowStarAnim, function(Target,InAnim,InNum)
        self:PlayShowAnim(InAnim,InNum)
    end)
end

function RoleStar:OnDestruct()
    if self.ShowAnim then
        EventSystem.Remove(self.ShowAnim)
        self.ShowAnim = nil
    end
end

--- 常规显示天启等级
function RoleStar:ShowBreakLv(InItem,nOffset)
    self.tbBreakLv={self.ImgI,self.ImgII,self.ImgIII,self.ImgIIII,self.ImgMax}
    for index, value in ipairs(self.tbBreakLv) do
        WidgetUtils.Hidden(value)

    end
    if InItem then
        WidgetUtils.SelfHitTestInvisible(self.tbBreakLv[InItem:Break()+nOffset])
    end
end

function RoleStar:ChangeLvColor(InWidget,InState)
    InWidget:SetColorAndOpacity(InState)
end


--- 激活状态
---@param InBreakLv Integer 突破等级
---@param InFrom Integer 跳转1:来源于需要预览的界面
function RoleStar:ShowActiveImg(InBreakLv,InFrom)
    local tbImgName = { sActiveImg = 'ImgActive',sLockImg = "ImgNotActice",sPreImg = "ImgNext",sPreAnimImg = "PanelNextLoop"}
    --- 初始化
    for i = 1, 5 do
        WidgetUtils.Collapsed(self[tbImgName.sActiveImg..i])
        WidgetUtils.Collapsed(self[tbImgName.sLockImg..i])
        WidgetUtils.Collapsed(self[tbImgName.sPreImg..i])
        WidgetUtils.Collapsed(self[tbImgName.sPreAnimImg..i])
    end

    for i = 1, 5 do
        --- 激活状态
        if i > InBreakLv then
            WidgetUtils.Collapsed(self[tbImgName.sActiveImg..i])
        else
            WidgetUtils.SelfHitTestInvisible(self[tbImgName.sActiveImg..i])
        end

        --- 锁定状态
        if i >= InBreakLv then
           WidgetUtils.SelfHitTestInvisible(self[tbImgName.sLockImg..i])
        else
            WidgetUtils.Collapsed(self[tbImgName.sLockImg..i])
        end

        --- 预览状态
        if InFrom and InFrom == 1 then
            if i == InBreakLv + 1 then
                if self[tbImgName.sPreImg..i] and  self[tbImgName.sPreAnimImg..i] then
                    WidgetUtils.SelfHitTestInvisible(self[tbImgName.sPreImg..i])
                    WidgetUtils.SelfHitTestInvisible(self[tbImgName.sPreAnimImg..i])
                end
            else
                if self[tbImgName.sPreImg..i] and self[tbImgName.sPreAnimImg..i] then
                    WidgetUtils.Collapsed(self[tbImgName.sPreImg..i])
                    WidgetUtils.Collapsed(self[tbImgName.sPreAnimImg..i])
                end
            end
        end
    end

    if InFrom and InFrom == 1 then
        EventSystem.TriggerTarget(RBreak,RBreak.ShowStarAnim,self.Next,99)
    end
end

--- 播放展示动画
function RoleStar:PlayShowAnim(InAnim,InNum)
    if InAnim and not self:IsAnimationPlaying(InAnim) then
        self:PlayAnimation(InAnim, 0, InNum or 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    end
end

return RoleStar