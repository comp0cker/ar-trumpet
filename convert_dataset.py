import scipy.io
import turicreate as tc
import os
from os import listdir
from os.path import isfile, join
 
for mode in ["training", "test"]:
    print(mode, "...")
    path = '/Users/jaredgrimes/xcode/ARTrumpet/hand_dataset/' + mode + '_dataset/' + mode + '_data/annotations'
    imagesDir = "/Users/jaredgrimes/xcode/ARTrumpet/hand_dataset/" + mode + "_dataset/" + mode + "_data/images"
    files = [f for f in listdir(path) if isfile(join(path, f))]
    annotations = []
    labels = []
    for fname in files:
        if fname != ".DS_Store":
            mat = scipy.io.loadmat(path + "/" + fname)
            entries = []

            # how many hands are in the picture
            size = mat['boxes'][0].size
            for count in range(size):
                # the first hand detected is the right hand
                # the second hand detected is the left hand
                bounds = mat['boxes'][0, count][0, 0]

                label = "right" # arbitrary
                x = float('inf')
                y = float('inf')

                max_x = 0
                max_y = 0

                # we extrapolate a reactangle that surrounds all the points
                # by taking the absolute min y and min x
                for coord in bounds:
                    if coord.size > 0:
                        # recognize the L and R label in the array
                        if coord[0] == "R":
                            label = "right"
                        elif coord[0] == "L":
                            label = "left"
                        elif coord[0].size > 1:
                            if coord[0, 0] < x:
                                x = coord[0, 0]
                            if coord[0, 1] < y:
                                y = coord[0, 1]

                            # we also set the max_x and max_y of the rectangle to be
                            # the absolute max of the coords

                            if coord[0, 0] > max_x:
                                max_x = coord[0, 0]
                            if coord[0, 1] > max_y:
                                max_y = coord[0, 1]
                
                width = max_x - x
                height = max_y - y
                xCenter = x + width / 2
                yCenter = y + height / 2
                coordinates = {'height': height, 'width': width, 'x': xCenter, 'y': yCenter}
                entry = { 'coordinates' : coordinates, 'label' : label }
                entries.append(entry)

            annotations.append(entries)
            print(fname, "done")

    sf_images = tc.image_analysis.load_images(imagesDir, random_order=False, with_path=False)
    sf_images["annotations"] = annotations
    sf_images['image_with_ground_truth'] = \
        tc.object_detector.util.draw_bounding_boxes(sf_images['image'], sf_images['annotations'])
    sf_images.save(mode + 'Hands.sframe')