using UnityEngine;
using System;
using DG.Tweening;

public class ClockAnimator : MonoBehaviour
{
    public DateTime next_deadline_ = new DateTime(2020, 2, 2, 16, 00, 0); 
    public GameObject camera_anchor_;
    public Material mat_ref_;

    private const int FONT_W = 3; // this cannot be changed, because voxel font design is by hand
    private const int SPACING = 1;
    private const int FONT_H = 5; // this cannot be changed, because voxel font design is by hand
    private const int TEXT_COUNT = 10; // _88:88:88_ 
    private const int TOTAL_WIDTH = (FONT_W + SPACING) * TEXT_COUNT;
    private const float CUBE_SIZE = 0.8f;
    private const float DOT_SIZE = CUBE_SIZE * 0.9f;
    private Vector3 BOTTOM_LEFT = new Vector3((-TOTAL_WIDTH/2 + 1) * CUBE_SIZE, -FONT_H/2 * CUBE_SIZE, -4);

    private GameObject[,] dots_;
    private int[,] dots_data_new_ = new int[TOTAL_WIDTH, FONT_H];
    private int[,] dots_data_old_ = new int[TOTAL_WIDTH, FONT_H];
    private DateTime last_time_;
    private int second_count_ = 0;
    private bool clock_mode_ = true;
    private string orig_lottery_string_ = "ABCEFHI";
    private string lottery_string_ = "";
    private int[] lottery_killorder_;
    private int lottery_taken_ = 0;
    private int space_prefill_ = 0;
    
    private const float
        hoursToDegrees_ = 360f / 12f,
        minutesToDegrees_ = 360f / 60f,
        secondsToDegrees_ = 360f / 60f;

    // Start is called before the first frame update
    void Start()
    {
        DOTween.Init();
        DOTween.SetTweensCapacity(2560, 1280);
        
        DateTime time = DateTime.Now;
        TimeSpan diff = next_deadline_ - time;
        last_time_ = time;
        if (diff.TotalMilliseconds >= 0)
        {
            //note: a temp hack to append whitespace wraps
            string_to_dots_display(" "+diff.Hours.ToString("D2") + ":" + diff.Minutes.ToString("D2") + ":" + diff.Seconds.ToString("D2")+" ");
        }
        else
        {
            //note: a temp hack to append whitespace wraps
            string_to_dots_display(" 00:00:00 ");
        }

        dots_ = new GameObject[TOTAL_WIDTH, FONT_H];

        for (int i = 0; i < TOTAL_WIDTH; ++i)
        {
            for (int j = 0; j < FONT_H; ++j)
            {
                dots_[i, j] = GameObject.CreatePrimitive(PrimitiveType.Cube);
                dots_[i, j].transform.SetParent(transform);
                dots_[i, j].transform.position = BOTTOM_LEFT + (new Vector3(i * CUBE_SIZE, j * CUBE_SIZE, 0));
                dots_[i, j].GetComponent<Renderer>().material = mat_ref_;

                if ( dots_data_new_[i, j] == 1 ) {
                    dots_[i, j].transform.localScale = new Vector3(DOT_SIZE, DOT_SIZE, 2f);
                }
                else {
                    dots_[i, j].transform.localScale = new Vector3(.1f, .1f, 2f);
                }
                //dots_[i, j].GetComponent<Renderer>().material.SetColor("default_color", new Color(0, 0, 0));
            }
        }
        dots_data_new_to_old();
    }

    // Update is called once per frame
    void Update()
    {
        handle_input();
        
        if (clock_mode_)
        {
            DateTime time = DateTime.Now;
            if (time.Second != last_time_.Second) // WAIT SO DATETIME SMALLEST UNIT IS NOT SECOND!
            {
                last_time_ = time;
                TimeSpan diff = (next_deadline_ - time);

                if (diff.TotalMilliseconds < 0) return; // If deadline arrived, stop doing anything

                Color emergency_color = Color.white;
                if (diff.Hours == 1)
                {
                    emergency_color = Color.yellow;
                }
                else if (diff.Hours == 0)
                {
                    emergency_color = Color.red;
                }

                //string_to_dots_display(diff.Hours.ToString("D2") + ":" + diff.Minutes.ToString("D2") + ":" + diff.Seconds.ToString("D2"));
                //note: a temp hack to append whitespace wraps
                string_to_dots_display(" " + diff.Hours.ToString("D2") + ":" + diff.Minutes.ToString("D2") + ":" + diff.Seconds.ToString("D2") + " ");
                clock_display_animate(emergency_color);
                dots_data_new_to_old();
                //second_count_ += 1;
            }
        }
    }

