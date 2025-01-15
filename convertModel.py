
import os
import sys
# os.environ["THEANO_FLAGS"] = "floatX=float32,device=cpu,force_device=True"
import numpy as np

from keras.utils import load_img, img_to_array

from keras.applications.vgg16 import preprocess_input

from keras.models import Sequential

from keras.layers import Dense, Flatten, Conv2D, Dropout, MaxPooling2D, BatchNormalization

from keras import backend as K

K.set_image_data_format('channels_first')


np.random.seed(2016)


def VGG_16(weights_path=None):

    model = Sequential()

    #layer_1
    model.add(Conv2D(64, (3, 3), strides=(1, 1), input_shape=(3, 224, 224), padding='same', activation='relu', kernel_initializer='uniform'))
    model.add(Conv2D(64, (3, 3), strides=(1, 1), padding='same', activation='relu', kernel_initializer='uniform'))
    model.add(MaxPooling2D((2, 2)))

    #layer_2
    model.add(Conv2D(128, (3, 3), strides=(1, 1), padding='same', activation='relu', kernel_initializer='uniform'))
    model.add(Conv2D(128, (3, 3), strides=(1, 1), padding='same', activation='relu', kernel_initializer='uniform'))
    model.add(MaxPooling2D((2, 2)))

    #layer_3
    model.add(Conv2D(256, (3, 3), strides=(1, 1), padding='same', activation='relu'))
    model.add(Conv2D(256, (3, 3), strides=(1, 1), padding='same', activation='relu'))
    model.add(Conv2D(256, (3, 3), strides=(1, 1), padding='same', activation='relu'))
    model.add(MaxPooling2D((2, 2)))
    #layer_4
    model.add(Conv2D(512, (3, 3), strides=(1, 1), padding='same', activation='relu'))
    model.add(Conv2D(512, (3, 3), strides=(1, 1), padding='same', activation='relu'))
    model.add(Conv2D(512, (3, 3), strides=(1, 1), padding='same', activation='relu'))
    model.add(MaxPooling2D((2, 2)))

    #layer_5
    model.add(Conv2D(512, (3, 3), strides=(1, 1), padding='same', activation='relu'))
    model.add(Conv2D(512, (3, 3), strides=(1, 1), padding='same', activation='relu'))
    model.add(Conv2D(512, (3, 3), strides=(1, 1), padding='same', activation='relu'))
    model.add(MaxPooling2D((2,2)))

    model.add(Flatten())
    model.add(Dense(4096, activation='relu'))
    model.add(Dense(4096, activation='relu'))
    model.add(Dense(1000, activation='relu'))
    # model.add(Dense(10, activation='softmax'))

    if weights_path:
        model.load_weights(weights_path)

    return model

def weight_quantize(data):
    sign = 0
    if data == 0:
        return 0
    elif data > 0:
        sign = 0
        data = data/0.6 # scalor
        data_tmp = round(data*128)
        return data_tmp
    else:
        sign = 1
        data = -data/0.6 # scalor
        data_tmp = round(data*128)
        return -data_tmp

def float2fixed(z):
    new_func = np.vectorize(weight_quantize)
    return new_func(z)


def create_weights_text_file(model, out_file):
    weights = dict()
    bias = dict()
    np.set_printoptions(precision=18)
    out = open(out_file, "w")
    weights[0], bias[0] = model.layers[0].get_weights()
    weights[1], bias[1] = model.layers[1].get_weights()
    weights[2], bias[2] = model.layers[3].get_weights()
    weights[3], bias[3] = model.layers[4].get_weights()
    weights[4], bias[4] = model.layers[6].get_weights()
    weights[5], bias[5] = model.layers[7].get_weights()
    weights[6], bias[6] = model.layers[8].get_weights()
    weights[7], bias[7] = model.layers[10].get_weights()
    weights[8], bias[8] = model.layers[11].get_weights()
    weights[9], bias[9] = model.layers[12].get_weights()
    weights[10], bias[10] = model.layers[14].get_weights()
    weights[11], bias[11] = model.layers[15].get_weights()
    weights[12], bias[12] = model.layers[16].get_weights()
    weights[13], bias[13] = model.layers[19].get_weights()
    weights[14], bias[14] = model.layers[20].get_weights()
    weights[15], bias[15] = model.layers[21].get_weights()

    # vgg16_int[layer][0] = float2fixed(model_data[layer][0]) # .astype(np.float32) # convert weights(int8)
    # vgg16_int[layer][1] = np.zeros(model_data[layer][1].shape,dtype=np.float32) # convert bias(int8)

    for z in range(13):
        weights[z] = weights[z].transpose(3,2,0,1)
        print('Shape weights {}: {}'.format(z, weights[z].shape))
        for i in range(weights[z].shape[0]):
            for j in range(weights[z].shape[1]):
                for k in range(weights[z].shape[2]):
                    for l in range(weights[z].shape[3]):
                        # out.write(str(weights[z][i, j, k, l].astype(np.float64)) + " ")
                        out.write(str(weight_quantize(weights[z][i, j, k, l])) + " ")
                        # print(str(weights[z][i, j, k, l].astype(np.float64)) + " ")
                        # print(str(weight_quantize(weights[z][i, j, k, l])) + " ")
        out.write("\n")
        print('Shape bias {}: {}'.format(z, bias[z].shape))
        for i in range(bias[z].shape[0]):
            # out.write(str(bias[z][i].astype(np.float64)) + " ")
            out.write("0 ")
        out.write("\n")

    # for z in range(13, 16):
    #     print('Shape weights {}: {}'.format(z, weights[z].shape))
    #     for i in range(weights[z].shape[0]):
    #         for j in range(weights[z].shape[1]):
    #             # out.write(str(weights[z][i, j].astype(np.float64)) + " ")
    #             out.write(str(weight_quantize(weights[z][i, j])) + " ")
    #     out.write("\n")
    #     print('Shape bias {}: {}'.format(z, bias[z].shape))
    #     for i in range(bias[z].shape[0]):
    #         # out.write(str(bias[z][i].astype(np.float64)) + " ")
    #         out.write("0 ")
    #     out.write("\n")

    out.close()


