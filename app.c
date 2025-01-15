#include <assert.h>
#include <dpu.h>
#include <dpu_log.h>
#include <stdio.h>

#include <stdlib.h>
#include <math.h>
#include <ctype.h>
#include <string.h>
#include <time.h>
#include <omp.h>
#include <stdint.h>
//#include <cstdint>


#ifndef DPU_BINARY
#define DPU_BINARY "./task"
#endif

#define T int8_t

#define DPU_NUM 528

//#define _OPENMP 1

#define IMG_SIZE 224
#define CONV_SIZE 3


// Weights and image block START
T ***image;
int cshape[13][4] = {
        { 64, 3, CONV_SIZE, CONV_SIZE },
        { 64, 64, CONV_SIZE, CONV_SIZE },
        { 128, 64, CONV_SIZE, CONV_SIZE },
        { 128, 128, CONV_SIZE, CONV_SIZE },
        { 256, 128, CONV_SIZE, CONV_SIZE },
        { 256, 256, CONV_SIZE, CONV_SIZE },
        { 256, 256, CONV_SIZE, CONV_SIZE },
        { 512, 256, CONV_SIZE, CONV_SIZE },
        { 512, 512, CONV_SIZE, CONV_SIZE },
        { 512, 512, CONV_SIZE, CONV_SIZE },
        { 512, 512, CONV_SIZE, CONV_SIZE },
        { 512, 512, CONV_SIZE, CONV_SIZE },
        { 512, 512, CONV_SIZE, CONV_SIZE }
};
T *****wc;
T **bc;
int dshape[3][2] = {
        { 25088, 4096 },
        { 4096, 4096 },
        { 4096, 1000 }
};
T ***wd;
T **bd;


// Blocks for intermediate convolutions
int mem_block_shape[3] = {512, IMG_SIZE, IMG_SIZE};
T ***mem_block1;
T ***mem_block2;
// Blocks for dense flatten layers
int mem_block_dense_shape = { 512 * 7 * 7 };
T *mem_block1_dense;
T *mem_block2_dense;

// Weights and image block END

void reset_mem_block(T ***mem) {
    int i, j, k;
    for (i = 0; i < mem_block_shape[0]; i++) {
        for (j = 0; j < mem_block_shape[1]; j++) {
            for (k = 0; k < mem_block_shape[2]; k++) {
                mem[i][j][k] = 0.0;
            }
        }
    }
}


void reset_mem_block_dense(T *mem) {
    int i;
    for (i = 0; i < mem_block_dense_shape; i++) {
        mem[i] = 0.0;
    }
}


void init_memory() {
    int i, j, k, l;

    // Init image memory
    image = malloc(3 * sizeof(T**));
    for (i = 0; i < 3; i++) {
        image[i] = malloc(IMG_SIZE * sizeof(T*));
        for (j = 0; j < IMG_SIZE; j++) {
            image[i][j] = malloc(IMG_SIZE * sizeof(T));
        }
    }

    // Init convolution weights
    wc = malloc(13 * sizeof(T****));
    bc = malloc(13 * sizeof(T*));
    for (l = 0; l < 13; l++) {
        wc[l] = malloc(cshape[l][0] * sizeof(T***));
        for (i = 0; i < cshape[l][0]; i++) {
            wc[l][i] = malloc(cshape[l][1] * sizeof(T**));
            for (j = 0; j < cshape[l][1]; j++) {
                wc[l][i][j] = malloc(cshape[l][2] * sizeof(T*));
                for (k = 0; k < cshape[l][2]; k++) {
                    wc[l][i][j][k] = malloc(cshape[l][3] * sizeof(T));
                }
            }
        }
        bc[l] = malloc(cshape[l][0] * sizeof(T));
    }

    // Init dense weights
    wd = malloc(3 * sizeof(T**));
    bd = malloc(3 * sizeof(T*));
    for (l = 0; l < 3; l++) {
        wd[l] = malloc(dshape[l][0] * sizeof(T*));
        for (i = 0; i < dshape[l][0]; i++) {
            wd[l][i] = malloc(dshape[l][1] * sizeof(T));
        }
        bd[l] = malloc(dshape[l][1] * sizeof(T));
    }

    // Init mem_blocks
    mem_block1 = malloc(mem_block_shape[0] * sizeof(T**));
    mem_block2 = malloc(mem_block_shape[0] * sizeof(T**));
    for (i = 0; i < mem_block_shape[0]; i++) {
        mem_block1[i] = malloc(mem_block_shape[1] * sizeof(T*));
        mem_block2[i] = malloc(mem_block_shape[1] * sizeof(T*));
        for (j = 0; j < mem_block_shape[1]; j++) {
            mem_block1[i][j] = malloc(mem_block_shape[2] * sizeof(T));
            mem_block2[i][j] = malloc(mem_block_shape[2] * sizeof(T));
        }
    }
    reset_mem_block(mem_block1);
    reset_mem_block(mem_block2);

    // Init mem blocks dense
    mem_block1_dense = calloc(mem_block_dense_shape, sizeof(T));
    mem_block2_dense = calloc(mem_block_dense_shape, sizeof(T));
}


