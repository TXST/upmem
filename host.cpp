#include <dpu>
#include <iostream>
#include "vector"

using namespace std;


extern "C" {
#include <assert.h>
#include <dpu.h>
#include <dpu_log.h>
#include <stdio.h>
}

#ifndef DPU_BINARY
#define DPU_BINARY "./ztb"
#endif

#define T int8_t



/*

As a consequence, the host API works on sets of DPUs, which may contain multiple DPU ranks.
The provided C macro DPU_RANK_FOREACH and DPU_FOREACH iterate over the ranks and DPUs respectively of a set.
Here are some of the available C functions to manage a DPU set:

dpu_alloc: returns a set of DPUs, which contains exactly the specified number of DPUs,
or an error if the given number of DPUs cannot be allocated.
Unless DPU_ALLOCATE_ALL is used, which means that dpu_alloc will allocate all available DPUs.

dpu_free: frees a given set of DPUs. Only sets allocated with dpu_alloc can be freed.

dpu_get_nr_ranks: returns the number of ranks in a DPU set

dpu_get_nr_dpus: returns the number of DPUs in a DPU set

This operation is achieved by dpu_load to program all the DPUs in a set.
The function gets a binary file path as input and loads the enclosed program onto the specified DPUs.
The program information that can be stored in a given pointer, or ignored if the pointer is NULL.

The program is persistent in the DPU memory, meaning that it can be rebooted as many times
as the application wants and will always execute the same code.

Applications may, however, reload DPUs with new programs, by invoking dpu_load at any moment.

This goal is achieved by “booting” DPUs, via invocations to dpu_launch to boot all the DPUs of a given set

Some resources, but not all of them, are reset before booting.

DPU_SYNCHRONOUS suspends the application until the requested DPUs complete their execution
(or encounters an error)

DPU_ASYNCHRONOUS immediately gives back the control to the application,
which will be in charge of checking the DPU’s status via dpu_status or dpu_sync


//

dpu_copy_from(struct dpu_set_t set, const char *symbol_name,
            uint32_t symbol_offset, void *dst, size_t length)
to copy a buffer from a single DPU

dpu_broadcast_to(struct dpu_set_t set, const char *symbol_name,
                uint32_t symbol_offset, const void *src, size_t length, dpu_xfer_flags_t flags)
to broadcast a buffer to a set of DPUs

————dpu_broadcast_to 和 dpu_copy_to 效果一样，但是可以异步

dpu_push_xfer(struct dpu_set_t set, dpu_xfer_t xfer, const char *symbol_name,
            uint32_t symbol_offset, size_t length, dpu_xfer_flags_t flags)
to push different buffers to a set of DPUs in one transfer.

————在使用 dpu_push_xfer 之前，需要循环中调用 dpu_prepare_xfer ，为每个DPU指定数据地址，
作为 dpu_push_xfer 的输入或输出

*/

//#define Cin 3
//#define Cout 3
//#define T int8_t

// conv0 : 7——3——5
// conv1 : 5——3——3
// conv2 : 3——3——1
//按照paper，第一层先拿出来5*5
// int Tr = , int Tc = , int Tm = 3, int Tn = 3, int K = 3,int S = 1


class ConvLayer{
public:
    int C_in = 3,C_out = 3,K = 3, S = 1, H = 8, W = 8;
    vector<vector<vector<int> > > in;
    vector<vector<vector<vector<int> > > > weights;
    vector<vector<vector<int> > > out;

//    ConvLayer(){}
    ConvLayer(int C_in = 3,int C_out = 3,int K = 3, int S = 1, int H = 8, int W = 8){
        C_in = C_in,C_out = C_out,K = K, S = S, H = H, W = W;

        in.resize(C_in);
        for (int i = 0; i < C_in; ++i){
            in[i].resize(H);
            for (int j = 0; j < H; ++j)
                in[i][j].resize(W);
        }

        weights.resize(C_out);
        for (int i = 0; i < C_out; ++i) {
            weights[i].resize(C_in);
            for (int j = 0; j < C_in; ++j) {
                weights[i][j].resize(K);
                for (int k = 0; k < K; ++k)
                    weights[i][j][k].resize(K);
            }
        }
    }
};

ConvLayer conv1,conv2(3,3,3,1,6,6);


