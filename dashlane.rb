#!/usr/bin/env ruby

# Exploring Dashlane dump here

require "base64"
require "pbkdf2"
require "digest"

def compute_encryption_key password, salt
    pbkdf2 = PBKDF2.new(password: password,
                        salt: salt,
                        iterations: 10204,
                        key_length: 32,
                        hash_function: :sha1)
    pbkdf2.bin_string
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

blob = "DX7UC8cXOLq9FcRCDCML6MxqtfxaoEiKALkHLpFQ/D9LV0Mz+VPkxu+eKOl/nYDCLhRVg7MCCAHydvDwh01pWvdEzSIKsn7hUL5Qk2hrW0mfclyzp3SjezXW15mI2CELaSA586vU0upV8zLAP//9JA6qVfmiSU7kzlglXGNSXKou67Fzw5WsB9/HWePSesjlRMfwhOHcy0+C6oXc7p1Fo1hO4V4="
password = "password"

parsed = parse_encrypted_blob Base64.decode64 blob
key = compute_encryption_key password, parsed[:salt]
key_iv = derive_encryption_key_iv key, parsed[:salt], parsed[:iterations]

p key
p key_iv
