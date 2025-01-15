#include <stdio.h>
#include <mram.h>
#include <stdbool.h>
#include <stdint.h>
#include <defs.h>
#include <mram_unaligned.h>

#define C_in 3
#define C_out 3
#define T int8_t
#define H_ 8
#define W_ 8
#define K_ 3
#define S_ 1

#define ALIGN8(x) x % 8 == 0 ? x : x / 8 * 8 + 8

#define out_size  6


//TODO:每个数组前4个字节（对齐）存放自己的尺寸

__dma_aligned int buffer_in[C_in * H_ * W_];
__dma_aligned int buffer_weights1[C_out * C_in * K_ * K_];
__dma_aligned int buffer_weights2[C_out * C_in * K_ * K_];
//用C还是固定数组...
__dma_aligned int buffer_out[C_out * out_size * out_size];

int BL[C_in * H_ * (K_ - S_)];//BL的大小应该根据每层算出来的尺寸，这里先多给
int BT[C_in * (K_ - S_) * W_]; //BT的大小应该对

//mram相当于DPU的外设，程序中的mram大小限制是啥？是每个DPU能访问的那一块吗？
//数据是一开始就被加载到mram吗？如果是同时包含正常DRAM和PIM内存条的系统，数据怎么加载？
__mram_noinit int input[ALIGN8(C_in * H_ * W_)];
__mram_noinit int weights1[ALIGN8(C_out * C_in * K_ * K_)];
__mram_noinit int weights2[ALIGN8(C_out * C_in * K_ * K_)];
//用C还是固定数组...
__mram_noinit int out[C_out * out_size * out_size];

__host int check;



void scan(int * in,int C,int H,int W){

    printf("scan\n");
    for (int i = 0; i < C; ++i)
    {
        for (int j = 0; j < H; ++j)
        {
            for (int k = 0; k < W; ++k)
            {
                printf("%d\t",in[i * H * W + j * W + k]);
            }
            printf("\n");
        }
        printf("\n");
    }

    printf("\n");
}

void clear_buffer(int * in,int C,int H,int W){

    printf("clear\n");
    for (int i = 0; i < C; ++i)
    {
        for (int j = 0; j < H; ++j)
        {
            for (int k = 0; k < W; ++k)
            {
                in[i * H * W + j * W + k] = 0;
            }
        }

    }

}


int M = 3, N = 3;

void compute(int * in,
             int * weights,
             int * out,
             int Tr, int Tc, int Tm, int Tn, int K,int S)
{

    clear_buffer(out,M,Tr,Tc);

    for(int m = 0; m < M; m += Tm)
        for(int n = 0; n < N; n += Tn)
            for(int r = 0; r < Tr; r++)
                for(int c = 0; c < Tc; c++)
                    for(int i = 0; i < K; i++)
                        for(int j = 0; j < K; j++)
                        {

                            for(int tm = 0; tm < Tm; tm++)  //UNROLL
// if(n == 0)conv.out[m + tm][r][c] = conv.bias[m + tm];
                                for(int tn = 0; tn < Tn; tn++)  //UNROLL
                                {
                                    out[(m + tm) * Tr * Tc + r * Tc + c] +=
                                            weights[(m + tm) * N * K * K + (n + tn) * K * K + i * K + j] *
                                            in[(n + tn) * ((Tr - 1)*S + K) * ((Tc - 1)*S + K) +
                                               (S * r + i) * ((Tc - 1)*S + K) + (S * c + j)];
// if(i == K - 1 && j == K - 1 && conv[idx].out[m + tm][r][c] < 0)conv[idx].out[m + tm][r][c] = 0;     //ReLU
                                }
                        }


}


int channel = 3;	//懒得传参了。。。
//X和Y调换了一下
void copy(int * src, int * dst,
          int H, int W, int srcY, int srcX, int dstY, int dstX,
          int srcH, int srcW, int dstH, int dstW)
{

    for(int ch = 0; ch < channel; ch++)
        for(int row = 0; row < H; row++)
            for(int col = 0; col < W; col++){
                dst[ch * dstH * dstW + (dstY + row) * dstW + (dstX + col)] =
                        src[ch * srcH * srcW + (srcY + row) * srcW + (srcX + col)];
            }

}

