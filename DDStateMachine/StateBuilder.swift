//
//  StateBuilder.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 8/26/18.
//

import Foundation
import ReactiveSwift
import Result

public struct StateDirection<TStatus, TEvent, TExtraState, TFromState, TToState>
  where
  TStatus: Hashable,
  TFromState: StateBuilder<TStatus, TEvent, TExtraState>,
TToState: StateBuilder<TStatus, TEvent, TExtraState> {
  let fromState: TFromState
  let toState: TToState
}

public class StateBuilder<TStatus: Hashable, TEvent, TExtraState> {
  private let status: TStatus

  public init(_ status: TStatus) {
    self.status = status
  }

  public static func ~> (
    fromStateBuilder: StateBuilder<TStatus, TEvent, TExtraState>,
    toStateBuilder: StateBuilder<TStatus, TEvent, TExtraState>)
    -> StateDirection<
    TStatus,
    TEvent,
    TExtraState,
    StateBuilder<TStatus, TEvent, TExtraState>,
    StateBuilder<TStatus, TEvent, TExtraState>> {
      return StateDirection(
        fromState: fromStateBuilder,
        toState: toStateBuilder)
  }
}

public class WorkStateBuilder<
  TStatus: Hashable,
  TEvent, TExtraState,
TWorkResult>: StateBuilder<TStatus, TEvent, TExtraState> {
  private var work: (()-> SignalProducer<TWorkResult, NoError>)

  public init(_ status: TStatus, work: @escaping ()-> SignalProducer<TWorkResult, NoError>) {
    self.work = work

    super.init(status)
  }

  public static func ~> (
    fromStateBuilder: WorkStateBuilder<TStatus, TEvent, TExtraState, TWorkResult>,
    toStateBuilder: StateBuilder<TStatus, TEvent, TExtraState>)
    -> StateDirection<
    TStatus,
    TEvent,
    TExtraState,
    WorkStateBuilder<TStatus, TEvent, TExtraState, TWorkResult>,
    StateBuilder<TStatus, TEvent, TExtraState>> {
      return StateDirection(
        fromState: fromStateBuilder,
        toState: toStateBuilder)
  }
}
