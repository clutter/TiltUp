//
//  Observables.swift
//  TiltUp
//
//  Created by Michael Mattson on 9/23/19.
//

import Foundation

public class Observable<Observed> {
    public typealias Observer = (_ oldValue: Observed, _ newValue: Observed) -> Void
    private var observers: [UUID: (DispatchQueue, Observer)] = [:]

    public var value: Observed {
        didSet {
            notifyObservers(oldValue: oldValue, newValue: value)
        }
    }

    public init(value: Observed) {
        self.value = value
    }

    /**
     Adds an observer to be notified on the given queue when the receiver’s observed condition is met. Returns a
     `Disposable` that removes the observer upon deallocation.

     - parameter observingCurrentValue: If true, observe the value at the time `addObserver` is called.
     - parameter queue: The dispatch queue on which to notify the observer. Defaults to `DispatchQueue.main`.
     - parameter observer: The observer to be updated when the value changes.
     - returns: A `Disposable` that must be retained until you want to stop observing. Release the `Disposable` to
     remove the observer.
     */
    func addObserver(observingCurrentValue: Bool, on queue: DispatchQueue = .main, observer: @escaping Observer) -> Disposable {
        let uuid = UUID()
        observers[uuid] = (queue, observer)

        if observingCurrentValue {
            let observedValue = value
            queue.async {
                observer(observedValue, observedValue)
            }
        }

        return Disposable { [weak self] in
            self?.observers[uuid] = nil
        }
    }

    /**
     Calls each of the receiver’s `observers` with `oldValue` and `newValue` as arguments. Each observer is called on the
     queue specified upon registration with `Observable.addObserver(on:observer:)`.

     - parameter oldValue: The observed old value of which to notify each observer.
     - parameter newValue: The observed new value of which to notify each observer.
     */
    private func notifyObservers(oldValue: Observed, newValue: Observed) {
        observers.values.forEach { queue, observer in
            queue.async {
                observer(oldValue, newValue)
            }
        }
    }
}

public class ObserverList<Observed> {
    public typealias Observer = (Observed) -> Void
    fileprivate var observers: [UUID: (DispatchQueue, Observer)] = [:]

    /**
     Adds an observer to be notified on the given queue when the receiver’s observed condition is met. Returns a
     `Disposable` that removes the observer upon deallocation.

     - parameter queue: The dispatch queue on which to notify the observer. Defaults to `DispatchQueue.main`.
     - parameter observer: The observer to be notified when the observed condition is met.
     - returns: A `Disposable` that must be retained until you want to stop observing. Release the `Disposable` to
     remove the observer.
     */
    public func addObserver(on queue: DispatchQueue = .main, observer: @escaping Observer) -> Disposable {
        let uuid = UUID()
        observers[uuid] = (queue, observer)
        return Disposable { [weak self] in
            self?.observers[uuid] = nil
        }
    }
}

public class ObserverNotifier<Observed> {
    let observerList = ObserverList<Observed>()

    /**
     Calls each observer in the receiver’s `observerList` with `observed` as an argument. Each observer is called on the
     queue specified upon registration with `ObserverList.addObserver(on:observer:)`.

     - parameter observed: The observed value of which to notify each observer.
     */
    public func notifyObservers(of observed: Observed) {
        self.observerList.observers.values.forEach { queue, observer in
            queue.async {
                observer(observed)
            }
        }
    }
}

public extension ObserverNotifier where Observed == Void {
    func notifyObservers() {
        notifyObservers(of: ())
    }
}
