

function [P_GB,F_user,Hload,H_buy] = computeObj4(x,load_h)

h_load =load_h;
%读取数据 
%电负荷、热负荷、光伏、风机、购电价、售电价
n1=zeros(1,1);%消减连续
Hcut=[25 25 25 25 25 25 25 25 30 35 35 35 35 35 35 35 35 35 35 35 30 30 20 15];%可削减热负荷
Temp_Hcut=binvar(1,24,'full'); % 热负荷削减标志
HHcut=sdpvar(1,24,'full');%热负荷消减量
n2=zeros(1,1);%消减连续


Hshift=[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 15 15 15 0 0 0 0 ];%可平移热负荷
Temp_Hshift=binvar(1,24,'full'); % 可平移热负荷 平移标志
HHshift=sdpvar(1,24,'full');%可平移热负荷量


for i=1:24
    Hfix(i)=h_load(i)-Hshift(i)-Hcut(i);%基础热负荷
end


%定义机组变量

P_mt=sdpvar(1,24,'full');%燃气轮机电输出功率
P_GB=sdpvar(1,24,'full');%燃气锅炉输出热功率


Hbuy=sdpvar(1,24,'full');%从电网购电电量
%Psell=sdpvar(1,24,'full');%向电网售电电量
Hnet=sdpvar(1,24,'full');%与电网交换功率
Temp_net=binvar(1,24,'full'); % 购|售电标志


Hcharge=sdpvar(1,24,'full');%储热系统充热
Hdischarge=sdpvar(1,24,'full');%储热系统放热
UHcharge=binvar(1,24,'full'); %储热系统充热标志
UHdischarge=binvar(1,24,'full'); %储热系统放热标志
H=sdpvar(1,24,'full'); %热储能余量


%储能参数

%热储能参数
H_storage_max=0.95*1000;H_storage_min=0.4*1000;h_loss=0.001;h_charge=0.9;h_discharge=0.9;%热储能容量//自损/充热/放热
%约束条件
Constraints =[];

 

 %% 热储能容量约束、SOC约束、充热约束、放热约束、充放热状态约束
H(1,1)=H_storage_min;%热储能初始
 for t=2:25  %在一个周期内的充放热功率
    Constraints=[Constraints,(H(mod(t-1,24)+1)==(H(mod(t-2,24)+1)*(1-h_loss)+(h_charge*Hcharge(mod(t-2,24)+1)-(1/h_discharge)*Hdischarge(mod(t-2,24)+1))))];
 end
% %  %全周期净交换功率为零
%    Constraints=[Constraints,H(1,24)==H_storage_min];%初始功率相等即可
for i=1:24
Constraints=[Constraints,H_storage_min<=H(1,i)<=H_storage_max];%容量约束限制
end
 for i=1:24
     Constraints=[Constraints,50*UHcharge(1,i)<=Hcharge(1,i)<=200*UHcharge(1,i)];%热储能充电约束
     Constraints=[Constraints,50*UHdischarge(1,i)<=Hdischarge(1,i)<=200*UHdischarge(1,i)];%热储能放电约束
 end
 %蓄热池充放电约束
 for i=1:24
     Constraints=[Constraints,UHcharge(1,i)+UHdischarge(1,i)<=1];   %不同时充放热 
 end
   Constraints=[Constraints,sum(UHcharge(1,1:24))+sum(UHdischarge(1,1:24))==24];%使用寿命小于24

%% 机组约束
for i=1:24
   
   Constraints = [Constraints,0<=P_mt(i)<=200];%燃气轮机上下限约束
   Constraints = [Constraints,0<=P_GB(i)<=160];%燃气锅炉上下限约束
   Constraints = [Constraints, -200<=Hnet(i)<=200,0<=Hbuy(i)<=200,]; %主网功率交换约束
   Constraints = [Constraints, implies(Temp_net(i),[Hnet(i)>=0,Hbuy(i)==Hnet(i)])]; %购电情况约束
 %  Constraints = [Constraints, implies(1-Temp_net(i),[Pnet(i)<=0,Psell(i)==Pnet(i),Pbuy(i)==0])]; %售电情况约束 
end 
 
%% 需求响应约束

