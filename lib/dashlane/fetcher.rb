# Copyright (C) 2016 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

module Dashlane
    class Fetcher
        LATEST_URI = URI "https://www.dashlane.com/12/backup/latest"

        def self.fetch username, uki, http = Net::HTTP
            response = http.post_form LATEST_URI, {
                login: username,
                lock: "nolock",
                timestamp: 1,
                sharingTimestamp: 0,
                uki: uki
            }

            raise NetworkError if response.code != "200"

            response.body
        end
    end
end
