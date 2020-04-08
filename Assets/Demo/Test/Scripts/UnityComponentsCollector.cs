using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UnityComponentsCollector : MonoBehaviour
{
    public Transform ColliderRoot;
    public Animator TargetAnimator;

    public RuntimeAnimatorController[] AnimCtrls;

    protected Animator mAnimator;
    public UnityEngine.Animator Animator { get { return mAnimator; } }

    protected System.Action<string> mOnAnimationTrigger;
    public event System.Action<string> OnAnimationTriggerEvent
    {
        add
        {
            mOnAnimationTrigger += value;
        }
        remove
        {
            mOnAnimationTrigger -= value;
        }
    }

    protected Collider2D[] mMoveColliders;
    public Collider2D[] MoveColliders { get { return mMoveColliders; } }

    protected CollisionConfigManager mCollisionManager;
    public CollisionConfigManager CollisionConfigManager { get { return mCollisionManager; } }

    protected System.Action<Collider> mOnTriggerEnter;
    public event System.Action<Collider> OnTriggerEnterEvent
    {
        add
        {
            mOnTriggerEnter += value;
        }
        remove
        {
            mOnTriggerEnter -= value;
        }
    }

    protected void Awake()
    {
        InitComponents();
    }

    protected void InitComponents()
    {
        mAnimator = TargetAnimator ? TargetAnimator : GetComponent<Animator>();
        CollectColliders();
        CollisionCollisions();
    }


    public void AnimTrigger(string name)
    {
        mOnAnimationTrigger?.Invoke(name);
    }

    public void OnTriggerEnter(Collider other)
    {
        mOnTriggerEnter?.Invoke(other);
    }
    protected void CollectColliders()
    {
        Transform root = ColliderRoot == null ? transform : ColliderRoot;

        Collider2D[] colliders = root.GetComponentsInChildren<Collider2D>();
        if (colliders != null)
        {
            List<Collider2D> moveColliders = new List<Collider2D>();
            for (int i = 0; i < colliders.Length; i++)
            {
                colliders[i].gameObject.layer = Base.Game.Utils.LayerManager.NAVIGATION_COLLIDER;
                moveColliders.Add(colliders[i]);
            }
            mMoveColliders = moveColliders.ToArray();
        }
    }

    protected void CollisionCollisions()
    {
        foreach (Transform t in transform)
        {
            mCollisionManager = t.GetComponent<CollisionConfigManager>();
            if (mCollisionManager != null)
                return;
        }
    }
}
