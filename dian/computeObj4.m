
function [P_MT,F_user,Eload,P_buy] = computeObj4(x,load_e)


e_load=load_e;


%需求响应数据
Pcut=[10 10 10 10 10 10 15 15 25 100 100 100 50 50 50 50 50 50 50 50 40 40 15 10];%可削减电负荷
Temp_Pcut=binvar(1,24,'full'); % 电负荷削减标志
PPcut=sdpvar(1,24,'full');%电负荷消减量
n1=zeros(1,1);%消减连续


n2=zeros(1,1);%消减连续

Ptran=[0 0 0 0 0 0 0 0 0 0 0 0 25 25 25 25 0 0 0 0 0 0 0 0 ];%可转移电负荷
Temp_Ptran=binvar(1,24,'full'); % 可转移电负荷 转移标志
PPtran=sdpvar(1,24,'full');%电负荷转移量

Pshift1=[0 0 0 0 0 0 0 0 0 0 0 25 25 0 0 0 0 0 0 0 0 0 0 0 ];%可平移电负荷1
Temp_Pshift1=binvar(1,24,'full'); % 可平移电负荷1 平移标志
PPshift1=sdpvar(1,24,'full');%可平移电负荷1量
Pshift2=[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  25 25 25 0 0 ];%可平移电负荷2
Temp_Pshift2=binvar(1,24,'full'); % 可平移电负荷2 平移标志
PPshift2=sdpvar(1,24,'full');%可平移电负荷2量


for i=1:24
    Pfix(i)=e_load(i)-Pshift1(i)-Pshift2(i)-Ptran(i)-Pcut(i);%基础电负荷
end



%定义机组变量
% P_pv=sdpvar(1,24,'full');%光伏电输出功率
% P_wt=sdpvar(1,24,'full');%风机电输出功率
P_mt=sdpvar(1,24,'full');%燃气轮机电输出功率


Pbuy=sdpvar(1,24,'full');%从电网购电电量
% Psell=sdpvar(1,24,'full');%向电网售电电量
Pnet=sdpvar(1,24,'full');%与电网交换功率
Temp_net=binvar(1,24,'full'); % 购|售电标志

Pcharge=sdpvar(1,24,'full');%充电功率
UPcharge=binvar(1,24,'full');%充电标志  
Pdischarge=sdpvar(1,24,'full');%放电功率
UPdischarge=binvar(1,24,'full');%放电标志  
B=sdpvar(1,24,'full');%电储能余量




%储能参数
%电储能参数
E_storage_max=0.95*1000;E_storage_min=0.4*1000;e_loss=0.001;e_charge=0.9;e_discharge=0.9;%电储能容量/自损/充电/放电
%热储能参数


Constraints =[];
 %% 电储能容量约束、SOC约束、充电约束、放电约束、充放电状态约束、爬坡约束
B(1,1)=E_storage_min;%电储能初始
 for t=2:25  %在一个周期内的充放电功率
    Constraints=[Constraints,(B(mod(t-1,24)+1)==(B(mod(t-2,24)+1)*(1-e_loss)+(e_charge*Pcharge(mod(t-2,24)+1)-(1/e_discharge)*Pdischarge(mod(t-2,24)+1))))];
 end
% % %   %全周期净交换功率为零
%     Constraints=[Constraints,B(1,24)==E_storage_min];%初始功率相等即可
for i=1:24
Constraints=[Constraints,E_storage_min<=B(1,i)<=E_storage_max];%容量约束限制
end
 for i=1:24
     Constraints=[Constraints,30*UPcharge(1,i)<=Pcharge(1,i)<=200*UPcharge(1,i)];%电储能充电约束
     Constraints=[Constraints,30*UPdischarge(1,i)<=Pdischarge(1,i)<=200*UPdischarge(1,i)];%电储能放电约束
 end
 %蓄电池充放电约束
 for i=1:24
     Constraints=[Constraints,UPcharge(1,i)+UPdischarge(1,i)<=1];   %不同时充放电 
 end
   Constraints=[Constraints,sum(UPcharge(1,1:24))+sum(UPdischarge(1,1:24))==16];%使用寿命小于24

 
%% 机组约束
for i=1:24
%    Constraints = [Constraints,0<=P_pv(i)<=ppv(i)];%光伏上下限约束
%     Constraints = [Constraints,0<=P_wt(i)<=pwt(i)];%风机上下限约束
   Constraints = [Constraints,0<=P_mt(i)<=200];%燃气轮机上下限约束
 
   Constraints = [Constraints, -200<=Pnet(i)<=200,0<=Pbuy(i)<=200]; %主网功率交换约束
   Constraints = [Constraints, implies(Temp_net(i),[Pnet(i)>=0,Pbuy(i)==Pnet(i)])]; %购电情况约束
%   Constraints = [Constraints, implies(1-Temp_net(i),[Pnet(i)<=0,Psell(i)==Pnet(i),Pbuy(i)==0])]; %售电情况约束 
end 
 
%% 需求响应约束
%% 可平移电负荷1量
    Constraints= [Constraints,sum(Temp_Pshift1(1,1:24)) == 2,sum(Temp_Pshift1(1,5:21)) == 2];%可平移电负荷1 平移标志
    for i=5:20 %时段区间为5~21-2+1
   Constraints = [Constraints,sum(Temp_Pshift1(1,i:i+1)) >= 2*(Temp_Pshift1(1,i)-Temp_Pshift1(1,i-1))];%连续2个时段
    end
    for i=1:24
       Constraints = [Constraints,PPshift1(1,i)== 25*Temp_Pshift1(1,i)];%可平移电负荷1量
    end
