
% read in nifti
tmp = niftiRead('../t2.nii.gz');

% number of slices to make up midline
slices = 1:157;

% starting slice for viewing
starting_slice = 50;

% cut image at midline and flip to combine into 1 image
origHalf = tmp.data(slices,:,:);
flipHalf = flipud(origHalf);

% merge into new figure
newFig = vertcat(origHalf, flipHalf);

% display slices to check
figure;
count = 1;
for ii =1:10:200
subplot(5,4,count)   
imagesc(rot90(newFig(:, :, starting_slice+ii))); 
    axis square; axis equal; axis tight; axis off;
    count = count + 1;
end

% check the best output option
figure; imagesc(rot90(newFig(:, :, 201))); axis square; axis equal; axis tight; axis off; 

% MATCH IMAGE DIMENSIONS BEFORE SAVING
size(newFig) - size(tmp.data)

% add 3 empty y by z matrices to data to keep the same dimension
filler = zeros(3, 320, 256);

% add extra spaces evenly on each side
out = cat(1, filler, newFig);
out = cat(1, out, filler);

% create nifti object 
outNii = tmp;
outNii.data = out;
outNii.fname = 't2_symmetric.nii.gz';
outNii.descrip = '';

% save nifti out
niftiWrite(outNii, 't2_symmetric.nii.gz');
% shows up in micrometers...


%% development notes
figure; imagesc(tmp.data(1:160, :, 150)); axis square; axis equal;
figure; imagesc(flipud(tmp.data(1:170, :, 150))); axis square; axis equal;