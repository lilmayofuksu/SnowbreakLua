-- ========================================================
-- @File    : Loading/Loading.lua
-- @Brief   : Loading图/Tips 逻辑
-- ========================================================

Loading = Loading or {}

local var = {sPath = nil , sTitle = nil, sContent = nil, nTipPos = nil}

---指定loading图 只生效一次
function Loading.AppointPicture(Path, Title, Content, TipPos)
    if not Path then
        var.sPath = nil
        var.sTitle = nil
        var.sContent = nil
        var.nTipPos = nil
        return
    end
    if type(Path) == "number" then
        var.sPath = Resource.Get(Path)
    else
        var.sPath = Path
    end
    var.sTitle = Title
    var.sContent = Content
    var.nTipPos = TipPos
end

function Loading.LoadConfig()
    Loading.tbLoadConf = {}
    local tbFile = LoadCsv('chapter/loading.txt', 1)
    for _, tbLine in ipairs(tbFile) do
        local Id = tonumber(tbLine.ID) or 0
        if Id > 0 then
            local tb = {}
            tb.nId = Id
            tb.nPicture = tonumber(tbLine.Picture)
            tb.sTitle = tbLine.Title and 'Loading.'.. tbLine.Title or ""
            tb.sContent = tbLine.Content and 'Loading.'.. tbLine.Content or ""
            tb.tbCondition = Eval(tbLine.Condition) or {}
            tb.nRate = tonumber(tbLine.Rate) or 0
            tb.nTipPos = tonumber(tbLine.TipsPos) or 0
            Loading.tbLoadConf[Id] = tb
        end
    end
    print('chapter/loading.txt')
end

function Loading.GetLoadingConf()
    local InfoArray = UE4.TArray(UE4.FString)

    if var.sPath ~= nil then
        InfoArray:Add(var.sPath)
        InfoArray:Add(var.sTitle or "")
        InfoArray:Add(var.sContent or "")
        InfoArray:Add(tostring(var.nTipPos or 0))
        Loading.AppointPicture(nil)
        return InfoArray
    end

    local tbCanShow, nTotalRate = {}, 0
    for _, tbInfo in ipairs(Loading.tbLoadConf) do
        if tbInfo.nRate > 0 and Condition.Check(tbInfo.tbCondition) then
            nTotalRate = nTotalRate + tbInfo.nRate
            table.insert(tbCanShow, {Id = tbInfo.nId, nRate = nTotalRate})
        end
    end
    if nTotalRate == 0 then return end
    local nRandom = math.random(1, nTotalRate)
    for _, tb in ipairs(tbCanShow) do
        if nRandom <= tb.nRate then
            local tbConf = Loading.tbLoadConf[tb.Id]
            local path = Resource.Get(tbConf.nPicture)
            InfoArray:Add(path)
            InfoArray:Add(tbConf.sTitle)
            InfoArray:Add(tbConf.sContent)
            InfoArray:Add(tostring(tbConf.nTipPos))
            return InfoArray
        end
    end
end

Loading.LoadConfig()
