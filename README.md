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

    a. Optionally add the TiltUpTest pod to your test target:

        ```ruby
        pod 'TiltUpTest'
        ```

3. Add & update the private pod repo, then install the pod:

```
bundle exec pod repo add clutter-specs git@github.com:clutter/Specs.git
bundle exec pod repo update clutter-specs
bundle exec pod install
```

## TiltUp Usage

### Architecture

TODO: Document Architecture components

## TiltUpTest Usage

## Assertions

#### <a name="assertCast"></a>assertCast(\_:as:)

`assertCast(_:as:)` asserts that it can cast the provided value to the provided
type using the [type cast operator `as?`][Type Casting]; it returns the cast
value if it succeeds and throws an
[`UnexpectedNilError`](#UnexpectedNilError) if it fails.

```swift
func testPresentedAlertControllerTitle() throws {
    let alertController = try assertCast(navigationController.presentedViewController, as: UIAlertController.self)
    XCTAssertEqual(alertController.title, "An error occurred")
}
```

`assertCast(_:as:)` is similar to [`assertType(of:is:)`](#assertType), but
`assertCast(_:as:)` returns the cast value or throws an error, while
`assertType(of:is:)` only asserts and does not return a value or throw.

Prefer `assertCast(_:as:)` over `as!`. `assertCast(_:as:)` ends the current test
method if it fails, but `as!` ends the entire test process if it fails.

**Preferred**:
```swift
let alertController = try assertCast(navigationController.presentedViewController, as: UIAlertController.self)
```

**Not preferred**:
```swift
let alertController = navigationController.presentedViewController as! UIAlertController.self
```

Prefer `assertCast(_:as:)` over [`assertUnwrap`](#assertUnwrap) and `as?`.
`assertCast(_:as:)` emits a more-helpful error message if it fails.

**Preferred**: 
```swift
let alertController = try assertCast(navigationController.presentedViewController, as: UIAlertController.self)
}
```

**Not preferred**:
```swift
let alertController = try assertUnwrap(navigationController.presentedViewController as? UIAlertController.self)
```

#### <a name="assertType"></a>assertType(of:is:) and assertType(of:isNot:)

`assertType(of:is:)` and `assertType(of:isNot)` assert that the provided value
is or is not of the provided type, respectively, using the
[type check operator `is`][Type Casting].

```swift
func testAlertControllerIsPresented() {
    assertType(of: navigationController.presentedViewController, is: UIAlertController.self)
    assertType(of: navigationController.presentedViewController, isNot: UINavigationController.self)
}
```

`assertType(of:is:)` is similar to [`assertCast(_:as:)`](#assertCast), but
`assertType(of:is:)` only asserts and does not return a value or throw, while
`assertCast(_:as:)` returns the cast value or throws an error.

#### assertUnwrap

`assertUnwrap` asserts that the provided `Optional` value is non-`nil`; it
returns the unwrapped value if it succeeds and throws an
[`UnexpectedNilError`](#UnexpectedNilError) if it fails.

```swift
func testItemID() throws {
    let item = try assertUnwrap(items.first)
    XCTAssertEqual(item.id, 42)
}
```

`assertUnwrap` is similar to [`XCTAssertNotNil`][XCTAssertNotNil], but
`assertUnwrap` returns the unwrapped value or throws an error, while
`XCTAssertNotNil` only asserts and does not return a value or throw.

`assertUnwrap` is functionally equivalent to [`XCTUnwrap`][XCTUnwrap],
introduced in Xcode 11 beta 7.

Prefer `assertUnwrap` over the forced unwrap operator `!`. `assertUnwrap` ends
the current test method if it fails, but `!` ends the entire test process if it
fails. For the same reason, prefer expressions like `assertUnwrap(array.first)`
over `array[0]`.

**Preferred**:
```swift
let item = try assertUnwrap(items.first)
```

**Not preferred**:
```swift
let item = items.first!
```

**Not preferred**:
```swift
let item = items[0]
```

#### assertTrue and assertFalse

`assertTrue` and `assertFalse` assert that the provided `Bool?` value is
`true` or `false`, respectively.

```swift
func testCanReceiveInWarehouse() {
    assertTrue(packedOrder.state?.canReceiveInWarehouse)
    assertFalse(canceledOrder.state?.canReceiveInWarehouse)
}
```

`assertTrue` and `assertFalse` are similar to [`XCTAssertTrue`][XCTAssertTrue]
and [`XCTAssertFalse`][XCTAssertFalse], respectively, but `assertTrue` and
`assertFalse` accept optional parameters, while `XCTAssertTrue` and
`XCTAssertFalse` require non-optional parameters.

Where possible, prefer `XCTAssertTrue` and `XCTAssertFalse` over `assertTrue`
and `assertFalse`.

**Preferred**:

```swift
XCTAssertTrue(nonOptionalTrue)
XCTAssertFalse(nonOptionalFalse)

assertTrue(optionalTrue)
assertFalse(optionalFalse)
```

**Not preferred**:

```swift
assertTrue(nonOptionalTrue)
assertFalse(nonOptionalFalse)
```

#### testUI

`testUI` takes two `() -> Void` closure parameters, `setup` and `assertions`; it
calls `setup`, waits for the main thread to run, and calls `assertions`.

`testUI` is useful for testing code that has to wait for the main thread to run
after triggering UIKit functionality without a callback.

```swift
func testTappingAnItem() {
    testUI(setup: {
        self.coordinator.tappedItem(at: 0)
    }, completion: {
        self.assertType(of: self.coordinator.router.navigationController.topViewController, is: ItemDetailsController.self)
    })
}
```

#### wait(for:)

`wait(for:)` is a convenience wrapper for
[`wait(for:timeout:)`][wait(for:timeout)] that uses a default `timeout` of `1.0`
seconds.

```swift
func testRefreshing() {
    let refreshed = expectation(description: "Refreshed items")
    viewModel.viewObservers.reloadData = refreshed.fulfill
    
    viewModel.refresh()
    
    wait(for: [refreshed])
    assertEqual(viewModel.sections.first?.count, 2)
}
```

## Errors

#### UnexpectedNilError

`UnexpectedNilError` represents the failure of an assertion that expected a
value but found `nil`. Initialize `UnexpectedNilError` by passing the expected
type, along with the file and line where the assertion failed.

Consumers of TiltUpTest will most commonly interact with `UnexpectedNilError`
through provided test assertions like [`assertUnwrap`](#assertUnwrap) and
[`assertCast(_:as:)`](#assertCast).

```swift
func requireNotNil<T>(_ value: T?, file: StaticString = #file, line: UInt = #line) throws {
    guard value != nil else {
        throw UnexpectedNilError(expectedType: T.self, file: file, line: line)
    }
}
```

## Releasing a New Version

See [iOS Wiki](https://github.com/clutter/iOS/wiki/Framework-Release-Process).
Make sure the TiltUp and TiltUpTest versions match.

## Author

Jeremy Grenier, jeremy.grenier@clutter.com

[Type Casting]: https://docs.swift.org/swift-book/LanguageGuide/TypeCasting.html
[UIView.animate]: https://developer.apple.com/documentation/uikit/uiview/1622515-animate
[wait(for:timeout)]: https://developer.apple.com/documentation/xctest/xctestcase/2806856-wait
[XCTAssertNotNil]: https://developer.apple.com/documentation/xctest/xctassertnotnil
[XCTUnwrap]: https://developer.apple.com/documentation/xcode_release_notes/xcode_11_beta_7_release_notes
[XCTAssertTrue]: https://developer.apple.com/documentation/xctest/xctasserttrue
[XCTAssertFalse]: https://developer.apple.com/documentation/xctest/xctassertfalse
