using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterProperty : UnityEntityProperty
{
    //TODO:属性改变事件
    public new SpineCharacterTable RawData { get { return (SpineCharacterTable)mRawData; } }

    public override void SetData(object data)
    {
        base.SetData(data);
        
    }

    public override void ResetOnDestroy()
    {
        base.ResetOnDestroy();
        
    }
}
