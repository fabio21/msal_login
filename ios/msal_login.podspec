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
  s.homepage         = 'https://github.com/AzureAD/microsoft-authentication-library-for-objc.git'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'FSC' => '' }
  s.source           = { :path => '.' }
  s.source_files = '/ios/login.swift'
  s.public_header_files = '/ios/login.swift'
  s.dependency 'Flutter'
  s.dependency 'MSAL', '~> 1.1.1'

  s.swift_version = '4.0'
  s.ios.deployment_target = '11.0'
end

