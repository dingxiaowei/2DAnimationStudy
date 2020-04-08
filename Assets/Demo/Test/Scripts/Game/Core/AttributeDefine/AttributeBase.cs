using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AttributeBase
{
    protected object mRawData;
    public object RawData { get { return mRawData; } }

    protected float[] mAttributes;

    public AttributeBase()
    {

    }

    public float GetAttribute(int attrId)
    {
#if UNITY_EDITOR
        if (mAttributes == null)
        {
            UnityEngine.Debug.LogError("Attribute is null ! ");
        }
        else if (mAttributes.Length <= attrId)
        {
            UnityEngine.Debug.LogError("Attribute out of range : " + attrId.ToString());
        }
#endif
        return mAttributes[attrId];
    }

    public void SetAttribute(int attrId, float value)
    {
#if UNITY_EDITOR
        if (mAttributes == null)
        {
            UnityEngine.Debug.LogError("Attribute is null ! ");
        }
        else if (mAttributes.Length <= attrId)
        {
            UnityEngine.Debug.LogError("Attribute out of range : " + attrId.ToString());
        }
#endif
        mAttributes[attrId] = value;
        OnAttributeChanged(attrId, value);
    }

    protected virtual void OnAttributeChanged(int attrid, float value)
    {

    }

    public virtual void SetData(object data)
    {
        mRawData = data;
    }

    public virtual void ResetOnDestroy()
    {
        mRawData = null;
    }
}
