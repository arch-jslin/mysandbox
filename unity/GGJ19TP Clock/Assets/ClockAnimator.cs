﻿using UnityEngine;
using System;
using DG.Tweening;

public class ClockAnimator : MonoBehaviour
{
    public Transform hours, minutes, seconds;
    public bool analog;
    public DateTime next_deadline_ = new DateTime(2019, 1, 26, 10, 0, 0); 

    private const int FONT_W = 3; // this cannot be changed, because voxel font design is by hand
    private const int SPACING = 1;
    private const int FONT_H = 5; // this cannot be changed, because voxel font design is by hand
    private const int TEXT_COUNT = 8; // 88:88:88 
    private const int TOTAL_WIDTH = (FONT_W + SPACING) * TEXT_COUNT;
    private const float CUBE_SIZE = 1f;
    private Vector3 BOTTOM_LEFT = new Vector3((-TOTAL_WIDTH/2) * CUBE_SIZE, -FONT_H/2 * CUBE_SIZE, 0);

    private GameObject[,] dots_;
    private int[,] dots_data_new_ = new int[TOTAL_WIDTH, FONT_H];
    private int[,] dots_data_old_ = new int[TOTAL_WIDTH, FONT_H];
    private DateTime last_time_;
    private int second_count_ = 0;

    private const float
        hoursToDegrees_ = 360f / 12f,
        minutesToDegrees_ = 360f / 60f,
        secondsToDegrees_ = 360f / 60f;

