//
//  OnTransitionAction.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 10/8/18.
//

import Foundation

class OnTransitionAction<TExtendedState: ExtendedStateProtocol> {
  let action: (TExtendedState) -> Void

  init(action: @escaping (TExtendedState) -> Void) {
    self.action = action
  }
}
