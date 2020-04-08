using Spine;
using Spine.Unity;
using Spine.Unity.AttachmentTools;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace SpineTest
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
    public class CharacterChangeSkin : MonoBehaviour
    {
        public SkeletonDataAsset skeletonDataAsset;
        public Material SourceMaterial;
        public List<EquipHook> EquipHookList = new List<EquipHook>();
        public Dropdown SkinDropdown;

        SkeletonData mSkeletonData;
        SkeletonMecanim skeletonMecanim;
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
            skeletonMecanim = GetComponentInChildren<SkeletonMecanim>();
            if (skeletonMecanim == null)
                Debug.LogError("没有找到SkeletonMecanim组件");
            UpdateSkinData();
        }

        private void Start()
        {
            mSkeletonData = skeletonMecanim?.skeleton.Data;
            //HeadDropdown.onValueChanged.AddListener(ChangeHead);
            //AnimDropdown.onValueChanged.AddListener(ChangeAnim);
            SkinDropdown.onValueChanged.AddListener(ChangeSkin);
            equipsSkin = new Skin("Equips");
            var templateSkin = skeletonMecanim.Skeleton.Data.FindSkin(templateSkinName);
            if (templateSkin != null)
                equipsSkin.AddAttachments(templateSkin);
            skeletonMecanim.Skeleton.Skin = equipsSkin;
            RefreshSkeletonAttachments();

            //UpdateAnimData();
        }

        void RefreshSkeletonAttachments()
        {
            skeletonMecanim.Skeleton.SetSlotsToSetupPose();
            //skeletonMecanim.AnimationState.Apply(skeletonMecanim.Skeleton); //skeletonAnimation.Update(0);
        }

        void UpdateSkinData()
        {
            skins.Clear();
            foreach (var skin in skeletonMecanim.Skeleton.Data.Skins)
            {
                skins.Add(skin);
                mSkinList.Add(new Dropdown.OptionData(skin.Name));
            }
            equipsSkin = skeletonMecanim.Skeleton.Data.DefaultSkin;
            SkinDropdown.options = mSkinList;
        }

        void ChangeSkin(int value)
        {
            if (value < mSkinList.Count)
            {
                skeletonMecanim.Skeleton.Skin = skins[value];
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
            skeletonMecanim.Skeleton.SetSkin(equipsSkin);
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
    }
}
