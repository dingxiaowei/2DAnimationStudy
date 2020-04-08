using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Mover : MonoBehaviour
{
    
    Transform trans;
    Vector3 orig;

    // Start is called before the first frame update
    void Start()
    {
        trans = this.GetComponent<Transform>();
        orig = trans.position;
    }

    // Update is called once per frame
    void Update()
    {
        var pos = orig;
        pos.z += Mathf.Sin( Time.time * 2);
        pos.x += Mathf.Cos( Time.time * 2);
        trans.position = pos;
    }
}
