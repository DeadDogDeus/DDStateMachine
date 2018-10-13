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
  TState: Hashable,
  TEvent: Equatable,
  TExtendedState: ExtendedStateProtocol,
TWorkResult>: StateBuilder<TState, TEvent, TExtendedState> {
  public typealias TWorkStateBuilder = WorkStateBuilder<TState, TEvent, TExtendedState, TWorkResult>
  public typealias TStateBuilder = StateBuilder<TState, TEvent, TExtendedState>
  public typealias TWorkStateDirection =
    StateDirection<TState, TEvent, TExtendedState, TWorkStateBuilder, TStateBuilder>
  typealias Work = (TExtendedState) -> SignalProducer<TWorkResult, NoError>

  let work: Work

  private init() {
    fatalError()
  }

  init(_ state: TState, work: @escaping Work) {
    self.work = work

    super.init(state)
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
    return StateDirection(fromStateBuilder: fromStateBuilder, toStateBuilder: toStateBuilder)
  }
}
