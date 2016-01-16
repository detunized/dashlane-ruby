# Copyright (C) 2016 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

module Dashlane
    class Vault
        def self.open_remote username, password, uki
            text = Fetcher.fetch username, uki
            open text, password
        end

        def self.open_local filename, username, password
            text = File.read filename
            open text, password
        end

        def self.open text, password
            new text, password
        end

        def initialize text, password
            data = JSON.load text
        end
    end
end
