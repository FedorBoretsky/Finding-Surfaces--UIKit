//
//  ViewController.swift
//  Finding Surfaces
//
//  Created by Fedor Boretskiy on 12.03.2022.
//

import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet var sceneView: ARSCNView!
    
    
    // MARK: - Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Setup debug
        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        
        // Use default lighting
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Set up plane recognition
        configuration.planeDetection = .horizontal
                
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - Methods
    
    /// Extract ship model from Apple's example
    /// - Returns: Ship model as node.
    func loadShip() -> SCNNode {
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let shipNode = scene.rootNode.clone()
        return shipNode
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor,
           planeAnchor.alignment == .horizontal {
            // Get plane size
            let width = CGFloat(planeAnchor.extent.x)
            let height = CGFloat(planeAnchor.extent.z)
            
            // Create plane mesh
            let plane = SCNPlane(width: width, height: height)
            plane.firstMaterial?.diffuse.contents = UIColor.green
            
            // Create plane node
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi/2
            planeNode.opacity = 0.5
            
            // Show plane node with ship
            node.addChildNode(planeNode)
            node.addChildNode(loadShip())
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor,
           planeAnchor.alignment == .horizontal {
            
            for child in node.childNodes {
                // Center every our node
                child.simdPosition = planeAnchor.center
                
                // Update size of plane
                if let plane = child.geometry as? SCNPlane {
                    plane.width = CGFloat(planeAnchor.extent.x)
                    plane.height = CGFloat(planeAnchor.extent.z)
                }
            }
        }
    }
    
}