if __name__ == '__main__':

    print('Read model...')
    if len(sys.argv) != 3:
        print('Usage: python convertModel.py <path to keras weights (.h5)> <path to output weights in text format (.txt)>')
    else:
        model = VGG_16(sys.argv[1])
        print(model.summary())

        total_weight = 0
        total_out = 0
        split = (1,64,32,64,32,64,64,32,64,64,16,16,16)
        idx = 0
        for i in range(18):

            layer = model.layers[i]
            if(not layer.name.startswith("conv")):continue
            inp = layer.input_shape[1] * layer.input_shape[2] * layer.input_shape[3]
            out = layer.output_shape[1] * layer.output_shape[2] * layer.output_shape[3]
            par = layer.count_params()
            wei = (layer.get_weights()[0].shape[0] * layer.get_weights()[0].shape[1] *
                   layer.get_weights()[0].shape[2] * layer.get_weights()[0].shape[3])

            # print(layer.get_weights()[0].shape)  # (k,k,cin,cout)

            # wei /= split[idx]
            # out /= split[idx]


            # print(layer.name,":",inp/ (1024),"K\t","+",out/ (1024),"K\t","+",par/ (1024),"K\t\t",
            #       "=", "(",(inp + out + par) / (1024),"K)")
            #       "---",inp * wei/ layer.input_shape[1] / split[idx] / 1e8)
            # print(layer.name,":",inp/ (1024),"K\t","+",out/ (1024),"K\t","+",par/ (1024),"K\t\t",
            # "=", "(",(inp + out + par) / (1024),"K)",
            # "---",out * wei/ layer.output_shape[1] / 1e8)

            print(layer.name,":","(",(inp + (out * 2) + wei) / (1024),"K)",
                  "---",out * wei / layer.output_shape[1] / 1e8,
                  "----",(out * wei / layer.output_shape[1]) / (inp + (out * 2) + wei) )

            # WRAM = (62 * 1024)
            # print(layer.name,":",
            #       (WRAM - wei - out) / 1024,"K",
            #       "----",((WRAM - wei - out) / 2) % ((layer.output_shape[2]) * 14),
            #       # "----",layer.output_shape[2],
            #       # "----",layer.output_shape[1] / split[idx],
            #       # "----",layer.output_shape[1] / split[idx] * (layer.output_shape[2] * 14) / 1024,"K",
            #       # "----",((WRAM - wei) / 2 / (layer.output_shape[2] * 14)) - (layer.output_shape[1] / split[idx]),
            #       # "----",(((WRAM - wei) / 2 / (layer.output_shape[2] * 14)) - (layer.output_shape[1] / split[idx])) * (layer.output_shape[2] * 14) / 1024,"K",
            #       "----",layer.input_shape[1],
            #       )

            idx += 1

        #     total_weight += wei
        #
        # print(total_weight)


        # test_image = load_img("cat1.jpg", target_size = (224, 224))
        # x = img_to_array(test_image)
        #
        # #(1,3,224,224)
        # img = np.expand_dims(x, axis=0)
        # # 预处理 -mean
        # img = preprocess_input(img)
        #
        # # print(img)
        #
        # predict_label = model.predict(img)
        # print("predict_label:",np.argmax(predict_label))
        #
        # idx = 19
        # layer = model.layers[idx]
        #
        # print(layer.name)
        #
        # inp = model.input                                           # input placeholder
        # fun = K.function([inp], [layer.input])
        # func = K.function([inp], [layer.output])
        #
        # print("input ",layer.input_shape)
        #
        # input = fun([img])[0][0]
        #
        # for z in range(49):
        #     print(input[z])
        #
        #
        # print("weight ",layer.get_weights()[0].shape)
        # for i in range(3):
        #     print(layer.get_weights()[0][i][0],layer.get_weights()[0][i][1],layer.get_weights()[0][i][2])
        #
        # print("bias ",layer.get_weights()[1])
        #
        # print(layer.output_shape)
        # print("output in layer ",idx)
        #
        # output = func([img])[0][0]
        # for z in range(49):
        #     print(output[z])

        #
        # create_weights_text_file(model, sys.argv[2])
        # print('Complete!')






        # inp = model.input                                           # input placeholder
        # outputs = [layer.output for layer in model.layers]          # all layer outputs
        # functors = [K.function([inp], [out]) for out in outputs]    # evaluation functions
        # Testing
        # layer_outs = [func([img]) for func in functors]
        # print(layer_outs)
