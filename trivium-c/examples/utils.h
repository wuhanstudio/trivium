#ifndef __UTILS_H__
#define __UTILS_H__

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

/* Print array from Ath byte to Bth byte */
void print_array_bytes(uint8_t *arr, uint8_t a, uint8_t b);

/* Print array */
void print_array(uint8_t *arr, uint8_t size_of_array);

/* Print array from Ath bit to Bth bit */
void print_array_bits(uint8_t *arr, uint16_t a, uint16_t b);

uint8_t get_random_byte();

uint8_t hexchar_to_int(char ch);

uint8_t get_byte_from_console_input();

#endif // __UTILS_H__