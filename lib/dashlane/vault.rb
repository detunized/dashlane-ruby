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

            data["transactionList"].each do |transaction|
                if transaction["type"] == "AUTHENTIFIANT"
                    case transaction["action"]
                    when "BACKUP_EDIT"
                        @accounts += Parser.extract_encrypted_accounts transaction["content"],
                                                                       password
                    when "BACKUP_REMOVE"
                        @accounts.delete_if { |i| i.id == transaction["identifier"] }
                    end
                end
            end
        end
    end
end
