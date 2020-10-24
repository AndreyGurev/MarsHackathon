//
//  ARViewController.swift
//  MarsIOS
//
//  Created by Andrey Gurev on 24.10.2020.
//

import UIKit
import RealityKit
import SceneKit
import ARKit

class ARViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    private static var shared: ARViewController?
    
    @IBOutlet var arView: VirtualObjectARView!
    @IBOutlet weak var addButton: UIButton!
    
    var screenCenter: CGPoint {
        let bounds = arView.bounds
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    let updateQueue = DispatchQueue(label: "com.example.apple-samplecode.arkitexample.serialSceneKitQueue")
    
    private var session: ARSession {
        return arView.session
    }
    
    static func make() -> ARViewController {
        if shared == nil {
            shared = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ARVC") as? ARViewController
        }
        return shared!
    }
        
    @IBAction func onAddTap(_ sender: Any) {
        let modelsURL = Bundle.main.url(forResource: "Models.scnassets", withExtension: nil)!

        let fileEnumerator = FileManager().enumerator(at: modelsURL, includingPropertiesForKeys: [])!

        let a:[VirtualObject] = fileEnumerator.compactMap { element in
            let url = element as! URL

            guard url.pathExtension == "scn" && !url.path.contains("lighting") else { return nil }

            return VirtualObject(url: url)
        }
        
        loadVirtualObject(a[0], loadedHandler: { [unowned self] loadedObject in
            self.arView.prepare([loadedObject], completionHandler: { _ in
                DispatchQueue.main.async {
                    guard let cameraTransform = arView.session.currentFrame?.camera.transform,
                        let result = arView.smartHitTest(
                            screenCenter,
                            infinitePlane: false,
                            objectPosition: loadedObject.simdWorldPosition,
                            allowedAlignments: loadedObject.allowedAlignments)
                        else { return }
                    
                    let planeAlignment: ARPlaneAnchor.Alignment
                    if let planeAnchor = result.anchor as? ARPlaneAnchor {
                        planeAlignment = planeAnchor.alignment
                    } else if result.type == .estimatedHorizontalPlane {
                        planeAlignment = .horizontal
                    } else if result.type == .estimatedVerticalPlane {
                        planeAlignment = .vertical
                    } else {
                        return
                    }

                    /*
                     Plane hit test results are generally smooth. If we did *not* hit a plane,
                     smooth the movement to prevent large jumps.
                     */
                    let transform = result.worldTransform
                    let isOnPlane = result.anchor is ARPlaneAnchor
                    loadedObject.setTransform(transform,
                                        relativeTo: cameraTransform,
                                        smoothMovement: !isOnPlane,
                                        alignment: planeAlignment,
                                        allowAnimation: false)
                    
                    self.arView.scene.rootNode.addChildNode(loadedObject)
                    self.arView.addOrUpdateAnchor(for: loadedObject)
                    
                    loadedObject.isHidden = false
                }
            })
        })
    }
    
    func loadVirtualObject(_ object: VirtualObject, loadedHandler: @escaping (VirtualObject) -> Void) {
        
        DispatchQueue.global(qos: .background).async {
            object.reset()
            object.load()

            loadedHandler(object)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func setupCamera() {
        guard let camera = arView.pointOfView?.camera else {
            fatalError("Expected a valid `pointOfView` from the scene.")
        }

        camera.wantsHDR = true
        camera.exposureOffset = -1
        camera.minimumExposure = -1
        camera.maximumExposure = 3
    }
    
    func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        if #available(iOS 12.0, *) {
            configuration.environmentTexturing = .automatic
        }
        session.run(configuration, options: [.resetTracking])
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arView.delegate = self
        arView.session.delegate = self

        setupCamera()
        resetTracking()
        arView.setupDirectionalLighting(queue: updateQueue)
    }
}