void free_memory() {
    int i, j, k, l;

    // Free image memory
    for (i = 0; i < 3; i++) {
        for (j = 0; j < IMG_SIZE; j++) {
            free(image[i][j]);
        }
        free(image[i]);
    }
    free(image);

    // Free convolution weights
    for (l = 0; l < 13; l++) {
        for (i = 0; i < cshape[l][0]; i++) {
            for (j = 0; j < cshape[l][1]; j++) {
                for (k = 0; k < cshape[l][2]; k++) {
                    free(wc[l][i][j][k]);
                }
                free(wc[l][i][j]);
            }
            free(wc[l][i]);
        }
        free(wc[l]);
        free(bc[l]);
    }
    free(wc);
    free(bc);

    // Free dense weights
    for (l = 0; l < 3; l++) {
        for (i = 0; i < dshape[l][0]; i++) {
            free(wd[l][i]);
        }
        free(wd[l]);
        free(bd[l]);
    }
    free(wd);
    free(bd);

    // Free memblocks
    for (i = 0; i < mem_block_shape[0]; i++) {
        for (j = 0; j < mem_block_shape[1]; j++) {
            free(mem_block1[i][j]);
            free(mem_block2[i][j]);
        }
        free(mem_block1[i]);
        free(mem_block2[i]);
    }
    free(mem_block1);
    free(mem_block2);

    free(mem_block1_dense);
    free(mem_block2_dense);
}


void read_weights(char *in_file, int lvls) {

    int dval;
    int i, j, k, l, z;
    FILE *iin;
    int total_lvls_read = 0;

    iin = fopen(in_file, "r");
    if (iin == NULL) {
        printf("File %s absent\n", in_file);
        exit(1);
    }

    // Reading convolution weights (store them flipped from begining)
    for (z = 0; z < 13; z++) {

        if (total_lvls_read >= lvls && lvls != -1)
            break;

        printf("Read conv block %d weights\n", z);
        for (i = 0; i < cshape[z][0]; i++) {
            for (j = 0; j < cshape[z][1]; j++) {
                for (k = 0; k < cshape[z][2]; k++) {
                    for (l = 0; l < cshape[z][3]; l++) {
                        fscanf(iin, "%d", &dval);
                        wc[z][i][j][k][l] = dval;
                    }
                }
            }
        }
        for (i = 0; i < cshape[z][0]; i++) {
            fscanf(iin, "%d", &dval);
            bc[z][i] = dval;
        }

        total_lvls_read += 1;
    }

    for(int i = 0;i < 3;i ++) {
        for(int j = 0;j < 3;j ++)
            printf("%d %d %d\n",wc[12][0][i][j][0],
                   wc[12][0][i][j][1],wc[12][0][i][j][2]);
    }

//    printf("%d %d %d\n",wc[0][0][0][0][0],wc[0][0][0][0][1],wc[0][0][0][0][2]);

    // Reading dense weights
    for (z = 0; z < 3; z++) {

        if (total_lvls_read >= lvls && lvls != -1)
            break;

        printf("Read dense block %d weights\n", z);
        for (i = 0; i < dshape[z][0]; i++) {
            for (j = 0; j < dshape[z][1]; j++) {
                fscanf(iin, "%d", &dval);
                wd[z][i][j] = dval;
            }
        }
        for (i = 0; i < dshape[z][1]; i++) {
            fscanf(iin, "%d", &dval);
            bd[z][i] = dval;
        }

        total_lvls_read += 1;
    }

    fclose(iin);
}


