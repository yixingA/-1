

clc;clear;close all;
%读取数据 

Sw = 10;

h_load=[135	140 150 135 140 120 115 100 115 115 160 180 190 170 140 130 145 100 220 230 160 160 180 120]*3;%基础热负荷

[m1] = user(h_load); 
for w = 1:Sw
    M1(:,w)=m1(:,w);
    
%    pload_uncertainty(w, :) = pload_base .* (1 + 0.05 * randn(1, T)); % 在基准负荷基础上加入随机波动
end
h_load=M1';




buy_price=repmat([0.20	0.20 0.20 0.20 0.20 0.20 0.25 0.25 0.3 0.3 0.3 0.28 0.28 0.32 0.32 0.32 0.32 0.35 0.35 0.35 0.35 0.35 0.22 0.22],Sw,1);%购热价
sell_price=repmat([0.18 0.18 0.18 0.18 0.18 0.18 0.22 0.22 0.27 0.27 0.27 0.25 0.25 0.25 0.25 0.25 0.25 0.3 0.3 0.3 0.3 0.3 0.2 0.2],Sw,1);%售热价
%需求响应数据
%n1=zeros(Sw,1);%消减连续
Hcut=repmat([25 25 25 25 25 25 25 25 30 40 40 40 40 40 40 40 40 40 50 50 30 30 20 15],Sw,1);%可削减热负荷
Temp_Hcut=binvar(Sw,24,'full'); % 热负荷削减标志
HHcut=sdpvar(Sw,24,'full');%热负荷消减量
n2=zeros(Sw,1);%消减连续


Hshift=repmat([0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 45 45 45 0 0 0 ],Sw,1);%可平移热负荷
Temp_Hshift=binvar(Sw,24,'full'); % 可平移热负荷 平移标志
HHshift=sdpvar(Sw,24,'full');%可平移热负荷量

for w=1:Sw
for i=1:24
    Hfix(w,i)=h_load(w,i)-Hshift(w,i)-Hcut(w,i);%基础热负荷
end
end

%定义机组变量

%P_mt=sdpvar(Sw,24,'full');%燃气轮机热输出功率
h_G3=0.68;%燃气轮机热效率
P_GB=sdpvar(Sw,24,'full');%燃气锅炉输出热功率
%P_EH=sdpvar(Sw,24,'full');%余热锅炉输出热功率
%EH=0.6;%余热回收效率
Hbuy=sdpvar(Sw,24,'full');%从热网购热量
Hsell=sdpvar(Sw,24,'full');%向热网售热量
Hnet=sdpvar(Sw,24,'full');%与电网交换功率
Temp_net=binvar(Sw,24,'full'); % 购|售热标志


Hcharge=sdpvar(Sw,24,'full');%储热系统充热
Hdischarge=sdpvar(Sw,24,'full');%储热系统放热
UHcharge=binvar(Sw,24,'full'); %储热系统充热标志
UHdischarge=binvar(Sw,24,'full'); %储热系统放热标志
H=sdpvar(Sw,24,'full'); %热储能余量

%CVAR参数
zk=sdpvar(Sw,1);
var=sdpvar(1,1);%VAR的值

%pai = [0.3,0.2,0.3,0.1,0.1]; % 场景权重
%pai = [0.3 0.2 0.5 ]; % 场景权重
pai =ones(1,10)*0.1;%场景权重
obj_single = 0;
L = 0.9; % 风险系数

%储能参数

%热储能参数
H_storage_max=0.95*1500;
H_storage_min=0.4*1500;
h_loss=0.001;
h_charge=0.9;
h_discharge=0.9;%热储能容量//自损/充热/放热

%% 约束条件
Constraints =[];

 

 %% 热储能容量约束、充热约束、放热约束、充放热状态约束
 for w=1:Sw
H(w,1)=H_storage_min;%热储能初始
 for t=2:25  %在一个周期内的充放热功率
    Constraints=[Constraints,(H(w,mod(t-1,24)+1)==(H(w,mod(t-2,24)+1)*(1-h_loss)+(h_charge*Hcharge(w,mod(t-2,24)+1)-(1/h_discharge)*Hdischarge(w,mod(t-2,24)+1))))];
 end
