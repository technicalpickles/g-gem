#!/usr/bin/env ruby

require 'rubygems'
require 'rubygems/dependency_installer'

require 'ruby-debug'
require 'erubis'

package = ARGV.first || 'activerecord'

inst = Gem::DependencyInstaller.new
specs = inst.find_spec_by_name_and_version(package)



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
    File.open(filename, 'w') {|f| f.write(output) }
  end
  
  protected
  
  def eruby
    unless @eruby
      input = File.read('ebuild.eruby')
      @eruby = Erubis::Eruby.new(input)
    end
    @eruby
  end
  
end

specs.each do |spec_pair|
  ebuild = Ebuild.new(spec_pair)
  
  ebuild.write
end