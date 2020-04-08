using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BattleManager : Singleton<BattleManager>
{
    private bool mIsStarted = false;

    public bool IsStarted
    {
        get => mIsStarted;
    }

    private BattleMembers mMembers = new BattleMembers();
    public BattleMembers Members
    {
        get { return mMembers; }
    }

    public BattleEntityInfo Avatar
    {
        get
        {
            return mMembers.AvatarEntity;
        }
    }

    private void CreateCharacter(bool isAvatar, Msg.BattleEntityInfo info, BattlePlayerInfo playerInfo = null)
    {
   
    }

    public void SpawnEntity(Msg.BattleEntityInfo info)
    {
        BattlePlayerInfo ownerPlayer;
        bool isAvatar = false;

        if (!mMembers.BattleEntities.ContainsKey(info.Id))
        {
            if (Members.TryGetBattlePlayer(info.Owner, out ownerPlayer))
            {
                if (ownerPlayer.IsAvatar)
                {
                    isAvatar = true;
                }
            }
            CreateCharacter(isAvatar, info);
        }
    }
}
