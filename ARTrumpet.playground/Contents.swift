import ARKit
import SceneKit
import UIKit
import PlaygroundSupport

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

public class LiveVC: UIViewController, ARSessionDelegate, ARSCNViewDelegate {
    let scene = SCNScene()
    public var arscn = ARSCNView(frame: CGRect(x: 0,y: 0,width: 640,height: 360))
    var ship: SCNNode!
    
    private var recentFocusSquarePositions: [SCNVector3] = []

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        arscn.delegate = self
        arscn.session.delegate = self
        arscn.scene = scene
        arscn.debugOptions = [ARSCNDebugOptions.showFeaturePoints,
                                   /*ARSCNDebugOptions.showWorldOrigin,
                                   .showBoundingBoxes,
                                   .showWireframe,
                                   .showSkeletons,
                                   .showPhysicsShapes,
                                   .showCameras*/
                                 ]
        //arscn.showsStatistics = true
        arscn.session.delegate = self
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arscn.session.run(config)
        
        view.addSubview(arscn)
        
        addCoachingOverlay()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        arscn.addGestureRecognizer(tapGesture)
    }
    
    @objc func didTap(_ gesture: UIPanGestureRecognizer) {
        // Ensure ship is on screen
        guard let _ = ship else { return }

        let tapLocation = gesture.location(in: arscn)
        let results = arscn.hitTest(tapLocation, types: .featurePoint)

        if let result = results.first {
            let translation = result.worldTransform.translation
            ship.position = SCNVector3Make(translation.x, translation.y, translation.z)
            arscn.scene.rootNode.addChildNode(ship)
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let shipScn = SCNScene(named: "ship.scn", inDirectory: "art.scnassets")

        ship = shipScn?.rootNode
        ship.simdPosition = SIMD3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)

        arscn.scene.rootNode.addChildNode(ship)
        node.addChildNode(ship)
    }
    
    func addCoachingOverlay() {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [
          .flexibleWidth, .flexibleHeight
        ]
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.session = arscn.session
        
        view.addSubview(coachingOverlay)
    }

    public func session(_ session: ARSession, didFailWithError error: Error) {}
    public func sessionWasInterrupted(_ session: ARSession) {}
    public func sessionInterruptionEnded(_ session: ARSession) {}
}

var vc = LiveVC()
PlaygroundPage.current.liveView = vc
PlaygroundPage.current.needsIndefiniteExecution = true
