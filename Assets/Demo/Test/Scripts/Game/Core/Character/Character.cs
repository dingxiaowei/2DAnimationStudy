using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Base.Game.Core.CustomPhysics;

public class Character : UnityEntity
{
    public CharacterProperty CharacterProperty { get { return mProperty as CharacterProperty; } set { mProperty = value; } }
    protected CharacterMotor mCharacterMotor;
    public CharacterMotor CharacterMotor { get { return mCharacterMotor; } }
    public Character() : base()
    {

    }

    protected override void InitializeBeforeAwake()
    {
        base.InitializeBeforeAwake();
        CreateMotor();
    }

    protected override void InitBeforeStart()
    {
        base.InitBeforeStart();
    }

    protected virtual void CreateRotater()
    {

    }

    protected virtual void CreateRunController()
    {

    }

    protected virtual void UpdateRotater()
    {

    }

    protected override void CreateMotor()
    {
        mMotor = new CharacterMotor(ComponentsManager.Trans);
        mCharacterMotor = mMotor as CharacterMotor;
    }
}
