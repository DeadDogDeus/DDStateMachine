//
//  ResultCondition.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 9/1/18.
//

import Foundation

struct ResultCondition<TState: Hashable, TEvent, TExtendedState: ExtendedStateProtocol, TWorkResult>
  : TransitionCondition {
  let destinationState: TState
  let action: (TWorkResult, TExtendedState) -> Bool
}

