# OCIKeyboardAdjuster
OCIKeyboardAdjuster is a utility class written in Swift that maintains scroll views to automatically scroll and change content size when keyboard is present.
## Overview
* Adjust scroll views to keyboard appearance
* Follow the keyboard animation precisely
* No need to add/remove observers or write complex code.
* Supported classes:
  * `UITableView`
  * `UICollectionView`
  * `UIScrollView`
* Written in Swift 2.0(supports Swift 1.2 also)
## Usage
The most simple way to use is call following in your `viewDidLoad` method:
```
OCIKeyboardAdjuster.sharedKeyboardAdjuster.startObserving(scroll, holderView: self.view)
```
where `scroll` is your scroll view, and `self.view` is it's super view. The class uses `self.view` in order to get and covert `rect`'s in proper coordinate system.

If you have a view that need's to be focused when keyboard shows(for example some `UITextView`), you could mark it as focus *before* keyboard is shown:
```
OCIKeyboardAdjuster.sharedKeyboardAdjuster.focusedControl = myTextView
```
Depending on your requirements, setting focus control on `viewDidLoad` is perfectly valid case. No need to release this value.
## Installation
Simply drop OCIKeyboardAdjuster.swift file into your project
## Requirements
The project requires Swift 2.0, and although it is currently supporting Swift 1.2 also, this could change in future.
## License
OCIKeyboardAdjuster is released under an MIT license. See LICENSE for more information.
## Creator
Hristo Todorov
