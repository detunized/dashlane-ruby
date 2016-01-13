# Copyright (C) 2016 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

module Dashlane
    class Vault
        def self.open_remote username, password, uki
            text = Fetcher.fetch username, uki
            open text, username, password
        end

        def self.open_local filename, username, password
            text = File.read filename
            open text, username, password
        end

        def self.open text, username, password
            new text
        end

        def self.compute_encryption_key password, salt
            OpenSSL::PKCS5.pbkdf2_hmac_sha1 password, salt, 10204, 32
        end

        def initialize text
            data = JSON.load text
        end
    end
end
