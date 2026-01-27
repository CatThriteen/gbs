#ifndef FANCYINDEX_H
#define FANCYINDEX_H

#include <Eigen/Dense>
#include <vector>
#include <complex>
#include <cmath>

using namespace Eigen;
using namespace std;

typedef Eigen::Matrix<int32_t, Eigen::Dynamic, Eigen::Dynamic> MatrixXi;

typedef Eigen::Matrix<uint8_t, Eigen::Dynamic, Eigen::Dynamic> MatrixXb;

MatrixXb fancyIndex(MatrixXb data,MatrixXi index); 
MatrixXi getResult(const Matrix<uint16_t, Dynamic, Dynamic>& data,const MatrixXi& index, const VectorXi &target); 
VectorXi generateMask(int bits);
vector<int> bincount(const VectorXi& values, int minlength =0);

#endif // FANCYINDEX_H
