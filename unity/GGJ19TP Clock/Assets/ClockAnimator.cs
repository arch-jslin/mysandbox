using UnityEngine;
using System;

public class ClockAnimator : MonoBehaviour
{
    public Transform hours, minutes, seconds;
    public bool analog;
    private const int FONT_W = 3; // this cannot be changed, because voxel font design is by hand
    private const int SPACING = 1;
    private const int FONT_H = 5; // this cannot be changed, because voxel font design is by hand
    private const int TEXT_COUNT = 8; // 88:88:88 
    private const int TOTAL_WIDTH = (FONT_W + SPACING) * TEXT_COUNT;
    private const float CUBE_SIZE = 1f;
    private Vector3 BOTTOM_LEFT = new Vector3(0, 0, 0);

    private GameObject[,] dots_; 

    private const float
        hoursToDegrees_ = 360f / 12f,
        minutesToDegrees_ = 360f / 60f,
        secondsToDegrees_ = 360f / 60f;

    // Start is called before the first frame update
    void Start()
    {
        dots_ = new GameObject[TOTAL_WIDTH, FONT_H];
        
        for( int i = 0; i < TOTAL_WIDTH; ++i )
        {
            for( int j = 0; j < FONT_H; ++j )
            {
                dots_[i, j] = GameObject.CreatePrimitive(PrimitiveType.Cube);
                dots_[i, j].transform.position = BOTTOM_LEFT + (new Vector3(i*CUBE_SIZE, j*CUBE_SIZE, 0));
                dots_[i, j].transform.localScale = new Vector3(.7f, .7f, .7f);
                //dots_[i, j].GetComponent<Renderer>().material.SetColor("default_color", new Color(0, 0, 0));
            }
        }

        string_to_dots_display("12:34:56");
    }
    
    // <TEXT_COUNT> length only, and only works on "0123456789:", and only works for FONT_H = 5
    void string_to_dots_display(string str = "88:88:88")
    {
        int[,] buffer;
        for( int i = 0; i < str.Length; ++i )
        {
            int starting_position = i * (FONT_W + SPACING);
            if ( starting_position >= TOTAL_WIDTH ) continue;  // fail safe 
            if( str[i] == '0' )
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
            else if( str[i] == '1' )
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
            else if( str[i] == '2' )
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

            for( int m = 0; m < FONT_W; ++m )
            {
                for( int n = 0; n < FONT_H; ++n)
                {
                    int invert_y = (FONT_H - n) - 1; // stupidly... y is inverted with the buffer array design;
                    if( buffer[n, m] == 1 )          // stupidly... we need to transpose buffer here because of significant dimension
                    {
                        dots_[starting_position + m, invert_y].transform.localScale = new Vector3(.9f, .9f, .9f);
                    }
                    else if ( buffer[n, m] == 0 )
                    {
                        dots_[starting_position + m, invert_y].transform.localScale = new Vector3(.1f, .1f, .1f);
                    }
                }
            }

            // handle spacing
            for( int n = 0; n < FONT_H; ++n )
            {
                for (int m = 0; m < SPACING; ++m)
                {
                    dots_[starting_position + FONT_W + m, n].transform.localScale = new Vector3(.1f, .1f, .1f);
                }
            }
        }
    }

    // Update is called once per frame
    void Update()
    {
        if( analog ) {
            TimeSpan timespan = DateTime.Now.TimeOfDay;
            hours.localRotation =
                Quaternion.Euler(0f, 0f, (float)timespan.TotalHours * -hoursToDegrees_);
            minutes.localRotation =
                Quaternion.Euler(0f, 0f, (float)timespan.TotalMinutes * -minutesToDegrees_);
            seconds.localRotation =
                Quaternion.Euler(0f, 0f, (float)timespan.TotalSeconds * -secondsToDegrees_);
        }
        else {
            DateTime time = DateTime.Now;
            hours.localRotation = Quaternion.Euler(0f, 0f, time.Hour * -hoursToDegrees_);
            minutes.localRotation = Quaternion.Euler(0f, 0f, time.Minute * -minutesToDegrees_);
            seconds.localRotation = Quaternion.Euler(0f, 0f, time.Second * -secondsToDegrees_);
        }
    }
}

