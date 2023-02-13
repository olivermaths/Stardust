internal class EventManager{
    var callbackPool : Array<(EventType)->()>
    init(){
        callbackPool = []
    }

    func register(callback: @escaping (EventType) -> ()){
        callbackPool.append(callback)
    }

    func dispath(event: EventType){
        for callback in callbackPool{
            callback(event)
        }
    }
}
let eventsystem = EventManager()

protocol EventType{}


struct WindowResize : EventType{}
struct WindowClose : EventType{}
