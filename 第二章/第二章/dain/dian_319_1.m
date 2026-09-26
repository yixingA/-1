
clc;clear;close all;
%读取数据 
Sw = 10;

%电负荷、热负荷、光伏、风机、购电价、售电价
e_load=repmat([160	150	140	140	130	135	150	180	215	250	275	320	335	290	260	275	270	280	320	360	345	310	220	160]*3,Sw,1);%电负荷
buy_price=repmat([0.25	0.25 0.25 0.25 0.25 0.25 0.25 0.53 0.53 0.53 0.82 0.82 0.82 0.82 0.82 0.53 0.53 0.53 0.82 0.82 0.82 0.53 0.53 0.53],Sw,1);%购电价
sell_price=repmat([0.22 0.22 0.22 0.22 0.22 0.22 0.22 0.42 0.42 0.42 0.65 0.65 0.65 0.65 0.65 0.42 0.42 0.42 0.65 0.65 0.65 0.42 0.42 0.42],Sw,1);%售电价

%% 光伏风机生成

%wf1=[160 165  270 275 280 185 190 200 225 250 230 310 100 120 125 130 140 160 180 200 175 160 155 150];%风机预测数据
%wf2=[0 0 0	0 0	10 15 25 45 75 90 100 80 100 50  40 30 15 10 0 0 0 0 0  ];%光伏预测数据


%wf1=[339,287,449,471,512,530,527,641,634,519,401,634,589,530,512,505,206,85,81,80,83,110,353,523];%风基础数据
wf1=[339,287,449,471,412,430,427,541,534,419,401,434,489,430,412,505,206,85,81,80,83,110,353,523];%风基础数据
wf2=[0,0,0,0,0,0,99,137,150,178,189,191,176,171,138,104,77,0,0,0,0,0,0,0]*3;%光基础数据


    [m1,m2] = WTC(wf1,wf2); % 考虑风光不确定性
    
for w = 1:Sw
    M1(:,w)=m1(:,w);
     M2(:,w)=m2(:,w);
%    pload_uncertainty(w, :) = pload_base .* (1 + 0.05 * randn(1, T)); % 在基准负荷基础上加入随机波动

end

pwt=M1';
ppv=M2';

% pwt=[341.5811706	284.2212291	446.4401253	482.0549917	514.3556522	538.2162248	534.2962411	628.2094189	619.2653992	522.4477794	414.9734633	627.3358069	600.8752505	521.6323491	504.5147956	487.3197847	206.3400358	86.95958051	82.39077502	84.40992412	86.69973066	102.1460702	358.2878374	522.1070696;
% 335.7064845	279.3448602	446.0642998	469.8976656	505.5271016	537.2074762	540.4104165	644.9347013	631.2791971	513.0927854	399.6402626	636.1670616	566.2280216	514.4058262	506.295559	517.2771986	216.7414127	78.35466472	81.00764176	83.92160261	73.56746132	107.448516	345.6844194	527.2856847;
% 349.3991862	287.4093496	442.1257031	477.6357595	510.0723192	527.5481275	525.9789526	643.7735872	662.272009	514.7742258	402.4743719	632.0731856	581.0340265	528.9668061	493.1602984	480.0981976	207.2909577	86.49712521	72.34768854	87.53828658	81.43094219	115.3036252	356.7923451	524.8490219;
% ];
% 
% ppv=[0	0	0	0	0	0	94.06871767	141.1896249	148.5736378	176.0129162	182.9622384	202.3526851	172.2408161	180.8657118	140.3360059	95.62797853	75.41158697	0	0	0	0	0	0	0;
% 0	0	0	0	0	0	88.16306177	135.7334021	145.5178091	194.8822848	193.32574	191.527566	175.7552636	172.9280687	136.0527982	100.7049283	78.68828744	0	0	0	0	0	0	0;
% 0	0	0	0	0	0	100.8880664	137.6451851	148.4228496	170.4406792	179.1011681	202.9160833	176.1014749	159.4388855	152.1232634	120.5321957	79.99763346	0	0	0	0	0	0	0;
% ];




