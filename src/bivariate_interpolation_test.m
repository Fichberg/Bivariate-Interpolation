#! /usr/bin/octave -qf

# Support scripts declaration
argument_checker;

function main(args)
  # Select a function f
  f = @f1;

  # Get arguments
  [nx, ny, ax, ay, bx, by, mode, compression_rate, x, y] = extract2(args);
  hx = (bx - ax) / nx; hy = (by - ay) / ny;

  # Get matrix
  fx = get_image_matrix(nx, ny, ax, ay, bx, by, hx, hy, f);

  # Compute coefficients
  vx = build_v(mode, fx, ax, ay, bx, by, hx, hy);

  # Evaluate a given point (x, y) using vx
  z = evaluate_v(vx, x, y, ax, ay, bx, by, hx, hy, mode);

endfunction

# Evaluate a given point (x, y) in vx (interpolates (x,y))
function z = evaluate_v(vx, x, y, ax, ay, bx, by, hx, hy, mode)
  row = rows(vx);
  yy = ay;
  while row > 1
    if yy <= y && y <= (yy + hy)
      break;
    endif
    yy += hy;
    row--;
  endwhile

  col = 1;
  xx = ax;
  while col < columns(vx)
    if xx <= x && x <= (xx + hx)
      break;
    endif
    xx += hx;
    col++;
  endwhile

  if mode == 0
    z = vx(row, col).c0 + (vx(row, col).c1 * (x - xx)) + (vx(row, col).c2 * (y - yy)) + (vx(row, col).c3 * ((x - xx) * (y - yy)));
  else
    left_matrix  = [1, (x - xx), (x - xx) * (x - xx), (x - xx) * (x - xx) * (x - xx)];
    right_matrix = [1; (y - yy); (y - yy) * (y - yy); (y - yy) * (y - yy) * (y - yy)];
    coefficients = [vx(row, col).c0,  vx(row, col).c1,  vx(row, col).c2,  vx(row, col).c3;
                    vx(row, col).c4,  vx(row, col).c5,  vx(row, col).c6,  vx(row, col).c7;
                    vx(row, col).c8,  vx(row, col).c9,  vx(row, col).c10, vx(row, col).c11;
                    vx(row, col).c12, vx(row, col).c13, vx(row, col).c14, vx(row, col).c15;];
    z = left_matrix * coefficients * right_matrix;
  endif
endfunction

# Build v(x, y)
function vx = build_v(mode, fx, ax, ay, bx, by, hx, hy)
  if mode == 0
    printf("Computing bilinear mode coefficients for f(x, y)... ");
    vx = bilinear_method(fx, hx, hy);
    printf("Done!\n");
  else
    # Compute derivatives
    [dfx, dfy, d2fxy] = aproxdf(ax, ay, bx, by, hx, hy, fx);
    # Get matrices in function of h to compute coefficients for bicubic interpolation
    [mx, my] = h_matrices(hx, hy);
    printf("Computing bicubic mode coefficients for f(x, y)... ");
    vx = bicubic_method(fx, dfx, dfy, d2fxy, hx, hy, mx, my);
    printf("Done!\n");
  endif
endfunction

# Compute bicubic method's coefficients
function vx = bicubic_method(fx, dfx, dfy, d2fxy, hx, hy, mx, my)
  row = rows(fx);
  while row > 1
    column = 1;
    while column < columns(fx)

      mh = [
          fx(row, column),      fx(row - 1, column),      dfy(row, column),       dfy(row - 1, column);
          fx(row, column + 1),  fx(row - 1, column + 1),  dfy(row, column + 1),   dfy(row - 1, column + 1);
          dfx(row, column),     dfx(row - 1, column),     d2fxy(row, column),     d2fxy(row - 1, column);
          dfx(row, column + 1), dfx(row - 1, column + 1), d2fxy(row, column + 1), d2fxy(row - 1, column + 1);
        ];
      mh = double(mh);
      coefficients = mx * mh * my;

      vx(row - 1, column).c0  = coefficients(1, 1);
      vx(row - 1, column).c1  = coefficients(1, 2);
      vx(row - 1, column).c2  = coefficients(1, 3);
      vx(row - 1, column).c3  = coefficients(1, 4);
      vx(row - 1, column).c4  = coefficients(2, 1);
      vx(row - 1, column).c5  = coefficients(2, 2);
      vx(row - 1, column).c6  = coefficients(2, 3);
      vx(row - 1, column).c7  = coefficients(2, 4);
      vx(row - 1, column).c8  = coefficients(3, 1);
      vx(row - 1, column).c9  = coefficients(3, 2);
      vx(row - 1, column).c10 = coefficients(3, 3);
      vx(row - 1, column).c11 = coefficients(3, 4);
      vx(row - 1, column).c12 = coefficients(4, 1);
      vx(row - 1, column).c13 = coefficients(4, 2);
      vx(row - 1, column).c14 = coefficients(4, 3);
      vx(row - 1, column).c15 = coefficients(4, 4);
      column++;
    endwhile
    row--;
  endwhile
endfunction

