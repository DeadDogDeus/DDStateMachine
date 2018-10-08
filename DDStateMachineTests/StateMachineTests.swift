//
//  StateMachineTests.swift
//  DDStateMachineTests
//
//  Created by Alexander Bondarenko on 8/26/18.
//

import Foundation
import XCTest
import ReactiveSwift
import Result

@testable import DDStateMachine

class StateMachineTest: XCTestCase {
  func test_CurrentState_HasOneRegisteredStateWithoutActions_ShouldReturnRegisteredState() {
    // Arrange

    let builder = self.createStateMachineBuilder()

    let state1 = builder.createStateBuilder(from: .state1)

    // Act

    let stateMachine = builder.build(initialState: state1)

    // Assert

    XCTAssertEqual(stateMachine.currentState.value, TestState.state1)
  }

  func test_Execute_HasTwoStatesWithTransition_ShouldChangeStateAfterExecutingEvent() {
    // Arrange

    var newState = TestState.none

    let expectation = XCTestExpectation(description: "Has state")

    let builder = self.createStateMachineBuilder()

    let state1 = builder.createStateBuilder(from: .state1)
    let state2 = builder.createStateBuilder(from: .state2)

    builder.shouldTransit(state1 ~> state2).by(event: .goState2).immediately()

    let stateMachine = builder.build(initialState: state1)

    stateMachine.currentState.signal.observeValues { state in
      newState = state

      expectation.fulfill()
    }

    // Act

    _ = stateMachine.execute(event: .goState2).wait()

    self.wait(for: [expectation], timeout: 1)

    // Assert

    XCTAssertEqual(newState, .state2)
  }

  func test_Execute_HasTwoStatesWithTransition_ShouldCallOnTransitionActionAfterTransition() {
    // Arrange

    let expectation = XCTestExpectation(description: "Has On Condition")

    let builder = self.createStateMachineBuilder()

    let state1 = builder.createStateBuilder(from: .state1)
    let state2 = builder.createStateBuilder(from: .state2)

    builder.shouldTransit(state1 ~> state2).on({ _ in
      expectation.fulfill()
    }).by(event: .goState2).immediately()

    let stateMachine = builder.build(initialState: state1)

    // Act

    _ = stateMachine.execute(event: .goState2).wait()

    // Assert

    self.wait(for: [expectation], timeout: 1)
  }

  func test_Execute_HasTwoStatesWithTransitionAndUnsuccessfulIfCondition_ShouldNotTransit() {
    // Arrange

    let expectation = XCTestExpectation(description: "Has state")
    expectation.isInverted = true

    let builder = self.createStateMachineBuilder()

    let state1 = builder.createStateBuilder(from: .state1)
    let state2 = builder.createStateBuilder(from: .state2)

    builder.shouldTransit(state1 ~> state2).by(event: .goState2).ifCondition {_ in false }

    let stateMachine = builder.build(initialState: state1)

    stateMachine.currentState.signal.observeValues { _ in
      expectation.fulfill()
    }

    // Act

    _ = stateMachine.execute(event: .goState2).wait()

    // Assert

    self.wait(for: [expectation], timeout: 1)

    XCTAssertEqual(stateMachine.currentState.value, TestState.state1)
  }

