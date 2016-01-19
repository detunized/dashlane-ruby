# Copyright (C) 2016 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

module Dashlane
    class Vault
        attr_reader :accounts

        def self.open_remote username, password, uki
            text = Fetcher.fetch username, uki
            new text, password
        end

        def self.open_local filename, username, password
            text = File.read filename
            new text, password
        end

        def initialize text, password
            data = JSON.load text

            @accounts = []
            if data.key?("fullBackupFile") && !data["fullBackupFile"].empty?
                @accounts += Parser.extract_accounts_from_xml Parser.decrypt_blob data["fullBackupFile"], password
            end

            @accounts += data["transactionList"]
                .select { |i| i["type"] == "AUTHENTIFIANT" && i["action"] == "BACKUP_EDIT" }
                .flat_map { |i| Parser.extract_accounts_from_xml Parser.decrypt_blob i["content"], password }
        end
    end
end
