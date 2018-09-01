//
//  WorkState.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 9/1/18.
//

import Foundation
import ReactiveSwift
import Result

class WorkState<TStatus: Hashable, TEvent: Equatable, TExtraState: ExtraStateProtocol, TWorkResult>
: State<TStatus, TEvent, TExtraState> {
  typealias Work = (TExtraState) -> SignalProducer<TWorkResult, NoError>

  private let resultConditions: [ResultCondition<TStatus, TEvent, TExtraState, TWorkResult>]
  private let work: Work

  init(
    status: TStatus,
    work: @escaping Work,
    onConditions: [OnCondition<TExtraState>],
    ifConditions: [IfCondition<TStatus, TEvent, TExtraState>],
    resultConditions: [ResultCondition<TStatus, TEvent, TExtraState, TWorkResult>]) {
    self.work = work
    self.resultConditions = resultConditions

    super.init(status: status, onConditions: onConditions, ifConditions: ifConditions)
  }

  override func instantNextStatus() -> SignalProducer<TStatus, NoError> {
    return super.instantNextStatus().then(SignalProducer<TWorkResult, NoError> { (observer, _) in
      self.work(self.extraState).startWithValues { (result) in
        observer.send(value: result)
        observer.sendCompleted()
      }
    }).map { self.nextStatus(from: $0) }
  }

  private func nextStatus(from workResult: TWorkResult) -> TStatus {
    var nextStatus = self.status

    for resultCondition in self.resultConditions {
      if resultCondition.action(workResult, self.extraState) {
        nextStatus = resultCondition.destinationStatus

        break
      }
    }

    return nextStatus
  }
}

