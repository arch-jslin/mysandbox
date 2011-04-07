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
    alureStream *stream2; //test playing multiple file
    ALuint src, buf[NUM_BUFS];
    ALuint src2, buf2[NUM_BUFS];

    if(argc < 2)
    {
        fprintf(stderr, "Usage %s <soundfile> [<soundfile>...]\n", argv[0]);
        return 1;
    }

    if(!alureInitDevice(NULL, NULL))
    {
        fprintf(stderr, "Failed to open OpenAL device: %s\n", alureGetErrorString());
        return 1;
    }

    alGenSources(1, &src);
    if( argc > 2 )
        alGenSources(1, &src2);
    if(alGetError() != AL_NO_ERROR)
    {
        fprintf(stderr, "Failed to create OpenAL source!\n");
        alureShutdownDevice();
        return 1;
    }

    //alureStreamSizeIsMicroSec(AL_TRUE);  let's still use byte as length unit. We're not making general music player.

    stream = alureCreateStreamFromFile(argv[1], 4096, NUM_BUFS, buf);
    if( argc > 2 )
        stream2 = alureCreateStreamFromFile(argv[2], 4096, NUM_BUFS, buf2);
    if(!stream)
    {
        fprintf(stderr, "Could not load %s: %s\n", argv[1], alureGetErrorString());
        alDeleteSources(1, &src);

        alureShutdownDevice();
        return 1;
    }
    if( argc > 2 && !stream2 ) {
        fprintf(stderr, "Could not load %s: %s\n", argv[2], alureGetErrorString());
        alDeleteSources(1, &src2);

        alureShutdownDevice();
        return 1;
    }

    alSourcef(src, AL_GAIN, 0.5f);
    if( argc > 2 )
        alSourcef(src2, AL_GAIN, 0.25f);

    if(!alurePlaySourceStream(src, stream, NUM_BUFS, -1, eos_callback, NULL))
    {
        fprintf(stderr, "Failed to play stream %s: %s\n", argv[1], alureGetErrorString());
        isdone = 1;
    }
    if( argc > 2 && !alurePlaySourceStream(src2, stream2, NUM_BUFS, -1, eos_callback, NULL)) {
        fprintf(stderr, "Failed to play stream %s: %s\n", argv[2], alureGetErrorString());
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

    if( argc > 2 ) {
        alureStopSource(src2, AL_FALSE);
        alDeleteSources(1, &src2);
        alureDestroyStream(stream2, NUM_BUFS, buf2);
    }

    alureShutdownDevice();
    return 0;
}
