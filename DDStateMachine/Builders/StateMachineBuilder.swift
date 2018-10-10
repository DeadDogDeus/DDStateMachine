//
//  StateMachineBuilder.swift
//  DDStateMachine
//
//  Created by Alexander Bondarenko on 8/26/18.
//

import Foundation
import ReactiveSwift
import Result

/**
 This class is the main builder of this framework,
 it can be used for creating of State Machine and customization of its states.
 */
public class StateMachineBuilder<TState: Hashable, TEvent: Equatable, TExtendedState: ExtendedStateProtocol> {
  public typealias TStateBuilder = StateBuilder<TState, TEvent, TExtendedState>
  public typealias TWorkStateBuilder<TWorkResult> = WorkStateBuilder<TState, TEvent, TExtendedState, TWorkResult>
  public typealias TStateDirection = MachineStateDirection<TState, TEvent, TExtendedState, TStateBuilder, TStateBuilder>
  public typealias TWorkStateDirection<TWorkResult> =
    MachineStateDirection<TState, TEvent, TExtendedState, TWorkStateBuilder<TWorkResult>, TStateBuilder>
  typealias TStateContainer = MachineStateContainer<TState, TEvent, TExtendedState>
  typealias TWorkStateContainer<TWorkResult> = MachineWorkStateContainer<TState, TEvent, TExtendedState, TWorkResult>
  typealias TResultCondition<TWorkResult> = ResultCondition<TState, TEvent, TExtendedState, TWorkResult>
  public typealias Work<TWorkResult> = (TExtendedState) -> SignalProducer<TWorkResult, NoError>

  private let executeScheduler: Scheduler
  private let stateScheduler: Scheduler

  private var statesContainers = [TState: TStateContainer]()

  public init(executeScheduler: Scheduler, stateScheduler: Scheduler) {
    self.executeScheduler = executeScheduler
    self.stateScheduler = stateScheduler
  }

  public func createStateBuilder(from state: TState) -> TStateBuilder {
    let stateBuilder: TStateBuilder = StateBuilder(state)

    self.addState(stateBuilder: stateBuilder)

    return stateBuilder
  }

  public func createStateBuilder<TWorkResult>(
    from state: TState,
    work: @escaping Work<TWorkResult>) -> TWorkStateBuilder<TWorkResult> {
    let stateBuilder: TWorkStateBuilder<TWorkResult> = WorkStateBuilder(state, work: work)

    self.addWorkState(stateBuilder: stateBuilder)

    return stateBuilder
  }

  /**
   Method for registering transition between states.
   Example: builder.shouldTransit(state1 ~> state2)
   - parameters:
   - direction: transition direction for example: state1 ~> state2
   */
  public func shouldTransit(_ direction: TStateDirection) -> EventBuilder<TState, TEvent, TExtendedState> {
    return EventBuilder(stateMachineBuilder: self, direction: direction)
  }

  /**
   Method for registering transition between states.
   From state should be WorkState
   Example: builder.shouldTransit(state1 ~> state2)
   - parameters:
   - direction: transition direction for example: state1 ~> state2
   */
  public func shouldTransit<TWorkResult>(_ direction: TWorkStateDirection<TWorkResult>)
    -> WorkEventBuilder<TState, TEvent, TExtendedState, TWorkResult> {
    return WorkEventBuilder(stateMachineBuilder: self, direction: direction)
  }

  /**
   Create State Machine with the initial state
   */
  public func build(initialState: TStateBuilder) -> StateMachine<TState, TEvent, TExtendedState> {
    self.addState(stateBuilder: initialState)

    let internalStates = self.createInternalStates()

    return StateMachine(
      executeScheduler: self.executeScheduler,
      stateScheduler: self.stateScheduler,
      currentState: initialState.state,
      internalStates: internalStates)
  }

  func addStates(
    event: TEvent,
    direction: TStateDirection,
    onTransitionActions: [OnTransitionAction<TExtendedState>] = [OnTransitionAction<TExtendedState>](),
    ifConditions: [IfCondition<TState, TEvent, TExtendedState>]? = nil) {

    self.editStateContainer(for: direction.fromStateBuilder.state) { (container) in
      if let conditions = ifConditions {
        container.ifConditions.append(contentsOf: conditions)
      } else {
        let ifCondition = IfCondition<TState, TEvent, TExtendedState>(
          direction.toStateBuilder.state,
          event: event) { _ in true }

        container.ifConditions.append(ifCondition)
      }
    }

    self.editStateContainer(for: direction.toStateBuilder.state) { (container) in
      container.onTransitionActions.append(contentsOf: onTransitionActions)
    }
  }

  func addWorkStates<TWorkResult>(
    direction: TWorkStateDirection<TWorkResult>,
    resultCondition: TResultCondition<TWorkResult>,
    onTransitionActions: [OnTransitionAction<TExtendedState>] = [OnTransitionAction<TExtendedState>]()) {

    self.editWorkStateContainer(for: direction.fromStateBuilder.state, work: direction.fromStateBuilder.work) {
        $0.resultConditions.append(resultCondition)
    }

    self.editStateContainer(for: direction.toStateBuilder.state) {
      $0.onTransitionActions.append(contentsOf: onTransitionActions)
    }
  }

  private func addState(stateBuilder: TStateBuilder) {
    self.statesContainers[stateBuilder.state] = self.stateContainer(for: stateBuilder.state)
  }

  private func addWorkState<TWorkResult>(stateBuilder: TWorkStateBuilder<TWorkResult>) {
    self.statesContainers[stateBuilder.state] = self.workStateContainer(
      for: stateBuilder.state,
      work: stateBuilder.work)
  }

  private func editStateContainer(for state: TState, _ action: @escaping (TStateContainer) -> Void) {
    let stateContainer = self.stateContainer(for: state)

    action(stateContainer)

    self.statesContainers[state] = stateContainer
  }

  private func editWorkStateContainer<TWorkResult>(
    for state: TState,
    work: @escaping Work<TWorkResult>,
    _ action: @escaping (TWorkStateContainer<TWorkResult>) -> Void) {
    let workStateContainer = self.workStateContainer(for: state, work: work)

    action(workStateContainer)

    self.statesContainers[state] = workStateContainer
  }

  private func createInternalStates() -> [InternalState<TState, TEvent, TExtendedState>] {
    return self.statesContainers.map { $0.value.toInternalState() }
  }

  private func stateContainer(for state: TState) -> TStateContainer {
    return self.statesContainers[state] ?? MachineStateContainer(state: state)
  }

  private func workStateContainer<TWorkResult>(
    for state: TState,
    work: @escaping Work<TWorkResult>)
    -> TWorkStateContainer<TWorkResult> {
    var resultContainer = TWorkStateContainer<TWorkResult>(state: state, work: work)

    if let stateContainer = self.statesContainers[state] {
      resultContainer.onTransitionActions.append(contentsOf: stateContainer.onTransitionActions)
      resultContainer.ifConditions.append(contentsOf: stateContainer.ifConditions)

      if let workStateContainer = stateContainer as? TWorkStateContainer<TWorkResult> {
        resultContainer = workStateContainer
      }
    }

    return resultContainer
  }
}
