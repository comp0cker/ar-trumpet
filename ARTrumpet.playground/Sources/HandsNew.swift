//
// HandsNew.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
public class HandsNewInput : MLFeatureProvider {

    /// Input image as color (kCVPixelFormatType_32BGRA) image buffer, 416 pixels wide by 416 pixels high
    public var image: CVPixelBuffer

    /// (optional) IOU Threshold override (default: 0.45) as double value
    public var iouThreshold: Double

    /// (optional) Confidence Threshold override (default: 0.25) as double value
    public var confidenceThreshold: Double

    public var featureNames: Set<String> {
        get {
            return ["image", "iouThreshold", "confidenceThreshold"]
        }
    }
    
    public func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "image") {
            return MLFeatureValue(pixelBuffer: image)
        }
        if (featureName == "iouThreshold") {
            return MLFeatureValue(double: iouThreshold)
        }
        if (featureName == "confidenceThreshold") {
            return MLFeatureValue(double: confidenceThreshold)
        }
        return nil
    }
    
    public init(image: CVPixelBuffer, iouThreshold: Double, confidenceThreshold: Double) {
        self.image = image
        self.iouThreshold = iouThreshold
        self.confidenceThreshold = confidenceThreshold
    }
}

/// Model Prediction Output Type
@available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
public class HandsNewOutput : MLFeatureProvider {

    /// Source provided by CoreML

    private let provider : MLFeatureProvider


    /// Boxes × public class confidence (see user-defined metadata "public classes") as multidimensional array of doubles
    lazy public var confidence: MLMultiArray = {
        [unowned self] in return self.provider.featureValue(for: "confidence")!.multiArrayValue
    }()!

    /// Boxes × [x, y, width, height] (relative to image size) as multidimensional array of doubles
    lazy public var coordinates: MLMultiArray = {
        [unowned self] in return self.provider.featureValue(for: "coordinates")!.multiArrayValue
    }()!

    public var featureNames: Set<String> {
        return self.provider.featureNames
    }
    
    public func featureValue(for featureName: String) -> MLFeatureValue? {
        return self.provider.featureValue(for: featureName)
    }

    public init(confidence: MLMultiArray, coordinates: MLMultiArray) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["confidence" : MLFeatureValue(multiArray: confidence), "coordinates" : MLFeatureValue(multiArray: coordinates)])
    }

    public init(features: MLFeatureProvider) {
        self.provider = features
    }
}


/// public class for model loading and prediction
@available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
public class HandsNew {
    public var model: MLModel

/// URL of model assuming it was installed in the same bundle as this public class
    public class var urlOfModelInThisBundle : URL {
        let bundle = Bundle(for: HandsNew.self)
        return bundle.url(forResource: "HandsNew", withExtension:"mlmodelc")!
    }

    /**
        Construct a model with explicit path to mlmodelc file
        - parameters:
           - url: the file url of the model
           - throws: an NSError object that describes the problem
    */
    public init(contentsOf url: URL) throws {
        self.model = try MLModel(contentsOf: url)
    }

    /// Construct a model that automatically loads the model from the app's bundle
    convenience public init() {
        try! self.init(contentsOf: type(of:self).urlOfModelInThisBundle)
    }

    /**
        Construct a model with configuration
        - parameters:
           - configuration: the desired model configuration
           - throws: an NSError object that describes the problem
    */
    convenience public init(configuration: MLModelConfiguration) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct a model with explicit path to mlmodelc file and configuration
        - parameters:
           - url: the file url of the model
           - configuration: the desired model configuration
           - throws: an NSError object that describes the problem
    */
    public init(contentsOf url: URL, configuration: MLModelConfiguration) throws {
        self.model = try MLModel(contentsOf: url, configuration: configuration)
    }

    /**
        Make a prediction using the structured interface
        - parameters:
           - input: the input to the prediction as HandsNewInput
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as HandsNewOutput
    */
    public func prediction(input: HandsNewInput) throws -> HandsNewOutput {
        return try self.prediction(input: input, options: MLPredictionOptions())
    }

    /**
        Make a prediction using the structured interface
        - parameters:
           - input: the input to the prediction as HandsNewInput
           - options: prediction options
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as HandsNewOutput
    */
    public func prediction(input: HandsNewInput, options: MLPredictionOptions) throws -> HandsNewOutput {
        let outFeatures = try model.prediction(from: input, options:options)
        return HandsNewOutput(features: outFeatures)
    }

    /**
        Make a prediction using the convenience interface
        - parameters:
            - image: Input image as color (kCVPixelFormatType_32BGRA) image buffer, 416 pixels wide by 416 pixels high
            - iouThreshold: (optional) IOU Threshold override (default: 0.45) as double value
            - confidenceThreshold: (optional) Confidence Threshold override (default: 0.25) as double value
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as HandsNewOutput
    */
    public func prediction(image: CVPixelBuffer, iouThreshold: Double, confidenceThreshold: Double) throws -> HandsNewOutput {
        let input_ = HandsNewInput(image: image, iouThreshold: iouThreshold, confidenceThreshold: confidenceThreshold)
        return try self.prediction(input: input_)
    }

    /**
        Make a batch prediction using the structured interface
        - parameters:
           - inputs: the inputs to the prediction as [HandsNewInput]
           - options: prediction options
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as [HandsNewOutput]
    */
    public func predictions(inputs: [HandsNewInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [HandsNewOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [HandsNewOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  HandsNewOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}
