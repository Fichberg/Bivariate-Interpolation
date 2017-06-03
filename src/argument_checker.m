#! /usr/bin/octave -qf

# Prevent Octave from thinking that this is a function file:
1;

# Extract values from CLI
function [nx, ny, ax, ay, bx, by, tests_enable, img] = extract(args)
  tests_enable = false;
  img = "";

  if length(args) < 12
    printf("Missing arguments. Read documentation for further information.");
    exit;
  elseif length(args) > 15
    printf("Too many arguments. Read documentation for further information.");
    exit;
  endif

  i = 1;
  while i <= length(args)
    if strcmp("-nx", args{i}) && (i < length(args))
      nx = floor(str2num(args{i + 1}));
      if nx < str2num(args{i + 1})
        printf("WARNING: detected %s as argument for '-nx' parameter. Will be used %d instead (must be integer).\n", args{i + 1}, by);
      endif
      if isempty(nx)
        printf("Expected an integer as argument for '-nx' parameter.");
        exit;
      endif
    elseif strcmp("-ny", args{i}) && (i < length(args))
      ny = floor(str2num(args{i + 1}));
      if ny < str2num(args{i + 1})
        printf("WARNING: detected %s as argument for '-ny' parameter. Will be used %d instead (must be integer).\n", args{i + 1}, by);
      endif
      if isempty(ny)
        printf("Expected an integer as argument for '-ny' parameter.");
        exit;
      endif
    elseif strcmp("-ax", args{i}) && (i < length(args))
      ax = str2double(args{i + 1});
      if isnan(ax)
        printf("Expected a double as argument for '-ax' parameter.");
        exit;
      endif
    elseif strcmp("-ay", args{i}) && (i < length(args))
      ay = str2double(args{i + 1});
      if isnan(ay)
        printf("Expected a double as argument for '-ay' parameter.");
        exit;
      endif
    elseif strcmp("-bx", args{i}) && (i < length(args))
      bx = str2double(args{i + 1});
      if isnan(bx)
        printf("Expected a double as argument for '-bx' parameter.");
        exit;
      endif
    elseif strcmp("-by", args{i}) && (i < length(args))
      by = str2double(args{i + 1});
      if isnan(by)
        printf("Expected a double as argument for '-by' parameter.");
        exit;
      endif
    elseif strcmp("--image", args{i}) && (i < length(args))
      if exist(strcat("../images/", args{i + 1}), "file") == 2
        img = strcat("../images/", args{i + 1});
      else
        printf("Unable to locate requested image file.");
        exit;
      endif
    elseif strcmp("--tests", args{i})
      tests_enable = true;
      i++;
      continue;
    else
      printf("Wrong program invocation. Check if every parameters have a valid value or if they are invoked correctly (typos are more likely to be the problem).");
      exit;
    endif
    i += 2;
  endwhile

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
endfunction
