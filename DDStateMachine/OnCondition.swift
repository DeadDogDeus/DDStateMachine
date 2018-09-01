//
//  OnCondition.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 9/1/18.
//

import Foundation

typealias OnCondition<TExtraState: ExtraStateProtocol> = (TExtraState) -> Void
