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
% Wrappers of function calls to iView Library
%
% Author: SMI GmbH, 2015


% If function is not listed, used 'calllib' function to call it 
% To list the available function use 'libfunctions iViewXAPI'  


function f = iViewXAPI  
    f.iV_Calibrate = @iV_Calibrate;
    f.iV_ClearRecordingBuffer = @iV_ClearRecordingBuffer;
    f.iV_Connect = @iV_Connect;
    f.iV_Disconnect = @iV_Disconnect;
    f.iV_GetAccuracy = @iV_GetAccuracy;
    f.iV_GetSample = @iV_GetSample;
    f.iV_GetSystemInfo = @iV_GetSystemInfo;
    f.iV_SaveData = @iV_SaveData;
    f.iV_SendImageMessage = @iV_SendImageMessage;
    f.iV_SetLogger = @iV_SetLogger;
    f.iV_SetupCalibration = @iV_SetupCalibration;
    f.iV_StartRecording = @iV_StartRecording;
    f.iV_StopRecording = @iV_StopRecording;
    f.iV_Validate = @iV_Validate;
end

function ret = iV_Calibrate()
	ret = calllib('iViewXAPI', 'iV_Calibrate');
end

function ret = iV_ClearRecordingBuffer()
    ret = calllib('iViewXAPI', 'iV_ClearRecordingBuffer');
end

function ret = iV_Connect(sendIPAddress, sendPort, recvIPAddress, receivePort)
    ret = calllib('iViewXAPI', 'iV_Connect', sendIPAddress, int32(sendPort), recvIPAddress, int32(receivePort));
end

function ret = iV_Disconnect()
    ret = calllib('iViewXAPI', 'iV_Disconnect');
end

function ret = iV_GetAccuracy(pAccuracyData, visualization)
    ret = calllib('iViewXAPI', 'iV_GetAccuracy', pAccuracyData, int32(visualization));
end

function ret = iV_GetSample(pSampleData)
    ret = calllib('iViewXAPI', 'iV_GetSample', pSampleData);
end

function ret = iV_GetSystemInfo(pSystemInfoData)
    ret = calllib('iViewXAPI', 'iV_GetSystemInfo', pSystemInfoData);
end

function ret = iV_SaveData(filename, description, user, overwrite)
     ret = calllib('iViewXAPI', 'iV_SaveData', filename, description, user, overwrite);
end

function ret = iV_SendImageMessage(etMessage)
     ret = calllib('iViewXAPI', 'iV_SendImageMessage', etMessage);
end

function ret = iV_SetLogger(logLevel,filename)
    ret = calllib('iViewXAPI', 'iV_SetLogger', int32(logLevel), filename);
end

function ret = iV_SetupCalibration(pCalibrationData) 
	ret = calllib('iViewXAPI', 'iV_SetupCalibration', pCalibrationData);
end

function ret = iV_StartRecording()
    ret = calllib('iViewXAPI', 'iV_StartRecording');
end

function ret = iV_StopRecording()
     ret = calllib('iViewXAPI', 'iV_StopRecording');
end

function ret = iV_Validate()
	ret = calllib('iViewXAPI', 'iV_Validate');
end

