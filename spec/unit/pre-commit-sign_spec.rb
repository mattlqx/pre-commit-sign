# frozen_string_literal: true

require_relative '../spec_helper'
require './lib/pre-commit-sign'
require 'tempfile'
require 'fileutils'

describe PrecommitSign do
  let(:tempfile) { Tempfile.new('pre-commit-sign_spec') }
  let(:test_message) { "This is a test commit\n\nTest summary!\nMore.\n\n# Some comment\n\n\n" }
  let(:test_message2) { "This is a different commit\n\nAnother summary.\nMoar.\nPrecommit-Verified: f00\n" }
  let(:file_instance) { described_class.new(tempfile) }
  let(:string_instance) { described_class.from_message(test_message2) }

  before do
    IO.write(tempfile, test_message)
  end

  describe '#initialize' do
    it 'creates object with nil argument' do
      instance_with_nil = described_class.new
      expect(instance_with_nil).to be_an_instance_of(described_class)
      expect(instance_with_nil.message).to be_nil
    end

    it 'creates object with a path argument' do
      expect(file_instance).to be_an_instance_of(described_class)
    end

    it 'reads message from path' do
      expect(file_instance.message).to eq(test_message)
    end
  end

  describe '.from_message' do
    it 'creates an object with specified message' do
      expect(string_instance).to be_an_instance_of(described_class)
      expect(string_instance.message).to eq(test_message2)
    end

    it 'has a no file' do
      expect(string_instance.instance_variable_get('@message_file')).to be_nil
    end
  end

  describe '#real_message' do
    it 'filters out comments' do
      expect(file_instance.real_message).to eq("This is a test commit\n\nTest summary!\nMore.")
    end

    it 'filters out footer' do
      expect(string_instance.real_message).to eq("This is a different commit\n\nAnother summary.\nMoar.")
    end

    it 'strips whitespace from both ends' do
      expect(described_class.from_message("\n\t\nthis is\n\na commit\n    \n\n").real_message).to \
        eq("this is\n\na commit")
    end
  end

  describe '#date' do
    it 'gets date from environment' do
      ENV['GIT_AUTHOR_DATE'] = '@1528992614 -7:00'
      instance = described_class.new(tempfile)
      expect(instance.date).to be_an_instance_of(Time)
      expect(instance.date.to_s).to eq('2018-06-14 16:10:14 UTC')
      ENV.delete('GIT_AUTHOR_DATE')
    end

    it 'defaults to now' do
      expect(file_instance.date).to be_within(10).of(Time.now)
    end

    it 'returns set time' do
      file_instance.date = Time.at(1_528_993_040)
      expect(file_instance.date.to_s).to eq('2018-06-14 16:17:20 UTC')
    end
  end

  describe '#commit_title' do
    it 'returns first line of real message' do
      expect(file_instance.commit_title).to eq('This is a test commit')
    end
  end

  describe '#commit_message' do
    it 'returns body of the real message' do
      expect(file_instance.commit_message).to eq("Test summary!\nMore.")
    end
  end

  describe '#signature' do
    it 'signs with hash of real message and date' do
      file_instance.date = Time.at(1_528_993_040)
      expect(file_instance.signature).to eq('6e07bede86ce004dd5771934ed5e2f759e79ab2fc43303a55f488d1d1f034069')
    end
  end

  describe '#commit_signature?' do
    it 'sees signature when present' do
      expect(string_instance.commit_signature?).to eq true
    end

    it 'does not see signature when absent' do
      expect(file_instance.commit_signature?).to eq false
    end
  end

  describe '#valid_signature?' do
    before do
      file_instance.date = Time.at(1_528_993_040)
    end

    it 'sees no signature as invalid' do
      expect(file_instance.valid_signature?).to be false
    end

    it 'sees an invalid signature as invalid' do
      expect(string_instance.valid_signature?).to be false
    end

    it 'sees a valid signature as valid' do
      file_instance.message = "#{file_instance.message}\n" \
        "Precommit-Verified: 6e07bede86ce004dd5771934ed5e2f759e79ab2fc43303a55f488d1d1f034069\n"
      expect(file_instance.valid_signature?).to be true
    end
  end

  describe '#existing_signature' do
    it 'returns existing signature from message' do
      expect(string_instance.existing_signature).to eq('f00')
    end
  end

  describe '#write_signature' do
    before do
      file_instance.date = Time.at(1_528_993_040)
      file_instance.write_signature
    end

    it 'adds signature to message' do
      expect(file_instance.message).to \
        match(/^Precommit-Verified: 6e07bede86ce004dd5771934ed5e2f759e79ab2fc43303a55f488d1d1f034069$/)
    end

    it 'adds signature to file' do
      expect(IO.read(tempfile)).to \
        match(/^Precommit-Verified: 6e07bede86ce004dd5771934ed5e2f759e79ab2fc43303a55f488d1d1f034069$/)
    end
  end
end
