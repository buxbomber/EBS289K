%% Homework #4
close all; clear all; clc;

%% Constant definitions
global N W RL n dT DT Rmin sensitivity previous stop;
previous = 1;
stop = 1;
sensitivity = 20;
N = 10; %number of rows
W = 2.5; %m, row width
RL = 20; %row length m
wi = 2.5; %Tractor width [m]
%r = 0.5; %Tractor wheel radius [m]
L = 3; % Wheel base [m]
tractor = draw_tractor(wi,L); % draw a vehicle element
gamma_max = 60*pi/180; %radians
Rmin = L/tan(gamma_max); %Tractor turning radius [m]
dT = 0.001; DT =  0.1; %% mode integration step & controller integratin step [s]
s = 0.0; %Slip [%]
tal_v = 0; tal_gamma = 0; %Controller delay times [s]
delta1 = 0*pi/180; delta2 = 0*pi/180; %Skid factors [%]
v_max = 1;
constraints = [gamma_max, v_max]; %Constraints (negative part is built in
%the bycicle model function)
error = zeros(1,max(length(path),length(0:DT:300-DT))); %error tracking
%% Path planning
xy = Nodes(N,W,RL,2);

DMAT = costMatrix(N,W,xy);

t = cputime;
resultStruct = tspof_ga('XY',xy,'DMAT',DMAT,'SHOWRESULT',false,'SHOWWAITBAR',false,'SHOWPROG',false);
E = cputime-t;
coordinates = [1 resultStruct.optRoute 2*N+2];
resultStruct.minDist;

path = pathGen(coordinates,xy);
%% Navigation
clc;
x = path(1,1);
y = path(2,1);
theta = atan2(path(2,2)-y,path(1,2)-x); % Start theta looking at the next
% waypoint
q = [x,y,theta,1,0]; %Current state [x,y,theta,velocity,gamma] [m,m,radians,m/s,radians]
Ld = 2; %Look ahead distance [m]
u = [theta, v_max]'; %Desired state [radians] / [m/s]
n = 1;
tolerance = 0.4;

for i = 0:DT:400-DT
    [u(1),error(n)]  = purePursuitController(q,L,Ld,path'); %Update gamma based on purePursuitController
    q = bycicle_model(u,q,dT,DT,L,s,tal_v,tal_gamma,delta1,delta2,constraints);
    hold on;
    %plot(path(1,:),path(2,:),'yo');
    move_robot(q(1),q(2),q(3),tractor,path,1);
    p = 100*previous/length(path);
    fprintf('Simulation %.2f %% complete\n',p);
    if previous == length(path) && abs(stop) < tolerance
        break   % stop if navigating to last path point and position close
        clc;
    end
end

%% ERROR PLOTS
n = n-1;
error = error(1:n);
figure();
plot(1:n,error(1:n));
xlabel('Steps');
ylabel('Error [m]');
mean_error = mean(error(1:n));
x1 = 1; x2 = length(error);
x_mean = [x1 x2];
y_mean = [mean_error mean_error];
hold on;
plot(x_mean,y_mean,'r-');
legend('Error [m]','Mean error [m]');
max_error = max(error(1:n));
percentile_error = prctile(error(1:n),95);
rmse_error = rms(error(1:n));
fprintf('The maximum error is %.3f m\n', max_error);
fprintf('The 95th percentile error is %.3f m\n', percentile_error);
fprintf('The RMSE of error is %.3f m\n', rmse_error);