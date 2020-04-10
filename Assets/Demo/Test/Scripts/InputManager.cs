using Framework.Mgr;
using UnityEngine;
using UnityEngine.InputSystem;

public class InputManager : ManagerBase<InputManager>
{
    CharacterInputAction mInputAction;
    private Character mAvatarCharacter;
    bool mIsWalkPerformed;
    bool mIsRunPerformed;

    private MoveAbilityEventArgs mMoveAbility = new MoveAbilityEventArgs();
    public override void Init()
    {
        base.Init();
        InitInputAction();
        ResetData();
    }

    void ResetData()
    {
        mIsWalkPerformed = false;
        mIsRunPerformed = false;
    }

    public void OnCharacterCreated(Character c)
    {
        if (c == null)
            return;
        mAvatarCharacter = c;
    }

    public override void Update()
    {
        base.Update();
        //if (mIsWalkPerformed)
        //{
        //    Vector2 detail = mInputAction.Player.Walk.ReadValue<Vector2>();
        //    Debug.LogError(detail);
        //}
    }

    void InitInputAction()
    {
        mInputAction = new CharacterInputAction();
        mInputAction.Player.Walk.started += WalkStarted;
        mInputAction.Player.Walk.performed += WalkPerformed;
        mInputAction.Player.Walk.canceled += WalkEnd;
        mInputAction.Player.Run.performed += RunPerformed;
        mInputAction.Player.Run.canceled += RunEnd;
        mInputAction.Player.Jump.performed += Jump;
        mInputAction.Player.Shoot.started += ShootStarted;
        mInputAction.Player.Shoot.performed += ShootPerformed;
        mInputAction.Player.Shoot.canceled += ShootCancel;
        mInputAction.Player.Skill1.performed += Skill1;
        mInputAction.Player.Skill2.performed += Skill2;
        mInputAction.Player.Skill3.performed += Skill3;
        mInputAction.Player.Ack1.performed += Ack1;
        mInputAction.Player.Ack2.performed += Ack2;

        mInputAction.Enable();
    }

    void WalkStarted(InputAction.CallbackContext context)
    {
        mIsWalkPerformed = true;
    }

    void WalkPerformed(InputAction.CallbackContext context)
    {
        var dir = context.ReadValue<Vector2>();
        Debug.LogError("Walk + " + dir);
        mMoveAbility.MoveDirection = dir;
        mAvatarCharacter?.AbilityManager.TriggerAbility(mMoveAbility);
    }

    void WalkEnd(InputAction.CallbackContext context)
    {
        mIsWalkPerformed = false;
        Debug.LogError("WalkEnd");
    }

    void RunPerformed(InputAction.CallbackContext context)
    {
        mIsRunPerformed = true;
        Debug.LogError("RunPerformed");
    }

    void RunEnd(InputAction.CallbackContext context)
    {
        mIsRunPerformed = false;
        Debug.LogError("RunEnd");
    }

    void Jump(InputAction.CallbackContext context)
    {
        Debug.LogError("Jump");
    }

    void ShootStarted(InputAction.CallbackContext context)
    {
        Debug.LogError("ShootStart");
    }

    void ShootPerformed(InputAction.CallbackContext context)
    {
        Debug.LogError("Shoot");
    }

    void ShootCancel(InputAction.CallbackContext context)
    {
        Debug.LogError("ShootCancel");
    }

    void Skill1(InputAction.CallbackContext context)
    {
        Debug.LogError("Skill1");
    }

    void Skill2(InputAction.CallbackContext context)
    {

    }

    void Skill3(InputAction.CallbackContext context)
    {

    }

    void Ack1(InputAction.CallbackContext context)
    {
        Debug.LogError("Ack1");
    }

    void Ack2(InputAction.CallbackContext context)
    {
        Debug.LogError("Ack2");
    }

    public override void OnDestroy()
    {
        base.OnDestroy();
        mInputAction.Disable();
        mMoveAbility = null;
    }
}
