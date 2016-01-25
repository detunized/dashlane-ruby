# Copyright (C) 2016 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

# Run via top level rake file:
# $ rake example

require "dashlane"
require "yaml"

credentials = YAML.load_file File.join File.dirname(__FILE__), "credentials.yaml"

username = credentials["username"]
password = credentials["password"]

begin
    # TODO: Show UKI registration here as well

    uki = Dashlane::Uki.import username.reverse, password
    vault = Dashlane::Vault.open_remote username, password, uki

    vault.accounts.each_with_index do |i, index|
        puts "#{index + 1}: #{i.name} #{i.username} #{i.password} #{i.url} #{i.note}"
    end
rescue => e
    puts "Account #{username} doesn't seem to exist, incorrent password or " +
         "the platform is not currenlty supported '#{e}'"
end
