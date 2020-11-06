# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'pre-commit-sign'
  s.version     = '1.1.2'
  s.licenses    = ['MIT']
  s.summary     = 'Pre-commit plugin for signing commits'
  s.description = 'This pre-commit plugin will hash certain fields of the commit message and sign it.'
  s.authors     = ['Matt Kulka']
  s.email       = 'matt@lqx.net'
  s.files       = ['lib/pre-commit-sign.rb']
  s.executables = ['sign-commit']
  s.homepage    = 'https://github.com/mattlqx/pre-commit-sign'
  s.metadata    = { 'source_code_uri' => 'https://github.com/mattlqx/pre-commit-sign' }

  s.required_ruby_version = '>= 2.3'
end