  func test_Execute_HasTwoStatesWithTransitions_ExecuteTwoEvents_ShouldPassCorrectExtendedStateAndReturnToInitState() {
    // Arrange

    let ifConditionExpectation = XCTestExpectation(description: "state2 ifCondition")
    ifConditionExpectation.expectedFulfillmentCount = 1

    let state1Expectation = XCTestExpectation(description: "state1")
    state1Expectation.expectedFulfillmentCount = 1

    let state2Expectation = XCTestExpectation(description: "state2")
    state2Expectation.expectedFulfillmentCount = 1

    let builder = self.createStateMachineBuilder()

    let state1 = builder.createStateBuilder(from: .state1)
    let state2 = builder.createStateBuilder(from: .state2)

    builder
      .shouldTransit(state1 ~> state2)
      .on { $0.testField = true }
      .by(event: .goState2)
      .immediately()

    builder
      .shouldTransit(state2 ~> state1)
      .by(event: .goState1)
      .ifCondition { (extendedState) -> Bool in
        ifConditionExpectation.fulfill()
        return extendedState.testField
    }

    let stateMachine = builder.build(initialState: state1)

    stateMachine.currentState.signal.observeValues { state in
      switch state {
      case .state1:
        state1Expectation.fulfill()
      case .state2:
        state2Expectation.fulfill()
      default:
        XCTAssert(false)
      }
    }

    // Act

    _ = stateMachine.execute(event: .goState2).wait()

    self.wait(for: [state2Expectation], timeout: 1)

    _ = stateMachine.execute(event: .goState1).wait()

    // Assert

    self.wait(for: [ifConditionExpectation, state1Expectation], timeout: 1)

    XCTAssertEqual(stateMachine.currentState.value, TestState.state1)
  }

  func test_Execute_HasTwoStatesWithTransition_ExecuteUnknowEvent_ShouldNotTransit() {
    // Arrange

    let expectation = XCTestExpectation(description: "Has On Condition")
    expectation.isInverted = true

    let builder = self.createStateMachineBuilder()

    let state1 = builder.createStateBuilder(from: .state1)
    let state2 = builder.createStateBuilder(from: .state2)

    builder.shouldTransit(state1 ~> state2).by(event: .goState2).immediately()

    let stateMachine = builder.build(initialState: state1)

    stateMachine.currentState.signal.observeValues { _ in
      expectation.fulfill()
    }

    // Act

    _ = stateMachine.execute(event: .goState3).wait()

    // Assert

    self.wait(for: [expectation], timeout: 1)

    XCTAssertEqual(stateMachine.currentState.value, TestState.state1)
  }

  func test_Execute_HasThreeOnTransitionActions_ShouldCallThreeOnTransitionActions() {
    // Arrange

    let expectation = XCTestExpectation(description: "Has On Conditions")
    expectation.expectedFulfillmentCount = 3

    let builder = self.createStateMachineBuilder()

    let state1 = builder.createStateBuilder(from: .state1)
    let state2 = builder.createStateBuilder(from: .state2)

    builder.shouldTransit(state1 ~> state2)
      .on { _ in expectation.fulfill() }
      .on { _ in expectation.fulfill() }
      .on { _ in expectation.fulfill() }
      .by(event: .goState2)
      .immediately()

    let stateMachine = builder.build(initialState: state1)

    // Act

    _ = stateMachine.execute(event: .goState2).wait()

    // Assert

    self.wait(for: [expectation], timeout: 1)
  }

  func test_Execute_HasWorkState_ShouldRunWorkAfterTransitionAndTransitAfterWork() {
    // Arrange

    let workExpectation = XCTestExpectation(description: "Work")
    workExpectation.expectedFulfillmentCount = 1

    let state1Expectation = XCTestExpectation(description: "state1")
    state1Expectation.expectedFulfillmentCount = 1

    let builder = self.createStateMachineBuilder()

    let state1 = builder.createStateBuilder(from: .state1)
    let state2 = builder.createStateBuilder(
    from: TestState.state2) { (_) -> SignalProducer<Bool, NoError> in
      workExpectation.fulfill()
      return SignalProducer(value: true)
    }

    builder.shouldTransit(state1 ~> state2).by(event: .goState2).immediately()
    builder.shouldTransit(state2 ~> state1).ifResult { (result, _) in result }

    let stateMachine = builder.build(initialState: state1)

    stateMachine.currentState.signal.observeValues { state in
      if case TestState.state1 = state {
        state1Expectation.fulfill()
      }
    }

    // Act

    _ = stateMachine.execute(event: .goState2).wait()

    // Assert

    self.wait(for: [workExpectation, state1Expectation], timeout: 1)
  }

