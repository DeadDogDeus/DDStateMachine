//
//  StateMachine.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 8/26/18.
//

import Foundation
import ReactiveSwift
import Result

class StateMachine<TStatus: Hashable, TEvent: Equatable, TExtraState: ExtraStateProtocol> {
  typealias TState = State<TStatus, TEvent, TExtraState>

  private let scheduler: Scheduler

  let currentStatus: Property<TStatus>
  private let mutableCurrentStatus: MutableProperty<TStatus>

  private var states = [TStatus: TState]()

  private var currentState: TState {
    didSet {
      self.mutableCurrentStatus.value = self.currentState.status
    }
  }

  init(scheduler: Scheduler, currentStatus: TStatus, states: [TState]) {
    self.scheduler = scheduler

    self.mutableCurrentStatus = MutableProperty(currentStatus)
    self.currentStatus = Property(self.mutableCurrentStatus)

    for state in states {
      self.states[state.status] = state
    }

    self.currentState = self.states[currentStatus]!
  }

  func execute(event: TEvent) {
    let stateSignalProducer  = self.currentState.execute(event)

    _ = self.applyState(stateSignalProducer)
      .flatMap(.latest, self.executeInstantStateUpdate)
      .start(on: self.scheduler).start()
  }

  private func executeInstantStateUpdate() -> SignalProducer<Void, NoError> {
    let stateSignalProducer  = self.currentState.instantNextStatus()

    return self.applyState(stateSignalProducer).flatMap(.latest, self.executeInstantStateUpdate)
  }

  private func applyState(
    _ stateSignalProducer: SignalProducer<TStatus, NoError>) -> SignalProducer<Void, NoError> {
    return stateSignalProducer
      .map { self.states[$0]! }
      .filter { $0.status != self.currentState.status }
      .on(value: { self.currentState = $0 })
      .map { _ in () }
  }
}

