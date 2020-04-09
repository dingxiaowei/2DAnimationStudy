using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Base.Game.Core.CustomPhysics
{
    public class CharacterRun : MonoBehaviour
    {
        protected Character mHostCharacter;

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

        }

        //public bool TryTrigger()
        //{
        //    if (mCurrentDuration == 0 && mCurrentCD == 0 && mHostCharacter != null && mHostCharacter.CharacterProperty.CanRun)
        //    {
        //        mCurrentDuration = mHostCharacter.CharacterProperty.RunDuration;
        //        mCurrentCD = mHostCharacter.CharacterProperty.RunCD;
        //        mHostCharacter.CharacterMotor.RunSpeedMultiplier = mHostCharacter.CharacterProperty.RunSpeedMultiplier;
        //        mHostCharacter.ComponentsManager.Animator.SetIsRunning(true);
        //        return true;
        //    }
        //    return false;
        //}

        //protected void EndRun()
        //{
        //    if (mHostCharacter != null && mHostCharacter.CharacterProperty.CanRun)
        //    {
        //        mHostCharacter.CharacterMotor.RunSpeedMultiplier = 1.0f;
        //        mHostCharacter.ComponentsManager.Animator.SetIsRunning(false);
        //    }
        //}
    }
}
