using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Character : UnityEntity
{
    public CharacterProperty CharacterProperty { get { return mProperty as CharacterProperty; } set { mProperty = value; } }


}
