# Copyright (C) 2016 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

# Run via top level rake file:
# $ rake example

require "dashlane"
require "yaml"

# In order to log in we need a device identifier (UKI) that is registered with Dashlane.
# If there's a local client installed on this machine we can import the UKI and use it
# to log in silently and fetch the vault. In case there's no local DB available we need
# to register a new UKI with the server. This process is interactive as it requires
# a security token that is sent to the user by email.

# Look for a local Dashlane installation and import the device id to access the vault
def import_local_uki username, password
    uki = Dashlane::Uki.import username, password
    puts "Found an UKI in the local database (UKI: #{uki})"

    uki
rescue => e
    puts "Failed to import the UKI from the local database: '#{e}'"
end

# Generate a new device id and register it with Dashlane
def register_uki username
    puts "Requesting a security token for the new UKI registration"
    Dashlane::Uki.register_uki_step_1 username

    puts "Enter the PIN sent by email:"
    token = gets.chomp

    puts "Registering the new device/UKI pair with Dashlane"
    uki = Dashlane::Uki.generate
    Dashlane::Uki.register_uki_step_2 username, "dashlane-ruby", uki, token

    puts "A new device 'dashlane-ruby' is registered with Dashlane (UKI: #{uki})"
    puts "Please add it to 'credentials.yaml'"

    uki
rescue => e
    puts "Failed to register a new UKI with Dashlane: '#{e}'"
end

# Print the content of the vault
def list_vault username, password, uki
    vault = Dashlane::Vault.open_remote username, password, uki
    vault.accounts.each_with_index do |i, index|
        puts "#{index + 1}: #{i.name} #{i.username} #{i.password} #{i.url} #{i.note}"
    end
rescue => e
    puts "Failed to open the vault: '#{e}'"
end

# Load the credentials and the UKI, if present
credentials = YAML.load_file File.join File.dirname(__FILE__), "credentials.yaml"

username = credentials["username"]
password = credentials["password"]
uki = credentials["uki"]

# Look for a local UKI or get a new one (see the big comment above)
uki ||= import_local_uki(username, password) || register_uki(username)

# Peek inside the vault
list_vault username, password, uki
