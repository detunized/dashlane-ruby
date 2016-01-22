# Copyright (C) 2016 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

module Dashlane
    module Uki
        def self.generate
            # This loosely mirrors the web uki generation process. Not clear if it's needed. Looks
            # like a simple random string does the job. Anyways...
            time = (Time.now.to_f * 1000).to_i.to_s
            text = RUBY_DESCRIPTION + time + ((1 + Random.rand) * 268435456).to_i.to_s(16)
            hashed = Digest::MD5.hexdigest text

            hashed + "-webaccess-" + time
        end
    end
end
