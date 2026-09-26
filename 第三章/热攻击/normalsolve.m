function [ym,Pc,Cost_total,Price_Charge]=normalsolve(num_LA)
global N1
global N2
global N3
global Zc
n1=N1(num_LA);
n2=N2(num_LA);
n3=N3(num_LA);
% k1=0.0001;
%price_day_ahead=[3.5;3.3;3;3.3;3.6;4;4.4;4.6;5.2;5.8;6.6;7.5;8.1;7.6;8;8.3;8.1;7.5;6.4;5.5;5.3;4.7;4;3.7];
price_day_ahead=[0.35;0.33;0.3;0.33;0.36;0.4;0.44;0.46;0.52;0.58;0.66;0.75;0.81;0.76;0.8;0.83;0.81;0.75;0.64;0.55;0.53;0.47;0.40;0.37];
% pt=0.6*sdpvar(24,1);
PL=[1600;1800;2100;2300;2400;2700;2800;2900;3400;3500;3700;3400;3200;2900;2600;2400;2700;2900;3400;3200;2700;2229;1900;2000]*3;
%PL=[1733.66666666000;1857.50000000000;2105.16666657000;2352.83333343000;2476.66666657000;2724.33333343000;2848.16666657000;2972;3219.66666657000;3467.33333343000;3591.16666657000;3715.00000000000;3467.33333343000;3219.66666657000;2972;2600.50000000000;2476.66666657000;2724.33333343000;2972;3467.33333343000;3219.66666657000;2724.33333343000;2229;1981.33333343000]*3;
% Qideal=PL+(N1+N2+N3)*X/24;

a=0.003*PL/mean(PL);
b=0.0025/mean(PL)*ones(24,1);

% price_s=1.2*price_day_ahead;
lb=0.8*price_day_ahead;
ub=1.2*price_day_ahead;
T_1=[1;1;1;1;1;1;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;1;1];
T_2=[1;1;1;1;1;1;1;1;0;0;0;0;1;1;1;0;0;0;0;1;1;1;1;1];
T_3=[0;0;0;0;0;0;0;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;0;0];
Ce=sdpvar(24,1);%电价
M=1000000;
Pdis=ones(24,1);
% z=binvar(24,1);%购售电状态
Ps_day=sdpvar(24,1);%实时售电量
Pc1=sdpvar(24,1);%一类用电功率
Pc2=sdpvar(24,1);%二类用电功率
Pc3=sdpvar(24,1);%三类用电功率
%C=[lb<=Ce<=ub,mean(Ce)==0.5,Ps_day<=M*Pdis,Ps_day>=0];%边界约束
C=[lb<=Ce<=ub,mean(Ce)==0.5,Ps_day<=M*Pdis,Ps_day>=0];
%,pt==0.6*price_day_ahead-k1*abs(PL+(n1+n2+n3)*X/24-Ps_day)
C=[C,Pc1+Pc2+Pc3==Ps_day];%能量平衡
L_u=sdpvar(1,3);%电量需求等式约束的拉格朗日函数
L_lb=sdpvar(24,3);%充电功率下限约束的拉格朗日函数
L_ub=sdpvar(24,3);%充电功率上限约束的拉格朗日函数
L_T=sdpvar(24,3);%充电可用时间约束的拉格朗日函数
% f=n1*L_u(1)*(Zc)+n2*L_u(2)*(Zc)+n3*L_u(3)*(Zc)+sum(sum(L_ub).*[n1*3,n2*3,n3*3])-sum(a.*Ps_day+b.*Ps_day.^2);%目标函数
% C=[C,Ce-L_u(1)*ones(24,1)-L_lb(:,1)-L_ub(:,1)-L_T(:,1)==0,Ce-L_u(2)*ones(24,1)-L_lb(:,2)-L_ub(:,2)-L_T(:,2)==0,Ce-L_u(3)*ones(24,1)-L_lb(:,3)-L_ub(:,3)-L_T(:,3)==0];%KKT条件
% C=[C,sum(Pc1)==n1*(Zc),sum(Pc2)==n2*(Zc),sum(Pc3)==n3*(Zc)];%电量需求约束
f=n1*L_u(1)*(Zc)+n2*L_u(2)*(Zc)+n3*L_u(3)*(Zc)+sum(sum(L_ub).*[n1*3,n2*3,n3*3])-sum(a.*Ps_day+b.*Ps_day.^2);%目标函数
C=[C,Ce-L_u(1)*ones(24,1)-L_lb(:,1)-L_ub(:,1)-L_T(:,1)==0,Ce-L_u(2)*ones(24,1)-L_lb(:,2)-L_ub(:,2)-L_T(:,2)==0,Ce-L_u(3)*ones(24,1)-L_lb(:,3)-L_ub(:,3)-L_T(:,3)==0];%KKT条件
C=[C,sum(Pc1)==n1*(Zc),sum(Pc2)==n2*(Zc),sum(Pc3)==n3*(Zc)];%电量需求约束
for t=1:24
    if T_1(t)==0
        C=[C,Pc1(t)==0];
    else
        C=[C,L_T(t,1)==0];
    end
    if T_2(t)==0
        C=[C,Pc2(t)==0];
    else
        C=[C,L_T(t,2)==0];
    end
    if T_3(t)==0
        C=[C,Pc3(t)==0];
    else
        C=[C,L_T(t,3)==0];
    end
