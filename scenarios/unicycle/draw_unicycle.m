%% draw_unicycle.m
% *Summary:* Draw the unicycle with cost and applied torques
%
%    function draw_unicycle(latent, plant,t2,cost,text1, text2)
%
%
% *Input arguments:*
%
%		latent     state of the unicycle (including the torques)
%   plant      plant structure
%     .dt      sampling time
%     .dyno    state indices that are passed ont the cost function
%   t2         supersampling frequency (in case you want smoother plots)
%   cost       cost structure
%     .fcn     function handle (it is assumed to use saturating cost)
%     .<>      other fields that are passed to cost
%   text1      (optional) text field 1
%   text2      (optional) text field 2
%
%
% Copyright (C) 2008-2013 by
% Marc Deisenroth, Andrew McHutchon, Joe Hall, and Carl Edward Rasmussen.
%
% Last modified: 2013-04-04

function draw_unicycle(latent,plant,t2,cost,text1, text2)
%% Code

clf; set(gca,'FontSize',16);

t1 = plant.dt;

rw =  0.225; % wheel radius
rf =  0.54;  % frame center of mass to wheel
rt =  0.27;  % frame centre of mass to turntable
rr =  rf+rt;  % distance wheel to turntable

M = 24; MM = 2*pi*(0:M)/M;
RR = ['r-';'r-';'r-';'k-';'b-';'b-';'b-'];
ii = 10000;


qq = latent;

clear q;
xi = t1*(0:size(qq,1)-1); xn = 0:t2:(size(qq,1)-1)*t1;
for i = 1:size(qq,2), q(:,i) = interp1(xi,qq(:,i),xn); end

