-- ========================================================
-- @File	: Mail/Mail.lua
-- @Brief	: 邮件逻辑
-- ========================================================

Mail = Mail or {};

---邮件领取附件回调
---@param nMailID integer 邮件ID
function Mail.OnMailAttachMent(nMailID)
    local UIMail = UI.GetUI("Mail");
    if not UIMail then return; end
    UIMail:OnGetMailAttachments(nMailID);
end

---判断当前是否有新邮件
---@return boolean 是否有新邮件
function Mail.HaveNew()
    local AllMails = UE4.TArray(UE4.UMail)
    me:GetMails(AllMails);

    for i = 1, AllMails:Length() do
        local pMail = AllMails:Get(i);
        if not pMail.Readed then return true; end 
    end
    return false;
end

---判断邮件是否过期
---@param nExpiration integer 邮件保质期
---@return boolean 是否过期
function Mail.IsExpiration(nExpiration)
    return (nExpiration ~= -1) and nExpiration <= GetTime()
end

--检查处理标题、正文中的参数
---@param sContent 待处理文本
---@return sNewContent  处理后的文本
---@return tbParam 处理后的参数 tbParam[1] 是新的key
function Mail.CheckContentParam(sContent)
    --参数化的邮件
    local p1 = string.find(sContent,"PM|")
    if p1==1 then
        local tbContent = Split(string.sub(sContent,4),"|")
        local sNewContent = Text(tbContent[1])
        table.remove(tbContent,1)
        for i=1,#tbContent do
            tbContent[i] = Text(tbContent[i])
        end

        sNewContent = string.format(sNewContent,table.unpack(tbContent))

        return sNewContent
    end

    return LocalContent(sContent)
end