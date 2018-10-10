//
//  MachineWorkStateContainer.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 9/1/18.
//

import Foundation
import ReactiveSwift
import Result

class MachineWorkStateContainer<
  TState: Hashable,
  TEvent: Equatable,
  TExtendedState: ExtendedStateProtocol,
  TWorkResult> : MachineStateContainer<TState, TEvent, TExtendedState> {
  var resultConditions = [ResultCondition<TState, TEvent, TExtendedState, TWorkResult>]()
  let work: (TExtendedState) -> SignalProducer<TWorkResult, NoError>

  init(
    state: TState,
    work: @escaping (TExtendedState) -> SignalProducer<TWorkResult, NoError>) {
    self.work = work
    super.init(state: state)
  }

  override func toInternalState()
    -> InternalWorkState<TState, TEvent, TExtendedState, TWorkResult> {
    return InternalWorkState(
      state: self.state,
      work: self.work,
      onTransitionActions: self.onTransitionActions,
      ifConditions: self.ifConditions,
      resultConditions: self.resultConditions)
  }
}

