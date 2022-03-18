#include "trivium.h"

static uint8_t trivium_nbit(uint8_t *arr, uint16_t n)
{
    uint8_t nbyte = (n - 1) / 8;
    uint8_t trivium_nbit = ((n - 1) % 8) + 1;
    return (arr[nbyte] & (1 << (8 - trivium_nbit))) >> (8 - trivium_nbit);
}

static void trivium_change_bit(uint8_t *arr, uint16_t n, uint8_t value)
{
    uint8_t nbyte = (n - 1) / 8;
    uint8_t trivium_nbit = ((n - 1) % 8) + 1;

    arr[nbyte] = ((255 << (9 - trivium_nbit)) & arr[nbyte]) |
                (value << (8 - trivium_nbit)) |
                ((255 >> trivium_nbit) & arr[nbyte]);
}

static void trivium_insert_bits(uint8_t *arr, uint16_t n, uint8_t *source, uint16_t ssize)
{
    uint16_t i;
    for(i = 0; i < ssize; i++)
    {
        trivium_change_bit(arr, n + i, trivium_nbit(source, i + 1));
    }
}

static uint8_t trivium_rotate(uint8_t *arr, uint8_t arr_size)
{
    uint8_t i;

    uint8_t t1 = trivium_nbit(arr, 66) ^ trivium_nbit(arr, 93);
    uint8_t t2 = trivium_nbit(arr, 162) ^ trivium_nbit(arr, 177);
    uint8_t t3 = trivium_nbit(arr, 243) ^ trivium_nbit(arr, 288);

    uint8_t out = t1 ^ t2 ^ t3;

    uint8_t a1 = trivium_nbit(arr, 91) & trivium_nbit(arr, 92);
    uint8_t a2 = trivium_nbit(arr, 175) & trivium_nbit(arr, 176);
    uint8_t a3 = trivium_nbit(arr, 286) & trivium_nbit(arr, 287);

    uint8_t s1 = a1 ^ trivium_nbit(arr, 171) ^ t1;
    uint8_t s2 = a2 ^ trivium_nbit(arr, 264) ^ t2;
    uint8_t s3 = a3 ^ trivium_nbit(arr, 69) ^ t3;

    /* Begin trivium_rotate */

    for(i = arr_size - 1; i > 0; i--)
    {
        arr[i] = (arr[i - 1] << 7) | (arr[i] >> 1);
    }
    arr[0] = arr[0] >> 1;

    /* End trivium_rotate */

    trivium_change_bit(arr, 1, s3);
    trivium_change_bit(arr, 94, s1);
    trivium_change_bit(arr, 178, s2);

    return out;
}

static void trivium_init_state(uint8_t *arr)
{
    uint16_t i;
    for(i = 0; i < 4*288; i++)
    {
        trivium_rotate(arr, TRIVIUM_STATE_SIZE);
    }
}

trivium_ctx* trivium_init(uint8_t *key, uint8_t *iv)
{
    trivium_ctx *ctx = malloc(sizeof(struct _trivium_ctx));

    if (ctx == NULL)
    {
        printf("Error: malloc trivium_ctx failed.\n");
        return NULL;
    }

    for(int i = 0; i < TRIVIUM_STATE_SIZE; i++) ctx->b[i] = 0;

    ctx->key = key;
    ctx->iv = iv;

    trivium_insert_bits(ctx->b, 1, key, 80);
    trivium_insert_bits(ctx->b, 94, iv, 80);
    trivium_change_bit(ctx->b, 286, 1);
    trivium_change_bit(ctx->b, 287, 1);
    trivium_change_bit(ctx->b, 288, 1);

    trivium_init_state(ctx->b);

    return ctx;
}

uint8_t trivium_gen_keystream(trivium_ctx* ctx)
{
    uint8_t buf = 0;
    uint8_t i = 0;
    while(i != 8)
    {
        uint8_t z = trivium_rotate(ctx->b, TRIVIUM_STATE_SIZE);
        buf = buf | (z << i);
        i += 1;
    }
    return buf;
}
