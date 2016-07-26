Pod::Spec.new do |spec|
  spec.name                  = 'CTAssetsPickerController'
  spec.version               = '3.3.2-alpha'
  spec.summary               = 'iOS control that allows picking multiple photos and videos from user\'s photo library.'

  spec.description           = <<-DESC
                               CTAssetsPickerController is an iOS controller that allows picking
                               multiple photos and videos from user's photo library.
                               The usage and look-and-feel just similar to UIImagePickerController.
                               It uses **ARC** and **Photos** frameworks.
                               DESC

  spec.homepage              = 'https://github.com/chiunam/CTAssetsPickerController'
  spec.screenshot            = 'https://raw.github.com/chiunam/CTAssetsPickerController/master/Screenshot.png'
  spec.license               = { :type => 'MIT', :file => 'LICENSE' }
  spec.author                = { 'Clement T' => 'chiunam@gmail.com' }
  spec.social_media_url      = 'https://twitter.com/chiunam'
  spec.platform              = :ios, '8.0'
  spec.ios.deployment_target = '8.0'
  spec.source                = { :git => 'https://github.com/chiunam/CTAssetsPickerController.git', :tag => 'v3.3.2-alpha' }
  spec.public_header_files   = 'CTAssetsPickerController/*.h'
  spec.source_files          = 'CTAssetsPickerController/**/*.{h,m}'
  spec.resource_bundles      = { 'CTAssetsPickerController' => ['CTAssetsPickerController/Resources/CTAssetsPicker.xcassets', 'CTAssetsPickerController/Resources/*.lproj'] }
  spec.ios.frameworks        = 'Photos'
  spec.requires_arc          = true
  spec.dependency            'PureLayout', '~> 3.0.0'
end
