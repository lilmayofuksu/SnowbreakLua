-- ========================================================
-- @File    : uw_general_props_one.lua
-- @Brief   : 通用道具显示
-- ========================================================

---数据格式模板
-- local tbParam={
--     G        = 1,
--     D        = 1,
--     P        = 1,
--     L        = 1,
--     N        = -1,  --道具需求数量 -1 或者 nil 为不显示需求数量
--     nHaveNum = -1,  --道具拥有数量 -1 或者 nil 则查找数量
--     OnSelect = nil  --选中事件
--     bFirt    = false  --是否显示首通奖励标记
-- }


local tbClass = Class("UMG.SubWidget")

---被添加时初始化
function tbClass:OnListItemObjectSet(pObj)
    self:Update(pObj.Data or pObj.Logic)
end

function tbClass:Update(tbArg)
    self.tbParam = tbArg
    function self.tbParam.SetSelect(_, bSelect)
        if bSelect then
            WidgetUtils.Visible(self.click);
        else
            WidgetUtils.Hidden(self.click);
        end;
        self.bSelected = bSelect;
    end
    local nHaveNum = 0;
    if self.tbParam.nHaveNum and self.tbParam.nHaveNum >= 0 then
        nHaveNum = self.tbParam.nHaveNum;
    else
        nHaveNum = me:GetItemCount(self.tbParam.G,self.tbParam.D,self.tbParam.P,self.tbParam.L)
    end
    if nHaveNum > 0 then
        WidgetUtils.HitTestInvisible(self.Num)
        Color.Set(self.nHave,Color.DefaultColor)
        self.nNeed:SetText(self.tbParam.N)
        self.nHave:SetText(nHaveNum)
        if self.tbParam.N then
            self.nNeed:SetText("/"..self.tbParam.N)
            if self.tbParam.N< nHaveNum then
                Color.Set(self.nHave,Color.WarnColor)
            end
        end
       
    else
        WidgetUtils.Collapsed(self.Num)
    end
    local pItemTemplate = UE4.UItem.FindTemplate(self.tbParam.G,self.tbParam.D,self.tbParam.P,self.tbParam.L)
    if pItemTemplate then
        SetTexture(self.Icon, pItemTemplate.Icon);
    end
    WidgetUtils.Hidden(self.click);

    if self.tbParam.bFirt then
        WidgetUtils.HitTestInvisible(self.FirstFlag)
    else
        WidgetUtils.Collapsed(self.FirstFlag)
    end
end

---点击Down时的回调
function tbClass:OnMouseButtonDown()
    WidgetUtils.Visible(self.click);
    return UE4.UWidgetBlueprintLibrary.Handled()
end

---点击Up时的回调
function tbClass:OnMouseButtonUp()
    if not self.tbParam.OnSelect then
        -- 打开掉落途径
        ---显示道具提示信息
        UI.Open("ItemInfo", self.tbParam.G, self.tbParam.D, self.tbParam.P, self.tbParam.L, self.tbParam.N or 1)
        --UI.Open("DropWay", self.tbParam.G,self.tbParam.D,self.tbParam.P,self.tbParam.L);
        WidgetUtils.Hidden(self.click);
        return UE4.UWidgetBlueprintLibrary.Handled()
    end

    if self.tbParam.bSelected then
        WidgetUtils.Hidden(self.click);
        self.bSelected = false;
    else
        self.bSelected = true;
    end

    self.tbParam.OnSelect(self.bSelected)

    return UE4.UWidgetBlueprintLibrary.Handled()
end

---鼠标离开时则取消按下选中
function tbClass:OnMouseLeave()
    if not self.bSelected then
        WidgetUtils.Hidden(self.click);
    end
    return UE4.UWidgetBlueprintLibrary.Handled()
end

return tbClass
