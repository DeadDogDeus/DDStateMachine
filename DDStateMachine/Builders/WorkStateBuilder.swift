//
//  WorkStateBuilder.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 9/1/18.
//

import Foundation
import ReactiveSwift
import Result

/**
 This builder should be used for State Machine Builder for creating directions between states.
 Example: builder.shouldTransit(state1 ~> state2)
 */
public class WorkStateBuilder<
  TStatus: Hashable,
  TEvent: Equatable,
  TExtraState: ExtraStateProtocol,
TWorkResult>: StateBuilder<TStatus, TEvent, TExtraState> {
  public typealias TWorkStateBuilder = WorkStateBuilder<TStatus, TEvent, TExtraState, TWorkResult>
  public typealias TStateBuilder = StateBuilder<TStatus, TEvent, TExtraState>
  public typealias TWorkStateDirection = StateDirection<TStatus, TEvent, TExtraState, TWorkStateBuilder, TStateBuilder>
  public typealias Work = (TExtraState) -> SignalProducer<TWorkResult, NoError>

  let work: Work

  private init() {
    fatalError()
  }

  init(_ status: TStatus, work: @escaping Work) {
    self.work = work

    super.init(status)
  }

  /**
   Method for creating a direction for a transition between states.
   Example: builder.shouldTransit(state1 ~> state2)
   - parameters:
   - fromStateBuilder: state1 (it should be WorkStateBuilder)
   - toStateBuilder: state2
   */
  public static func ~> (
    fromStateBuilder: TWorkStateBuilder,
    toStateBuilder: TStateBuilder) -> TWorkStateDirection {
    return StateDirection(fromState: fromStateBuilder, toState: toStateBuilder)
  }
}
