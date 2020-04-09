#
# Be sure to run `pod lib lint ARQuickLook.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ARQuickLook'
  s.version          = '0.1.0'
  s.summary          = 'Alternative for Apple\'s AR Quick Look, with GLB/GLTF format support, and https loader support.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Alternative for Apple's AR Quick Look, with GLB/GLTF format support, and allows developers to load model not only from lcoal file system path, but also from remote server with https request.
                       DESC

  s.homepage         = 'https://github.com/lapbay/ARQuickLook'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lapbay' => 'lapbay@gmail.com' }
  s.source           = { :git => 'https://github.com/lapbay/ARQuickLook.git', :tag => '0.1.0' }
  s.social_media_url = 'https://twitter.com/tapray'

  s.ios.deployment_target = '11.0'

  s.source_files = 'ARQuickLook/Classes/**/*'
  s.platform = :ios, '11.0'
  s.swift_version = '5.0'
  s.pod_target_xcconfig = {
    "SWIFT_VERSION" => "5.0"
  }

  # s.resource_bundles = {
  #   'ARQuickLook' => ['ARQuickLook/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
   s.frameworks = 'UIKit', 'ARKit'
   s.dependency 'GLTFSceneKit'
end
