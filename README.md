# APIFire
A lightweight toolkit for querying APIs, built on top of Alamofire.

[![Version](https://img.shields.io/cocoapods/v/APIFire.svg?style=flat)](https://cocoapods.org/pods/APIFire)
[![License](https://img.shields.io/cocoapods/l/APIFire.svg?style=flat)](https://cocoapods.org/pods/APIFire)
[![Platform](https://img.shields.io/cocoapods/p/APIFire.svg?style=flat)](https://cocoapods.org/pods/APIFire)

APIFire is an opinionanted, encapsulated toolkit for defining APIs. It includes protocols for API servers and
endpoints. It can form these into managed and easy to call structures that use Alamofire (and underlying native
URLSession calls) to do over-the-wire communication, and uses Decodable to convert response JSON to usable models.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

This project is in Swift 5.1+ and built on top of [Alamofire](https://github.com/Alamofire/Alamofire) 5.2. Both of those are required.

## Installation

APIFire is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'APIFire'
```

## Author

Zack Sheppard, zack@zacksheppard.com

## License

APIFire is available under the MIT license. See the LICENSE file for more info.
