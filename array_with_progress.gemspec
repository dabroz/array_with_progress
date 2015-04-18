# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'array_with_progress/version'

Gem::Specification.new do |spec|
  spec.name          = "array_with_progress"
  spec.version       = ArrayWithProgress::VERSION
  spec.authors       = ["Tomasz Dąbrowski"]
  spec.email         = ["t.dabrowski@rock-hard.eu"]

  spec.summary       = 'Easily visualize progress of any Ruby task. A drop in replacement for Array.each.'
  spec.description   = "Output uses different colors for successes/failured, allowing to easily check status of every task. Every line is trimmed/padded to match the terminal width. There is also a possiblity to change item name during processing. Transactions for ActiveRecord are also handled if required."
  spec.homepage      = "https://github.com/dabroz/array_with_progress"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|example)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'colorize'
  spec.add_runtime_dependency 'highline'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency 'activerecord'
end