%% 需求响应数据
Pcut=repmat([10 10 10 10 10 40 40 40 40 50 50 50 50 50 50 50 50 50 50 50 40 80 15 10],Sw,1);%可削减电负荷
Temp_Pcut=binvar(Sw,24,'full'); % 电负荷削减标志
PPcut=sdpvar(Sw,24,'full');%电负荷消减量
n1=zeros(Sw,1);%消减连续


Ptran=repmat([0 0 0 0 0 0 0 0 0 0 0 0 25 25 25 25 0 0 0 0 0 0 0 0]*2,Sw,1);%可转移电负荷
Temp_Ptran=binvar(Sw,24,'full'); % 可转移电负荷 转移标志
PPtran=sdpvar(Sw,24,'full');%电负荷转移量

Pshift1=repmat([0 0 0 0 0 0 0 0 0 0 0 20 20 0 0 0 0 0 0 0 0 0 0 0 ]*5,Sw,1);%可平移电负荷1
Temp_Pshift1=binvar(Sw,24,'full'); % 可平移电负荷1 平移标志
PPshift1=sdpvar(Sw,24,'full');%可平移电负荷1量
Pshift2=repmat([0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 20  20 20 0 0 0]*5,Sw,1);%可平移电负荷2
Temp_Pshift2=binvar(Sw,24,'full'); % 可平移电负荷2 平移标志
PPshift2=sdpvar(Sw,24,'full');%可平移电负荷2量

for w=1:Sw
  for i=1:24
    Pfix(w,i)=e_load(w,i)-Pshift1(w,i)-Pshift2(w,i)-Ptran(w,i)-Pcut(w,i);%基础电负荷
  end
end


%% 机组变量
P_pv=sdpvar(Sw,24,'full');%光伏电输出功率
P_wt=sdpvar(Sw,24,'full');%风机电输出功率
P_mt=sdpvar(Sw,24,'full');%燃气轮机电输出功率


Pbuy=sdpvar(Sw,24,'full');%从运营商购电电量
Psell=sdpvar(Sw,24,'full');%向电网售电电量
Pnet=sdpvar(Sw,24,'full');%与电网交换功率
Temp_net=binvar(Sw,24,'full'); % 购|售电标志

Pcharge=sdpvar(Sw,24,'full');%充电功率
UPcharge=binvar(Sw,24,'full');%充电标志  
Pdischarge=sdpvar(Sw,24,'full');%放电功率
UPdischarge=binvar(Sw,24,'full');%放电标志  
B=sdpvar(Sw,24,'full');%电储能余量




%储能参数
%电储能参数
E_storage_max=0.95*1000;
E_storage_min=0.4*1000;
e_loss=0.001;e_charge=0.9;
e_discharge=0.9;%电储能容量/自损/充电/放电


%% CVAR参数
zk=sdpvar(Sw,1);
var=sdpvar(1,1);%VAR的值

%pai = [0.4,0.2,0.2,0.1,0.1]; % 场景权重
%pai = [0.3,0.2,0.3,0.1,0.1]; % 场景权重
%pai = [0.2 0.7 0.1]; % 场景权重
pai = ones(1,10)*0.1;% 场景权重
%pai = ones(1,20)*0.05;
obj_single = 0;
L = 0.1; % 风险系数
Constraints =[];

 %% 电储能容量约束、SOC约束、充电约束、放电约束、充放电状态约束、爬坡约束
 for w=1:Sw
B(w,1)=E_storage_min;%电储能初始
 for t=2:25  %在一个周期内的充放电功率
    Constraints=[Constraints,(B(w,mod(t-1,24)+1)==(B(w,mod(t-2,24)+1)*(1-e_loss)+(e_charge*Pcharge(w,mod(t-2,24)+1)-(1/e_discharge)*Pdischarge(w,mod(t-2,24)+1))))];
 end
% % %   %全周期净交换功率为零
%     Constraints=[Constraints,B(1,24)==E_storage_min];%初始功率相等即可
for i=1:24
Constraints=[Constraints,E_storage_min<=B(w,i)<=E_storage_max];%容量约束限制
end
 for i=1:24
     Constraints=[Constraints,30*UPcharge(w,i)<=Pcharge(w,i)<=100*UPcharge(w,i)];%电储能充电约束
     Constraints=[Constraints,30*UPdischarge(w,i)<=Pdischarge(w,i)<=100*UPdischarge(w,i)];%电储能放电约束
 end
 %蓄电池充放电约束
 for i=1:24
     Constraints=[Constraints,UPcharge(w,i)+UPdischarge(w,i)<=1];   %不同时充放电 
 end
   Constraints=[Constraints,sum(UPcharge(w,1:24))+sum(UPdischarge(w,1:24))==24];%使用寿命小于24
 end
 
