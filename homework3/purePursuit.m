function [gamma, error] = purePursuit(q, L, Ld, path)

% Find nearest path point

% Converts path to robot coordinate frame
rTr = transl2(q(1),q(2))*trot2(q(3)); %Transformation from robot to world
rTr = inv(rTr); %Inverse is transformation from world to robot frame
path(:,3)=1; %Algebrae trick to allow the multiplication of matrices
robotFrame = rTr*path'; %Final path in robot frame coordinates

%Find the number of points in Path
Points_number = length(path);

%Find index of point on path to calculate ey
err = inf; row_goal = 0;
di = zeros(1,Points_number);
distance = zeros(1,Points_number);

for i = 1:1:Points_number
    % path's x and y in robot frame
    dx = robotFrame(1,i); dy = robotFrame(2,i); 

    %find distance of robot(0,0)to points in path (in robot frame)
    di(i) = sqrt(dx^2+dy^2);
    distance(i) = abs(di(i) - Ld); %idea is to find a waypoint such that
    %the distance from this waypoint to the robot = lookAhead
    dmin = min(di(di>0)); %Selects point that minimizes (di-Ld)
    
    if (dx > 0) && (di(i) < Ld) && (distance(i) <= err) %Check if point is in front of robot
        row_goal = i; % this index represents the look ahead point
    end
    err = distance(i);
end

%if no points is in front of robot, move to the closest point
if row_goal == 0 
    ey = dmin;
else 
    ey = robotFrame(2,row_goal);
end
gamma = atan(2*ey*L/Ld^2);

%cross track error, return the tracking error
error = dmin;


