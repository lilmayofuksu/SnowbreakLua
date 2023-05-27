-- ========================================================
-- @File    : Localization.lua
-- @Brief   : 本地化
-- ========================================================
Localization = Localization or {
    tbData      = {}, 
    sLanguage   = UE4.UGameLibrary.GetGameIni_String('Distribution', 'Language', 'zh_CN'),
    tbLanguage = {'zh_CN','zh_TW','ja_JP','ko_KR','en_US', 'de_DE', 'fr_FR', 'es_ES', 'id_ID', 'th_TH'},
    tbLanguageDesc = {'简体中文','繁体中文','日语','韩语','英语','德语','法语','西语','印尼语','泰语'},     -- GM界面需要使用
    tbOverseaLanguage = {'zh_CN', 'zh_TW', 'en_US', 'ja_JP', 'ko_KR', 'de_DE', 'fr_FR', 'es_ES', 'id_ID', 'th_TH'},
    tbOverseaLanguageImgs = {'1003036', '1003037', '1003038', '1003039', '1003040', '1003052','1003053', '1003054','1003055','1003056'},
    tbLanguageImgs = {'1003036','1003037','1003039','1003040','1003038', '1003052','1003053', '1003054','1003055','1003056'},
    tbAreaKey = {
        ['zh_CN'] = 'cbjq',
        ['zh_TW'] = 'cbjq_tc',
        ['ja_JP'] = 'cbjq_jp',
        ['ko_KR'] = 'cbjq_kr',
        ['en_US'] = 'cbjq_en'
    },
    tbOverseaAreaKey = {
        ['zh_TW'] = 'cbjq_tc',
        ['ja_JP'] = 'cbjq_jp',
        ['ko_KR'] = 'cbjq_kr',
        ['en_US'] = 'cbjq_en'
    },
    bForceShowLanguageSelect = false,
    tbVoiceLanguage = {'Chinese', 'Japanese', 'English(US)'},
    tbSpecialFile = {'skill_describe', 'spine'},
    tbOverseaVoiceImgs = {'1003050', '1003039', '1003038'},
    tbVoiceImgs = {'1003057', '1003058'},
};

--[[
xgsdk支持语言
ja  日本语
ko  韩语
th  泰语
zh-Hant  繁体中文
en  英语
it  意大利语
in  印尼语
es  西班牙语
ru  俄语
de  德语
fr  法语
]]--

Localization.DateFormat = {
    ["en_US"] = "%m-%d-%Y-%H:%M",
    ["it_IT"] = "%Y-%m-%d-%H:%M",
    ["fr_FR"] = "%d-%m-%Y-%H:%M",
    ["es_ES"] = "%d-%m-%Y-%H:%M",
    ["de_DE"] = "%d-%m-%Y-%H:%M",
    ["ru_RU"] = "%Y-%m-%d-%H:%M",
    ["ko_KR"] = "%Y-%m-%d-%H:%M",
    ["ja_JP"] = "%Y-%m-%d-%H:%M",
    ["zh_TW"] = "%Y-%m-%d-%H:%M",
    ["zh_CN"] = "%Y-%m-%d-%H:%M",
    ["th_TH"] = "%d-%m-%Y-%H:%M",
    ["id_ID"] = "%Y-%m-%d-%H:%M",
}

local xgsdk_language = {
    ['zh_TW'] = 'zh-Hant',
    ['ja_JP'] = 'ja',
    ['ko_KR'] = 'ko',
    ['en_US'] = 'en',
    ['zh_CN'] = 'zh-Hans',
    ['de_DE'] = 'de',
    ['fr_FR'] = 'fr',
    ['es_ES'] = 'es',
    ['id_ID'] = 'in',
    ['th_TH'] = 'th',
}
function Localization.ConvertToXgsdkLanguage(lan)
    return xgsdk_language[lan]
end

-- GM界面所需
function Localization.GetGMLangTable()
    local tb = {}
    for i, v in ipairs(Localization.tbLanguage) do 
        table.insert(tb, string.format("%s-%s",  Localization.tbLanguageDesc[i] or "未知", v))
    end
    return tb;
end

