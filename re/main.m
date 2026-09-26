%% 热聚合商交互过程

clc;clear;close all;% 程序初始化
%% 读取数据
shuju=xlsread('LA数据.xlsx'); %把一天划分为24小时
load_h=shuju(2,:); %初始热负荷
pe_hrid_S=shuju(3,:); %购热价
pe_hrid_B=shuju(4,:); %售热价


%% 主从博弈过程

F = 0.5;   % 缩放因子
CR = 0.9;  % 交叉因子
%参数设置
groupSize =40;        %个体数目(Number of individuals)
groupDimension=24;  %染色体长度
MAXGEN =300;      %最大遗传代数(Maximum number of generations)
v=zeros(groupSize,groupDimension);    % 变异种群
u=zeros(groupSize,groupDimension);    % 交叉种群
Unew=zeros(groupSize,groupDimension); % 边界处理后的种群
%初始种群
population = smartGroupInit(groupSize,groupDimension);% 初始化群体
gen=0;                                         %种群世代计数器
fitness=0; %初始适应度
user=10000;%用户收益
while gen<MAXGEN
   gen=gen+1 
%计算目标函数值   
   [P_GB,F_user,Hload,H_buy] = computeObj4(population,load_h);
%变异操作
   v=mutate(population,F,MAXGEN,gen); %针对整个种群的变异
%交叉操作
   u=crossover(population,v,CR);
%边界处理
   Unew = boundaryprocess(u,pe_hrid_S,pe_hrid_B);
% 选择操作 (计算新的适应度)
[Newpopulation,fitbest,best] =select(Unew,population,P_GB,H_buy,pe_hrid_S);
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
phmax=shuju(5,:); %热价上限
phmin=shuju(6,:); %热价下限
%% 热聚合商画图函数
figure(1)
plot(trace(:,2)*10,'c-','linewidth',1)
hold on
% plot(trace(:,3),'c-*','linewidth',2)
% hold on
xlabel('迭代次数');
ylabel('运营商收益函数');
yyaxis right
plot(trace(:,4),'g-','linewidth',1);
ylabel('热聚合商成本函数');
title('迭代过程');
%legend('微网运营商收益曲线','共享储能商收益曲线','用户收益曲线')
legend('运营商收益曲线','热聚合商成本曲线')


% figure(2)
% bar(load_h-Hload);
% hold on 
% ylabel('负荷/kW');
% yyaxis right
% plot(shuju(3,:),'g-*','linewidth',2)
% xlabel('时间/h');
% ylabel('热价');
% title('热负荷优化结果');
% legend('负荷转移结果','市场热价');


figure(3)
plot(load_h,'b-*','linewidth',2);
hold on
plot(Hload,'r-*','linewidth',2)
hold on 
xlabel('时间/h');
ylabel('热负荷/kW');
title('热负荷变化');
legend('原始热负荷值','优化热负荷值');



figure(4)
xx=1:24;
stairs(phmax,'r--*','linewidth',2);
hold on
stairs(phmin,'b--*','linewidth',2);
hold on
stairs(best(1,xx),'y--','linewidth',2);
xlabel('时间/h');
ylabel('热价');
title('微网运营商热价');
legend('热价上限','热价下限','运营商售热价');


