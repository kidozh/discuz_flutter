Pod::Spec.new do |s|
  s.name = 'apple_post_translation'
  s.version = '0.1.0'
  s.summary = 'Apple Translation for forum posts'
  s.description = s.summary
  s.homepage = 'https://developer.apple.com/documentation/translation'
  s.license = { :type => 'MIT' }
  s.author = 'Discuz Flutter'
  s.source = { :path => '.' }
  s.source_files = 'Classes/**/*.swift'
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '18.0'
  s.osx.deployment_target = '15.0'
  s.frameworks = 'Translation', 'SwiftUI', 'NaturalLanguage'
  s.swift_version = '5.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
