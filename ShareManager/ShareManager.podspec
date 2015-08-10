Pod::Spec.new do |s|
  s.ios.deployment_target = '7.0'
  s.name                  = 'ShareManager'
  s.version               = '0.1.0'
  s.summary               = 'A SNS Platform Share Manager for ios, support Facebook, Twitter, Weixin, QQ and Weixin.'
  s.homepage              = 'https://github.com/imjerrybao/ShareManager'
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.author                = { 'Jerry' => 'imjerrybao@gmail.com' }
  s.source                = { :git => 'https://github.com/imjerrybao/ShareManager.git', :tag => "v#{s.version.to_s}" }
  s.source_files          =  '*.{h,m}'
  s.resources             = 'SMResources.bundle'
  s.ios.frameworks        = 'libc++, libsqlite3.0, libz, SystemConfiguration'
  s.requires_arc          = true
  s.dependency            'BlocksKit', '~> 2.2.5'  'MBProgressHUD', '~> 0.9.1'
end
