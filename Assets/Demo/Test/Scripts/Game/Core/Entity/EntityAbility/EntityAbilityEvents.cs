using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum SkillButtonPressState
{
    DOWN = 0,
    UP,
}

public class EntityAbilityEventsArgs : System.EventArgs
{

    public EntityAbilityType AbilityType { get; set; }
}

public class MoveAbilityEventArgs : EntityAbilityEventsArgs
{
    public MoveAbilityEventArgs()
    {
        AbilityType = EntityAbilityType.MOVE;
    }
    public UnityEngine.Vector2 MoveDirection { get; set; }
}
