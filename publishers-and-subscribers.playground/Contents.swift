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
