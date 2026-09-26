clc;
clear;
tic
mf0=0;
mf=0;
maxf=mf;
global Ce
global Cm
global xx0
global ind
global ind0
global N1
global N2
global N3
global Zc
global X0
global X00
global t
global w
global price_day_ahead


w=0.6;%热力系统损失权重
D=4;%维数(指给4个热节点配置LA)
t=7;%求t时段时最优攻击
L=1;
T=1;%攻击节点数量
%R=0.65;%最大攻击资源
R=0.65;
%5个节点LA下的不同用户数（给4个节点配备LA）
% N1=[200 150 250 200 150 250 200 150]*3;%早出晚归型
% N2=[150 150 150 150 150 150 150 150]*3;%上班族
% N3=[50 50 100 50 50 100 50 50]*3;%夜班型

N1=[200 150 250 200]*3;%早出晚归
N2=[150 150 150 150]*3;%上班族
N3=[50 50 100 50 50]*3;%夜班型


%Zc=0.9*24-9.6;%单个用户的可转移负荷总量
Zc=0.9*24-9.6;

%% ---------各个节点通讯漏洞成本-------------
A=xlsread('vulnerability scores.xlsx','1','A1:A4');%读取4个节点通讯漏洞分数
b=sum(A(2:4,1));%分数加和
Cm=A/b;%LA节点网络漏洞攻击成本矩阵


%% 应用粒子群求解模型




%热网初始24小时负荷与不响应时热价
%x0=[1733.66666666000;1857.50000000000;2105.16666657000;2352.83333343000;2476.66666657000;2724.33333343000;2848.16666657000;2972;3219.66666657000;3467.33333343000;3591.16666657000;3715.00000000000;3467.33333343000;3219.66666657000;2972;2600.50000000000;2476.66666657000;2724.33333343000;2972;3467.33333343000;3219.66666657000;2724.33333343000;2229;1981.33333343000]*3;%某节点LA下24小时用户的基线负荷
x0=[1600;1800;2100;2300;2400;2700;2800;2900;3400;3500;3700;3400;3200;2900;2600;2400;2700;2900;3400;3200;2700;2229;1900;2000]*3;%某节点LA下24小时用户的热负荷

price_day_ahead=[0.35;0.33;0.3;0.33;0.36;0.4;0.44;0.46;0.52;0.58;0.66;0.75;0.81;0.76;0.8;0.83;0.81;0.75;0.64;0.55;0.53;0.47;0.40;0.37];
%price_day_ahead=[3.5;3.3;3;3.3;3.6;4;4.4;4.6;5.2;5.8;6.6;7.5;8.1;7.6;8;8.3;8.1;7.5;6.4;5.5;5.3;4.7;4;3.7];
X0=repmat(x0,1,D);%假设4个节点的LA下用户24小时初始负荷相同
for i=1:4
    X0(:,i)=X0(:,i)+(N1(i)+N2(i)+N3(i))*Zc/24;
end
Ce=repmat(price_day_ahead,1,D);%假设4个节点的LA下用户24小时不响应时电价相同
X1=X0;%初始化矩阵X0，否则在执行PSO中生成攻击向量的这个过程中调用的矩阵X1不对。
xx0=X0(t,:);%,t时段各个节点的原始功率，一直恒定，用于判别Delta
data_a=zeros(1,T);
num_a=zeros(1,T);
data_am=zeros(1,T);
MM=nchoosek(D,T); %从n各元素中取m个元素的所有组合数（相当于所有的攻击可能性）
A0=get01(D,T);%生成0-1矩阵
X00=X0; %为了固定住P_b不随后面迭代过程X0的变化而变化，定义X00，在下层函数中维持住变化量幅度不超过原始数据的0.7-1.3倍，计算对热力系统影响时，也用的对最初值的增幅
Pn_b = X00(t,:);%t时段每个节点LA的未响应时负荷，此处认为是各LA,t时段的基线负荷


data_ta=zeros(1,2);
num_ta=zeros(1,2);

% % for t=6:10

%% 选择攻击模式
for k=1:MM
    C=A0(k,:).*Cm';%代价矩阵(攻击成本计算)
    b=sum(sum(C));%^篡改已经使用的资源
    if b<=R
        ind=find(C);%得到A0中对应非零元素位置
        ind0=find(C==0);%得到A0中对应零元素位置
        if T==1
            [mf0,data_a]=outersolve_1D(20,1.8,2.2,0.8,10);
        elseif T==2    
            [mf0,data_a]=outersolve_2D(20,1.8,2.2,0.8,10);
        elseif T==3
            [mf0,data_a]=outersolve_3D(20,0.8,0.5,0.5,10);
        elseif T==4
            [mf0,data_a]=outersolve_4D(20,0.8,0.5,0.5,10);    
        end


    else
    end


    if maxf<mf0 %mf、mx、mx1是单次指定攻击节点数量的最大值
        maxf = mf0;
        num_a = ind;
        data_am=data_a;
    end
end



for i=num_a
    x = 1:1:24;% 24个时段
    [m,n]=find(num_a==i);%% 找到对应节点
    [z0,pcout0,Cost_total0,Price_Charge0] = normalsolve(i); %正常时每个LA负荷 
    %[z2,pcout1,Cost_total1,Price_Charge1] = innersolve(data_am(n),z0,pcout0,i,Price_Charge0);%被攻击后
 [z2,pcout1,Cost_total1,Price_Charge1] = innersolve1(data_am(n),z0,pcout0,i,Price_Charge0)



%% 画图函数（攻击负荷）
 figure
    plot(x,z0,'b.--','linewidth',1)%画正常时
    hold on
    plot(x,z2,'r.:','linewidth',1)%画被攻击后
%     axis([1 24 1500 15000])
  
    xlabel('时间（h）');
    ylabel('热聚合商负荷（KW）'); 
    legend('正常负荷响应','受攻击后负荷响应');



 figure
    plot(x,Price_Charge0,'g.--','linewidth',1)%画正常时
    hold on
    plot(x,Price_Charge1,'b.:','linewidth',1)%画被攻击后

  
    xlabel('时间（h）');
    ylabel('热价'); 
    legend('正常负荷响应','受攻击后负荷响应');
    hold on

    
 figure
    plot(x,Cost_total0,'g.--','linewidth',1)%画正常时
    hold on
    plot(x,Cost_total1,'b.:','linewidth',1)%画被攻击后

    
    xlabel('时间（h）');
    ylabel('聚合商收益'); 
    legend('正常负荷响应','受攻击后负荷响应');
    hold on


end







toc
disp(['运行时间: ',num2str(toc)]);