---切换语言
---@param sLanguage string 语言名称
function Localization.SwitchLanguage(sLanguage)
    local sCurrentLanguage = Localization.GetCurrentLanguage()
    print('Localization.SwitchLanguage:', sLanguage, sCurrentLanguage)
    if not sLanguage then return end

    local xgsdk_lan = Localization.ConvertToXgsdkLanguage(sLanguage)
    print("swith language", sLanguage, xgsdk_lan)
    if xgsdk_lan then
        UE4.UGameLibrary.SwitchLanguage(xgsdk_lan)
        UE4.UGameLibrary.SetGameIni_String('Distribution', 'xgsdk_language', xgsdk_lan)
    end

    if sCurrentLanguage == sLanguage then return end
    Localization.sLanguage = sLanguage
    Localization.Load()
    Dialogue.Load()
    UE4.UGameLibrary.SetGameIni_String('Distribution', 'Language', sLanguage)
    UE4.ULocalizationSubSystem.ReloadFontConfig()

    Localization.NotifyLanSetting(4, sLanguage)

    local loginUI = UI.GetUI('Login')
    if loginUI then
        loginUI:RefreshText()
    else
        UI.ReOpen();
    end
    EventSystem.TriggerToAll(Event.LanguageChange, sLanguage)
end

---登录检查是否提示切换语言
function Localization.CheckLanguageTip()
    local sCurrentLan = Localization.GetCurrentLanguage()
    local curVoice = Localization.GetCurrentVoiceLanguage()
    local bChecked = false
    for index, value in ipairs(Localization.tbVoiceLanguage) do
        if value == curVoice then
            bChecked = true
            break
        end
    end

    if bChecked and curVoice then
        Localization.SetCurrentVoiceLanguage(curVoice)
    else
        Localization.ChangeVoiceLanguage(sCurrentLan)
    end

    if not Login.IsOversea() then 
        return 
    end

    local sAsked = UE4.UGameLibrary.GetGameIni_String('Distribution', 'CheckLanguageTip', "")
    if sAsked == "Set" then return end

    --打点
    Adjust.DoRecord("2jfh4s");

    print("CheckLanguageTip", sCurrentLan)
    UE4.UGameLibrary.SetGameIni_String('Distribution', 'CheckLanguageTip', "Set")
    Localization.SwitchLanguage(sCurrentLan)
end

--修改语音
function Localization.ChangeVoiceLanguage(sLanguage)
    local nIndex = 1
    if not Login.IsOversea() then
        Localization.SetCurrentVoiceLanguage(Localization.tbVoiceLanguage[nIndex] or Localization.tbVoiceLanguage[1])
        return
    end

    nIndex = 2
    if sLanguage == 'en_US' then
        nIndex = 3
        local sOSLanguage = UE4.ULocalizationSubSystem.GetOSLanguage() or ""
        if not string.find(sOSLanguage, 'en') then
            nIndex = 2
        end
    elseif sLanguage == 'zh_CN' then
        nIndex = 1
    end

    Localization.SetCurrentVoiceLanguage(Localization.tbVoiceLanguage[nIndex] or Localization.tbVoiceLanguage[2])
end

--获取当前语音
function Localization.GetCurrentVoiceLanguage()
    return UE4.UGameLibrary.GetGameIni_String('Distribution', 'VoiceLanguage', "")
end

--设置语音
function Localization.SetCurrentVoiceLanguage(sVoice)
    if type("sVoice") ~= "string" then return end

    local nIndex = 1
    if Login.IsOversea() then
        nIndex = 2
    end

    UE4.UWwiseLibrary.SetLanguage(sVoice or Localization.tbVoiceLanguage[nIndex])
    UE4.UGameLibrary.SetGameIni_String('Distribution', 'VoiceLanguage', sVoice or Localization.tbVoiceLanguage[nIndex])
end

--获取语音
function Localization.GetVoiceLanguage(nIndex)
    if Login.IsOversea() then
        nIndex = tonumber(nIndex) or 2
    else 
        nIndex = tonumber(nIndex) or 1
    end

    return Localization.tbVoiceLanguage[nIndex]
end

function Localization.IsShowLanguageSelect()
    return Login.IsOversea() or Localization.bForceShowLanguageSelect
end

---获取当前设置的语言
function Localization.GetCurrentLanguage()
    return Localization.sLanguage
end

function Localization.GetCurrentAreaKey()
    if Login.IsOversea() then
        return Localization.tbOverseaAreaKey[Localization.sLanguage] or 'cbjq_en'
    end
    return Localization.tbAreaKey[Localization.sLanguage] or 'cbjq_en'
end

---获取语言列表
function Localization.GetLanguages()
    return Login.IsOversea() and Localization.tbOverseaLanguage or Localization.tbLanguage
end

function Localization.GetLanguageImgs()
    return Login.IsOversea() and Localization.tbOverseaLanguageImgs or Localization.tbLanguageImgs
end

---获取语音列表
function Localization.GetVoices()
    return Localization.tbVoiceLanguage
end

function Localization.GetVoiceImgs()
    return Login.IsOversea() and Localization.tbOverseaVoiceImgs or Localization.tbVoiceImgs
end

