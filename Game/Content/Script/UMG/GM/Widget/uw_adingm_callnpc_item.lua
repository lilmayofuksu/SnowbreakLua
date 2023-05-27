

local tbClass=Class("UMG.SubWidget")
function tbClass:Construct()
    self.Btnexecute.OnClicked:Add(self,self.ExecuteSpawnNPC)

end

function tbClass:ExecuteSpawnNPC()
    --local Num= 
    local Num =UE4.UKismetStringLibrary.Conv_StringToInt(self.NPCNum:GetText())
    if Num<=0 then
        return
    end
    
    for i=1,Num do
        local NPCLocation=self:GetOwningPlayerPawn():K2_GetActorLocation()+self:GetOwningPlayerPawn():GetActorForwardVector()*400
        local SkilsArr=UE4.TArray(UE4.int32)
        local Params= UE4.FSpawnNpcParams()
        Params.Id=self.NPCID:GetText()
        Params.AI=self.NPCID:GetText()
        Params.Location=NPCLocation
        Params.Rotation=nil
        Params.PlayEnterAnimIndex=1
        Params.Level=self.NPCLevel:GetText()
        Params.Team="1"
        Params.Type=UE4.ECharacterType.AI
        Params.AIEvents=nil
        Params.AIEventID=0
        Params.bIsTeamCaptain=false
        Params.PatrolPoint=""
        Params.SpecializedSkillsConfig.MinNum=2
        Params.SpecializedSkillsConfig.MaxNum=2
        SkilsArr:Add(self.NPCJN1:GetText())
        SkilsArr:Add(self.NPCJN2:GetText())
        Params.SpecializedSkillsConfig.SpecializedSkillIDs= SkilsArr;
        Params.SpecializedSkillsConfig.SpecializedPropertyID = self.AttributesID:GetSelectedOption();
        UE4.ULevelLibrary.SpawnNpcAtLocation(self,Params,self:GetOwningPlayer())
    end
end


return tbClass