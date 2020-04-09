using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Base.Game.Core.CustomPhysics
{
    public class CharacterRun : MonoBehaviour
    {
        protected Character mHostCharacter;
        protected float mCurrentDuration = 0;
        protected float mCurrentCD = 0;

        public float CurrentDuration { get { return mCurrentDuration; } }
        public float CurrentCD { get { return mCurrentCD; } }
        public bool IsRunning { get { return mCurrentDuration > 0.0f; } }

        public CharacterRun(Character host)
        {
            mHostCharacter = host;
        }

        public virtual void InitBeforeAwake()
        {

        }

        public virtual void InitBeforeStart()
        {
            if (mHostCharacter != null)
            {
                mHostCharacter.ComponentsManager.Animator.SetIsRunning(false);
            }
        }

        public void Update(float deltaTime)
        {
            if (mCurrentDuration > 0)
            {
                mCurrentDuration -= deltaTime;
                if (mCurrentDuration <= 0.0f)
                {
                    mCurrentDuration = 0;
                    EndRun();
                }
            }
            else if (mCurrentCD > 0)
            {
                mCurrentCD -= deltaTime;
                if (mCurrentCD <= 0.0f)
                {
                    mCurrentCD = 0;
                }
            }
        }

        public bool TryTrigger()
        {
            if (mCurrentDuration == 0 && mCurrentCD == 0 && mHostCharacter != null && mHostCharacter.CharacterProperty.CanRun)
            {
                //mCurrentDuration = mHostCharacter.CharacterProperty.RunDuration;
                //mCurrentCD = mHostCharacter.CharacterProperty.RunCD;
                //mHostCharacter.CharacterMotor.RunSpeedMultiplier = mHostCharacter.CharacterProperty.RunSpeedMultiplier;
                mHostCharacter.ComponentsManager.Animator.SetIsRunning(true);
                return true;
            }
            return false;
        }

        protected void EndRun()
        {
            if (mHostCharacter != null && mHostCharacter.CharacterProperty.CanRun)
            {
                //mHostCharacter.CharacterMotor.RunSpeedMultiplier = 1.0f;
                mHostCharacter.ComponentsManager.Animator.SetIsRunning(false);
            }
        }
    }
}
