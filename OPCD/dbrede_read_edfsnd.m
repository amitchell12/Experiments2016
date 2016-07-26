function [M, X, A] = dbrede_read_edfsnd(filename, varargin)

% brede_read_edf       - Read Eyelink EDF file
%
%       Input:    filename  Filename for the EDF file
%
%    %
%       Output:   M and A         'mat' structure
%
%       M -  all data lines will be returned with columns
%       indicating whether the line is within a saccade, blink, 'PUSHON' and 'CONTROLON' block.
%
%       X - only the non blink, non saccade, in block rows
%
%       A-  will compute the average within each 
%       'LEDON' block exluding lines with saccade or blink.       
%
%       Example: 
%         M = brede_read_edf('eyelink.edf') 
%
%      
% 
%       See also BREDE, BREDE_READ.
%
% $Id: brede_read_edf.m,v 1.2 2010/10/12 09:24:03 fn Exp $


  % Default properties
  type = 'all';

  % Read properties
  n = 1;
  while n < length(varargin)
    arg = lower(varargin{n}); 

    if strcmp(arg, 'type')
      n = n + 1;
      arg = lower(varargin{n}); 
      if ismember(arg, {'all' 'blockaverage'})
	type = arg;
      else
	error('Wrong argument to ''type'' ')
      end
      
    else
      error(sprintf('Wrong property: %s', arg));
    end
    n = n + 1;
  end


  fid = fopen(filename);

  M.type = 'mat'; 
  M.columns = { 'time' 'lx' 'ly' 'lp' 'rx' 'ry' 'rp' 'saccade' 'blink' 'soundon' 'controlcounter' 'pushcounter' 'push' 'control'};
  M.matrix = [];

  saccade = 0;
  blink = 0;
  controlcounter = 0;
  soundon = 0; 
  pushcounter = 0;
  push = 0;
  k = 1; 
  tline = fgetl(fid);
  while ischar(tline)
    if regexp(tline, '^SSACC')
      saccade = 1;
    elseif regexp(tline, '^ESACC')
      saccade = 0;
    elseif regexp(tline, '^SBLINK')
      blink = 1;
    elseif regexp(tline, '^EBLINK')
      blink = 0;
    elseif regexp(tline, '^MSG\s+\d+\s+SOUNDON')
      soundon = 1;
    elseif soundon & regexp(tline, '^MSG\s+\d+\s+SOUNDEND') 
      soundon = 0;
    elseif regexp(tline, '^MSG\s+\d+\s+PUSHON')
      push = 1;
      pushcounter = 1;
    elseif regexp(tline, '^MSG\s+\d+\s+PUSHEND') 
      push = 0;
    elseif regexp(tline, '^MSG\s+\d+\s+CONTROLON')
      control = 1;
      controlcounter = 1;
    elseif regexp(tline, '^MSG\s+\d+\s+PUSHEND') 
      control = 0;
    else
      d = regexp(tline, '^(\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+', 'tokens');
      if ~isempty(d)
        values = str2double(d{1});
        M.matrix = [ M.matrix ; [ values saccade blink soundon controlcounter pushcounter push control] ];
        k = k + 1;
        pushcounter = 0;
        controlcounter = 0;
      end
    end
      
    tline = fgetl(fid);
  end

  fclose(fid);

      M.description = sprintf('Samples read from %s', filename);
     % Samples that are not in saccades and not in eyeblink and is within a block
      I = find(~any(M.matrix(:,7:8),2) & M.matrix(:,8)); %this returns the indices of non-saccade, non-blinks elements AND that are within the INBLOCK
      X = M.matrix(I,:);

      blockids = unique(X(:,12))';
      A.type = 'mat';
      A.columns = { 'block' 'x' 'y' };
      A.matrix = zeros(length(blockids), 3);
      for id = blockids
        A.matrix(id,:) = [ id mean(X(X(:,12)==id,2)) mean(X(X(:,13)==id,3)) ];
      end
      
      save eyedata