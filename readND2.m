function im_array = readND2(filename)

% make sure to download bfmatlab.zip and extract in Documents/MATLAB
% before proceeding.

ND2_obj = bfopen(filename);

% I'm assuming only one series in file -- never seen an exception, at least
% in the files we work with...

images = ND2_obj{1}; nr_images = size(images,1);

% get width and height from representative image
im = images{1,1}; [h, w] = size(im);

% Pre-allocate array. 
% Large ND2 files may fail at this step depending on system and OS.
% See here for some potential solutions: 
% https://www.mathworks.com/help/matlab/matlab_prog/resolving-out-of-memory-errors.html
im_array = zeros(h,w,nr_images,'uint16');

for ii = 1:nr_images
    im_array(:,:,ii) = images{ii,1};
end

% reshape array into proper shape (accounting for z and t)
% we'll need z and t dimension size for this.

% get descriptor associated with the first plane
% a sample descriptor looks like this:
% '~/Desktop/filename.nd2; plane 1/504; Z=1/56; T=1/9'
descriptor = images{1,2};

% remove filename (delete everything up to and including the space 
% after the first semicolon)

descriptor = descriptor(strfind(descriptor,';')+2:end);

extracted_nums = sscanf(descriptor, 'plane %i/%i; Z=%i/%i; T=%i/%i');

% extracted_nums should be in format [1,d1,1,d2,1,d3] where d2*d3 = d1
nr_planes = extracted_nums(2);
nr_z      = extracted_nums(4);
nr_t      = extracted_nums(6);
assert(nr_z * nr_t == nr_planes);

% if everything is fine, reshape the image stack
im_array = reshape(im_array,[h, w, nr_z, nr_t]);

