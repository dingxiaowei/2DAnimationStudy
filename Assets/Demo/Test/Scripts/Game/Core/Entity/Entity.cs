﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Entity
{
    protected System.Action mOnDestroy;
    public event System.Action OnDestroyEvent
    {
        add { mOnDestroy += value; }
        remove { mOnDestroy -= value; }
    }

    protected EntityProperty mProperty;
    public EntityProperty Property { get { return mProperty; } set { mProperty = value; } }

    public bool IsAvatar { get { return mProperty.IsAvatar; } }
    public bool IsBelongAvatar { get { return mProperty.IsBelongAvatar; } }

    //TODO:添加各种Manager


    protected virtual void InitializeBeforeAwake()
    {
        //Create各种系统
    }

    protected virtual void InitBeforeStart()
    {

    }

    protected virtual void Start()
    {

    }


    protected virtual void Update()
    {

    }

    protected virtual void LateUpdate()
    {

    }

    protected virtual void FixedUpdate()
    {

    }

    protected virtual void OnDestroy()
    {

    }

    protected virtual void UpdateMotor()
    {

    }

    protected virtual void UpdatePhysics()
    {

    }

    protected virtual void FixedUpdatePhysics()
    {

    }

    protected virtual void UpdateAnimator()
    {

    }

    public void InternalDestroy()
    {
        mOnDestroy?.Invoke();
        mOnDestroy = null;
        OnDestroy();
    }

    public void InternalUpdate()
    {
        Update();
    }
    public void InternalLateUpdate()
    {
        LateUpdate();
    }
    public void InternalFixedUpdate()
    {
        FixedUpdate();
    }
}