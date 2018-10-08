//
//  MachineStateContainer.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 9/1/18.
//

import Foundation

class MachineStateContainer<TState: Hashable, TEvent: Equatable, TExtendedState: ExtendedStateProtocol> {
  let state: TState

  var onTransitionActions = [OnTransitionAction<TExtendedState>]()
  var ifConditions = [IfCondition<TState, TEvent, TExtendedState>]()

  init(state: TState) {
    self.state = state
  }

  func toInternalState() -> InternalState<TState, TEvent, TExtendedState> {
    return InternalState(
      state: self.state,
      onTransitionActions: self.onTransitionActions,
      ifConditions: self.ifConditions)
  }
}
