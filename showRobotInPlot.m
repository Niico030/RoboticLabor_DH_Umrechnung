function Robot = showRobotInPlot(tetha_i, d_i, a_i, alpha_i)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    for i = 1:length(a_i)
        L(i) = Link([tetha_i(i), d_i(i), a_i(i), alpha_i(i)]);
    end
    
    Robot = SerialLink(L, 'name', 'Roboter Hausuebung SS21');
    
    % Plot des Roboters
    Robot.plot(zeros(1,length(a_i)));
end

