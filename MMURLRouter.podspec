#
# Be sure to run `pod lib lint MMRouter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MMURLRouter'
  s.version          = '0.0.2'
  s.summary          = 'MMURLRouter is a tool for any modules.'
  s.description      = <<-DESC
    MMRouter is a tool for any modules,you can use it more easier
    DESC
  s.homepage         = 'https://github.com/IDwangluting/MMURLRouter'
  s.license          = 'Copyright (c) 2018年 wangluitng. All rights reserved.'
  s.author           = { 'IDwangluting' => 'm13051699286@163.com' }
  s.source           = { :git => 'https://github.com/IDwangluting/MMURLRouter.git', :tag => s.version.to_s }
  
  s.ios.deployment_target   = '8.0'
  s.source_files            = 'MMURLRouter/Classes/**/*'
  s.frameworks              = 'UIKit','Foundation'
  s.libraries               = 'Objc'
  s.dependency 'YYModel','~> 1.0.4'
  s.dependency 'YYCategories','~> 1.0.4'
  s.dependency 'WWBaseLib'
end




