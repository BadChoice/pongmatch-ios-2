import EventKit
import Combine

class CalendarManager: ObservableObject {
    private let store = EKEventStore()
    
    func requestAccess(completion: @escaping (Bool) -> Void) {
        store.requestWriteOnlyAccessToEvents { granted, error in
            DispatchQueue.main.async {
                completion(granted && error == nil)
            }
        }        
    }
    
    func addEvent(title: String, startDate: Date, endDate: Date) throws {
        let event = EKEvent(eventStore: store)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = store.defaultCalendarForNewEvents
        
        try store.save(event, span: .thisEvent)
    }
}
