# TiltUp

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installing

TiltUp is available via Clutter's private CocoaPods repo. To include it in your project you will need to add a few lines to your `Podfile`:

1. Include the `clutter/Specs` repo as one of your pod sources:

```ruby
source 'git@github.com:clutter/Specs.git'
```

2. Add the TiltUp pod:

```ruby
pod 'TiltUp'
```

3. Add & update the private pod repo, then install the pod:

```
bundle exec pod repo add clutter-specs git@github.com:clutter/Specs.git
bundle exec pod repo update clutter-specs
bundle exec pod install
```

## Releasing a New Version

See [iOS Wiki](https://github.com/clutter/iOS/wiki/Framework-Release-Process)

## Author

Jeremy Grenier, jeremy.grenier@clutter.com
