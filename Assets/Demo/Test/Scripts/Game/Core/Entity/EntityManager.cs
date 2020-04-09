using Framework.Mgr;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EntityManager : ManagerBase<EntityManager>
{
    private Dictionary<Type, List<Entity>> mEntityLists = new Dictionary<Type, List<Entity>>();
    private Dictionary<Type, List<Entity>> mToDestroyEntityLists = new Dictionary<Type, List<Entity>>();
    private Dictionary<UnityEngine.Transform, Entity> mEntityTransformMap = new Dictionary<Transform, Entity>();

}
