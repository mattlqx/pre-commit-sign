# frozen_string_literal: true

require 'date'
require 'digest'

# Class for signing Git commit messages with a computed hash
class PrecommitSign
  SIG_KEY = 'Precommit-Verified'

  attr_accessor :message
  attr_writer :date # Manually set a commit date with a Time object

  def initialize(message_file = nil)
    @message_file = message_file
    @message = IO.read(@message_file) unless @message_file.nil?
  end

  def self.from_message(message)
    instance = new
    instance.message = message
    instance
  end

  def full_message
    message
  end

  # Ignores comments, leading and trailing whitespace and the signature footer
  def real_message
    m = full_message.split("\n").reject { |l| l.start_with?('#', "#{SIG_KEY}:") }.join("\n")
    /\A\s*(.*?)\s*\Z/m.match(m).captures.first
  end

  def date
    if ENV.key?('GIT_AUTHOR_DATE')
      DateTime.strptime(ENV['GIT_AUTHOR_DATE'], '@%s %z').to_time.utc
    else
      (@date || Time.now).utc
    end
  end

  def commit_title
    real_message.split("\n").first
  end

  def commit_message
    real_message.split("\n")[2..-1].join("\n")
  end

  def signature
    Digest::SHA256.hexdigest("#{real_message}#{date}")
  end

  def commit_signature?
    /^Precommit-Verified:/.match?(full_message)
  end

  def valid_signature?
    existing_signature == signature
  end

  def existing_signature
    /#{SIG_KEY}:\s*([a-f0-9]+)$/.match(full_message)&.captures&.first
  end

  # Real message with signature
  def write_signature
    self.message = "#{real_message.chomp}\n\n#{SIG_KEY}: #{signature}\n"
    IO.write(@message_file, message, 0, mode: 'w') unless @message_file.nil?
  end
end
