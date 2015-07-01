#include "mex.h"
#include "math.h"
#include "histnd.h"

/*#define HIST_DEBUG*/
/*#define HIST_VERBOSE*/

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

	if (nrhs<2 || nrhs>2)
		mexErrMsgTxt("wrong number of input arguments: mex_histc(X,nBins);");
	if (nlhs>1)
		mexErrMsgTxt("wrong number of output arguments: h = mex_histc(X,nBins);");
	

	unsigned int nBins = (unsigned int) (*mxGetPr(prhs[1]));
	double *X = mxGetPr(prhs[0]);

	unsigned int npts = mxGetM(prhs[0]);
	unsigned int ndims = mxGetN(prhs[0]);

#ifdef HIST_VERBOSE
	printf("nPts = %d\n",npts);
	printf("nBins = %d\n",nBins);
	printf("nDims = %d\n",ndims);
#endif

	if (nBins<=0)
		mexErrMsgTxt("nBins must be positive number");
	
#ifdef HIST_DEBUG
	for ( i=0 ; i<npts*ndims ; i++ )
	{
		if ( X[i]>1 )
		{
			printf("X must not be >1\n");
			return;
		}
	}
#endif

	mwSize dims[2];
	dims[0] = (mwSize)pow(nBins,ndims);
	dims[1] = 1;

	plhs[0] = mxCreateNumericArray(2,dims,mxUINT32_CLASS,mxREAL);
	unsigned int *hist = (unsigned int*)mxGetPr(plhs[0]);

	histnd(hist,X,ndims,npts,nBins);
    return;
}

