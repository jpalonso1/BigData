#include "xfun.h"

double xfun::randomUniform() {
	return double(rand()) / double(RAND_MAX);
}

double xfun::randomNormalBM() {
	double left=sqrt(-2.0*log(xfun::randomUniform()));
	double right=cos(2.0*3.14159265359*(randomUniform()));
	return left*right;
}
