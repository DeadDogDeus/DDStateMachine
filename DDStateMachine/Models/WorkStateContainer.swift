//
//  WorkStateContainer.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 9/1/18.
//

import Foundation
import ReactiveSwift
import Result

class WorkStateContainer<
  TStatus: Hashable,
  TEvent: Equatable,
  TExtraState: ExtraStateProtocol,
TWorkResult> : StateContainer<TStatus, TEvent, TExtraState> {
  var resultConditions = [ResultCondition<TStatus, TEvent, TExtraState, TWorkResult>]()
  let work: (TExtraState)-> SignalProducer<TWorkResult, NoError>

  init(status: TStatus, work: @escaping (TExtraState)-> SignalProducer<TWorkResult, NoError>) {
    self.work = work
    super.init(status: status)
  }

  override func toState() -> WorkState<TStatus, TEvent, TExtraState, TWorkResult> {
    return WorkState(
      status: self.status,
      work: self.work,
      onConditions: self.onConditions,
      ifConditions: self.ifConditions,
      resultConditions: self.resultConditions)
  }
}

