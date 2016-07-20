function [M, X, A] = readEyeData(filename, varargin)
%% INSTRUCTIONS
%This is an adaptation of a file brede_read_edf that was used to convert an
%eyelink edf (asc) file into a matrix in Matlab for analysis

%I adjusted the inputs to regexp to work with the SMI's idf file layout 
%B_Innes 

%% ORIGINAL FILE INSTRUCTIONS 
% brede_read_edf       - Read Eyelink EDF file
%
%       Input:    filename  Filename for the EDF file
%
%       Output:   M and A         'mat' structure
%
%       M -  all data lines will be returned with columns
%       indicating whether the line is within a saccade, blink and 
%       'LEDON' block: AS WELL AS THE T point within each LEDON
%
%       X - only the non blink, non saccade, in block rows
%
%       A-  will compute the average within each 
%       'LEDON' block exluding lines with saccade or blink.       
%
%       Example: 
%         M = brede_read_edf('eyelink.edf') 
%       See also BREDE, BREDE_READ.
% $Id: brede_read_edf.m,v 1.2 2010/10/12 09:24:03 fn Exp $
%% UNUSED? 

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

%% OPEN THE FILE 
fid = fopen(filename); %specify the file (should be a converted idf in txt format) 
M.type = 'mat'; 
M.columns = { 'time' 'type' 'trial' 'lx' 'ly' 'rx' 'ry' 'fix' 'arrow' 'saccadeWait' 'trialNo'}; %columns of your matrix
M.matrix = [];

k = 1; %counter for the upcoming while loop

% set up variables for columns
fix = 0; 
arrow = 0; 
saccadeWait = 0; 
trialNo = 0; 
saccadeDirectionOn = 0;
fixationTimestampSMI = 0; 
%goes through each line trying to match the start of each line with input
%to regexp function (see matlab help for more on this). 

tline = fgetl(fid);
  
while ischar(tline)
%disp(tline)
    if regexp(tline, '^\d+\s+MSG\s+\d+\s+\# Message: fixationStart') %all SMI messages will look something like this
        fix = 1;
        fixationTimestampSMI = 1; 
        trialNo = trialNo+1; 
    elseif regexp(tline, '^\d+\s+MSG\s+\d+\s+\# Message: fixationStop')
        fix = 0;
    elseif regexp(tline, '^\d+\s+MSG\s+\d+\s+\# Message: arrowStart')
        arrow = 1;
        saccadeDirectionOn = 1; 
    elseif regexp(tline, '^\d+\s+MSG\s+\d+\s+\# Message: arrowStop')
        arrow = 0;
    elseif regexp(tline, '^\d+\s+MSG\s+\d+\s+\# Message: saccadeWaitStart')
        saccadeWait = 1;
        %saccadeTargetOn = 1; 
    elseif regexp(tline, '^\d+\s+MSG\s+\d+\s+\# Message: saccadeWaitStop')
        saccadeWait = 0;
    else
        d = regexp(tline, '^(\d+)\s+\w+\s+(\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+', 'tokens');
        if ~isempty(d)
            values = str2double(d{1});
            M.matrix = [ M.matrix ; [values fix arrow saccadeWait trialNo saccadeDirectionOn fixationTimestampSMI]];
            k = k + 1;
            saccadeDirectionOn = 0;
            fixationTimestampSMI = 0; 
        end
    end
%     fix = 0; 
%     arrow = 0; 
%     saccadeWait = 0; 
    tline = fgetl(fid);
end 

fclose(fid);
M.description = sprintf('Samples read from %s', filename);

% TO DEAL WITH SACCADES, SMI DETECTS EVENTS AND OUTPUTS TO SEPARATE FILE
% NEED TO MATCH TIMESTAMPS 

  
%        I = find(~any(M.matrix(:,5:6),2) & M.matrix(:,7)); %this returns the indices of non-saccade, non-blinks elements AND that are within the INBLOCK
%       X = M.matrix(I,:);
% 
%       blockids = unique(X(:,8))';
%       A.type = 'mat';
%       A.columns = { 'block' 'x' 'y' };
%       A.matrix = zeros(length(blockids), 3);
%       for id = blockids
%         A.matrix(id,:) = [ id mean(X(X(:,8)==id,2)) mean(X(X(:,8)==id,3)) ];
%       end
%      