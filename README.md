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

## Translation Keys

```

[
"Initializing": "",
"TRACKING UNAVAILABLE": "",
"TRACKING NORMAL": "",
"TRACKING LIMITED\nExcessive motion": "",
"TRACKING LIMITED\nLow detail": "",
"Recovering from interruption": "",
"Unknown tracking state.": "",
"Try slowing down your movement, or reset the session.": "",
"Try pointing at a flat surface, or reset the session.": "",
"Return to the location where you left off or try resetting the session.": "",
"FIND A SURFACE TO PLACE AN OBJECT": "",
"TRY MOVING LEFT OR RIGHT": "",
"TAP + TO PLACE AN OBJECT": "",
"SURFACE DETECTED": "",
"CANNOT PLACE OBJECT\nTry moving left or right.": ""
]


```


## Settings

"url": "https://storage.googleapis.com/ar-answers-in-search-models/static/Tiger/model.glb",  // support be https or file scheme  
  
"format": "GLB",  // full options: ["GLB", "GLTF", "OBJ", "DAE", "ABC", "PLY", "STL", "USD", "USDZ", "USDA", "USDC", "SCN"]  
  
"max": 1,  // max size in all three dimensions in meters, models larger than this will be force resized to it.  
  
"gestures": ["scale": false, "rotate": true, "drag": true, "tap": true]  // enable or disable gestures in AR View  
  


