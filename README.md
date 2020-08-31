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
pod "ARQuickLook"
```

## Author

lapbay, lapbay@gmail.com

## License

ARQuickLook is available under the MIT license. See the LICENSE file for more info.

## Usage

### Add privacy usage declaration in Info.plist in Xcode project

<key>NSCameraUsageDescription</key>
<string>The camera is used for augmenting reality.</string>


### Swift
```
import ARQuickLook

let translations: Dictionary<String, String> = [
"Initializing": "Inicializando",
]
let settings: Dictionary<String, Any> = [
    "max": 1,
    "scale": 0.1,
    "lighting": false,
    "gestures": ["scale": true, "rotate": false, "drag": true, "tap": false]
]
let models: Array<Dictionary<String, String>> = [[
    "m": "https://storage.googleapis.com/ar-answers-in-search-models/static/Tiger/model.glb",
    "tn": "https://storage.googleapis.com/support-forums-api/attachment/thread-36849721-3973664935013022854.png",
    "t": "google tiger",
]]
let controller = ARQuickLookController(models: models, settings: args)
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
        @"max": @1,
        @"scale": @1,
        @"lighting": @true,
        @"gestures": @{@"scale": @true, @"rotate": @false, @"drag": @true, @"tap": @false}
};
NSDictionary *models = @{
        @"m": @"https://storage.googleapis.com/ar-answers-in-search-models/static/Tiger/model.glb",
        @"tn": @"https://storage.googleapis.com/support-forums-api/attachment/thread-36849721-3973664935013022854.png",
        @"t": @"google tiger"
};
ARQuickLookController *controller = [[ARQuickLookController alloc] initWithModels: models settings: settings translations: translations onPrepared: nil];
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

## Models fields

"m": "https://storage.googleapis.com/ar-answers-in-search-models/static/Tiger/model.glb",  // required model url, support  https or file scheme , file format full options: ["GLB", "GLTF", "OBJ", "DAE", "ABC", "PLY", "STL", "USD", "USDZ", "USDA", "USDC", "SCN"]

"tn": "https://storage.googleapis.com/ar-answers-in-search-models/static/Tiger/model.glb",  // optional model thumbnail url.  

"t": "model title",  // optional model title.  


## Settings

"max": 1,  // max size in all three dimensions in meters, models larger than this will be force resized to it.  

"scale": 1,  // scale the object on loaded.  
  
"lighting": true,  // set default lighting in AR scene or not.  

"gestures": ["scale": false, "rotate": true, "drag": true, "tap": true]  // enable or disable gestures in AR View  
  


