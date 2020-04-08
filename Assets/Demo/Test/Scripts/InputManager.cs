using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InputManager : Singleton<InputManager>
{
    private float mJoystickV = 0.0f, mJoystickH = 0.0f;

    public void SetJoystickValue(float inputV, float inputH)
    {
        if (inputV != mJoystickV || inputH != mJoystickH)
        {
            mJoystickV = inputV;
            mJoystickH = inputH;
        }
    }


}
