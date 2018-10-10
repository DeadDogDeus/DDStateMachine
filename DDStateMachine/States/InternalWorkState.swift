//
//  WorkState.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 9/1/18.
//

import Foundation
import ReactiveSwift
import Result

class InternalWorkState<TState: Hashable, TEvent: Equatable, TExtendedState: ExtendedStateProtocol, TWorkResult>
: InternalState<TState, TEvent, TExtendedState> {
  typealias Work = (TExtendedState) -> SignalProducer<TWorkResult, NoError>

  private let resultConditions: [ResultCondition<TState, TEvent, TExtendedState, TWorkResult>]
  private let work: Work

  init(
    state: TState,
    work: @escaping Work,
    onTransitionActions: [OnTransitionAction<TExtendedState>],
    ifConditions: [IfCondition<TState, TEvent, TExtendedState>],
    resultConditions: [ResultCondition<TState, TEvent, TExtendedState, TWorkResult>]) {
    self.work = work
    self.resultConditions = resultConditions

    super.init(state: state, onTransitionActions: onTransitionActions, ifConditions: ifConditions)
  }

  override func run() -> SignalProducer<TState?, NoError> {
    return super.run().then(SignalProducer<TWorkResult, NoError> { (observer, _) in
      self.work(self.extendedState).startWithValues { (result) in
        observer.send(value: result)
        observer.sendCompleted()
      }
    }).map { self.nextState(from: $0) }
  }

  private func nextState(from workResult: TWorkResult) -> TState? {
    let destinationState = self.resultConditions
      .first { $0.action(workResult, self.extendedState) }
      .flatMap { $0.destinationState}

    return destinationState
  }
}
