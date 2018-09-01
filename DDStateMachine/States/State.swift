//
//  State.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 8/26/18.
//

import Foundation
import ReactiveSwift
import Result

class State<TStatus: Hashable, TEvent: Equatable, TExtraState: ExtraStateProtocol> {
  let status: TStatus
  let extraState: TExtraState
  private let onConditions: [OnCondition<TExtraState>]
  private let ifConditions: [IfCondition<TStatus, TEvent, TExtraState>]

  init(
    status: TStatus,
    onConditions: [OnCondition<TExtraState>],
    ifConditions: [IfCondition<TStatus, TEvent, TExtraState>]) {
    self.status = status
    self.onConditions = onConditions
    self.ifConditions = ifConditions

    self.extraState = TExtraState()
  }

  func instantNextStatus() -> SignalProducer<TStatus, NoError> {
    return SignalProducer { () -> TStatus in
      self.onConditions.forEach { $0(self.extraState) }

      return self.status
    }
  }

  func execute(_ event: TEvent) -> SignalProducer<TStatus, NoError> {
    return SignalProducer { () -> TStatus in
      var nextStatus = self.status

      for ifCondition in self.ifConditions where ifCondition.event == event {
        if ifCondition.action(self.extraState) {
          nextStatus = ifCondition.destinationStatus

          break
        }
      }

      return nextStatus
    }
  }
}