%% 可平移电负荷2量
        Constraints = [Constraints,sum(Temp_Pshift2(1,1:24)) == 3,sum(Temp_Pshift2(1,7:23)) == 3];%可平移电负荷2 平移标志
    for i=7:21 %时段区间为7~23-3+1
    Constraints = [Constraints,sum(Temp_Pshift2(1,i:i+2)) >= 3*(Temp_Pshift2(1,i)-Temp_Pshift2(1,i-1)-Temp_Pshift2(1,i-2))];%连续3个时段
    end
       for i=1:24
       Constraints = [Constraints,PPshift2(1,i)== 25*Temp_Pshift2(1,i)];%可平移电负荷2量
       end
 

  %% 可转移电负荷(大于5自然会大于2)
  for i=1:24
      Constraints = [Constraints,Temp_Ptran(i)*8<=PPtran(i)<=Temp_Ptran(i)*26.7 ];%可转移电负荷
  end
      Constraints = [Constraints,sum(Temp_Ptran(1,1:24)) == 5,sum(Temp_Ptran(1,4:22)) ==5];%可转移电负荷
            Constraints = [Constraints,sum(Temp_Ptran(1,1:24)) ==5];%可转移电负荷
    for i=4:18 %时段区间为4~22-5+1
    Constraints = [Constraints,sum(Temp_Ptran(1,i:i+4)) >= 5*(Temp_Ptran(1,i)-Temp_Ptran(1,i-1))];
    end


%% 可削减电负荷

Constraints=[Constraints,sum(Temp_Pcut)==8,sum(Temp_Pcut(1,5:22))==8];
Constraints=[Constraints,2<=n1<=5];
    for i=5:22-n1+1 %时段区间为5~22-n1+1
    Constraints = [Constraints,sum(Temp_Pcut(1,i:i+n1-1)) >= n1*(Temp_Pcut(1,i)-Temp_Pcut(1,i-1))];
    end
for i=1:24
       Constraints = [Constraints,0<=PPcut(1,i)<=Temp_Pcut(1,i)*0.9*Pcut(i)];%可消减电负荷
end
%% 平衡
   for i=1:24       
   Constraints = [Constraints,P_mt(i)+Pnet(i)-Pcharge(1,i)+Pdischarge(1,i)==Pfix(i)+Pcut(i)+PPshift1(i)+PPshift2(i)+PPtran(i)-PPcut(i)]; %电平衡约束
  
   end
      
%% 目标函数
%% 从购电成本
C_gridbuy=0;
for i=1:24
    C_gridbuy=C_gridbuy+x(i).*Pbuy(i);
end
% %% 向大电网的售电成本
% C_gridsell=0;
% for i=1:24
%     C_gridsell=C_gridsell+Psell(i)*sell_price(i);
% end
%运行成本
% C_OM=0;
% for i=1:24
%  C_OM=C_OM+0.72*P_pv(i)+0.52*P_wt(i);%风机光伏运维成本
% end

%% 燃料成本
C_fuel=0;
for i=1:24
 C_fuel=C_fuel+x(i).*P_mt(i);%耗气成本
end
%% 储能运行成本
C_storge=0;
for i=1:24
 C_storge=C_storge+0.5*(Pcharge(i)+Pdischarge(i));%储能运行成本
end

%% 补偿成本
C_L=0;
for i=1:24
    C_L=C_L+0.2*(PPshift1(i)+PPshift2(i))+0.3*PPtran(i)+0.4*PPcut(i);
end



F= C_fuel+C_gridbuy+C_storge+C_L;
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
op_e_load(i)=Pfix(i)+Pcut(i)+PPshift1(i)+PPshift2(i)+PPtran(i)-PPcut(i);
end
% end
F_user=value(F);%成本
% P_pv=value(P_pv);
% P_wt=value(P_wt);
P_MT=value(P_mt);
Pcharge=value(Pcharge);
Pdischarge=value(Pdischarge);
P_buy=value(Pbuy);
% Psell=value(Psell);
PPshift1=value(PPshift1);
PPshift2=value(PPshift2);
PPtran=value(PPtran);
PPcut=value(PPcut);
Eload=value(op_e_load);

%% 画图

% figure
% ee=value([Pfix;Pcut;Pshift1;Pshift2;Ptran]);
% bar(ee',1,'stack')
% hold on
% plot(Pfix+Pcut+Pshift1+Pshift2+Ptran,'g-*','linewidth',2)
% hold on 
% plot(Pfix,'y-*','linewidth',2)
% xlabel('时间/h');
% ylabel('电负荷功率/kW');
% legend('基础电负荷','可消减电负荷','可平移电负荷1','可平移电负荷2','可转移电负荷','等效负荷','固定负荷');
% title('优化前用户侧柔性电负荷分布');
% 
% 
% 
% 
% for i=1:24
%     op_e_load(i)=Pfix(i)+Pcut(i)+PPshift1(i)+PPshift2(i)+PPtran(i)-PPcut(i);
% end
% x=1:24;
% 
% % figure
% % bar(e_load-op_e_load,'b');
% % hold on
% % xlabel('时间/h');
% % ylabel('电负荷/kW');
% % yyaxis right
% % plot(buy_price,'r--*','linewidth',2);
% % xlabel('时间/h');
% % ylabel('电价');
% % title('需求响应前后电负荷曲线');
% % legend('响应电负荷','市场电价');
% 
% figure
% plot(e_load,'r-');
% hold on
% plot(op_e_load,'g-*','linewidth',2);
% xlabel('时间/h');
% ylabel('电负荷/kW');
% title('需求响应前后电负荷曲线');
% legend('优化前电负荷','优化后电负荷');
end