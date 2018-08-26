//
//  StateMachineBuilder.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 8/26/18.
//

import Foundation
import ReactiveSwift
import Result

public class ConditionBuilder<TStatus: Hashable, TEvent, TExtraState, TState: StateBuilder<TStatus, TEvent, TExtraState>> {
  func immediately() {
    fatalError()
  }

  func ifCondition(_ condition: @escaping (TExtraState) -> Bool) {
    fatalError()
  }
}

public class EventBuilder<TStatus: Hashable, TEvent, TExtraState, TState: StateBuilder<TStatus, TEvent, TExtraState>> {
  func by(event: TEvent)
    -> ConditionBuilder<TStatus, TEvent, TExtraState, StateBuilder<TStatus, TEvent, TExtraState>> {
      fatalError()
  }

  func on(_ editExtraState: @escaping (TExtraState) -> Void)
    -> EventBuilder<TStatus, TEvent, TExtraState, TState> {
      fatalError()
  }
}

public class WorkEventBuilder<
  TStatus: Hashable,
  TEvent,
  TExtraState,
  TWorkResult,
  TState: WorkStateBuilder<TStatus, TEvent, TExtraState, TWorkResult>>
: EventBuilder<TStatus, TEvent, TExtraState, TState> {
  func ifResult(_ result: @escaping (TWorkResult) -> Bool) {
    fatalError()
  }
}

public class StateMachineBuilder<TStatus: Hashable, TEvent, TExtraState> {
  private let scheduler: Scheduler

  init(scheduler: Scheduler) {
    self.scheduler = scheduler
  }

  func shouldTransit(
    _ direction: StateDirection<
    TStatus,
    TEvent,
    TExtraState,
    StateBuilder<TStatus, TEvent, TExtraState>,
    StateBuilder<TStatus, TEvent, TExtraState>>)
    -> EventBuilder<TStatus, TEvent, TExtraState, StateBuilder<TStatus, TEvent, TExtraState>> {
      fatalError()
  }

  func shouldTransit<TWorkResult>(
    _ direction: StateDirection<
    TStatus,
    TEvent,
    TExtraState,
    WorkStateBuilder<TStatus, TEvent, TExtraState, TWorkResult>,
    StateBuilder<TStatus, TEvent, TExtraState>>)
    -> WorkEventBuilder<
    TStatus,
    TEvent,
    TExtraState,
    TWorkResult,
    WorkStateBuilder<TStatus, TEvent, TExtraState, TWorkResult>> {
      fatalError()
  }

  func build(initialState: StateBuilder<TStatus, TEvent, TExtraState>) -> StateMachine<TStatus, TEvent> {
    fatalError()
  }
}
