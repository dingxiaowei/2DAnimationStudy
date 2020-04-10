using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterStateMachine : EntityStateMachine
{
    public CharacterStateMachine(Character character) : base(character)
    {

    }

    protected override void Build()
    {
        BuildStateMap();
        BuildAllStates();
    }

    protected override void BuildStateMap()
    {
        base.BuildStateMap();
        SetStateMap(Msg.EBattleEntityState.EntityStateMove, typeof(CharacterMove));
        SetStateMap(Msg.EBattleEntityState.EntityStateIdle, typeof(CharacterIdle));
    }

    protected override void BuildAllStates()
    {
        foreach (KeyValuePair<uint, Type> kv in mStatesMap)
        {
            if (kv.Value == null)
                continue;

            string stateName = string.Empty;
            if (kv.Key > (uint)Msg.EBattleEntityState.EntityStateBegin && kv.Key < (uint)Msg.EBattleEntityState.EntityStateMax)
            {
                stateName = ((Msg.EBattleEntityState)kv.Key).ToString();
            }
            else
            {
                //warning
            }
        }
    }
}
