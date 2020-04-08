using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BattleMembers
{
    private BattleEntityInfo mAvatarEntity;
    public BattleEntityInfo AvatarEntity { get { return mAvatarEntity; } }

    private Dictionary<long, BattlePlayerInfo> mBattlePlayers = new Dictionary<long, BattlePlayerInfo>();
    public Dictionary<long, BattlePlayerInfo> BattlePlayers { get { return mBattlePlayers; } }

    private Dictionary<long, BattleEntityInfo> mBattleEntities = new Dictionary<long, BattleEntityInfo>();
    public Dictionary<long, BattleEntityInfo> BattleEntities { get { return mBattleEntities; } }

    public bool TryGetBattlePlayer(long playerId, out BattlePlayerInfo playerInfo)
    {
        return mBattlePlayers.TryGetValue(playerId, out playerInfo);
    }

}
