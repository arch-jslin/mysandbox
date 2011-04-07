#include <cstdio>
#include "AL/alure.h"

volatile int isdone = 0;
static void eos_callback(void *unused, ALuint unused2)
{
    isdone = 1;
    (void)unused;
    (void)unused2;
    fprintf(stdout, "The audio stream has done playing.\n");
}

#define NUM_BUFS 3

int main(int argc, char **argv)
{
    alureStream *stream;
    ALuint src, buf[NUM_BUFS];

    if(argc < 2)
    {
        fprintf(stderr, "Usage %s <soundfile>\n", argv[0]);
        return 1;
    }

    if(!alureInitDevice(NULL, NULL))
    {
        fprintf(stderr, "Failed to open OpenAL device: %s\n", alureGetErrorString());
        return 1;
    }

    alGenSources(1, &src);
    if(alGetError() != AL_NO_ERROR)
    {
        fprintf(stderr, "Failed to create OpenAL source!\n");
        alureShutdownDevice();
        return 1;
    }

    //alureStreamSizeIsMicroSec(AL_TRUE); -- let's still use byte as length unit. We're not making general music player.

    stream = alureCreateStreamFromFile(argv[1], 4096, NUM_BUFS, buf);
    if(!stream)
    {
        fprintf(stderr, "Could not load %s: %s\n", argv[1], alureGetErrorString());
        alDeleteSources(1, &src);

        alureShutdownDevice();
        return 1;
    }

    alSourcef(src, AL_GAIN, 0.5f);

    if(!alurePlaySourceStream(src, stream, NUM_BUFS, -1, eos_callback, NULL))
    {
        fprintf(stderr, "Failed to play stream: %s\n", alureGetErrorString());
        isdone = 1;
    }

    while(!isdone)
    {
        alureSleep(0.01);
        alureUpdate();
    }
    alureStopSource(src, AL_FALSE);

    alDeleteSources(1, &src);
    alureDestroyStream(stream, NUM_BUFS, buf);

    alureShutdownDevice();
    return 0;
}
