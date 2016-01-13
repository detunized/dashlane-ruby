# Copyright (C) 2016 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

require "spec_helper"

describe Dashlane::Account do
    let(:name) { "name" }
    let(:username) { "username" }
    let(:password) { "password" }
    let(:url) { "url" }
    let(:note) { "note" }

    subject { Dashlane::Account.new name, username, password, url, note }

    its(:name) { should eq name }
    its(:username) { should eq username }
    its(:password) { should eq password }
    its(:url) { should eq url }
    its(:note) { should eq note }
end