vector<int> buffer_in(conv1.C_in * conv1.H * conv1.W );
vector<int > buffer_weights1(conv1.C_out * conv1.C_in * conv1.K * conv1.K);
vector<int > buffer_weights2(conv2.C_out * conv2.C_in * conv2.K * conv2.K);
vector<int > buffer_out;


vector<vector<vector<int> > > BL;
vector<vector<vector<int> > > BT;


void init_data(){

    printf("init\n");
    for (int i = 0; i < conv1.C_in; ++i)
    {

        for (int j = 0; j < conv1.H; ++j)
        {
            for (int k = 0; k < conv1.W; ++k)
            {
                conv1.in[i][j][k] = k + 1;
                buffer_in[i * conv1.H * conv1.W + j * conv1.W + k] = k + 1;
            }
        }
    }

    for (int i = 0; i < conv1.C_out; ++i)
    {

        for (int j = 0; j < conv1.C_in; ++j)
        {
            for (int k = 0; k < conv1.K; ++k)
            {
                for (int l = 0; l < conv1.K; ++l)
                {
                    conv1.weights[i][j][k][l] = k + j;
                    buffer_weights1[i * conv1.C_in * conv1.K * conv1.K
                                    + j * conv1.K * conv1.K + k * conv1.K + l] = k + j;
                }
            }
        }
    }

    for (int i = 0; i < conv2.C_out; ++i)
    {

        for (int j = 0; j < conv2.C_in; ++j)
        {
            for (int k = 0; k < conv2.K; ++k)
            {
                for (int l = 0; l < conv2.K; ++l)
                {
                    conv2.weights[i][j][k][l] = k + l;
                    buffer_weights2[i * conv2.C_in * conv2.K * conv2.K
                                    + j * conv2.K * conv2.K + k * conv2.K + l] = k + l;
                }
            }
        }
    }

    //BT 和 BL按照每层情况给预设的大小
    //BL在reuse里重置
    //BT-->应该是宽度 = 本层input，高度K - S，这个不能重置

    BT.clear();
    BT.resize(conv2.C_in);
    for (int i = 0; i < conv2.C_in; ++i) {
        BT[i].resize(conv2.K - conv2.S);
        for (int j = 0; j < conv2.K - conv2.S; ++j)
            BT[i][j].resize(conv2.W);
    }

}

vector<vector<vector<vector<int> > > > w1,w2;

void scan(vector<vector<vector<int> > > in,
          vector<vector<vector<vector<int> > > > weights1 = w1,
          vector<vector<vector<vector<int> > > > weights2 = w2){

    printf("scan\n");
    for (int i = 0; i < in.size(); ++i)
    {

        for (int j = 0; j < in[i].size(); ++j)
        {
            for (int k = 0; k < in[i][j].size(); ++k)
            {
                cout << in[i][j][k] << ' ';
            }
            cout << endl;
        }
        cout << endl;
    }

    cout << endl;
    printf("weights\n");
    for (int i = 0; i < weights1.size(); ++i)
    {

        for (int j = 0; j < weights1[i].size(); ++j)
        {
            for (int k = 0; k < weights1[i][j].size(); ++k)
            {
                for (int l = 0; l < weights1[i][j][k].size(); ++l)
                {
                    cout << weights1[i][j][k][l] << ' ';
                }
                cout << endl;
            }
            cout << endl;
        }
        cout << endl;
    }
    cout << endl;

    printf("weights\n");
    for (int i = 0; i < weights2.size(); ++i)
    {

        for (int j = 0; j < weights2[i].size(); ++j)
        {
            for (int k = 0; k < weights2[i][j].size(); ++k)
            {
                for (int l = 0; l < weights2[i][j][k].size(); ++l)
                {
                    cout << weights2[i][j][k][l] << ' ';
                }
                cout << endl;
            }
            cout << endl;
        }
        cout << endl;
    }
    cout << endl;
}


