using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public enum EntityAbilityType
{
    IDLE = 1,
    MOVE,
    JUMP,
}


public class EntityAbility
{
    protected EntityAbilityType mType;
    protected Entity mEntity;
    public EntityAbility(Entity entity)
    {
        mEntity = entity;
    }

    public virtual void Trigger()
    {

    }
}
