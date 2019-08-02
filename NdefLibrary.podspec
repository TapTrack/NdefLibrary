#
# Be sure to run `pod lib lint NdefLibrary.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NdefLibrary'
  s.version          = '1.0.0'
  s.summary          = 'Parse and compose NDEF messages on iOS without CoreNFC.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This library is intended for use in applications that use external NFC readers (such as TapTrack Tappy 
readers) from which NDEF messages must be validated, parsed, and composed.
                       DESC

  s.homepage         = 'https://github.com/TapTrack/NdefLibrary'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Alice Cai' => 'info@taptrack.com' }
  s.source           = { :git => 'https://github.com/TapTrack/NdefLibrary.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.swift_version = "4.2"

  s.source_files = 'NdefLibrary/Classes/**/*'
  
  # s.resource_bundles = {
  #   'NdefLibrary' => ['NdefLibrary/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
