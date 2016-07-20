% Unload iViewX API library 

% disconnect from iViewX 
disp('Disconnect')
ret_discon  = iView.iV_Disconnect();
if (ret_discon ~= 1)
    disp('Device could not be disconnected')
end


pause(1);
clear

% unload iViewX API library
unloadlibrary('iViewXAPI');
