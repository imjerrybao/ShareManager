Pod::Spec.new do |s|
  s.ios.deployment_target   = '7.0'
  s.platform                = :ios, '7.0'
  s.name                    = 'ShareManager'
  s.version                 = '0.3.3'
  s.summary                 = 'A SNS(Social Networking Services) Share Manager for ios, support Instagram, Facebook, Twitter, Weibo, QQ and Wechat.'
  s.homepage                = 'https://github.com/imjerrybao/ShareManager'
  s.license                 = { :type => 'MIT', :file => 'LICENSE' }
  s.author                  = { 'Jerry' => 'imjerrybao@gmail.com' }
  s.source                  = { :git => 'https://github.com/imjerrybao/ShareManager.git', :tag => "v#{s.version.to_s}" }
  s.public_header_files     = 'ShareManager/**/*.h'
  s.source_files            = 'ShareManager/**/*.{h,m}'
  s.resources               = ['ShareManager/SMResources.bundle', 'ShareManager/lib/TencentQQ/TencentOpenApi_IOS_Bundle.bundle']
  s.ios.frameworks          = ['SystemConfiguration', 'CoreTelephony']
  s.ios.vendored_frameworks = 'ShareManager/lib/TencentQQ/TencentOpenAPI.framework'
  s.libraries               = 'c++', 'sqlite3.0', 'z'
  s.ios.vendored_library    = 'ShareManager/lib/WeChatSDK/libWeChatSDK.a'
  s.requires_arc            = true
  s.dependency              'BlocksKit', '~> 2.2.5'
  s.dependency              'MBProgressHUD', '~> 0.9.1'
  s.dependency              'OAuthConsumer', '~> 1.0.3'
end
