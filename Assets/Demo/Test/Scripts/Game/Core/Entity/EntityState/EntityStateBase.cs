using FSM;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EntityStateBase : AbstractState
{
    protected struct StateMask
    {
        private int mMask;
        public StateMask(StateMask other)
        {
            mMask = other.mMask;
        }

        public StateMask AddStateMask(Msg.EBattleEntityState state)
        {
            return SetStateMask(state, true);
        }
        public StateMask RemoveStateMask(Msg.EBattleEntityState state)
        {
            return SetStateMask(state, false);
        }
        public StateMask SetStateMask(Msg.EBattleEntityState state, bool canChageTo)
        {
            int mask = GetStateIdMask((int)state);
            if (canChageTo)
            {
                mMask |= mask;
            }
            else
            {
                mMask &= (~mask);
            }
            return this;
        }
        public bool CanChageToState(Msg.EBattleEntityState state)
        {
            int mask = GetStateIdMask((int)state);
            return (mMask & mask) > 0;
        }

        static public int GetStateIdMask(int stateId)
        {
            if (stateId > 0) //not Msg.EBattleEntityState.EntityStateBegin
            {
                return (1 << (stateId - 1));
            }
            else
            {
                return 0;
            }
        }
    }

    protected Entity mEntity;
    protected uint mStateId;
    protected StateMask mOtherStateMask;

    public EntityStateBase() : base()
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

    public virtual void RegisterEvents()
    {

    }

    protected virtual void RegisterCustomEvent()
    {

    }

    public bool CanChageToState(Msg.EBattleEntityState state)
    {
        return mOtherStateMask.CanChageToState(state);
    }

    protected void ChangeToOtherState(Msg.EBattleEntityState stateType)
    {
        ChangeToOtherState(stateType.ToString());
    }

    protected void ChangeToOtherState(string stateName)
    {
        if (Parent != null)
        {
            Parent.ChangeState(stateName);
        }
    }

    protected virtual void OnAbilityTriggeredEvent(EntityAbilityEventsArgs args)
    {
        Msg.EBattleEntityState targetState = Msg.EBattleEntityState.EntityStateBegin;
        switch (args.AbilityType)
        {
            case EntityAbilityType.MOVE:
                targetState = Msg.EBattleEntityState.EntityStateMove;
                break;
        }

        if (targetState != Msg.EBattleEntityState.EntityStateBegin)
        {
            if (CanChageToState(targetState))
                ChangeToOtherState(targetState);
        }
    }
}