end
b_lb=binvar(24,3);%用电功率下限约束的松弛变量
b_ub=binvar(24,3);%用电功率上限约束的松弛变量

for t=1:24
    if T_1(t)==0
        C=[C,L_ub(t,1)==0,b_ub(t,1)==1,b_lb(t,1)==1];
    else
        C=[C,L_lb(t,1)>=0,L_lb(t,1)<=M*b_lb(t,1),Pc1(t)>=0,Pc1(t)<=M*(1-b_lb(t,1)),Pc1(t)<=n1*3,n1*3-Pc1(t)<=M*b_ub(t,1),L_ub(t,1)<=0,L_ub(t,1)>=M*(b_ub(t,1)-1)];
    end
    if T_2(t)==0
        C=[C,L_ub(t,2)==0,b_ub(t,2)==1,b_lb(t,2)==1];
    else
        C=[C,L_lb(t,2)>=0,L_lb(t,2)<=M*b_lb(t,2),Pc2(t)>=0,Pc2(t)<=M*(1-b_lb(t,2)),Pc2(t)<=n2*3,n2*3-Pc2(t)<=M*b_ub(t,2),L_ub(t,2)<=0,L_ub(t,2)>=M*(b_ub(t,2)-1)];
    end
    if T_3(t)==0
        C=[C,L_ub(t,3)==0,b_ub(t,3)==1,b_lb(t,3)==1];
    else
        C=[C,L_lb(t,3)>=0,L_lb(t,3)<=M*b_lb(t,3),Pc3(t)>=0,Pc3(t)<=M*(1-b_lb(t,3)),Pc3(t)<=n3*3,n3*3-Pc3(t)<=M*b_ub(t,3),L_ub(t,3)<=0,L_ub(t,3)>=M*(b_ub(t,3)-1)];
    end
end
ops=sdpsettings('solver','cplex');
solvesdp(C,-f,ops);
Pc=[double(Pc1),double(Pc2),double(Pc3)];
Ps_day=double(Ps_day);
% S=double(S);
Cost_total=double(f);
Price_Charge=double(Ce);
clear ans b_lb b_ub C Ce f L_lb L_ub L_T L_u lb M ops Pc1 Pc2 Pc3 price_b price_day_ahead price_s t T_1 T_2 T_3 u ub z
% plot(PL);
% plot(PL+(N1+N2+N3)*X/24)
% hold on
% plot(PL+Ps_day,'r');
% Pc1=double(Pc1);
% Pc2=double(Pc2);
% Pc3=double(Pc3);

ym=Ps_day+PL;