import turicreate as tc

train_data =  tc.SFrame('trainingHands.sframe')
test_data =  tc.SFrame('testHands.sframe')

# Create a model
model = tc.object_detector.create(train_data, feature='image', max_iterations=120)

# Save predictions to an SArray
predictions = model.predict(test_data)

# Evaluate the model and save the results into a dictionary
metrics = model.evaluate(test_data)

# Export for use in Core ML
model.export_coreml('Hands.mlmodel')