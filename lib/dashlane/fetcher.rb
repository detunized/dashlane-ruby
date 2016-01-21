# Copyright (C) 2016 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

module Dashlane
    class Fetcher
        def self.fetch username, uki, http = Net::HTTP
            uri = URI "https://www.dashlane.com/12/backup/latest"
            response = http.post_form uri, {
                login: username,
                lock: "nolock",
                timestamp: 1,
                sharingTimestamp: 0,
                uki: uki
            }

            # TODO: Use custom exception!
            raise "Fetch failed" if response.code != "200"

            response.body
        end
    end
end
