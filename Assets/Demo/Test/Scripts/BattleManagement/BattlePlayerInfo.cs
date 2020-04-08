using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BattlePlayerInfo
{
    public long Id { get; set; }
    public string Name { get; set; }
    public bool IsAvatar { get; set; }

    //队伍ID
    public int PartId { get; set; }

    public BattlePlayerInfo(Msg.BattlePlayerInfo info)
    {
        Id = info.Id;
        Name = info.Name;
        PartId = info.PartId;
    }
}
