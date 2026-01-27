#include <iostream>
#include <vector>
#include <random>
#include <cmath>
#include <numeric>
#include <Eigen/Dense>
#include <unordered_map>
#include <chrono> // 用于统计运行时间
#include "fancyIndex.h"

using namespace std;
using namespace Eigen;
using namespace chrono;

// 加载数据的模拟函数
Matrix<uint16_t, Dynamic, Dynamic> loadData(const string& path, int rows, int cols) {
    // 模拟加载数据，实际需要从文件中读取
    Matrix<uint16_t, Dynamic, Dynamic> data = Matrix<uint16_t, Dynamic, Dynamic>::Random(rows, cols).array().abs();
    return data;
}

// 生成随机索引
Matrix<int, Dynamic, Dynamic> generateRandomIndex(int rows, int cols, int max_value) {
    Matrix<int, Dynamic, Dynamic> index(rows, cols);
    random_device rd;
    mt19937 gen(rd());
    uniform_int_distribution<> dis(0, max_value - 1);
    for (int i = 0; i < rows; ++i) {
        for (int j = 0; j < cols; ++j) {
            index(i, j) = dis(gen);
        }
    }
    return index;
}


// 主函数
int main() {
    // 加载数据
    string data_path = "/home/g/data/GBS/GBS4/0120/power1/data_1M.bin.npy";
    int data_rows = 1000000; // 假设数据有 1000000 行
    int data_cols = 511;  // 假设数据有 511 列
    auto data = loadData(data_path, data_rows, data_cols);

    // 生成随机索引
    int index_rows = 70000;
    int index_cols = 16;
    auto index = generateRandomIndex(index_rows, index_cols, data_cols);

    // 生成 mask
    auto mask = generateMask(index_cols);


        // 记录程序开始时间
        auto start_time = high_resolution_clock::now();


    // 计算结果
    VectorXi result(data_rows);
    result.setZero();
    for (int i = 0; i < data_rows; ++i) {
        for (int j = 0; j < index_cols; ++j) {
            result(i) += (data(i, index(0, j)) & mask(j));
        }
    }
    // 使用 bincount 统计结果
    auto counts = bincount(result);

    // // 输出 bincount 结果
    // cout << "Bincount results:" << endl;
    // for (size_t i = 0; i < counts.size(); ++i) {
    //     if (counts[i] > 0) {
    //         cout << i << ": " << counts[i] << endl;
    //     }
    // }

    // 记录程序结束时间
    auto end_time = high_resolution_clock::now();
    auto duration = duration_cast<milliseconds>(end_time - start_time);

    // 输出运行时间
    cout << "Execution time: " << duration.count() << " ms" << endl;

    return 0;
}