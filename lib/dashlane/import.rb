# Copyright (C) 2016 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

module Dashlane
    module Import
        def self.load_uki username, password
            xml = load_settings username, password
            REXML::Document.new(xml).text "/root/KWLocalSettingsManager/KWDataItem[@key='uki']"
        end

        def self.load_settings username, password
            blob = Base64.encode64 File.binread find_settings_file username
            Parser.decrypt_blob blob, password
        end

        def self.find_settings_file username
            # TODO: Support other OSes!
            raise NotImplementedError, "Unsupported platform" if !RUBY_PLATFORM =~ /darwin/

            profiles_path = "Library/Group Containers/5P72E3GC48.com.dashlane/Dashlane/profiles"
            settings_path = "Settings/localSettings.aes"

            path = File.join Dir.home, profiles_path, username, settings_path
            raise "Profile '#{username}' doesn't exist" if !File.exist? path

            path
        end
    end
end
