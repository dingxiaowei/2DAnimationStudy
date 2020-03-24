using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class EquipButtonTest : MonoBehaviour
{
    public EquipAsset asset;
    public SpineAnimationTest1 spineAnimationTest;
    public Image inventoryImage;
    void OnValidate()
    {
        MatchImage();
    }

    void MatchImage()
    {
        if (inventoryImage != null)
            inventoryImage.sprite = asset.sprite;
    }
    void Start()
    {
        MatchImage();

        var button = GetComponent<Button>();
        button.onClick.AddListener(
                delegate {
                    spineAnimationTest.Equip(asset);
                    Debug.Log("当前点击的是：" + asset.description);
                }
            );
    } 
}
