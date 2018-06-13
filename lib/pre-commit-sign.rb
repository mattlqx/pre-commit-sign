# frozen_string_literal: true

require 'date'
require 'digest'

# Class for signing Git commit messages with a computed hash
class PrecommitSign
  SIG_KEY = 'Precommit-Verified'

  def initialize(message_file)
    @message_file = message_file
  end

  def full_message
    IO.read(@message_file)
  end

  # Ignores comments, leading and trailing whitespace and the signature footer
  def real_message
    m = full_message.split("\n").reject { |l| l.start_with?('#', "#{SIG_KEY}:") }.join("\n")
    /^\s*(.*?)\s*$/m.match(m).captures.first
  end

  def date
    date_comment = /^# Date:\s+(.*)/.match(full_message)&.captures&.first
    DateTime.parse(date_comment) unless date_comment.nil?
  end

  def commit_title
    real_message.split("\n").first
  end

  def commit_message
    real_message.split("\n")[2..-1].join("\n")
  end

  def signature
    raise 'Date comment is missing from commit message' if date.nil?
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

  # Real message with signature and Date comment added back for future hashing
  def write_signature
    IO.write(
      @message_file,
      "#{real_message.chomp}\n\n#{SIG_KEY}: #{signature}\n\n# Date:  #{date}\n",
      0,
      mode: 'w'
    )
  end
end
