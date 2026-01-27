#include "fancyIndex.h"
#include <cmath>
#include <Eigen/Dense>
#include <iostream>
#include <omp.h>
#include <vector>
using namespace Eigen;
using namespace std;

MatrixXb fancyIndex(MatrixXb data, MatrixXi index) {
  Eigen::Matrix<uint8_t, Eigen::Dynamic, Eigen::Dynamic, Eigen::RowMajor> tmp(
      index.rows() * data.rows(), index.cols());

#pragma omp parallel for
  for (int i = 0; i < index.rows(); ++i) {
    for (int j = 0; j < index.cols(); ++j) {
      for (int k = 0; k < data.rows(); ++k) {
        tmp(i * data.rows() + k, j) = data(k, index(i, j));
      }
    }
  }

  return tmp;
}

// 计算 mask
VectorXi generateMask(int bits) {
  VectorXi mask(bits);
  for (int i = 0; i < bits; ++i) {
    mask(i) = pow(2, i);
  }
  return mask;
}

// 实现 bincount 功能
vector<int> bincount(const VectorXi &values, int minlength) {
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
  int index_rows = index.rows();
  int index_cols = index.cols();
  int data_rows = data.rows();
  int data_cols = data.cols();

  auto mask = generateMask(index_cols);
  // cout<< mask;

  // 计算结果
  MatrixXi results(index_rows, target.size());
  results.setZero();

  #pragma omp parallel for
  for (int num = 0; num < index_rows; ++num) {
    VectorXi result(data_rows);
    result.setZero();
    for (int i = 0; i < data_rows; ++i) {
      for (int j = 0; j < index_cols; ++j) {
        result(i) += (data(i, index(num, j)) & mask(j));
      }
    }
    // 使用 bincount 统计结果
    auto counts = bincount(result, pow(2, index_cols));

    for (int i = 0; i < target.size(); ++i) {
      results(num, i) = counts[target(i)];
    }
  }
  return results;
}