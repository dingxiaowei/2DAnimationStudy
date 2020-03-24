using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "EquipAsset", menuName = "MyAsset/CreateEquipAsset")]
public class EquipAsset : ScriptableObject
{
    public SpineAnimationTest1.EquipType equipType;
    public Sprite sprite;
    public string description;
}
