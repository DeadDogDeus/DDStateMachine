//
//  StateMachine.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 8/26/18.
//

import Foundation
import ReactiveSwift
import Result

/**
 Loosely based interpretation of the old and well-known state machine.

 After the creation of StateMachine, it gives just a possibility to send an event for changing its current state and observe current state changes
 */
public class StateMachine<TState: Hashable, TEvent: Equatable, TExtendedState: ExtendedStateProtocol> {
  typealias TInternalState = InternalState<TState, TEvent, TExtendedState>

  private let executeScheduler: Scheduler
  private let stateScheduler: Scheduler

  /**
   Observable property for checking a current state of State Machine
   */
  public let currentState: Property<TState>
  private let mutableCurrentState: MutableProperty<TState>

  private var internalStates = [TState: TInternalState]()

  private var currentInternalState: TInternalState {
    didSet {
      self.mutableCurrentState.value = self.currentInternalState.state
    }
  }

  init(
    executeScheduler: Scheduler,
    stateScheduler: Scheduler,
    currentState: TState,
    internalStates: [TInternalState]) {
    self.executeScheduler = executeScheduler
    self.stateScheduler = stateScheduler

    self.mutableCurrentState = MutableProperty(currentState)
    self.currentState = Property(self.mutableCurrentState)

    self.internalStates = internalStates.toDictionary { $0.state }

    self.currentInternalState = self.internalStates[currentState]!
  }

  /**
   Method for executing a new even
   if this event can be handled by current status
   it will affect the status of State Machine
   - parameters:
   - event: Event for executing
   */
  public func execute(event: TEvent) -> SignalProducer<Void, NoError> {
    return SignalProducer { () -> Void in
      let stateSignalProducer  = self.currentInternalState.destinationState(by: event)
        .start(on: self.stateScheduler)

      _ = self.applyState(stateSignalProducer).flatMap(.latest, self.runState).start()
    }.start(on: self.executeScheduler)
  }

  private func runState() -> SignalProducer<Void, NoError> {
    let stateSignalProducer  = self.currentInternalState.run().start(on: self.stateScheduler)

    return self.applyState(stateSignalProducer).flatMap(.latest, self.runState)
  }

  private func applyState(
    _ stateSignalProducer: SignalProducer<TState?, NoError>) -> SignalProducer<Void, NoError> {
    return stateSignalProducer
      .observe(on: self.executeScheduler) // process on executeScheduler
      .filterMap { $0 } // remove nil values
      .map { self.internalStates[$0]! } // get internal state by state
      .filter { $0.state != self.currentInternalState.state } // skip internal state if its state is the same as current
      .on(value: { self.currentInternalState = $0 }) // set new current state
      .map { _ in () } // convert signal producer to SignalProducer<Void, NoError>
  }
}


