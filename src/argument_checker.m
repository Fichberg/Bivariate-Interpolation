#! /usr/bin/octave -qf

# Prevent Octave from thinking that this is a function file:
1;

# Extract values from CLI
function [tests_enable, img] = extract(args)
  tests_enable = false;
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
endfunction
