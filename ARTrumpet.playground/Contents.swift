import Foundation
import ARKit
import SceneKit
import UIKit
import PlaygroundSupport
import Vision
import CoreML

public class LiveVC: UIViewController, ARSessionDelegate, ARSCNViewDelegate {
    let scene = SCNScene()
    //public var arscn = ARSCNView()
    public var arscn = ARSCNView(frame: CGRect(x: 0,y: 0,width: 640,height: 360))
    
    
    var cubeNode: SCNNode!
    private var visionRequests = [VNRequest]()
    var trackingRequests = [VNTrackObjectRequest]()
    var imageTrackHandler = VNSequenceRequestHandler()
    
    private var timer: Timer! = Timer()
    private var handState: String = "none"
    let handsModel = HandsNew().model
    var handBox: SCNBox!
    var shouldScanNewHands: Bool = true
    var boxOnScreen: Bool = false
    var confidence: Float = 0.1
    
    var animating: Bool = false

    func animate() {
        
        if animating { return }
        animating = true
        
        let rotateOne = SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi * 2), z: 0, duration: 5.0)
        let repeatForever = SCNAction.repeatForever(rotateOne)

        cubeNode.runAction(repeatForever)
    }
    
    func stopAnimating() {
        cubeNode.removeAllActions()
        animating = false
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(arscn)
        
        setupSceneView()
        // addCoachingOverlay()
        // addTapGestureToSceneView()
        setupCoreML()
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(loopCoreMLUpdate), userInfo: nil, repeats: true)
    }
    
    func setupCoreML() {
        guard let selectedModel = try? VNCoreMLModel(for: handsModel) else {
            renderAlert(message: "could not load model")
            return
        }
        
        let classificationRequest = VNCoreMLRequest(model: selectedModel,
                                                    completionHandler: self.classificationCompleteHandler)
        // classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop // Crop from centre of images and scale to appropriate size.
        self.visionRequests = [classificationRequest]
    }
    
    func updateCoreML() {
        let pixbuff : CVPixelBuffer? = (arscn.session.currentFrame?.capturedImage)
        if pixbuff == nil { return }
        
        let deviceOrientation = UIDevice.current.orientation.getImagePropertyOrientation()
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixbuff!, orientation: deviceOrientation,options: [:])
        do {
            if shouldScanNewHands {
                try imageRequestHandler.perform(self.visionRequests)
            } else {
                try imageTrackHandler.perform(trackingRequests, on: pixbuff!)
            }
        } catch {
            renderAlert(message: "imageRequestHandler processing failed")
        }
    }
    
    func handleHand(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            //perform all the UI updates on the main queue
            guard let observation = request.results?.first as? VNDetectedObjectObservation else {
                return
            }
            
            /*
            if self.trackingRequests.count > 0 {
                for i in 0...self.trackingRequests.count - 1 {
                    
                    if self.trackingRequests[i].inputObservation.uuid == observation.uuid {
                        self.trackingRequests[i].inputObservation = observation
                    }
                }
            }
 */
            
            //guard observation.confidence >= self.confidence else {
            //    //arscn.removeMask(id: observation.uuid.uuidString)
            //    return
            //}
            
            //self.previewView.removeMask(id: observation.uuid.uuidString)
            //self.previewView.drawHandBoundingBox(hand: observation, id: observation.uuid.uuidString, shortname: self.predictedHands[observation.uuid])
            
            let frameSize = CGSize(width: CVPixelBufferGetWidth(self.arscn.session.currentFrame!.capturedImage), height: CVPixelBufferGetHeight(self.arscn.session.currentFrame!.capturedImage))

            let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -frameSize.height)
            let translate = CGAffineTransform.identity.scaledBy(x: frameSize.width, y: frameSize.height)
            
            let handbounds = observation.boundingBox.applying(translate).applying(transform)
            
            //let zoom = handbounds.size.width / 3.0
            
            //let fr = CGRect(x: handbounds.origin.x - zoom, y: handbounds.origin.y - zoom - 5, width: handbounds.size.width + 2*zoom, height: handbounds.size.height + 2*zoom)
            
            if !self.boxOnScreen {
                let handBox = SCNBox(width: 0.1, height: 0.1, length: 0.2, chamferRadius: 0)
                //handBox.materials.first?.diffuse.contents = UIColor.red.withAlphaComponent(0.5)
                
                //self.renderAlert(message: "\(Float(handbounds.origin.x)), \(Float(handbounds.origin.y))")
                
                let handBoxNode = SCNNode(geometry: handBox)
                handBoxNode.position = SCNVector3Make((Float(handbounds.origin.x) - 1000) / 1500, (Float(handbounds.origin.y) - 500) / 2000, -1)
                
                //self.arscn.pointOfView?.enumerateChildNodes{(node, stop) in node.removeFromParentNode()
                self.arscn.pointOfView?.addChildNode(handBoxNode)
            }
            else {
                self.arscn.pointOfView?.enumerateChildNodes{(node, stop) in node.position = SCNVector3Make((Float(handbounds.origin.x) - 1000) / 1500, (Float(handbounds.origin.y) - 500) / 2000, -1)}
            }
        }
    }
    
    private func classificationCompleteHandler(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            if error != nil {
                print("Error: " + (error?.localizedDescription)!)
                self.renderAlert(message: "noooo")
                return
            }
            guard let observations = request.results as? [VNRecognizedObjectObservation] else {
                self.renderAlert(message: "nuts")
                return
            }
            /*
            let classifications = observations[0...2]
                .compactMap({ $0 as? VNClassificationObservation })
                .map({ "\($0.identifier) \(String(format:" : %.2f", $0.confidence))" })
                .joined(separator: "\n")
     */
            if observations.count == 0 {
                self.shouldScanNewHands = true
            }
            
            for result in observations {
                //self.renderAlert(message: "hi")
                
                if result.confidence >= 0 {
                    self.shouldScanNewHands = false
                    let trackingRequest = VNTrackObjectRequest(detectedObjectObservation: result, completionHandler: self.handleHand)
                    trackingRequest.trackingLevel = .accurate
                    self.trackingRequests.append(trackingRequest)
            }
            }
    /*
            print("Classifications: \(classifications)")
            
            DispatchQueue.main.async {
                let topPrediction = classifications.components(separatedBy: "\n")[0]
                let topPredictionName = topPrediction.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
                guard let topPredictionScore: Float = Float(topPrediction.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces)) else { return }
                
                if self.cubeNode == nil {
                    return
                }
                
                if topPredictionName == "openFist" {
                    self.animate()
                }
                else {
                    self.stopAnimating()
                }
            }
     */
        }
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
        arscn.showsStatistics = true
    }
    /*
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: arscn, action: #selector(handleTap(rec:)))
        arscn.addGestureRecognizer(tapGestureRecognizer)
    }
 */
    
    func renderAlert() {
        let alert = UIAlertController(title: "This is a trumpet.", message: "Hopefully?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        vc.present(alert, animated: true, completion: nil)
    }
    
    func renderAlert(message: String) {
        let alert = UIAlertController(title: "This is a trumpet.", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        vc.present(alert, animated: true, completion: nil)
    }
    
    // when you tap ON THE SCREEN
    @objc func handleTap(rec: UIGestureRecognizer) {
        renderAlert()
    }
    
    // updates the coreML detection constantly
    @objc func loopCoreMLUpdate() {
        DispatchQueue.main.async {
            self.updateCoreML()
        }
    }
    
    // initially render the plane
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        /*
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
        //addAnimation(node: cubeNode)
        //cubeNode.position = SCNVector3(-1, -1, 0) // SceneKit/AR coordinates are in meters
        node.addChildNode(cubeNode)
 */
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
