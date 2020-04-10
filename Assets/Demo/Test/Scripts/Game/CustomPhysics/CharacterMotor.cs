using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Base.Game.Core.CustomPhysics
{
    public class CharacterMotor : UnityEntityMotor
    {
        protected float mLocalForwardSpeed;

        public CharacterMotor(Transform trans) : base(trans)
        {

        }

        ~CharacterMotor()
        {

        }

        public override void InitBeforeAwake(UnityEntityPhysics physics)
        {
            base.InitBeforeAwake(physics);
        }

        public override void InitBeforeStart(Transform trans)
        {
            base.InitBeforeStart(trans);
        }

        public virtual void SetInternalLocalInputSpeed(Vector2 inputSpeed)
        {
            mInternalNormalizedInput = inputSpeed;
        }
    }
}