%% 电聚合商交互过程

clc;clear;close all;% 程序初始化
%% 读取数据
shuju=xlsread('LA数据.xlsx'); %把一天划分为24小时
%load_e=[160	150	140	140	130	135	150	180	215	250	275	320	335	290	260	275	270	280	320	360	345	310	220	160];%电负荷;
load_e=shuju(2,:); %初始电负荷

pe_grid_S=shuju(3,:); %电网售电价
pe_grid_B=shuju(4,:); %电网购电价



%% 主从博弈过程

F = 0.5;   % 缩放因子
CR = 0.9;  % 交叉因子
%参数设置
groupSize =40;        %个体数目(Number of individuals)
groupDimension=24;  %染色体长度
MAXGEN =300;      %最大遗传代数(Maximum number of generations)%200
v=zeros(groupSize,groupDimension);    % 变异种群
u=zeros(groupSize,groupDimension);    % 交叉种群
Unew=zeros(groupSize,groupDimension); % 边界处理后的种群
%初始种群
population = smartGroupInit(groupSize,groupDimension);% 初始化群体
gen=0;                                         %种群世代计数器
trace1=zeros(MAXGEN,24);
fitness=0; %初始适应度
user=10000;%用户成本
while gen<MAXGEN
   gen=gen+1 
%计算目标函数值   
    [P_MT,F_user,Eload,P_buy] = computeObj4(population,load_e);
    trace1(gen,:)=Eload;
%变异操作
   v=mutate(population,F,MAXGEN,gen); %针对整个种群的变异
%交叉操作
   u=crossover(population,v,CR);
%边界处理
 %  Unew = boundaryprocess(u,pe_grid_S,pe_grid_B,ph_max,ph_min);
  Unew = boundaryprocess(u,pe_grid_S,pe_grid_B);
% 选择操作 (计算新的适应度)
[Newpopulation,fitbest,best] =select(Unew,population,P_MT,P_buy,pe_grid_S);
trace(gen,1)=gen; %赋值世代数
    population=Newpopulation;
    %追踪最优适应度和售电售热价
    if fitness<=fitbest
    fitness = fitbest;  
    trace(gen,2)=fitbest;
    remainbest=best;
    else
    trace(gen,2)=fitness;
    end
 %   trace(gen,3)=F_share; %共享储能商的收益
%追踪最优目标函数
if user>=F_user
    user=F_user;
    trace(gen,4)=F_user;%用户收益曲线
else
    trace(gen,4)=user;
end
end

%% 画图




%电聚合商画图函数

% 电价画图
figure(1)
plot(trace(:,2)*10,'c-','linewidth',1)
hold on
xlabel('迭代次数');
ylabel('运营商收益');
yyaxis right
plot(trace(:,4)*5,'g-','linewidth',1);
ylabel('聚合商成本');
title('迭代过程');
legend('运营商收益曲线','电聚合商成本曲线')


% figure(2)
% bar(load_e-Eload);
% hold on 
% ylabel('负荷/kW');
% yyaxis right
% plot(shuju(3,:),'g-*','linewidth',2)
% xlabel('时间/h');
% ylabel('电价');
% title('电负荷优化结果');
% legend('负荷转移结果','市场电价');


figure(3)
bar(load_e,'b');
hold on
plot(Eload,'r-*','linewidth',2)
hold on 
xlabel('时间/h');
ylabel('电负荷/kW');
title('电负荷变化');
legend('原始电负荷值','优化电负荷值');



figure(4)
xx=1:24;
stairs(pe_grid_S,'r--*','linewidth',2);
hold on
stairs(pe_grid_B,'b--*','linewidth',2);
hold on
stairs(best(1,xx),'y--','linewidth',2);
xlabel('时间/h');
ylabel('电价');
title('运营商电价');
legend('电价上限','电价下限','运营商售电价');


