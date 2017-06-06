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

  [tests_enable, image_path] = extract(args);
  [image_, image_R, image_G, image_B] = get_image_matrices(image_path);
  [nx, ny, ax, ay, bx, by, hx, hy] = get_image_parameters(image_);
  printf("Computing bijection.\n");
  [fx, bijection] = do_bijection(image_R);
  



endfunction

# Bijection bewtween pixels values andassociated integers
function [fx, bijection] = do_bijection(image_)
  fx = [];
  bijection = [];
  associated_integer = 0;

  row = rows(image_);
  while row >= 1
    column = 1;
    fx_row = [];

    while column <= columns(image_)
      integer_index = 1;

      while integer_index <= rows(bijection)
        if bijection(integer_index, 2) == image_(row, column)
          break;
        endif
        integer_index++;
      endwhile

      if integer_index > rows(bijection)
        bijection = [bijection; [associated_integer++, image_(row, column)]];
      endif
      fx_row = [fx_row, bijection(integer_index, 1)];

      column++;
      #row
      #column
    endwhile
    fx = [fx_row; fx];
    row--;
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
