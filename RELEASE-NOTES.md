### v2.9.2
* [#89](https://github.com/chiunam/CTAssetsPickerController/issues/89) Add Finnish language support
* [#90](https://github.com/chiunam/CTAssetsPickerController/issues/90) Remove deprication warrnings for iOS 8
* [#87](https://github.com/chiunam/CTAssetsPickerController/issues/87) Fix: Missing padlock image
* [#91](https://github.com/chiunam/CTAssetsPickerController/issues/91) Fix: Wrong view position when in-call / tethering status bar is shown

### v2.9.1
* [#85](https://github.com/chiunam/CTAssetsPickerController/issues/85) Fix: No "swipe to go back" gesture

### v2.9.0
* [#64](https://github.com/chiunam/CTAssetsPickerController/issues/64) Put resources into a bundle

### v2.8.1
* [#81](https://github.com/chiunam/CTAssetsPickerController/issues/81) Fix: Update `collectionView` after calling `de/selectAsset` methods.
* [#77](https://github.com/chiunam/CTAssetsPickerController/issues/77) Fix: When assets group changed, the asset filter is not re-applied
* [#83](https://github.com/chiunam/CTAssetsPickerController/issues/83) Better Japanese translation of "Done"
* [#76](https://github.com/chiunam/CTAssetsPickerController/issues/76) Add Danish localisation
* [#74](https://github.com/chiunam/CTAssetsPickerController/issues/74) Add Japanese, Korean, Simplified Chinese, Indonesian, Italian, Russian localisations
* [#73](https://github.com/chiunam/CTAssetsPickerController/issues/73) Add German localisation
* [#72](https://github.com/chiunam/CTAssetsPickerController/issues/72) Add French localisation

### v2.8.0
* [#63](https://github.com/chiunam/CTAssetsPickerController/issues/63) Add translations for pt, pt-PT and es-MX
* [#59](https://github.com/chiunam/CTAssetsPickerController/issues/59) Add `alwaysEnableDoneButton` property to allow enabling done button even without assets selected

### v2.7.0
* [#57](https://github.com/chiunam/CTAssetsPickerController/issues/57) Make the picker's toolbar to conform UIApperance so that it can be overridden
* [#56](https://github.com/chiunam/CTAssetsPickerController/issues/56) Move the localisable string to separated string table


### v2.6.1
* [#55](https://github.com/chiunam/CTAssetsPickerController/issues/55) Fix: Pictures disappear until you do scrolling gesture when you take screenshot

### v2.6.0
* Fix: Footer of collection view is not horizontally centered in iOS 8
* Add: Support iPhone 6 and iPhone 6 Plus native view
* [#52](https://github.com/chiunam/CTAssetsPickerController/issues/52) Extracted Navigation Controller creation to a separate method
* Rename property `navigationController` to `childNavigatonController`

### v2.5.0
* [#49](https://github.com/chiunam/CTAssetsPickerController/issues/49) Share AssetLibrary with user

### v2.4.0
* [#46](https://github.com/chiunam/CTAssetsPickerController/issues/46) Add navigationController property

### v2.3.1
* [#42](https://github.com/chiunam/CTAssetsPickerController/issues/42) Fix errors of building in Xcode 6 beta
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
