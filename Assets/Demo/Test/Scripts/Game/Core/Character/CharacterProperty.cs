using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterProperty : UnityEntityProperty
{
    //TODO:属性改变事件
    public new SpineCharacterTable RawData { get { return (SpineCharacterTable)mRawData; } }
    protected System.Action<EnumCharacterAttr, float> mOnAttributeChanged;
    public event System.Action<EnumCharacterAttr, float> OnAttributeChangedEvent
    {
        add { mOnAttributeChanged += value; }
        remove { mOnAttributeChanged -= value; }
    }

    public float RunCD;
    public bool CanRun;

    public override void SetData(object data)
    {
        base.SetData(data);
        
    }

    public override void ResetOnDestroy()
    {
        base.ResetOnDestroy();
        
    }

    protected override void OnAttributeChanged(int attrid, float value)
    {
        mOnAttributeChanged?.Invoke((EnumCharacterAttr)attrid, value);
        Debug.Log("Character attr changed " + ((EnumCharacterAttr)attrid).ToString() + " : " + value.ToString());
    }
}
