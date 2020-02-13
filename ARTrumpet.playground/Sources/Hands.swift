//
// Hands.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
public class HandsInput : MLFeatureProvider {

    /// Input image as color (kCVPixelFormatType_32BGRA) image buffer, 416 pixels wide by 416 pixels high
    public var image: CVPixelBuffer

    /// The maximum allowed overlap (as intersection-over-union ratio) for any pair of output bounding boxes (default: 0.45) as optional double value
    public var iouThreshold: Double? = nil

    /// The minimum confidence score for an output bounding box (default: 0.25) as optional double value
    public var confidenceThreshold: Double? = nil

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
            return iouThreshold == nil ? nil : MLFeatureValue(double: iouThreshold!)
        }
        if (featureName == "confidenceThreshold") {
            return confidenceThreshold == nil ? nil : MLFeatureValue(double: confidenceThreshold!)
        }
        return nil
    }
    
    public init(image: CVPixelBuffer, iouThreshold: Double? = nil, confidenceThreshold: Double? = nil) {
        self.image = image
        self.iouThreshold = iouThreshold
        self.confidenceThreshold = confidenceThreshold
    }
}

/// Model Prediction Output Type
@available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
public class HandsOutput : MLFeatureProvider {

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
public class Hands {
    public var model: MLModel

/// URL of model assuming it was installed in the same bundle as this public class
    public class var urlOfModelInThisBundle : URL {
        let bundle = Bundle(for: Hands.self)
        return bundle.url(forResource: "Hands", withExtension:"mlmodelc")!
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
           - input: the input to the prediction as HandsInput
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as HandsOutput
    */
    public func prediction(input: HandsInput) throws -> HandsOutput {
        return try self.prediction(input: input, options: MLPredictionOptions())
    }

    /**
        Make a prediction using the structured interface
        - parameters:
           - input: the input to the prediction as HandsInput
           - options: prediction options
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as HandsOutput
    */
    public func prediction(input: HandsInput, options: MLPredictionOptions) throws -> HandsOutput {
        let outFeatures = try model.prediction(from: input, options:options)
        return HandsOutput(features: outFeatures)
    }

    /**
        Make a prediction using the convenience interface
        - parameters:
            - image: Input image as color (kCVPixelFormatType_32BGRA) image buffer, 416 pixels wide by 416 pixels high
            - iouThreshold: The maximum allowed overlap (as intersection-over-union ratio) for any pair of output bounding boxes (default: 0.45) as optional double value
            - confidenceThreshold: The minimum confidence score for an output bounding box (default: 0.25) as optional double value
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as HandsOutput
    */
    public func prediction(image: CVPixelBuffer, iouThreshold: Double?, confidenceThreshold: Double?) throws -> HandsOutput {
        let input_ = HandsInput(image: image, iouThreshold: iouThreshold, confidenceThreshold: confidenceThreshold)
        return try self.prediction(input: input_)
    }

    /**
        Make a batch prediction using the structured interface
        - parameters:
           - inputs: the inputs to the prediction as [HandsInput]
           - options: prediction options
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as [HandsOutput]
    */
    public func predictions(inputs: [HandsInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [HandsOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [HandsOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  HandsOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}
