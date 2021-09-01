import Foundation
import Combine

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
