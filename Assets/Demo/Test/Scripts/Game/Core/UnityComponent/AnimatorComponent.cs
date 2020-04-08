using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Base.Game.Core.UnityComponent
{
    public class AnimatorComponent : UnityComponentBase
    {
        //protected readonly string HUB_LAYER_NAME = "Hub Layer";

        protected AnimatorGroup mAnimator;
        public AnimatorGroup UnityAnimator { get { return mAnimator; } }

        #region
        protected readonly int mIsRunning;
        protected readonly int mWalkSpeed;
        protected readonly int mJump;
        protected readonly int mDie;
        protected readonly int mAtk1;
        protected readonly int mAtk2;
        protected readonly int mSpawn;
        protected readonly int mIdel;
        protected readonly int mIsMove;
        #endregion

        protected enum MoveDir
        {
            Left,
            Right
        }

        public AnimatorComponent(Animator anim, RuntimeAnimatorController[] animatorControllers)
        {
            mAnimator = new AnimatorGroup();
            mAnimator.AddAnimator(anim, animatorControllers);

            mIsRunning = Animator.StringToHash("IsRunning");
            mWalkSpeed = Animator.StringToHash("WalkSpeed");
            mJump = Animator.StringToHash("Jump");
            mDie = Animator.StringToHash("Die");
            mAtk1 = Animator.StringToHash("Atk1");
            mAtk2 = Animator.StringToHash("Atk2");
            mSpawn = Animator.StringToHash("Spawn");
            mIdel = Animator.StringToHash("Idel");
            mIsMove = Animator.StringToHash("IsMove");
        }

        public void TriggerDie()
        {
            mAnimator.SetTrigger(mDie);
        }

        public void TriggerIdel()
        {
            mAnimator.SetTrigger(mIdel);
        }

        public void TriggerAtk1()
        {
            mAnimator.SetTrigger(mAtk1);
        }

        public void TriggerAtk2()
        {
            mAnimator.SetTrigger(mAtk2);
        }

        public void TriggerJump()
        {
            mAnimator.SetTrigger(mJump);
        }

        public void SetWalkSpeed(float value)
        {
            mAnimator.SetFloat(mWalkSpeed, value);
        }

        public void SetRunintState(bool isRun)
        {
            mAnimator.SetBool(mIsRunning, isRun);
        }

        public void SetMoveState(bool isMove)
        {
            mAnimator.SetBool(mIsMove, isMove);
        }

        public void TriggerSpawn()
        {
            mAnimator.SetTrigger(mSpawn);
        }
    }
}
