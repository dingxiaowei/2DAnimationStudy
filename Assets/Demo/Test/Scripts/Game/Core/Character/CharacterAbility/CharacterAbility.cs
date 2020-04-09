using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterAbility : EntityAbility
{
    protected Character mCharacter;
    public CharacterAbility(Character character) : base(character)
    {
        mCharacter = character;
    }
}
