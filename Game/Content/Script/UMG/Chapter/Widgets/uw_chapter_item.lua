-- ========================================================
-- @File    : uw_chapter_item.lua
-- @Brief   : 章节条目
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.NormalBtn, function()
        if not self.ChapterCfg then
            return UI.ShowTip(Text("ui.TxtNotOpen"))
        end
        if not self.ChapterCfg.tbCondition then return end
        local bUnLock, tbLockDes, tbResult = Condition.Check(self.ChapterCfg.tbCondition, true)
        if not bUnLock then
            for i = 1, #self.ChapterCfg.tbCondition do
                if self.ChapterCfg.tbCondition[i][1] == 2 and tbResult[i] == false then
                    local levelId = self.ChapterCfg.tbCondition[i][2]
                    local levelConf = ChapterLevel.Get(levelId)
                    local chapterConf = Chapter.GetChapterCfgByLevelID(levelId)
                    if levelConf and chapterConf then
                        local strDiff = chapterConf.nDifficult == 1 and Text('ui.TxtNormal') or Text('ui.TxtHard')
                        local levelName = GetLevelName(levelConf)
                        UI.ShowTip(string.format(Text('chapter.condition_5'), chapterConf.nID, strDiff, levelName))
                        return
                    end
                end
            end
            UI.ShowTip(tbLockDes[1] or '')
            return
        end
        if self.ClickFun then
            self.ClickFun(self.ChapterCfg)
        end
    end)
    WidgetUtils.Collapsed(self.chapterNum)
    --WidgetUtils.Collapsed(self.TxtCondition)
end

function tbClass:Init(InChapterCfg, InIndex, InClickFun)
    self.ChapterCfg = InChapterCfg
    if not InChapterCfg then return end
    self.ClickFun = InClickFun
    self.nIndex = InIndex

    self.TxtChapter:SetText(Text('ui.main_'..self.nIndex))
    self.TxtChapterLock:SetText(string.format("%02d", self.nIndex))

    if InChapterCfg.nPicture then
        SetTexture(self.UnSelectImg, InChapterCfg.nPicture)
    end

    self.chapterNormal:SetText(Text(InChapterCfg.sName))
    self.New:SetTag(string.format('%d_%d', InChapterCfg.nID, InChapterCfg.nDifficult))

    local bMain, nDifficult, nChapterID = Chapter.IsMain(), InChapterCfg.nDifficult, self.ChapterCfg.nID

    ---星级数量显示
    local nAllNum, nGetNum = Chapter.GetChapterStarInfo(bMain, nDifficult, nChapterID)

    if nAllNum > 0 then
        local precent = nGetNum / nAllNum
        self.numberNormal:SetText(string.format("%02d%%", math.ceil(precent * 100)))
        self.numberNormalLock:SetText(math.ceil(precent * 100) .. '%')
        self.Percent:SetPercent(precent)
        if nGetNum >= nAllNum then
            WidgetUtils.Collapsed(self.zero)
            self.TxtState:SetText(Text('ui.TxtChapterFinish'))
            self.TxtState:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(0.058, 0.08, 0.61, 0.8))
        else
            WidgetUtils.SelfHitTestInvisible(self.zero)
            self.TxtState:SetText(Text('ui.TxtChapterUnfinish'))
            self.TxtState:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(0.0056, 0.0056, 0.0185, 0.8))
        end
    end

    local bUnLock, tbLockDes, tbResult = Condition.Check(self.ChapterCfg.tbCondition, true)
    if bUnLock then
        WidgetUtils.Collapsed(self.LockNode)
        WidgetUtils.SelfHitTestInvisible(self.Normal)
        WidgetUtils.SelfHitTestInvisible(self.numberNormal)
    else
        WidgetUtils.HitTestInvisible(self.LockNode)
        WidgetUtils.Collapsed(self.Select)
        WidgetUtils.Collapsed(self.numberNormal)
        WidgetUtils.Collapsed(self.zero)

        -- self.TxtCondition:SetText(tbLockDes[1])
        -- for i = 1, #self.ChapterCfg.tbCondition do
        --     if self.ChapterCfg.tbCondition[i][1] == 2 and tbResult[i] == false then
        --         self.TxtCondition:SetText(Text('chapter.condition_3'))
        --         break
        --     end
        -- end
    end
end

---暂未开放的章节条目
function tbClass:NotOpenInit()
    self.ChapterCfg = nil
    self.ClickFun = nil
    self.nIndex = nil
    WidgetUtils.HitTestInvisible(self.LockNode)
    WidgetUtils.Collapsed(self.Normal)
    WidgetUtils.Collapsed(self.ProgressLock)
    WidgetUtils.Collapsed(self.New)
    -- self.TxtCondition:SetText(Text("ui.TxtNotOpen"))
end

function tbClass:OnSelect()
    WidgetUtils.SelfHitTestInvisible(self.Select)
    self.bSelect = true
end

function tbClass:UnSelect()
    WidgetUtils.Collapsed(self.Select)
    self.bSelect = false
end

return tbClass
