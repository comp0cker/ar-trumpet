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
    //public var arscn = ARSCNView()
    public var arscn = ARSCNView(frame: CGRect(x: 0,y: 0,width: 640,height: 360))
    
    var cubeNode: SCNNode!
    // var firstValve: SCNNode!
    // var secondValve: SCNNode!
    // var thirdValve: SCNNode!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(arscn)
        
        setupSceneView()
        // addCoachingOverlay()
        addTapGestureToSceneView()
    }
    
    func setupSceneView() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arscn.session.run(config)
        
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
    }
        
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: arscn, action: #selector(handleTap(rec:)))
        arscn.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // when you tap ON THE SCREEN
    @objc func handleTap(rec: UIGestureRecognizer) {
        let alert = UIAlertController(title: "This is a trumpet.", message: "Hopefully?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        vc.present(alert, animated: true, completion: nil)
    }
    
    // initially render the plane
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        // Create a SceneKit plane to visualize the node using its position and extent.
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        // Makes the plane clear blue
        plane.materials.first?.diffuse.contents = UIColor.blue.withAlphaComponent(0.5)
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)

        // We rotate the plane to match the surface (instead of the plane standing upright)
        planeNode.eulerAngles.x = -.pi / 2

        // ARKit owns the node corresponding to the anchor, so make the plane a child node.
        node.addChildNode(planeNode)
        
        // this is the trumpet we add?
        cubeNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
        //cubeNode.position = SCNVector3(-1, -1, 0) // SceneKit/AR coordinates are in meters
        node.addChildNode(cubeNode)
    }
    
    // Update the plane as we move around
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
        let planeNode = node.childNodes.first,
        let plane = planeNode.geometry as? SCNPlane
        else { return }

        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height

        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
    
    func addCoachingOverlay() {
        let coachingOverlay = ARCoachingOverlayView()
        /*
        coachingOverlay.autoresizingMask = [
          .flexibleWidth, .flexibleHeight
        ]
 */
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
