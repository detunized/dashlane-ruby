#!/usr/bin/env ruby

require "base64"
require "json"
require "openssl"

SALT_LENGTH = 32
VERSION_LENGTH = 4
KWC3_VERSION = "KWC3"

def compute_encryption_key password, salt
    OpenSSL::PKCS5.pbkdf2_hmac_sha1 password, salt, 10204, 32
end

def parse_encrypted_blob blob
    salt = blob[0, SALT_LENGTH]
    version = blob[SALT_LENGTH, VERSION_LENGTH]

    if version == KWC3_VERSION
        {
                       salt: salt,
                 ciphertext: blob[SALT_LENGTH + VERSION_LENGTH .. -1],
                 compressed: true,
            use_derived_key: false,
                 iterations: 1,
                    version: version
        }
    else
        {
                       salt: salt,
                 ciphertext: blob[SALT_LENGTH .. -1],
                 compressed: false,
            use_derived_key: true,
                 iterations: 5,
                    version: ""
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

def encrypt_aes256 plaintext, iv, encryption_key
    aes = OpenSSL::Cipher::AES256.new :CBC
    aes.encrypt
    aes.key = encryption_key
    aes.iv = iv
    aes.update(plaintext) + aes.final
end

def reencrypt_blob blob, password, new_password
    parsed = parse_encrypted_blob Base64.decode64 blob

    # TODO: DRY this up
    key = compute_encryption_key password, parsed[:salt]
    key_iv = derive_encryption_key_iv key, parsed[:salt], parsed[:iterations]
    plaintext = decrypt_aes256 parsed[:ciphertext],
                               key_iv[:iv],
                               parsed[:use_derived_key] ? key_iv[:key] : key

    new_key = compute_encryption_key new_password, parsed[:salt]
    new_key_iv = derive_encryption_key_iv new_key, parsed[:salt], parsed[:iterations]
    ciphertext = encrypt_aes256 plaintext,
                                new_key_iv[:iv],
                                parsed[:use_derived_key] ? new_key_iv[:key] : new_key

    salty_ciphertext = if parsed[:version] == KWC3_VERSION
        parsed[:salt] + KWC3_VERSION + ciphertext
    else
        parsed[:salt] + ciphertext
    end

    Base64.strict_encode64 salty_ciphertext
end

def reencrypt_vault filename, password, new_password
    vault = JSON.load File.read filename
    vault["fullBackupFile"] = reencrypt_blob vault["fullBackupFile"], password, new_password
    vault["transactionList"].each do |i|
        if i.key?("content") && !i["content"].empty?
            i["content"] = reencrypt_blob i["content"], password, new_password
        end
    end

    vault
end

def zip text
    Zlib::Deflate.new(Zlib::DEFAULT_COMPRESSION, -Zlib::MAX_WBITS).deflate text, Zlib::FINISH
end

def encrypt_blob text, password, salt
    key = compute_encryption_key password, salt
    key_iv = derive_encryption_key_iv key, salt, 1
    zipped = zip text
    encrypted = encrypt_aes256 "beefed" + zipped, key_iv[:iv], key

    salt + KWC3_VERSION + encrypted
end

def encrypt_blob_base64 text, password, salt
    Base64.strict_encode64 encrypt_blob text, password, salt
end

vault = reencrypt_vault "encrypted.json", File.read(".password").strip, "password"
puts JSON.pretty_generate vault
