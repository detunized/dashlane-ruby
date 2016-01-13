# Copyright (C) 2016 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

require "spec_helper"

describe Dashlane::Vault do
    let(:username) { "username" }
    let(:password) { "password" }
    let(:uki) { "uki" }
    let(:filename) { "vault.json" }

    describe ".open_remote" do
        it "returns a vault" do
            expect(Dashlane::Vault.open_remote username, password, uki).to be_a Dashlane::Vault
        end
    end

    describe ".open_local" do
        it "returns a vault" do
            expect(Dashlane::Vault.open_local filename, username, password).to be_a Dashlane::Vault
        end
    end
end
