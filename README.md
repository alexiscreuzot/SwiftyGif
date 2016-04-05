[![Language](https://img.shields.io/badge/swift-2.2-orange.svg)](http://swift.org)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/JWAnimatedImage.svg)](https://img.shields.io/cocoapods/v/JWAnimatedImage.svg)
[![Pod License](http://img.shields.io/cocoapods/l/SDWebImage.svg?style=flat)](https://www.apache.org/licenses/LICENSE-2.0.html)

High performance Gif engine based on [JWAnimatedImage](https://github.com/wangjwchn/JWAnimatedImage)

![video](http://i.imgur.com/v9EHNrK.gif)

##Features
- [x] UIImage and UIImageView extension based
- [x] Great CPU/Memory performances
- [x] Allow controlof  display quality by using factor 'level of Integrity'
- [x] Allow control CPU/memory tradeoff via 'memoryLimit' 

##Installation
######With CocoaPods
```ruby
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!
pod 'SwiftGif'
```

##How to Use
```swift
let gifmanager = SwiftyGifManager(memoryLimit:20)
let gif = UIImage(gifName: "MyImage.gif")
let imageview = UIImageView(gifImage: gif, manager: gifManager, loopTime: -1) // -1 means infinite
imageview.frame = CGRect(x: 0.0, y: 5.0, width: 400.0, height: 200.0)
view.addSubview(imageview)
```

##Licence
SwiftyGif is released under the MIT license. See [LICENSE](https://github.com/kirualex/SwiftyGif/raw/master/LICENSE) for details.