// int out1, int in2, int BL, int BT ————  0, 1，2，3 、、、暂时
// 注意使用本层的S
// BL每次更新为结果右边的一条(K - S)，
// BT高度为(K - S)，横向则以col为标点不断向右添加
// 目前貌似只能S = 1，否则BT好像有点问题 ———— 改成：取的时候col * S + (K - S)? 存的时候col * S?
//从BL, BT拿数据，跟上层output一起，拼出下层需要参与计算的input，并更新BL, BT给旁边的金字塔用
void reuse(int* src, int* dst, int* BL, int* BT, int row, int col, int K, int S, int H, int W,
           int buffer_outH, int buffer_outW)
{

//    dst.clear();
//    dst.resize();
//    BL[C_in * H_ * (K_ - S_)];
//    BT[C_in * (K_ - S_) * W_];

    if(row == 0 && col == 0)
        copy(src, dst, H, W, 0, 0, 0, 0,buffer_outH, buffer_outW, H, W);
    else if(row == 0)
    {
        copy(BL, dst, H, K - S, 0, 0, 0, 0, H_, (K_ - S_), H, W);
        copy(src, dst, H, W - (K - S), 0, 0, 0, K - S, buffer_outH, buffer_outW, H, W);
    }

    else if(col == 0)
    {
        copy(BT, dst, K - S, W, 0, col, 0, 0, (K_ - S_) , W_, H, W);
        copy(src, dst, H - (K - S), W, 0, 0, K - S, 0, buffer_outH, buffer_outW, H, W);
    }

    else
    {
        copy(BL, dst, H, K - S, 0, 0, 0, 0, H_, (K_ - S_), H, W);
        copy(BT, dst, K - S, W - (K - S), 0, col + (K - S), 0, K - S, (K_ - S_) , W_, H, W);
        copy(src, dst, H - (K - S), W - (K - S), 0, 0, K - S, K - S, buffer_outH, buffer_outW, H, W);
    }

//BL-->(H, K - S)在reuse里重置
//BT不能重置，放init里了
//    BL.clear();
//    BL.resize();

    copy(dst, BL, H, K - S, 0, W - (K - S), 0, 0, H, W, H_, (K_ - S_));
    copy(dst, BT, K - S, W, H - (K - S), 0, 0, col, H, W, (K_ - S_) , W_);

}

int num_fused = 3, Tr = 2, Tc = 2;
// num_fused 融合层数，但实际卷积次数为 num_fused - 1，比如融3层，实际中间是2次卷积
// Tr 融合层最后一层每次输出的尺寸
// Tc Tr——row——Y；Tc——col——X
int X = 6,Y = 6, Kk[3] = {3,3,3}, Ss[3] = {1,1,1},
        Sx = 1,Sy = 1;

void initParams(){

    // 根据存储大小？（64K）确定融合层数和每次计算的分块大小

    num_fused = 3;
    Tc = 2;
    Tr = 2;

    //向上反算X，Y，以及累乘出Sx,Sy
}

// 根据paper中的pipeline，大概率不能是乱序的并行，而是顺序进入流水线（而且乱序的情况下，数据复用也会变差
// the input data to transfer from off-chip memory (rowt, colt, inW1, inH1)
// rowt,colt是load的起点，下面的inW[1]和inH[1]是尺寸
// ———— 用于计算的起点和尺寸（也就是下一层的新数据（复用buffer里没有的）需要的
// 猜测：Sx,Sy代表，塔尖每个坐标变化所导致的，塔底的距离
// ———— 即等于所有融合层的S之积，———— 但这样的话Sx和Sy应该相等，没必要搞俩变量？
// 如果tride between adjacent pyramids指的就是两个相邻的金字塔，
// 那么就是横着走的时候Sy = 0,竖着走的时候Sx = 0
// ———— 不过这样算出来的rowt, colt就不是相对于原始input的坐标 ———— 所以还是有问题？

// 由于复用，每层in的尺寸不应由上层out决定，
// 这里搞一个每层自己的Sx和Sy ———— 暂时没必要
int rowt = 0,colt = 0,inW[3] = {0},outW[3] = {0},inH[3] = {0},outH[3] = {0};
// 由于复用，每层in的尺寸不应由上层out决定

//根据融合层数和每次计算的分块大小，初始化需要加载的input，以及每层参与计算的数据尺寸

