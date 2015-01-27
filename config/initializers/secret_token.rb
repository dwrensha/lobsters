# taken from GitLab's secret_token.rb

require 'securerandom'

def find_secure_token
  token_file = '/var/tmp/.secret'
  if ENV.key?('SECRET_KEY_BASE')
    ENV['SECRET_KEY_BASE']
  elsif File.exist? token_file
    # Use the existing token.
    File.read(token_file).chomp
  else
    # Generate a new token of 64 random hexadecimal characters and store it in token_file.
    token = SecureRandom.hex(64)
    File.write(token_file, token)
    token
  end
end

Lobsters::Application.config.secret_token = find_secure_token
Lobsters::Application.config.secret_key_base = find_secure_token
