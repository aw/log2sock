#!/usr/bin/env gem build
# encoding: utf-8

require "base64"

Gem::Specification.new do |s|
  s.name        = 'log2sock'
  s.version     = '0.0.6'

  s.date        = Date.today.to_s

  s.summary     = "log2sock allows you to send logs to a UNIX domain socket"
  s.description = "#{s.summary}. Its usage is similar to the Ruby 'logger' class, except with slightly less features."

  s.author      = 'Alex Williams'
  s.email       = Base64.decode64("YXdpbGxpYW1zQGFsZXh3aWxsaWFtcy5jYQ==\n")

  s.homepage    = 'http://unscramble.co.jp'

  s.require_paths = ["lib"]
  s.bindir      = 'bin'
  s.executables = %w[log2read]
  s.files       = `git ls-files`.split("\n")

  license = 'MIT'
  s.required_ruby_version = ::Gem::Requirement.new("~> 1.9")
end
