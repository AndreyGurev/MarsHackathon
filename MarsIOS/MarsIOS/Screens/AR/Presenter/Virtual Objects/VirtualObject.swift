import Foundation
import SceneKit
import ARKit

class VirtualObject: SCNReferenceNode {
    private var recentVirtualObjectDistances = [Float]()
    
    var modelName: String {
        return referenceURL.lastPathComponent.replacingOccurrences(of: ".scn", with: "")
    }
    
    var allowedAlignments: [ARPlaneAnchor.Alignment] {
        if modelName == "sticky note" {
            return [.horizontal, .vertical]
        } else if modelName == "painting" {
            return [.vertical]
        } else {
            return [.horizontal]
        }
    }
    
    var currentAlignment: ARPlaneAnchor.Alignment = .horizontal
    private var isChangingAlignment: Bool = false
    
    var objectRotation: Float {
        get {
            return childNodes.first!.eulerAngles.y
        }
        set (newValue) {
            var normalized = newValue.truncatingRemainder(dividingBy: 2 * .pi)
            normalized = (normalized + 2 * .pi).truncatingRemainder(dividingBy: 2 * .pi)
            if normalized > .pi {
                normalized -= 2 * .pi
            }
            childNodes.first!.eulerAngles.y = normalized
            if currentAlignment == .horizontal {
                rotationWhenAlignedHorizontally = normalized
            }
        }
    }
    
    var rotationWhenAlignedHorizontally: Float = 0
    var anchor: ARAnchor?
    func reset() {
        recentVirtualObjectDistances.removeAll()
    }
    
    func isPlacementValid(on planeAnchor: ARPlaneAnchor?) -> Bool {
        if let anchor = planeAnchor {
            return allowedAlignments.contains(anchor.alignment)
        }
        return true
    }
    
    func setTransform(_ newTransform: float4x4,
                      relativeTo camera: ARCamera,
                      smoothMovement: Bool,
                      alignment: ARPlaneAnchor.Alignment,
                      allowAnimation: Bool) {
        let cameraWorldPosition = camera.transform.translation
        var positionOffsetFromCamera = newTransform.translation - cameraWorldPosition
        
        if simd_length(positionOffsetFromCamera) > 10 {
            positionOffsetFromCamera = simd_normalize(positionOffsetFromCamera)
            positionOffsetFromCamera *= 10
        }

        if smoothMovement {
            let hitTestResultDistance = simd_length(positionOffsetFromCamera)
            
            recentVirtualObjectDistances.append(hitTestResultDistance)
            recentVirtualObjectDistances = Array(recentVirtualObjectDistances.suffix(10))
            
            let averageDistance = recentVirtualObjectDistances.average!
            let averagedDistancePosition = simd_normalize(positionOffsetFromCamera) * averageDistance
            simdPosition = cameraWorldPosition + averagedDistancePosition
        } else {
            simdPosition = cameraWorldPosition + positionOffsetFromCamera
        }
        
        updateAlignment(to: alignment, transform: newTransform, allowAnimation: allowAnimation, camera: camera)
    }
    
    func updateAlignment(to newAlignment: ARPlaneAnchor.Alignment, transform: float4x4, allowAnimation: Bool, camera: ARCamera) {
        if isChangingAlignment {
            return
        }
        
        let animationDuration = (newAlignment != currentAlignment && allowAnimation) ? 0.5 : 0
        
        var newObjectRotation: Float?
        switch (newAlignment, currentAlignment) {
        case (.horizontal, .horizontal):
            newObjectRotation = camera.eulerAngles.y
        case (.horizontal, .vertical):
            newObjectRotation = rotationWhenAlignedHorizontally
        case (.vertical, .horizontal):
            newObjectRotation = 0.0001
        default:
            break
        }
        
        currentAlignment = newAlignment
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = animationDuration
        SCNTransaction.completionBlock = {
            self.isChangingAlignment = false
        }
        
        isChangingAlignment = true
        
        var mutableTransform = transform
        mutableTransform.translation = simdWorldPosition
        simdTransform = mutableTransform
        
        if newObjectRotation != nil {
            objectRotation = newObjectRotation!
        }
        
        SCNTransaction.commit()
    }
}

extension VirtualObject {
    static let availableObjects: [VirtualObject] = {
        let modelsURL = Bundle.main.url(forResource: "Models.scnassets", withExtension: nil)!

        let fileEnumerator = FileManager().enumerator(at: modelsURL, includingPropertiesForKeys: [])!

        return fileEnumerator.compactMap { element in
            let url = element as! URL

            guard url.pathExtension == "scn" && !url.path.contains("lighting") else { return nil }

            return VirtualObject(url: url)
        }
    }()
    
    static func existingObjectContainingNode(_ node: SCNNode) -> VirtualObject? {
        if let virtualObjectRoot = node as? VirtualObject {
            return virtualObjectRoot
        }
        
        guard let parent = node.parent else { return nil }
        
        return existingObjectContainingNode(parent)
    }
}

extension Collection where Element == Float, Index == Int {
    var average: Float? {
        guard !isEmpty else {
            return nil
        }

        let sum = reduce(Float(0)) { current, next -> Float in
            return current + next
        }

        return sum / Float(count)
    }
}
