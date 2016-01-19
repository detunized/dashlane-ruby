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
                @accounts += Parser.extract_encrypted_accounts data["fullBackupFile"], password
            end

            # TODO: Remove transactions are simply ignored. This is at the moment a feature. Though
            #       it's really a bug. This makes it possible to see deleted accounts in some cases.
            #       This could be a problem though with editing of existing accounts. Need to test
            #       more. This only happens when we have accounts in the fullBackupFile and
            #       transactions to remove them.

            @accounts += data["transactionList"]
                .select { |i| i["type"] == "AUTHENTIFIANT" && i["action"] == "BACKUP_EDIT" }
                .flat_map { |i| Parser.extract_encrypted_accounts i["content"], password }
        end
    end
end
