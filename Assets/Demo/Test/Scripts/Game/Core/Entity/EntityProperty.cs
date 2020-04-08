using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EntityProperty : AttributeBase
{
    protected BattleEntityInfo mBattleInfo;
    public BattleEntityInfo BattleInfo { get { return mBattleInfo; } set { mBattleInfo = value; } }

    public long Id
    {
        get
        {
            if (mBattleInfo != null)
                return mBattleInfo.Id;
            else
                return 0;
        }
    }

    public bool IsAvatar
    {
        get
        {
            if (mBattleInfo != null)
            {
                return mBattleInfo.IsAvatarEntity;
            }
            return false;
        }
    }

    public bool IsBelongAvatar
    {
        get
        {
            if (mBattleInfo != null)
            {
                return mBattleInfo.IsBelongAvatar;
            }
            return false;
        }
    }

    protected bool mIsAlive = true;
    public bool IsAlive { get => mIsAlive; set => mIsAlive = value; }

    public override void ResetOnDestroy()
    {
        base.ResetOnDestroy();
        mBattleInfo = null;
        mIsAlive = true;
    }
}
