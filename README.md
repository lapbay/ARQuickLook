# ARQuickLook

[![CI Status](https://img.shields.io/travis/lapbay/ARQuickLook.svg?style=flat)](https://travis-ci.org/lapbay/ARQuickLook)
[![Version](https://img.shields.io/cocoapods/v/ARQuickLook.svg?style=flat)](https://cocoapods.org/pods/ARQuickLook)
[![License](https://img.shields.io/cocoapods/l/ARQuickLook.svg?style=flat)](https://cocoapods.org/pods/ARQuickLook)
[![Platform](https://img.shields.io/cocoapods/p/ARQuickLook.svg?style=flat)](https://cocoapods.org/pods/ARQuickLook)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements


## Installation

ARQuickLook is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ARQuickLook'
```

## Author

lapbay, lapbay@gmail.com

## License

ARQuickLook is available under the MIT license. See the LICENSE file for more info.

## Usage

### Swift
```
import ARQuickLook

let translations: Dictionary<String, String> = [
"Initializing": "Inicializando",
]
let settings: Dictionary<String, Any> = [
    "url": "https://storage.googleapis.com/ar-answers-in-search-models/static/Tiger/model.glb",
    "format": "GLB",
    "max": 1,
    "gestures": ["scale": true, "rotate": false, "drag": true, "tap": false]
]
let controller = ARQuickLookController(settings: settings)
controller.translations = translations
controller.launchAR(self) {
    print("presented")
}

```

### Objective-C
```
@import ARQuickLook;

NSDictionary *translations = @{@"Initializing": @"Inicializando"};
NSDictionary *settings = @{
        @"url": @"https://storage.googleapis.com/ar-answers-in-search-models/static/Tiger/model.glb",
        @"format": @"GLB",
        @"max": @1,
        @"gestures": @{@"scale": @true, @"rotate": @false, @"drag": @true, @"tap": @false}
};
ARQuickLookController *controller = [[ARQuickLookController alloc] initWithSettings: settings translations: translations onPrepared: nil];
[controller launchAR: self completion: nil];


```
