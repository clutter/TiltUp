#
# Be sure to run `pod lib lint TiltUpTest.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TiltUpTest'
  s.version          = '2.2.1'
  s.summary          = 'Official Clutter SDK in Swift to access core iOS test helpers.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/clutter/TiltUp'

  s.author           = { 'Erik Strottmann' => 'erik.strottmann@clutter.com' }

  s.ios.deployment_target = '13.3'
  s.swift_versions        = ['5.1']

  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }

  s.frameworks = 'XCTest'
  s.dependency 'TiltUp'

  s.source       = { :git => "git@github.com:clutter/TiltUp.git", :tag => "#{s.version}" }

  s.source_files  = 'TiltUpTest/**/*'
end
