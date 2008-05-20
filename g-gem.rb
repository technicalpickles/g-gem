#!/usr/bin/env ruby

require 'rubygems'
require 'rubygems/dependency_installer'

require 'ruby-debug'
require 'erubis'

inst = Gem::DependencyInstaller.new
specs = inst.find_spec_by_name_and_version('activerecord')

input = File.read('ebuild.eruby')
eruby = Erubis::Eruby.new(input)

FileUtils.mkdir_p('ebuilds')

specs.each do |spec_pair|
  spec, source = spec_pair
  filename = "#{spec.name.downcase}-#{spec.version.version}.ebuild"
  output = eruby.result binding
  File.open(filename, 'w') {|f| f.write(output) }
end