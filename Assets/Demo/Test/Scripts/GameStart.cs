using Framework.Mgr;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameStart : MonoBehaviour
{
    public Vector3 Position;
    public GameObject CharacterPrefab;

    private List<IMgr> mMgrList;

    private void Awake()
    {
        //启动各种Manager
        RegisterAllMgr();
    }

    void Start()
    {
        foreach (var mgr in mMgrList)
        {
            mgr.Start();
        }

        var obj = GameObject.Instantiate(CharacterPrefab, Position, Quaternion.identity);

    }

    private void RegisterAllMgr()
    {
        mMgrList = new List<IMgr>();
        mMgrList.Add(TimeManager.Instance);
        mMgrList.Add(DataManager.Instance);

        foreach(var mgr in mMgrList)
        {
            mgr.Init();
        }
    }

    void Update()
    {
        foreach (var mgr in mMgrList)
        {
            mgr.Update();
        }
    }

    private void FixedUpdate()
    {
        foreach (var mgr in mMgrList)
        {
            mgr.FixedUpdate();
        }
    }

    private void LateUpdate()
    {
        foreach (var mgr in mMgrList)
        {
            mgr.LateUpdate();
        }
    }

    void OnDestroy()
    {
        foreach(var mgr in mMgrList)
        {
            mgr.OnDestroy();
        }
        mMgrList.Clear();
    }
}
