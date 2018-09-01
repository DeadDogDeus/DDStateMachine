//
//  EventBuilder.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 9/1/18.
//

import Foundation

/**
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
  */
  public func by(event: TEvent) -> ConditionBuilder<TStatus, TEvent, TExtraState> {
    return ConditionBuilder(
      event: event,
      direction: self.direction,
      onConditions: self.onConditions,
      stateMachineBuilder: stateMachineBuilder)
  }

  /**
  */
  public func on(_ editExtraState: @escaping (TExtraState) -> Void)
    -> EventBuilder<TStatus, TEvent, TExtraState> {
      self.onConditions.append(editExtraState)

      return self
  }
}
