//
//  TransitionCondition.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 10/8/18.
//

import Foundation

class TransitionCondition<TState: Hashable> {
  let destinationState: TState

  init(_ destinationState: TState) {
    self.destinationState = destinationState
  }
}
