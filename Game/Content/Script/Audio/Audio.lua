-- ========================================================
-- @File	: Audio.lua
-- @Brief	: 音效
-- ========================================================

---@class Audio
Audio = Audio or {tbSounds = {}}

---播放音效
---@param nSoundsID Integer 音效ID
function Audio.PlaySounds(nSoundsID)
    UE4.UWwiseLibrary.PostEvent2D(GetGameIns(), Audio.Get(nSoundsID));
end

function Audio.PlaySoundsAttachActor(nSoundsID,InActor)
    UE4.UWwiseLibrary.PostEventAttachedActor(Audio.Get(nSoundsID),InActor);
end

---播放voices
---@param sVoicesID string voicesID
---@param pCard CharacterCard 播放哪个妹子的voices，不填则播放当前看板娘的voices
function Audio.PlayVoices(sVoicesID, pCard)
    pCard = pCard or me:GetCharacterCard(PlayerSetting.GetShowCardID())
    if not sVoicesID or not pCard then
        return
    end
    UE4.UVoiceManager.Play(GetGameIns(), pCard:AppearID(), sVoicesID)
end

function Audio.Get(nID)
    return Audio.tbSounds[nID] or ''
end

---加载配置
function Audio.Load()
    local tbInfo = LoadCsv("audio/audio.txt", 1)
    for _, tbLine in ipairs(tbInfo) do
        local nID = tonumber(tbLine.ID) or 0;
        Audio.tbSounds[nID] = tostring(tbLine.EventName)
    end
end

Audio.Load()