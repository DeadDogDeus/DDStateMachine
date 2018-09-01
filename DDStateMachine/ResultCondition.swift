//
//  ResultCondition.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 9/1/18.
//

import Foundation

class ResultCondition<TStatus: Hashable, TEvent, TExtraState: ExtraStateProtocol, TWorkResult> {
  let action: (TWorkResult, TExtraState) -> Bool
  let destinationStatus: TStatus

  init(destinationStatus: TStatus, action: @escaping (TWorkResult, TExtraState) -> Bool) {
    self.destinationStatus = destinationStatus
    self.action = action
  }
}
