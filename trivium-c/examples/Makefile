examples: trivium_encrypt trivium_decrypt

CC = gcc

trivium_encrypt: trivium_encrypt.c ../trivium.c
	$(CC) -o trivium_encrypt -I ../ trivium_encrypt.c ../trivium.c

trivium_decrypt: trivium_decrypt.c ../trivium.c
	$(CC) -o trivium_decrypt -I ../ trivium_decrypt.c ../trivium.c

clean:
	rm -f *.o trivium_encrypt trivium_decrypt
