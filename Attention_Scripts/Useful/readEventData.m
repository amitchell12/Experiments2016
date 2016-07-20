function [F, S, B] = readEventData(filename, varargin)
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

F.type = 'mat'; 
F.columns = { 'timestampStartF' 'timestampStopF'}; %columns of your matrix
F.matrix = [];
fCounter = 0; 

S.type = 'mat'; 
S.columns = { 'timestampStartS' 'timestampStopS' 'startX' 'startY' 'endX' 'endY'}; %columns of your matrix
S.matrix = [];
sCounter = 0; 

B.type = 'mat'; 
B.columns = { 'timestampStartB' 'timestampStopB'}; %columns of your matrix
B.matrix = [];
bCounter = 0; 

k = 1; %counter for the upcoming while loop

% % set up variables for columns
% fix = 0; 
% arrow = 0; 
% saccadeWait = 0; 

%goes through each line trying to match the start of each line with input
%to regexp function (see matlab help for more on this). 

tline = fgetl(fid);
  
while ischar(tline)
% disp(tline)

if regexp(tline, '^Fixation')
    if regexp(tline, '^Fixation L')
        d = regexp(tline, '^Fixation L\s+\d+\s+\d+\s+(\d+)\s+(\d+)', 'tokens');
        if ~isempty(d)
            values = str2double(d{1});
            fCounter = fCounter + 1;
            F.matrix(fCounter, :) = values;
        end
    else 
         d = regexp(tline, '^Fixation R\s+\d+\s+\d+\s+(\d+)\s+(\d+)', 'tokens');
         if ~isempty(d)
            values = str2double(d{1});
            fCounter = fCounter + 1;
            F.matrix(fCounter, :) = values;
        end
    end     
elseif regexp(tline, '^Saccade')
    if regexp(tline, '^Saccade L')
        d = regexp(tline, '^Saccade L\s+\d+\s+\d+\s+(\d+)\s+(\d+)\s+\d+\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)', 'tokens');
        if ~isempty(d)
            values = str2double(d{1});
            sCounter = sCounter + 1;
            S.matrix(sCounter, :) = values;
        end
    else 
          d = regexp(tline, '^Saccade R\s+\d+\s+\d+\s+(\d+)\s+(\d+)\s+\d+\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)', 'tokens');
        if ~isempty(d)
            values = str2double(d{1});
            sCounter = sCounter + 1;
            S.matrix(sCounter, :) = values;
        end
    end 
elseif regexp(tline, '^Blink') 
    if regexp(tline, '^Blink L') 
        d = regexp(tline, '^Blink L\s+\d+\s+\d+\s+(\d+)\s+(\d+)', 'tokens');
        if ~isempty(d)
            values = str2double(d{1});
            bCounter = bCounter + 1;
            B.matrix(bCounter, :) = values;
        end
    else 
          d = regexp(tline, '^Blink R\s+\d+\s+\d+\s+(\d+)\s+(\d+)', 'tokens');
        if ~isempty(d)
            values = str2double(d{1});
            bCounter = bCounter + 1;
            B.matrix(bCounter, :) = values;
        end
    end     
end    
    tline = fgetl(fid);
end 

fclose(fid);
%M.description = sprintf('Samples read from %s', filename);

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