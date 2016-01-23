# Copyright (C) 2016 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

module Dashlane
    module Uki
        TOKEN_URI = URI "https://www.dashlane.com/6/authentication/sendtoken"
        REGISTER_URI = URI "https://www.dashlane.com/6/authentication/registeruki"

        def self.generate
            # This loosely mirrors the web uki generation process. Not clear if it's needed. Looks
            # like a simple random string does the job. Anyways...
            time = (Time.now.to_f * 1000).to_i.to_s
            text = RUBY_DESCRIPTION + time + ((1 + Random.rand) * 268435456).to_i.to_s(16)
            hashed = Digest::MD5.hexdigest text

            hashed + "-webaccess-" + time
        end

        # This initiates a request. Dashlane should send an email with a token. Plug it into step 2.
        def self.register_uki_step_1 username, http = Net::HTTP
            response = http.post_form TOKEN_URI, {
                login: username,
                isOTPAware: true
            }

            raise NetworkError if response.code != "200"
            raise RegisterError if response.body != "SUCCESS"
        end

        # Token should be reveived via email. See step 1.
        def self.register_uki_step_2 username, device_name, uki, token, http = Net::HTTP
            response = http.post_form REGISTER_URI, {
                devicename: device_name,
                login: username,
                platform: "webaccess",
                temporary: 0,
                token: token,
                uki: uki
            }

            raise NetworkError if response.code != "200"
            raise RegisterError if response.body != "SUCCESS"
        end
    end
end
