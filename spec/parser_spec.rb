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
        let(:salt) { "salt" * 8 }
        let(:encryption_key) { "OAIU9FREAugcAkNtoeoUithzi2qXJQc6Gfj5WgPD0mY=".decode_base64 }

        it "returns an encryption key" do
            expect(Dashlane::Parser.compute_encryption_key password, salt).to eq encryption_key
        end
    end

    describe ".sha1" do
        let(:bytes) { "All your base are belong to us" }

        def check times, expected
            expect(Dashlane::Parser.sha1 bytes, times).to eq expected
        end

        it "returns SHA1 checksum" do
            check 1, "xgmXgTCENlJpbnSLucn3NwPXkIk=".decode_base64
            check 5, "RqcjtwJ5KY1MON7n3WwvqGhrrpg=".decode_base64
        end
    end

    describe ".derive_encryption_key_iv" do
        let(:encryption_key) { "OAIU9FREAugcAkNtoeoUithzi2qXJQc6Gfj5WgPD0mY=".decode_base64 }
        let(:salt) { "salt" * 8 }

        def check iterations, expected
            expect(Dashlane::Parser.derive_encryption_key_iv encryption_key, salt, 1).to eq expected
        end

        it "returns an encryption key and IVs" do
            check 1, {
                key: "6HA2Rq9GTeKzAc1imNjvyaXBGW4zRA5wIr60Vbx/o8w=".decode_base64,
                 iv: "fCk2EkpIYGn05JHcVfR8eQ==".decode_base64
            }

            check 5, {
                key: "6HA2Rq9GTeKzAc1imNjvyaXBGW4zRA5wIr60Vbx/o8w=".decode_base64,
                iv: "fCk2EkpIYGn05JHcVfR8eQ==".decode_base64
            }
        end
    end

    describe ".decrypt_aes256" do
        let(:ciphertext) { "TZ1+if9ofqRKTatyUaOnfudletslMJ/RZyUwJuR/+aI=".decode_base64 }
        let(:iv) { "YFuiAVZgOD2K+s6y8yaMOw==".decode_base64 }
        let(:encryption_key) { "OfOUvVnQzB4v49sNh4+PdwIFb9Fr5+jVfWRTf+E2Ghg=".decode_base64 }
        let(:plaintext) { "All your base are belong to us" }

        it "returns decrypted plaintext" do
            expect(Dashlane::Parser.decrypt_aes256 ciphertext, iv, encryption_key).to eq plaintext
        end
    end

    describe ".inflate" do
        let(:compressed) { "c8zJUajMLy1SSEosTlVILEpVSErNyc9LVyjJVygtBgA=".decode_base64 }
        let(:content) { "All your base are belong to us" }

        it "returns inflated content" do
            expect(Dashlane::Parser.inflate compressed).to eq content
        end
    end

    describe ".decrypt_blob" do
        let(:password) { "password"}
        let(:blob) { "T+/5FeWHo/AGe9kLULw+PGzQQseYT0IQkF84LtDQTmZLV0MzBMOknkr2SdlP2f" +
                     "3VmlsVAt+9A8hlwXY014OeflgUejN4qwL7i/04AZZrDKGfRWmfn6EwhyBrt0Bg" +
                     "BOQgKiNNB3V7gZWMOaec5I5tlOrgDny3Xcs4jTJrrN+WF9KV7VyaQ1Bbuu7Tfi" +
                     "E/pwJz8EZ4xWbV8YTc/QLgXpEIC8I2xeM=" }
        let(:content) { %Q{<?xml version="1.0" encoding="UTF-8"?><root><KWSecurityAlertsManager>} +
                        %Q{<KWDataList key="PwndList"/><KWDataList key="SecurityAlerts"/>} +
                        %Q{</KWSecurityAlertsManager></root>\n} }

        it "returns decrypted content" do
            expect(Dashlane::Parser.decrypt_blob blob, password).to eq content
        end
    end

    describe ".extract_accounts_from_xml" do
        let(:accounts_xml) { %q{
            <KWAuthentifiant>
                <KWDataItem key="Title"><![CDATA[dude]]></KWDataItem>
                <KWDataItem key="Login"><![CDATA[jeffrey.lebowski]]></KWDataItem>
                <KWDataItem key="Password"><![CDATA[logjammin]]></KWDataItem>
                <KWDataItem key="Url"><![CDATA[https://dude.com]]></KWDataItem>
                <KWDataItem key="Note"><![CDATA[Get a new rug!]]></KWDataItem>
            </KWAuthentifiant>
            <KWAuthentifiant>
                <KWDataItem key="Title"><![CDATA[walter]]></KWDataItem>
                <KWDataItem key="Login"><![CDATA[walter.sobchak]]></KWDataItem>
                <KWDataItem key="Password"><![CDATA[worldofpain]]></KWDataItem>
                <KWDataItem key="Url"><![CDATA[https://nam.com]]></KWDataItem>
                <KWDataItem key="Note"><![CDATA[Don't roll on Shabbos!]]></KWDataItem>
            </KWAuthentifiant>
        } }

        let(:accounts) { [
            {
                    name: "dude",
                username: "jeffrey.lebowski",
                password: "logjammin",
                     url: "https://dude.com"
            },
            {
                    name: "walter",
                username: "walter.sobchak",
                password: "worldofpain",
                     url: "https://nam.com"
            },
        ] }

        def check xml, expected
            expect(Dashlane::Parser.extract_accounts_from_xml xml).to eq expected
        end

        it "returns an empty array when no accounts present" do
            check "<root />", []
        end

        it "returns accounts at level 1" do
            check "<root>#{accounts_xml}</root>", accounts
        end

        it "returns accounts at level 2" do
            check "<root><subroot>#{accounts_xml}</subroot></root>", accounts
        end
    end
end
