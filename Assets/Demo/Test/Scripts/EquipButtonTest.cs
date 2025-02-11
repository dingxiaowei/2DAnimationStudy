﻿using SpineTest;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class EquipButtonTest : MonoBehaviour
{
    public EquipAsset asset;
    public CharacterChangeSkin spineAnimationTest;
    public Image inventoryImage;

    private void Awake()
    {
        spineAnimationTest = GameObject.Find("Character").GetComponent<CharacterChangeSkin>();
    }
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
                }
            );
    } 
}
