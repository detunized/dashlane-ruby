# Copyright (C) 2016 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

module Dashlane
    class Fetcher
        def self.fetch username, uki
            # TODO: Get a premium account and fetch the actual vault
            File.read "vault.json"
        end
    end
end
