# Copyright (C) 2016 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

require "spec_helper"

describe Dashlane::Uki do
    let(:username) { "username" }
    let(:device_name) { "device" }
    let(:uki) { "uki" }
    let(:token) { "token" }

    let(:ok) { double "response", code: "200", body: "SUCCESS" }

    describe ".generate" do
        it "returns an uki" do
            expect(Dashlane::Uki.generate).to be_a String
        end
    end

    describe ".register_uki_step_1" do
        def step1 http
            Dashlane::Uki.register_uki_step_1 username, http
        end

        def check_raise response, error_type, message = nil
            http = double "http", post_form: response
            expect {
                step1 http
            }.to raise_error error_type, message
        end

        it "make a POST request to a specific URL" do
            http = double "http"
            expect(http).to receive(:post_form)
                .with(uri_of("https://www.dashlane.com/6/authentication/sendtoken"), anything)
                .and_return(ok)

            step1 http
        end

        it "makes a POST request with correct parameters" do
            http = double "http"
            expect(http).to receive(:post_form)
                .with(anything, hash_including(login: username))
                .and_return(ok)

            step1 http
        end

        it "raises an exception on HTTP error" do
            check_raise double("response", code: "404", body: ""), Dashlane::NetworkError
        end

        it "raises an exception on invalid response" do
            check_raise double("response", code: "200", body: "FAILURE"), Dashlane::RegisterError
        end
    end

    describe ".register_uki_step_2" do
        def step2 http
            Dashlane::Uki.register_uki_step_2 username, device_name, uki, token, http
        end

        def check_raise response, error_type, message = nil
            http = double "http", post_form: response
            expect {
                step2 http
            }.to raise_error error_type, message
        end

        it "make a POST request to a specific URL" do
            http = double "http"
            expect(http).to receive(:post_form)
                .with(uri_of("https://www.dashlane.com/6/authentication/registeruki"), anything)
                .and_return(ok)

            step2 http
        end

        it "makes a POST request with correct parameters" do
            http = double "http"
            expect(http).to receive(:post_form)
                .with(anything, hash_including(login: username, devicename: device_name, uki: uki, token: token))
                .and_return(ok)

            step2 http
        end

        it "raises an exception on HTTP error" do
            check_raise double("response", code: "404", body: ""), Dashlane::NetworkError
        end

        it "raises an exception on invalid response" do
            check_raise double("response", code: "200", body: "FAILURE"), Dashlane::RegisterError
        end
    end
end
