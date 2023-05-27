local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
	self:DoClearListItems(self.ListRole)
	self.Factory = Model.Use(self)
end

function tbClass:OnOpen(SetNumParamFunc)
    RuntimeState.ChangeInputMode(true)
	local Controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
	local tbDead = {}
	local SlFunc = function (SlIndex)
		self.SelectedIndex = SlIndex
        self.ListRole:RegenerateAllEntries()
	end
    if IsValid(Controller) then
        local lineup = Controller:GetPlayerCharacters()
        for i = 1, lineup:Length() do
            local Character = lineup:Get(i)
            if Character and Character:IsDead() then
            	if not self.SelectedIndex then
            		self.SelectedIndex = i
            	end
            	tbDead[#tbDead + 1] = {Char = Character,Index = i,NowIndex = function ()
                    return self.SelectedIndex;
                end,ClickFunc = SlFunc}
            end
        end
    end

    self:DoClearListItems(self.ListRole)
    for i,v in ipairs(tbDead) do
    	self.ListRole:AddItem(self.Factory:Create(v))
    end

    BtnClearEvent(self.BtnOK)
    BtnAddEvent(self.BtnOK,function ()
        UI.Close(self)
        UI.ShowTip(Text('ui.Defense_LevelShop_GirlChoose'))
    	SetNumParamFunc(self.SelectedIndex)
    end)

    BtnClearEvent(self.BtnNo)
    BtnAddEvent(self.BtnNo,function ()
        UI.Close(self)
        SetNumParamFunc(self.SelectedIndex)
    end)
end

function tbClass:OnClose( ... )
    RuntimeState.ChangeInputMode(false)
end

function tbClass:CanEsc()
    return false
end
return tbClass