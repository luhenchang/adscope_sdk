#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint adscope_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'adscope_sdk'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency  'AMPSAdSDK'

  s.dependency 'AMPSASNPAdapter'
#   s.dependency 'AMPSBZAdapter', '~> 5.1.490700.1'
#   s.dependency 'AMPSGDTAdapter', '~> 5.1.41560.3'
  s.dependency 'AMPSKSAdapter' , '~> 5.1.4920.1'
#   s.dependency 'AMPSGMAdapter'
#   s.dependency 'AMPSBDAdapter', '~> 5.1.10020.1'
#   s.dependency 'AMPSSGAdapter', '~> 5.1.4203.0'
#   s.dependency 'AMPSCSJAdapter'
  s.dependency 'AMPSJDAdapter'
#   s.dependency 'AMPSQMAdapter'
#   s.dependency 'AMPSOCTAdapter'
#   s.dependency 'AMPSMSAdapter'

  s.platform = :ios, '13.0'


  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
