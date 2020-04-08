using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Framework.Mgr
{
    public interface IMgr
    {
        void Init();
        void Start();
        void Update();
        void LateUpdate();
        void FixedUpdate();
        void OnDestroy();
    }
}
