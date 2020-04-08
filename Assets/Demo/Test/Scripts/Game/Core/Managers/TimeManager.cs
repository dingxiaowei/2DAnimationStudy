using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Framework.Mgr;
using System;

public class TimeManager : ManagerBase<TimeManager>
{
    static private float sUpdateBeginTime;
    static public void InitUpdateDeltaTimePerFrame()
    {
        sUpdateBeginTime = Time.realtimeSinceStartup;
    }
    public DateTime SystemTime
    {
        get
        {
            return DateTime.Now;
        }
    }

    static public float DeltaTime
    {
        get
        {
            float deltaTime = (Time.realtimeSinceStartup - sUpdateBeginTime) * Time.timeScale;
#if UNITY_EDITOR
            //防止断点时deltaTime过大
            deltaTime = UnityEngine.Mathf.Clamp(deltaTime, 0.0f, 0.1f);
#endif
            return deltaTime + Time.deltaTime;
        }
    }

    public override void Update()
    {
        base.Update();
    }
}
