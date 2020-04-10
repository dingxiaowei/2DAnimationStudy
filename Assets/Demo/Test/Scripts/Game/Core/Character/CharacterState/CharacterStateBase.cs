using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterStateBase : EntityStateBase
{
    protected Character mCharacterEntity;
    public Character CharacterEntity
    {
        get
        {
            if (mCharacterEntity == null)
            {
                mCharacterEntity = mEntity as Character;
            }
            return mCharacterEntity;
        }
    }

    public CharacterStateBase() : base()
    {

    }

    public override void RegisterEvents()
    {
        base.RegisterEvents();
    }

    public override void BeginEnter()
    {
        base.BeginEnter();
    }

    protected sealed override void OnAbilityTriggeredEvent(EntityAbilityEventsArgs args)
    {
        base.OnAbilityTriggeredEvent(args);
        OnCharacterAbilityTriggered(args);
    }

    protected virtual void OnCharacterAbilityTriggered(EntityAbilityEventsArgs args)
    {

    }
}
