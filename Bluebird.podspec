Pod::Spec.new do |s|
  s.name             = 'Bluebird'
  s.version          = '1.10.3'
  s.summary          = 'Promise/A+, Bluebird inspired, implementation in Swift 3'
  s.homepage         = 'https://github.com/AndrewBarba/Bluebird.swift'
  s.license          = 'MIT'
  s.author           = { 'Andrew Barba' => 'abarba.77@gmail.com' }
  s.source           = { :git => 'https://github.com/AndrewBarba/Bluebird.swift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'Source/**/*.swift'
end
