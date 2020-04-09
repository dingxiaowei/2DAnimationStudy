using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class CharacterCreatorData
{
    public int CharacterId;

    public CharacterCreatorData InitFromEntitySpawn(Msg.BattleEntityInfo entitySpawnMsg)
    {
        CharacterId = entitySpawnMsg.SpineCharacterId;

        return this;
    }

    public CharacterCreatorData InitFromSpineCharacterData(SpineCharacterTable spineCharacterData)
    {
        CharacterId = spineCharacterData.id;

        return this;
    }
}

public class CharacterCreator
{
    private System.Action<Character> mCallBack;
    public CharacterCreatorData Data { get; private set; }
    public Character Character { get; private set; }
    private bool mIsInBattle;

    public CharacterCreator(CharacterCreatorData data, bool isInBattle, System.Action<Character> callback)
    {
        Data = data;
        mIsInBattle = isInBattle;
        mCallBack = callback;

        Create();
    }

    private void Create()
    {
        var rawData = DataManager.Instance.GetSpineCharacterTableInfo(Data.CharacterId);
        if(rawData == null)
        {
            Debug.LogError($"CharacterId({Data.CharacterId}) not exist");
            return;
        }

        
    }
}
