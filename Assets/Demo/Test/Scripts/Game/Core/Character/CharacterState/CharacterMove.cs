using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FSM;

public class CharacterMove : CharacterStateBase
{
    private float mTime = 0.0f;
    private float mLeaveTime = 0.0f;

    public override void OnEnter()
    {
        base.OnEnter();

    }

    public override void OnUpdate(float deltaTime)
    {
        //if (mCharacterEntity.CharacterMotor.AnimForwardSpeed == 0.0f && mCharacterEntity.CharacterMotor.AnimHorizontalSpeed == 0.0f)
        //{
        //    if (mLeaveTime >= 0.1f)
        //    {
        //        mCharacterEntity.ChangeState(Msg.EBattleEntityState.EntityStateIdle);
        //    }
        //    mLeaveTime += deltaTime;
        //}
        //else if (mTime > 0.3f && !mCharacterEntity.CharacterPhysics.CanStickOnGround && mCharacterEntity.CharacterPhysics.HeightToGround > 0.1f)
        //{
        //    if (mLeaveTime >= 0.1f)
        //    {
        //        mCharacterEntity.ChangeState(Msg.EBattleEntityState.EntityStateFall);
        //    }
        //    mLeaveTime += deltaTime;
        //}
        //else
        //{
        //    mLeaveTime = 0.0f;
        //}

        //mTime += deltaTime;
    }

    public override void OnExit()
    {

    }
}
