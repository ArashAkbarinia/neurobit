#ifndef __HISTND_H__
#define __HISTND_H__

void histnd(unsigned int *hist, const double *X, unsigned int nDims, unsigned int nPoints, unsigned int nBins);
void histnd_factors(unsigned int *hist, const double *X, const unsigned int nDims, const unsigned int nPoints, const unsigned int nBins, const double *factors);

#endif