%% 机组约束
for w=1:Sw
  for i=1:24
%    Constraints = [Constraints,0<=P_pv(w,i)<=ppv(w,i)];%光伏上下限约束
%     Constraints = [Constraints,0<=P_wt(w,i)<=pwt(w,i)];%风机上下限约束
       Constraints = [Constraints,P_pv(w,i)==ppv(w,i)];%光伏上下限约束
       Constraints = [Constraints,P_wt(w,i)==pwt(w,i)];%风机上下限约束
   Constraints = [Constraints,0<=P_mt(w,i)<=700];%燃气轮机上下限约束（800）
 
   Constraints = [Constraints, -100<=Pnet(w,i)<100, 0<=Pbuy(w,i)<=100, -100<=Psell(w,i)<=0]; %主网功率交换约束
   Constraints = [Constraints, implies(Temp_net(w,i),[Pnet(w,i)>=0,Pbuy(w,i)==Pnet(w,i),Psell(w,i)==0])]; %购电情况约束
  Constraints = [Constraints, implies(1-Temp_net(w,i),[Pnet(w,i)<=0,Psell(w,i)==Pnet(w,i),Pbuy(w,i)==0])]; %售电情况约束 
  end 
end
%% 需求响应约束
%% 可平移电负荷1量
for w=1:Sw
    Constraints= [Constraints,sum(Temp_Pshift1(w,1:24)) ==2,sum(Temp_Pshift1(w,5:22)) == 2];%可平移电负荷1 平移标志
    for i=5:21 %时段区间为5~22-2+1
   Constraints = [Constraints,sum(Temp_Pshift1(w,i:i+1)) >= 2*(Temp_Pshift1(w,i)-Temp_Pshift1(w,i-1))];%连续2个时段
    end
    for i=1:24
       Constraints = [Constraints,PPshift1(w,i)== 5*20*Temp_Pshift1(w,i)];%可平移电负荷1量
    end
end
%% 可平移电负荷2量
for w=1:Sw
        Constraints = [Constraints,sum(Temp_Pshift2(w,1:24)) == 3,sum(Temp_Pshift2(w,7:23)) ==3];%可平移电负荷2 平移标志
    for i=7:21 %时段区间为7~13-3+1
    Constraints = [Constraints,sum(Temp_Pshift2(w,i:i+2)) >= 3*(Temp_Pshift2(w,i)-Temp_Pshift2(w,i-1)-Temp_Pshift2(w,i-2))];%连续3个时段
    end
       for i=1:24
       Constraints = [Constraints,PPshift2(w,i)==5*20*Temp_Pshift2(w,i)];%可平移电负荷2量
       end
end
  %% 可转移电负荷(大于5自然会大于2)
for w=1:Sw
  for i=1:24
      Constraints = [Constraints,Temp_Ptran(w,i)*10<=PPtran(w,i)<=Temp_Ptran(w,i)*50];%可转移电负荷约束
  end
      Constraints = [Constraints,sum(Temp_Ptran(w,1:24)) == 4,sum(Temp_Ptran(w,4:22)) ==4];%可转移电负荷总数
           
    for i=4:18 %时段区间为4~22-5+1
    Constraints = [Constraints,sum(Temp_Ptran(w,i:i+4)) >= 4*(Temp_Ptran(w,i)-Temp_Ptran(w,i-1))];
    end
end
%% 可削减电负荷
for w=1:Sw
Constraints=[Constraints,sum(Temp_Pcut(w,:))==7,sum(Temp_Pcut(w,3:22))==7];
%Constraints=[Constraints,sum(Temp_Pcut(w,:))==3];
Constraints=[Constraints,2<=n1<=7];
    for i=3:22-n1+1 %时段区间为5~22-n1+1
    Constraints = [Constraints,sum(Temp_Pcut(w,i:i+n1-1)) >= n1*(Temp_Pcut(w,i)-Temp_Pcut(w,i-1))];
    end
