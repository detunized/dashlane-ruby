# Copyright (C) 2016 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

require "spec_helper"

describe Dashlane::Uki do
    describe ".generate" do
        it "returns an uki" do
            expect(Dashlane::Uki.generate).to be_a String
        end
    end
end
