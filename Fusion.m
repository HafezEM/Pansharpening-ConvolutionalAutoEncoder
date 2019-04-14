clc
clear
close all

%     This code provide the fusion results of the
%     Convolutional AutoEncoder (CAE) network. 
%% Reference

%       A. Azarang, H. E. Manoochehri and N. Kehtarnavaz, "Convolutional Autoencoder-Based Multispectral 
%       Image Fusion," in IEEE Access, vol. 7, pp. 35673-35683, 2019.

%     This code is finaliezed the fusion process by first loading the estimated High
%     resoultion patches of LRMS bands, tilling the patches to reconstruct the
%     corresponding bands and at the end injecting the detail to obtain the
%     High resolution MS image. 

%% Loading the estimated High resolution LRMS patches

%     It consists of four sets of patches which corresponds to each MS
%     bands

load Estimated_HighLRMS 

% Select the dataset that used for training

Dataset = 'P'; % 'W' = WorldView - 'Q' = Quickbird - 'S' = Stockholm_data - 'G' = GeoEye - 'P' =  Pleiades

% The Patch_size of the training data with the overlapping pixel known as
% overlap.

Patch_size = 8;
overlap = 5;

switch Dataset
    case 'Q'
        addpath QuickBird %QuickBird folder        
        disp('Quickbird is dataset')
        load matlab_QuickBird
    case 'G'
        addpath GeoEye-1 %GeoEye-1 folder
        disp('GeoEye is dataset')
        load GeoEye_MS
        load GeoEye_Pan
    case 'P'
        addpath Pleiades-1A %Pleiades folder
        disp('Pleiades is dataset')
        load Pan_Pleiades_1
        load MS_Pleiades_1
        MSWV = MS_Pleiades_1;
        PanWV = Pan_Pleiades_1;
    otherwise
        disp('Dataset is not defined')
end

%% Adding the path of satellite data 

% addpath QuickBird_Data
% addpath Pleiades-1A_Data
% addpath GeoEye-1_Data


%% Make the PAN and MS data ready for the processing

MSWV_db  = double(MSWV);
PanWV_db = double(PanWV);

figure, imshow(uint8(PanWV),'border','tight');
figure, imshow(uint8(MSWV(:,:,1:3),'border','tight');

%% Preprocessing steps

MSWV_DS  =   imresize(MSWV, 1/4, 'bicubic');
MSWV_US  =   imresize(MSWV_DS, 4, 'bicubic');
PanWV_DS =  imresize(PanWV, 1/4, 'bicubic');

%% Finding the optimal weigthts of the LRMS bands

W = impGradDes(MSWV_US,PanWV_DS);
W_1 = W(1);
W_2 = W(2);
W_3 = W(3);
W_4 = W(4);

%% Histogram matching

I = W_1*MSWV_US(:,:,1)+W_2*MSWV_US(:,:,2)+W_3*MSWV_US(:,:,3)+W_4*MSWV_US(:,:,4);

PanWV_DS_2 = (PanWV_DS-mean(PanWV_DS(:)))*std(I(:))/std(PanWV_DS(:)) + mean(I(:));

%% Seperation of LRMS bands

MS_U_1 = MSWV_US(:,:,1);
MS_U_2 = MSWV_US(:,:,2);
MS_U_3 = MSWV_US(:,:,3);
MS_U_4 = MSWV_US(:,:,4);

%% Injection gains for primitive detail maps

Cov_1 = cov(MS_U_1(:),I(:))/var(I(:));
Cov_2 = cov(MS_U_2(:),I(:))/var(I(:));
Cov_3 = cov(MS_U_3(:),I(:))/var(I(:));
Cov_4 = cov(MS_U_4(:),I(:))/var(I(:));

gk_1 = Cov_1(1,2);
gk_2 = Cov_2(1,2);
gk_3 = Cov_3(1,2);
gk_4 = Cov_4(1,2);

%% Primitive deatil map

Det = PanWV_DS - I_New;

%% Tiling the High resolution LRMS bands

L = size(Patches_MS_U_1,2);
N = size(Patches_MS_U_1,1);

EHMS(:,:,1) = Tiling_av(Decoded(1:N,1:L), Patch_size, overlap, BlX, BlY, PadX, PadY, r, c);
EHMS(:,:,2) = Tiling_av(Decoded(1:N,L+1:2*L), Patch_size, overlap, BlX, BlY, PadX, PadY, r, c);
EHMS(:,:,3) = Tiling_av(Decoded(1:N,2*L+1:3*L), Patch_size, overlap, BlX, BlY, PadX, PadY, r, c);
EHMS(:,:,4) = Tiling_av(Decoded(1:N,3*L+1:4*L), Patch_size, overlap, BlX, BlY, PadX, PadY, r, c);

%% Fusion products

MSHR(:,:,1) = EHMS(:,:,1) + gk_1*Det;
MSHR(:,:,2) = EHMS(:,:,2) + gk_2*Det;
MSHR(:,:,3) = EHMS(:,:,3) + gk_3*Det;
MSHR(:,:,4) = EHMS(:,:,4) + gk_4*Det;

%% Objective Assessment 

addpath Objective_Evaluation
ERGAS = ERGAS(MSWV, MSHR, 4);
SAM = SAM_3(MSWV,MSHR);
RASE = RASE(MSWV, MSHR);
RMSE = RMSE(MSWV,MSHR);
UIQI = uqi(MSWV,MSHR);
SSIM = ssim(MSHR, MSWV);
CC = CC(MSWV, MSHR);
T = table(ERGAS, SAM,  RASE, RMSE, UIQI, CC)