# DDStateMachine
State Machine for Swift.

Loosely based interpretation of the old and well-known state machine.

![Abstract diagram](/Screenshots/Abstract%20diagram.png?raw=true)

# Introduction
This framework is an interpretation of [UML state machine](https://en.wikipedia.org/wiki/UML_state_machine) and [a finite automaton](https://en.wikipedia.org/wiki/Finite-state_machine).

There are main components of DDStateMachine:
* **StateMachineBuilder.** State Machine can be initialized just via StateMachineBuilder it provides a flexible interface for creating different sequences of states and relations between them.
* **StateBuilder.** The framework doesn't give access to State but it still needs to create it for describing relations and its action (work).
* **StateMachine.** After the creation of State Machine, it gives a possibility to send an event for changing State Machine current state and observe current state changes.
* **Event.** Events are commands for manipulation of State Machine, developers can register State Machine with Events which State Machine would process (we recommend to use enums). If the current step can process this even it will toggle needed transition.
* **Transition.** Relations between states are called transitions, they can be registered during building of State Machine.
* **Extra State.** Even the most simple systems have many states which are hard for registering like independent states. In this case, we can use an extra state. It is a specific data class which can be attached to each state and be processed inside state's work block.
* **Result Conditions.** Not only events can toggle transitions if a state does some work we can register result condition. In this case, we can use the result of the work for making a decision:  run or not a particular transition.
* **On Conditions.** We can register specific listeners on a particular transition, they will be called when this transition ends, before running the second state's work.
* **If Conditions.** We can extend transitions which will be called by specific events using If Conditions. In this case, even if State Machine gets needed event it will need success result of the "If Condition".

# Example

Let's create a state machine for a synchronization process.
Our synchronization process contains the following states:
* **Not Synchronized**
* **In Progress**
* **Synchronized**
* **Failed**

In this case, the state machine will process just a one external event "sync", moreover for preventing frequent calls of the synchronization work we introduce 30 seconds cache lifetime before we can transit from Synced to In Progress.

Here is a diagram:

![Synchronizaton diagram](/Screenshots/Synchronizaton%20diagram.svg)

In code it will look like:

**Data Structures**
```swift
enum SyncStatus: Int, Hashable {
  case notSynced
  case inProgress
  case synced
  case failed
}

enum SyncEvent {
  case sync
}

class SyncExtraState: ExtraStateProtocol {
  var expiryDate: Date?
  
  required init() {
  }
}
```

**State machine properties**
```swift
  private var stateMachine: StateMachine<SyncStatus, SyncEvent>?

  // This property will be used for observing
  var currentStatus: Property<SyncStatus> {
    return self.stateMachine!.currentStatus
  }
```
**Describing state machine**
```swift
// Scheduler will be used for running states' works
let builder = StateMachineBuilder<SyncStatus, SyncEvent, SyncExtraState>(scheduler: QueueScheduler())

let notSynced: StateBuilder<SyncStatus, SyncEvent, SyncExtraState> = StateBuilder(.notSynced)
let synced: StateBuilder<SyncStatus, SyncEvent, SyncExtraState> = StateBuilder(.synced)
let failed: StateBuilder<SyncStatus, SyncEvent, SyncExtraState> = StateBuilder(.failed)

// For describing states with "Work" we need to use a special type of StateBuilder - WorkStateBuilder.
let inProgress: WorkStateBuilder<SyncStatus, SyncEvent, SyncExtraState, ResultDomainModel<Void>> =
  WorkStateBuilder(.inProgress, work: self.doSync)
 
// If the state machine is in Not Synced state and gets the event "sync"
// it will transit to In Progress state immediately.
builder.shouldTransit(notSynced ~> inProgress).by(event: .sync).immediately()
 
// If the state machine is in In Progress state and In Progress work returns true
// the state machine will transit to Synced state immediately.
// After the transition it will call "on" condition for synced State (It sets SyncExtraState->expiryDate to now + 30 seconds).
builder.shouldTransit(inProgress ~> synced)
  .on { $0.expiryDate = Date() + 10.seconds }
  .ifResult { (result, _) in result }
 
// If the state machine is in In Progress state and In Progress work returns false
// the state machine will transit to Failed state immediately.
builder.shouldTransit(inProgress ~> failed).ifResult { (result, _) in !result }
 
// If the state machine is in Synced state and gets the event "sync" and if cache has expired
// then if all conditions fulfilled it will transit to In Progress state immediately.
builder.shouldTransit(synced ~> inProgress)
  .by(event: .sync)
  .ifCondition { $0.expiryDate == nil || $0.expiryDate! < Date() }
 
// If the state machine is in Failed state and gets the event "sync"
// it will transit to In Progress state immediately.
builder.shouldTransit(failed ~> inProgress).by(event: .sync).immediately()
 
// Create the state machine with initial state Not Synced
self.stateMachine = builder.build(initialState: notSynced)
```

**Sync work method**
```swift
  func doSync() -> SignalProducer<Bool, NoError> {
    // Write some sycnronization code
  }
```

**Setting "Sync" event**
```swift
  func sync() {
    self.stateMachine?.execute(event: .sync)
  }
```

This example uses [SwiftDate](https://github.com/malcommac/SwiftDate) for working with dates and [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift) for scheduling.

## Known peculiarities

Here is a list of some know problems of this SDK (see Unit Tests for extra details)

- if the initial state is a work-state, the state machine will not run its work.
- If the state machine is acyclic and the last state has a work, the state machine will not run its work.

## Requirements

- iOS 10.3+
- Xcode 9.4+
- Swift 4.1+

## Installation

### CocoaPods

If you use CocoaPods to manage your dependencies, simply add DDStateMachine to your Podfile:

```bash
 pod 'DDStateMachine', '~> 1.0'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](https://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate DDStateMachine into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "DeadDogDeus/DDStateMachine" ~> 1.0
```

Run `carthage update` to build the framework and drag the built `DDStateMachine.framework` into your Xcode project.
