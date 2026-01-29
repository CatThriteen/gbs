#include "fancyIndex.h"
#include <cmath>
#include <Eigen/Dense>
#include <iostream>
#ifdef _OPENMP
#include <omp.h>
#endif
#include <vector>
using namespace Eigen;
using namespace std;

MatrixXb fancyIndex(MatrixXb data, MatrixXi index) {
  // data: [data_rows, data_cols]，index: [index_rows, index_cols]
  // 目标：按照 index 中给出的列索引，从 data 中取出对应列，
  //      拼成一个大的矩阵 tmp（行数 = index_rows * data_rows）。
  Eigen::Matrix<uint8_t, Eigen::Dynamic, Eigen::Dynamic, Eigen::RowMajor> tmp(
      index.rows() * data.rows(), index.cols());

#ifdef _OPENMP
#pragma omp parallel for
#endif
  for (int i = 0; i < index.rows(); ++i) {
    for (int j = 0; j < index.cols(); ++j) {
      for (int k = 0; k < data.rows(); ++k) {
        // 第 i 组索引、data 的第 k 行，取第 j 个索引位置的值
        tmp(i * data.rows() + k, j) = data(k, index(i, j));
      }
    }
  }

  return tmp;
}

// 计算 mask
VectorXi generateMask(int bits) {
  // 生成长度为 bits 的掩码向量：[1,2,4,8,...]
  VectorXi mask(bits);
  for (int i = 0; i < bits; ++i) {
    mask(i) = pow(2, i);
  }
  return mask;
}

// 实现 bincount 功能
vector<int> bincount(const VectorXi &values, int minlength) {
  // 对 values 中的整数做计数统计，类似 numpy.bincount
  int max_value = values.maxCoeff();
  int size = max(max_value + 1, minlength);
  vector<int> counts(size, 0);
  // cout << values.size() << endl;
  for (int i = 0; i < values.size(); ++i) {
    counts[values(i)]++;
  }

  return counts;
}

MatrixXi getResult(const Matrix<uint16_t, Dynamic, Dynamic> &data,
                   const MatrixXi &index, const VectorXi &target) {
  // data: [data_rows, data_cols]，每个元素是 uint16
  // index: [index_rows, index_cols]，每行是一组列索引
  // target: 要统计的编码值列表
  //
  // 核心思路：
  // 1) 对每一组 index（每一行）：
  //    - 从 data 的每一行取出 index_cols 个元素
  //    - 把这些元素的“第 j 位”拼成一个 index_cols-bit 的整数编码
  // 2) 对所有样本的编码做 bincount
  // 3) 只返回 target 中指定编码的计数
  int index_rows = index.rows();
  int index_cols = index.cols();
  int data_rows = data.rows();
  int data_cols = data.cols();

  auto mask = generateMask(index_cols);
  // mask 用来提取每个 bit 位（1,2,4,...）

  // 计算结果
  MatrixXi results(index_rows, target.size());
  results.setZero();

#ifdef _OPENMP
  #pragma omp parallel for
#endif
  for (int num = 0; num < index_rows; ++num) {
    VectorXi result(data_rows);
    result.setZero();
    for (int i = 0; i < data_rows; ++i) {
      // 对 data 的每一行，组合出一个编码值
      for (int j = 0; j < index_cols; ++j) {
        // data(i, index(num, j)) 是一个 uint16
        // 与 mask(j) 做按位与，提取第 j 位（0 或 2^j）
        result(i) += (data(i, index(num, j)) & mask(j));
      }
    }
    // 使用 bincount 统计结果
    auto counts = bincount(result, pow(2, index_cols));

    // 只取 target 指定的编码出现次数
    for (int i = 0; i < target.size(); ++i) {
      results(num, i) = counts[target(i)];
    }
  }
  return results;
}
