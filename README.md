# DDStateMachine
Loosely based interpretation of the old and well-known state machine

![Abstract diagram](/Screenshots/Abstract%20diagram.png?raw=true)

# Introduction
This framework is an interpretation of UML state machine (https://en.wikipedia.org/wiki/UML_state_machine) and a finite automaton (https://en.wikipedia.org/wiki/Finite-state_machine).

There are main components of DDStateMachine:
* **StateMachineBuilder.** The state machine can be initialized just via StateMachineBuilder it provides a flexible interface for creating different sequences of states and relations between them.
* **StateBuilder.** The framework doesn't give access to State but it still needs to create it for describing relations and its action (work).
* **StateMachine.** After the creation of StateMachine, it gives just a possibility to send an event for changing its current state and observe current state changes.
* **Event.** Events are commands for manipulation of the state machine, developers can register StateMachine with Events which it would process (we recommend to use enums). If the current step can process this even it will toggle needed transition.
* **Transition.** Relations between states are called transitions, they can be registered during building the state machine.
* **Extra State.** Even the most simple systems have gazillions states which are hard for registering like independent states. In this case, we can use an extra state. It is a specific data class which can be attached to each state and be processing inside its work block.
* **Result Conditions.** Not only events can toggle transitions if a state does some work we can register result condition. In this case, we can use the result of the work for making a decision:  run or not a particular transition.
* **On Conditions.** We can register specific listeners on a particular state, they will be called when this state will be set, before running its work.
* **If Conditions.** We can extend transitions which will be called by specific event using If Conditions. In this case, even if StateMachine will get needed event it will need success result of the "If Condition". 

![Synchronizaton diagram](/Screenshots/Synchronizaton%20diagram.svg)

## Requirements

- iOS 10.3+
- Xcode 9.4+
- Swift 4.1+

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
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
