#ifndef __TRIVIUM_H__
#define __TRIVIUM_H__

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define TRIVIUM_STATE_SIZE 36

typedef struct _trivium_ctx
{
    uint8_t* key;
    uint8_t* iv;
    uint8_t b[TRIVIUM_STATE_SIZE];
} trivium_ctx;

trivium_ctx* trivium_init(uint8_t *key, uint8_t *iv);

uint8_t trivium_gen_keystream(trivium_ctx* ctx);

#endif // __TRIVIUM_H__
