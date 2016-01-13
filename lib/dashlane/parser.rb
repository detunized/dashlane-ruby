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
    end
end
