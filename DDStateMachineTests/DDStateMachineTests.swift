//
//  DDStateMachineTests.swift
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
  func test_CurrentStatus_HasOneRegisteredStateWithoutActions_ShouldReturnRegisteredStatus() {
    // Arrange

    let scheduler = QueueScheduler()

    let builder = StateMachineBuilder<TestStatus, TestEvent, TestExtraState>(scheduler: scheduler)
    let state1: StateBuilder<TestStatus, TestEvent, TestExtraState> = StateBuilder(.status1)

    // Act

    let stateMachine = builder.build(initialState: state1)

    // Assert

    XCTAssertEqual(stateMachine.currentStatus.value, TestStatus.status1)
  }

  func test_Execute_HasTwoStatesWithTransition_ShouldChangeStateAfterExecutingEvent() {
    // Arrange

    var newStatus = TestStatus.none

    let expectation = XCTestExpectation(description: "Has status")

    let scheduler = QueueScheduler()

    let builder = StateMachineBuilder<TestStatus, TestEvent, TestExtraState>(scheduler: scheduler)
    let state1: StateBuilder<TestStatus, TestEvent, TestExtraState> = StateBuilder(.status1)
    let state2: StateBuilder<TestStatus, TestEvent, TestExtraState> = StateBuilder(.status2)

    builder.shouldTransit(state1 ~> state2).by(event: .goState2).immediately()

    let stateMachine = builder.build(initialState: state1)

    stateMachine.currentStatus.signal.observeValues { status in
      newStatus = status

      expectation.fulfill()
    }

    // Act

    stateMachine.execute(event: .goState2)

    self.wait(for: [expectation], timeout: 1)

    // Assert

    XCTAssertEqual(newStatus, .status2)
  }

  func test_Execute_HasTwoStatesWithTransition_ShouldCallOnConditionAfterTransition() {
    // Arrange

    let expectation = XCTestExpectation(description: "Has On Condition")

    let scheduler = QueueScheduler()

    let builder = StateMachineBuilder<TestStatus, TestEvent, TestExtraState>(scheduler: scheduler)
    let state1: StateBuilder<TestStatus, TestEvent, TestExtraState> = StateBuilder(.status1)
    let state2: StateBuilder<TestStatus, TestEvent, TestExtraState> = StateBuilder(.status2)

    builder.shouldTransit(state1 ~> state2).on({ _ in
      expectation.fulfill()
    }).by(event: .goState2).immediately()

    let stateMachine = builder.build(initialState: state1)

    // Act

    stateMachine.execute(event: .goState2)

    // Assert

    self.wait(for: [expectation], timeout: 1)
  }

  func test_Execute_HasTwoStatesWithTransitionAndUnsuccessfulIfCondition_ShouldNotTransit() {
    // Arrange

    let expectation = XCTestExpectation(description: "Has status")
    expectation.isInverted = true

    let scheduler = QueueScheduler()

    let builder = StateMachineBuilder<TestStatus, TestEvent, TestExtraState>(scheduler: scheduler)
    let state1: StateBuilder<TestStatus, TestEvent, TestExtraState> = StateBuilder(.status1)
    let state2: StateBuilder<TestStatus, TestEvent, TestExtraState> = StateBuilder(.status2)

    builder.shouldTransit(state1 ~> state2).by(event: .goState2).ifCondition {_ in false }

    let stateMachine = builder.build(initialState: state1)

    stateMachine.currentStatus.signal.observeValues { _ in
      expectation.fulfill()
    }

    // Act

    stateMachine.execute(event: .goState2)

    // Assert

    self.wait(for: [expectation], timeout: 1)

    XCTAssertEqual(stateMachine.currentStatus.value, TestStatus.status1)
  }

  func test_Execute_HasTwoStatesWithTransitions_ExecuteTwoEvents_ShouldPassCorrectExtraStateAndReturnToInitialState() {
    // Arrange

    let ifConditionExpectation = XCTestExpectation(description: "state2 ifCondition")
    ifConditionExpectation.expectedFulfillmentCount = 1

    let status1Expectation = XCTestExpectation(description: "status1")
    status1Expectation.expectedFulfillmentCount = 1

    let status2Expectation = XCTestExpectation(description: "status2")
    status2Expectation.expectedFulfillmentCount = 1

    let scheduler = QueueScheduler()

    let builder = StateMachineBuilder<TestStatus, TestEvent, TestExtraState>(scheduler: scheduler)
    let state1: StateBuilder<TestStatus, TestEvent, TestExtraState> = StateBuilder(.status1)
    let state2: StateBuilder<TestStatus, TestEvent, TestExtraState> = StateBuilder(.status2)

    builder
      .shouldTransit(state1 ~> state2)
      .on { $0.testField = true }
      .by(event: .goState2)
      .immediately()

    builder
      .shouldTransit(state2 ~> state1)
      .by(event: .goState1)
      .ifCondition { (extraState) -> Bool in
        ifConditionExpectation.fulfill()
        return extraState.testField
    }

    let stateMachine = builder.build(initialState: state1)

    stateMachine.currentStatus.signal.observeValues { status in
      switch status {
      case .status1:
        status1Expectation.fulfill()
      case .status2:
        status2Expectation.fulfill()
      default:
        XCTAssert(false)
      }
    }

    // Act

    stateMachine.execute(event: .goState2)

    self.wait(for: [status2Expectation], timeout: 1)

    stateMachine.execute(event: .goState1)

    // Assert

    self.wait(for: [ifConditionExpectation, status1Expectation], timeout: 1)

    XCTAssertEqual(stateMachine.currentStatus.value, TestStatus.status1)
  }

  func test_Execute_HasTwoStatesWithTransition_ExecuteUnknowEvent_ShouldNotTransit() {
    // Arrange

    let expectation = XCTestExpectation(description: "Has On Condition")
    expectation.isInverted = true

    let scheduler = QueueScheduler()

    let builder = StateMachineBuilder<TestStatus, TestEvent, TestExtraState>(scheduler: scheduler)
    let state1: StateBuilder<TestStatus, TestEvent, TestExtraState> = StateBuilder(.status1)
    let state2: StateBuilder<TestStatus, TestEvent, TestExtraState> = StateBuilder(.status2)

    builder.shouldTransit(state1 ~> state2).by(event: .goState2).immediately()

    let stateMachine = builder.build(initialState: state1)

    stateMachine.currentStatus.signal.observeValues { _ in
      expectation.fulfill()
    }

    // Act

    stateMachine.execute(event: .goState3)

    // Assert

    self.wait(for: [expectation], timeout: 1)

    XCTAssertEqual(stateMachine.currentStatus.value, TestStatus.status1)
  }

  func test_Execute_HasThreeOnConditions_ShouldCallThreeOnConditions() {
    // Arrange

    let expectation = XCTestExpectation(description: "Has On Conditions")
    expectation.expectedFulfillmentCount = 3

    let scheduler = QueueScheduler()

    let builder = StateMachineBuilder<TestStatus, TestEvent, TestExtraState>(scheduler: scheduler)
    let state1: StateBuilder<TestStatus, TestEvent, TestExtraState> = StateBuilder(.status1)
    let state2: StateBuilder<TestStatus, TestEvent, TestExtraState> = StateBuilder(.status2)

    builder.shouldTransit(state1 ~> state2)
      .on { _ in expectation.fulfill() }
      .on { _ in expectation.fulfill() }
      .on { _ in expectation.fulfill() }
      .by(event: .goState2)
      .immediately()

    let stateMachine = builder.build(initialState: state1)

    // Act

    stateMachine.execute(event: .goState2)

    // Assert

    self.wait(for: [expectation], timeout: 1)
  }

  func test_Execute_HasWorkState_ShouldRunWorkAfterTransitionAndTransitAfterWork() {
    // Arrange

    let workExpectation = XCTestExpectation(description: "Work")
    workExpectation.expectedFulfillmentCount = 1

    let status1Expectation = XCTestExpectation(description: "status1")
    status1Expectation.expectedFulfillmentCount = 1

    let scheduler = QueueScheduler()

    let builder = StateMachineBuilder<TestStatus, TestEvent, TestExtraState>(scheduler: scheduler)
    let state1: StateBuilder<TestStatus, TestEvent, TestExtraState> = StateBuilder(.status1)
    let state2: WorkStateBuilder<TestStatus, TestEvent, TestExtraState, Bool> =
      WorkStateBuilder(.status2) { (_) in
        workExpectation.fulfill()
        return SignalProducer(value: true)
    }

    builder.shouldTransit(state1 ~> state2).by(event: .goState2).immediately()
    builder.shouldTransit(state2 ~> state1).ifResult { (result, _) in result }

    let stateMachine = builder.build(initialState: state1)

    stateMachine.currentStatus.signal.observeValues { status in
      if case TestStatus.status1 = status {
        status1Expectation.fulfill()
      }
    }

    // Act

    stateMachine.execute(event: .goState2)

    // Assert

    self.wait(for: [workExpectation, status1Expectation], timeout: 1)
  }

  func test_Execute_HasWorkStatesWithOnConditions_ShouldCallBlocksInCorrectOrder() {
    // Arrange

    let workExpectation = XCTestExpectation(description: "Work")
    workExpectation.expectedFulfillmentCount = 2

    let status1Expectation = XCTestExpectation(description: "status1")
    status1Expectation.expectedFulfillmentCount = 1

    let scheduler = QueueScheduler()

    let builder = StateMachineBuilder<TestStatus, TestEvent, TestExtraState>(scheduler: scheduler)

    let state1: StateBuilder<TestStatus, TestEvent, TestExtraState> = StateBuilder(.status1)
    let state2: WorkStateBuilder<TestStatus, TestEvent, TestExtraState, Bool> =
      WorkStateBuilder(.status2) { (extraState) in
        if extraState.number == 2 {
          workExpectation.fulfill()
        }

        return SignalProducer(value: true)
    }

    let state3: WorkStateBuilder<TestStatus, TestEvent, TestExtraState, Bool> =
      WorkStateBuilder(.status3) { (extraState) in
        if extraState.number == 3 {
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

    stateMachine.currentStatus.signal.observeValues { status in
      if case TestStatus.status1 = status {
        status1Expectation.fulfill()
      }
    }

    // Act

    stateMachine.execute(event: .goState2)

    // Assert

    self.wait(for: [workExpectation, status1Expectation], timeout: 1)
  }

  /**
   It is a known peculiarity of this state machine
   If the state machine is acyclic and the last state has a work,
   the state machine will not run its work.
   */
  func test_Execute_HasTwoAcyclicStatesLastWithWork_ShouldNotRunWork() {
    // Arrange

    let expected = XCTestExpectation(description: "Expected")
    expected.expectedFulfillmentCount = 1

    let unexpected = XCTestExpectation(description: "Unexpected")
    unexpected.isInverted = true

    let scheduler = QueueScheduler()

    let builder = StateMachineBuilder<TestStatus, TestEvent, TestExtraState>(scheduler: scheduler)

    let state1: StateBuilder<TestStatus, TestEvent, TestExtraState> = StateBuilder(.status1)

    let state2: WorkStateBuilder<TestStatus, TestEvent, TestExtraState, Bool> =
      WorkStateBuilder(.status2) { (_) in
        unexpected.fulfill()

        return SignalProducer(value: true)
    }

    builder.shouldTransit(state1 ~> state2).by(event: .goState2).immediately()

    let stateMachine = builder.build(initialState: state1)

    stateMachine.currentStatus.signal.observeValues { _ in expected.fulfill() }

    // Act

    stateMachine.execute(event: .goState2)

    // Assert

    self.wait(for: [expected, unexpected], timeout: 1)

    XCTAssertEqual(stateMachine.currentStatus.value, .status2)
  }

  /**
   It is a known peculiarity of this state machine
   if the initial state is a work-state,
   the state machine will not run its work.
   */
  func test_CurrentStatus_HasInitialStateWithWork_ShouldNotRunWork() {
    // Arrange

    let unexpected = XCTestExpectation(description: "Unexpected")
    unexpected.isInverted = true

    let scheduler = QueueScheduler()

    let builder = StateMachineBuilder<TestStatus, TestEvent, TestExtraState>(scheduler: scheduler)

    let state1: WorkStateBuilder<TestStatus, TestEvent, TestExtraState, Bool> =
      WorkStateBuilder(.status1) { (_) in
        unexpected.fulfill()

        return SignalProducer(value: true)
    }

    // Act

    let stateMachine = builder.build(initialState: state1)

    // Assert

    self.wait(for: [unexpected], timeout: 1)

    XCTAssertEqual(stateMachine.currentStatus.value, TestStatus.status1)
  }
}

private enum TestStatus: String {
  case status1
  case status2
  case status3
  case none
}

private enum TestEvent {
  case goState1
  case goState2
  case goState3
}

private class TestExtraState: ExtraStateProtocol {
  var testField: Bool = false
  var number: Int = 0

  required init() {
  }
}
