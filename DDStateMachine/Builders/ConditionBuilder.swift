//
//  ConditionBuilder.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 9/1/18.
//

import Foundation

/**
 This building should be used for specifying a condition for a registered transition.
 Example: builder.shouldTransit(state1 ~> state2).by(event: .goState2).immediately()
 */
public class ConditionBuilder<
  TState: Hashable,
  TEvent: Equatable,
  TExtendedState: ExtendedStateProtocol> {
  typealias TStateBuilder = StateBuilder<TState, TEvent, TExtendedState>
  typealias TStateDirection = StateDirection<TState, TEvent, TExtendedState, TStateBuilder, TStateBuilder>

  private let direction: TStateDirection
  private let stateMachineBuilder: StateMachineBuilder<TState, TEvent, TExtendedState>
  private let event: TEvent
  private let onTransitionActions: [OnTransitionAction<TExtendedState>]

  private init() {
    fatalError()
  }

  init(
    event: TEvent,
    direction: TStateDirection,
    onTransitionActions: [OnTransitionAction<TExtendedState>],
    stateMachineBuilder: StateMachineBuilder<TState, TEvent, TExtendedState>) {
    self.event = event
    self.direction = direction
    self.onTransitionActions = onTransitionActions
    self.stateMachineBuilder = stateMachineBuilder
  }

  /**
   Method immediately should be used if it is needed to transit immediately
   after receiving an appropriate event.
   Example: builder.shouldTransit(state1 ~> state2).by(event: .goState2).immediately()
   */
  public func immediately() {
    self.stateMachineBuilder.addStates(
      event: self.event,
      direction: self.direction,
      onTransitionActions: self.onTransitionActions)
  }

  /**
   Method ifCondition should be used if it is needed to analyse fields of ExtraState model
   Example: builder.shouldTransit(state1 ~> state2).by(event: .goState2).ifCondition { $0.field == "something" }
   */
  public func ifCondition(_ condition: @escaping (TExtendedState) -> Bool) {
    let ifCondition: IfCondition<TState, TEvent, TExtendedState> = IfCondition(
      destinationState: self.direction.toStateBuilder.state,
      action: condition,
      event: self.event)

    self.stateMachineBuilder.addStates(
      event: self.event,
      direction: self.direction,
      onTransitionActions: self.onTransitionActions,
      ifConditions: [ifCondition])
  }
}
