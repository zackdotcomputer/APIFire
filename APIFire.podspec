#
# Be sure to run `pod lib lint APIFire.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'APIFire'
  s.version          = '0.2.0'
  s.summary          = 'A lightweight toolkit for querying APIs, built on top of Alamofire.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
APIFire is an opinionanted, encapsulated toolkit for defining APIs. It includes protocols for API servers and
endpoints. It can form these into managed and easy to call structures that use Alamofire (and underlying native
URLSession calls) to do over-the-wire communication, and uses Decodable to convert response JSON to usable models.
                       DESC

  s.homepage         = 'https://github.com/zackdotcomputer/APIFire'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Zack Sheppard' => 'zack@zacksheppard.com' }
  s.source           = { :git => 'https://github.com/zackdotcomputer/APIFire.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

# Copied from Alamofire 5.2.2 - intentionally mirrors their compatability
  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.tvos.deployment_target = '10.0'
  s.watchos.deployment_target = '3.0'

  s.swift_versions = ['5.1', '5.2']

  s.source_files = 'APIFire/src/**/*'
  
  # s.resource_bundles = {
  #   'APIFire' => ['APIFire/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Alamofire', '~> 5.2'
  s.dependency 'Logging', '~> 1.2'
end
