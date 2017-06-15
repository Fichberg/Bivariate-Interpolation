#! /usr/bin/octave -qf

# Prevent Octave from thinking that this is a function file:
1;

# Extract values from CLI to image program
function [img, mode, compression_rate] = extract(args)
  compression_rate = mode = -1;
  img = "";

  i = 1;
  while i <= length(args)
    if strcmp("--image", args{i}) && (i < length(args))
      if exist(strcat("../images/", args{i + 1}), "file") == 2
        img = strcat("../images/", args{i + 1});
      else
        printf("Unable to locate requested image file.");
        exit;
      endif
    elseif strcmp("--cr", args{i}) && (i < length(args))
      try
        compression_rate = str2num(args{i + 1});
        if compression_rate <= 1
          printf("Compression rate must be an integer > 1.");
          exit;
        elseif (compression_rate - floor(compression_rate)) > 0
          printf("Compression rate must be an integer > 1.");
          exit;
        endif
      catch
        compression_rate
        printf("Compression rate must be an integer > 1.");
        exit;
      end_try_catch
    elseif strcmp("--bicubic", args{i})
      if mode == -1
        mode = 1;
      else
        printf("More than one call to mode parameters found in the command line.");
        exit;
      endif
      i++;
      continue;
    elseif strcmp("--bilinear", args{i})
      if mode == -1
        mode = 0;
      else
        printf("More than one call to mode parameters found in the command line.");
        exit;
      endif
      i++;
      continue;
    else
      printf("Wrong program invocation. Check if every parameters have a valid value or if they are invoked correctly (typos are more likely to be the problem).");
      exit;
    endif
    i += 2;
  endwhile

  if mode == -1
    printf("Missing mode. Use '--bilinear' to run in bilinear mode and '--bicubic' to run in bicubic mode.");
    exit;
  endif

  if compression_rate == -1
    printf("Missing compression rate. Use '--cr' <integer> to set a compression rate. Integer value must be > 1.");
    exit;
  endif
endfunction

# Extract values from CLI to function program (used mainly to perform the tests routine)
function [nx, ny, ax, ay, bx, by, mode, x, y] = extract2(args)
  dont_have_x = dont_have_y = dont_have_nx = dont_have_ny = dont_have_ax = dont_have_ay = dont_have_bx = dont_have_by = true;
  mode = -1;
  img = "";

  i = 1;
  while i <= length(args)
    if strcmp("--nx", args{i}) && (i + 1 <= length(args))
      nx = floor(str2num(args{i + 1}));
      dont_have_nx = false;
      if nx < str2num(args{i + 1})
        printf("WARNING: detected %s as argument for '--nx' parameter. Will be used %d instead (must be integer).\n", args{i + 1}, by);
      endif
      if isempty(nx)
        printf("Expected an integer as argument for '--nx' parameter.");
        exit;
      endif
    elseif strcmp("--ny", args{i}) && (i + 1 <= length(args))
      ny = floor(str2num(args{i + 1}));
      dont_have_ny = false;
      if ny < str2num(args{i + 1})
        printf("WARNING: detected %s as argument for '--ny' parameter. Will be used %d instead (must be integer).\n", args{i + 1}, by);
      endif
      if isempty(ny)
        printf("Expected an integer as argument for '--ny' parameter.");
        exit;
      endif
    elseif strcmp("--ax", args{i}) && (i + 1 <= length(args))
      ax = str2double(args{i + 1});
      dont_have_ax = false;
      if isnan(ax)
        printf("Expected a double as argument for '-a-x' parameter.");
        exit;
      endif
    elseif strcmp("--ay", args{i}) && (i + 1 <= length(args))
      ay = str2double(args{i + 1});
      dont_have_ay = false;
      if isnan(ay)
        printf("Expected a double as argument for '--ay' parameter.");
        exit;
      endif
    elseif strcmp("--bx", args{i}) && (i + 1 <= length(args))
      bx = str2double(args{i + 1});
      dont_have_bx = false;
      if isnan(bx)
        printf("Expected a double as argument for '--bx' parameter.");
        exit;
      endif
    elseif strcmp("--by", args{i}) && (i + 1 <= length(args))
      by = str2double(args{i + 1});
      dont_have_by = false;
      if isnan(by)
        printf("Expected a double as argument for '--by' parameter.");
        exit;
      endif
    elseif strcmp("--x", args{i}) && (i + 1 <= length(args))
      x = str2double(args{i + 1});
      dont_have_x = false;
      if isnan(ax)
        printf("Expected a double as argument for '--x' parameter.");
        exit;
      endif
    elseif strcmp("--y", args{i}) && (i + 1 <= length(args))
      y = str2double(args{i + 1});
      dont_have_y = false;
      if isnan(ax)
        printf("Expected a double as argument for '--y' parameter.");
        exit;
      endif
    elseif strcmp("--bicubic", args{i})
      if mode == -1
        mode = 1;
      else
        printf("More than one call to mode parameters found in the command line.");
        exit;
      endif
      i++;
      continue;
    elseif strcmp("--bilinear", args{i})
      if mode == -1
        mode = 0;
      else
        printf("More than one call to mode parameters found in the command line.");
        exit;
      endif
      i++;
      continue;
    else
      printf("Wrong program invocation. Check if every parameters have a valid value or if they are invoked correctly (typos are more likely to be the problem).");
      exit;
    endif
    i += 2;
  endwhile

  if mode == -1
    printf("Missing mode. Use '--bilinear' to run in bilinear mode and '--bicubic' to run in bicubic mode.");
    exit;
  endif

  if dont_have_x
    printf("Missing '--x' parameter.");
    exit;
  endif

  if dont_have_y
    printf("Missing '--y' parameter.");
    exit;
  endif

  if dont_have_nx
    printf("Missing '--nx' parameter.");
    exit;
  endif

  if dont_have_ny
    printf("Missing '--ny' parameter.");
    exit;
  endif

  if dont_have_ax
    printf("Missing '--ax' parameter.");
    exit;
  endif

  if dont_have_ay
    printf("Missing '--ay' parameter.");
    exit;
  endif

  if dont_have_bx
    printf("Missing '--bx' parameter.");
    exit;
  endif

  if dont_have_by
    printf("Missing '--by' parameter.");
    exit;
  endif

  if ax >= bx
    printf("Expected ax < bx.");
    exit;
  endif

  if ay >= by
    printf("Expected ay < by.");
    exit;
  endif

  if nx <= 0
    printf("Expected positive nx.");
    exit;
  endif

  if ny <= 0
    printf("Expected positive ny.");
    exit;
  endif

  if x < ax || x > bx
    printf("Expected ax <= x <= bx.");
    exit;
  endif

  if y < ay || y > by
    printf("Expected ay <= y <= by.");
    exit;
  endif
endfunction
