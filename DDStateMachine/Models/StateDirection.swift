//
//  StateDirection.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 9/1/18.
//

import Foundation

public struct StateDirection<
  TStatus: Hashable,
  TEvent: Equatable,
  TExtraState: ExtraStateProtocol,
  TFromState,
  TToState>
  where
  TStatus: Hashable,
  TFromState: StateBuilder<TStatus, TEvent, TExtraState>,
TToState: StateBuilder<TStatus, TEvent, TExtraState> {
  public let fromState: TFromState
  public let toState: TToState
}

