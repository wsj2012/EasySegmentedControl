Pod::Spec.new do |s|
s.name         = "EasySegmentedControl"
s.version      = "2.0.2"
s.summary      = "swift版本HMSegmentedControl,一个好用的第三方分段控制器库，样式可深度灵活定制。"
s.homepage     = "https://github.com/wsj2012/EasySegmentedControl"
s.license      = "MIT"
s.author       = { "wsj_2012" => "time_now@yeah.net" }
s.source       = { :git => "https://github.com/wsj2012/EasySegmentedControl.git", :tag => "#{s.version}" }
s.requires_arc = true
s.ios.deployment_target = "9.0"
s.source_files  = "EasySegmentedControlSource/*.{swift}"
s.swift_version = '4.2'

end
