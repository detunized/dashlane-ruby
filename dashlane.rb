#!/usr/bin/env ruby

# Exploring Dashlane dump here

require "base64"
require "digest"
require "openssl"
require "zlib"

def compute_encryption_key password, salt
    OpenSSL::PKCS5.pbkdf2_hmac_sha1 password, salt, 10204, 32
end

SALT_LENGTH = 32
VERSION_LENGTH = 4

def parse_encrypted_blob blob
    salt = blob[0, SALT_LENGTH]
    version = blob[SALT_LENGTH, VERSION_LENGTH]

    if version == "KWC3"
        {
                       salt: salt,
                 ciphertext: blob[SALT_LENGTH + VERSION_LENGTH .. -1],
                 compressed: true,
            use_derived_key: false,
                 iterations: 1
        }
    else
        {
                       salt: salt,
                 ciphertext: blob[SALT_LENGTH .. -1],
                 compressed: false,
            use_derived_key: true,
                 iterations: 5
        }
    end
end

def sha1 bytes, times
    times.times do
        bytes = Digest::SHA1.digest bytes
    end

    bytes
end

def derive_encryption_key_iv encryption_key, salt, iterations
    salty_key = encryption_key + salt[0, 8]

    parts = [""]
    3.times do
        parts << sha1(parts.last + salty_key, iterations)
    end

    key_iv = parts.join

    {
        key: key_iv[0, 32],
        iv: key_iv[32, 16]
    }
end

def decrypt_aes256 ciphertext, iv, encryption_key
    aes = OpenSSL::Cipher::AES256.new :CBC
    aes.decrypt
    aes.key = encryption_key
    aes.iv = iv
    aes.update(ciphertext) + aes.final
end

def inflate compressed
    z = Zlib::Inflate.new(-Zlib::MAX_WBITS)
    uncompressed = z.inflate compressed
    z.finish
    z.close

    uncompressed
end

def decrypt_blob blob, password
    parsed = parse_encrypted_blob Base64.decode64 blob
    key = compute_encryption_key password, parsed[:salt]
    key_iv = derive_encryption_key_iv key, parsed[:salt], parsed[:iterations]
    plaintext = decrypt_aes256 parsed[:ciphertext],
                               key_iv[:iv],
                               parsed[:use_derived_key] ? key_iv[:key] : key

    if parsed[:compressed]
        inflate plaintext[6 .. -1]
    else
        plaintext
    end
end

blob = "DX7UC8cXOLq9FcRCDCML6MxqtfxaoEiKALkHLpFQ/D9LV0Mz+VPkxu+eKOl/nYDCLhRVg7MCCAHydvDwh01pWvdEzSIKsn7hUL5Qk2hrW0mfclyzp3SjezXW15mI2CELaSA586vU0upV8zLAP//9JA6qVfmiSU7kzlglXGNSXKou67Fzw5WsB9/HWePSesjlRMfwhOHcy0+C6oXc7p1Fo1hO4V4="
password = "Password1337"

p decrypt_blob blob, password
