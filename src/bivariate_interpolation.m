#! /usr/bin/octave -qf

# Support scripts declaration
argument_checker;

function main(args)
  ##########
  # Select a function f
  f = @f1;
  # Select mode. 0 = bilinear. 1 = bicubic.
  mode = 1;
  # Select x value. x must be in [ax, bx]
  x = 3.11;
  # Select y value. y must be in [ay, by]
  y = -0.357;
  # Compression rate
  compression_rate = 5;
  ##########

  [nx, ny, ax, ay, bx, by, tests_enable, img] = extract(args);
endfunction






# Test functions
##############################################################
function z = f1(x, y)
  z = x^2 + y^2;
endfunction


main(argv());