% %  %全周期净交换功率为零
%    Constraints=[Constraints,H(1,24)==H_storage_min];%初始功率相等即可
for i=1:24
Constraints=[Constraints,H_storage_min<=H(w,i)<=H_storage_max];%容量约束限制
end
 for i=1:24
     Constraints=[Constraints,50*UHcharge(w,i)<=Hcharge(w,i)<=500*UHcharge(w,i)];%热储能充热约束
     Constraints=[Constraints,50*UHdischarge(w,i)<=Hdischarge(w,i)<=500*UHdischarge(w,i)];%热储能放热约束
 end
 %蓄热池充放热约束
 for i=1:24
     Constraints=[Constraints,UHcharge(w,i)+UHdischarge(w,i)<=1];   %不同时充放热 
 end
 Constraints=[Constraints,sum(UHcharge(w,1:24))+sum(UHdischarge(w,1:24))==16];%使用寿命小于24
 end 
%% 机组约束
for w=1:Sw
for i=1:24
   
  % Constraints = [Constraints,0<=H_mt(w,i)<=80];%燃气轮机产热上下限
   Constraints = [Constraints,0<=P_GB(w,i)<=800];%燃气锅炉上下限约束
   Constraints = [Constraints, -80<=Hnet(w,i)<=80,0<=Hbuy(w,i)<=80, -80<=Hsell(w,i)<=0]; %热网功率交换约束
   Constraints = [Constraints, implies(Temp_net(w,i),[Hnet(w,i)>=0,Hbuy(w,i)==Hnet(w,i),Hsell(w,i)==0])]; %购热情况约束
   Constraints = [Constraints, implies(1-Temp_net(w,i),[Hnet(w,i)<=0,Hsell(w,i)==Hnet(w,i),Hbuy(w,i)==0])]; %售热情况约束 
end 
end
%% 需求响应约束

%% 可平移热负荷1量
for w=1:Sw
        Constraints = [Constraints,sum(Temp_Hshift(w,1:24)) == 3,sum(Temp_Hshift(w,5:21)) == 3];%可平移热负荷 平移标志

    for i=5:19%时段区间为5~21-3+1
    Constraints = [Constraints,sum(Temp_Hshift(w,i:i+2)) >= 3*(Temp_Hshift(w,i)-Temp_Hshift(w,i-1)-Temp_Hshift(w,i-2))];%连续3个时段
    end
    for i=1:24
       Constraints = [Constraints,HHshift(w,i)==45*Temp_Hshift(w,i)];%可平移热负荷量
    end 
    
  
end


%% 可削减热负荷
for w=1:Sw
Constraints=[Constraints,sum(Temp_Hcut(w,1:24))==8,sum(Temp_Hcut(w,8:19))==8];
Constraints=[Constraints,2<=n2<=5];
    for i=8:19-n2+1 %时段区间为11~19-n2+1
    Constraints = [Constraints,sum(Temp_Hcut(w,i:i+n2-1)) >= n2*(Temp_Hcut(w,i)-Temp_Hcut(w,i-1))];
    end
for i=1:24
       Constraints = [Constraints,HHcut(w,i)==Temp_Hcut(w,i)*0.9*Hcut(w,i)];%可消减热负荷
end
end
%% 热平衡
for w=1:Sw
   for i=1:24       
  
   Constraints = [Constraints,P_GB(w,i)+Hnet(w,i)-Hcharge(w,i)+Hdischarge(w,i)==Hfix(w,i)+Hcut(w,i)+HHshift(w,i)-HHcut(w,i)]; %热平衡约束
   end
end     
%% 目标函数
%燃料成本
C_fuel=0;
for w=1:Sw
for i=1:24
 C_fuel=C_fuel+0.1*P_GB(w,i)/9.7;%耗气成本
end
end
%储能运行成本
C_storge=0;
for w=1:Sw
for i=1:24
 C_storge=C_storge+0.02*(Hcharge(w,i)+Hdischarge(w,i));%储能运行成本
end
end
%补偿成本
C_L=0;
for w=1:Sw
for i=1:24
    C_L=C_L+0.3*HHshift(w,i)+0.5*HHcut(w,i);
end
end
%热交换成本
for w=1:Sw
C_Hridbuy=0;

    C_Hridbuy=C_Hridbuy+Hbuy(w,:)*buy_price(w,:)';

end


for w=1:Sw
C_Hridsell=0;

    C_Hridsell=C_Hridsell+Hsell(w,:)*sell_price(w,:)';

end




F= C_Hridbuy-C_Hridsell+sum(C_fuel+C_storge+C_L);
%% CVAR约束
 for w = 1:Sw

    Constraints = [Constraints,
                   zk(w) >= (F) - var
                   zk(w) >= 0
                   ];
          
    
 end
