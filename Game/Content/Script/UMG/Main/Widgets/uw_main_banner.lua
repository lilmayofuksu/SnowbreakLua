-- ========================================================
-- @File    : uw_main_banner.lua
-- @Brief   : 主界面Banner
-- ========================================================
local tbClass = Class("UMG.SubWidget");

---打开界面
function tbClass:Construct()
    self.ImgBanner:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed);
    self.Pointbox:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed);
    self.OnClicked:Add(self, function()
        local Cur = self.tbSort[self.CurBannerIndex]
        if Cur and Cur.nJump then 
            Banner.Jump(Cur.nJump, table.unpack(Cur.tbJumpParam)) 
        elseif Cur and Cur.sUrl then 
            Web.Route(Cur.sUrl)
        end
    end)

    self.OnTouchMove:Add(self, function (_, dis)
        self:SetCurIndex(self.CurBannerIndex + (dis > 0 and -1 or 1))
    end)
end

function tbClass:Check()
    local cache = Banner.GetSortTable()
    if not self.tbSort or #cache ~= #self.tbSort then 
        return true, cache 
    end

    for i,v in ipairs(cache) do
        if v.nId ~= self.tbSort[i].nId then
            return true, cache
        end
    end

    return false
end

---更新数据
function tbClass:Refresh()
    local bNeedReload, cache = self:Check()
    if not bNeedReload then
        return 
    end
    self:Reset()
    self.tbSort = cache
    if not self.Factory then
        self.Factory = Model.Use(self)
    end

    for index, value in ipairs(self.tbSort) do
        local NewItem =self.Factory:Create(value)
        local NewPoint = self.Factory:Create({ OnClick = function ()
            self:SetCurIndex(index)
        end, Light = index == 1})
        self.ImgBanner:AddItem(NewItem)
        self.Pointbox:AddItem(NewPoint)
        table.insert(self.tbBanner, value)
        table.insert(self.tbPoint, NewPoint.Data)
    end

    self.nCountDown = 5
    self.CurBannerIndex = 1
    if #self.tbBanner <= 1 then 
        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TimerHandle)
        self.TimerHandle = nil
    elseif not self.TimerHandle then
        self.TimerHandle = UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
            {
                self,
                function()
                    if not UI.IsOpen('Main') then return end
                    self.nCountDown = self.nCountDown - 1
                    if self.nCountDown <= 0 then
                        self:SetCurIndex(self.CurBannerIndex + 1)
                    end
                end
            },
            1,
            true
        )
    end
end

function tbClass:OnDestruct()
    UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TimerHandle)
    self.TimerHandle = nil
    self:DoClearListItems(self.ImgBanner)
    self:DoClearListItems(self.Pointbox)
end

function tbClass:Reset()
    UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TimerHandle)
    self.TimerHandle = nil
    self:DoClearListItems(self.ImgBanner)
    self:DoClearListItems(self.Pointbox)
    self.ImgBanner:SetScrollOffset(0)
    self.tbBanner = {}
    self.tbPoint = {}
end

function tbClass:SetCurIndex(Index)
    if self.CurBannerIndex == Index then
        self.nCountDown = 5
        return
    end
    if Index > #self.tbBanner then Index = 1 end
    if Index < 1 then Index = #self.tbBanner end
    self.CurBannerIndex = Index
    self.ImgBanner:SetScrollOffset(Index - 1)
    self.nCountDown = 5

    for i,v in ipairs(self.tbPoint) do
        if v.InObj then
            v.InObj:Update(i == Index)
        end
    end
end

return tbClass;