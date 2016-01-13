# Copyright (C) 2016 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

require "spec_helper"

describe Dashlane::Vault do
    let(:username) { "username" }
    let(:password) { "password" }
    let(:uki) { "uki" }
    let(:filename) { "vault.json" }
    let(:salt) { "salt" }
    let(:encryption_key) { "ImVTD46STEbPkg4szsKMQXtEBfK3l1zYaUjOo681GWs=".decode_base64 }

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

    describe ".compute_encryption_key" do
        it "returns an encryption key" do
            expect(Dashlane::Vault.compute_encryption_key password, salt).to eq encryption_key
        end
    end
end
