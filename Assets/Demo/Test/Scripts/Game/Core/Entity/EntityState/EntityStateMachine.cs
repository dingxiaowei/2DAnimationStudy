using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using FSM;

public class EntityStateMachine
{
    public enum EntityStateEvent
    {
        ABILITY_TRIGGERED = 1,
    }

    protected Dictionary<uint, Type> mStatesMap = new Dictionary<uint, Type>();
    protected AbstractState mRootState = new State();
    protected Entity mEntity;

    public EntityStateMachine(Entity entity)
    {
        mEntity = entity;

        Build();
    }

    public virtual void Update()
    {
        mRootState.Update(TimeManager.DeltaTime);
    }

    public void TriggerEvent(EntityStateEvent stateEvent, EventArgs args)
    {
        TriggerEvent(stateEvent.ToString(), args);
    }

    public void TriggerEvent(EntityStateEvent stateEvent)
    {
        TriggerEvent(stateEvent.ToString());
    }

    public void ChangeState(string stateName)
    {
        mRootState.ChangeState(stateName);
    }

    public void TriggerEvent(string eventName, EventArgs args)
    {
        mRootState.TriggerEvent(eventName, args);
    }

    public void TriggerEvent(string eventName)
    {
        mRootState.TriggerEvent(eventName, EventArgs.Empty);
    }

    public void OnAbilityTriggered(EntityAbilityEventsArgs args)
    {
        TriggerEvent(EntityStateEvent.ABILITY_TRIGGERED, args);
    }

    protected virtual void Build()
    {
        BuildStateMap();
    }

    protected virtual void BuildStateMap()
    {
        SetStateMap(Msg.EBattleEntityState.EntityStateIdle, typeof(EntityIdle));
        SetStateMap(Msg.EBattleEntityState.EntityStateMove, typeof(EntityMove));
        SetStateMap(Msg.EBattleEntityState.EntityStateDead, typeof(EntityDie));
    }

    protected void SetStateMap(Msg.EBattleEntityState stateEnum, Type stateClassType)
    {
        mStatesMap[(uint)stateEnum] = stateClassType;
    }

    public EntityStateBase CurrentState
    {
        get
        {
            return mRootState.PeekChildren() as EntityStateBase;
        }
    }
}