for i=1:24
       Constraints = [Constraints,PPcut(w,i)==Temp_Pcut(w,i)*0.8*Pcut(w,i)];%可消减电负荷
      % Constraints = [Constraints,0<=PPcut(w,i)<=Temp_Pcut(w,i)*0.9*Pcut(w,i)];
end
end
%% 平衡
for w=1:Sw
   for i=1:24       
   Constraints = [Constraints,P_mt(w,i)+P_pv(w,i)+P_wt(w,i)+Pnet(w,i)-Pcharge(w,i)+Pdischarge(w,i)==Pfix(w,i)+Pcut(w,i)+PPshift1(w,i)+PPshift2(w,i)+PPtran(w,i)-PPcut(w,i)]; %电平衡约束
 %Constraints = [Constraints,P_pv(w,i)+P_wt(w,i)+Pnet(w,i)-Pcharge(w,i)+Pdischarge(w,i)==Pfix(w,i)+Pcut(w,i)+PPshift1(w,i)+PPshift2(w,i)+PPtran(w,i)-PPcut(w,i)]; 
   end
end    

%% 目标函数
%电网的交互成本
for w=1:Sw
C_gridbuy=0;

    C_gridbuy=C_gridbuy+Pbuy(w,:)*buy_price(w,:)';

end

C_gridsell=0;
for w=1:Sw

    C_gridsell=C_gridsell+Psell(w,:)*sell_price(w,:)';


%运行成本
C_OM=0;

 %C_OM=C_OM+0.72*P_pv(w,:)+0.52*P_wt(w,:);%风机光伏运维成本
C_OM=C_OM+0.7*P_pv(w,:)+0.5*P_wt(w,:);%风机光伏运维
end

%MT燃料成本
C_fuel=0;
for w=1:Sw

%  C_fuel=C_fuel+2.5*P_mt(w,:)/0.35/9.7;%耗气成本151
C_fuel=C_fuel+0.6*P_mt(w,:)/0.45/9.7;%耗气成本

end

%储能运行成本
C_storge=0;
for w=1:Sw

 C_storge=C_storge+0.02*(Pcharge(w,:)+Pdischarge(w,:));%储能运行成本end
end

%补偿成本
C_L=0;
for w=1:Sw
    C_L=C_L+0.2*(PPshift1(w,:)+PPshift2(w,:))+0.3*PPtran(w,:)+0.5*PPcut(w,:);


F= C_gridbuy-C_gridsell+sum(C_OM)+sum(C_fuel)+sum(C_storge)+sum(C_L);
%F= C_gridbuy-C_gridsell+sum(C_OM+C_storge+C_L);

 end
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

obj_single = obj_single + L* (var+pai * zk /(1-0.95));

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
P_pv=value(P_pv);
P_wt=value(P_wt);
P_mt=value(P_mt);
Pcharge=value(Pcharge);
Pdischarge=value(Pdischarge);
Pbuy=value(Pbuy);
Psell=value(Psell);
PPshift1=value(PPshift1);
cvar=value((1-L)*(var+pai*zk/(1-0.95)))
PPshift2=value(PPshift2);
PPtran=value(PPtran);
PPcut=value(PPcut);



%% 画图

% figure
% plot(pwt(1,:),'-')
% hold on
% plot(pwt(2,:),'-')
% hold on
% plot(pwt(3,:),'-')
% hold on
% plot(pwt(4,:),'-')
% hold on
% plot(pwt(5,:),'-')
% hold on
% l2=xlabel('t/h');
% set(l2,'Fontname', 'Times New Roman','FontSize',15)
% l3=ylabel('P/kW');
% set(l3,'Fontname', 'Times New Roman','FontSize',15)
% set(gca,'FontName','Times New Roman','FontSize',15)
% 
% 
% figure
% plot(ppv(1,:),'-')
% hold on
% plot(ppv(2,:),'-')
% hold on
% plot(ppv(3,:),'-')
% hold on
% plot(ppv(4,:),'-')
% hold on
% plot(ppv(5,:),'-')
% hold on
% l2=xlabel('t/h');
% set(l2,'Fontname', 'Times New Roman','FontSize',15)
% l3=ylabel('P/kW');
% set(l3,'Fontname', 'Times New Roman','FontSize',15)
% set(gca,'FontName','Times New Roman','FontSize',15)

