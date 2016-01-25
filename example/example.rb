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
    uki = Dashlane::Uki.import username, password
    puts "Found UKI: #{uki}"
rescue
    puts "Account #{username} doesn't seem to exist, incorrent password or " +
         "the platform is not currenlty supported"
end
