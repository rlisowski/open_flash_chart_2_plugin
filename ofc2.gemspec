# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ofc2/version"

Gem::Specification.new do |s|
  s.name        = "ofc2"
  s.version     = OFC2::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Rafał Lisowski"]
  s.email       = ["lisukorin@gmail.com"]
  s.homepage    = "http://github.com/korin/open_flash_chart_2_plugin"
  s.summary     = %q{open flash chart 2 plugin for rails applications}
  s.description = %q{This library was ported from the open flash chart project's php code to be used with Ruby on Rails.}
  s.license = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
