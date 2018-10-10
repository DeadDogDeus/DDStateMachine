//
//  ResultCondition.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 9/1/18.
//

import Foundation

class ResultCondition<TState: Hashable, TEvent, TExtendedState: ExtendedStateProtocol, TWorkResult>
  : TransitionCondition<TState> {
  let action: (TWorkResult, TExtendedState) -> Bool

  init(destinationState: TState, action: @escaping (TWorkResult, TExtendedState) -> Bool) {
    self.action = action

    super.init(destinationState)
  }
}

