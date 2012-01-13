# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "ether_shell"
  s.version = "0.9.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Victor Costan"]
  s.date = "2012-01-13"
  s.description = "IRB session specialized for testing Ethernet devices"
  s.email = "victor@costan.us"
  s.executables = ["ether_shell"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".project",
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/ether_shell",
    "ether_shell.gemspec",
    "lib/ether_shell.rb",
    "lib/ether_shell/expectation_error.rb",
    "lib/ether_shell/shell_dsl.rb",
    "spec/ether_shell/shell_dsl_spec.rb",
    "spec/ether_shell_spec.rb",
    "spec/spec_helper.rb",
    "spec/support/raw_socket_stub.rb",
    "spec/support/shell_stub.rb"
  ]
  s.homepage = "http://github.com/pwnall/ether_shell"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.15"
  s.summary = "IRB session specialized for testing Ethernet devices"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ethernet>, [">= 0.1.3"])
      s.add_development_dependency(%q<rdoc>, [">= 3.6.1"])
      s.add_development_dependency(%q<rspec>, [">= 2.8.0"])
      s.add_development_dependency(%q<bundler>, [">= 1.0.0"])
      s.add_development_dependency(%q<jeweler>, [">= 1.6.4"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
    else
      s.add_dependency(%q<ethernet>, [">= 0.1.3"])
      s.add_dependency(%q<rdoc>, [">= 3.6.1"])
      s.add_dependency(%q<rspec>, [">= 2.8.0"])
      s.add_dependency(%q<bundler>, [">= 1.0.0"])
      s.add_dependency(%q<jeweler>, [">= 1.6.4"])
      s.add_dependency(%q<rcov>, [">= 0"])
    end
  else
    s.add_dependency(%q<ethernet>, [">= 0.1.3"])
    s.add_dependency(%q<rdoc>, [">= 3.6.1"])
    s.add_dependency(%q<rspec>, [">= 2.8.0"])
    s.add_dependency(%q<bundler>, [">= 1.0.0"])
    s.add_dependency(%q<jeweler>, [">= 1.6.4"])
    s.add_dependency(%q<rcov>, [">= 0"])
  end
end