void calcparams(int row, int col) 	//config X,Y,Sx,Sy
{
    //从Tr,Tc开始，向上计算每层的输入输出尺寸
    for (int n = num_fused - 1; n > 0; n --){

        //每层的out尺寸表示（除了复用之外）需要计算的新数据
        if(n == num_fused - 1){
            outW[n] = Tc;
            outH[n] = Tr;
        } else{
            //* S 表示新移动出的位置，即除了复用之外需要计算的新数据
            outW[n] = outW[n + 1] * Ss[n];
            outH[n] = outH[n + 1] * Ss[n];
            //贴边的时候，有一个维度没有能复用的数据，此时（本层输出=下层输入）
            //特殊情况就是（0，0）的时候，是完全没有复用，俩维度都是全尺寸一路算下来
            if(col == 0) outW[n] = inW[n + 1];
            if(row == 0) outH[n] = inH[n + 1];
        }

        //得到输出尺寸后反算输入
        inW[n] = (outW[n] - 1) * Ss[n] + Kk[n];
        inH[n] = (outH[n] - 1) * Ss[n] + Kk[n];

    }

//    if(row == 0) rowt = 0;
//    else
    rowt = row * Sy + Y  - inH[1];


//    if(col == 0) colt = 0;
//    else
    colt = col * Sx + X - inW[1];

}


void load(int * buffer_in, int rowt, int colt, int inH1, int inW1) 		//MRAM->WRAM
{
    //load input，实际还可进一步减少加载
//    buffer_in.clear();
//    buffer_in.resize();
    for (int i = 0; i < C_in; ++i)
    {
        for (int j = 0; j < inH1; ++j)
        {
//            buffer_in[i][j].assign(conv1.in[i][j + rowt].begin() + colt,
//                                   conv1.in[i][j + rowt].begin() + colt + inW1);
            //这个unaligned在读的时候会自己aligned，这里是奇数的时候，它会自己多读一个，还包括src和dst的地址对齐
            // 文档的描述是读前面的数据，For example, if the MRAM address is 0x08000004, and the size is 4 bytes,
            // the mram_read is done at address 0x8000000 with size 8.
            mram_read(&input[i * H_ * W_ + (j + rowt) * W_ + colt],
                                &buffer_in[i * inH1 * inW1 + j * inW1], ALIGN8(inW1 * sizeof(int)));
        }
    }

//    mram_read_unaligned(input, buffer_in, C_in * H_ * W_ * sizeof(int));

}

//vector<int> res;
void store(int * out) 	//WRAM->MRAM
{
    scan(out,3,2,2);
//    for (int i = 0; i < 3; ++i) {
//        printf("%d\t",out[i*3*3]);
////        res.push_back(out[i][0][0]);
//    }

}

void fused(int Tm1, int Tn1, int Tn2, int R, int C)
{
    //根据循环来看，就是每次算了一个output点
    //———— paper里面也是表达金字塔尖是单点 ———— 这个貌似没有必要？
    //———— 应该根据融合层数和片上buffer大小来决定一次算多少个点？
    for(int row = 0; row < R; row+=Tr)
    {

        for(int col = 0; col < C; col+=Tc)
        {

            calcparams(row, col);
            //根据起点和尺寸，加载进片上，
            // ———— 这个load input还有可以复用的一条没有考虑
            load(buffer_in, rowt, colt, inH[1], inW[1]);

//            scan(buffer_in,3,7,7);

//            printf("%d,___,%d\n",rowt,colt);

            //根据给定的尺寸，算一块卷积（output都是新数据）
            compute(buffer_in,buffer_weights1,buffer_out, outH[1], outW[1], Tm1, Tn1,3,1);

//            printf("%d,___,%d\n",outH[1],outW[1]);
//            scan(buffer_out,3,5,5);

            //把上层output新数据和buffer中能复用的组合起来，作为下层输入，也是只产生下层的新数据
            //上层的out只是新数据，而本层的in代表组合之后的尺寸，所以应该不同
            //能复用的数据被规整到了BT和BL中，这种copy带来的移动应该也有一定的代价？
            reuse(buffer_out, buffer_in, BL, BT, row, col, 3, 1, inH[2], inW[2], outH[1], outW[1]);

//            printf("buffer_out________\n");
//            scan(buffer_out,3,outH[1],outW[1]);
//
//            printf("buffer_in________\n");
//            scan(buffer_in,3,inH[2], inW[2]);
//
//            printf("BBB________\n");
//            scan(BL,C_in,H_,(K_ - S_));
//            scan(BT,C_in,(K_ - S_),W_);

            int Tm2 = Tn1;
            compute(buffer_in,buffer_weights2,buffer_out, outH[2], outW[2], Tm2, Tn2,3,1);

            store(buffer_out);

        }

    }

}


