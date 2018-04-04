#
#  Be sure to run `pod spec lint DLPageMenu.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "DLPageMenu"
  s.version      = "1.2.0"
  s.summary      = "Paging through view controllers made easy"
  s.description  = <<-DESC
                          A paging menu controller built from other view controllers placed inside a scroll view (like Spotify, Windows Phone, Instagram)
                   DESC
  s.homepage     = "https://github.com/duylinh158/DLPageMenu"
  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "duylinh158" => "duylinh158@gmail.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/duylinh158/DLPageMenu.git", :tag => "#{s.version}" }
  s.source_files  = 'DLPageMenu/*.{h,m,swift}'
  s.frameworks = "Foundation", "UIKit"
end
