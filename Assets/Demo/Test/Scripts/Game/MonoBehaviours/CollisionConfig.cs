using System.Collections;
using System.Collections.Generic;
using UnityEngine;

#if !_IMPLEMENT_IN_CPP
using Sirenix.OdinInspector;
#endif

public class CollisionConfig : MonoBehaviour
{
    public enum CollisionPositionType
    {
        Torso = 0,
        Torso_armor,
        Torso_weak,
        Leg,
        Leg_armor,
        Leg_weak,
        Weapon,
        Equipment,
    }

    public CollisionPositionType Type;

    [ReadOnly] public string Node;
    public bool IsWeakness;

    [ReadOnly] public Vector3 LocalPosition;
    [ReadOnly] public Vector3 LocalAngle;
    [ReadOnly] public Vector3 LocalScale;

    protected bool mEnabled = true;
    protected Collider[] mCollsionBox;

    protected Transform mRootTrans;
    public Transform RootTrans { get { return mRootTrans; } }

    protected System.Action mOnHit;
    public event System.Action OnHitEvent
    {
        add { mOnHit += value; }
        remove { mOnHit -= value; }
    }

    protected void Awake()
    {
        mCollsionBox = GetComponents<Collider>();
    }

    public void Reset()
    {
        mOnHit = null;
    }

    public void SetRootTransform(Transform transform)
    {
        mRootTrans = transform;
    }

    public void SetCollisionEnabled(bool enabled)
    {
        if (enabled != mEnabled)
        {
            mEnabled = enabled;
            if (mCollsionBox != null)
            {
                foreach (Collider c in mCollsionBox)
                {
                    c.enabled = mEnabled;
                }
            }
        }
    }

    public void SaveLocalMessage()
    {
        LocalPosition = transform.localPosition;
        LocalAngle = transform.localEulerAngles;
        LocalScale = transform.localScale;
    }

    public void SetLocalMessage()
    {
        transform.localPosition = LocalPosition;
        transform.localEulerAngles = LocalAngle;
        transform.localScale = LocalScale;
    }
}
