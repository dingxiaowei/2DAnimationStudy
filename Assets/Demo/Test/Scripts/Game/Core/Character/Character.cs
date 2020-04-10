using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Base.Game.Core.CustomPhysics;

public class Character : UnityEntity
{
    public CharacterProperty CharacterProperty { get { return mProperty as CharacterProperty; } set { mProperty = value; } }
    protected CharacterMotor mCharacterMotor;
    public CharacterMotor CharacterMotor { get { return mCharacterMotor; } }

    protected CharacterRun mRunController;
    public Character() : base()
    {

    }

    protected override void InitializeBeforeAwake()
    {
        base.InitializeBeforeAwake();
        CreateMotor();
        CreateRunController();
        CharacterProperty.OnAttributeChangedEvent += OnPropertyChanged;
    }

    protected override void InitBeforeStart()
    {
        base.InitBeforeStart();
    }

    protected virtual void CreateRunController()
    {
        mRunController = new CharacterRun(this);
        mRunController?.InitBeforeAwake();
    }

    protected override void CreateMotor()
    {
        mMotor = new CharacterMotor(ComponentsManager.Trans);
        mCharacterMotor = mMotor as CharacterMotor;
    }

    protected override void CreateStateMachine()
    {
        mStateMachine = new EntityStateMachine(this);
    }

    protected override void OnDestroy()
    {
        base.OnDestroy();
    }

    protected void OnPropertyChanged(EnumCharacterAttr attrType, float value)
    {
        if (mCharacterMotor != null)
        {
            
        }
    }
}
