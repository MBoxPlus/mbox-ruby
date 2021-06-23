
require 'yaml'
yaml = YAML.load_file('../manifest.yml')
name = yaml["NAME"]
name2 = name.sub('MBox', 'mbox').underscore
version = ENV["VERSION"] || yaml["VERSION"]

Pod::Spec.new do |spec|
  spec.name         = "#{name}"
  spec.version      = "#{version}"
  spec.summary      = "Ruby Support Plugin for MBox."
  spec.description  = <<-DESC
    Make mbox to support ruby.
                   DESC

  spec.homepage     = "https://github.com/MBoxSpace/#{name2}"

  spec.license      = "MIT"
  spec.author       = { `git config user.name`.strip => `git config user.email`.strip }
  spec.source       = { :git => "git@github.com:MBoxSpace/#{name2}.git", :tag => "#{spec.version}" }

  spec.platform     = :osx, '10.15'
  spec.source_files = "#{name}/*.{h,m,swift}", "#{name}/**/*.{h,m,swift}"
  spec.default_subspec = 'Core'

  spec.subspec 'Core' do |ss|
    ss.source_files = "#{name}/*.{h,m,swift}", "#{name}/**/*.{h,m,swift}"

    yaml['DEPENDENCIES'].each do |name|
      ss.dependency name
    end
  end
#  spec.dependency "RubyGateway"
end
