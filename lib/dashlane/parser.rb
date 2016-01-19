# Copyright (C) 2016 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

module Dashlane
    class Parser
        SALT_LENGTH = 32
        VERSION_LENGTH = 4
        KWC3_VERSION = "KWC3"

        def self.parse_encrypted_blob blob
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

        def self.compute_encryption_key password, salt
            OpenSSL::PKCS5.pbkdf2_hmac_sha1 password, salt, 10204, 32
        end

        def self.sha1 bytes, times
            times.times do
                bytes = Digest::SHA1.digest bytes
            end

            bytes
        end

        def self.derive_encryption_key_iv encryption_key, salt, iterations
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

        def self.decrypt_aes256 ciphertext, iv, encryption_key
            aes = OpenSSL::Cipher::AES256.new :CBC
            aes.decrypt
            aes.key = encryption_key
            aes.iv = iv
            aes.update(ciphertext) + aes.final
        end

        def self.inflate compressed
            z = Zlib::Inflate.new(-Zlib::MAX_WBITS)
            uncompressed = z.inflate compressed
            z.finish
            z.close

            uncompressed
        end

        def self.decrypt_blob blob, password
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

        def self.extract_accounts_from_xml xml
            REXML::Document.new(xml).elements.to_a("//KWAuthentifiant").map { |i|
                Account.new i.text("KWDataItem[@key='Id']"),
                            i.text("KWDataItem[@key='Title']"),
                            i.text("KWDataItem[@key='Login']"),
                            i.text("KWDataItem[@key='Password']"),
                            i.text("KWDataItem[@key='Url']"),
                            i.text("KWDataItem[@key='Note']")
            }
        end

        def self.extract_encrypted_accounts blob, password
            extract_accounts_from_xml decrypt_blob blob, password
        end
    end
end
