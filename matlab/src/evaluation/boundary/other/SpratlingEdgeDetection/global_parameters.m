function GP=global_parameters()
GP.LGNsigma=2;
GP.V1sigmaLength=3;
GP.V1sigmaWidth=GP.LGNsigma;
GP.V1angleStep=22.5; %15; %30;
GP.V1angles=[0:GP.V1angleStep:179];
GP.LGNresponseGain=2*pi;
GP.iterations=30;