    void handle_input()
    {
        if (LookingGlass.ButtonManager.GetButtonDown(LookingGlass.ButtonType.SQUARE))
        {
            clock_mode_ = !clock_mode_;
            if (!clock_mode_)
            { // Transition effect...? 
                lottery_string_ = String.Copy(orig_lottery_string_);
                //populate the kill order based on our lottery_string_
                lottery_killorder_ = new int[lottery_string_.Length];
                for( int i = 0; i < lottery_string_.Length; ++i)
                {
                    lottery_killorder_[i] = i;
                }
                lottery_taken_ = 0;
                //shuffle
                for( int i = 0; i < lottery_killorder_.Length; ++i)
                {
                    int j = UnityEngine.Random.Range(i, lottery_killorder_.Length);
                    int tmp = lottery_killorder_[i];
                    lottery_killorder_[i] = lottery_killorder_[j];
                    lottery_killorder_[j] = tmp;
                }

                int spaces_to_fill = TEXT_COUNT - lottery_string_.Length;
                space_prefill_ = spaces_to_fill / 2;   // we need to remember this number for another button usage
                int postfill = spaces_to_fill / 2 + (Convert.ToBoolean(spaces_to_fill % 2) ? 1 : 0);
                string lottery_string_with_space = "";
                for (int i = 0; i < space_prefill_; ++i) { lottery_string_with_space += " "; }
                lottery_string_with_space += lottery_string_;
                for (int i = 0; i < postfill; ++i) { lottery_string_with_space += " "; }
                string_to_dots_display(lottery_string_with_space);
                clock_display_animate(Color.white);
                dots_data_new_to_old();
            }
            else if( (next_deadline_ - DateTime.Now).TotalMilliseconds <= 0 )
            {
                //note: a temp hack to append whitespace wraps
                string_to_dots_display(" 00:00:00 ");
                clock_display_animate(Color.white);
                dots_data_new_to_old();
            }
        }

        if (LookingGlass.ButtonManager.GetButtonDown(LookingGlass.ButtonType.LEFT))
        {
            if(!clock_mode_)
            {
                if (lottery_taken_ < lottery_killorder_.Length)
                {
                    lottery_string_ = lottery_string_.Remove(lottery_killorder_[lottery_taken_], 1);
                    lottery_string_ = lottery_string_.Insert(lottery_killorder_[lottery_taken_], " ");
                    lottery_taken_ += 1;
                    string lottery_string_with_space = "";
                    for (int i = 0; i < space_prefill_; ++i) { lottery_string_with_space += " "; }
                    lottery_string_with_space += lottery_string_;
                    string_to_dots_display(lottery_string_with_space);
                    clock_display_animate(Color.white);
                    dots_data_new_to_old();
                }
            }
        }
        
        // Mouse-induced camera rotation
        if( camera_anchor_ )
        {
            int center_x = Screen.width / 2;
            int center_y = Screen.height / 2;
            float delta_x  = center_x - Input.mousePosition.x;
            float delta_y  = center_y - Input.mousePosition.y;
            float y_tilt = (delta_x / center_x) * 10;    // difference in x influences rotation on y axis (horizontal rotation)
            float x_tilt = (delta_y / center_y) * 5;     // difference in y influences rotation on x axis (vertical rotation) 
            Quaternion target_rot = Quaternion.Euler((x_tilt > 5f ? 5f : x_tilt), (y_tilt > 10f ? 10f : y_tilt), 0f);
            camera_anchor_.transform.rotation = target_rot;
        }    
    }

    // overriding old data with new data (if the data indeed is different), for the next cycle's update to compare them
    void dots_data_new_to_old()
    {
        for (int i = 0; i < TOTAL_WIDTH; ++i)
        {
            for (int j = 0; j < FONT_H; ++j)
            {
                dots_data_old_[i, j] = dots_data_new_[i, j];
            }
        }
    }