void read_image(char *in_file) {
    int i, j, l;
    FILE *iin;
    float dval;

    iin = fopen(in_file, "r");
    if (iin == NULL) {
        printf("File %s absent\n", in_file);

        exit(1);
    }
    printf("reading... %s\n", in_file);

    /* Reading image */
    for (i = 0; i < 3; i++) {
        for (j = 0; j < IMG_SIZE; j++) {
            for (l = 0; l < IMG_SIZE; l++) {
                fscanf(iin, "%f", &dval);
                image[i][j][l] = (T)dval;
            }
        }
    }
//    printf("%d %d %d\n",image[0][0][0],image[1][0][0],image[2][0][0]);

    fclose(iin);
}


void convolution_3_x_3(T **matrix, T **kernel, T **out, int size) {
    int i, j;
    T sum;
    T zeropad[IMG_SIZE + 2][IMG_SIZE + 2] = {0.0 };

    for (i = 0; i < size; i++) {
        for (j = 0; j < size; j++) {
            zeropad[i + 1][j + 1] = matrix[i][j];
        }
    }

    for (i = 0; i < size; i++) {
        for (j = 0; j < size; j++) {
            sum = zeropad[i][j] * kernel[0][0] +
                  zeropad[i + 1][j] * kernel[1][0] +
                  zeropad[i + 2][j] * kernel[2][0] +
                  zeropad[i][j + 1] * kernel[0][1] +
                  zeropad[i + 1][j + 1] * kernel[1][1] +
                  zeropad[i + 2][j + 1] * kernel[2][1] +
                  zeropad[i][j + 2] * kernel[0][2] +
                  zeropad[i + 1][j + 2] * kernel[1][2] +
                  zeropad[i + 2][j + 2] * kernel[2][2];
            out[i][j] += sum;
        }
    }

}

//
void add_bias_and_relu(T **out, T bs, int size) {
    int i, j;

    for (i = 0; i < size; i++) {
        for (j = 0; j < size; j++) {
            out[i][j] += bs;
            if (out[i][j] < 0)
                out[i][j] = 0.0;
            // printf("%.12lf\n", out_HW[i][j]);
        }
    }
}


void add_bias_and_relu_flatten(T *out, T *bs, int size, int relu) {
    int i;
    for (i = 0; i < size; i++) {
        out[i] += bs[i];
        if (relu == 1) {
            if (out[i] < 0)
                out[i] = 0.0;
        }
    }
}


T max_of_4(T a, T b, T c, T d) {
    if (a >= b && a >= c && a >= d) {
        return a;
    }
    if (b >= c && b >= d) {
        return b;
    }
    if (c >= d) {
        return c;
    }
    return d;
}


void maxpooling(T **out, int size) {
    int i, j;
    for (i = 0; i < size; i+=2) {
        for (j = 0; j < size; j+=2) {
            out[i / 2][j / 2] = max_of_4(out[i][j], out[i + 1][j], out[i][j + 1], out[i + 1][j + 1]);
        }
    }
}

//根据python那边的情况，注意这里的维度，先收集的是通道维度
void flatten(T ***in, T *out, int sh0, int sh1, int sh2) {
    int i, j, k, total = 0;
    for (i = 0; i < sh1; i++) {
        for (j = 0; j < sh2; j++) {
            for (k = 0; k < sh0; k++) {
                out[total] = in[k][i][j];
                total += 1;
            }
        }
    }
}

void dense(T *in, T **weights, T *out, int sh_in, int sh_out) {
    int i, j;

    for (i = 0; i < sh_out; i++) {
        T sum = 0.0;
        for (j = 0; j < sh_in; j++) {
            sum += in[j] * weights[j][i];
        }
        out[i] = sum;
    }
}

void conv1(T *** mem_block1){

    int i, j;
    int level, cur_size;

    reset_mem_block(mem_block1);

    level = 0;
    cur_size = IMG_SIZE;
    for (i = 0; i < cshape[level][0]; i++) {
        for (j = 0; j < cshape[level][1]; j++) {
            convolution_3_x_3(image[j], wc[level][i][j], mem_block1[i], cur_size);

        }
        add_bias_and_relu(mem_block1[i], bc[level][i], cur_size);
    }

}

