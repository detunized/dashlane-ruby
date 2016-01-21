# Copyright (C) 2016 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

require "spec_helper"

describe Dashlane::Fetcher do
    let(:username) { "username" }
    let(:uki) { "uki" }

    describe ".fetch" do
        it "returns a vault" do
            response = double "response", code: "200", body: ""
            http = double "http", post_form: response
            expect(Dashlane::Fetcher.fetch username, uki, http).to be_a String
        end
    end
end
