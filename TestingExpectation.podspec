Pod::Spec.new do |s|
  s.name     = 'TestingExpectation'
  s.version  = '0.1.1'
  s.license  = 'MIT'
  s.summary  = 'Create an asynchronous expectation in Swift Testing'
  s.homepage = 'https://github.com/dfed/swift-testing-expectation'
  s.authors  = 'Dan Federman'
  s.source   = { :git => 'https://github.com/dfed/swift-testing-expectation.git', :tag => s.version }
  s.swift_version = '6.0'
  s.source_files = 'Sources/**/*.{swift}'
  s.frameworks = 'Testing'
  s.ios.deployment_target = '16.0'
  s.tvos.deployment_target = '16.0'
  s.watchos.deployment_target = '9.0'
  s.macos.deployment_target = '13.0'
  s.visionos.deployment_target = '1'
end
