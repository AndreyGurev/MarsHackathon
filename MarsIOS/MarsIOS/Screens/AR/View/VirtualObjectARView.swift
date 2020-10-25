//
//  VirtualObjectARView.swift
//  MarsIOS
//
//  Created by Andrey Gurev on 24.10.2020.
//


import Foundation
import ARKit

class VirtualObjectARView: ARSCNView {
    func virtualObject(at point: CGPoint) -> VirtualObject? {
        let hitTestOptions: [SCNHitTestOption: Any] = [.boundingBoxOnly: true]
        let hitTestResults = hitTest(point, options: hitTestOptions)
        
        return hitTestResults.lazy.compactMap { result in
            return VirtualObject.existingObjectContainingNode(result.node)
        }.first
    }
    
    func smartHitTest(_ point: CGPoint,
                      infinitePlane: Bool = false,
                      objectPosition: float3? = nil,
                      allowedAlignments: [ARPlaneAnchor.Alignment] = [.horizontal, .vertical]) -> ARHitTestResult? {
        
        let results = hitTest(point, types: [.existingPlaneUsingGeometry, .estimatedVerticalPlane, .estimatedHorizontalPlane])
        
        if let existingPlaneUsingGeometryResult = results.first(where: { $0.type == .existingPlaneUsingGeometry }),
            let planeAnchor = existingPlaneUsingGeometryResult.anchor as? ARPlaneAnchor, allowedAlignments.contains(planeAnchor.alignment) {
            return existingPlaneUsingGeometryResult
        }
        
        if infinitePlane {
            let infinitePlaneResults = hitTest(point, types: .existingPlane)
            
            for infinitePlaneResult in infinitePlaneResults {
                if let planeAnchor = infinitePlaneResult.anchor as? ARPlaneAnchor, allowedAlignments.contains(planeAnchor.alignment) {
                    if planeAnchor.alignment == .vertical {
                        return infinitePlaneResult
                    } else {
                        if let objectY = objectPosition?.y {
                            let planeY = infinitePlaneResult.worldTransform.translation.y
                            if objectY > planeY - 0.05 && objectY < planeY + 0.05 {
                                return infinitePlaneResult
                            }
                        } else {
                            return infinitePlaneResult
                        }
                    }
                }
            }
        }
        
        let vResult = results.first(where: { $0.type == .estimatedVerticalPlane })
        let hResult = results.first(where: { $0.type == .estimatedHorizontalPlane })
        switch (allowedAlignments.contains(.horizontal), allowedAlignments.contains(.vertical)) {
            case (true, false):
                return hResult
            case (false, true):
                return vResult ?? hResult
            case (true, true):
                if hResult != nil && vResult != nil {
                    return hResult!.distance < vResult!.distance ? hResult! : vResult!
                } else {
                    return hResult ?? vResult
                }
            default:
                return nil
        }
    }
    
    func addOrUpdateAnchor(for object: VirtualObject) {
        if let anchor = object.anchor {
            session.remove(anchor: anchor)
        }
        
        let newAnchor = ARAnchor(transform: object.simdWorldTransform)
        object.anchor = newAnchor
        session.add(anchor: newAnchor)
    }
    
    var lightingRootNode: SCNNode? {
        return scene.rootNode.childNode(withName: "lightingRootNode", recursively: true)
    }
    
    func setupDirectionalLighting(queue: DispatchQueue) {
        guard self.lightingRootNode == nil else {
            return
        }
        
        guard let lightingScene = SCNScene(named: "lighting.scn", inDirectory: "Models.scnassets", options: nil) else {
            print("Error setting up directional lights: Could not find lighting scene in resources.")
            return
        }
        
        let lightingRootNode = SCNNode()
        lightingRootNode.name = "lightingRootNode"
        
        for node in lightingScene.rootNode.childNodes where node.light != nil {
            lightingRootNode.addChildNode(node)
        }
        
        queue.async {
            self.scene.rootNode.addChildNode(lightingRootNode)
        }
    }
    
    func updateDirectionalLighting(intensity: CGFloat, queue: DispatchQueue) {
        guard let lightingRootNode = self.lightingRootNode else {
            return
        }
        
        queue.async {
            for node in lightingRootNode.childNodes {
                node.light?.intensity = intensity
            }
        }
    }
}

extension SCNView {
    func unprojectPoint(_ point: float3) -> float3 {
        return float3(unprojectPoint(SCNVector3(point)))
    }
}
