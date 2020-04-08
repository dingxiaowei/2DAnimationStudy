using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Framework.Mgr;
using LitJson;

public class DataManager : ManagerBase<DataManager>
{
    public Dictionary<int, SpineCharacterTable> spineCharacterRows = new Dictionary<int, SpineCharacterTable>();
    public override void Init()
    {
        base.Init();

        //加载角色表
        TextAsset jsonData = Resources.Load<TextAsset>("Tables/spinecharacters");
        var jsonObject = JsonMapper.ToObject<List<SpineCharacterTable>>(jsonData.text);
        foreach (var info in jsonObject)
        {
            spineCharacterRows.Add(info.id, info);
        }

        //TODO:加载其他表
    }

    public SpineCharacterTable GetSpineCharacterTableInfo(int id)
    {
        if (spineCharacterRows.ContainsKey(id))
            return spineCharacterRows[id];
        else
            return null;
    }


    public override void OnDestroy()
    {
        base.OnDestroy();
        spineCharacterRows.Clear();
    }
}
