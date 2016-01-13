# Copyright (C) 2016 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

# Only calculate test coverage on TravisCI
if ENV["CI"] == "true" && ENV["TRAVIS"] == "true"
    require "coveralls"
    Coveralls.wear!
end

require "base64"
require "rspec/its"

require "dashlane"

class String
    def decode_base64
        Base64.decode64 self
    end

    def decode_hex
        scan(/../).map { |i| i.to_i 16 }.pack "c*"
    end
end
