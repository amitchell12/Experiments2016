function fix = checkFixationSMI(mx,my,fixationWindow)
        % determine if gx and gy are within fixation window
        fix = mx > fixationWindow(1) &  mx <  fixationWindow(3) & ...
            my > fixationWindow(2) & my < fixationWindow(4);
end
