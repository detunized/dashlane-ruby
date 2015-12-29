#!/usr/bin/env ruby

require "digest"
require "net/http"

def post url, params
    uri = URI url
    response = Net::HTTP.post_form uri, params
    raise "POST to '#{url}' failed (#{response.msg}: '#{response.msg}')" if response.code != "200"

    response.body
end

def request_token username
    response = post "https://www.dashlane.com/6/authentication/sendtoken", {
        login: username,
        isOTPAware: true
    }

    raise "Failed to request a token" if response != "SUCCESS"
end

def generate_uki
    time = (Time.now.to_f * 1000).to_i.to_s
    text = RUBY_DESCRIPTION + time + ((1 + Random.rand) * 268435456).to_i.to_s(16)
    hashed = Digest::MD5.hexdigest text

    hashed + "-webaccess-" + time
end

def register username, uki, name, token
    response = post "https://www.dashlane.com/6/authentication/registeruki", {
        devicename: name,
        login: username,
        platform: "webaccess",
        temporary: 0,
        token: token,
        uki: uki
    }

    p response
end

username = File.read(".username").strip
name = "dashlane-ruby"

puts "Requesting a token"
request_token username
puts "Enter the token from the email:"
token = gets.chomp
uki = generate_uki
puts "Registering uki '#{uki}' for '#{name}'"
register username, uki, name, token
