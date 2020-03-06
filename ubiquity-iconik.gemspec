# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ubiquity/iconik/version'

Gem::Specification.new do |spec|
  spec.name          = 'ubiquity-iconik'
  spec.version       = Ubiquity::Iconik::VERSION
  spec.authors       = ['John Whitson']
  spec.email         = ['john.whitson@gmail.com']

  spec.summary       = %q{A library for interacting with Cantemo's Iconik product.}
  spec.description   = %q{}
  spec.homepage      = %q{https://github.com/XPlatform-Consulting/ubiquity-iconik}
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14.a'
  spec.add_development_dependency 'rake', ">= 12.3.3"
  spec.add_development_dependency 'minitest', '~> 5.0'
end
