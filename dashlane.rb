#!/usr/bin/env ruby

# Exploring Dashlane dump here

require "base64"
require "digest"
require "openssl"
require "zlib"
require "json"
require "rexml/document"

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

def dump_vault filename, password
    vault = JSON.load File.read filename
    puts decrypt_blob vault["fullBackupFile"], password
    vault["transactionList"].each do |i|
        puts decrypt_blob i["content"], password
    end
end

def parse_xml xml
    REXML::Document.new(xml).elements.to_a("/root/KWDataList/KWAuthentifiant").map { |i|
        {
                name: i.text("KWDataItem[@key='Title']"),
            username: i.text("KWDataItem[@key='Login']"),
            password: i.text("KWDataItem[@key='Password']"),
                 url: i.text("KWDataItem[@key='Url']")
        }
    }
end

def load_vault filename, password
    vault = JSON.load File.read filename

    xml = {
        base: decrypt_blob(vault["fullBackupFile"], password),
        transactions: vault["transactionList"].map { |i| decrypt_blob i["content"], password }
    }

    parse_xml xml[:base]

    # TODO: Apply transactions here
end

if __FILE__ == $0
    p load_vault "vault.json", "Password1337"
end
