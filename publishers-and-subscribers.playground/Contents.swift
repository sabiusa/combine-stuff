import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "Old Style") {
    let notif = Notification.Name("MyNotification")
    let center = NotificationCenter.default
        
    let observer = center.addObserver(
        forName: notif,
        object: nil,
        queue: nil,
        using: { notification in
            print("Notification Received!")
        }
    )
    
    center.post(name: notif, object: nil)
    
    center.removeObserver(observer)
}

example(of: "Subscriber") {
    let notif = Notification.Name("MyNotification")
    let center = NotificationCenter.default
    
    let pub = center.publisher(for: notif, object: nil)
    
    let sub = pub
        .sink { value in
            print(value)
            print("Received from Publisher!")
        }
    
    center.post(name: notif, object: nil)
    
    sub.cancel()
}

example(of: "Just") {
    let just = Just("Hello")
    
    _ = just.sink(
        receiveCompletion: {
            print("Completion: ", $0)
        },
        receiveValue: {
            print("Value: ", $0)
        }
    )
    
    _ = just.sink(
        receiveCompletion: {
            print("Completion 2: ", $0)
        },
        receiveValue: {
            print("Value 2: ", $0)
        }
    )
}

example(of: "assign(to:on:)") {
    class Obj {
        var value: String = "" {
            didSet {
                print(value)
            }
        }
    }
    
    let obj = Obj()
    
    let publisher = ["Hello", "World"].publisher
    
    _ = publisher
        .assign(to: \.value, on: obj)
    
    print(obj.value)
}

example(of: "assign(to:)") {
    class Obj {
        @Published var value = -1
    }
    
    let obj = Obj()
    
    obj.$value
        .sink { value in
            print(value)
        }
    
    (1 ... 5).publisher
        .assign(to: &obj.$value)
    
    print(obj.value)
}

example(of: "Custom Subscriber") {
    let publisher = (1 ... 5).publisher
    
    final class IntSubscriber: Subscriber {
        
        typealias Input = Int
        typealias Failure = Never
        
        func receive(subscription: Subscription) {
            subscription.request(.max(3))
        }
        
        func receive(_ input: Int) -> Subscribers.Demand {
            print("Received value", input)
            return .max(1) // increase by 1 every time value is received
        }
        
        func receive(completion: Subscribers.Completion<Never>) {
            print("Received completion")
        }
        
    }
    
    let intSub = IntSubscriber()
    
    publisher.subscribe(intSub)
}

example(of: "Future") {
    func futureIncrement(
        integer: Int,
        delay: TimeInterval
    ) -> Future<Int, Never> {
        return Future<Int, Never> { promise in
            print("Start Future")
            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                promise(.success(integer + 1))
            }
        }
    }
    
    let future = futureIncrement(integer: 1, delay: 0)
    
    future
        .sink(
            receiveCompletion: { print("Completion: ", $0) },
            receiveValue: { print("Value: ", $0) }
        )
        .store(in: &subscriptions)
    
    future
        .sink(
            receiveCompletion: { print("Second Completion: ", $0) },
            receiveValue: { print("Second value: ", $0) }
        )
        .store(in: &subscriptions)
}

example(of: "PassthroughSubject") {
    enum MyError: Error {
        case test
    }
    
    final class StringSubscriber: Subscriber {
        
        typealias Input = String
        typealias Failure = MyError
        
        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }
        
        func receive(_ input: String) -> Subscribers.Demand {
            print("Received value: ", input)
            return input == "World" ? .max(1) : .none
        }
        
        func receive(completion: Subscribers.Completion<MyError>) {
            print("Received completion: ", completion)
        }
        
    }
    
    let subscriber = StringSubscriber()
    let subject = PassthroughSubject<String, MyError>()
    
    subject.subscribe(subscriber)
    
    let subscription = subject
        .sink(
            receiveCompletion: { completion in
                print("Received completion (sink)", completion)
            },
            receiveValue: { value in
                print("Received value (sink)", value)
            }
        )
    
    subject.send("Hello")
    subject.send("World")
    subscription.cancel()
    subject.send("Still there?")
    subject.send("Another") // omitted, because reached max request count, 2+1
//    subject.send(completion: .failure(.test)) // this will also finish
    subject.send(completion: .finished)
    subject.send("Yet Another") // not reached
}
