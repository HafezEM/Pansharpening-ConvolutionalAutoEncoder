clc
clear
close all
%  This code prepares the dataset to be used as the input and target of the
%  Convolutional AutoEncoder (CAE) network. 
%% Reference

%       A. Azarang, H. E. Manoochehri and N. Kehtarnavaz, "Convolutional Autoencoder-Based Multispectral 
%       Image Fusion," in IEEE Access, vol. 7, pp. 35673-35683, 2019.

%  Select the dataset , The satellite data you wish to work on

Dataset = 'P'; % 'W' = WorldView - 'Q' = Quickbird - 'S' = Stockholm_data - 'G' = GeoEye - 'P' =  Pleiades
SaveMode = 1; %0/1 Mode
Visualization = 0; %0/1 Mode
% The Patch_size of the training data with the overlapping pixel known as
% overlap.
Patch_size = 8;
overlap = 5;
% The datasets used 
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
%% Make the PAN and MS data ready for the processing

MSWV_db  = double(MSWV);
PanWV_db = double(PanWV);

%% Resizing, Upsampling the MS data to the size of PAN

MSWV_US  = imresize(MSWV_db, 4, 'bicubic');
PANWV_DS = imresize(PANWV_db, 1/4, 'bicubic');
PANWV_US = imresize(PANWV_DS, 4, 'bicubic');

%% Preparing the Training Set for the patching

[Patches_PAN_INP, BlX, BlY, PadX, PadY, r, c]  = Partitioning(PANWV_db, Patch_size, overlap);
[Patches_PAN_TRG, BlX, BlY, PadX, PadY, r, c]  = Partitioning(PANWV_US, Patch_size, overlap);

%% Preparing the Test Set for the patching 

MS_U_TST_1 = MSWV_US(:,:,1);
MS_U_TST_2 = MSWV_US(:,:,2);
MS_U_TST_3 = MSWV_US(:,:,3);
MS_U_TST_4 = MSWV_US(:,:,4);
 
[Patches_MS_U_TST_1, BlX, BlY, PadX, PadY, r, c]  = Partitioning(MS_U_TST_1, Patch_size, overlap);
[Patches_MS_U_TST_2, BlX, BlY, PadX, PadY, r, c]  = Partitioning(MS_U_TST_2, Patch_size, overlap);
[Patches_MS_U_TST_3, BlX, BlY, PadX, PadY, r, c]  = Partitioning(MS_U_TST_3, Patch_size, overlap);
[Patches_MS_U_TST_4, BlX, BlY, PadX, PadY, r, c]  = Partitioning(MS_U_TST_4, Patch_size, overlap); 

TestSet = [Patches_MS_U_TST_1, Patches_MS_U_TST_2, Patches_MS_U_TST_3, Patches_MS_U_TST_4];
%% Show the PAN, MS and Upsampled data

figure, imshow(uint8(PanWV),'border','tight');
figure, imshow(uint8(MSWV(:,:,1:3)),'border','tight');

if (SaveMode == 1)
    save ('Test.mat','TestSet');
    save ('Input.mat','Patches_PAN_INP');
    save ('Target.mat','Patches_PAN_TRG');
end