[![Language](https://img.shields.io/badge/swift-5.0-blue.svg)](http://swift.org)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/SwiftyGif.svg)](https://img.shields.io/cocoapods/v/SwiftyGif.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/kirualex/SwiftyGif.svg?branch=master)](https://travis-ci.org/kirualex/SwiftyGif)
[![Pod License](http://img.shields.io/cocoapods/l/SDWebImage.svg?style=flat)](https://raw.githubusercontent.com/kirualex/SwiftyGif/master/LICENSE)

High performance & easy to use Gif engine

<img src="http://i.imgur.com/p8A6jJh.gif" width="280" />

## Features
- [x] UIImage and UIImageView extension based
- [x] Remote Gifs
- [x] Great CPU/Memory performances
- [x] Control playback
- [x] Allow control of  display quality by using 'levelOfIntegrity'
- [x] Allow control CPU/memory tradeoff via 'memoryLimit' 

## Installation

#### With CocoaPods
```ruby
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!
pod 'SwiftyGif'
```

#### With Carthage
Follow the usual Carthage instructions on how to [add a framework to an application](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application). When adding SwiftyGif among the frameworks listed in `Cartfile`, apply its syntax for [GitHub repositories](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#github-repositories):

```
github "kirualex/SwiftyGif"
```

## How to Use

#### Project files
As of now, Xcode `xcassets` folders do not recognize `.gif` as images. This means you need to put your `.gif` oustide of the assets. I recommend creating a group `gif` for instance. 

#### Quick Start
SwiftyGif uses familiar `UIImage` and `UIImageView`  to display gifs. 

```swift
import SwiftyGif

do {
    let gif = try UIImage(gifName: "MyImage.gif")
    let imageview = UIImageView(gifImage: gif, loopCount: 3) // Use -1 for infinite loop
    imageview.frame = view.bounds
    view.addSubview(imageview)
} catch {
    print(error)
}
```

In case your `UIImageView` is already created (via Nib or Storyboards for instance), it's even easier.

```swift
self.myImageView.setGifImage(gif) 

// You can also set it with an URL pointing to your gif
let url = URL(string: "...")
self.myImageView.setGifFromURL(url) 
```

#### Performances
A  `SwiftyGifManager`  can hold one or several UIImageView using the same memory pool. This allows you to tune the memory limits to you convenience. If no manager is declared, SwiftyGif will just use the `SwiftyGifManager.defaultManager`.


##### Level of integrity
Setting a lower level of integrity will allow for frame skipping, lowering both CPU and memory usage. This can be a godd option if you need to preview a lot of gifs at the same time.

```swift
do {
    let gif = try UIImage(gifName: "MyImage.gif", levelOfIntegrity:0.5)
} catch {
    print(error)
}
```

#### Controls
SwiftyGif offer various controls on the current `UIImageView` playing your gif file. 

```swift
self.myImageView.startAnimatingGif()
self.myImageView.stopAnimatingGif()
self.myImageView.showFrameAtIndexDelta(delta: Int)
self.myImageView.showFrameAtIndex(index: Int)
```

To allow easy use of those controls, some utility methods are provided :

```swift
self.myImageView.isAnimatingGif() // Returns wether the gif is currently playing
self.myImageView.gifImage!.framesCount() // Returns number of frames for this gif
```

#### Delegate
You can declare a SwiftyGifDelegate to receive updates on the gif lifecycle.
For instance, if you want your controller `MyController` to act as the delegate:
```swift
override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.delegate = self
}
```

Then simply add an extension:

```swift
extension MyController : SwiftyGifDelegate {

    func gifURLDidFinish(sender: UIImageView) {
        print("gifURLDidFinish")
    }

    func gifURLDidFail(sender: UIImageView) {
        print("gifURLDidFail")
    }

    func gifDidStart(sender: UIImageView) {
        print("gifDidStart")
    }
    
    func gifDidLoop(sender: UIImageView) {
        print("gifDidLoop")
    }
    
    func gifDidStop(sender: UIImageView) {
        print("gifDidStop")
    }
}
```

## Benchmark
#### Display 1 Image
|               |CPU Usage(average) |Memory Usage(average) |
|:-------------:|:-----------------:|:-----------------------:|
|FLAnimatedImage|35%                |9,5Mb                    |
|SwiftyGif      |2%                 |18,4Mb                   |
|SwiftyGif(memoryLimit:10)|34%      |9,5Mb                    |

#### Display 6 Images
|               |CPU Usage(average) |Memory Usage(average) |
|:-------------:|:-----------------:|:-----------------------:|
|FLAnimatedImage|65%                |25,1Mb                   |
|SwiftyGif      |22%                |105Mb                    |
|SwiftyGif(memoryLimit:20)|45%      |26Mb                     |

Measured on an iPhone 6S, iOS 9.3.1 and Xcode 7.3.

