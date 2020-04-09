using System.Collections.Generic;

public class AbilityManager
{
    protected Dictionary<EntityAbilityType, EntityAbility> mAbilities = new Dictionary<EntityAbilityType, EntityAbility>();
    public System.Action<EntityAbilityEventsArgs> OnAbilityTriggered;

    public void TriggerAbility(EntityAbilityType abilityType)
    {
        EntityAbilityEventsArgs args = new EntityAbilityEventsArgs();
        args.AbilityType = abilityType;
        TriggerAbility(args);
    }

    public void TriggerAbility(EntityAbilityEventsArgs args)
    {
        OnAbilityTriggered.Invoke(args);
    }

    public void ResetOnDestroy()
    {
        mAbilities.Clear();
    }
}
