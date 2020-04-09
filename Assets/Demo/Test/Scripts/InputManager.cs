using Framework.Mgr;
using UnityEngine;
using UnityEngine.InputSystem;

public class InputManager : ManagerBase<InputManager>
{
    CharacterInputAction mInputAction;
    private Character mAvatarCharacter;
    //private float mJoystickV = 0.0f, mJoystickH = 0.0f;
    bool mIsWalkPerformed;
    bool mIsRunPerformed;
    //public void SetJoystickValue(float inputV, float inputH)
    //{
    //    if (inputV != mJoystickV || inputH != mJoystickH)
    //    {
    //        mJoystickV = inputV;
    //        mJoystickH = inputH;
    //    }
    //}

    public override void Init()
    {
        base.Init();
        InitInputAction();
    }

    public void OnCharacterCreated(Character c)
    {
        if (c == null)
            return;
        mAvatarCharacter = c;
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

        mInputAction.Enable();
    }

    void WalkStarted(InputAction.CallbackContext context)
    {
        mIsWalkPerformed = true;
    }

    void WalkPerformed(InputAction.CallbackContext context)
    {

    }

    void WalkEnd(InputAction.CallbackContext context)
    {
        mIsWalkPerformed = false;

    }

    void RunPerformed(InputAction.CallbackContext context)
    {
        mIsRunPerformed = true;
    }

    void RunEnd(InputAction.CallbackContext context)
    {
        mIsRunPerformed = false;
    }

    void Jump(InputAction.CallbackContext context)
    {

    }

    void ShootStarted(InputAction.CallbackContext context)
    {

    }

    void ShootPerformed(InputAction.CallbackContext context)
    {

    }

    void ShootCancel(InputAction.CallbackContext context)
    {

    }

    void Skill1(InputAction.CallbackContext context)
    {

    }

    void Skill2(InputAction.CallbackContext context)
    {

    }

    void Skill3(InputAction.CallbackContext context)
    {

    }

    public override void OnDestroy()
    {
        base.OnDestroy();
        mInputAction.Disable();
    }
}
