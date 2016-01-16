# Copyright (C) 2016 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

require "spec_helper"

describe Dashlane::Vault do
    let(:username) { "username" }
    let(:password) { "password" }
    let(:uki) { "uki" }
    let(:filename) { "vault.json" }
    let(:blob) { File.read filename }
    let(:vault) { Dashlane::Vault.new blob, password }

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

    describe ".new" do
        it "returns a vault" do
            expect(Dashlane::Vault.new blob, password).to be_a Dashlane::Vault
        end
    end

    describe "#accounts" do
        context "returned accounts" do
            it { expect(vault.accounts).to be_instance_of Array }
            it { expect(vault.accounts).not_to be_empty }
            it { expect(vault.accounts).to all(be_an Dashlane::Account) }
        end
    end
end
