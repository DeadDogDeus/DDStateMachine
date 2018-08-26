//
//  StateMachine.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 8/26/18.
//

import Foundation
import ReactiveSwift

public class StateMachine<TStatus: Hashable, TEvent> {
  let currentStatus: Property<TStatus>
  private let mutableCurrentStatus: MutableProperty<TStatus>

  init(status: TStatus) {
    self.mutableCurrentStatus = MutableProperty(status)
    self.currentStatus = Property(self.mutableCurrentStatus)
  }

  func execute(event: TEvent) {
    fatalError()
  }
}
