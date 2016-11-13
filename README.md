[![Language](https://img.shields.io/badge/swift-3-orange.svg)](http://swift.org)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/SwiftyGif.svg)](https://img.shields.io/cocoapods/v/SwiftyGif.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Pod License](http://img.shields.io/cocoapods/l/SDWebImage.svg?style=flat)](https://www.apache.org/licenses/LICENSE-2.0.html)
[![Build Status](https://travis-ci.org/kirualex/SwiftyGif.svg?branch=master)](https://travis-ci.org/kirualex/SwiftyGif)

High performance & easy to use Gif engine

<img src="http://i.imgur.com/p8A6jJh.gif" width="280" /> <img src="http://i.imgur.com/0hJ8MzW.gif" width="280"  />

##Features
- [x] UIImage and UIImageView extension based
- [x] Great CPU/Memory performances
- [x] Control playback
- [x] Allow control of  display quality by using 'levelOfIntegrity'
- [x] Allow control CPU/memory tradeoff via 'memoryLimit' 

##Installation
######With CocoaPods
```ruby
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!
pod 'SwiftyGif'
```

##How to Use

####Project files
As of now, Xcode `xcassets` folders do not recognize `.gif` as images. This means you need to put your `.gif` oustide of the assets. I recommend creating a group `gif` for instance. 

####Init
To use SwiftyGif you need 3 components:
- An `UIImage` which backs the gif data and cache it for efficient use.
- An `UIImageView` which hold to the `UIImage` gif and provide utility methods.
- A `SwiftyGifManager` which can hold one or several `UIImageView` using the same memory pool.

```swift
let gifmanager = SwiftyGifManager(memoryLimit:20)
let gif = UIImage(gifName: "MyImage.gif")
let imageview = UIImageView(gifImage: gif, manager: gifManager)
imageview.frame = CGRect(x: 0.0, y: 5.0, width: 400.0, height: 200.0)
view.addSubview(imageview)
```
####Set
In case your `UIImageView` is already created (via Nib or Storyboards for instance), you can also set its Gif.
You can do this multiple times, new parameters overwrite old ones.

```swift
let gifmanager = SwiftyGifManager(memoryLimit:20)
self.myImageView.setGifImage(gif, manager: gifManager) 
```
####Level of integrity
Setting a lower level of integrity will allow for frame skipping, lowering both CPU and memory usage. This can be a godd option if you need to preview a lot of gifs at the same time.

```swift
let gif = UIImage(gifName: "MyImage.gif", levelOfIntegrity:0.5)
```
####LoopCount
You can furthermore set a specific number of loops to your gif via `loopCount`. Default is `-1`, which translate to infinite.

```swift
self.myImageView.setGifImage(gif, manager: gifManager, loopCount:2)// The gif will loop 2 times
```

####Controls
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

####Delegate
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

    func gifDidStart() {
        print("gifDidStart")
    }
    
    func gifDidLoop() {
        print("gifDidLoop")
    }
    
    func gifDidStop() {
        print("gifDidStop")
    }
}
```

####Default Manager	
If you only need to display one gif here and there, you can use the `SwiftyGifManager.defaultManager` which will use a SwiftyGifManager singleton with a default memory pool of 50Mb. 

##Benchmark
####Display 1 Image
|               |CPU Usage(average) |Memory Usage(average) |
|:-------------:|:-----------------:|:-----------------------:|
|FLAnimatedImage|35%                |9,5Mb                    |
|SwiftyGif      |2%                 |18,4Mb                   |
|SwiftyGif(memoryLimit:10)|34%      |9,5Mb                    |

####Display 6 Images
|               |CPU Usage(average) |Memory Usage(average) |
|:-------------:|:-----------------:|:-----------------------:|
|FLAnimatedImage|65%                |25,1Mb                   |
|SwiftyGif      |22%                |105Mb                    |
|SwiftyGif(memoryLimit:20)|45%      |26Mb                     |

Measured on an iPhone 6S, iOS 9.3.1 and Xcode 7.3.

##Licence
SwiftyGif is released under the MIT license. See [LICENSE](https://github.com/kirualex/SwiftyGif/raw/master/LICENSE) for details.
