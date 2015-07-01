#include "math.h"
#include <assert.h>
#include "stdlib.h"
#include "histnd.h"

/*
 * histnd, ndimensional histogram of 'X' in 'hist' with equally spaced 'nBins' bins
 *
 */
void histnd(unsigned int *hist, const double *X, unsigned int nDims, unsigned int nPoints, unsigned int nBins)
{
	assert(hist);
	unsigned int *facs = (unsigned int*)malloc(nDims * sizeof(unsigned int));
	assert(facs);
	unsigned int *knPoints = (unsigned int*)malloc(nDims * sizeof(unsigned int));
	assert(knPoints);
	
	facs[0] = 1;
	knPoints[0] = 0;
	for ( unsigned int i=1 ; i<nDims ; i++)
	{
		facs[i] = facs[i-1]*nBins;
		knPoints[i]=i*nPoints;
	}
	for ( unsigned int i=0 ; i<(unsigned int)pow(nBins,nDims) ; i++)
		hist[i] = (unsigned int)0;

	for ( unsigned int i=0 ; i<nPoints ; i++ )
	{
		unsigned int binindx = 0;
		for ( unsigned int k=0 ; k<nDims ; k++)
		{
			unsigned int b = (unsigned int)(nBins * X[i+knPoints[k]]);
			b = (b==nBins)?nBins-1:b;
			binindx += facs[k] * b;
		}
		hist[binindx]++;
	}
	free(facs);
	free(knPoints);
}

/*
 * histc_factors, ndimensional histogram of 'factors * X' in 'hist' with equally spaced 'nBins' bins
 *
 */
void histnd_factors(unsigned int *hist, const double *X, const unsigned int nDims, const unsigned int nPoints, const unsigned int nBins, const double *factors)
{
	assert(hist);
	assert(factors);


	unsigned int *facs = (unsigned int*)malloc(nDims * sizeof(unsigned int));
	assert(facs);
	unsigned int *knPoints = (unsigned int*)malloc(nDims * sizeof(unsigned int));
	assert(knPoints);
	
	facs[0] = 1;
	knPoints[0] = 0;
	for ( unsigned int i=1 ; i<nDims ; i++)
	{
		facs[i] = facs[i-1]*nBins;
		knPoints[i] = i*nPoints;
	}


	for ( unsigned int i=0 ; i<(unsigned int)pow(nBins,nDims) ; i++)
		hist[i] = (unsigned int)0;

#ifdef HISTC_DEBUG
	for ( i=0 ; i<nPoints ; i++)
		for ( k=0 ; k<nDims ; k++)
			if (factors[k]*X[i+k*nPoints] > 1)
			{
				printf("factors[%d] = %g\n",k,factors[k]);
				printf("X[%d+%d*nPoints] = %g\n",i,k,X[i+knPoints[k]]);
				mxErrMsgTxt("terror of error");
			}
#endif

	for ( unsigned int i=0 ; i<nPoints ; i++ )
	{
		unsigned int binindx = 0;
		for ( unsigned int k=0 ; k<nDims ; k++)
		{
			unsigned int b = (unsigned int)(factors[k] * nBins * X[i+knPoints[k]]);
			b = (b==nBins)?(nBins-1):b;
			binindx += facs[k] * b;
		}
		hist[binindx]++;
	}
	free(facs);
	free(knPoints);
}

