using UnityEngine;

namespace Base.Game.Core.CustomPhysics
{
    public struct EntityCenterPoint
    {
        public Transform Target;
        public Vector3 CenterOffset;
        public Vector3 CenterPosition
        {
            get { return Target == null ? Vector3.zero : (Target.position + CenterOffset); }
        }

        public void Clear()
        {
            Target = null;
            CenterOffset = Vector3.zero;
        }
    }
    public class UnityEntityPhysics : IEntityComponent
    {
        protected Transform mEntityTrans;
        public Transform EntityTrans { get { return mEntityTrans; } }

        protected bool mEnabled = true;
        public bool Enabled
        {
            get { return mEnabled; }
            set
            {
                mEnabled = value;
            }
        }

        protected UnityEntityMotor mMotor;

        public UnityEntityPhysics(Transform trans)
        {
            mEntityTrans = trans;
        }

        public virtual void InitBeforeAwake(UnityEntityMotor motor)
        {
            mMotor = motor;
        }

        public virtual void InitBeforeStart(Transform trans)
        {
            mEntityTrans = trans;
            Enabled = true;
        }

        public virtual void Awake()
        {

        }

        public virtual void Start()
        {

        }

        public virtual void FixedUpdate()
        {

        }

        public virtual void Update(float deltaTime)
        {

        }

        public virtual void ResetOnDestroy()
        {

        }
    }
}
