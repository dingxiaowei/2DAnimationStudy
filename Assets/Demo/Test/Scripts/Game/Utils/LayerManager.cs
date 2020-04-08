using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Base.Game.Utils
{
    static public class LayerManager
    {
        public const int DEFAULT = 0;
        public const int DEFAULT_MASK = 1 << DEFAULT;
        public const int TRANSPARENT_FX = 1;
        public const int TRANSPARENT_FX_MASK = 1 << TRANSPARENT_FX;
        public const int IGNORE_RAYCAST = 2;
        public const int IGNORE_RAYCAST_MASK = 1 << IGNORE_RAYCAST;
        public const int WATER = 4;
        public const int WATER_MASK = 1 << WATER;
        public const int UI = 5;
        public const int UI_MASK = 1 << UI;


        public const int OBJECT_HIT_COLLISION = 10;
        public const int OBJECT_HIT_COLLISION_MASK = 1 << OBJECT_HIT_COLLISION;

        public const int NAVIGATION_COLLIDER = 11;
        public const int NAVIGATION_COLLIDER_MASK = 1 << NAVIGATION_COLLIDER;
    }
}