void compute(vector<vector<vector<int> > > in,
             vector<vector<vector<vector<int> > > > weights,
             vector<vector<vector<int> > > &out,
             int Tr, int Tc, int Tm, int Tn, int K,int S,int M = 3, int N = 3)
{

    out.clear();
    out.resize(M);
    for (int i = 0; i < M; ++i) {
        out[i].resize(Tr);
        for (int j = 0; j < Tr; ++j)
            out[i][j].resize(Tc);
    }

    for(int m = 0; m < M; m += Tm)
        for(int n = 0; n < N; n += Tn)
            for(int r = 0; r < Tr; r++)
                for(int c = 0; c < Tc; c++)
                    for(int i = 0; i < K; i++)
                        for(int j = 0; j < K; j++)
                        {

                            for(int tm = 0; tm < Tm; tm++)	//UNROLL
                                // if(n == 0)conv.out_HW[m + tm][r][c] = conv.bias[m + tm];
                                for(int tn = 0; tn < Tn; tn++) 	//UNROLL
                                {
                                    out[m + tm][r][c] += weights[m + tm][n + tn][i][j] * in[n + tn][S * r + i][S * c + j];
                                    // if(i == K - 1 && j == K - 1 && conv[idx].out_HW[m + tm][r][c] < 0)conv[idx].out_HW[m + tm][r][c] = 0;		//ReLU
                                }
                        }


}



int align8(int size){

    if(size % 8 == 0) return size;
    else return size / 8 * 8 + 8;
}



int main() {

    struct dpu_set_t set, dpu;
    uint32_t check;
    uint32_t idx;

    cout << "hello ztb~" << endl;

    DPU_ASSERT(dpu_alloc(1, NULL, &set));
    DPU_ASSERT(dpu_load(set, DPU_BINARY, NULL));

    init_data();
//    scan(conv1.in,conv1.weights,conv2.weights);
//    buffer_in = conv1.in;
//    int * p = &buffer_in[0];
//    for (int i = 0; i < conv1.C_in * conv1.H * conv1.W; ++i) {
//        cout << (*p) << ' ';
//        p ++;
//    }
////    scan(buffer_in);
//    cout << endl ;

//————这感觉像是要先把正常DRAM里的数据传到DPU那边的DRAM（MRAM）？

    DPU_FOREACH(set, dpu, idx) {
        //直接用conv class传的话，数据不太对，估计class在做什么对齐之类的？
        // 另外知乎上说直接传地址也有问题，暂时没测试
        DPU_ASSERT(dpu_prepare_xfer(dpu, &buffer_in[0]));
    }
    DPU_ASSERT(dpu_push_xfer(set, DPU_XFER_TO_DPU, "input", 0,
                             align8(conv1.C_in * conv1.H * conv1.W * sizeof(int)), DPU_XFER_DEFAULT));

    DPU_FOREACH(set, dpu, idx) {
        DPU_ASSERT(dpu_prepare_xfer(dpu, &buffer_weights1[0]));
    }
    DPU_ASSERT(dpu_push_xfer(set, DPU_XFER_TO_DPU, "weights1", 0,
                             align8(conv1.C_out * conv1.C_in * conv1.K * conv1.K * sizeof(int)), DPU_XFER_DEFAULT));

    DPU_FOREACH(set, dpu, idx) {
        DPU_ASSERT(dpu_prepare_xfer(dpu, &buffer_weights2[0]));
    }
    DPU_ASSERT(dpu_push_xfer(set, DPU_XFER_TO_DPU, "weights2", 0,
                             align8(conv2.C_out * conv2.C_in * conv2.K * conv2.K * sizeof(int)), DPU_XFER_DEFAULT));


//   DPU_ASSERT(dpu_broadcast_to(set, "buffer", 0, buffer, BUFFER_SIZE, DPU_XFER_DEFAULT));

    DPU_ASSERT(dpu_launch(set, DPU_SYNCHRONOUS));
//    DPU_FOREACH(set, dpu) {
//        DPU_ASSERT(dpu_copy_from(dpu, "check", 0, (uint8_t *)&check, sizeof(check)));
//        printf("check = %d\n", check);
//    }
    DPU_FOREACH(set, dpu) {
        DPU_ASSERT(dpu_log_read(dpu, stdout));
    }

    DPU_ASSERT(dpu_free(set));

    return 0;
}


int test()
{
    init_data();
//    load(buffer_in,1,2,5,5);
    scan(conv1.in,conv1.weights,conv2.weights);
//    compute(buffer_in,buffer_weights1,buffer_out,3, 3, 3, 3,3,1);
//    scan(buffer_out);
//    fused(3, 3, 3, 3, 3);

    compute(conv1.in,conv1.weights,conv1.out, 5, 5, 3, 3,3,1);

    scan(conv1.out);

    compute(conv1.out,conv2.weights,conv2.out, 3, 3, 3, 3,3,1);

    scan(conv2.out);

    cout << endl;
//    for (int i = 0; i < res.size(); ++i) {
//        cout << res[i] << ' ';
//    }
//    cout << endl;

    return 0;
}

