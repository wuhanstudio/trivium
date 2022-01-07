import time

from trivium import Trivium
from trivium import hex_to_bits, bits_to_hex

def main():
    # Key IV are little endian bits
    KEY = hex_to_bits("0F62B5085BAE0154A7FA")[::-1]
    IV = hex_to_bits("288FF65DC42B92F960C7")[::-1]

    # Encoding a string
    trivium_encoder = Trivium(KEY, IV)
    cipher = trivium_encoder.encrypt("hello")

    # Cipher texts are little endian bits
    print("Encoded:", bits_to_hex(cipher)[::-1])

    # Decoding from the cipher
    trivium_decoder = Trivium(KEY, IV)
    plain = trivium_decoder.decrypt(cipher)

    # Plain Text
    print("Decoded:", plain)


if __name__ == "__main__":
    main()
