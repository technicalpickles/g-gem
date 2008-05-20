#!/usr/bin/env ruby

require 'rubygems'
require 'rubygems/dependency_installer'

require 'ruby-debug'
require 'erubis'

package = ARGV.first || 'activerecord'

class Ebuild
  attr_accessor :spec, :source
  
  def initialize(spec_pair)
    @spec, @source = spec_pair 
  end
  
  def filename
    "#{spec.name.downcase}-#{spec.version.version}.ebuild"
  end
  
  def atom_of(dependency)
    "dev-ruby/#{dependency.name}"
  end
  
  def uri
    "#{source}/gems/#{spec.name}-#{spec.version.version}.gem"
  end
  
  def write
    output = eruby.evaluate(self)
    FileUtils.mkdir_p('ebuilds')
    File.open("ebuilds/#{filename}", 'w') {|f| f.write(output) }
  end
  
  protected
  
  def eruby
    unless @eruby
      input = File.read('ebuild.eruby')
      @eruby = Erubis::Eruby.new(input)
    end
    @eruby
  end
  
  def self.create_from_spec_lookup(package)
    @@inst ||= Gem::DependencyInstaller.new
    spec_pair = @@inst.find_spec_by_name_and_version(package).first
    self.new(spec_pair)
  end
end


gems_to_lookup = [package]
ebuilds = {}
until gems_to_lookup.empty?
  next_package = gems_to_lookup.shift
  
  unless ebuilds.has_key?(next_package)
    puts "Gathering info about #{next_package}..."
  
    ebuilds[next_package] = Ebuild.create_from_spec_lookup(next_package)
  else
    puts "Already know about #{next_package}"
  end
  
  ebuilds[next_package].spec.dependencies.each do |dependency|
    unless ebuilds.has_key? dependency.name
      puts "Need to lookup dependency #{dependency.name}"
      gems_to_lookup.push(dependency.name)
    end
  end
end

ebuilds.each_pair do |name, ebuild|
  puts "Writing out #{ebuild.filename}"
  ebuild.write
end