#include <cstdio>


#include "iostream"
#include "vector"

using namespace std;


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


vector<vector<vector<int> > > buffer_in;
vector<vector<vector<vector<int> > > > buffer_weights1;
vector<vector<vector<vector<int> > > > buffer_weights2;
vector<vector<vector<int> > > buffer_out;


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
                                // if(n == 0)conv.out[m + tm][r][c] = conv.bias[m + tm];
                                for(int tn = 0; tn < Tn; tn++) 	//UNROLL
                                {
                                    out[m + tm][r][c] += weights[m + tm][n + tn][i][j] * in[n + tn][S * r + i][S * c + j];
                                    // if(i == K - 1 && j == K - 1 && conv[idx].out[m + tm][r][c] < 0)conv[idx].out[m + tm][r][c] = 0;		//ReLU
                                }
                        }


}

int num_fused, Tr, Tc;
// num_fused 融合层数，但实际卷积次数为 num_fused - 1，比如融3层，实际中间是2次卷积
// Tr 融合层最后一层每次输出的尺寸
// Tc Tr——row——Y；Tc——col——X

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

int rowt = 0,colt = 0,inW[3] = {0},outW[3] = {0},inH[3] = {0},outH[3] = {0};
// 由于复用，每层in的尺寸不应由上层out决定
int X = 6,Y = 6, Kk[3] = {3,3,3}, Ss[3] = {1,1,1},
        Sx = 1,Sy = 1;
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

//        cout << rowt << "..." << colt << endl;

}


void load(vector<vector<vector<int> > > &buffer_in, int rowt, int colt, int inH1, int inW1) 		//MRAM->WRAM
{
    //load input，实际还可进一步减少加载
    buffer_in.clear();
    buffer_in.resize(conv1.C_in);
    for (int i = 0; i < conv1.C_in; ++i)
    {
        buffer_in[i].resize(inH1);
        for (int j = 0; j < inH1; ++j)
        {
//            buffer_in[i][j].resize(inW1);
//            for (int k = 0; k < inW1; ++k)
//            {
//                conv1.in[i][j][k] = 1;
//            }

            buffer_in[i][j].assign(conv1.in[i][j + rowt].begin() + colt,
                                   conv1.in[i][j + rowt].begin() + colt + inW1);

        }
    }

    //weight 直接copy
    buffer_weights1 = conv1.weights;
    buffer_weights2 = conv2.weights;

}

vector<int> res;
void store(vector<vector<vector<int> > > out) 	//WRAM->MRAM
{
    scan(out);
    for (int i = 0; i < 3; ++i) {
        res.push_back(out[i][0][0]);
    }

}

int channel = 3;	//懒得传参了。。。
//X和Y调换了一下
void copy(vector<vector<vector<int> > > src, vector<vector<vector<int> > > &dst,
          int H, int W, int srcY, int srcX, int dstY, int dstX)
{

    for(int ch = 0; ch < channel; ch++)
        for(int row = 0; row < H; row++)
            for(int col = 0; col < W; col++){
                dst[ch][dstY + row][dstX + col] = src[ch][srcY + row][srcX + col];
            }

}


