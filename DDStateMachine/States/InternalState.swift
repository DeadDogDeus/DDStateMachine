//
//  State.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 8/26/18.
//

import Foundation
import ReactiveSwift
import Result

class InternalState<TState: Hashable, TEvent: Equatable, TExtendedState: ExtendedStateProtocol> {
  let state: TState
  internal let extendedState: TExtendedState
  private let onTransitionActions: [OnTransitionAction<TExtendedState>]
  private let ifConditions: [IfCondition<TState, TEvent, TExtendedState>]

  init(
    state: TState,
    onTransitionActions: [OnTransitionAction<TExtendedState>],
    ifConditions: [IfCondition<TState, TEvent, TExtendedState>]) {
    self.state = state
    self.onTransitionActions = onTransitionActions
    self.ifConditions = ifConditions

    self.extendedState = TExtendedState()
  }

  func run() -> SignalProducer<TState?, NoError> {
    return SignalProducer { () -> TState? in
      self.onTransitionActions.forEach { $0.action(self.extendedState) }

      return nil
    }
  }

  func destinationState(by event: TEvent) -> SignalProducer<TState?, NoError> {
    return SignalProducer { () -> TState? in
      let destinationState = self.ifConditions
        .first { $0.event == event && $0.action(self.extendedState) }
        .flatMap { $0.destinationState }

      return destinationState
    }
  }
}
