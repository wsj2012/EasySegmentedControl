EasySegmentedControl
===

Thanks for the author of HMSegmentedControl(oc version).  
This is swift version of HMSegmentedControl.  
A drop-in replacement for UISegmentedControl mimicking the style of the segmented control used in Google Currents and various other Google products.

# Features
- Supports both text and images
- Support horizontal scrolling
- Supports advanced title styling with text attributes for font, color, kerning, shadow, etc.
- Supports selection indicator both on top and bottom
- Supports blocks
- Works with ARC and iOS >= 9

# Installation

### CocoaPods
The easiest way of installing EasySegmentedControl is via [CocoaPods](http://cocoapods.org/). 

```
pod 'EasySegmentedControl'
```

### Old-fashioned way

- Add `EasySegmentedControl.swift` to your project.
- Add `QuartzCore.framework` to your linked frameworks.

# Usage

The code below will create a segmented control with the default looks:

```  swift
     	let viewWidth = view.frame.size.width
        let sc = EasySegmentedControl.init(with: ["Trending", "News", "Library"])
        sc.frame = CGRect(x: 0, y: 88, width: viewWidth, height: 40)
        sc.autoresizingMask = [.flexibleRightMargin, .flexibleWidth]
        sc.backgroundsColor = UIColor.clear
        sc.addTarget(self, action: #selector(segmentedControlChangedValue(segmentedControl:)), for: .valueChanged)
        view.addSubview(sc)
```

Included is a demo project showing how to fully customise the control.

![EasySegmentedControl](https://github.com/wsj2012/EasySegmentedControl/blob/master/ScreenShot.png?raw=true)

# Apps using EasySegmentedControl

If you are using EasySegmentedControl in your app or know of an app that uses it, please add it to [this list](https://github.com/wsj2012/EasySegmentedControl/wiki).
  

# License

EasySegmentedControl is licensed under the terms of the MIT License. Please see the [LICENSE](LICENSE.md) file for full details.

If this code was helpful, I would love to hear from you.
