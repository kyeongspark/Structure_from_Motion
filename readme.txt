This is the zip file for Computer Vision Programming Assignment 2 20195061 Park, Kyeong Seop

(FOLDER)
calibration: contains calibration tools, calibration results, and self-taken pictures
pictures: contains input images
vlfeat-0.9.21.-bin: contains the vl_setup

(FILE)
init.m: script for 3D construction (initiation step) using given images
initSelf.m: script for 3D construction using self-taken images
addMethod.m: script for 3D construction (growing step) using given images
normCoord.m: code for normalizing the pixel image coordinate system
RANSAC.m: code of the fivepoint algorithm + RANSAC 
tri.m: code for estimating the camera motion

Before you start executing MATLAB files, please type in the command,
run('vlfeat-0.9.21-bin\vlfeat-0.9.21/toolbox/vl_setup')

To view the reconstruction (initiation step) of the starbucks cup image, type
run('init.m') %% Will create a ply file 'ImageInit.ply'
-> The ply result executed in my own computer is stored in 'starbucks.ply'

To view the reconstruction (initiation step) of the self-taken image of the mountain dew can, type
run('initSelf.m') %% Will create a ply file 'initSelfImage.ply'
-> The ply result executed in my own computer is stored in 'self.ply'

To view the reconstruction (growing step) of the starbucks cup image, type
run('addMethod.m') %% Will create a ply file 'InitaddMethod.ply'
-> The ply result executed in my own computer is stored in 'addMethod.ply' and 'addMethod2.ply'