// 注意使用本层的 K和 S
// BL每次更新为结果右边的一条(K - S)，
// BT高度为(K - S)，横向则以col为标点不断向右添加
// 目前貌似只能S = 1，否则BT好像有点问题 ———— 取的时候应该是col * S + (K - S)? 存的时候应该是col * S?
void reuse(vector<vector<vector<int> > > &src, vector<vector<vector<int> > > &dst,
           vector<vector<vector<int> > > &BL, vector<vector<vector<int> > > &BT,
           int row, int col, int K, int S, int H, int W)
{

    dst.clear();
    dst.resize(src.size());
    for (int i = 0; i < dst.size(); ++i) {
        dst[i].resize(H);
        for (int j = 0; j < H; ++j)
            dst[i][j].resize(W);
    }

    if(row == 0 && col == 0)
        copy(src, dst, H, W, 0, 0, 0, 0);
    else if(row == 0)
    {
        copy(BL, dst, H, K - S, 0, 0, 0, 0);
        copy(src, dst, H, W - (K - S), 0, 0, 0, K - S);
    }

    else if(col == 0)
    {
        copy(BT, dst, K - S, W, 0, col, 0, 0);
        copy(src, dst, H - (K - S), W, 0, 0, K - S, 0);
    }

    else
    {
        copy(BL, dst, H, K - S, 0, 0, 0, 0);
        copy(BT, dst, K - S, W - (K - S), 0, col + (K - S), 0, K - S);
        copy(src, dst, H - (K - S), W - (K - S), 0, 0, K - S, K - S);
    }

    //BL-->(H, K - S)在reuse里重置
    //BT不能重置，放init里了
    BL.clear();
    BL.resize(src.size());
    for (int i = 0; i < src.size(); ++i) {
        BL[i].resize(H);
        for (int j = 0; j < H; ++j)
            BL[i][j].resize(K - S);
    }

    copy(dst, BL, H, K - S, 0, W - (K - S), 0, 0);
    copy(dst, BT, K - S, W, H - (K - S), 0, 0, col);

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
            //根据给定的尺寸，算一块卷积（output都是新数据）
            compute(buffer_in,buffer_weights1,buffer_out, outH[1], outW[1], Tm1, Tn1,3,1);
            //把上层output新数据和buffer中能复用的组合起来，作为下层输入，也是只产生下层的新数据
            //上层的out只是新数据，而本层的in代表组合之后的尺寸，所以应该不同
            //能复用的数据被规整到了BT和BL中，这种copy带来的移动应该也有一定的代价？
            reuse(buffer_out, buffer_in, BL, BT, row, col, 3, 1, inH[2], inW[2]);
//            scan(BL);
//            scan(BT);
            int Tm2 = Tn1;
            compute(buffer_in,buffer_weights2,buffer_out, outH[2], outW[2], Tm2, Tn2,3,1);

            store(buffer_out);

        }

    }

}


int main()
{

    init_data();
//    load(buffer_in,1,2,5,5);
    scan(conv1.in,conv1.weights,conv2.weights);
//    compute(buffer_in,buffer_weights1,buffer_out,3, 3, 3, 3,3,1);
//    scan(buffer_out);

    initParams();

    fused(3, 3, 3, 4, 4);


    compute(conv1.in,conv1.weights,conv1.out, 6, 6, 3, 3,3,1);

    compute(conv1.out,conv2.weights,conv2.out, 4, 4, 3, 3,3,1);

    scan(conv2.out);

    cout << endl;
    for (int i = 0; i < res.size(); ++i) {
        cout << res[i] << ' ';
    }
    cout << endl;

    return 0;
}



//void calcparams(int row, int col) 	//config X,Y,Sx,Sy
//{
//
//    int X = 6,Y = 6,Sx = 1,Sy = 1, K = 3, S = 1;
//
//    for (int n = 1; n < 3; ++n){
//
//    }
//
//    if(row > 0)rowt = Y + (row - 1) * Sy - (K - S);
//    if(row == 0)rowt = 0;
//
//    if(col > 0)colt = X + (col - 1) * Sx - (K - S);
//    if(col == 0)colt = 0;
//
//
//    for (int n = 1; n < 3; ++n)	//从1开始
//    {
//
//        if(n == 1 && col == 0)inW[n] = X;
////        if(n == 1 && col > 0)inW[n] = Sx + K - S;
////        if(n > 1)inW[n] = outW[n - 1];
//        else inW[n] = Sx + K - S;
//
//
//        if(n == 1 && row == 0)inH[n] = Y;
////        if(n == 1 && row > 0)inH[n] = Sy + K - S;
////        if(n > 1)inH[n] = outH[n - 1];
//        else inH[n] = Sy + K - S;
//
//        outW[n] = (inW[n] - K) / S + 1;
//        outH[n] = (inH[n] - K) / S + 1;
//    }
//
//}

