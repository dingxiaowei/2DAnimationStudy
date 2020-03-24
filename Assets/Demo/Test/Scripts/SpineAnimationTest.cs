using Spine.Unity;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum AnimState
{
    Idel = 0,
    Atk,
    Walk
}

public class SpineAnimationTest : MonoBehaviour
{
    public SkeletonAnimation SpineMan;

    private string[] states = new string[] { "Idle", "Walk", "Atk" };
    private int currentIndex = 0;
    void Start()
    {
        //Debug.Log(SpineMan.AnimationName);
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            //SpineMan.AnimationName = "Idle";
            SpineMan.AnimationState.SetAnimation(0, states[currentIndex++ % 3], true);
        }
    }
}
