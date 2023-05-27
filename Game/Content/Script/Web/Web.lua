-- ========================================================
-- @File	: Web/Web.lua
-- @Brief	: 网页处理
-- ========================================================

Web = Web or {tbRoute = {}}

---解析连接信息
---@param sUrl string
function Web.Route(sUrl)
    local sLeft = sUrl
    local sType = Split(sLeft, '?')[1]

    local _, SplitPos = string.find(sLeft, '=')
    local sArgs = string.sub(sLeft, SplitPos + 1)
    print("Questionnaire Route", sUrl)
    if not sType then return end
    if Web.tbRoute[sType] then
        Web.tbRoute[sType](sArgs)
    end
end

---解析跳转连接
function Web.ChangeUrl(sUrl)
    print("Questionnaire ChangeUrl", sUrl)
    --1.跳转问卷关闭url
    local pattern = "^" .. Str2Pattern(Questionnaire.CurCallback)
    if Questionnaire.CurCallback ~= '' and string.find(sUrl, pattern)
        or string.find( sUrl, '^https://www%.project%-snow%.com' ) then
            Questionnaire.OnClientFinish()
    end
end

---打开网页链接
---@param sUrl string 链接
---@param pContent UBorder
---@param pWeb UGameWebBrowser
function Web.LoadUrl(sUrl, pContent, pWeb)
    UE4.Timer.NextFrame(function()
        local nWidth = pContent:GetPaintSpaceGeometry()
        local AbsoluteSize = UE4.USlateBlueprintLibrary.GetAbsoluteSize(pContent:GetCachedGeometry())
        sUrl = string.format(sUrl, math.floor(AbsoluteSize.X), math.floor(AbsoluteSize.Y))
        pWeb.ViewportSize = AbsoluteSize
        pWeb:LoadURL(sUrl)
    end);
end

---打开UI处理
Web.tbRoute['openui'] = function(sInfo)
    if not sInfo then return end
    local tbSplit = Split(sInfo, ':')
    local sUIName = tbSplit[1]
    local tbArgs = Eval(tbSplit[2])
    local ui = UI.GetUI('Notice')
    if ui then UI.Close(ui) end
    FunctionRouter.GoToByUIName(sUIName, table.unpack(tbArgs or {}))
end


---关闭UI
Web.tbRoute['closeui'] = function(sUIName)
    if not sUIName then return end
    UI.CloseByName(sUIName)
end


local DecodeURL = function(sUrl)
    return string.gsub(sUrl, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
end

---打开外部网页
Web.tbRoute['openurl'] = function(sUrl)
    sUrl = DecodeURL(sUrl)
    local nStart = string.find(sUrl, '^https?://')
    if nStart == nil then
        sUrl = 'https://' .. sUrl
    end
    UE4.UKismetSystemLibrary.LaunchURL(sUrl)
end