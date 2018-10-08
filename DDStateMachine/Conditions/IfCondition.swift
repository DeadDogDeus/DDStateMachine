//
//  IfCondition.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 9/1/18.
//

import Foundation

class IfCondition<TState: Hashable, TEvent, TExtendedState: ExtendedStateProtocol>
: TransitionCondition<TState> {
  let action: (TExtendedState) -> Bool
  let event: TEvent

  init(_ destinationState: TState, event: TEvent, action: @escaping (TExtendedState) -> Bool) {
    self.event = event
    self.action = action

    super.init(destinationState)
  }
}
