Convolutional Autoencoder-Based Multispectral Image Fusion
====================================================

Overview
-----
This repository contains code necessary to run our deep learning-based pansharpening method for fusion of panchromatic
and multispectral images in remote sensing applications. See our paper for details on the algorithm.


Usage: Pansharpening
-----

Convolutional Autoencoder-Based Multispectral Image Fusion is a new deep learning-based method for multispectral image fusion based on the convolutional autoencoder architecture. For more information, see the following paper:
> A. Azarang, H. E. Manoochehri, N. Kehtarnavaz, Convolutional Autoencoder-Based Multispectral Image Fusion, IEEE Access. [\[PDF\]](https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=8668404)

> __Abstract__: This paper presents a deep learning-based pansharpening method for fusion of panchromatic
and multispectral images in remote sensing applications. This method can be categorized as a component
substitution method in which a convolutional autoencoder network is trained to generate original panchromatic
images from their spatially degraded versions. Low resolution multispectral images are then fed into
the trained convolutional autoencoder network to generate estimated high resolution multispectral images.
The fusion is achieved by injecting the detail map of each spectral band into the corresponding estimated high
resolution multispectral bands. Full reference and no-reference metrics are computed for the images of three
satellite datasets. These measures are compared with the existing fusion methods whose codes are publicly
available. The results obtained indicate the effectiveness of the developed deep learning-based method for
multispectral image fusion.

<p align="center">
<img src="https://github.com/HafezEM/Pansharpening-ConvolutionalAutoEncoder/blob/master/images/GraphicalAbstract.png" width="800" align="center">
</p>


Getting Started
----------


First, you need to use Data_Generation.m to prepare your data to be used in our pansharpening framework. We only use 4-Bands MultiSpectral (MS) data for our study. (B, G, R, NIR bands) 

    Add path of your data
 
The path should contain the MS and PANchromatic (PAN) data. Also, It can be .mat files (MAT-files).

    Importing the MS and PAN data

After running the Data_Generation.m, 3 files are saved to the directory: 

    Input.m   // it is used to serve as the input of the netowrk
    Target.m  // it is used to serve as the target of the network
    Test.m    // it is used to test the perforamnce of the network based on Low Resolution MS (LRMS) patches

Then, run Auto_Conv.ipynb to train the Convolutional AutoEncoder (CAE) network. 
    
After training the CAE network, the output of the netowrk in response to the LRMS patches is saved as .mat file (MAT-file) to be processed into the fusion framework.

To finalize the fusion process and get the result, run the Fusion.m file in MATLAB. This MATLAB file will import the estimated high resolution MS patches. The tiling_av.m file will reconstruct the estimated high resoultion MS band using the output of the CAE network. 

To do the objective assesmet, do the following: 
    Add objecticve evaluation path to your current directory
    follow the sturcture of using metrics mentioned in the Fusion.m
    Create a table in _Command Window_ and see the results.

Requirements
------------

The code is written in Python 3 and uses Keras and also MATLAB. Recent versions of Tensorflow, sklearn, networkx, numpy, and scipy are required. All the required packages can be installed using the following command:
    
    $ pip install -r requirements.txt


