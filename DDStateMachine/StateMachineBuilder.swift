//
//  StateMachineBuilder.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 8/26/18.
//

import Foundation
import ReactiveSwift
import Result

class StateBuilder<TStatus: Hashable, TEvent: Equatable, TExtraState: ExtraStateProtocol> {
  internal let status: TStatus

  private init() {
    fatalError()
  }

  internal init(_ status: TStatus) {
    self.status = status
  }

  static func ~> (
    fromStateBuilder: StateBuilder,
    toStateBuilder: StateBuilder)
    -> StateDirection<TStatus, TEvent, TExtraState, StateBuilder, StateBuilder> {
      return StateDirection(fromState: fromStateBuilder, toState: toStateBuilder)
  }
}

class WorkStateBuilder<
  TStatus: Hashable,
  TEvent: Equatable,
  TExtraState: ExtraStateProtocol,
TWorkResult>: StateBuilder<TStatus, TEvent, TExtraState> {
  typealias TWorkStateBuilder = WorkStateBuilder<TStatus, TEvent, TExtraState, TWorkResult>
  typealias TStateBuilder = StateBuilder<TStatus, TEvent, TExtraState>
  typealias TWorkStateDirection = StateDirection<TStatus, TEvent, TExtraState, TWorkStateBuilder, TStateBuilder>
  typealias Work = (TExtraState) -> SignalProducer<TWorkResult, NoError>

  internal let work: Work

  private init() {
    fatalError()
  }

  internal init(_ status: TStatus, work: @escaping Work) {
    self.work = work

    super.init(status)
  }

  static func ~> (
    fromStateBuilder: TWorkStateBuilder,
    toStateBuilder: TStateBuilder) -> TWorkStateDirection {
    return StateDirection(fromState: fromStateBuilder, toState: toStateBuilder)
  }
}

class ConditionBuilder<
  TStatus: Hashable,
  TEvent: Equatable,
TExtraState: ExtraStateProtocol> {
  typealias TStateBuilder = StateBuilder<TStatus, TEvent, TExtraState>
  typealias TStateDirection = StateDirection<TStatus, TEvent, TExtraState, TStateBuilder, TStateBuilder>

  private let direction: TStateDirection
  private let stateMachineBuilder: StateMachineBuilder<TStatus, TEvent, TExtraState>
  private let event: TEvent
  private let onConditions: [OnCondition<TExtraState>]

  private init() {
    fatalError()
  }

  internal init(
    event: TEvent,
    direction: TStateDirection,
    onConditions: [OnCondition<TExtraState>],
    stateMachineBuilder: StateMachineBuilder<TStatus, TEvent, TExtraState>) {
    self.event = event
    self.direction = direction
    self.onConditions = onConditions
    self.stateMachineBuilder = stateMachineBuilder
  }

  func immediately() {
    self.stateMachineBuilder.addStates(
      event: self.event,
      direction: self.direction,
      onConditions: self.onConditions)
  }

  func ifCondition(_ condition: @escaping (TExtraState) -> Bool) {
    let ifCondition: IfCondition<TStatus, TEvent, TExtraState> = IfCondition(
      self.direction.toState.status,
      event: self.event,
      action: condition)

    self.stateMachineBuilder.addStates(
      event: self.event,
      direction: self.direction,
      onConditions: self.onConditions,
      ifConditions: [ifCondition])
  }
}

class EventBuilder<
  TStatus: Hashable,
  TEvent: Equatable,
TExtraState: ExtraStateProtocol> {
  typealias TStateBuilder = StateBuilder<TStatus, TEvent, TExtraState>
  typealias TStateDirection = StateDirection<TStatus, TEvent, TExtraState, TStateBuilder, TStateBuilder>

  private let direction: TStateDirection
  private let stateMachineBuilder: StateMachineBuilder<TStatus, TEvent, TExtraState>
  private var onConditions = [OnCondition<TExtraState>]()

  private init() {
    fatalError()
  }

  internal init(
    stateMachineBuilder: StateMachineBuilder<TStatus, TEvent, TExtraState>,
    direction: TStateDirection) {
    self.stateMachineBuilder = stateMachineBuilder
    self.direction = direction
  }

  func by(event: TEvent) -> ConditionBuilder<TStatus, TEvent, TExtraState> {
    return ConditionBuilder(
      event: event,
      direction: self.direction,
      onConditions: self.onConditions,
      stateMachineBuilder: stateMachineBuilder)
  }

  func on(_ editExtraState: @escaping (TExtraState) -> Void)
    -> EventBuilder<TStatus, TEvent, TExtraState> {
      self.onConditions.append(editExtraState)

      return self
  }
}

class WorkEventBuilder<
  TStatus: Hashable,
  TEvent: Equatable,
  TExtraState: ExtraStateProtocol,
TWorkResult> {
  typealias TWorkStateBuilder = WorkStateBuilder<TStatus, TEvent, TExtraState, TWorkResult>
  typealias TStateBuilder = StateBuilder<TStatus, TEvent, TExtraState>
  typealias TResultCondition = ResultCondition<TStatus, TEvent, TExtraState, TWorkResult>
  typealias TWorkStateDirection = StateDirection<TStatus, TEvent, TExtraState, TWorkStateBuilder, TStateBuilder>

  private let direction: TWorkStateDirection
  private let stateMachineBuilder: StateMachineBuilder<TStatus, TEvent, TExtraState>
  private var onConditions = [OnCondition<TExtraState>]()

  private init() {
    fatalError()
  }

  internal init(
    stateMachineBuilder: StateMachineBuilder<TStatus, TEvent, TExtraState>,
    direction: TWorkStateDirection) {
    self.stateMachineBuilder = stateMachineBuilder
    self.direction = direction
  }

  func ifResult(_ result: @escaping (TWorkResult, TExtraState) -> Bool) {
    let condition = TResultCondition(destinationStatus: self.direction.toState.status, action: result)

    self.stateMachineBuilder.addWorkStates(
      direction: self.direction,
      resultCondition: condition,
      onConditions: self.onConditions)
  }

  func on(_ editExtraState: @escaping (TExtraState) -> Void)
    -> WorkEventBuilder<TStatus, TEvent, TExtraState, TWorkResult> {
      self.onConditions.append(editExtraState)

      return self
  }
}

