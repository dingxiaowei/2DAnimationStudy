using UnityEngine;
using System.Collections;
using Spine.Unity;
using System.Collections.Generic;
using Spine;
using System;
using UnityEngine.UI;
using Spine.Unity.AttachmentTools;

public class SpineAnimationTest1 : MonoBehaviour
{
    public enum EquipType
    {
        Head,
        Weapon
    }

    [Serializable]
    public class EquipHook
    {
        public EquipType Type;
        [SpineSlot]
        public string Slot;
        [SpineSkin]
        public string Skin;
        [SpineAttachment(skinField: "Skin")]
        public string Attachment;
    }

    [SpineAnimation("Idle")]
    public string idleAnimation;

    [SpineAnimation]
    public string attackAnimation;

    [SpineAnimation]
    public string moveAnimation;

    [Range(0, 0.2f)]
    public float blinkDuration = 0.05f;

    public KeyCode attackKey = KeyCode.Mouse0;
    public KeyCode rightKey = KeyCode.D;
    public KeyCode leftKey = KeyCode.A;

    public float moveSpeed = 3;

    public SkeletonDataAsset skeletonDataAsset;
    public Material SourceMaterial;
    public List<EquipHook> EquipHookList = new List<EquipHook>();
    //public Dropdown AnimDropdown;
    public Dropdown SkinDropdown;
    //public Dropdown HeadDropdown;
    //public Dropdown WeaponDropdown;

    SkeletonData mSkeletonData;
    SkeletonAnimation skeletonAnimation;
    List<Spine.Skin> skins = new List<Spine.Skin>();
    int currentSkinIndex = 0;
    List<Dropdown.OptionData> mAnimNameList = new List<Dropdown.OptionData>();
    List<Dropdown.OptionData> mSkinList = new List<Dropdown.OptionData>();
    public Dictionary<EquipAsset, Attachment> cachedAttachments = new Dictionary<EquipAsset, Attachment>();
    Spine.Skin equipsSkin;
    Spine.Skin collectedSkin;
    [SpineSkin]
    public string templateSkinName;
    void Awake()
    {
        skeletonAnimation = GetComponent<SkeletonAnimation>();
       
        UpdateSkinData();
    }

    private void Start()
    {
        mSkeletonData = skeletonAnimation?.skeleton.Data;
        //HeadDropdown.onValueChanged.AddListener(ChangeHead);
        //AnimDropdown.onValueChanged.AddListener(ChangeAnim);
        SkinDropdown.onValueChanged.AddListener(ChangeSkin);
        equipsSkin = new Skin("Equips");
        var templateSkin = skeletonAnimation.Skeleton.Data.FindSkin(templateSkinName);
        if (templateSkin != null)
            equipsSkin.AddAttachments(templateSkin);
        skeletonAnimation.Skeleton.Skin = equipsSkin;
        RefreshSkeletonAttachments();

        //UpdateAnimData();
    }

    //void ChangeHead(int value)
    //{

    //}

    void RefreshSkeletonAttachments()
    {
        skeletonAnimation.Skeleton.SetSlotsToSetupPose();
        skeletonAnimation.AnimationState.Apply(skeletonAnimation.Skeleton); //skeletonAnimation.Update(0);
    }

    //void UpdateAnimData()
    //{
    //    mAnimNameList.Clear();
    //    foreach (var animation in mSkeletonData.Animations)
    //        mAnimNameList.Add(new Dropdown.OptionData(animation.Name));

    //    AnimDropdown.options = mAnimNameList;

    //    if (mAnimNameList.Count > 0)
    //        ChangeAnim(0);
    //}

    //void ChangeAnim(int value)
    //{
    //    if (value < mAnimNameList.Count)
    //        skeletonAnimation.AnimationName = mAnimNameList[value].text;
    //}

    void UpdateSkinData()
    {
        skins.Clear();
        foreach (var skin in skeletonAnimation.Skeleton.Data.Skins)
        {
            skins.Add(skin);
            mSkinList.Add(new Dropdown.OptionData(skin.Name));
        }
        equipsSkin = skeletonAnimation.Skeleton.Data.DefaultSkin;
        SkinDropdown.options = mSkinList;
    }

    void ChangeSkin(int value)
    {
        if(value < mSkinList.Count)
        {
            skeletonAnimation.Skeleton.Skin = skins[value];
            equipsSkin = skins[value];
        }
    }

    public void Equip(EquipAsset asset)
    {
        var equipType = asset.equipType;
        EquipHook howToEquip = EquipHookList.Find(x => x.Type == equipType);

        var skeletonData = skeletonDataAsset.GetSkeletonData(true);
        int slotIndex = skeletonData.FindSlotIndex(howToEquip.Slot);
        var attachment = GenerateAttachmentFromEquipAsset(asset, slotIndex, howToEquip.Skin, howToEquip.Attachment);
        Equip(slotIndex, howToEquip.Attachment, attachment);
    }

    void Equip(int slotIndex, string attachmentName, Attachment attachment)
    {
        equipsSkin.SetAttachment(slotIndex, attachmentName, attachment);
        skeletonAnimation.Skeleton.SetSkin(equipsSkin);
        RefreshSkeletonAttachments();
    }

    Attachment GenerateAttachmentFromEquipAsset(EquipAsset asset, int slotIndex, string templateSkinName, string templateAttachmentName)
    {
        Attachment attachment;
        cachedAttachments.TryGetValue(asset, out attachment);

        if (attachment == null)
        {
            var skeletonData = skeletonDataAsset.GetSkeletonData(true);
            var templateSkin = skeletonData.FindSkin(templateSkinName);
            Attachment templateAttachment = templateSkin.GetAttachment(slotIndex, templateAttachmentName);
            attachment = templateAttachment?.GetRemappedClone(asset.sprite, SourceMaterial); //没有武器

            cachedAttachments.Add(asset, attachment); // Cache this value for next time this asset is used.
        }

        return attachment;
    }


    void Update()
    {
        if (Input.GetKey(attackKey))
        {
            skeletonAnimation.AnimationName = attackAnimation;
        }
        else
        {
            if (Input.GetKey(rightKey))
            {
                skeletonAnimation.AnimationName = moveAnimation;
                //skeletonAnimation.AnimationState.SetAnimation(0, moveAnimation, true);
                skeletonAnimation.Skeleton.ScaleX = -1;
                transform.Translate(moveSpeed * Time.deltaTime, 0, 0);
            }
            else if (Input.GetKey(leftKey))
            {
                skeletonAnimation.AnimationName = moveAnimation;
                //skeletonAnimation.AnimationState.SetAnimation(0, moveAnimation, true);
                skeletonAnimation.Skeleton.ScaleX = 1;
                transform.Translate(-moveSpeed * Time.deltaTime, 0, 0);
            }
            else
            {
                skeletonAnimation.AnimationName = idleAnimation;
            }
        }

        //if (Input.GetMouseButtonUp(1))
        //{
        //    var skinIndex = (currentSkinIndex++) % skins.Count;
        //    if (skinIndex == 0)
        //        skinIndex = 1;
        //    skeletonAnimation.Skeleton.Skin = skins[skinIndex];
        //}
    }
}
