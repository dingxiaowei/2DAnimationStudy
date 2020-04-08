using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ProjectileProperty : UnityEntityProperty
{
    protected BattleEntityInfo mHostEntityInfo;
    public BattleEntityInfo HostEntityInfo
    {
        get { return mHostEntityInfo; }
        set { mHostEntityInfo = value; }
    }
    public override void ResetOnDestroy()
    {
        base.ResetOnDestroy();
    }
}
