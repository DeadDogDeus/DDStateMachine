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
  TStatus: Hashable,
  TEvent: Equatable,
  TExtraState: ExtraStateProtocol> {
  typealias TStateBuilder = StateBuilder<TStatus, TEvent, TExtraState>
  typealias TStateDirection = StateDirection<TStatus, TEvent, TExtraState, TStateBuilder, TStateBuilder>

  private let direction: TStateDirection
  private let stateMachineBuilder: StateMachineBuilder<TStatus, TEvent, TExtraState>
  private var onConditions = [OnCondition<TExtraState>]()

  private init() {
    fatalError()
  }

  init(
    stateMachineBuilder: StateMachineBuilder<TStatus, TEvent, TExtraState>,
    direction: TStateDirection) {
    self.stateMachineBuilder = stateMachineBuilder
    self.direction = direction
  }

  /**
   Method by should be used for registering an even for a transition.
   Example: builder.shouldTransit(state1 ~> state2).by(event: .goState2).immediately()
  */
  public func by(event: TEvent) -> ConditionBuilder<TStatus, TEvent, TExtraState> {
    return ConditionBuilder(
      event: event,
      direction: self.direction,
      onConditions: self.onConditions,
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
  public func on(_ editExtraState: @escaping (TExtraState) -> Void)
    -> EventBuilder<TStatus, TEvent, TExtraState> {
      self.onConditions.append(editExtraState)

      return self
  }
}
