# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jekyllpress/version'

Gem::Specification.new do |spec|
  spec.name          = "jekyllpress"
  spec.version       = Jekyllpress::VERSION
  spec.authors       = ["Tamara Temple"]
  spec.email         = ["tamouse@gmail.com"]
  spec.summary       = %q{Thor utility to do neat jekyll stuff.}
  spec.homepage      = "https://github.com/tamouse/jekyllpress"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", ">= 0.19"
  spec.add_dependency "jekyll"
  spec.add_dependency "stringex", ">= 2"
  spec.add_dependency "i18n"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry", "~> 0.9"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
end
