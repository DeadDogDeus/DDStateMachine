//
//  StateContainer.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 9/1/18.
//

import Foundation

class StateContainer<TStatus: Hashable, TEvent: Equatable, TExtraState: ExtraStateProtocol> {
  let status: TStatus

  var onConditions = [OnCondition<TExtraState>]()
  var ifConditions = [IfCondition<TStatus, TEvent, TExtraState>]()

  init(status: TStatus) {
    self.status = status
  }

  func toState() -> State<TStatus, TEvent, TExtraState> {
    return State(
      status: self.status,
      onConditions: self.onConditions,
      ifConditions: self.ifConditions)
  }
}
