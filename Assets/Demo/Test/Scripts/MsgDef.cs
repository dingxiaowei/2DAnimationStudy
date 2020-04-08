using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Msg
{
    public partial class BattlePlayerInfo
    {
        public long Id { get; set; }
        public string Name { get; set; }
        public int PartId { get; set; }

        
    }

    public partial class BattleEntityInfo
    {
        public long Id { get; set; }

        public int SpineCharacterId { get; set; }
        
        public long Owner { get; set; }
    }

}
