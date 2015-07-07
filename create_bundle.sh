#!/bin/sh

BUNDLE="CTAssetsPickerController/CTAssetsPickerController.bundle"

rm -rf $BUNDLE
mkdir $BUNDLE

find "CTAssetsPickerController/Resources" -name "*.png" | xargs -I {} cp {} "$BUNDLE/"
find "CTAssetsPickerController/Resources" -name "*.lproj" | xargs -I {} cp -R {} "$BUNDLE/"
echo "Created $BUNDLE"
