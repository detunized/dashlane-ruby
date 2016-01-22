# Copyright (C) 2016 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

module Dashlane
    # Base class for all errors, should not be raised
    class Error < StandardError; end

    #
    # Generic errors
    #

    # Something went wrong with the network
    class NetworkError < Error; end
end
