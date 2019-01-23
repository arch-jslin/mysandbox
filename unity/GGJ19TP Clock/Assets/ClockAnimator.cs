using UnityEngine;
using System;

public class ClockAnimator : MonoBehaviour
{
    public Transform hours, minutes, seconds;

    private const float
        hoursToDegrees_ = 360f / 12f,
        minutesToDegrees_ = 360f / 60f,
        secondsToDegrees_ = 360f / 60f;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        DateTime time = DateTime.Now;
        hours.localRotation = Quaternion.Euler(0f, 0f, time.Hour * -hoursToDegrees_);
        minutes.localRotation = Quaternion.Euler(0f, 0f, time.Minute * -minutesToDegrees_);
        seconds.localRotation = Quaternion.Euler(0f, 0f, time.Second * -secondsToDegrees_);
    }
}

