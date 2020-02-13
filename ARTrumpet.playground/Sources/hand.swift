//
// hand.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public class handInput : MLFeatureProvider {

    /// data as color (kCVPixelFormatType_32BGRA) image buffer, 227 pixels wide by 227 pixels high
    public var data: CVPixelBuffer

    public var featureNames: Set<String> {
        get {
            return ["data"]
        }
    }
    
    public func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "data") {
            return MLFeatureValue(pixelBuffer: data)
        }
        return nil
    }
    
    public init(data: CVPixelBuffer) {
        self.data = data
    }
}

/// Model Prediction Output Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public class handOutput : MLFeatureProvider {

    /// Source provided by CoreML

    private let provider : MLFeatureProvider


    /// loss as dictionary of strings to doubles
    lazy public var loss: [String : Double] = {
        [unowned self] in return self.provider.featureValue(for: "loss")!.dictionaryValue as! [String : Double]
    }()

    /// public classLabel as string value
    lazy public var classLabel: String = {
        [unowned self] in return self.provider.featureValue(for: "public classLabel")!.stringValue
    }()

    public var featureNames: Set<String> {
        return self.provider.featureNames
    }
    
    public func featureValue(for featureName: String) -> MLFeatureValue? {
        return self.provider.featureValue(for: featureName)
    }

    public init(loss: [String : Double], public classLabel: String) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["loss" : MLFeatureValue(dictionary: loss as [AnyHashable : NSNumber]), "public classLabel" : MLFeatureValue(string: classLabel)])
    }

    public init(features: MLFeatureProvider) {
        self.provider = features
    }
}


/// public class for model loading and prediction
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public class hand {
    public var model: MLModel

/// URL of model assuming it was installed in the same bundle as this public class
    public class var urlOfModelInThisBundle : URL {
        let bundle = Bundle(for: hand.self)
        return bundle.url(forResource: "hand", withExtension:"mlmodelc")!
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
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
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
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
    public init(contentsOf url: URL, configuration: MLModelConfiguration) throws {
        self.model = try MLModel(contentsOf: url, configuration: configuration)
    }

    /**
        Make a prediction using the structured interface
        - parameters:
           - input: the input to the prediction as handInput
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as handOutput
    */
    public func prediction(input: handInput) throws -> handOutput {
        return try self.prediction(input: input, options: MLPredictionOptions())
    }

    /**
        Make a prediction using the structured interface
        - parameters:
           - input: the input to the prediction as handInput
           - options: prediction options
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as handOutput
    */
    public func prediction(input: handInput, options: MLPredictionOptions) throws -> handOutput {
        let outFeatures = try model.prediction(from: input, options:options)
        return handOutput(features: outFeatures)
    }

    /**
        Make a prediction using the convenience interface
        - parameters:
            - data as color (kCVPixelFormatType_32BGRA) image buffer, 227 pixels wide by 227 pixels high
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as handOutput
    */
    public func prediction(data: CVPixelBuffer) throws -> handOutput {
        let input_ = handInput(data: data)
        return try self.prediction(input: input_)
    }

    /**
        Make a batch prediction using the structured interface
        - parameters:
           - inputs: the inputs to the prediction as [handInput]
           - options: prediction options
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as [handOutput]
    */
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
    public func predictions(inputs: [handInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [handOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [handOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  handOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}