//模型分割、DPU分配
//查找表做乘法、加法？非线性
// ———— 查找表分块成链表，矩阵乘时扫描结果（扫描时可做稀疏），然后把需要的查找表调进来


int main() {


    printf("Hello!\n");

    initParams();

//    mram_read_unaligned(input, buffer_in, C_in * H_ * W_ * sizeof(int));
//    scan(buffer_in,3,7,7);
    //weight 全量读使用unaligned貌似问题不大？
    // 会污染临近的内存（这里俩地址没问题，就是会在最后多读几个字节），如果没有挨着的变量就没问题
    // ———— VGG中通道数都是偶数，所以没啥问题
    mram_read(weights1, buffer_weights1, ALIGN8(C_out * C_in * K_ * K_ * sizeof(int)));
    mram_read(weights2, buffer_weights2, ALIGN8(C_out * C_in * K_ * K_ * sizeof(int)));

    fused(3, 3, 3, 4, 4);

//    compute(buffer_in,buffer_weights1,buffer_out, 5, 5, 3, 3,3,1);
//
//    scan(buffer_out,3,5,5);

//    check = 999;

    return 0;
}

//9720 12636 15552 18468
//9720 12636 15552 18468
//9720 12636 15552 18468
//9720 12636 15552 18468

// mram_read_unaligned返回的地址就是第二个参数（dst）,如果dst地址不是8的倍数，
// 实际复制数据的起始地址会往前找8的整数倍的地方 ———— 比如dst=244，则真实数据从240开始复制
// ———— 这时就会造成实际拿到的数据跟想象的不一样
// 同理，对于第一个参数（src）也一样，如果src地址不是8的整数倍，
// 实际拿数据的地方也是往前找8的整数倍，比如input = {1，2，3，4}，
// src传input或者input+1,都是从1开始复制，而input+2和input+3都是从3开始复制
//    int * p = mram_read_unaligned(input + 3, buffer_in + 2, 12);
//    printf("%d  %d\n",p,buffer_in);
//    scan(buffer_in,1,1,10);

int test() {

    printf("test\n");

//    init_data();
//    load(buffer_in,1,2,5,5);
    scan(buffer_in,3,7,7);
//    compute(buffer_in,buffer_weights1,buffer_out,3, 3, 3, 3,3,1);

    // fused(3, 3, 3, 3, 3);

    compute(buffer_in,buffer_weights1,buffer_out, 5, 5, 3, 3,3,1);

    scan(buffer_out,3,5,5);

    compute(buffer_out,buffer_weights2,buffer_in, 3, 3, 3, 3,3,1);

    scan(buffer_in,3,3,3);

    return 0;
}


//    int size = 6;

//    for (int i = 0; i < C_in; ++i)
//    {
//        for (int j = 0; j < size; ++j)
//        {
////            buffer_in[i][j].assign(conv1.in[i][j + rowt].begin() + colt,
////                                   conv1.in[i][j + rowt].begin() + colt + inW1);
//
//            mram_read(&input[i * H_ * W_ + (j + rowt) * W_ + colt],
//                                &buffer_in[i * size * size + j * size], size * sizeof(int));
//
//            for(int k = 0;k < size;k ++) printf("%d\t",buffer_in[i * size * size + j * size + k]);
//
//            printf("\n");
//        }
//    }
//
//    scan(buffer_in,3,size,size);




