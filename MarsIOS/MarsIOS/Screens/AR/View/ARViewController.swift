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
import NVActivityIndicatorView

class ARViewController: UIViewController, NVActivityIndicatorViewable, ARSCNViewDelegate, ARSessionDelegate {
    private static var shared: ARViewController?
    
    @IBOutlet var arView: VirtualObjectARView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
    private var focusSquare = FocusSquare()
    
    private var loadedObjectsById: [String: VirtualObject] = [:]
    private var currentObject: VirtualObject?
    private var currentObjectId: String?

    private var screenCenter: CGPoint {
        let bounds = arView.bounds
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    private var session: ARSession {
        return arView.session
    }

    private let updateQueue = DispatchQueue(label: "com.example.apple-samplecode.arkitexample.serialSceneKitQueue")
    
    static func make(id: String) -> ARViewController {
        if shared == nil {
            shared = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ARVC") as? ARViewController
        }

        if (shared!.currentObjectId != id) {
            shared!.currentObjectId = id
            shared!.loadObject(completion: {})
        }
        
        return shared!
    }
        
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateFocusSquare(isObjectVisible: false)
        }
        
        // If light estimation is enabled, update the intensity of the directional lights
        if let lightEstimate = session.currentFrame?.lightEstimate {
            arView.updateDirectionalLighting(intensity: lightEstimate.ambientIntensity, queue: updateQueue)
        } else {
            arView.updateDirectionalLighting(intensity: 1000, queue: updateQueue)
        }
    }
    
    func translate(_ object: VirtualObject, basedOn screenPos: CGPoint, infinitePlane: Bool, allowAnimation: Bool) {
            guard let cameraTransform = arView.session.currentFrame?.camera.transform,
                let result = arView.smartHitTest(
                    screenPos,
                    infinitePlane: infinitePlane,
                    objectPosition: object.simdWorldPosition,
                    allowedAlignments: object.allowedAlignments)
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

        let transform = result.worldTransform
        let isOnPlane = result.anchor is ARPlaneAnchor
        object.setTransform(
            transform,
            relativeTo: arView.session.currentFrame!.camera,
            smoothMovement: !isOnPlane,
            alignment: planeAlignment,
            allowAnimation: false
        )
    }
    
    func loadObject(completion: @escaping () -> ()) {
        let modelsURL = Bundle.main.url(forResource: "Models.scnassets", withExtension: nil)!

        let fileEnumerator = FileManager().enumerator(at: modelsURL, includingPropertiesForKeys: [])!

        let modelsFromFile: [VirtualObject] = fileEnumerator.compactMap { element in
            let url = element as! URL
            
            let pathExtension = url.pathExtension
            let name = url.deletingPathExtension().lastPathComponent
            
            guard pathExtension == "dae" && name.lowercased() == currentObjectId! && !url.path.contains("lighting") else { return nil }
            return VirtualObject(url: url)
        }
        
        loadVirtualObject(modelsFromFile[0], loadedHandler: { [unowned self] loadedObject in
            self.arView.prepare([loadedObject], completionHandler: { _ in
                DispatchQueue.main.async {
                    loadedObjectsById.updateValue(loadedObject, forKey: currentObjectId!)
                    currentObject = loadedObject
            
                    completion()
                }
            })
        })
    }
    
    @IBAction func onAddTap(_ sender: Any) {
        translate(currentObject!, basedOn: screenCenter, infinitePlane: false, allowAnimation: false)
        arView.scene.rootNode.addChildNode(currentObject!)
        arView.addOrUpdateAnchor(for: currentObject!)

        currentObject!.isHidden = false
    }
    
    @IBAction func onDeleteALL(_ sender: Any) {
        arView.scene.rootNode.childNodes.forEach { node in
            node.removeFromParentNode()
        }
    }
    
    func updateFocusSquare(isObjectVisible: Bool) {
        if isObjectVisible {
            focusSquare.hide()
        } else {
            focusSquare.unhide()
        }
        
        if let camera = session.currentFrame?.camera, case .normal = camera.trackingState,
            let result = self.arView.smartHitTest(screenCenter) {
            updateQueue.async {
                self.arView.scene.rootNode.addChildNode(self.focusSquare)
                self.focusSquare.state = .detecting(hitTestResult: result, camera: camera)
            }
            addButton.isHidden = false
        } else {
            updateQueue.async {
                self.focusSquare.state = .initializing
                self.arView.pointOfView?.addChildNode(self.focusSquare)
            }
            addButton.isHidden = true
        }
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
        activityIndicator.startAnimating()
        
        loadObject(completion: {
            self.arView.delegate = self
            self.arView.session.delegate = self
            
            self.arView.scene.rootNode.addChildNode(self.focusSquare)
            
            self.setupCamera()
            self.resetTracking()
            self.arView.setupDirectionalLighting(queue: self.updateQueue)
            
            self.activityIndicator.stopAnimating()
        })
    }
}
