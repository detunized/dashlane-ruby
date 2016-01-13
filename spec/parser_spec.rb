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

    describe ".compute_encryption_key" do
        let(:password) { "password" }
        let(:salt) { "salt" }
        let(:encryption_key) { "ImVTD46STEbPkg4szsKMQXtEBfK3l1zYaUjOo681GWs=".decode_base64 }

        it "returns an encryption key" do
            expect(Dashlane::Parser.compute_encryption_key password, salt).to eq encryption_key
        end
    end
end
