### v2.4.0
* [#46](https://github.com/chiunam/CTAssetsPickerController/issues/46) #46 Add navigationController property

### v2.3.1
* [#42](https://github.com/chiunam/CTAssetsPickerController/issues/42) #42 Fix errors of building in Xcode 6 beta
* Rename asset catalog to a more explicit one

### v2.3.0
* [#29](https://github.com/chiunam/CTAssetsPickerController/issues/29) Add "hold to preview" feature (Finally!)
* [#32](https://github.com/chiunam/CTAssetsPickerController/issues/32) Fix showing "No photos" view issue even there are photos in album
* [#35](https://github.com/chiunam/CTAssetsPickerController/issues/35) Fix showing supplementary view issue when there are no assets in the album
* [#38](https://github.com/chiunam/CTAssetsPickerController/issues/38) Add shouldShowAsset delegate method 
* [#39](https://github.com/chiunam/CTAssetsPickerController/issues/39) Add showsNumberOfAssets property
* [#40](https://github.com/chiunam/CTAssetsPickerController/issues/40) Change the picker to a container view controller rather than a navigation controller.
* [#41](https://github.com/chiunam/CTAssetsPickerController/issues/41) Add "show default content" feature
* Make assets group cell to opaque to increase scrolling performance
* Add accessibility label to the auxiliary view

### v2.2.2
* Fix issue of removing notifications from the same thread

### v2.2.1
* [#33](https://github.com/chiunam/CTAssetsPickerController/issues/33) Rectify the delegate method name `shouldEnableAsset` in the sample app and README.md

### v2.2.0
* [#30](https://github.com/chiunam/CTAssetsPickerController/issues/30) Refactor into separate files

### v2.1.0
* [#28](https://github.com/chiunam/CTAssetsPickerController/issues/28) Disable "Done" Button if no assets are selected
* Change "Done" Button style to `UIBarButtonItemStyleDone`


### v2.0.0
* Rename the delegate methods to more sensible one
* Replace certain properties with delegate methods in order to provide more flexibility
* Selected assets are preserved across albums
* Move title of selected assets to toolbar
* Show "no assets" view on empty albums
* Make "no assets" message to be more graceful, reflecting the device's model and camera feature
* Update padlock image to iOS 7 style
* Monitor ALAssetsLibraryChangedNotification and reload corresponding view controllers
* Use KVO to monitor the change of selected assets
* Add: Empty assets placeholder image
* Add: Selected assets property
* Add: Selected assets changed notification
* Add: Selection methods
* Add: iPad demo
* Add: Appledoc documentation
* Fix: Footer is not centre aligned after rotation
* Fix: Collection view layout issue on iPad landscape mode
* Fix: Collection view not scrolling to bottom on load
* Refactor certain methods