void mlp(T *** mem_block1) {
    int i, j;
    int level, cur_size;

    reset_mem_block_dense(mem_block1_dense);
    reset_mem_block_dense(mem_block2_dense);

    level = 12;
    cur_size = 7;


    printf("Flatten\n");

    // Layer 19 (Flatten)
    flatten(mem_block1, mem_block1_dense, cshape[level][0], cur_size, cur_size);

    // Layer 20 (Dense)
    level = 0;
    dense(mem_block1_dense, wd[level], mem_block2_dense, dshape[level][0], dshape[level][1]);
    add_bias_and_relu_flatten(mem_block2_dense, bd[level], dshape[level][1], 1);
    reset_mem_block_dense(mem_block1_dense);

    // Layer 21 (Dense)
    level = 1;
    dense(mem_block2_dense, wd[level], mem_block1_dense, dshape[level][0], dshape[level][1]);
    add_bias_and_relu_flatten(mem_block1_dense, bd[level], dshape[level][1], 1);
    reset_mem_block_dense(mem_block2_dense);

    // Layer 22 (Dense)
    level = 2;
    dense(mem_block1_dense, wd[level], mem_block2_dense, dshape[level][0], dshape[level][1]);
    add_bias_and_relu_flatten(mem_block2_dense, bd[level], dshape[level][1], 1);

    printf("\ninput:\n");
    for(int z = 0;z < 49;z ++){
        printf("%d ",mem_block1_dense[z]);
    }
    printf("\nweight:\n");
    for(int z = 0;z < 3;z ++){
        for(int t = 0;t < 3;t ++){
            printf("%d ",wd[level][z][t]);
        }
    }
    printf("\noutput:\n");
    for(int z = 0;z < 49;z ++){
        printf("%d ",mem_block2_dense[z]);
    }
    printf("\n");

//    softmax(mem_block2_dense, dshape[level][1]);
    // dump_memory_structure_dense_to_file(mem_block2_dense, dshape[level][1]);

    int idx = 0;
    T max = 0.0;
    for(i = 0;i < 1000;i ++){
        if(mem_block2_dense[i] > max) {
            max = mem_block2_dense[i];
            idx = i;
        }
    }
    printf("\n predict class: %d \n",idx);
}


int align8(int size){

    if(size % 8 == 0) return size;
    else return size / 8 * 8 + 8;
}


int main(int argc, char *argv[]) {

    struct dpu_set_t set[12], dpu;
    int nr_dpus,idx;

    char *weights_file = "weights1.txt";
    char *image_file = "cat1.txt";
    char *output_file = "results.txt";
    int lvls = 13;


    init_memory();
//  1.加载weight
    read_weights(weights_file, lvls);

//  2.申请dpu，分配数据,（img和kernel(输出通道/split)）,CPU DRAM数据传到DPU MRAM
//  3.dpu需要把数据搬到WRAM才能计算(可使用fuse,算到最后一层conv)
    T split[12] = {64,32,64,32,64,64,
                 32,64,64,16,16,16};  //共申请528个dpu

    T input[64 * IMG_SIZE * IMG_SIZE];
    T weights[512 * 512 * 3 * 3];
//    int weight_offset = 0;
    int idz = 0;

    //分配12组dpu，和每组上面的weight
    for(int i = 0;i < 2;i ++){

        DPU_ASSERT(dpu_alloc(split[i], NULL, &set[i])); //申请
        DPU_ASSERT(dpu_load(set[i], DPU_BINARY, NULL));//装程序
        DPU_ASSERT(dpu_get_nr_dpus(set[i], &nr_dpus)); //dpu数

        int z = i + 1;  //从第二层开始
        //取出每一层，按计算负载切输出通道，分给不同数量的dpu
        int cout_per_dpu = cshape[z][0] / split[i];
        int size = (cout_per_dpu * cshape[z][1] * cshape[z][2] * cshape[z][3]);
        idz = 0;
        //之前用申请指针方式拿到的数组不是连续的空间（每次malloc出来的可能不挨着？）
        for(int i = 0;i < cshape[z][0];i ++)
            for(int j = 0;j < cshape[z][1];j ++)
                for(int k = 0;k < cshape[z][2];k ++)
                    for(int t = 0;t < cshape[z][3];t ++)
                        weights[idz ++] = wc[z][i][j][k][t];

        DPU_FOREACH(set[i], dpu, idx) {
            DPU_ASSERT(dpu_prepare_xfer(dpu, &weights[idx * size]));
        }
        //----------"weight"
        DPU_ASSERT(dpu_push_xfer(set[i], DPU_XFER_TO_DPU, "weight", 0,
                                 align8(size * sizeof(T)), DPU_XFER_DEFAULT));

    }

    //加载img
    read_image(image_file);
    //为了负载均衡，第一层在cpu算
    conv1(mem_block1);
    printf("conv1 done~\n");

    //conv1结果作为输入广播给第一个set
    for(int i = 0;i < 64;i ++)
        for(int j = 0;j < IMG_SIZE;j ++)
            for(int k = 0;k < IMG_SIZE;k ++)
                input[idz ++] = mem_block1[i][j][k];

    //开始pipeline,z为流水段数
    for(int z = 0;z < 1;z ++){

        //64dpu * 3136k
//        DPU_FOREACH(set[0], dpu, idx) {
//            DPU_ASSERT(dpu_prepare_xfer(dpu, input));
//        }
//        DPU_ASSERT(dpu_push_xfer(set[0], DPU_XFER_TO_DPU, "input", 0,
//                                 (IMG_SIZE * IMG_SIZE * 64 * sizeof(T)), DPU_XFER_DEFAULT));

        DPU_ASSERT(dpu_broadcast_to(set[0], "input", 0, input,
                                    (IMG_SIZE * IMG_SIZE * 64 * sizeof(T)), DPU_XFER_DEFAULT));

        DPU_ASSERT(dpu_launch(set[0], DPU_ASYNCHRONOUS));   //试试异步，不行就开线程   DPU_SYNCHRONOUS


        read_image(image_file);
        conv1(mem_block1);
        printf("conv1 done~\n");
        for(int i = 0;i < 64;i ++)
            for(int j = 0;j < IMG_SIZE;j ++)
                for(int k = 0;k < IMG_SIZE;k ++)
                    input[idz ++] = mem_block1[i][j][k];

        dpu_sync(set[0]);



    }



    for(int i = 0;i < 2;i ++){

        DPU_FOREACH(set[i], dpu) {
            DPU_ASSERT(dpu_log_read(dpu, stdout));
        }

    }


    //  4.所有结果回传拼在一起，进入fc


    for(int i = 0;i < 2;i ++)
        DPU_ASSERT(dpu_free(set[i]));

    free_memory();
    return 0;
}

