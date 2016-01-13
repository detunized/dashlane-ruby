# Copyright (C) 2016 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

module Dashlane
    class Account
        attr_reader :name,
                    :username,
                    :password,
                    :url,
                    :note

        def initialize name, username, password, url, note
            @name = name
            @username = username
            @password = password
            @url = url
            @note = note
        end
    end
end