//void init_data(){
//
//    printf("init\n");
//    for (int i = 0; i < 3; ++i)
//    {
//
//        for (int j = 0; j < 7; ++j)
//        {
//            for (int k = 0; k < 7; ++k)
//            {
//                buffer_in[i * 7 * 7 + j * 7 + k] = k + 1;
//            }
//        }
//    }
//
//    for (int i = 0; i < 3; ++i)
//    {
//
//        for (int j = 0; j < 3; ++j)
//        {
//            for (int k = 0; k < 3; ++k)
//            {
//                for (int l = 0; l < 3; ++l)
//                {
//                    buffer_weights1[i * 3 * 3 * 3 + j * 3 * 3 + k * 3 + l] = k + j;
//                }
//            }
//        }
//    }
//
//    for (int i = 0; i < 3; ++i)
//    {
//
//        for (int j = 0; j < 3; ++j)
//        {
//            for (int k = 0; k < 3; ++k)
//            {
//                for (int l = 0; l < 3; ++l)
//                {
//                    buffer_weights2[i * 3 * 3 * 3 + j * 3 * 3 + k * 3 + l] = k + l;
//                }
//            }
//        }
//    }
//
//    //BT 和 BL按照每层情况给预设的大小
//    //BL在reuse里重置
//    //BT-->应该是宽度 = 本层input，高度K - S，这个不能重置
//
//    // BT.clear();
//    // BT.resize(conv2.C_in);
//    // for (int i = 0; i < conv2.C_in; ++i) {
//    //     BT[i].resize(conv2.K - conv2.S);
//    //     for (int j = 0; j < conv2.K - conv2.S; ++j)
//    //         BT[i][j].resize(conv2.W);
//    // }
//
//}


//void reuse(int*** src, int*** dst, int*** BL, int*** BT, int row, int col, int K, int S, int H, int W) {
//
//    int dstSize = 3;
//    // 清空并重新分配目标矩阵dst的内存空间
//    for (int i = 0; i < dstSize; ++i) {
//        for (int j = 0; j < H; ++j) {
//            for (int k = 0; k < W; ++k) {
//                dst[i][j][k] = 0; // 清空目标矩阵的元素
//            }
//            free(dst[i][j]);
//        }
//        free(dst[i]);
//    }
//    free(dst);
//    dst = malloc(dstSize * sizeof(int**));
//    for (int i = 0; i < dstSize; ++i) {
//        dst[i] = malloc(H * sizeof(int*));
//        for (int j = 0; j < H; ++j) {
//            dst[i][j] = malloc(W * sizeof(int));
//        }
//    }
//
//    if (row == 0 && col == 0) {
//        copy(src, dst, H, W, 0, 0, 0, 0);
//    }
//    else if (row == 0) {
//        copy(BL, dst, H, K - S, 0, 0, 0, 0);
//        copy(src, dst, H, W - (K - S), 0, 0, 0, K - S);
//    }
//    else if (col == 0) {
//        copy(BT, dst, K - S, W, 0, col, 0, 0);
//        copy(src, dst, H - (K - S), W, 0, 0, K - S, 0);
//    }
//    else {
//        copy(BL, dst, H, K - S, 0, 0, 0, 0);
//        copy(BT, dst, K - S, W - (K - S), 0, col + (K - S), 0, K - S);
//        copy(src, dst, H - (K - S), W - (K - S), 0, 0, K - S, K - S);
//    }
//
//    int srcSize = 3;
//    // 清空并重新分配BL矩阵的内存空间
//    for (int i = 0; i < srcSize; ++i) {
//        for (int j = 0; j < H; ++j) {
//            free(BL[i][j]);
//        }
//        free(BL[i]);
//    }
//    free(BL);
//    BL = malloc(srcSize * sizeof(int**));
//    for (int i = 0; i < srcSize; ++i) {
//        BL[i] = malloc(H * sizeof(int*));
//        for (int j = 0; j < H; ++j) {
//            BL[i][j] = malloc((K - S) * sizeof(int));
//        }
//    }
//
//    copy(dst, BL, H, K - S, 0, W - (K - S), 0, 0);
//    copy(dst, BT, K - S, W, H - (K - S), 0, 0, col);
//}
//
//
//void load(vector<vector<vector<int> > > &buffer_in, int rowt, int colt, int inH1, int inW1) 		//MRAM->WRAM
//{
////load input，实际还可进一步减少加载
//buffer_in.clear();
//buffer_in.resize(conv1.C_in);
//for (int i = 0; i < conv1.C_in; ++i)
//{
//buffer_in[i].resize(inH1);
//for (int j = 0; j < inH1; ++j)
//{
////            buffer_in[i][j].resize(inW1);
////            for (int k = 0; k < inW1; ++k)
////            {
////                conv1.in[i][j][k] = 1;
////            }
//
//buffer_in[i][j].assign(conv1.in[i][j + rowt].begin() + colt,
//conv1.in[i][j + rowt].begin() + colt + inW1);
//
//}
//}
//
////weight 直接copy
//buffer_weights1 = conv1.weights;
//buffer_weights2 = conv2.weights;
//
//}