//
//  StateMachine.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 8/26/18.
//

import Foundation
import ReactiveSwift

public class StateMachine<TStatus: Hashable, TEvent> {
  public let currentStatus: Property<TStatus>
  private let mutableCurrentStatus: MutableProperty<TStatus>

  public init(status: TStatus) {
    self.mutableCurrentStatus = MutableProperty(status)
    self.currentStatus = Property(self.mutableCurrentStatus)
  }

  public func execute(event: TEvent) {
    fatalError()
  }
}
