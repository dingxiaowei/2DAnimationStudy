using Base.Game.Core.CustomPhysics;
using Base.Game.Core.UnityComponent;
using UnityEngine;

public class UnityEntity : Entity
{
    public UnityEntityProperty UnityProperty
    {
        get { return mProperty as UnityEntityProperty; }
        set { mProperty = value; }
    }

    protected UnityEntityMotor mMotor;
    public UnityEntityMotor Motor { get { return mMotor; } }

    protected UnityEntityPhysics mPhysics;
    public UnityEntityPhysics Physics { get { return mPhysics; } }

    protected UnityComponentsManager mUnityComponentsManager = new UnityComponentsManager();

    public UnityComponentsManager ComponentsManager { get { return mUnityComponentsManager; } }

    public Transform Trans { get { return mUnityComponentsManager?.Trans; } }

    public UnityEntity()
    {

    }

    public virtual Vector3 AimingPosition { get { return Vector3.zero; } set { } }
    public virtual BattleEntityInfo AimingTarget { get { return null; } set { } }

    protected override void InitializeBeforeAwake()
    {
        base.InitBeforeStart();
        CreateMotor();
        CreatePhysics();

        mMotor?.InitBeforeAwake(mPhysics);
        mPhysics?.InitBeforeAwake(mMotor);
    }

    protected override void InitBeforeStart()
    {
        base.InitBeforeStart();

        mMotor?.InitBeforeStart(ComponentsManager.Trans);
        mPhysics?.InitBeforeStart(ComponentsManager.Trans);
    }

    protected virtual void CreateMotor()
    {
        mMotor = new UnityEntityMotor(mUnityComponentsManager.Trans);
    }

    protected virtual void CreatePhysics()
    {
        mPhysics = new UnityEntityPhysics(mUnityComponentsManager.Trans);
    }

    protected override void UpdateMotor()
    {
        if (Property.IsAlive)
        {
            mMotor.Update(TimeManager.DeltaTime);
        }
    }

    protected override void UpdatePhysics()
    {
        if (Property.IsAlive)
        {
            mPhysics.Update(TimeManager.DeltaTime);
        }
    }

    protected override void FixedUpdatePhysics()
    {
        if (Property.IsAlive)
        {
            mPhysics.FixedUpdate();
        }
    }

    protected override void OnDestroy()
    {
        base.OnDestroy();

        mMotor?.ResetOnDestroy();
        mPhysics?.ResetOnDestroy();
        mUnityComponentsManager?.ResetOnDestroy();
    }
}
