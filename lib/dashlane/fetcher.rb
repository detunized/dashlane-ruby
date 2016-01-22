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

            parse_and_check_for_errors response.body
        end

        private

        def self.parse_and_check_for_errors json
            parsed = JSON.load json rescue raise InvalidResponseError.new "Invalid JSON object"

            if parsed.key? "error"
                raise UnknownError.new parsed["error"].fetch "message", "Unknown error"
            end

            if parsed["objectType"] == "message"
                raise UnknownError.new parsed["content"]
            end

            # TODO: Do some integrity check to see if it's the actual vault we've got here!

            parsed
        end
    end
end
