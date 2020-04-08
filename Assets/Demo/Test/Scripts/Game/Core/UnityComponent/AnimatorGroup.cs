using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace Base.Game.Core.UnityComponent
{
    public class AnimatorGroup : IEnumerable
    {
        protected Animator mMain;
        public Animator MainAnimator { get { return mMain; } }
        protected List<Animator> mAnimatorGroup = new List<Animator>();
        protected Dictionary<Animator, RuntimeAnimatorController[]> mAnimControllerList = new Dictionary<Animator, RuntimeAnimatorController[]>();
        public IEnumerator GetEnumerator()
        {
            return mAnimatorGroup.GetEnumerator();
        }

        public void AddAnimator(Animator animator, RuntimeAnimatorController[] animCtrls)
        {
            if (!mAnimatorGroup.Contains(animator))
            {
                mAnimatorGroup.Add(animator);
                if (animCtrls != null && animCtrls.Length > 1 && !mAnimControllerList.ContainsKey(animator))
                {
                    mAnimControllerList.Add(animator, animCtrls);
                }
            }
            if (mAnimatorGroup.Count > 0)
                mMain = mAnimatorGroup[0];
        }

        public virtual void SwitchAnimatorController(int index)
        {
            foreach (KeyValuePair<Animator, RuntimeAnimatorController[]> kvp in mAnimControllerList)
            {
                RuntimeAnimatorController[] ctrls = kvp.Value;
                if (ctrls.Length > index && ctrls[index] != null)
                {
                    kvp.Key.runtimeAnimatorController = ctrls[index];
                }
            }
        }

        public void RemoveAnimator(Animator animator)
        {
            mAnimatorGroup.Remove(animator);
            if (mAnimatorGroup.Count > 0)
                mMain = mAnimatorGroup[0];
        }

        public void SetFloat(int id, float value)
        {
            foreach (var anim in mAnimatorGroup)
            {
                anim.SetFloat(id, value);
            }
        }

        public void PlayState(string stateName)
        {
            foreach (var anim in mAnimatorGroup)
            {
                anim.Play(stateName);
            }
        }

        public float GetFloat(int id)
        {
            return mMain.GetFloat(id);
        }

        public void SetBool(int id, bool value)
        {
            foreach (var anim in mAnimatorGroup)
            {
                anim.SetBool(id, value);
            }
        }

        public bool GetBool(int id)
        {
            return mMain.GetBool(id);
        }

        public void SetInteger(int id, int value)
        {
            foreach (var anim in mAnimatorGroup)
            {
                anim.SetInteger(id, value);
            }
        }

        public int GetInteger(int id)
        {
            return mMain.GetInteger(id);
        }

        public void SetTrigger(int id)
        {
            foreach (var anim in mAnimatorGroup)
            {
                anim.SetTrigger(id);
            }
        }

        public void ResetTrigger(int id)
        {
            foreach (var anim in mAnimatorGroup)
            {
                anim.ResetTrigger(id);
            }
        }
    }
}