# Compute bilinear method's coefficients
function vx = bilinear_method(fx, hx, hy)
  row = rows(fx);
  while row > 1
    column = 1;
    while column < columns(fx)
      vx(row - 1, column).c0 = fx(row, column);
      vx(row - 1, column).c1 = (fx(row, column + 1) - vx(row - 1, column).c0) / hx;
      vx(row - 1, column).c2 = (fx(row - 1, column) - vx(row - 1, column).c0) / hy;
      vx(row - 1, column).c3 = (fx(row - 1, column + 1) - vx(row - 1, column).c0 - (hx * vx(row - 1, column).c1) - (hy * vx(row - 1, column).c2)) / (hx * hy);
      column++;
    endwhile
    row--;
  endwhile
endfunction

# Compute matrices used to compute the coefficients
function [mx, my] = h_matrices(hx, hy)
  mx = [
    1.0,                   0.0,                  0.0,             0.0;
    0.0,                   0.0,                  1.0,             0.0;
   -3.0 / (hx * hx),       3.0 / (hx * hx),     -2.0 / hx,       -1.0 / hx;
    2.0 / (hx * hx * hx), -2.0 / (hx * hx * hx), 1.0 / (hx * hx), 1.0 / (hx * hx)
  ];
  my = [
    1.0, 0.0, -3.0 / (hy * hy),  2.0 / (hy * hy * hy);
    0.0, 0.0,  3.0 / (hy * hy), -2.0 / (hy * hy * hy);
    0.0, 1.0, -2.0 / hy,         1.0 / (hy * hy);
    0.0, 0.0, -1.0 / hy,         1.0 / (hy * hy)
  ];
endfunction

# Compute all partial derivatives
function [dfx, dfy, d2fxy] = aproxdf(ax, ay, bx, by, hx, hy, fx)
  # dfx
  printf("Computing partial derivative on x (dfx) for f(x, y)... ");
  dfx = compute_dfx(ax, ay, bx, by, hx, hy, fx);
  printf("Done!\n");

  # dfy
  printf("Computing partial derivative on y (dfy) for f(x, y)... ");
  dfy = compute_dfy(ax, ay, bx, by, hx, hy, fx);
  printf("Done!\n");

  # d2fxy
  printf("Computing mixed derivatives (d2fxy) for f(x, y)... ");
  d2fxy = compute_d2fxy(ax, ay, bx, by, hx, hy, dfy);
  printf("Done!\n");
endfunction

# Compute d2fxy
function d2fxy = compute_d2fxy(ax, ay, bx, by, hx, hy, dfy)
  d2fxy = [];

  row = rows(dfy);
  while row >= 1
    column = 1;
    new_row = [];
    while column <= columns(dfy)
      if column == 1
        new_row = [new_row, (dfy(row, column + 1) - dfy(row, column)) / hx];
      elseif column == columns(dfy)
        new_row = [new_row, (dfy(row, column) - dfy(row, column - 1)) / hx];
      else
        new_row = [new_row, (dfy(row, column + 1) - dfy(row, column - 1)) / (2 * hx)];
      endif
      column++;
    endwhile
    row--;
    d2fxy = [new_row; d2fxy];
  endwhile
endfunction

# Compute dfy
function dfy = compute_dfy(ax, ay, bx, by, hx, hy, fx)
  dfy = [];

  row = rows(fx);
  while row >= 1
    column = 1;
    new_row = [];
    while column <= columns(fx)
      if row == 1
        new_row = [new_row, (fx(row + 1, column) - fx(row, column)) / hy];
      elseif row == rows(fx)
        new_row = [new_row, (fx(row, column) - fx(row - 1, column)) / hy];
      else
        new_row = [new_row, (fx(row + 1, column) - fx(row - 1, column)) / (2 * hy)];
      endif
      column++;
    endwhile
    row--;
    dfy = [new_row; dfy];
  endwhile
endfunction

# Compute dfx
function dfx = compute_dfx(ax, ay, bx, by, hx, hy, fx)
  dfx = [];

  row = rows(fx);
  while row >= 1
    column = 1;
    new_row = [];
    while column <= columns(fx)
      if column == 1
        new_row = [new_row, (fx(row, column + 1) - fx(row, column)) / hx];
      elseif column == columns(fx)
        new_row = [new_row, (fx(row, column) - fx(row, column - 1)) / hx];
      else
        new_row = [new_row, (fx(row, column + 1) - fx(row, column - 1)) / (2 * hx)];
      endif
      column++;
    endwhile
    row--;
    dfx = [new_row; dfx];
  endwhile
endfunction

# Draw fx in a matrix
function fx = get_image_matrix(nx, ny, ax, ay, bx, by, hx, hy, f)
  fx = [];

  i = ay;
  while i <= by
    j = ax;
    row = [];
    while j <= bx
      row = [f(j, i), row];
      j += hx;
    endwhile
    fx = [fx; row];
    i += hy;
  endwhile
endfunction

# Test functions
##############################################################
function z = f1(x, y)
  z = x^2 + y^2;
endfunction

main(argv());
