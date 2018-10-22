import Foundation
import DDStateMachine
import ReactiveSwift
import Result

enum SyncState: Int, Hashable {
  case notSynced
  case inProgress
  case synced
  case failed
}

enum SyncEvent {
  case sync
  case forceSync
}

class SyncExtendedState: ExtendedStateProtocol {
  var expiryDate: Date?

  required init() {}
}

var marker = MutableProperty(false)

func sync(extendedState: SyncExtendedState) -> SignalProducer<Bool, NoError> {
  return marker.producer
    .filter { $0 }
    .take(first: 1)
    .flatMap(.latest, { _ -> SignalProducer<Bool, NoError> in
    return SignalProducer<Bool, NoError>(value: true)
  })
}

var result = true

let executeScheduler = QueueScheduler()
let stateScheduler = QueueScheduler()

let builder = StateMachineBuilder<SyncState, SyncEvent, SyncExtendedState>(
  executeScheduler: QueueScheduler(),
  stateScheduler: stateScheduler)

let notSynced = builder.createStateBuilder(from: .notSynced)
let synced = builder.createStateBuilder(from: .synced)
let failed = builder.createStateBuilder(from: .failed)
let inProgress = builder.createStateBuilder(from: .inProgress, work: sync)

builder.shouldTransit(notSynced ~> inProgress).by(event: .sync).immediately()

builder.shouldTransit(inProgress ~> synced)
  .on { $0.expiryDate = Date(timeIntervalSinceNow: 30) }
  .ifResult { (result, _) in result }

builder.shouldTransit(inProgress ~> failed).ifResult { (result, _) in !result }

builder.shouldTransit(synced ~> inProgress)
  .by(event: .sync)
  .ifCondition { $0.expiryDate == nil || $0.expiryDate! < Date() }

builder.shouldTransit(failed ~> inProgress).by(event: .sync).immediately()

// Force
builder.shouldTransit(synced ~> inProgress).by(event: .forceSync).immediately()
builder.shouldTransit(failed ~> inProgress).by(event: .forceSync).immediately()


var stateMachine = builder.build(initialState: notSynced)

stateMachine.currentState.producer.startWithValues {
  print($0)
}

_ = stateMachine.execute(event: .sync).start()
marker.value = true
marker.value = false

_ = stateMachine.execute(event: .forceSync).start()
marker.value = true
