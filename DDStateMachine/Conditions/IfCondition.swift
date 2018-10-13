//
//  IfCondition.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 9/1/18.
//

import Foundation

struct IfCondition<TState: Hashable, TEvent, TExtendedState: ExtendedStateProtocol>
  : TransitionCondition {
  let destinationState: TState
  let action: (TExtendedState) -> Bool
  let event: TEvent
}
