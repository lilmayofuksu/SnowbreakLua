-- ========================================================
-- @File    : Preloads.lua
-- @Brief   : 控制预加载顺序
-- @Author  : Leo Zhao
-- @Date    : 2019-08-26
-- ========================================================
local do_require = function()
    require 'Misc.Json';
    require 'Misc.Lib';
    require 'Misc.Enums';
    require 'Misc.S2C';
    require 'Misc.ZoneTime';
    require 'Misc.EventSystem';
    require 'Login.Login'
    require 'Misc.Localization';
    require 'Misc.UE4';
    require 'Misc.Model';
    require 'Misc.Reconnect'
    require 'Misc.Questionnaire'
    require 'Misc.Adjust'
    require 'Setting.RuntimeState'

    require 'Preview.PreviewType'
    require 'Preview.Preview'
    require 'Preview.PreviewScene'
    require 'Cash.Cash';
    require 'Cash.Exchange';
    require 'Audio.Audio';
    require 'Error.Error';

    require 'Achievement.Achievement';
    require 'Achievement.Achievement_point';
    require 'Achievement.Achievement_DLC';

    require 'Ability.Ability';
    require "Ability.AbilityCollision";
    require "Ability.AbnormalStateCheck";
    require "Ability.NotifyListener";
    require 'Ability.EmitterSearcher';
    require 'Ability.EmitterBullet';

    require 'BattlePass.BattlePass'

    require "Loading.Loading";
    require 'Resource.Resource'
    require 'Data.DataPost'

    require 'Formation.Formation';

    require 'Item.ItemPower';
    require 'Item.Item';
    require 'Item.Weapon';
    require 'Item.ItemSort';
    require 'Item.Logistics';
    require 'Item.WeaponPart';
    require 'Item.RoleBreak';
    require 'Item.Spine';
    require 'Item.Affix';
    require 'Item.Refine';
    require 'Item.Recycle';
    require 'Item.DropWay.DropWay'
    require 'Item.Drop.Drop'
    require 'Item.Fashion'

    require 'Player.player';
    require 'Gacha.Gacha';
    require 'Web.Web'
    require 'Notice.Notice'
    require 'Condition.Condition'

    require 'Mail.Mail'

    require 'RedPoint.RedPoint'

    require 'Setting.PlayerSetting';

    require 'UMG.UI';
    require "UMG.WidgetUtils";

    require("Launch.Launch")
    require("Launch.LevelRecord")
    require "Launch.Chapter.ChapterLevel";
    require "Launch.Chapter.Chapter";
    require "Launch.Daily.DailyLevel";
    require "Launch.Daily.Daily";
    require "Launch.LaunchLog";
    require "Launch.Role.RoleLevel";
    require "Launch.Role.Role";
    require "Launch.Online.Online";
    require "Launch.Tower.TowerLevel";
    require "Launch.Online.OnlineLevel";
    require "Launch.Task.ChallengeMgr";
    require "Launch.TowerEvent.TowerEventLevel";
    require "Launch.TowerEvent.TowerEventChapter";
    require "Launch.Settlement";
    require "Launch.Dlc.DLC_Chapter";
    require "Launch.Dlc.DLC_Level";
    require "Launch.Rogue.RogueLevel";

    require("Map.Map");

    require "UMG.Dialogue.DialogueMgr";
    require 'UMG.Role.RoleCard';
    require 'Item.Color';
    require 'Activity.Sign';
    require 'Activity.Activity';
    require 'Activity.Banner';
    require 'Activity.Activityface';
    require 'Activity.SevenDay';
    require 'Activity.Recharge';
    require 'Activity.VigourSupply';
    require 'Activity.GachaTry';

    require 'NormalActivity.CycleGift';

    require "Challenge.Tower.ClimbTower";
    require "Challenge.Boss.Boss";
    require "Challenge.Defend.Defend";
    require "Challenge.Chess.ChessLogic"
    require "Challenge.TowerEvent.TowerEvent"

    require "Friend.Friend";
    require "Friend.Profile";

    require "Guide.Guide";
    require "Guide.ClientFileCheck"
    require "Shop.Shop";
    require "Purchase.IBShop";
    require "OpenWorld.OpenWorldClient";
    require "OpenWorld.OpenWorldConfig";
    require "OpenWorld.OpenWorldMgr";

    require "Task.Utils.TaskCommon";
    require "Task.Utils.MonsterSpawnStatistics";
    require "Task.Utils.LevelDropsManager";

    require "House.House"

    require 'Function.FunctionRouter'
    require 'Misc.GM';
    require 'GM.GmCommand'
    require 'Dialogue.SimpleDialogue'

    require "Chess.ChessClient"
    require "FragmentStory.FragmentStory"

    require "riki.riki"

    require "DLC.DLC_Logic"
    require "DLC.Rogue.Rogue"

    require "Survey.Survey"
    require "Designer.Designer"

    -- other require
    require("DS_ProfileTest.Utils.DsCommonAction")
    require "Challenge.TargetShoot.TargetShoot"
    require "LocalNotification.LocalNotification"

    require "WaterMark.WaterMark"
    require "Plot.BossSequenceConfig"
end

--- 当前登录玩家
--- @type UAccount
me = me;

--- 是否是服务器
--- @type boolean
SERVER = SERVER;

--- 是否是客户端
--- @type boolean
CLIENT = CLIENT;

--- DedicatedServer
SERVER_ONLY = SERVER_ONLY

xpcall(do_require, function(szErr)
    local lastSettingPath = UE4.UUMGLibrary.GetLastSettingPath()
    local msg = "游戏启动报错，请程序同学看看是啥情况： \n\n最近一次加载的配置表: " .. lastSettingPath .. "\n代码堆栈:\n" .. debug.traceback(szErr);
    print(msg)
    UE4.UGMLibrary.ShowDialog("请复制以下消息到项目大群中", msg);
end);

----------------- 代码提示 ----------------------------------



--- 策划lua参数配置
GlobalConfig = Eval(LoadSetting("config.txt"))