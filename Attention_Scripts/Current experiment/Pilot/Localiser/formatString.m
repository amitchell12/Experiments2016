% 
% formatString.m
%
% Description: 
% Due to the fact the iView X API functions are expecting a char array with a specific length it 
% is needed to format the char arrays before handing them over to the iView X API functions. The 
% formatString function will format the string which will be handed over to iView X API functions. 
% 
% input parameter: 
% StringLength - String length which is expected by the iView X API. See the iView X SDK manual for further information. 
% UnformattedString - The string which should be hand over to iView X API function 
% 
% output / return: 
% FormattedString - The string which will be hand over to iView X API function 
% 
% Author: SMI GmbH
% June, 2012

function [ FormattedString ] = formatString( StringLength, UnformattedString )

    UnformattedStringLength = length(UnformattedString);
    zero = 1:StringLength - UnformattedStringLength;
    zero(:) = 0;

    FormattedString = [UnformattedString int8(zero)];

    
    