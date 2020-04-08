using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[SerializeField]
public class SpineCharacterData
{
    public int id { get; set; }
    public string prefab { get; set; }

}

[CreateAssetMenu(fileName = "SpineCharacterAsset", menuName = "MyAsset/CreateSpineCharacterAsset")]
public class SpineCharacterAsset : ScriptableObject
{
    
}
