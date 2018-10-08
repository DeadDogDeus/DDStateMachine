//
//  MachineStateDirection.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 9/1/18.
//

import Foundation

public struct MachineStateDirection<
  TState: Hashable,
  TEvent: Equatable,
  TExtendedState: ExtendedStateProtocol,
  TFromStateBuilder,
  TToStateBuilder>
  where
  TState: Hashable,
  TFromStateBuilder: StateBuilder<TState, TEvent, TExtendedState>,
TToStateBuilder: StateBuilder<TState, TEvent, TExtendedState> {
  let fromStateBuilder: TFromStateBuilder
  let toStateBuilder: TToStateBuilder
}

