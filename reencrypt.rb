#!/usr/bin/env ruby

require_relative "dashlane"

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
        i["content"] = reencrypt_blob i["content"], password, new_password
    end

    vault
end

vault = reencrypt_vault "encrypted.json", File.read(".password").strip, "Password1337"
puts JSON.pretty_generate vault
