# Copyright (C) 2016 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

require "spec_helper"

describe Dashlane::Fetcher do
    let(:username) { "username" }
    let(:uki) { "uki" }
    let(:blob) { "{}" }
    let(:vault) { {} }

    describe ".fetch" do
        let(:ok) { http_ok blob }
        let(:error) { double "response", code: "404", body: "" }

        def fetch http
            Dashlane::Fetcher.fetch username, uki, http
        end

        def check_raise response, error_type, message = nil
            http = double "http", post_form: response
            expect {
                fetch http
            }.to raise_error error_type, message
        end

        def check_raise_with_body body, error_type, message = nil
            check_raise http_ok(body), error_type, message
        end

        it "returns a vault" do
            http = double "http", post_form: ok
            expect(fetch http).to eq vault
        end

        it "makes a POST request to a specific URL" do
            http = double "http"
            expect(http).to receive(:post_form)
                .with(uri_of("https://www.dashlane.com/12/backup/latest"), anything)
                .and_return(ok)
            fetch http
        end

        it "makes a POST request with correct parameters" do
            http = double "http"
            expect(http).to receive(:post_form)
                .with(anything, hash_including(login: username, uki: uki))
                .and_return(ok)
            fetch http
        end

        it "raises an exception on HTTP error" do
            check_raise error, Dashlane::NetworkError
        end

        it "raises an exception on invalid JSON" do
            check_raise_with_body "} invalid JSON {",
                                  Dashlane::InvalidResponseError,
                                  "Invalid JSON object"
        end

        it "raises an exception on an unknown error with a message" do
            message = "Dashlane is upset"
            check_raise_with_body %Q[{"error": {"message": "#{message}"}}],
                                  Dashlane::UnknownError,
                                  message
        end

        it "raises an exception on an unknown error without a message" do
            check_raise_with_body '{"error": {}}',
                                  Dashlane::UnknownError,
                                  "Unknown error"
        end

        it "raises an exception on a message" do
            message = "Dashlane is upset"
            check_raise_with_body %Q[{"objectType": "message", "content": "#{message}"}],
                                  Dashlane::UnknownError,
                                  message
        end
    end

    private

    def http_ok body
        double "response", code: "200", body: body
    end
end
