using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "EquipAsset", menuName = "MyAsset/CreateEquipAsset")]
public class EquipAsset : ScriptableObject
{
    public SpineTest.EquipType equipType;
    public Sprite sprite;
    public string description;
}