--检测是否特殊处理文件
function Localization.CheckSpecialFile(sFileName)
    if not sFileName then return end

    for i,v in ipairs(Localization.tbSpecialFile) do
        if sFileName == v then
            return true
        end
    end
end

function Localization.Load()
    Localization.tbData = {}
    local sLanguage = Localization.GetCurrentLanguage()
    local tbFolder = {"language", "dialogue/caption"}
    local tbSkillValueFiles = nil --技能数值读取单独处理
    if sLanguage ~= "zh_CN" then
        tbFolder = {"all_language/ui", "all_language/dialogue/caption"}
        tbSkillValueFiles = {}
    end

    local tbLoadedName = {}
    for _k, sFolder in ipairs(tbFolder) do 
        local aFiles = UE4.UUMGLibrary.FindFilesRecursive("Settings/" .. sFolder, ".txt")
        for i = 1, aFiles:Length() do
            local sFile = aFiles:Get(i);
            local fileName = GetFileNameByPath(sFile);
            local shortPath = GetFileNameByPath(sFile, "Settings/")
            if tbLoadedName[fileName] then 
                assert(false, string.format("发现重复命名的多语言文件%s,全路径为:%s", fileName, "Settings/" .. shortPath))
            end
            tbLoadedName[fileName] = true

            local fileName = string.gsub(fileName, ".txt", "")
            local tbFile = LoadCsv(shortPath, 1)
            local bSpecial = Localization.CheckSpecialFile(fileName)
            for _, tbLine in ipairs(tbFile) do
                local sKey = tbLine['Key']
                local sVal = tbLine[sLanguage];
                if bSpecial and string.find(sKey or "", "_value") ~= nil then --特殊处理 纯数值类文本
                    sVal = tbLine['zh_CN']
                    if tbSkillValueFiles and not tbSkillValueFiles[fileName] then
                        tbSkillValueFiles[fileName] = fileName
                    end
                elseif not sVal or sVal == '' then
                    sVal = tbLine['zh_CN']
                end

                if sKey and sVal then
                    local key = fileName .. '.' .. sKey
                    if not Localization.tbData[key] then 
                        Localization.tbData[key] = string.gsub(sVal, '\\n', '\n');
                    else
                        UE4.UUMGLibrary.LogError(string.format("发现重复的多语言key:%s - %s 所在目录:%s", key, sVal, shortPath))
                    end
                end
            end
        end
    end

    ---如果是海外并且是简中 特殊处理一些Key
    if Login.IsOversea() and sLanguage == "zh_CN" then
        Localization.tbData['error.318'] = Localization.tbData['error.318_Oversea']
        Localization.tbData['ui.TxtCloseRegistration'] = Localization.tbData['ui.TxtCloseRegistration_Oversea']
    end

    --海外
    if not tbSkillValueFiles then return end

    for k,v in pairs(tbSkillValueFiles) do
        Localization.LoadSkillValues(v)
    end
end

--海外版本 单独覆盖技能数值
function Localization.LoadSkillValues(sFileName)
    if not sFileName then return end

    local shortPath = "language/" .. sFileName.. ".txt"
    local tbFile = LoadCsv(shortPath, 1)
    local bSpecial = Localization.CheckSpecialFile(sFileName)
    for _, tbLine in ipairs(tbFile) do
        local sKey = tbLine['Key']
        local sVal = nil
        if bSpecial and string.find(sKey or "", "_value") ~= nil then --特殊处理 纯数值类文本
            sVal = tbLine['zh_CN']
        end

        if sKey and sVal then
            local key = sFileName .. '.' .. sKey
            Localization.tbData[key] = string.gsub(sVal, '\\n', '\n');
        end
    end
end

function Localization.GetSkillSpecialValue(InSpecialFunc)
    return assert(load("return " .. (InSpecialFunc or "")))()
end

function Localization.DefaultString()
    local bOversea = UE4.UGameLibrary.GetGameIni_Bool("Distribution", "Oversea", false)
    if bOversea then
        return "(NULL)"
    else
        return "(空)"
    end
end

function Localization.Get(InKey)
    if not InKey then return Localization.DefaultString() end

    return Localization.tbData[InKey] or InKey
end

function Localization.GetSkillName(InId)
    if not InId then return Localization.DefaultString() end

    local sName = Localization.tbData["skill_describe." .. InId..'_name'] or Localization.tbData["skill_support." .. InId] or Localization.tbData["spine." .. InId .."_name"]
    sName = sName or Localization.tbData["skill_node." .. InId]
    return sName or Localization.DefaultString()
end

function Localization.GetQTESkillName(InId)
    if not InId then return Localization.DefaultString() end

    local sName = Localization.tbData["skill_describe." .. InId..'_qte'] or Localization.tbData["skill_node." .. InId]
    return sName or Localization.DefaultString()