%% 可平移热负荷量
        Constraints = [Constraints,sum(Temp_Hshift(1,1:24)) == 3,sum(Temp_Hshift(1,5:21)) == 3];%可平移热负荷 平移标志

    for i=5:19%时段区间为5~21-3+1
    Constraints = [Constraints,sum(Temp_Hshift(1,i:i+2)) >= 3*(Temp_Hshift(1,i)-Temp_Hshift(1,i-1))];%连续3个时段
    end
    for i=1:24
       Constraints = [Constraints,HHshift(1,i)== 15*Temp_Hshift(1,i)];%可平移电负荷2量
    end 
    
  



%% 可削减热负荷
Constraints=[Constraints,sum(Temp_Hcut(1,1:24))==8,sum(Temp_Hcut(1,11:19))==8];
Constraints=[Constraints,2<=n2<=5];
    for i=11:19-n2+1 %时段区间为11~19-n2+1
    Constraints = [Constraints,sum(Temp_Hcut(1,i:i+n1-1)) >= n1*(Temp_Hcut(1,i)-Temp_Hcut(1,i-1))];
    end
for i=1:24
       Constraints = [Constraints,Temp_Hcut(1,i)*0<=HHcut(1,i)<=Temp_Hcut(1,i)*0.9*Hcut(i)];%可消减热负荷
end
%% 电平衡
   for i=1:24       
  
   Constraints = [Constraints,P_GB(i)+Hbuy(i)-Hcharge(1,i)+Hdischarge(1,i)==Hfix(i)+Hcut(i)+HHshift(i)-HHcut(i)]; %热平衡约束
   end
      
%% 目标函数

%% 燃料成本
C_fuel=0;
for i=1:24
 C_fuel=C_fuel+x(i).*P_GB(i);%耗气成本
end
%% 储能运行成本
C_storge=0;
for i=1:24
 C_storge=C_storge+0.5*(Hcharge(i)+Hdischarge(i));%储能运行成本
end

%% 补偿成本
C_L=0;
for i=1:24
    C_L=C_L+0.2*HHshift(i)+0.4*HHcut(i);
end

%%热网
for i=1:24
C_Hridbuy=0;

    C_Hridbuy=C_Hridbuy+x(i).*Hbuy(i);

end

F= C_Hridbuy+C_fuel+C_storge+C_L;

ops = sdpsettings('solver','cplex', 'verbose', 2);%参数指定程序用cplex求解器
optimize(Constraints,F,ops)
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
for i=1:24
    op_h_load(i)=Hfix(i)+Hcut(i)+HHshift(i)-HHcut(i);
end
F_user=value(F);%成本

%P_mt=value(P_mt);
P_GB=value(P_GB);
H_buy=value(Hbuy);
Hcharge=value(Hcharge);
Hdischarge=value(Hdischarge);

HHshift=value(HHshift);
HHcut=value(HHcut);
Hload= value(op_h_load);
%% 画图


% figure
% hh=value([Hfix;Hcut;Hshift]);
% bar(hh',1,'stack');
% hold on
% plot(Hfix+Hcut+Hshift,'c-*','linewidth',2)
% hold on 
% plot(Hfix,'y-*','linewidth',2)
% legend('基础热负荷','可消减热负荷','可平移热负荷','等效热负荷','基础热负荷');
% xlabel('时间/h');
% ylabel('热负荷功率/kW');
% title('优化前用户侧柔性热负荷分布');
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% x=1:24;
% figure
% bar(h_load,'r');
% hold on
% plot(op_h_load,'g-*','linewidth',2);
% xlabel('时间/h');
% ylabel('热负荷/kW');
% title('需求响应前后热负荷曲线');
% legend('优化前热负荷','优化后热负荷');
% 
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
% b=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
% hhh=value([P_GB;Hdischarge;-Hcharge;Hbuy]);
% figure
% bar(hhh','stack');
% hold on
% plot(x,op_h_load,'-rs');
% legend('燃气锅炉产热','热储能放热','热储能充热','买热','热负荷需求');
% title('热负荷平衡');
% xlabel('时段');ylabel('功率/kW');
% 
% 
% for i=1:24
%     HHHcut(i)=Hcut(i)-HHcut(i); %所剩的可消减热负荷
% end
% figure
% hh=value([Hfix;HHHcut;HHshift]);
% bar(hh','stack');
% legend('基础热负荷','可消减热负荷','可平移热负荷');
% xlabel('时间/h');
% ylabel('热负荷功率/kW');
% title('优化后用户侧柔性热负荷分布');
