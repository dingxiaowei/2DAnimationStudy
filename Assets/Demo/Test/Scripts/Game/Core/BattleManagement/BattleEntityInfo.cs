using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BattleEntityInfo
{
    protected bool mIsAvatar;

    public bool IsAvatarEntity { get { return mIsAvatar; } set { mIsAvatar = value; } }

    protected long mId;

    public long Id { get { return mId; } }

    public bool IsBelongAvatar
    {
        get { return IsAvatarEntity; }
    }

    public BattleEntityInfo(long entityId)
    {
        mId = entityId;
    }

    public void OnDestroy()
    {
        
    }
}
