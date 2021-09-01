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
