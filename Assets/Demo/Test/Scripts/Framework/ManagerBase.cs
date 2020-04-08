using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Framework.Mgr
{ 
    public class ManagerBase<T> : IMgr where T : IMgr, new()
    {
        static protected T mInstance;
        static public T Instance
        {
            get
            {
                if (mInstance == null)
                {
                    mInstance = new T();
                }
                return mInstance;
            }
        }

        protected ManagerBase()
        {

        }

        virtual public void FixedUpdate()
        {
            
        }

        virtual public void Init()
        {
            
        }

        virtual public void LateUpdate()
        {
            
        }

        virtual public void OnDestroy()
        {
           
        }

        virtual public void Start()
        {
            
        }

        virtual public void Update()
        {
           
        }
    }
}
