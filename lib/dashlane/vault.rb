# Copyright (C) 2016 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

module Dashlane
    class Vault
        def self.open_remote username, password, uki
            blob = Fetcher.fetch username, uki
            open blob, username, password
        end

        def self.open_local filename, username, password
            blob = File.read filename
            open blob, username, password
        end

        def self.open blob, username, password
            new blob
        end

        def initialize blob
            json = JSON.load blob
        end
    end
end
