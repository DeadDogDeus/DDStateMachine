//
//  IfCondition.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 9/1/18.
//

import Foundation

class IfCondition<TStatus: Hashable, TEvent, TExtraState: ExtraStateProtocol> {
  let action: (TExtraState) -> Bool
  let destinationStatus: TStatus
  let event: TEvent

  init(_ destinationStatus: TStatus, event: TEvent, action: @escaping (TExtraState) -> Bool) {
    self.destinationStatus = destinationStatus
    self.event = event
    self.action = action
  }
}
