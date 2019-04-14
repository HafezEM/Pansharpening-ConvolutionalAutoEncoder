function imout = Tiling_av(Patches, P, q, BlX, BlY, PadX, PadY, r, c)
%% References
% (1) M. Ghahremani, and H. Ghassemian, "Nonlinear IHS: A promising method for pan-sharpening," 
%        IEEE Geoscience and Remote Sensing Letters, vol. 13, no. 11, pp. 1606-1610, 2016.
% (2) A. Azarang, H. E. Manoochehri and N. Kehtarnavaz, "Convolutional Autoencoder-Based Multispectral Image Fusion," 
%        IEEE Access, vol. 7, pp. 35673-35683, 2019.
%% Descrption
%      Inputs
%      Patches   input image patches
%      P         patch size for partioning input images
%      q         overlap between two adjacent patches
%      Patches   an array of patches
%      BlX       the number of blocks in the direction of X
%      BlY       the number of blocks in the direction of Y
%      PadX      the number of pads required in the direction of X
%      PadY      the number of pads required in the direction of Y
%      [r c]     the size of original image (without paddings)
%      Outputs
%      imout        the desired tiled image 
%      Tiling patches through  average method

input = reshape(Patches, [P, P, BlX*BlY]); % reshape patches into P*P blocks 
x  = zeros(r+PadY , c+PadX);                     % the reconstructed image
l1 = [P q];
l2 = [q P];

%% our scheme
%     I  I  I  I
%    V  M  M  M
%    V  M  M  M
%    V  M  M  M
%% Margin #I: Upperhand 

ii = 1;
ri1 = zeros(1,BlY); 
ri2 = zeros(1,BlY);

ri1(ii) = 1; ri2(ii) = P;
ri = [ri1(ii):ri2(ii)];

jj = 1;
ci1 = zeros(1,BlX);ci2 = zeros(1,BlX);
ci1(jj) = 1; ci2(jj) = P;
ci = [ci1(jj):ci2(jj)];

posi = (ii-1)*BlX + jj;
y = input(:,:,posi);
x(ri,ci) = x(ri,ci) + y;
for jj = 2:BlX
    ci1(jj) = ci2(jj-1)-q+1;  ci2(jj) = ci1(jj)+P-1;
    ci      = [ci1(jj):ci2(jj)];
    posi    = (ii-1)*BlX+jj;
    y       = input(:,:,posi);
    
    cio = [ci1(jj):ci1(jj)+q-1];  
    cin = [ci1(jj)+q:ci2(jj)];   
    
    x(ri,cio) = 0.5*(x(ri,cio)+y(:,1:q));
    x(ri,cin) = x(ri,cin) + y(:, q+1:end);
end
%% Margin #V: Lefthand 
jj = 1;
ci1 = zeros(1,BlX);ci2 = zeros(1,BlX);
ci1(jj) = 1; ci2(jj) = P;
ci = [ci1(jj):ci2(jj)];

% 1-
ii = 1;ri1 = zeros(1,BlY);
ri2 = zeros(1,BlY);ri1(ii) = 1; ri2(ii) = P; % clear the ri1 ri2
for ii = 2:BlY
    ri1(ii) = ri2(ii-1)-q+1;  ri2(ii) = ri1(ii)+P-1;
    ri      = [ri1(ii):ri2(ii)];
    posi    = (ii-1)*BlX+jj;
    y       = input(:,:,posi);
    
    rio = [ri1(ii):ri1(ii)+q-1]; 
    rin = [ri1(ii)+q:ri2(ii)];   
    
    x(rio,ci) = 0.5*(x(rio,ci)+ y(1:q,:));
    x(rin,ci) = x(rin,ci) + y(q+1:end, :);
end
%% Middle #M
ii = 1;ri1 = zeros(1,BlY);ri2 = zeros(1,BlY);ri1(ii) = 1; ri2(ii) = P; % clear the ri1 ri2
jj = 1;ci1 = zeros(1,BlX);ci2 = zeros(1,BlX);ci1(jj) = 1; ci2(jj) = P; % clear the ci1 ci2

for ii = 2:BlY
    ri1(ii) = ri2(ii-1)-q+1;  ri2(ii) = ri1(ii)+P-1;
    ri = [ri1(ii):ri2(ii)];
    
    rio = [ri1(ii):ri1(ii)+q-1];  
    rin = [ri1(ii)+q:ri2(ii)];    
    for jj = 2:BlX
        posi = (ii-1)*BlX+jj;
        y = input(:,:,posi);
        
        ci1(jj) = ci2(jj-1)-q+1;  ci2(jj) = ci1(jj)+P-1;
        ci = [ci1(jj):ci2(jj)];
        
        cio = [ci1(jj):ci1(jj)+q-1];   
        cin = [ci1(jj)+q:ci2(jj)]; 
        
        x(ri,cio)  = 0.5*(x(ri,cio)+y(:,1:q));
        x(rio,ci)  = 0.5*(x(rio,ci)+ y(1:q,:));
        x(rin,cin) = x(rin,cin) + y(q+1:end, q+1:end);
    end
end

imout = x(1:ri2(end)-PadY,1:ci2(end)-PadX);
end

%%%%%%%
function out = CosineWindow(S, mode1, mode2)

if mode1 == 'row'
    out.win1 = (cos(pi*(0:S-1)/(2*S))).^2;
    out.win1 = repmat(out.win1, [mode2 1]);
    out.win2 = (cos(pi*(-S:-1)/(2*S))).^2;
    out.win2 = repmat(out.win2, [mode2 1]);
else
    out.win1 = transpose((cos(pi*(0:S-1)/(2*S))).^2);
    out.win1 = repmat(out.win1, [1 mode2]);
    out.win2 = transpose((cos(pi*(-S:-1)/(2*S))).^2);
    out.win2 = repmat(out.win2, [1 mode2]);
end
end
%%%%%%%
function output = Overlapping( xo, P, l)

[Max , kmax] = max(l);
[Min , kmin] = min(l);

Mode1 = 0;
Mode2 = Max;
if kmax == 1
    Mode1 = 'row';
end

if Min ==0
    xout = xo;
else
    xout = zeros(l);
    W = CosineWindow(Min, Mode1, Mode2);
    if kmax == 1
        xout = xo.*W.win1 + P.*W.win2;
    else
        xout = xo.*W.win1 + P.*W.win2;
    end
end
    output = xout;
end