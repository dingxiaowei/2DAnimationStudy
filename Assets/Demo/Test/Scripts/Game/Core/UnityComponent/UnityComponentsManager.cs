using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Base.Game.Core.UnityComponent
{
    public class UnityComponentsManager
    {
        private List<UnityComponentBase> mComponentList = new List<UnityComponentBase>();
        private GameObject mGameObject;
        private Transform mTrans;
        public Transform Trans { get { return mTrans; } }


        private System.Action<string> mOnAnimationTrigger;
        public event System.Action<string> OnAnimationTriggerEvent
        {
            add { mOnAnimationTrigger += value; }
            remove { mOnAnimationTrigger -= value; }
        }

        private System.Action<Collider> mOnTriggerEnter;
        public event System.Action<Collider> OnTriggerEnterEvent
        {
            add { mOnTriggerEnter += value; }
            remove { mOnTriggerEnter -= value; }
        }

        public AnimatorComponent Animator { private set; get; }

        private UnityComponentsCollector mComponentsCollector;
        public UnityComponentsCollector ComponentsCollector { get { return mComponentsCollector; } }

        public void SetUnityComponents(UnityComponentsCollector collector)
        {
            mComponentList.Clear();
            mComponentsCollector = collector;
            GameObject go = collector.gameObject;
            mGameObject = go;
            mTrans = go.transform;
            AddAnimator(collector.Animator, collector.AnimCtrls);

            collector.OnAnimationTriggerEvent += OnAnimTrigger;
            collector.OnTriggerEnterEvent += OnTriggerEnter;
        }

        protected void AddAnimator(Animator animator, RuntimeAnimatorController[] animCtrls)
        {
            if (animator == null)
                return;

            Animator = new AnimatorComponent(animator, animCtrls);
            mComponentList.Add(Animator);
        }

        protected void OnAnimTrigger(string name)
        {
            mOnAnimationTrigger?.Invoke(name);
        }

        protected void OnTriggerEnter(Collider other)
        {
            mOnTriggerEnter?.Invoke(other);
        }

        public void ResetOnDestroy()
        {
            mOnAnimationTrigger = null;
            mOnTriggerEnter = null;

            foreach (UnityComponentBase com in mComponentList)
            {
                com.ResetOnDestroy();
            }
        }
    }
}