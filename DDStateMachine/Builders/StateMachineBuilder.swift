//
//  StateMachineBuilder.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 8/26/18.
//

import Foundation
import ReactiveSwift
import Result

public class StateMachineBuilder<TStatus: Hashable, TEvent: Equatable, TExtraState: ExtraStateProtocol> {
  public typealias TStateBuilder = StateBuilder<TStatus, TEvent, TExtraState>
  public typealias TWorkStateBuilder<TWorkResult> = WorkStateBuilder<TStatus, TEvent, TExtraState, TWorkResult>
  public typealias TStateDirection = StateDirection<TStatus, TEvent, TExtraState, TStateBuilder, TStateBuilder>
  public typealias TWorkStateDirection<TWorkResult> =
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

  public func shouldTransit(_ direction: TStateDirection) -> EventBuilder<TStatus, TEvent, TExtraState> {
    return EventBuilder(stateMachineBuilder: self, direction: direction)
  }

  public func shouldTransit<TWorkResult>(_ direction: TWorkStateDirection<TWorkResult>)
    -> WorkEventBuilder<TStatus, TEvent, TExtraState, TWorkResult> {
      return WorkEventBuilder(stateMachineBuilder: self, direction: direction)
  }

  public func build(initialState: TStateBuilder) -> StateMachine<TStatus, TEvent, TExtraState> {
    self.addStates(stateBuilder: initialState)

    let states = self.createStates()

    return StateMachine(
      scheduler: scheduler,
      currentStatus: initialState.status,
      states: states)
  }

  func addStates(
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

  func addWorkStates<TWorkResult>(
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
