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
% Initializes iViewX API structures
%
% Author: SMI GmbH, 2012

%===========================
%==== Function definition
%===========================

function [pSystemInfoData, pSampleData, pEventData, pAccuracyData, Calibration] = InitiViewXAPI()


%===========================
%==== System Info
%===========================

SystemInfo.samplerate = int32(0);
SystemInfo.iV_MajorVersion = int32(0);
SystemInfo.iV_MinorVersion = int32(0);
SystemInfo.iV_Buildnumber = int32(0);
SystemInfo.API_MajorVersion = int32(0);
SystemInfo.API_MinorVersion = int32(0);
SystemInfo.API_Buildnumber = int32(0);
SystemInfo.iV_ETDevice = int32(0);
pSystemInfoData = libpointer('SystemInfoStruct', SystemInfo);


%===========================
%==== Eye data
%===========================

Eye.gazeX = double(0);
Eye.gazeY = double(0);
Eye.diam = double(0);
Eye.eyePositionX = double(0);
Eye.eyePositionY = double(0);
Eye.eyePositionZ = double(0);


%===========================
%==== Online Sample data
%===========================

Sample.timestamp = int64(0);
Sample.leftEye = Eye;
Sample.rightEye = Eye;
Sample.planeNumber = int32(0);
pSampleData = libpointer('SampleStruct', Sample);


%===========================
%==== Online Event data
%===========================

Event.eventType = int8('F');
Event.eye = int8('l');
Event.startTime = double(0);
Event.endTime = double(0);
Event.duration = double(0);
Event.positionX = double(0);
Event.positionY = double(0);
pEventData = libpointer('EventStruct', Event);


%===========================
%==== Accuracy data
%===========================

Accuracy.deviationLX = double(0);
Accuracy.deviationLY = double(0);
Accuracy.deviationRX = double(0);
Accuracy.deviationRY = double(0);
pAccuracyData = libpointer('AccuracyStruct', Accuracy);


%===========================
%==== Calibration data
%===========================

Calibration.method = int32(5);
Calibration.visualization = int32(1);
Calibration.displayDevice = int32(0);
Calibration.speed = int32(0);
Calibration.autoAccept = int32(1);
Calibration.foregroundBrightness = int32(20);
Calibration.backgroundBrightness = int32(239);
Calibration.targetShape = int32(1);
Calibration.targetSize = int32(15);
Calibration.targetFilename = int8([0:255] * 0 + 30);





