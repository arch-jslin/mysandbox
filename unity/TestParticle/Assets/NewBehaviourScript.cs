using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NewBehaviourScript : MonoBehaviour
{
    static bool flag = false;
    private class Destroyer : MonoBehaviour {
        void OnDestroy() {
            NewBehaviourScript.flag = true;
            Debug.LogFormat("after {0}", NewBehaviourScript.flag.ToString());
        }
    }
  
    GameObject obj;
    int count = 0;
    // Start is called before the first frame update
    void Start()
    {
        Debug.LogFormat("after {0}", NewBehaviourScript.flag.ToString());
        obj = GameObject.CreatePrimitive(PrimitiveType.Cube);
        obj.AddComponent<Destroyer>();
        obj.transform.parent = this.transform;
        obj.SetActive(false);
        Destroy(gameObject);
    }

    // Update is called once per frame
    void Update()
    {   
        //count = count + 1;
        //if( count > 120 && obj != null ) {
        //    Destroy(gameObject);
        //}
    }
}