  func test_Execute_HasWorkStatesWithOnTransitionActions_ShouldCallBlocksInCorrectOrder() {
    // Arrange

    let workExpectation = XCTestExpectation(description: "Work")
    workExpectation.expectedFulfillmentCount = 2

    let state1Expectation = XCTestExpectation(description: "state1")
    state1Expectation.expectedFulfillmentCount = 1

    let builder = self.createStateMachineBuilder()

    let state1 = builder.createStateBuilder(from: .state1)
    let state2 = builder.createStateBuilder(
    from: TestState.state2) { (extendedState) -> SignalProducer<Bool, NoError> in
      if extendedState.number == 2 {
        workExpectation.fulfill()
      }
      return SignalProducer(value: true)
    }

    let state3 = builder.createStateBuilder(
    from: TestState.state3) { (extendedState) -> SignalProducer<Bool, NoError> in
      if extendedState.number == 3 {
        workExpectation.fulfill()
      }
      return SignalProducer(value: true)
    }

    builder.shouldTransit(state1 ~> state2)
      .on { $0.number = 2 }
      .by(event: .goState2)
      .immediately()

    builder.shouldTransit(state2 ~> state3)
      .on { $0.number = 3 }
      .ifResult { (result, _) in result }

    builder.shouldTransit(state3 ~> state1)
      .ifResult { (result, _) in result }

    let stateMachine = builder.build(initialState: state1)

    stateMachine.currentState.signal.observeValues { state in
      if case TestState.state1 = state {
        state1Expectation.fulfill()
      }
    }

    // Act

    _ = stateMachine.execute(event: .goState2).wait()

    // Assert

    self.wait(for: [workExpectation, state1Expectation], timeout: 1)
  }

  func test_Execute_HasTwoAcyclicStatesLastWithWork_ShouldRunWork() {
    // Arrange

    let expected = XCTestExpectation(description: "Expected")
    expected.expectedFulfillmentCount = 2

    let builder = self.createStateMachineBuilder()

    let state1 = builder.createStateBuilder(from: .state1)

    let state2 = builder.createStateBuilder(
    from: TestState.state2) { (_) -> SignalProducer<Bool, NoError> in
      expected.fulfill()

      return SignalProducer(value: true)
    }

    builder.shouldTransit(state1 ~> state2).by(event: .goState2).immediately()

    let stateMachine = builder.build(initialState: state1)

    stateMachine.currentState.signal.observeValues { _ in expected.fulfill() }

    // Act

    _ = stateMachine.execute(event: .goState2).wait()

    // Assert

    self.wait(for: [expected], timeout: 1)

    XCTAssertEqual(stateMachine.currentState.value, .state2)
  }

  /**
   It is a known peculiarity of this state machine
   if the initial state is a work-state,
   the state machine will not run its work.
   */
  func test_CurrentState_HasInitialStateWithWork_ShouldNotRunWork() {
    // Arrange

    let unexpected = XCTestExpectation(description: "Unexpected")
    unexpected.isInverted = true

    let builder = self.createStateMachineBuilder()

    let state1 = builder.createStateBuilder(
    from: TestState.state1) { (_) -> SignalProducer<Bool, NoError> in
      unexpected.fulfill()

      return SignalProducer(value: true)
    }

    // Act

    let stateMachine = builder.build(initialState: state1)

    // Assert

    self.wait(for: [unexpected], timeout: 1)

    XCTAssertEqual(stateMachine.currentState.value, TestState.state1)
  }

  private func createStateMachineBuilder() -> StateMachineBuilder<TestState, TestEvent, TestExtendedState> {
    let executeScheduler = QueueScheduler()
    let stateScheduler = QueueScheduler()

    return StateMachineBuilder<TestState, TestEvent, TestExtendedState>(
      executeScheduler: executeScheduler,
      stateScheduler: stateScheduler)
  }
}

private enum TestState: String {
  case state1
  case state2
  case state3
  case none
}

private enum TestEvent {
  case goState1
  case goState2
  case goState3
}

private class TestExtendedState: ExtendedStateProtocol {
  var testField: Bool = false
  var number: Int = 0

  required init() {
  }
}
