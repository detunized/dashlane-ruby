#!/usr/bin/env ruby

# Exploring Dashlane dump here

require "pbkdf2"

def compute_encryption_key password, salt
    pbkdf2 = PBKDF2.new(password: password,
                        salt: salt,
                        iterations: 10204,
                        key_length: 32,
                        hash_function: :sha1)
    pbkdf2.bin_string
end
