
import cv2
import sys

import numpy as np

from keras.utils import load_img, img_to_array

from keras.applications.vgg16 import preprocess_input

from keras import backend as K

K.set_image_data_format('channels_first')


def gen_text_from_image(in_path, out_path):
    # img = cv2.imread(in_path)
    # if img.shape != (224, 224, 3):
    #     img = cv2.resize(img, (224, 224), interpolation=cv2.INTER_LANCZOS4)
    #
    # print(img)
    test_image = load_img(in_path, target_size = (224, 224))
    x = img_to_array(test_image)
    print(x)

    #(1,3,224,224)
    # tensor = np.expand_dims(x, axis=0)
    # 预处理 -mean
    img = preprocess_input(x)

    print(img)
    # (3,224,224)
    out = open(out_path, "w")
    for i in range(img.shape[0]):
        for j in range(img.shape[1]):
            for k in range(img.shape[2]):
                out.write(str(img[i, j, k]) + " ")
            out.write("\n")
        out.write("\n")
    out.close()


if __name__ == '__main__':
    print('Convert image...')
    if len(sys.argv) != 3:
        print('Usage: python convertImg.py <path to input image (.jpg, .png)> <path to output image in text format (.txt)>')
    else:
        in_path = sys.argv[1]
        out_path = sys.argv[2]
        gen_text_from_image(in_path, out_path)
        print('Complete!')