# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'codegrade/version'

Gem::Specification.new do |spec|
  spec.name          = "codegrade"
  spec.version       = Codegrade::VERSION
  spec.authors       = ["Michał Młoźniak", "Karol Słuszniak"]
  spec.email         = ["contact@visuality.pl"]
  spec.summary       = %q{Grade your git commits}
  spec.description   = %q{This tool grades your commit messages and all changes files}
  spec.homepage      = "http://www.visuality.pl"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency('bundler', '~> 1.7')
  spec.add_development_dependency('rake', '~> 10.0')
  spec.add_development_dependency('rspec', '~> 3.1')
  spec.add_runtime_dependency('rubocop', '~> 0.27')
  spec.add_runtime_dependency('rugged', '~> 0.21')
end
