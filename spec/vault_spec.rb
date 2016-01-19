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

    let(:dude) { Dashlane::Account.new "dude.com",
                                       "jeffrey.lebowski",
                                       "logjammin",
                                       "https://dude.com",
                                       "Get a new rug!" }

    let(:nam) { Dashlane::Account.new "nam.com",
                                      "walter.sobchak",
                                      "worldofpain",
                                      "https://nam.com",
                                      "Don't roll on Shabbos!" }

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

    describe "vault configurations" do
        def accounts filename
            Dashlane::Vault.open_local("spec/fixtures/#{filename}.json", username, password).accounts
        end

        context "empty vault" do
            it { expect(accounts "empty-vault").to be_empty }
        end

        context "a vault with empty fullfile and one add transation" do
            it { expect(accounts "empty-fullfile-one-add-transaction").to eq [dude] }
        end

        context "a vault with empty fullfile and two add transations" do
            it { expect(accounts "empty-fullfile-two-add-transactions").to eq [dude, nam] }
        end

        context "a vault with empty fullfile and two add and one remove transations" do
            it { expect(accounts "empty-fullfile-two-add-one-remove-transactions").to eq [dude, nam] }
        end

        context "a vault with two accounts in fullfile" do
            it { expect(accounts "two-accounts-in-fullfile").to eq [dude, nam] }
        end
    end
end
