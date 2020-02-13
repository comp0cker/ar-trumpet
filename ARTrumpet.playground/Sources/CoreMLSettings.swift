import Foundation
import ARKit
import SceneKit
import UIKit
import PlaygroundSupport
import Vision
import CoreML

/**
 The frequency that the ML tracking updates at. Measured in seconds.
 */
public let coreMLUpdateFrequency: Double = 1

/**
The serial queue that the coreML operations run off of. Can be set to DispatchQueue.global() to get background queue.
*/
public let coreMLserialQueue = DispatchQueue(label: "com.jaredgrimes.dispatchqueueml")
