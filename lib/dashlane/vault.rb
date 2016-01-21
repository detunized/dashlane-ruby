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

            accounts = {}
            if data.key?("fullBackupFile") && !data["fullBackupFile"].empty?
                Parser.extract_encrypted_accounts(data["fullBackupFile"], password).each do |i|
                    accounts[i.id] = i
                end
            end

            data["transactionList"].each do |transaction|
                if transaction["type"] == "AUTHENTIFIANT"
                    case transaction["action"]
                    when "BACKUP_EDIT"
                        Parser.extract_encrypted_accounts(transaction["content"], password).each do |i|
                            accounts[i.id] = i
                        end
                    when "BACKUP_REMOVE"
                        accounts.delete transaction["identifier"]
                    end
                end
            end

            # Order by id to introduce some determinism. No other hidden meaning here.
            @accounts = accounts.values.sort_by { |i| i.id }
        end
    end
end
