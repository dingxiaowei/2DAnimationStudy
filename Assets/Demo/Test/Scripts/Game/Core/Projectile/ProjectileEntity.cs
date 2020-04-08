using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ProjectileEntity : UnityEntity
{
    protected const float MIN_LIFETIME = 0.1f;
    protected const float MAX_RANGE = 500.0f;
    protected const float MAX_SPEED = 2500.0f;

    public ProjectileProperty ProjectileProperty { get { return mProperty as ProjectileProperty; } set { mProperty = value; } }

    protected Entity mHostEntity;
    public Entity Host { get { return mHostEntity; } }
    
    protected void OnDead()
    {

    }
}