    void clock_display_animate(Color color)
    {
        for (int i = TOTAL_WIDTH - 1; i >= 0; --i)
        {
            float horizontal_delay = (TOTAL_WIDTH - i) * .01f;

            //if (second_count_ == 0)
            //{
            //    horizontal_delay = 0;
            //}

            for (int j = 0; j < FONT_H; ++j)
            {
                if (dots_data_old_[i, j] == 0 && dots_data_new_[i, j] == 1)
                {
                    dots_[i, j].transform.DOScaleX(DOT_SIZE, .33f).SetDelay(horizontal_delay);
                    dots_[i, j].transform.DOScaleY(DOT_SIZE, .33f).SetDelay(horizontal_delay);
                }
                else if (dots_data_old_[i, j] == 1 && dots_data_new_[i, j] == 0)
                {
                    dots_[i, j].transform.DOScaleX(.1f, .33f).SetDelay(horizontal_delay);
                    dots_[i, j].transform.DOScaleY(.1f, .33f).SetDelay(horizontal_delay);
                }
                else
                {
                    Vector3 orig_scale = Vector3.zero;
                    Vector3 blip_scale = Vector3.zero;

                    if (dots_data_new_[i, j] == 0)
                    {
                        orig_scale = new Vector3(.1f, .1f, 2f);
                        blip_scale = new Vector3(.4f, .4f, 2f);
                    }
                    else if (dots_data_new_[i, j] == 1)
                    {
                        orig_scale = new Vector3(DOT_SIZE, DOT_SIZE, 2f);
                        blip_scale = new Vector3(1.2f    , 1.2f    , 2f);
                    }

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

                if (color != Color.white)
                {
                    Sequence seq_color = DOTween.Sequence();
                    seq_color.Append(dots_[i, j].GetComponent<Renderer>().material.DOColor(color, .1f))
                             .Append(dots_[i, j].GetComponent<Renderer>().material.DOColor(Color.white, .3f))
                             .PrependInterval(horizontal_delay).Play();
                }
            }
        }
    }

    // <TEXT_COUNT> length only, and only works on "0123456789:", and only works for FONT_H = 5
    // note: a temp hack to append whitespace wraps
    void string_to_dots_display(string str = " 88:88:88 ")
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
            else if (str[i] == ' ')
            {
                buffer = new int[,]
                {
                    {0,0,0},
                    {0,0,0},
                    {0,0,0},
                    {0,0,0},
                    {0,0,0},
                };
            }
            else if (str[i] == 'A')
            {
                buffer = new int[,]
                {
                    {0,1,0},
                    {1,0,1},
                    {1,1,1},
                    {1,0,1},
                    {1,0,1},
                };
            }
            else if (str[i] == 'B')
            {
                buffer = new int[,]
                {
                    {1,1,1},
                    {1,0,1},
                    {1,1,0},
                    {1,0,1},
                    {1,1,1},
                };
            }
            else if (str[i] == 'C')
            {
                buffer = new int[,]
                {
                    {1,1,1},
                    {1,0,0},
                    {1,0,0},
                    {1,0,0},
                    {1,1,1},
                };
            }
            else if (str[i] == 'D')
            {
                buffer = new int[,]
                {
                    {1,1,0},
                    {1,0,1},
                    {1,0,1},
                    {1,0,1},
                    {1,1,0},
                };
            }
            else if (str[i] == 'E')
            {
                buffer = new int[,]
                {
                    {1,1,1},
                    {1,0,0},
                    {1,1,1},
                    {1,0,0},
                    {1,1,1},
                };
            }
            else if (str[i] == 'F')
            {
                buffer = new int[,]
                {
                    {1,1,1},
                    {1,0,0},
                    {1,1,1},
                    {1,0,0},
                    {1,0,0},
                };
            }
            else if (str[i] == 'G')
            {
                buffer = new int[,]
                {
                    {0,1,1},
                    {1,0,0},
                    {1,0,1},
                    {1,0,1},
                    {1,1,0},
                };
            }
            else if (str[i] == 'H')
            {
                buffer = new int[,]
                {
                    {1,0,1},
                    {1,0,1},
                    {1,1,1},
                    {1,0,1},
                    {1,0,1},
                };
            }
            else if (str[i] == 'I')
            {
                buffer = new int[,]
                {
                    {1,1,1},
                    {0,1,0},
                    {0,1,0},
                    {0,1,0},
                    {1,1,1},
                };
            }
            else if (str[i] == 'J')
            {
                buffer = new int[,]
                {
                    {1,1,1},
                    {0,0,1},
                    {0,0,1},
                    {0,0,1},
                    {1,1,0},
                };
            }
            else if( str[i] == 'K')
            {
                buffer = new int[,]
                {
                    {1,0,1},
                    {1,0,1},
                    {1,1,0},
                    {1,0,1},
                    {1,0,1},
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
                    int invert_y = (FONT_H - n) - 1;// stupidly... y is inverted with the buffer array design;
                    if (buffer[n, m] == 1)          // stupidly... we need to transpose buffer here because of significant dimension
                    {
                        dots_data_new_[starting_position + m, invert_y] = 1;
                    }
                    else if (buffer[n, m] == 0)
                    {
                        dots_data_new_[starting_position + m, invert_y] = 0;
                    }
                }
            }

            // handle spacing
            for (int n = 0; n < FONT_H; ++n)
            {
                for (int m = 0; m < SPACING; ++m)
                {
                    dots_data_new_[starting_position + FONT_W + m, n] = 0;
                }
            }
        }
    }
}

