using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using HoloPlay;

public class ButtonsControl : MonoBehaviour
{
    GameObject clock;
    // Start is called before the first frame update
    void Start()
    {
        clock = GameObject.Find("Clock");
    }

    // Update is called once per frame
    void Update()
    {
        if (Buttons.GetButtonDown(ButtonType.ONE))
        {
            clock.SetActive(!clock.activeSelf);
        }
    }
}
