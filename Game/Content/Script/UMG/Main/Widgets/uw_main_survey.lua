-- ========================================================
-- @File    : uw_main_survey.lua
-- @Brief   : 问卷子界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    ---变量初始化
    self.History = {}
    ---事件注册
    self.Web.OnUrlChanged:Add( self, function(_, sUrl) 
        table.insert(self.History, sUrl)
        Web.ChangeUrl(sUrl)
    end)
    --完成问卷监视
    BtnAddEvent(self.BtnBack, function () self:Close() end)
    BtnAddEvent(self.BtnRefresh, function () self:Refresh() end)
    ---显示初始化
    WidgetUtils.Visible(self.BG)
end


function tbClass:OnOpen(url)
    Web.LoadUrl(url, self.BG, self.Web)
    --WidgetUtils.Visible(self)
    self.initurl = url
    if IsIOS() then -- IOS重定向不跳转问题
        UE4.Timer.Cancel( self.timerId or 0)
        self.timerId = UE4.Timer.Add(0.5, function() 
            self:Refresh()
        end)
    end
end

--后退, 如果有自动跳转, 只有后退会导致循环, 目前先不用
function tbClass:Back()
    table.remove(self.History)
    if #self.History == 0 then 
        self:Close() 
    else
        print(self.History[#self.History])
    end
end

--刷新
function tbClass:Refresh()
    if not self.History or #self.History == 0 then
        print( "Questionnaire Refresh", self.initurl)
        Web.LoadUrl(self.initurl, self.BG, self.Web)
    else
        print( "Questionnaire Refresh", #self.History)
        Web.LoadUrl(self.History[#self.History], self.BG, self.Web)
    end
end


function tbClass:Close()
    self.History = {}
    UE4.Timer.Cancel( self.timerId or 0)
    Web.LoadUrl('about:blank', self.BG, self.Web)
    --WidgetUtils.Collapsed(self)
    UI.Close(self)
end

return tbClass