# Copyright (C) 2016 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

require "spec_helper"

describe Dashlane::Parser do
    describe ".parse_encrypted_blob" do
        let(:salt) { "salt" * 8 }
        let(:content) { "All your base are belong to us" }

        it "parses KWC3 blob" do
            version = "KWC3"
            expected = {
                           salt: salt,
                     ciphertext: content,
                     compressed: true,
                use_derived_key: false,
                     iterations: 1,
                        version: version

            }

            expect(Dashlane::Parser.parse_encrypted_blob salt + version + content)
                .to eq expected
        end

        it "parses legacy blob" do
            version = "KWC3"
            expected = {
                           salt: salt,
                     ciphertext: content,
                     compressed: false,
                use_derived_key: true,
                     iterations: 5,
                        version: ""

            }

            expect(Dashlane::Parser.parse_encrypted_blob salt + content)
                .to eq expected
        end
    end
end
