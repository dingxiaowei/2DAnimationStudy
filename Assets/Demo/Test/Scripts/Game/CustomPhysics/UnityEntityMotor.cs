using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Base.Game.Core.CustomPhysics
{
    public class UnityEntityMotor : IEntityComponent
    {
        protected Transform mEntityTrans;
        protected UnityEntityPhysics mPhysics;
        protected bool mEnabled = true;
        protected Vector2 mInternalNormalizedInput = Vector2.zero;
        protected Vector2 mLastDeltaMove;
        protected Vector2 mNormalizedLastMoveDirection;
        protected float mTotalMovedDistance;
        protected Vector2 mDesiredForward;
        protected Vector2 mTargetForward;

        public Vector2 LastDeltaMove
        {
            get { return mLastDeltaMove; }
        }

        public float TotalMovedDistance
        {
            get { return mTotalMovedDistance; }
        }

        public Vector2 TargetForward
        {
            get { return mTargetForward; }
            set { mTargetForward = value; mTargetForward.Normalize(); }
        }
        public Vector3 DesiredForward
        {
            get { return mDesiredForward; }
            set { mDesiredForward = value; }
        }

        public bool Enabled { get { return mEnabled; } set { mEnabled = value; } }

        public UnityEntityMotor(Transform trans)
        {
            mEntityTrans = trans;
        }

        public virtual void InitBeforeAwake(UnityEntityPhysics physics)
        {
            mPhysics = physics;
            mEnabled = true;
        }

        public virtual void InitBeforeStart(Transform trans)
        {
            mEntityTrans = trans;
            mEnabled = true;
        }

        public virtual void Awake()
        {

        }

        public virtual void FixedUpdate()
        {

        }

        public virtual void Start()
        {

        }

        public virtual void Update(float deltaTime)
        {

        }

        public virtual void ResetOnDestroy()
        {
            mTotalMovedDistance = 0;
            mNormalizedLastMoveDirection = Vector2.zero;
            mLastDeltaMove = Vector2.zero;
            mTargetForward = Vector2.right;
            mDesiredForward = Vector2.right;
        }
    }
}
