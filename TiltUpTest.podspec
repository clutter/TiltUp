Pod::Spec.new do |s|
  s.name             = 'TiltUpTest'
  s.version          = '3.1.2'
  s.summary          = 'Official Clutter SDK in Swift to access core iOS test helpers.'

  s.description      = <<-DESC
TiltUpTest is a framework that provides utilities and mocks that are useful for
writing unit tests for components that are written using TiltUp.
                       DESC

  s.homepage         = 'https://github.com/clutter/TiltUp'

  s.author           = { 'Clutter' => 'tech@clutter.com' }
  s.license          = 'MIT' 
  s.ios.deployment_target = '13.3'
  s.swift_versions        = ['5.1']

  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }

  s.frameworks = 'XCTest'
  s.dependency 'TiltUp', "= #{s.version}"

  s.source       = { :git => "git@github.com:clutter/TiltUp.git", :tag => "#{s.version}" }

  s.source_files  = 'Sources/TiltUpTest/**/*'
end
