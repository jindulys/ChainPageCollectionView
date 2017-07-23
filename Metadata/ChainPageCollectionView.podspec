#
#  Be sure to run `pod spec lint ChainPageCollectionView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "ChainPageCollectionView"
  s.version      = "1.0.1"
  s.summary      = "ChainPageCollectionView to animate a chain of parent-child collection view."

  s.homepage     = "https://github.com/jindulys/ChainPageCollectionView"

  s.license      = "MIT"

  s.author             = { "jindulys" => "liyansong.edw@gmail.com" }

  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/jindulys/ChainPageCollectionView.git", :tag => s.version }

  s.source_files  = 'Sources/*.{h,swift}'

  # s.requires_arc = true
  
  s.pod_target_xcconfig = {'SWIFT_VERSION' => '3'}

end
