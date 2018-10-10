//
//  StateBuilder.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 9/1/18.
//

import Foundation

/**
 This builder should be used for State Machine Builder for creating directions between states.
 Example: builder.shouldTransit(state1 ~> state2)
 */
public class StateBuilder<TState: Hashable, TEvent: Equatable, TExtendedState: ExtendedStateProtocol> {
  let state: TState

  private init() {
    fatalError()
  }

  init(_ state: TState) {
    self.state = state
  }

  /**
   Method for creating a direction for a transition between states.
   Example: builder.shouldTransit(state1 ~> state2)
   - parameters:
   - fromStateBuilder: state1
   - toStateBuilder: state2
   */
  public static func ~> (
    fromStateBuilder: StateBuilder,
    toStateBuilder: StateBuilder)
    -> MachineStateDirection<TState, TEvent, TExtendedState, StateBuilder, StateBuilder> {
    return MachineStateDirection(
      fromStateBuilder: fromStateBuilder,
      toStateBuilder: toStateBuilder)
  }
}