class StateMachineBuilder<TStatus: Hashable, TEvent: Equatable, TExtraState: ExtraStateProtocol> {
  typealias TStateBuilder = StateBuilder<TStatus, TEvent, TExtraState>
  typealias TWorkStateBuilder<TWorkResult> = WorkStateBuilder<TStatus, TEvent, TExtraState, TWorkResult>
  typealias TStateDirection = StateDirection<TStatus, TEvent, TExtraState, TStateBuilder, TStateBuilder>
  typealias TWorkStateDirection<TWorkResult> =
    StateDirection<TStatus, TEvent, TExtraState, TWorkStateBuilder<TWorkResult>, TStateBuilder>
  typealias TStateContainer = StateContainer<TStatus, TEvent, TExtraState>
  typealias TWorkStateContainer<TWorkResult> = WorkStateContainer<TStatus, TEvent, TExtraState, TWorkResult>
  typealias TResultCondition<TWorkResult> = ResultCondition<TStatus, TEvent, TExtraState, TWorkResult>
  typealias Work<TWorkResult> = (TExtraState) -> SignalProducer<TWorkResult, NoError>

  private let scheduler: Scheduler
  private var statesContainers = [TStatus: TStateContainer]()

  init(scheduler: Scheduler) {
    self.scheduler = scheduler
  }

  func shouldTransit(_ direction: TStateDirection) -> EventBuilder<TStatus, TEvent, TExtraState> {
    return EventBuilder(stateMachineBuilder: self, direction: direction)
  }

  func shouldTransit<TWorkResult>(_ direction: TWorkStateDirection<TWorkResult>)
    -> WorkEventBuilder<TStatus, TEvent, TExtraState, TWorkResult> {
      return WorkEventBuilder(stateMachineBuilder: self, direction: direction)
  }

  func build(initialState: TStateBuilder) -> StateMachine<TStatus, TEvent, TExtraState> {
    self.addStates(stateBuilder: initialState)

    let states = self.createStates()

    return StateMachine(
      scheduler: scheduler,
      currentStatus: initialState.status,
      states: states)
  }

  internal func addStates(
    event: TEvent,
    direction: TStateDirection,
    onConditions: [OnCondition<TExtraState>] = [OnCondition<TExtraState>](),
    ifConditions: [IfCondition<TStatus, TEvent, TExtraState>]? = nil) {

    self.editStateContainer(for: direction.fromState.status) { (container) in
      if let conditions = ifConditions {
        container.ifConditions.append(contentsOf: conditions)
      } else {
        let ifCondition = IfCondition<TStatus, TEvent, TExtraState>(
          direction.toState.status,
          event: event) { _ in true }

        container.ifConditions.append(ifCondition)
      }
    }

    self.editStateContainer(for: direction.toState.status) { (container) in
      container.onConditions.append(contentsOf: onConditions)
    }
  }

  internal func addWorkStates<TWorkResult>(
    direction: TWorkStateDirection<TWorkResult>,
    resultCondition: TResultCondition<TWorkResult>,
    onConditions: [OnCondition<TExtraState>] = [OnCondition<TExtraState>]()) {

    self.editWorkStateContainer(
      for: direction.fromState.status,
      work: direction.fromState.work) { $0.resultConditions.append(resultCondition) }

    self.editStateContainer(
    for: direction.toState.status) { $0.onConditions.append(contentsOf: onConditions) }
  }

  private func addStates(stateBuilder: TStateBuilder) {
    self.statesContainers[stateBuilder.status] = self.stateContainer(for: stateBuilder.status)
  }

  private func editStateContainer(for status: TStatus, _ action: @escaping (TStateContainer) -> Void) {
    let stateContainer = self.stateContainer(for: status)

    action(stateContainer)

    self.statesContainers[status] = stateContainer
  }

  private func editWorkStateContainer<TWorkResult>(
    for status: TStatus,
    work: @escaping Work<TWorkResult>,
    _ action: @escaping (TWorkStateContainer<TWorkResult>) -> Void) {
    let workStateContainer = self.workStateContainer(for: status, work: work)

    action(workStateContainer)

    self.statesContainers[status] = workStateContainer
  }

  private func createStates() -> [State<TStatus, TEvent, TExtraState>] {
    return self.statesContainers.map { $0.value.toState() }
  }

  private func stateContainer(for status: TStatus) -> TStateContainer {
    return self.statesContainers[status] ?? StateContainer(status: status)
  }

  private func workStateContainer<TWorkResult>(
    for status: TStatus,
    work: @escaping Work<TWorkResult>)
    -> TWorkStateContainer<TWorkResult> {
      var resultContainer = TWorkStateContainer<TWorkResult>(status: status, work: work)

      if let stateContainer = self.statesContainers[status] {
        resultContainer.onConditions.append(contentsOf: stateContainer.onConditions)
        resultContainer.ifConditions.append(contentsOf: stateContainer.ifConditions)

        if let workStateContainer = stateContainer as? TWorkStateContainer<TWorkResult> {
          resultContainer = workStateContainer
        }
      }

      return resultContainer
  }
}