end

function Localization.GetQTESkillDesc(InId)
    if not InId then return Localization.DefaultString() end

    local sName = Localization.tbData["skill_describe." .. InId .. "_qtedes"] or Localization.tbData["skill_node." .. InId .. "_des"]
    return sName or Localization.DefaultString()
end

function Localization.GetSkillDesc(InId)
    if not InId then return Localization.DefaultString() end

    local sName = Localization.tbData["skill_describe." .. InId .. "_des"] or Localization.tbData["skill_support." .. InId .. "_des"] or Localization.tbData["spine." .. InId .."_des"]
    sName = sName or Localization.tbData["skill_node." .. InId .. "_des"]
    return sName or Localization.DefaultString()
end
function Localization.GetSkillValue(InId)
    if not InId then return Localization.DefaultString() end

    local sName = Localization.tbData["skill_describe." .. InId .. "_value"] or Localization.tbData["skill_support." .. InId .. "_value"] or Localization.tbData["spine." .. InId .."_value"]
    sName = sName or Localization.tbData["skill_node." .. InId .. "_value"]
    return sName or Localization.DefaultString()
end

function Localization.GetModifierName(InId)
    if not InId then return Localization.DefaultString() end

    local sName = Localization.tbData["skill_describe." .. InId..'_modifier']
    return sName or Localization.DefaultString()
end

--试玩 角色技能信息描述
function Localization.GetSkillIntroDesc(InId)
    if not InId then return Localization.DefaultString() end

    local sName = Localization.tbData["skill_tips." .. InId .. "_des"]
    return sName or Localization.DefaultString()
end
function Localization.GetSkillIntroName(InId)
    if not InId then return Localization.DefaultString() end
    local sName = Localization.tbData["skill_tips." .. InId .. "_name"]
    return sName or Localization.DefaultString()
end

--- 活动描述配置相关项
function Localization.GetItemName(InId)
    if not InId then return Localization.DefaultString() end
    local sName = Activity.tbData["activity_des."..InId..'_name']
    return sName or Localization.DefaultString()
end

function Localization.GetItemDesc(InId)
    if not InId then return Localization.DefaultString() end
    local sName = Localization.tbData["activity_des." .. InId .. "_des"]
    return sName or Localization.DefaultString()
end
function Localization.GetItemValue(InId)
    if not InId then return Localization.DefaultString() end
    local sName = Localization.tbData["activity_des." .. InId .. "_value"]
    return sName or Localization.DefaultString()
end

function Localization.GetMonsterName(InId)
    if not InId then return Localization.DefaultString() end
    local sName = Localization.tbData["monster." .. InId .. "_name"]
    if not sName and UE4.UGameLibrary.ConvertMonsTempExIdToMonsTempId then
        local MonsId = UE4.UGameLibrary.ConvertMonsTempExIdToMonsTempId(InId)
        sName = Localization.tbData["monster." .. MonsId .. "_name"]
    end
    return sName or Localization.DefaultString()
end
function Localization.GetMonsterDesc(InId)
    if not InId then return Localization.DefaultString() end
    local sName = Localization.tbData["monster." .. InId .. "_desc"]
    return sName or Localization.DefaultString()
end

--检测语言版本
---@param sLanguage string or talbe 语言版本
---@return bool 参数为空或者匹配时为真
function Localization.CheckLanguage(sLanguage)
    local sCurrentLanguage = Localization.GetCurrentLanguage()
    if not sLanguage then
        return true
    elseif type(sLanguage) == "string" then
        return sCurrentLanguage == sLanguage
    elseif type(sLanguage) == "table" then
        if #sLanguage == 0 then return true end
        for _,v in ipairs(sLanguage) do
            if v == sCurrentLanguage then
                return true
            end
        end
    end
end

---通知服务器玩家语言设置
---@param nOperationType integer 1-下载语音, 2-卸载语音  3-选择语音, 4-选择文本
---@param sLanguage string 语言
function Localization.NotifyLanSetting(nOperationType, sLanguage)
    if not me or me:Id() == 0 then return end

    local msg = {
        nType = nOperationType,
        sLan = sLanguage
    }
    me:CallGS("LanguageChange", json.encode(msg))
end

---根据当前语言调整日期显示格式
---@param nTime int 时间戳
---@return string 
function Localization.LocalDateFormat(nTime)
    if Localization.DateFormat[Localization.GetCurrentLanguage()] then
        return os.date(Localization.DateFormat[Localization.GetCurrentLanguage()], nTime)
    end
    return os.date("%Y-%m-%d-%H:%M", tbData.nTime)
end

if not SERVER_ONLY then
    Localization.Load();
end
