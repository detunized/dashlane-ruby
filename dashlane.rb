#!/usr/bin/env ruby

# Exploring Dashlane dump here

require "base64"
require "pbkdf2"

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
        }
    else
        {
                       salt: salt,
                 ciphertext: blob[SALT_LENGTH .. -1],
                 compressed: false,
            use_derived_key: true,
        }
    end
end

p parse_encrypted_blob Base64.decode64 "DX7UC8cXOLq9FcRCDCML6MxqtfxaoEiKALkHLpFQ/D9LV0Mz+VPkxu+eKOl/nYDCLhRVg7MCCAHydvDwh01pWvdEzSIKsn7hUL5Qk2hrW0mfclyzp3SjezXW15mI2CELaSA586vU0upV8zLAP//9JA6qVfmiSU7kzlglXGNSXKou67Fzw5WsB9/HWePSesjlRMfwhOHcy0+C6oXc7p1Fo1hO4V4="
