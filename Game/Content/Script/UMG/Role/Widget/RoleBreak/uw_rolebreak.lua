-- ========================================================
-- @File    : uw_rolebreak.lua
-- @Brief   : 角色突破，被动技能主界面
-- @Author  :
-- @Date    :
-- ========================================================

local RoleBreak = Class("UMG.BaseWidget")
RoleBreak.AnimFinish = false
---防止多次打开突破详情界面
RoleBreak.OpenDetail = false
RoleBreak.OpenAnim = false

function RoleBreak:Construct()
    self.tbData = {sSkill = "Skill",sBanner = 'PanelBanner',SPanelPiece = "ImgPiece"}

    -- self.Title
    self.MulBtnState = RBreak.MulBtn.None
    self.tbAttr = {}
    self.BtnUp.OnClicked:Add(self, function()
        --- 最大次数限制
        self.OpenDetail = not self.OpenDetail
        if RBreak.IsLimit(self.Role) then
            UI.ShowTip("tip.Limit_Times")
            return
        end
        local nBreak =  self.Role:Break() % RBreak.NBreakLv
        if self.Role:Break() >0 and nBreak == 8 and RBreak.CheckBreakMat(self.Role) then
            self:ChangePage(false)
            self:BindAnimFinished()
            if not self.OpenAnim then
                WidgetUtils.HitTestInvisible(self.BtnUp)
                WidgetUtils.HitTestInvisible(self.Skill)
                self:PlayAnimation(self.AllEnter, 0, 1, UE4.EUMGSequencePlayMode.Reverse, 1, false)
                EventSystem.TriggerTarget(RBreak,RBreak.ShowStarAnim,self.StarIcon.Outof,1)
                self.OpenAnim = true
            end
            return
        else
            self:OnBreakClick()
        end
    end)
end

function RoleBreak:BindAnimFinished()
    self:BindToAnimationEvent(self.AllEnter,
    {
        self,
        function()
            self:UnbindAllFromAnimationFinished(self.AllEnter)
            self:ChangePage(true)
            self.OpenDetail = not self.OpenDetail
            self:OnBreakClick()
            self.OpenAnim = false
        end
    },
    UE4.EWidgetAnimationEvent.Finished)
