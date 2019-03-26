Pod::Spec.new do |s|
  s.name = 'Bluebird'
  s.version = '5.0.0'
  s.summary = 'Promise/A+, Bluebird inspired, implementation in Swift 4'
  s.homepage = 'https://github.com/AndrewBarba/Bluebird.swift'
  s.documentation_url = 'https://andrewbarba.github.io/Bluebird.swift/'
  s.license = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author = { 'Andrew Barba' => 'abarba.77@gmail.com' }
  s.source = { :git => 'https://github.com/AndrewBarba/Bluebird.swift.git', :tag => s.version.to_s }

  s.swift_version = '5.0'
  s.source_files = 'Sources/**/*.swift'

  s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
end
