using FSM;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EntityStateBase : AbstractState
{
    protected Entity mEntity;
    protected uint mStateId;

    public EntityStateBase():base()
    {

    }

    public virtual void BeginEnter()
    {
        OnEnter();
    }

    public virtual void OnUpdate(float deltaTime)
    {

    }

    public virtual void OnEnter()
    {

    }

    public virtual void OnExit()
    {

    }

    //protected virtual void OnAbilityTriggered(EntityA)
}
