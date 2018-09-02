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
  TStatus: Hashable,
  TEvent: Equatable,
  TExtraState: ExtraStateProtocol,
  TWorkResult> {
  typealias TWorkStateBuilder = WorkStateBuilder<TStatus, TEvent, TExtraState, TWorkResult>
  typealias TStateBuilder = StateBuilder<TStatus, TEvent, TExtraState>
  typealias TResultCondition = ResultCondition<TStatus, TEvent, TExtraState, TWorkResult>
  typealias TWorkStateDirection = StateDirection<TStatus, TEvent, TExtraState, TWorkStateBuilder, TStateBuilder>

  private let direction: TWorkStateDirection
  private let stateMachineBuilder: StateMachineBuilder<TStatus, TEvent, TExtraState>
  private var onConditions = [OnCondition<TExtraState>]()

  private init() {
    fatalError()
  }

  init(
    stateMachineBuilder: StateMachineBuilder<TStatus, TEvent, TExtraState>,
    direction: TWorkStateDirection) {
    self.stateMachineBuilder = stateMachineBuilder
    self.direction = direction
  }

  /**
   Method ifResult should be used for processing a work result and making a decision run registered transition or not.
   Example: builder.shouldTransit(state1 ~> state2).ifResult { (result, _) in result == "something" }
  */
  public func ifResult(_ result: @escaping (TWorkResult, TExtraState) -> Bool) {
    let condition = TResultCondition(destinationStatus: self.direction.toState.status, action: result)

    self.stateMachineBuilder.addWorkStates(
      direction: self.direction,
      resultCondition: condition,
      onConditions: self.onConditions)
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
    -> WorkEventBuilder<TStatus, TEvent, TExtraState, TWorkResult> {
      self.onConditions.append(editExtraState)

      return self
  }
}
