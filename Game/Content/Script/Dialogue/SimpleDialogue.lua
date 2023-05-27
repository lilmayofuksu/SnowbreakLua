-- ========================================================
-- @File    : SimpleDialogue.lua
-- @Brief   : 
-- ========================================================
Dialogue = Dialogue or {
    tbData          = {},
    tbAllLanguage   = {},
};

Dialogue.ShowDialog = true

function Dialogue.Load()
    Dialogue.tbData = {}
    Dialogue.tbAllLanguage = {}
    local Is_zh_CN = Localization.sLanguage == "zh_CN"
    local FilePath = "dialogue/SimpleDialogue/SimpleDialogue.txt"
    local AllLanguageFilePath = "all_language/dialogue/SimpleDialogue/SimpleDialogue.txt"
    local tbConfig = LoadCsv(FilePath, 1)
    local tbAllLanguageConfig

    --- 加载多语言表格
    if not Is_zh_CN then
        tbAllLanguageConfig = LoadCsv(AllLanguageFilePath, 1)
        for _, tbLine in pairs(tbAllLanguageConfig) do
            local tbData = {}
            local key = tbLine.Key or ""
            if key ~= "" then
                for key, value in pairs(tbLine) do
                    if key ~= "Key" then
                        tbData[key] = value
                    end
                end
            end
            Dialogue.tbAllLanguage[key] = tbData
        end
    end

    --- 加载中文语言表格
    local IdNow
    for _, tbLine in pairs(tbConfig) do
        local Id = tbLine.Id
        if Id then
            if Id == IdNow then
                print("dialogue/SimpleDialogue/SimpleDialogue.txt 配置重复 Id:%s", Id)
            end
            IdNow = Id
            if not Dialogue.tbData[IdNow] then
                Dialogue.tbData[IdNow] = {}
            end
        end

        local tbInfo = {}

        local NowKey = tbLine.Key
        if NowKey == nil or NowKey == "" then break end
        for key, value in pairs(tbLine) do
            if key == "zh_CN" and not Is_zh_CN then
                if not Dialogue.tbAllLanguage[NowKey] then
                    tbInfo[Localization.sLanguage] = ""
                else
                    tbInfo[Localization.sLanguage] = Dialogue.tbAllLanguage[NowKey][Localization.sLanguage] or ""
                end
            else
                tbInfo[key] = value
            end
        end

        if Dialogue.tbData[IdNow] then
            table.insert(Dialogue.tbData[IdNow], tbInfo)
        end
    end
end

if not SERVER_ONLY then
    Dialogue.Load();
end
