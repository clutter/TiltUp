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

    1. Optionally add the TiltUpTest pod to your test target:

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

![architecture](https://user-images.githubusercontent.com/73529/137216479-d053fd5b-090d-475a-a8fe-e885a4fc51dc.png)

#### Coordinators

The `Coordinator` is responsible for handling the navigation logic of the app. It should have methods that allow it to create and start new coordinators as the user moves to new screens.

Each `Coordinator` has a access to an `AppCoordinator`, which retains the coordinator until it is no longer needed (usually, when its associated view controller is popped or dismissed)

Coordinators usually have the following basic structure:

```swift
final class ExampleCoordinator: Coordinator {
  private let viewModel: ExampleViewModel

  init(parent: Coordinating) {
    viewModel = ExampleViewModel()
    super.init(parent: parent, modal: false)
  }
  
  func start() {
    goToExample()
  }
  
  func goToExample() {
    let controller = ExampleController.make()
    controller.viewModel = viewModel
    
    viewModel.coordinatorObservers.goToAnotherScreen = { [weak self] in
      self?.goToAnotherScreen()
    }
    
    router.push(controller, retaining: self)
  }
  
  func goToAnotherScreen() {
    let coordinator = AnotherScreenCoordinator(parent: self)
    coordinator.start()
  }
}
```

#### Routers

`Router` helps you deallocate your coordinators. It exposes methods for pushing, popping, presenting, and dismissing view controllers, and provides completion handlers that trigger when a view controller is popped.

The most important use case for a router is to retain your coordinator on push via `router.push(controller, retaining: coordinator)`

##### Presenting and dismissing modals

Using a router to present a modal view controller is easy. If you want to
present an alert controller, or any other modal view controller that doesn’t
have its own coordinator or router, use `router.presentModal(viewController)`:

```swift
let viewController = SomeViewController(/* ... */)
router.presentModal(viewController)
```

If the modal you want to present does have its own coordinator and router, use
`parentRouter.presentModal(modalRouter)` instead:

```swift
class FooCoordinator: Coordinator {
  init(parent: Coordinating) {
    super.init(parent: parent, modal: false)
  }
  
  func start() {
    goToFoo()
  }
  
  func goToFoo() {
    let controller = FooController.make()
    let viewModel = FooViewModel()
    controller.viewModel = viewModel
    
    viewModel.coordinatorObservers.goToModalScreen = { [weak self] in 
      self?.goToModalScreen()
    }
    
    router.push(controller, retaining: self)
  }
  
  func goToModalScreen() {
    let modalScreenCoordinator = ModalScreenCoordinator(parent: self)
    modalScreenCoordinator.start()
  }
}

class ModalScreenCoordinator: Coordinator {
  init(parent: Coordinating) {
    super.init(parent: parent, modal: true)
  }
  
  func start() {
    goToModalScreen()
  }
  
  func goToModalScreen() {
    let controller = ModalScreenController.make()
    let viewModel = ModalScreenViewModel()
    controller.viewModel = viewModel
    
    router.push(controller)
    parent?.router.presentModal(router)
  }
}
```

To dismiss a modal, call `router.dismissModal()`. If you need execute code after the modal has been dismissed, you can pass in a `dismissHandler`:

```swift
router.dismissModal(dismissHandler: { [weak self] in
    // Take some action
})
```
Note: If you pass in a coordinator via the `retaining` parameter, that coordinator will automatically be popped when the modal is dismissed.

#### ViewModels

View models are meant to hold and organize data for populating the View Controller. They also act as an in-between for passing actions from the `ViewController` to the `Coordinator`

A standard `ViewModel` will have 2 sets of observers, `CoordinatorObservers` and `ViewObservers`.

The `CoordinatorObservers` are used to interact with the `Coordinator`, these are typically used to trigger starting a new `Coordinator` and pushing on a new view.

The `ViewObservers` are used to update the views that are being displayed by the `ViewController`. An example might be that a button can be enabled / disabled based on some business logic in the `ViewModel`, which would be communicated to the controller via the `ViewObserver`

You can read more about [ViewObservers below](#ViewObserver Protocols)

A rough example of the ViewModel can be found below:

```swift
enum Example {
    final class CoordinatorObservers {
        var goToAnotherScreen: (() -> Void)?
    }

    final class ViewObservers {
        var updateButton: ((_ isEnabled: Bool) -> Void)?
    }
}

final class ExampleViewModel {
    // MARK: Observers
    var coordinatorObservers = Example.CoordinatorObservers()
    var viewObservers = Example.ViewObservers()
    
    // MARK: Attributes
    var buttonIsEnabled: Bool {
      didSet { 
        viewObservers.updateButton?(newValue)
      }
    }

    init() {
        // Any initial setup
    }

    func start() {
        // Setup that should be called once the ExampleController has loaded
    }

    func anotherScreenButtonTapped() {
        coordinatorObservers.goToAnotherScreen?()
    }
}

```

#### Controllers

Fairly standard `ViewController`. All `Controllers` should have their own `Storyboard` and should be subclasses of the `StoryboardViewController`

```swift
final class ExampleController: StoryboardViewController {
    var viewModel: ExampleViewModel!
    
    @IBOutlet weak var actionButton: Button!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.viewObservers.updateButton = { [weak self] isEnabled in 
          self?.actionButton.isEnabled = isEnabled
        }

        viewModel.start()
    }

    // MARK: - Actions

    @IBAction func submitAction(_ sender: Any) {
        viewModel.anotherScreenButtonTapped()
    }}
}
```


### Utilities

#### Sum Helpers

Any sequence can use the `sum` function, which takes a closure. The function applies 
the given closure to each element of the sequence, adds the transformed elements together, 
and returns the result. If the sequence is empty, the result is `.zero`.

If the sequence conforms to `AdditiveArithmetic`, the `sum` function can be used without passing
a closure. It adds the sequence's elements together and returns the result. If the sequence is empty, 
the result is `.zero`.

Some examples of these helpeprs being used are below.

```swift
    func testSum() {
        let numbers = [1, -2, 3, -4]
        XCTAssertEqual(numbers.sum(), -2)
    }

    func testSumWithTransformClosure() {
        let numbers = [1.1, 3.3, 5.5, 7.7, 9.9]
        XCTAssertEqual(numbers.sum { $0.rounded() }, 28.0, accuracy: 0.001)
    }

    func testSumWithTransformKeyPath() {
        let strings = ["aleph", "omega", "double-yoo"]
        XCTAssertEqual(strings.sum(\.count.description.count), 4)
    }
 ```

## TiltUpTest Usage

### Assertions

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

### ViewObserver Protocols

There are multiple protocols provided for common view observers use-cases.

```swift
public typealias BaseViewObserving = LoadingStateObserving & PresentAlertObserving
public typealias BaseTableViewObserving = BaseViewObserving & ReloadDataObserving

public protocol ReloadDataObserving {
    var reloadData: (() -> Void)? { get set }
}

public protocol LoadingStateObserving {
    var loadingState: ((LoadingState) -> Void)? { get set }
}

public protocol PresentAlertObserving {
    var presentAlert: ((UIAlertController) -> Void)? { get set }
}

public enum LoadingState {
    case notLoading
    case loading(String = "Loading")
}
```

An example of this being used would look like:

```swift
final class ExampleViewObservers: BaseTableViewObservers {} 

final class ExampleViewModel {
  let viewObservers = ExampleViewObservers()
  ...
}

final class ExampleController: UIViewController {
    let viewModel: ExampleViewModel!

    ...

    func setUpObservers() {
        viewModel.viewObservers.loadingState = { [weak self] loadingState in
            ...
        }

        viewModel.viewObservers.presentAlert = { [weak self] alert in
            ...
        }

        viewModel.viewObservers.reloadData = { [weak self] in
            ...
        }
    }
}
```
#### waitForBaseTableViewObservers(...)

`waitForBaseTableViewObservers(
  _ viewObservers: BaseTableViewObserving, 
  expectationTypes: [BaseTableViewObservers.ExpectationType], 
  triggeringAction: (() -> Void)
)` is an extension on `XCTestCase`  to help check common view observer expectations.

Within your tests, you can test that a triggering action calls the
corresponding view observers. 

The available `ExpectationTypes` are as follows:

```swift
extension BaseTableViewObservers {
    public enum ExpectationType {
        case presentAlert
        case loadingCycle
        case reloadData
    }
}
```
`loadingCycle` expects two calls to `viewObservers.loadingState` , one `loading` and one `notLoading`. The other expectation types expect a single call.

The tested view observer callbacks are reset to `nil` at the end.

An example of this being used would look like:

```swift
func testRefreshSuccceeds() {
    ...

    waitForBaseTableViewObservers(
        viewModel.viewObservers,
        expectationTypes: [.loadingCycle, .reloadData],
        triggeringAction: viewModel.refresh
    )
}

func testUpdateFails() {
    ...

    waitForBaseTableViewObservers(
        viewModel.viewObservers,
        expectationTypes: [.loadingCycle, .presentAlert],
        triggeringAction: { viewModel.update(...) }
    )
}
```
#### waitForBaseViewObservers(...)

`waitForBaseViewObservers(
  _ viewObservers: BaseViewObserving, 
  expectationTypes: [BaseViewObservers.ExpectationType], 
  triggeringAction: (() -> Void)
)` is an extension on `XCTestCase`  to help check common view observer expectations.

It behaves identically to `waitForBaseTableViewObservers`, but has only the following
available `ExpectationTypes` :

```swift
extension BaseTableViewObservers {
    public enum ExpectationType {
        case presentAlert
        case loadingCycle
    }
}
```

### WaitableCoordinatorTest

An `XCTestCase` can conform to `WaitableCoordinatorTest` to gain
access to some useful helpers around testing view controller changes.

There are four helpers:

`waitForTopViewControllerChange<T: Coordinator>(using coordinator: T, work: () -> Void)`
`waitForPresentedViewControllerChange<T: Coordinator>(using coordinator: T, work: () -> Void)`
`waitForTopViewControllerChange(in router: Router, work: () -> Void)`
`waitForPresentedViewControllerChange(in router: Router, work: () -> Void)`

These helpers execute the `work` and wait for either the presented or top
view controller of the coordinator's route to change.

Some examples of these being used would look like:

```swift
final class ExampleCoordinatorTests: XCTestCase, WaitableCoordinatorTest {
    ...

    func testGoToReview() throws {
        ...

        waitForTopViewControllerChange(using: coordinator) {
            coordinator.goToReview()
        }

        assertType(of: coordinator.router.navigationController.topViewController, is: ReviewController.self)
    }

    func testGoToCamera() throws {
        ...

        waitForPresentedViewControllerChange(using: coordinator) {
            coordinator.goToCamera()
        }

        let presentedNavigationController = try assertUnwrap(
            coordinator.router.navigationController.presentedViewController as? UINavigationController
        )
        assertType(of: presentedNavigationController.topViewController, is: CameraController.self)
    }

    func testGoToNotes() throws {
        ...

        waitForTopViewControllerChange(in: coordinator.router) {
            coordinator.goToNotes()
        }

        assertType(of: coordinator.router.navigationController.topViewController, is: NotesController.self)
    }

    func testGoToAlert() throws {
        ...

        waitForPresentedViewControllerChange(in: coordinator.router) {
            coordinator.goToAlert()
        }

        let presentedNavigationController = try assertUnwrap(
            coordinator.router.navigationController.presentedViewController as? UINavigationController
        )
        assertType(of: presentedNavigationController.topViewController, is: AlertController.self)
    }
}
```

### Errors

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

## Author

Clutter Engineering Team, tech@clutter.com

[Type Casting]: https://docs.swift.org/swift-book/LanguageGuide/TypeCasting.html
[wait(for:timeout)]: https://developer.apple.com/documentation/xctest/xctestcase/2806856-wait
[XCTAssertNotNil]: https://developer.apple.com/documentation/xctest/xctassertnotnil
[XCTUnwrap]: https://developer.apple.com/documentation/xcode_release_notes/xcode_11_beta_7_release_notes
[XCTAssertTrue]: https://developer.apple.com/documentation/xctest/xctasserttrue
[XCTAssertFalse]: https://developer.apple.com/documentation/xctest/xctassertfalse
