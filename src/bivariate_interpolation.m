#! /usr/bin/octave -qf

# Support scripts declaration
argument_checker;

function main(args)
  ##########
  # Select mode. 0 = bilinear. 1 = bicubic.
  mode = 1;
  # Select x value. x must be in [ax, bx]
  x = 3.11;
  # Select y value. y must be in [ay, by]
  y = -0.357;
  # Compression rate
  compression_rate = 5;
  ##########

  # Get arguments
  [tests_enable, image_path] = extract(args);

  # Get image and image matrix parameters
  [image_, image_R, image_G, image_B] = get_image_matrices(image_path);
  [nx, ny, ax, ay, bx, by, hx, hy] = get_image_parameters(image_);

  # Compress image and save the compressed images
  printf("Compressing '%s'.\n", image_path);
  [compressed_, compressed_R, compressed_G, compressed_B] = get_compressed_matrices(image_R, image_G, image_B, compression_rate);
  write_compressed_images(compressed_, compressed_R, compressed_G, compressed_B);

endfunction

function write_compressed_images(compressed_, compressed_R, compressed_G, compressed_B)
  printf("Writing compressed image (\033[0;31mred channel\033[0m) to 'images/compressed_red.jpg'.\n");
  imwrite(compressed_R, "../images/compressed_red.jpg");
  printf("Writing compressed image (\033[0;32mgreen channel\033[0m) to 'images/compressed_green.jpg'.\n");
  imwrite(compressed_G, "../images/compressed_green.jpg");
  printf("Writing compressed image (\033[0;34mblue channel\033[0m) to 'images/compressed_blue.jpg'.\n");
  imwrite(compressed_B, "../images/compressed_blue.jpg");
  printf("Writing compressed image to 'images/compressed.jpg'.\n");
  imwrite(compressed_, "../images/compressed.jpg");
endfunction

# Get compressed image matrices
function [compressed_, compressed_R, compressed_G, compressed_B] = get_compressed_matrices(image_R, image_G, image_B, compression_rate)
  compressed_R = compress(image_R, compression_rate);
  compressed_G = compress(image_G, compression_rate);
  compressed_B = compress(image_B, compression_rate);
  compressed_ = reshape(1:(rows(compressed_R) * columns(compressed_R) * 3), rows(compressed_R), columns(compressed_R), 3);
  compressed_(:,:,1) = compressed_R;
  compressed_(:,:,2) = compressed_G;
  compressed_(:,:,3) = compressed_B;
endfunction

# Compress image using the compression rate parameter
function compressed_ = compress(image_, compression_rate)
  compressed_ = [];

  row = rows(image_);
  while row >= 1
    if rem(row, compression_rate) == 0
      row--;
      continue;
    endif

    column = 1;
    new_row = [];
    while column <= columns(image_)
      if rem(column, compression_rate) == 0
        column++;
        continue;
      endif
      new_row = [new_row, image_(row, column)];
      column++;
    endwhile
    row--;
    compressed_ = [new_row; compressed_];
  endwhile
endfunction

# Get image parameters
function [nx, ny, ax, ay, bx, by, hx, hy] = get_image_parameters(image_)
  ax = 0;
  ay = 0;
  bx = columns(image_);
  by = rows(image_);
  nx = bx - ax;
  ny = by - ay;
  hx = (bx - ax) / nx; # = 1 for the image
  hy = (by - ay) / ny; # = 1 for the image
endfunction

# Get image and its RGB channels matircs
function [image_, image_R, image_G, image_B] = get_image_matrices(image_path)
  image_ = imread(image_path);
  image_R = image_(:,:,1);
  image_G = image_(:,:,2);
  image_B = image_(:,:,3);
endfunction



main(argv());
