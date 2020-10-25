import Foundation
import ARKit

class VirtualObjectLoader {
    private(set) var loadedObjects = [VirtualObject]()
    private(set) var isLoading = false
    
    func loadVirtualObject(_ object: VirtualObject, loadedHandler: @escaping (VirtualObject) -> Void) {
        isLoading = true
        loadedObjects.append(object)
        
        // Load the content asynchronously.
        DispatchQueue.global(qos: .background).async {
            object.reset()
            object.load()

            self.isLoading = false
            loadedHandler(object)
        }
    }
        
    func removeAllVirtualObjects() {
        for index in loadedObjects.indices.reversed() {
            removeVirtualObject(at: index)
        }
    }
    
    func removeVirtualObject(at index: Int) {
        guard loadedObjects.indices.contains(index) else { return }
        
        loadedObjects[index].removeFromParentNode()
        loadedObjects.remove(at: index)
    }
}
