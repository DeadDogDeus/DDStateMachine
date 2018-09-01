//
//  WorkEventBuilder.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 9/1/18.
//

import Foundation
import ReactiveSwift
import Result

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

  public func ifResult(_ result: @escaping (TWorkResult, TExtraState) -> Bool) {
    let condition = TResultCondition(destinationStatus: self.direction.toState.status, action: result)

    self.stateMachineBuilder.addWorkStates(
      direction: self.direction,
      resultCondition: condition,
      onConditions: self.onConditions)
  }

  public func on(_ editExtraState: @escaping (TExtraState) -> Void)
    -> WorkEventBuilder<TStatus, TEvent, TExtraState, TWorkResult> {
      self.onConditions.append(editExtraState)

      return self
  }
}
