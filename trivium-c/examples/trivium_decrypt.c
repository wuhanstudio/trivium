#include <stdio.h>

#include "utils.h"
#include <trivium.h>

uint8_t hexchar_to_int(char ch)
{
    if (ch >= '0' && ch <= '9')
        return ch - '0';
    if (ch >= 'A' && ch <= 'F')
        return ch - 'A' + 10;
    if (ch >= 'a' && ch <= 'f')
        return ch - 'a' + 10;

    return -1;
}

uint8_t get_byte_from_console_input()
{
    uint8_t rb;
    uint8_t hc1, hc2;
    scanf("%c%c", &hc1, &hc2);
    rb = (hexchar_to_int(hc1) << 4) | (hexchar_to_int(hc2) );
    return rb;
}

int main(int argc, char **argv)
{
    uint8_t key[10], iv[10];

    uint8_t buffer, encbuffer;

    FILE *pFile, *outFile;

    uint8_t i;

    if (argc != 3)
    {
        printf("Usage: %s cipher.file output.file\n", argv[0]);
        return 0;
    }

    // Initialize the key
    printf("Type key in hexadecimal format (80 bit):\n");
    for (i = 0; i < 10; i++)
    {
        key[i] = get_byte_from_console_input();
    }

    // Initialize the IV
    pFile = fopen(argv[1] , "rb");
    outFile = fopen(argv[2], "wb");
    if (pFile==NULL) {fputs ("Input file error",stderr); exit (1);}
    if (outFile==NULL) {fputs ("Output file error",stderr); exit (1);}

    for(i = 0; i < 10; i++)
    {
        fread(&buffer, 1, 1, pFile);
        iv[i] = buffer;
    }

    // Initialize the trivium cipher
    trivium_ctx* ctx = trivium_init(key, iv);

    // Decrypt the file
    while(fread(&buffer, 1, 1, pFile) != 0)
    {
        encbuffer = buffer ^ trivium_gen_keystream(ctx);
        fwrite(&encbuffer, 1, 1, outFile);
    }

    fclose(pFile);
    fclose(outFile);

    return 0;
}
