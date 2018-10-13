//
//  EventBuilder.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 9/1/18.
//

import Foundation

/**
 This building should be used for specifying an event which will toggle a registered transition.
 Example: builder.shouldTransit(state1 ~> state2).by(event: .goState2).immediately()
 */
public class EventBuilder<
  TState: Hashable,
  TEvent: Equatable,
  TExtendedState: ExtendedStateProtocol> {
  typealias TStateBuilder = StateBuilder<TState, TEvent, TExtendedState>
  typealias TStateDirection = StateDirection<TState, TEvent, TExtendedState, TStateBuilder, TStateBuilder>

  private let direction: TStateDirection
  private let stateMachineBuilder: StateMachineBuilder<TState, TEvent, TExtendedState>
  private var onTransitionActions = [OnTransitionAction<TExtendedState>]()

  private init() {
    fatalError()
  }

  init(
    stateMachineBuilder: StateMachineBuilder<TState, TEvent, TExtendedState>,
    direction: TStateDirection) {
    self.stateMachineBuilder = stateMachineBuilder
    self.direction = direction
  }

  /**
   Method by should be used for registering an even for a transition.
   Example: builder.shouldTransit(state1 ~> state2).by(event: .goState2).immediately()
   */
  public func by(event: TEvent) -> ConditionBuilder<TState, TEvent, TExtendedState> {
    return ConditionBuilder(
      event: event,
      direction: self.direction,
      onTransitionActions: self.onTransitionActions,
      stateMachineBuilder: stateMachineBuilder)
  }

  /**
   Method by should be used for registering a handler which will track transitions.
   Example: builder
   .shouldTransit(state1 ~> state2)
   .on { $0.transitionName = "goState2" }
   .by(event: .goState2)
   .immediately()

   In this case editExtraState block will process the extra state for state2
   */
  public func on(_ editExtendedState: @escaping (TExtendedState) -> Void)
    -> EventBuilder<TState, TEvent, TExtendedState> {
    self.onTransitionActions.append(OnTransitionAction(action: editExtendedState))

    return self
  }
}
