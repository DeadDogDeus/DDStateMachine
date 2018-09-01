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
  TStatus: Hashable,
  TEvent: Equatable,
TExtraState: ExtraStateProtocol> {
  typealias TStateBuilder = StateBuilder<TStatus, TEvent, TExtraState>
  typealias TStateDirection = StateDirection<TStatus, TEvent, TExtraState, TStateBuilder, TStateBuilder>

  private let direction: TStateDirection
  private let stateMachineBuilder: StateMachineBuilder<TStatus, TEvent, TExtraState>
  private let event: TEvent
  private let onConditions: [OnCondition<TExtraState>]

  private init() {
    fatalError()
  }

  init(
    event: TEvent,
    direction: TStateDirection,
    onConditions: [OnCondition<TExtraState>],
    stateMachineBuilder: StateMachineBuilder<TStatus, TEvent, TExtraState>) {
    self.event = event
    self.direction = direction
    self.onConditions = onConditions
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
      onConditions: self.onConditions)
  }

  /**
   Method ifCondition should be used if it is needed to analyse fields of ExtraState model
   Example: builder.shouldTransit(state1 ~> state2).by(event: .goState2).ifCondition { $0.field == "something" }
  */
  public func ifCondition(_ condition: @escaping (TExtraState) -> Bool) {
    let ifCondition: IfCondition<TStatus, TEvent, TExtraState> = IfCondition(
      self.direction.toState.status,
      event: self.event,
      action: condition)

    self.stateMachineBuilder.addStates(
      event: self.event,
      direction: self.direction,
      onConditions: self.onConditions,
      ifConditions: [ifCondition])
  }
}