end
--- 激活系统主界面
function RoleBreak:OnActive(Template, Form, fun, Card)
    self.nForm = Form
    self.Role = Card or RoleCard.GetItem({Template.Genre, Template.Detail, Template.Particular, Template.Level}) or self.Role
    if not self.Role then return end
    RBreak.InCard = self.Role

    WidgetUtils.SelfHitTestInvisible(self.Skill)
    self:PlayAnimation(self.AllEnter, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    self:ModifierModel(self.Role)
    local nBreak = RBreak.GetProcess(self.Role)
    --- 界面背景碎片和Banner
    self:ShowImgEffect(nBreak)
    --- 界面技能入口
    self:ShowSkill()
    --- 天启
    self.StarIcon:ShowActiveImg(nBreak,1)
    EventSystem.TriggerTarget(RBreak,RBreak.ShowStarAnim,self.StarIcon.Into,1)

    --- 材料列表
    self:GetMaterals(self.Role)
    self:OnLimit(self.Role)
    self:UpdateRedDot()

    EventSystem.Remove(self.AbledBreakHandle)
    self.AbledBreakHandle = EventSystem.OnTarget(RBreak, RBreak.AbleClick, function()
        self:StopAnimation(self.AllEnter)
        self:OnLimit(self.Role)
        WidgetUtils.SelfHitTestInvisible(self.Skill)
        self:PlayAnimation(self.AllEnter, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
        EventSystem.TriggerTarget(RBreak, RBreak.ShowStarAnim, self.StarIcon.Into, 1)
        self.OpenDetail = false
    end)
end

function RoleBreak:UpdateRedDot()
    if RoleCard.CheckCardRedDot(self.Role, {2}) then
        WidgetUtils.HitTestInvisible(self.Red)
    else
        WidgetUtils.Collapsed(self.Red)
    end
end

--- 天启突破材料
function RoleBreak:GetMaterals(InItem)
    -- local tbIds = RBreak.GetBreakProcess(InItem)
    local  tbMat = RBreak.GetBreakMats(InItem)
    if not tbMat then
        -- UI.ShowTip("tip.Limit_Times")
        return
    end
    local  tbParam = {
        G = tbMat[1][1],
        D = tbMat[1][2],
        P = tbMat[1][3],
        L = tbMat[1][4],
        N = {nHaveNum = me:GetItemCount(tbMat[1][1],tbMat[1][2],tbMat[1][3],tbMat[1][4]), nNeedNum= tbMat[1][5]},
        bDetail = true,
    }
    self.MatList:Display(tbParam)
end

function RoleBreak:ChangePage(InState)
    local pParentWidget = UI.GetUI('RoleUpLv')
    if pParentWidget then
        pParentWidget:ChangeState(InState)
    end
end

--- 角色展示模型
function RoleBreak:ModifierModel(InCard)
    RoleCard.ModifierModel(nil, InCard, PreviewType.role_break, UE4.EUIWidgetAnimType.Role_Break)
end

-- 缓存返回点击事件
function RoleBreak:CachCallBack()
    self.FinishClick = function()
        self:FinishBreak()
    end
end

-- 进入天启培养界面，缓存返回动画事件
function RoleBreak:InitAnim(bAnim)
    if not bAnim then
        self:PlayAnimation(self.Anim, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
        Preview.Destroy()
        self:CachCallBack()
        self.AnimFinish = true
    end
end

-- 离开天启界面或则完成当前培养，清理缓存，
function RoleBreak:FinishBreak()
    self:PlayAnimation(self.Anim, 0, 1, UE4.EUMGSequencePlayMode.Reverse, 1, false)
    self.AnimFinish = false
    self:ModifierModel(self.Role)
end


--- 天启界面效果表现
function RoleBreak:ShowImgEffect(InBreakLv)
    local tbImgName = {sBannerImg = "ImgBanner", sPieceImg = "ImgPiece", sAnim = "Active"}
    for i = 1, RBreak.NBreak do
        WidgetUtils.Collapsed(self[tbImgName.sBannerImg..i])
        WidgetUtils.Collapsed(self[tbImgName.sPieceImg..i])
    end
    WidgetUtils.Collapsed(self.ImgBanner1_1)

    for i = 1, RBreak.NBreak do
        if InBreakLv == 1  then
            WidgetUtils.SelfHitTestInvisible(self.ImgBanner1_1)
        elseif i == InBreakLv  then
            WidgetUtils.SelfHitTestInvisible(self[tbImgName.sBannerImg..i])
        end
        if i <= InBreakLv then
            WidgetUtils.SelfHitTestInvisible(self[tbImgName.sPieceImg..i])
            self:PlayAnimation(self[tbImgName.sAnim..i], 0, 99, UE4.EUMGSequencePlayMode.Forward, 1, false)
        end
    end
end

--- 天启主界面入口
function RoleBreak:ShowSkill(InBreakLv)
    local gdpl = self.Role:Genre()..self.Role:Detail()..self.Role:Particular()..self.Role:Level()
    local BreakInfo = RBreak.tbBreakId[tonumber(gdpl)]
    if not BreakInfo then
        WidgetUtils.Collapsed(self.Skill)
        return
    else
        WidgetUtils.SelfHitTestInvisible(self.Skill)
    end
    local tbSkills = BreakInfo.SkillId
    local nBreak ,Temp = math.modf(self.Role:Break()/RBreak.NBreakLv)
    for i = 1, RBreak.NBreak do
        local  SkillState = 0
        if i <= nBreak then
            SkillState = RBreak.BreakState.Actived
        elseif i == nBreak+1 then
            SkillState = RBreak.BreakState.InActivated
        else
            SkillState = RBreak.BreakState.UnActive
        end

        local tbParam = {
            pRole = self.Role,
            Click = function(InId,InState) self:PreSkillDetail(InId,InState,i) end,
            SkillId = tbSkills[i][1],
            SkillState = SkillState,
            Idx = i
        }
        self["Skill"..i]:OnOpen(tbParam)
    end
end

--- 突破技能详情入口
function RoleBreak:PreSkillDetail(InId,InState,InIdx)
    self:ChangePage(false)
    local clickCall = function()
        self:ChangePage(true)
    end
    -- if InIdx == 1 then
    --     UI.Open('RoleSkillDetail',{Card = self.Role,SkillId = InId,SkillState = InState,Idx = InIdx,Click = clickCall})
    --     return
    -- end
    UI.Open("BreakDetail",{Card = self.Role,SkillId = InId,SkillState = InState,Idx = InIdx,Click = clickCall})
end

--- 突破点击事件
function RoleBreak:OnBreakClick()
    RBreak.Req_ByBreak(self.Role, function(InParam)
        local nBreak = RBreak.GetProcess(self.Role)
        self:OnLimit(self.Role)
        Audio.PlaySounds(3017)
        --- 界面技能入口
        self:ShowSkill()
        --- 天启
        self.StarIcon:ShowActiveImg(nBreak,1)
        --- 突破材料刷新
        self:GetMaterals(self.Role)
        --- 需要优话进度条件判断
        if self.Role:Break()%RBreak.NBreakLv == 0 then
            --- 界面背景碎片和Banner
            self:ShowImgEffect(nBreak)
            UI.CloseTopChild()
            UI.Open("RoleBreakTip",self.Role)
            --
            EventSystem.TriggerTarget(
                Survey,
                Survey.PRE_SURVEY_EVENT,
                Survey.RBREAK,
                self.Role:Break(),
                RBreak.NBreakLv
            )
            Adjust.ChapterBreakRecord(self.Role:Break())
        else
            local Attrs = RBreak.GetBreakLvAttr(self.Role)
            for _, value in ipairs(Attrs or {}) do
                UI.ShowTip(Text("cardnode." .. value[1], value[2]))
            end
        end
        --- 红点刷新
        self:UpdateRedDot()
    end)
end

--- 是否达到限制突破等级
function RoleBreak:IsLimitBreakState(InItem)
    if InItem and InItem:Break()>=45 then
        return true
    end
    return false
end

--- 限制状态
function RoleBreak:OnLimit(InItem)
    if InItem:IsTrial() or self.nForm == 5 then   --试玩角色
        WidgetUtils.Collapsed(self.BtnUp)
        WidgetUtils.Collapsed(self.MatList)
        return
    end
    if self:IsLimitBreakState(InItem) then
        WidgetUtils.Collapsed(self.BtnUp)
        WidgetUtils.Collapsed(self.MatList)
    else
        WidgetUtils.Visible(self.BtnUp)
        WidgetUtils.SelfHitTestInvisible(self.MatList)
    end
end

function RoleBreak:OnDestruct()
    self:OnClear()
end

function RoleBreak:OnClear()
    EventSystem.Remove(self.StarIcon.ShowAnim)
    self.StarIcon.ShowAnim = nil
    EventSystem.Remove(RBreak.OnShowTip)
    EventSystem.RemoveAllByTarget(RBreak)
    EventSystem.Remove(self.AbledBreakHandle)
    self.AbledBreakHandle = nil
    EventSystem.Remove(RBreak.AbleClick)
end


function RoleBreak:OnClose()
    self:OnClear()
end

return RoleBreak
