# Copyright (C) 2015 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

# Only calculate test coverage on TravisCI
if ENV["CI"] == "true" && ENV["TRAVIS"] == "true"
    require "coveralls"
    Coveralls.wear!
end

require "dashlane"
require "rspec/its"