    // Start is called before the first frame update
    void Start()
    {
        DOTween.Init();

        dots_ = new GameObject[TOTAL_WIDTH, FONT_H];
        
        for( int i = 0; i < TOTAL_WIDTH; ++i )
        {
            for( int j = 0; j < FONT_H; ++j )
            {
                dots_[i, j] = GameObject.CreatePrimitive(PrimitiveType.Cube);
                dots_[i, j].transform.position = BOTTOM_LEFT + (new Vector3(i*CUBE_SIZE, j*CUBE_SIZE, 0));
                dots_[i, j].transform.localScale = new Vector3(.1f, .1f, 2f);
                //dots_[i, j].GetComponent<Renderer>().material.SetColor("default_color", new Color(0, 0, 0));
            }
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (analog)
        {
            TimeSpan timespan = DateTime.Now.TimeOfDay;
            hours.localRotation =
                Quaternion.Euler(0f, 0f, (float)timespan.TotalHours * -hoursToDegrees_);
            minutes.localRotation =
                Quaternion.Euler(0f, 0f, (float)timespan.TotalMinutes * -minutesToDegrees_);
            seconds.localRotation =
                Quaternion.Euler(0f, 0f, (float)timespan.TotalSeconds * -secondsToDegrees_);
        }
        else
        {
            DateTime time = DateTime.Now;          
            if ((time - last_time_).Seconds > 0) // WAIT SO DATETIME SMALLEST UNIT IS NOT SECOND!
            {
                last_time_ = time;
                TimeSpan diff = (next_deadline_ - time);
                //hours.localRotation = Quaternion.Euler(0f, 0f, time.Hour * -hoursToDegrees_);
                //minutes.localRotation = Quaternion.Euler(0f, 0f, time.Minute * -minutesToDegrees_);
                //seconds.localRotation = Quaternion.Euler(0f, 0f, time.Second * -secondsToDegrees_);
                string_to_dots_display(diff.Hours.ToString("D2") + ":"+ diff.Minutes.ToString("D2") + ":" + diff.Seconds.ToString("D2"));

                for (int i = TOTAL_WIDTH - 1; i >= 0; --i)
                {
                    float horizontal_delay = (TOTAL_WIDTH - i) * .01f;

                    if (second_count_ == 0)
                    {
                        horizontal_delay = 0;
                    }

                    for (int j = 0; j < FONT_H; ++j) 
                    {
                        if (dots_data_old_[i, j] == 0 && dots_data_new_[i, j] == 1)
                        {
                            dots_[i, j].transform.DOScaleX(.9f, .33f).SetDelay(horizontal_delay);
                            dots_[i, j].transform.DOScaleY(.9f, .33f).SetDelay(horizontal_delay);
                        }
                        else if (dots_data_old_[i, j] == 1 && dots_data_new_[i, j] == 0)
                        {
                            dots_[i, j].transform.DOScaleX(.1f, .33f).SetDelay(horizontal_delay);
                            dots_[i, j].transform.DOScaleY(.1f, .33f).SetDelay(horizontal_delay);
                        } 
                        else
                        {
                            Vector3 orig_scale = dots_[i, j].transform.localScale;
                            Vector3 blip_scale = orig_scale + (new Vector3(.2f, .2f, 0f));

                            Sequence seqx = DOTween.Sequence();
                            Sequence seqy = DOTween.Sequence();

                            seqx.Append(dots_[i, j].transform.DOScaleX(blip_scale.x, .1f))
                                .Append(dots_[i, j].transform.DOScaleX(orig_scale.x, .23f))
                                .PrependInterval(horizontal_delay)
                                .Play();

                            seqy.Append(dots_[i, j].transform.DOScaleY(blip_scale.y, .1f))
                                .Append(dots_[i, j].transform.DOScaleY(orig_scale.y, .23f))
                                .PrependInterval(horizontal_delay)
                                .Play();
                        }
                    }
                }

                // overriding old data with new data (if the data indeed is different), for the next cycle's update to compare them
                for (int i = 0; i < TOTAL_WIDTH; ++i)
                {
                    for (int j = 0; j < FONT_H; ++j)
                    {
                        dots_data_old_[i, j] = dots_data_new_[i, j];
                    }
                }
                second_count_ += 1;
            }
        }
    }

    // <TEXT_COUNT> length only, and only works on "0123456789:", and only works for FONT_H = 5
    void string_to_dots_display(string str = "88:88:88")
    {
        int[,] buffer;
        for (int i = 0; i < str.Length; ++i)
        {
            int starting_position = i * (FONT_W + SPACING);
            if (starting_position >= TOTAL_WIDTH) continue;  // fail safe 
            if (str[i] == '0')
            {
                buffer = new int[,]
                {
                    {1,1,1},
                    {1,0,1},
                    {1,0,1},
                    {1,0,1},
                    {1,1,1}
                };
            }
            else if (str[i] == '1')
            {
                buffer = new int[,]
                {
                    {1,1,0},
                    {0,1,0},
                    {0,1,0},
                    {0,1,0},
                    {1,1,1}
                };
            }
            else if (str[i] == '2')
            {
                buffer = new int[,]
                {
                    {1,1,1},
                    {0,0,1},
                    {1,1,1},
                    {1,0,0},
                    {1,1,1}
                };
            }
            else if (str[i] == '3')
            {
                buffer = new int[,]
                {
                    {1,1,1},
                    {0,0,1},
                    {1,1,1},
                    {0,0,1},
                    {1,1,1}
                };
            }
            else if (str[i] == '4')
            {
                buffer = new int[,]
                {
                    {1,0,1},
                    {1,0,1},
                    {1,1,1},
                    {0,0,1},
                    {0,0,1}
                };
            }
            else if (str[i] == '5')
            {
                buffer = new int[,]
                {
                    {1,1,1},
                    {1,0,0},
                    {1,1,1},
                    {0,0,1},
                    {1,1,1}
                };
            }
            else if (str[i] == '6')
            {
                buffer = new int[,]
                {
                    {1,1,1},
                    {1,0,0},
                    {1,1,1},
                    {1,0,1},
                    {1,1,1}
                };
            }
            else if (str[i] == '7')
            {
                buffer = new int[,]
                {
                    {1,1,1},
                    {0,0,1},
                    {0,0,1},
                    {0,0,1},
                    {0,0,1}
                };
            }
            else if (str[i] == '8')
            {
                buffer = new int[,]
                {
                    {1,1,1},
                    {1,0,1},
                    {1,1,1},
                    {1,0,1},
                    {1,1,1}
                };
            }
            else if (str[i] == '9')
            {
                buffer = new int[,]
                {
                    {1,1,1},
                    {1,0,1},
                    {1,1,1},
                    {0,0,1},
                    {0,0,1}
                };
            }
            else if (str[i] == ':')
            {
                buffer = new int[,]
                {
                    {0,0,0},
                    {0,1,0},
                    {0,0,0},
                    {0,1,0},
                    {0,0,0},
                };
            }
            else // default is ? 
            {
                buffer = new int[,]
                {
                    {1,1,1},
                    {0,0,1},
                    {0,1,1},
                    {0,0,0},
                    {0,1,0}
                };
            }

            for (int m = 0; m < FONT_W; ++m)
            {
                for (int n = 0; n < FONT_H; ++n)
                {
                    int invert_y = (FONT_H - n) - 1; // stupidly... y is inverted with the buffer array design;
                    if (buffer[n, m] == 1)          // stupidly... we need to transpose buffer here because of significant dimension
                    {
                        //dots_[starting_position + m, invert_y].transform.localScale = new Vector3(.9f, .9f, 2f);
                        //dots_[starting_position + m, invert_y].transform.DOScaleX(.9f, .33f);
                        //dots_[starting_position + m, invert_y].transform.DOScaleY(.9f, .33f);
                        dots_data_new_[starting_position + m, invert_y] = 1;
                    }
                    else if (buffer[n, m] == 0)
                    {
                        //dots_[starting_position + m, invert_y].transform.localScale = new Vector3(.1f, .1f, 2f);
                        //dots_[starting_position + m, invert_y].transform.DOScaleX(.1f, .33f);
                        //dots_[starting_position + m, invert_y].transform.DOScaleY(.1f, .33f);
                        dots_data_new_[starting_position + m, invert_y] = 0;
                    }
                }
            }

            // handle spacing
            for (int n = 0; n < FONT_H; ++n)
            {
                for (int m = 0; m < SPACING; ++m)
                {
                    //dots_[starting_position + FONT_W + m, n].transform.localScale = new Vector3(.1f, .1f, 2f);
                    dots_data_new_[starting_position + FONT_W + m, n] = 0;
                }
            }
        }
    }
}

