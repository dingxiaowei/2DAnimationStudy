using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Sirenix.OdinInspector;

public class CollisionConfigManager : MonoBehaviour
{
    public Transform CollisonRoot;
    public List<CollisionConfig> CollisionConfigList = new List<CollisionConfig>();
    protected List<GameObject> mChildList = new List<GameObject>();

    public void DisableAllCollision()
    {
        foreach (CollisionConfig cc in CollisionConfigList)
        {
            if (cc != null)
            {
                cc.SetCollisionEnabled(false);
            }
        }
    }

    public void EnableAllCollision()
    {
        foreach (CollisionConfig cc in CollisionConfigList)
        {
            if (cc != null)
            {
                cc.SetCollisionEnabled(true);
            }
        }
    }


    [HorizontalGroup("Split", 0.5f)]
    [Button(ButtonSizes.Medium), GUIColor(0.4f, 0.8f, 1)]
    protected void SaveFromNodes()
    {
#if UNITY_EDITOR
        if (CollisonRoot != null)
        {
            FindAllCollisionConfigInRoot(CollisonRoot);
            foreach (CollisionConfig config in CollisionConfigList)
            {
                config.Node = GetGameObjectPath(CollisonRoot, config.transform.parent);
                config.SaveLocalMessage();
                config.gameObject.layer = Base.Game.Utils.LayerManager.OBJECT_HIT_COLLISION;
                config.transform.SetParent(transform);
                config.transform.localScale = Vector3.one;
            }
        }
#endif
    }

    [VerticalGroup("Split/right")]
    [Button(ButtonSizes.Medium), GUIColor(0, 1, 0)]
    protected virtual void AttachToNodes()
    {
        FindAllChildInMine();

        for (int i = 0; i < mChildList.Count; i++)
        {
            mChildList[i].layer = Base.Game.Utils.LayerManager.OBJECT_HIT_COLLISION;
            CollisionConfig config = mChildList[i].GetComponent<CollisionConfig>();
            string path = config.Node;
            //path = path.Substring(rootPath.Length + 1, path.Length - rootPath.Length - 1);
            Transform transform = CollisonRoot.Find(path);
            if (transform != null)
            {
                mChildList[i].transform.SetParent(transform);
                config.SetLocalMessage();
                mChildList.RemoveAt(i);
                i--;
            }
        }
        CleanMineCollider();
    }

    protected virtual void Start()
    {
        AttachToNodes();

        UnityComponentsCollector collector = GetComponentInParent<UnityComponentsCollector>();
        if (collector != null)
        {
            Transform root = collector.transform;
            foreach (CollisionConfig config in CollisionConfigList)
            {
                config.SetRootTransform(root);
            }
        }
    }

    protected virtual void FindAllCollisionConfigInRoot(Transform root)
    {
        CollisionConfigList.Clear();
        if (root != null)
        {
            CollisionConfigList.AddRange(root.GetComponentsInChildren<CollisionConfig>());
        }
    }

    protected void FindAllChildInMine()
    {
        mChildList.Clear();
        Transform trans = transform;
        for (int i = 0; i < trans.childCount; i++)
        {
            mChildList.Add(trans.GetChild(i).gameObject);
        }
    }

    protected void CleanMineCollider()
    {
        foreach (GameObject go in mChildList)
        {
            DestroyImmediate(go);
        }
        mChildList.Clear();
    }

    protected string GetGameObjectPath(Transform root, Transform trans)
    {
        string path = trans.name;
        if (trans.parent != null)
        {
            Transform parent = trans.parent;
            while (parent && root != parent)
            {
                path = parent.name + "/" + path;
                parent = parent.parent;
            }
        }
        return path;
    }
}