//int sum(int **a,int n,int m) {
//    //此处**a也可写为*a[]
//    //*p[]在传递时退化为指针，即指针数组的指针
//    int s = 0, i, j;
//    for (i = 0; i < n; i++) {
//        for (j = 0; j < m; j++) {
//            s += a[i][j];
//        }
//    }
//    return s;
//}


//void trans{
//
//        T weights[512 * 512 * 3 * 3];
//
//        int weight_offset = 0;
//        for(int z = 0;z < lvls;z ++){
//            //取出每一层，然后按输出通道平分给dpu
//            //每层维度不同，这里是分别传输；如果只传一次就要拼成一维数组
//            //那边如果用一维数组算比较麻烦(还得定位每一层)，如果还原回多维，就要浪费额外的时间和空间
//            //如果dpu多了，通道少的层会不满足8字节的整数倍，没办法直接传给多维数组，所以每层都用一维数组接，可以align8
//            int cout_per_dpu = cshape[z][0] / DPU_NUM;
//            int size = (cout_per_dpu * cshape[z][1] * cshape[z][2] * cshape[z][3]);
//            idz = 0;
//            for(int i = 0;i < cshape[z][0];i ++)
//                for(int j = 0;j < cshape[z][1];j ++)
//                    for(int k = 0;k < cshape[z][2];k ++)
//                        for(int t = 0;t < cshape[z][3];t ++)
//                            weights[idz ++] = wc[z][i][j][k][t];
//
//            DPU_FOREACH(set, dpu, idx) {
//                // 传输可以并行吗？
//                // TODO：看看数据排布会不会影响传输速度
//                DPU_ASSERT(dpu_prepare_xfer(dpu, &weights[idx * size]));
//            }
//
//            char weight_lv[8];
//            sprintf(weight_lv,"%s%d","weight",z + 1);
//            printf("%s\n",weight_lv);
//            DPU_ASSERT(dpu_push_xfer(set, DPU_XFER_TO_DPU, weight_lv, 0,
//                                     align8(size * sizeof(T)), DPU_XFER_DEFAULT));
//
////        DPU_ASSERT(dpu_push_xfer(set, DPU_XFER_TO_DPU, "weights", weight_offset,
////                                 size * sizeof(T), DPU_XFER_DEFAULT));
////        weight_offset += size;
//
//        }
//
//}