%%  成本最优
for w = 1:Sw

%obj_single = obj_single +pai(w)*(sum(price(w,:).*(LLC(w,:)+LLS(w,:)))-sum(CLC(w,:))-sum(CLS(w,:))-kcp*pmt(w,:)');
obj_single = obj_single +pai(w)*(F);

end

obj_single =  obj_single + L* (var+pai * zk /(1 - 0.95));

ops = sdpsettings('solver','cplex', 'verbose', 2);%参数指定程序用cplex求解器
optimize(Constraints,obj_single,ops)

% ops=sdpsettings('solver','cplex');%设置求解方式
% [model,recoveryalmip,diagnostic,internalmodel]=export(Constraints,F,ops);%转为cplex模型
% milpt=Cplex('milp for htc');
% milpt.Model.sense='minimize';
% milpt.Model.obj=model.f;
% milpt.Model.lb=model.lb;
% milpt.Model.ub=model.ub;
% milpt.Model.A=[model.Aineq;model.Aeq];
% milpt.Model.lhs=[-inf*ones(size(model.bineq,1),1);model.beq];
% milpt.Model.rhs=[model.bineq;model.beq];
% milpt.Model.ctype=model.ctype;
% milpt.writeModel('ab.lp');%输出cplex模型（注意大小写）
% milpt.solve();%模型求解

obj_single=value(obj_single)%成本

%P_mt=value(P_mt);
P_GB=value(P_GB);

Hcharge=value(Hcharge);
Hdischarge=value(Hdischarge);

HHshift=value(HHshift);
HHcut=value(HHcut);
zk=value(zk);
cvar=value((1-L)*(var+pai*zk/(1-0.95)))


%% 画图

% figure
% plot(h_load(1,:));
% hold on
% plot(h_load(2,:));
% hold on
% plot(h_load(3,:));
% hold on


for w = 1
figure
hh=value([Hfix(w,:);Hcut(w,:);Hshift(w,:)]);
bar(hh',1,'stacked');
hold on
% plot(Hfix(w,:)+Hcut(w,:)+Hshift(w,:),'c-*','linewidth',2)
% hold on 
% plot(Hfix(w,:),'y-*','linewidth',2)
legend('基础热负荷','可消减热负荷','可平移热负荷');
xlabel('时间/h');
ylabel('热负荷功率/kW');
title('优化前用户侧柔性热负荷分布');
end
% 
% 
% 
% 
% 
% 
% 
% 
% 
for w = 1:Sw
for i=1:24
    op_h_load(w,i)=Hfix(w,i)+Hcut(w,i)+HHshift(w,i)-HHcut(w,i);
end
end
x=1:24;
% figure
% bar(h_load(w,:),'r');
% hold on
% plot(op_h_load(w,:),'g-*','linewidth',2);
% xlabel('时间/h');
% ylabel('热负荷/kW');
% title('需求响应前后热负荷曲线');
% legend('优化前热负荷','优化后热负荷');
% end
% % figure
% % bar(h_load-op_h_load,'r');
% % hold on
% % xlabel('时间/h');
% % ylabel('热负荷/kW');
% % yyaxis right
% % plot(buy_price,'g--*','linewidth',2);
% % xlabel('时间/h');
% % ylabel('电价');
% % title('需求响应前后热负荷曲线');
% % legend('响应热负荷','市场电价');
% 
% 
% 
% 
for w=1
yyaxis left
hhh=value([Hbuy(w,:);Hsell(w,:);P_GB(w,:);Hdischarge(w,:);-Hcharge(w,:);]);

figure

bar(hhh','stacked');
hold on
plot(x,h_load(w,:),'-b*');
hold on
plot(x,op_h_load(w,:),'-rs');
hold on
ylabel('功率/kW');
yyaxis right
plot(buy_price(w,:),'g--*','linewidth',2);
hold on
ylabel('热价');
legend('买热功率','卖热功率','燃气锅炉产热','储能放热','储能充热','原热负荷需求','优化后热负荷需求','热价');

title('其他管理资源出力');
xlabel('时间/h');
end
% 
for i=1:24
    HHHcut(w,i)=Hcut(w,i)-HHcut(w,i); %所剩的可消减热负荷
end
figure
hh=value([Hfix(w,:);HHHcut(w,:);HHshift(w,:)]);
bar(hh','stack');
legend('基础热负荷','可消减热负荷','可平移热负荷');
xlabel('时间/h');
ylabel('热负荷功率/kW');
title('优化后用户侧柔性热负荷分布');
