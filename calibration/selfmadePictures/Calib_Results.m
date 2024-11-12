% Intrinsic and Extrinsic Camera Parameters
%
% This script file can be directly excecuted under Matlab to recover the camera intrinsic and extrinsic parameters.
% IMPORTANT: This file contains neither the structure of the calibration objects nor the image coordinates of the calibration points.
%            All those complementary variables are saved in the complete matlab data file Calib_Results.mat.
% For more information regarding the calibration model visit http://www.vision.caltech.edu/bouguetj/calib_doc/


%-- Focal length:
fc = [ 3384.000987415836800 ; 3419.296360576648600 ];

%-- Principal point:
cc = [ 2017.801473923848600 ; 1449.928378966605800 ];

%-- Skew coefficient:
alpha_c = 0.000000000000000;

%-- Distortion coefficients:
kc = [ -0.044349094126549 ; 0.199638434477560 ; -0.001431486077063 ; -0.001617130349498 ; 0.000000000000000 ];

%-- Focal length uncertainty:
fc_error = [ 300.704878167878410 ; 186.593464477003350 ];

%-- Principal point uncertainty:
cc_error = [ 56.111829310316793 ; 433.416036321250940 ];

%-- Skew coefficient uncertainty:
alpha_c_error = 0.000000000000000;

%-- Distortion coefficients uncertainty:
kc_error = [ 0.059140503476338 ; 0.359032685180435 ; 0.004606486479422 ; 0.005835681077554 ; 0.000000000000000 ];

%-- Image size:
nx = 4032;
ny = 3024;


%-- Various other variables (may be ignored if you do not use the Matlab Calibration Toolbox):
%-- Those variables are used to control which intrinsic parameters should be optimized

n_ima = 5;						% Number of calibration images
est_fc = [ 1 ; 1 ];					% Estimation indicator of the two focal variables
est_aspect_ratio = 1;				% Estimation indicator of the aspect ratio fc(2)/fc(1)
center_optim = 1;					% Estimation indicator of the principal point
est_alpha = 0;						% Estimation indicator of the skew coefficient
est_dist = [ 1 ; 1 ; 1 ; 1 ; 0 ];	% Estimation indicator of the distortion coefficients


%-- Extrinsic parameters:
%-- The rotation (omc_kk) and the translation (Tc_kk) vectors for every calibration image and their uncertainties

%-- Image #1:
omc_1 = [ 2.533839e+00 ; 5.454760e-01 ; -1.565807e-01 ];
Tc_1  = [ -1.424263e+02 ; 8.063283e+00 ; 3.557927e+02 ];
omc_error_1 = [ 5.557356e-02 ; 1.333501e-02 ; 2.499126e-02 ];
Tc_error_1  = [ 5.940583e+00 ; 4.543358e+01 ; 3.168120e+01 ];

%-- Image #2:
omc_2 = [ 2.496035e+00 ; -8.555540e-01 ; 3.054531e-01 ];
Tc_2  = [ -4.506299e+01 ; 7.228947e+01 ; 3.098467e+02 ];
omc_error_2 = [ 4.798318e-02 ; 2.332378e-02 ; 3.589549e-02 ];
Tc_error_2  = [ 5.166179e+00 ; 4.253873e+01 ; 2.730502e+01 ];

%-- Image #3:
omc_3 = [ 2.235991e+00 ; 1.390439e+00 ; -3.092190e-01 ];
Tc_3  = [ -1.280991e+02 ; -8.674917e+01 ; 4.163300e+02 ];
omc_error_3 = [ 4.985980e-02 ; 2.561183e-02 ; 3.123700e-02 ];
Tc_error_3  = [ 7.010755e+00 ; 4.890343e+01 ; 3.664639e+01 ];

%-- Image #4:
omc_4 = [ 2.318155e+00 ; -9.209129e-01 ; 5.001270e-01 ];
Tc_4  = [ -2.100330e+01 ; 5.220611e+01 ; 2.796138e+02 ];
omc_error_4 = [ 6.460474e-02 ; 4.107676e-02 ; 4.658660e-02 ];
Tc_error_4  = [ 4.645684e+00 ; 3.773575e+01 ; 2.422369e+01 ];

%-- Image #5:
omc_5 = [ 2.582254e+00 ; 4.673671e-01 ; -4.613862e-02 ];
Tc_5  = [ -1.352562e+02 ; 1.806996e+01 ; 3.385654e+02 ];
omc_error_5 = [ 5.234721e-02 ; 8.184157e-03 ; 2.153061e-02 ];
Tc_error_5  = [ 5.688262e+00 ; 4.372766e+01 ; 2.979042e+01 ];

