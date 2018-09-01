//
//  StateDirection.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 9/1/18.
//

import Foundation

struct StateDirection<
  TStatus: Hashable,
  TEvent: Equatable,
  TExtraState: ExtraStateProtocol,
  TFromState,
  TToState>
  where
  TStatus: Hashable,
  TFromState: StateBuilder<TStatus, TEvent, TExtraState>,
TToState: StateBuilder<TStatus, TEvent, TExtraState> {
  let fromState: TFromState
  let toState: TToState
}