%% 优化前负荷画图
w=1;
ee=value([Pfix(w,:);Pcut(w,:);Pshift1(w,:);Pshift2(w,:);Ptran(w,:)]);
figure

bar(ee',1,'stacked')

hold on
% bar(Pcut(w,:),1,'stack')
% hold on
% bar(Pshift1(w,:),1,'stack')
% hold on
% bar(Pshift2(w,:),1,'stack')
% hold on
% bar(Ptran(w,:),1,'stack')
% hold on
% plot(Pfix(w,:)+Pcut(w,:)+Pshift1(w,:)+Pshift2(w,:)+Ptran(w,:),'g-*','linewidth',2)
% hold on 
% plot(Pfix(w,:),'y-*','linewidth',2)
xlabel('时间/h');
ylabel('电负荷功率/kW');
legend('基础电负荷','可消减电负荷','可平移电负荷1','可平移电负荷2','可转移电负荷');
title('优化前用户侧柔性电负荷分布');



% 
%% 电场景1
for w=1:Sw

    op_e_load(w,:)=Pfix(w,:)+Pcut(w,:)+PPshift1(w,:)+PPshift2(w,:)+PPtran(w,:)-PPcut(w,:);
    a_e_load(w,:)=Pcut(w,:)+PPshift1(w,:)+PPshift2(w,:)+PPtran(w,:)-PPcut(w,:);
end
    x=1:24;
% % 
w=1;
% figure
% bar(e_load(w,:)-op_e_load(w,:),'b');
% hold on
% xlabel('时间/h');
% ylabel('电负荷/kW');
% yyaxis right
% plot(buy_price(w,:),'r--*','linewidth',2);
% xlabel('时间/h');
% ylabel('电价');
% title('需求响应前后电负荷曲线');
% legend('响应电负荷','市场电价');
% 
% 
% % 
% for w=1:Sw
% figure
% plot(e_load(w,:),'LineStyle', '-','LineWidth', 1);
% hold on
% plot(op_e_load(w,:),'LineStyle', '-','LineWidth', 1);
% hold on
% 
% hold on
% xlabel('时间/h');
% ylabel('电负荷/kW');
% title('需求响应前后电负荷曲线');
% legend('优化前电负荷','优化后电负荷');

% end
% % 
% 
% 

%% 其他管理资源画图
for w=1
b=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
yyaxis left
% eee=value([Pbuy(w,:);Psell(w,:);Pdischarge(w,:);-Pcharge(w,:);P_pv(w,:); P_mt(w,:);P_wt(w,:)]);
eee1=value([Pbuy(w,:);Pdischarge(w,:);P_pv(w,:); P_mt(w,:);P_wt(w,:)]);
eee2=value([Psell(w,:);-Pcharge(w,:)]);
figure
 bar(eee1','stack');
 hold on
bar(eee2','stack');
 hold on
plot(x,op_e_load(w,:),'-rs');
hold on
plot(x,e_load(w,:),'-b*');
hold on
ylabel('功率/kW');
yyaxis right
plot(buy_price(w,:),'b--*','linewidth',2);
xlabel('时间/h');
ylabel('电价');
legend({'买电功率','蓄电池放电','光伏出力','燃气轮机供电','风电出力','卖电功率','蓄电池充电','优化后电负荷需求','原电负荷需求','电网电价'});
title('电负荷平衡');

end
% % 
% % % % 

% 优化后负荷画图
for w=1
for i=1:24
    PPPcut(w,i)=Pcut(w,i)-PPcut(w,i); %所剩的可消减电负荷
end
w=1;
figure
ee=value([Pfix(w,:);PPPcut(w,:);PPshift1(w,:);PPshift2(w,:);PPtran(w,:)]);
bar(ee',1,'stacked');
legend('基础电负荷','可消减电负荷','可平移电负荷','可平移电负荷','可转移电负荷');
xlabel('时间/h');
ylabel('电负荷功率/kW');
title('优化后用户可调电负荷分布');
end
