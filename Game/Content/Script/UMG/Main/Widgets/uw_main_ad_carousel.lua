-- ========================================================
-- @File    : uw_main_ad_carousel.lua
-- @Brief   : 登录公告打脸界面
-- ========================================================

local tbNotice = Class("UMG.BaseWidget")
tbNotice.CheckPath = "/Game/UI/UMG/Widgets/uw_widgets_page_point.uw_widgets_page_point_C"
tbNotice.BannerPath = "/Game/UI/UMG/Main/Widgets/uw_banner_ad.uw_banner_ad_C"
tbNotice.BannerTimer = nil
tbNotice.Idx = 1

--- 界面初始化
function tbNotice:Construct()
    self:AddPoints()
    self:UpDatdPoints(Banner.InIdx)
    self:CachImage(Banner.tbBanner)

    self.AdList.OnCenterIndexChange:Add(
        self,
        function()
            self:UpDatdPoints(self.AdList:GetCenterIndex()+1)
        end
    )
end


function tbNotice:OnMouseButtonDown(MyGeometry,InTouchEvent)
    UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.BannerTimer)
    -- body()
end

function tbNotice:OnMouseButtonUp(MyGeometry,InTouchEvent)
    self:UpDate()
    self:Timer() 
end

--- 刷新显示数据
function tbNotice:UpDate()
    local function GetIdx(Index)
        if #Banner.tbBanner > Index then
            self.Idx = Index+1
        else
            self.Idx = 1
        end
        return self.Idx
    end
    local CurIdx = self.AdList:GetCenterIndex()
    self.AdList:SetCurrentIndex(GetIdx(CurIdx+1))
    self:OnChanegTexture(self.Idx)
    self:UpDatdPoints(self.Idx)
end

--- 刷新公告
function tbNotice:Tick(MyGeometry, InDeltaTime)
   -- body()
end

function tbNotice:OnOpen()
    self:Timer()
end


function tbNotice:Timer()
    self.BannerTimer = UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
        {
            self,
            function()
                self:UpDate()
            end
        },
        2.0,
        true
    )
end

--- 切换背景
function tbNotice:OnChanegTexture(Idx)
    self.AdList:SetCurrentIndex(Idx-1)
end

--- 添加轮播标记点展示
function tbNotice:UpDatdPoints(InIdx)
    for i = 1, self.PointsTag:GetChildrenCount() do
        local tbParam = {
            Index = i,
            bState = false,
        }
        if InIdx == i then
            tbParam.bState = true
        end
        self.PointsTag:GetChildAt(i-1):OnOpen(tbParam)
    end
end

function tbNotice:AddPoints()
    if self.PointsTag:HasAnyChildren() then
        self.PointsTag:ClearChildren()
    end
    for key, value in pairs(Banner.tbBanner) do
        local pPoint = LoadWidget(self.CheckPath)
        local tbParam = {
            Index = key,
            bState = false,
        }
        self.PointsTag:AddChild(pPoint)
    end
end

function tbNotice:CachImage(tbData)
    self.AdList:ClearChildren()
    for key, value in pairs(tbData) do
        local pBannerItem = LoadWidget(self.BannerPath)
        local  tbParam = {
            Idx = key,
            Data = value,
            ClickFun = function(InSelect)
                if Banner.tbBanner[InSelect].nJump then
                    FunctionRouter.GoTo(Banner.tbBanner[InSelect].nJump, table.unpack(Banner.tbBanner[InSelect].tbJumpParam))
                end
                if self.TimaHandle then
                    UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.BannerTimer)
                end
            end,
        }
        pBannerItem:OnInit(tbParam)
        self.AdList:AddChild(pBannerItem)
    end
    self.AdList:SetCurrentIndex(0)
end


function tbNotice:OnClose()
    UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.BannerTimer)
end

return tbNotice