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

        it "returns a vault" do
            http = double "http", post_form: ok
            expect(Dashlane::Fetcher.fetch username, uki, http).to eq vault
        end

        it "makes a POST request to a specific URL" do
            http = double "http"
            expect(http).to receive(:post_form)
                .with(uri_of("https://www.dashlane.com/12/backup/latest"), anything)
                .and_return(ok)
            Dashlane::Fetcher.fetch username, uki, http
        end

        it "makes a POST request with correct parameters" do
            http = double "http"
            expect(http).to receive(:post_form)
                .with(anything, hash_including(login: username, uki: uki))
                .and_return(ok)
            Dashlane::Fetcher.fetch username, uki, http
        end

        it "raises an exception on HTTP error" do
            http = double "http", post_form: error
            expect {
                Dashlane::Fetcher.fetch username, uki, http
            }.to raise_error Dashlane::NetworkError
        end

        it "raises an exception on invalid JSON" do
            http = double "http", post_form: http_ok("} invalid JSON {")
            expect {
                Dashlane::Fetcher.fetch username, uki, http
            }.to raise_error Dashlane::InvalidResponseError, "Invalid JSON object"
        end
    end

    private

    def http_ok body
        double "response", code: "200", body: body
    end
end
