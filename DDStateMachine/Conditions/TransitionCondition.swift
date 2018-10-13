//
//  TransitionCondition.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 10/8/18.
//

import Foundation

protocol TransitionCondition {
  associatedtype TState: Hashable

  var destinationState: TState { get }
}
