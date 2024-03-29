#
#  Be sure to run `pod spec lint lQBFramework_IOS.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "QBSpeechRecognizer"
  s.version      = "1.0.3"
  s.summary      = "语音识别框架."
  s.description  = "语音识别框架."

  s.homepage     = "https://github.com"

  s.license      = "MIT"

  s.author             = { "tjs101" => "tjs101@live.cn" }
  s.platform     = :ios, "10.0"
  s.ios.deployment_target = "10.0"
  s.source       = { :git => "", :tag => "#{s.version}" }
  s.source_files  = "QBSpeechRecognizer/**/*.{h,m}"

  s.framework  = "Speech"

  s.requires_arc = true

end
