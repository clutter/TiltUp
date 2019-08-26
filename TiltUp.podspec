#
# Be sure to run `pod lib lint TiltUp.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TiltUp'
  s.version          = '0.1.1'
  s.summary          = 'Official Clutter SDK in Swift to access core iOS features.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/clutter/TiltUp'

  s.author           = { 'Jeremy Grenier' => 'jeremy.grenier@clutter.com' }
  s.source           = { :git => 'https://github.com/Jeremy Grenier/TiltUp.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_version         = '5.0'

  s.source       = { :git => "git@github.com:clutter/TiltUp.git", :tag => "#{s.version}" }

  s.source_files  = 'TiltUp/Classes/**/*'
end
