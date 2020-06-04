#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'msal_login'
  s.version          = '0.0.1'
  s.summary          = 'MSAL Flutter Wrapper'
  s.description      = <<-DESC 
  A new flutter plugin project. 
  DESC
  s.homepage         = 'https://github.com/AzureAD/microsoft-authentication-library-for-objc'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'FSC' => 'fsconceicao@hotmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'MSAL', '~> 1.1.1'

  s.swift_version = '4.0'
  s.ios.deployment_target = '11.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end

