using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public struct ProjectileHitInfo
{
    public long EntityId;
    public long ShooterEntityId;
    public long HitEntityId;
    public long Timestamp;
    public float Damage;
    public float Heal;
    public Vector2 HitPosition;

    public void Set(ProjectileEntity pe, Entity hitEntity, float damage, float heal, Vector2 hitPosition)
    {
        EntityId = pe.Property.Id;
        ShooterEntityId = pe.Host.Property.Id;
        HitEntityId = pe.Host.Property.Id;
        Damage = damage;
        Heal = heal;
        HitPosition = hitPosition;
    }
}

public struct OneShootInfo
{

}

public class ProjectileManager : Singleton<ProjectileManager>
{
    protected Dictionary<long, ProjectileEntity> mProjectileManagers = new Dictionary<long, ProjectileEntity>();
    //TODO:
}
