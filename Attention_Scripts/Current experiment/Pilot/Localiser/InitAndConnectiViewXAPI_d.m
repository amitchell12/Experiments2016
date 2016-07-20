% -----------------------------------------------------------------------
%
% (c) Copyright 1997-2013, SensoMotoric Instruments GmbH
%
% Permission  is  hereby granted,  free  of  charge,  to any  person  or
% organization  obtaining  a  copy  of  the  software  and  accompanying
% documentation  covered  by  this  license  (the  "Software")  to  use,
% reproduce,  display, distribute, execute,  and transmit  the Software,
% and  to  prepare derivative  works  of  the  Software, and  to  permit
% third-parties to whom the Software  is furnished to do so, all subject
% to the following:
%
% The  copyright notices  in  the Software  and  this entire  statement,
% including the above license  grant, this restriction and the following
% disclaimer, must be  included in all copies of  the Software, in whole
% or  in part, and  all derivative  works of  the Software,  unless such
% copies   or   derivative   works   are   solely   in   the   form   of
% machine-executable  object   code  generated  by   a  source  language
% processor.
%
% THE  SOFTWARE IS  PROVIDED  "AS  IS", WITHOUT  WARRANTY  OF ANY  KIND,
% EXPRESS OR  IMPLIED, INCLUDING  BUT NOT LIMITED  TO THE  WARRANTIES OF
% MERCHANTABILITY,   FITNESS  FOR  A   PARTICULAR  PURPOSE,   TITLE  AND
% NON-INFRINGEMENT. IN  NO EVENT SHALL  THE COPYRIGHT HOLDERS  OR ANYONE
% DISTRIBUTING  THE  SOFTWARE  BE   LIABLE  FOR  ANY  DAMAGES  OR  OTHER
% LIABILITY, WHETHER  IN CONTRACT, TORT OR OTHERWISE,  ARISING FROM, OUT
% OF OR IN CONNECTION WITH THE  SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.
%
% -----------------------------------------------------------------------
%
%
% Load the iViewX API library and connect to the server
%
% Author: SMI GmbH, 2015

% Initializate Library
loadlibrary('iViewXAPI.dll', @iViewXAPIHeader);
connected = 0;

if libisloaded('iViewXAPI')
    
    
    disp('iViewXAPI.dll loaded')
    
    [pSystemInfoData, pSampleData, pEventData, pAccuracyData, CalibrationData] = InitiViewXAPI();
    
    CalibrationData.method = int32(5);
    CalibrationData.visualization = int32(1);
    CalibrationData.displayDevice = int32(0);
    CalibrationData.speed = int32(0);
    CalibrationData.autoAccept = int32(1);
    CalibrationData.foregroundBrightness = int32(250);
    CalibrationData.backgroundBrightness = int32(230);
    CalibrationData.targetShape = int32(2);
    CalibrationData.targetSize = int32(20);
    CalibrationData.targetFilename = int8('');
    pCalibrationData = libpointer('CalibrationStruct', CalibrationData);
    
    %Create structure with function wrappers
    iView = iViewXAPI;
    
    %Create logger file
    disp('Define Logger')
    ret_log= iView.iV_SetLogger(int32(1), 'iViewXSDK_Matlab_Demo_log.txt');
    
    if (ret_log ~= 1)
        disp('Logger could not be opened')
    end
    
    %Connect to server
    disp('Connecting to iViewX')
    ret_con = iView.iV_Connect('192.168.1.1', int32(4444), '192.168.1.2', int32(5555));
    
    switch ret_con
        case 1
            connected = 1;
            disp('Connection was successful')
        case 104
            msgbox('Could not establish connection. Check if Eye Tracker is running', 'Connection Error', 'modal');
        case 105
            msgbox('Could not establish connection. Check the communication Ports', 'Connection Error', 'modal');
        case 123
            msgbox('Could not establish connection. Another Process is blocking the communication Ports', 'Connection Error', 'modal');
        case 200
            msgbox('Could not establish connection. Check if Eye Tracker is installed and running', 'Connection Error', 'modal');
        otherwise
            msgbox('Could not establish connection', 'Connection Error', 'modal');
    end
    
else
    disp('iViewXAPI.dll was NOT loaded')
end
