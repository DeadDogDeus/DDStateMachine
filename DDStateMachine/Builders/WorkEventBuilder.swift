//
//  WorkEventBuilder.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 9/1/18.
//

import Foundation
import ReactiveSwift
import Result

/**
 This building should be used for specifying an action which will toggle a registered transition.
 Example: builder.shouldTransit(state1 ~> state2).ifResult { (result, _) in result == "something" }
 */
public class WorkEventBuilder<
  TState: Hashable,
  TEvent: Equatable,
  TExtendedState: ExtendedStateProtocol,
  TWorkResult> {
  typealias TWorkStateBuilder = WorkStateBuilder<TState, TEvent, TExtendedState, TWorkResult>
  typealias TStateBuilder = StateBuilder<TState, TEvent, TExtendedState>
  typealias TResultCondition = ResultCondition<TState, TEvent, TExtendedState, TWorkResult>
  typealias TWorkStateDirection =
    StateDirection<TState, TEvent, TExtendedState, TWorkStateBuilder, TStateBuilder>

  private let direction: TWorkStateDirection
  private let stateMachineBuilder: StateMachineBuilder<TState, TEvent, TExtendedState>
  private var onTransitionActions = [OnTransitionAction<TExtendedState>]()

  private init() {
    fatalError()
  }

  init(
    stateMachineBuilder: StateMachineBuilder<TState, TEvent, TExtendedState>,
    direction: TWorkStateDirection) {
    self.stateMachineBuilder = stateMachineBuilder
    self.direction = direction
  }

  /**
   Method ifResult should be used for processing a work result and making a decision run registered transition or not.
   Example: builder.shouldTransit(state1 ~> state2).ifResult { (result, _) in result == "something" }
   */
  public func ifResult(_ result: @escaping (TWorkResult, TExtendedState) -> Bool) {
    let condition = TResultCondition(
      destinationState: self.direction.toStateBuilder.state,
      action: result)

    self.stateMachineBuilder.addWorkStates(
      direction: self.direction,
      resultCondition: condition,
      onTransitionActions: self.onTransitionActions)
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
    -> WorkEventBuilder<TState, TEvent, TExtendedState, TWorkResult> {
    self.onTransitionActions.append(OnTransitionAction(action: editExtendedState))

    return self
  }
}
