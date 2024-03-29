Pod::Spec.new do |s|
  s.name             = 'TiltUp'
  s.version          = '5.0.2'
  s.summary          = 'Official Clutter SDK in Swift to access core iOS features.'

  s.description      = <<-DESC
TiltUp is the framework that provides the architectural building blocks for
Clutter's iOS apps. 

In addition to these building blocks, the framework also provides some
pre-built components and utilites that are useful across all of our apps.
                       DESC

  s.homepage         = 'https://github.com/clutter/TiltUp'

  s.author           = { 'Clutter' => 'tech@clutter.com' }
  s.license          = 'MIT'
  s.ios.deployment_target = '14.0'
  s.swift_versions        = ['5.1']

  s.source       = { :git => "git@github.com:clutter/TiltUp.git", :tag => "#{s.version}" }

  s.source_files  = 'Sources/TiltUp/**/*'
end
