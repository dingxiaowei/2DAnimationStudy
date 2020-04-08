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
    //private System.Action<Character>
}