for i=1:size(q,1)
  x     = q(i,10);
  y     = q(i,11);
  theta = q(i,14);
  phi   = q(i,15);
  psiw  = -q(i,16);
  psif  = q(i,17);
  psit  = q(i,18);
  
  A = [  cos(phi)             sin(phi)              0
    -sin(phi)*cos(theta)  cos(phi)*cos(theta)  -sin(theta)
    -sin(phi)*sin(theta)  cos(phi)*sin(theta)   cos(theta) ]';
  
  r = rw*[cos(psiw+MM); zeros(1,M+1); sin(psiw+MM)+1];
  R{1} = bsxfun(@plus,A*r,[x; y; 0]);
  r = rw*[cos(psiw) -cos(psiw); 0 0; sin(psiw)+1 -sin(psiw)+1];
  R{2} = bsxfun(@plus,A*r,[x; y; 0]);
  r = rw*[sin(psiw) -sin(psiw); 0 0; -cos(psiw)+1 cos(psiw)+1];
  R{3} = bsxfun(@plus,A*r,[x; y; 0]);
  r = [0 rr*sin(psif); 0 0; rw rw+rr*cos(psif)];
  R{4} = bsxfun(@plus,A*r,[x; y; 0]);
  r = [rr*sin(psif)+rw*cos(psif)*cos(psit+MM); rw*sin(psit+MM); rw+rr*cos(psif)-rw*sin(psif)*cos(psit+MM)];
  R{5} = bsxfun(@plus,A*r,[x; y; 0]);
  r = [rr*sin(psif)+rw*cos(psif)*cos(psit) rr*sin(psif)-rw* ...
    cos(psif)*cos(psit); rw*sin(psit) -rw*sin(psit); rw+rr* ...
    cos(psif)-rw*sin(psif)*cos(psit) rw+rr*cos(psif)+rw* ...
    sin(psif)*cos(psit)];
  R{6} = bsxfun(@plus,A*r,[x; y; 0]);
  r = [rr*sin(psif)+rw*cos(psif)*sin(psit) rr*sin(psif)-rw* ...
    cos(psif)*sin(psit); -rw*cos(psit) rw*cos(psit); rw+rr* ...
    cos(psif)-rw*sin(psif)*sin(psit) rw+rr*cos(psif)+rw* ...
    sin(psif)*sin(psit)];
  R{7} = bsxfun(@plus,A*r,[x; y; 0]);
  hold off
  aa = linspace(0,2*pi,201); plot3(2*sin(aa),2*cos(aa),0*aa,'k:','LineWidth',2);
  hold on
  
  r = A*[0; 0; rw] + [x; y; 0];
  P = [r R{1}(:,1:M/4+1) r]; fill3(P(1,:),P(2,:),P(3,:),'r','EdgeColor','none');
  P = [r R{1}(:,M/2+1:3*M/4+1) r]; fill3(P(1,:),P(2,:),P(3,:),'r','EdgeColor','none');
  
  r = A*[rr*sin(psif); 0; rw+rr*cos(psif) ] + [x; y; 0];
  P = [r R{5}(:,1:M/4+1) r]; fill3(P(1,:),P(2,:),P(3,:),'b','EdgeColor','none');
  P = [r R{5}(:,M/2+1:3*M/4+1) r]; fill3(P(1,:),P(2,:),P(3,:),'b','EdgeColor','none');
  
  for j = [1 4 5];
    plot3(R{j}(1,:),R{j}(2,:),R{j}(3,:),RR(j,:),'LineWidth',2)
  end
  axis equal; axis([-2 2 -2 2 0 1.5]);
  xlabel 'x [m]';
  ylabel 'y [m]';
  grid on
  
  % draw controls:
  ut  = q(i,end-1);
  uw  = q(i,end);
  L = cost.fcn(cost,q(i,plant.dyno)',zeros(length(plant.dyno)));
  
  utM = 10;
  uwM = 50;
  
  oo = [4 -3.07 0]/6.4; o1 = [-0.5 2 2.0]; o2 = [-0.5 2 1.6]; o3 = [-0.5 2 1.2];
  o0 = 1.5*ut/utM;
  plot3([o1(1) o1(1)+o0*oo(1)],[o1(2) o1(2)+o0*oo(2)],[o1(3) o1(3)+o0*oo(3)],'b','LineWidth',5)
  plot3([o1(1)-1.5*oo(1) o1(1)+1.5*oo(1) o1(1)+1.5*oo(1) o1(1)-1.5*oo(1) o1(1)-1.5*oo(1)],...
    [o1(2)-1.5*oo(2) o1(2)+1.5*oo(2) o1(2)+1.5*oo(2) o1(2)-1.5*oo(2) o1(2)-1.5*oo(2)],...
    [o1(3)+0.04 o1(3)+0.04 o1(3)-0.04 o1(3)-0.04 o1(3)+0.04], 'b');
  plot3([-0.5 -0.5],[2 2],o1(3)+[-0.06 0.06],'b');
  o0 = 1.5*uw/uwM;
  plot3([o2(1) o2(1)+o0*oo(1)],[o2(2) o2(2)+o0*oo(2)],[o2(3) o2(3)+o0*oo(3)],'r','LineWidth',5)
  plot3([o2(1)-1.5*oo(1) o2(1)+1.5*oo(1) o2(1)+1.5*oo(1) o2(1)-1.5*oo(1) o2(1)-1.5*oo(1)],...
    [o2(2)-1.5*oo(2) o2(2)+1.5*oo(2) o2(2)+1.5*oo(2) o2(2)-1.5*oo(2) o2(2)-1.5*oo(2)],...
    [o2(3)+0.04 o2(3)+0.04 o2(3)-0.04 o2(3)-0.04 o2(3)+0.04], 'r');
  plot3([-0.5 -0.5],[2 2],o2(3)+[-0.06 0.06],'r');
  
  o0 = 3*L-1.5;
  plot3([o3(1)-1.5*oo(1) o3(1)+o0*oo(1)],[o3(2)-1.5*oo(2) o3(2)+o0*oo(2)],[o3(3)-1.5*oo(3) o3(3)+o0*oo(3)],'k','LineWidth',5)
  plot3([o3(1)-1.5*oo(1) o3(1)+1.5*oo(1) o3(1)+1.5*oo(1) o3(1)-1.5*oo(1) o3(1)-1.5*oo(1)],...
    [o3(2)-1.5*oo(2) o3(2)+1.5*oo(2) o3(2)+1.5*oo(2) o3(2)-1.5*oo(2) o3(2)-1.5*oo(2)],...
    [o3(3)+0.04 o3(3)+0.04 o3(3)-0.04 o3(3)-0.04 o3(3)+0.04], 'k');
  
  
  text(-0.5-1.5*oo(1), 2-1.5*oo(2), 2.2,'Disc torque    max \pm 10 Nm','Color','b');
  text(-0.5-1.5*oo(1), 2-1.5*oo(2), 1.8,'Wheel torque max \pm 50 Nm','Color','r');
  text(-0.5-1.5*oo(1), 2-1.5*oo(2), 1.4,'Instantaneous Cost','Color','k');
  
  
  if nargin > 4
    text(2,1,1.8,text1);
    text(2,1,1.4,text2);
  end
  
  
  drawnow
%   pause(plant.dt/2);
end

