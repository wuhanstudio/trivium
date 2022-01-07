#include "utils.h"

/* Print array from Ath byte to Bth byte */
void print_array_bytes(uint8_t *arr, uint8_t a, uint8_t b)
{
    uint8_t i;
    uint8_t j;
    for(i = a - 1 ; i < b; i++)
    {
        printf("Byte number %d:\t", i + 1);
        for(j = 0; j < 8; j++)
        {
            printf("%d", (arr[i] & (1 << (7 - j))) >> (7 - j));
        }
        printf("\t(bits: %d - %d)\n", (i * 8 + 1), (i * 8 + 8));
    }
}

/* Print array */
void print_array(uint8_t *arr, uint8_t size_of_array)
{
    /*print_array_bytes(arr, 1, size_of_array);*/
    uint8_t i;
    printf("Initial state:\n");
    for(i = 0; i < size_of_array; i++)
    {
        printf("%02X", arr[i]);
        if((i + 1) % 10 == 0)
        {
            printf("\n");
        }
        else
        {
            printf("    ");
        } 
    }
    printf("\n");
}

/* Print array from Ath bit to Bth bit */
void print_array_bits(uint8_t *arr, uint16_t a, uint16_t b)
{
    uint8_t k;
    uint16_t i;
    for(i = a; i <= b; i++)
    {
        k = ((i-1) % 8) + 1;
        printf("%d", ((arr[(i - 1) / 8] & (1 << (8 - k))) >> (8 - k)));
    }
    printf("\t(bits: %d - %d)\n", a, b);
}
