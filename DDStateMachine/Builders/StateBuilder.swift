//
//  StateBuilder.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 9/1/18.
//

import Foundation

/**
*/
public class StateBuilder<TStatus: Hashable, TEvent: Equatable, TExtraState: ExtraStateProtocol> {
  let status: TStatus

  private init() {
    fatalError()
  }

  init(_ status: TStatus) {
    self.status = status
  }

  /**
  */
  public static func ~> (
    fromStateBuilder: StateBuilder,
    toStateBuilder: StateBuilder)
    -> StateDirection<TStatus, TEvent, TExtraState, StateBuilder, StateBuilder> {
      return StateDirection(fromState: fromStateBuilder, toState: toStateBuilder)
  }
}
