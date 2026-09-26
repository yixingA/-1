clc;clear;
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
global branch_num
global Pl_b
global G
global w
global price_day_ahead
global numnodes
global L
w=0.5;%电力系统损失权重
D=8;%维数(指给8个节点配置LA?)
t=7;%求t时段时最优攻击
L=5;
T=2;%攻击节点数量
R=0.29;%最大攻击资源
%8个节点LA下的不同用户数（给8个节点配备LA）
N1=[200 150 250 200 150 250 200 150]*3;%早出晚归型
N2=[150 150 150 150 150 150 150 150]*3;%上班族
N3=[50 50 100 50 50 100 50 50]*3;%夜班型
Zc=0.9*24-9.6;%单个用户的可转移负荷总量
%% 系统参数
%所有参数均用有名值表示
% newcase1 = IEEE33BW;
% paragen=xlsread('excel2017','机组参数');
loadcurve=importdata('mieee29-bus.mat');
netpara=importdata('mieee29-branch.mat');
branch_num=size(netpara);%网络中的支路
branch_num=branch_num(1,1);%7条支路数
Pl_b=netpara(:,5);%节点所带负荷
% %机组数
% gennum=size(paragen);
% gennum=gennum(1,1);%机组数6个
%节点数

numnodes=size(loadcurve);
numnodes=numnodes(1,1);%n个节点   

%% 直流潮流下的导纳矩阵节点参数初始化
netpara(:,4)=1./netpara(:,4);%电抗求倒数成电纳
slack_bus=1;%按不同的平衡节点号更改 ，目前选择1节点为平衡节点。
Y=zeros(numnodes,numnodes);
%% 直流潮流的导纳矩阵计算
for k=1:branch_num 
    i=netpara(k,1);%首节点
    j=netpara(k,2);%尾节点
    Y(i,j)=-netpara(k,4);%导纳矩阵中非对角元素
    Y(j,i)= Y(i,j);
end
for k=1:numnodes
       Y(k,k)=-sum(Y(k,:)); %导纳矩阵中的对角元素 
end

%再删除掉平衡节点所在的行与列
Y(slack_bus,:)=[];
Y(:,slack_bus)=[];
%% 输出功率转移分布因子(GSDF)
X=inv(Y);%X为直流潮流下节点导纳矩阵的逆矩阵
row=zeros(1,numnodes-1);%numnodes-1是因为节点导纳矩阵去掉了平衡节点 shape=1*29

%再次引入平衡节点的矩阵值，根据直流潮流定义ΔΘ=ΧΔP,平衡机角度始终为0，所以所有涉及平衡节点的X均为0
X=[X(1:slack_bus-1,:);row;X(slack_bus:numnodes-1,:)];%插入全0行
column=zeros(numnodes,1);
X=[X(:,1:slack_bus-1) column X(:,slack_bus:numnodes-1)];%插入全0列

G=zeros(branch_num,numnodes);%GSDF功率转移矩阵初始化
for k=1:branch_num
    m=netpara(k,1);%首端节点
    n=netpara(k,2);%末端节点
    xk=netpara(k,4);%支路k的阻抗值
    for i=1:numnodes
        G(k,i)=(X(m,i)-X(n,i))*xk;%输出功率转移分布因子
    end
end
%% ---------各个节点通讯漏洞成本-------------
A=xlsread('vulnerability scores.xlsx','','A1:A8');%读取8个节点通讯漏洞分数
b=sum(A(2:8,1));%分数加和
Cm=A/b;%LA节点网络漏洞攻击成本矩阵
%% 应用粒子群求解模型
% while(1)        %初始解
%     x0=rand(1,D);
%     if(h(x0)<=0)
%         break;
%     end
% end

%电网初始24小时基线负荷与不响应时电价
x0=[1733.66666666000;1857.50000000000;2105.16666657000;2352.83333343000;2476.66666657000;2724.33333343000;2848.16666657000;2972;3219.66666657000;3467.33333343000;3591.16666657000;3715.00000000000;3467.33333343000;3219.66666657000;2972;2600.50000000000;2476.66666657000;2724.33333343000;2972;3467.33333343000;3219.66666657000;2724.33333343000;2229;1981.33333343000]*3;%某节点LA下24小时用户的基线负荷
price_day_ahead=[0.35;0.33;0.3;0.33;0.36;0.4;0.44;0.46;0.52;0.58;0.66;0.75;0.81;0.76;0.8;0.83;0.81;0.75;0.64;0.55;0.53;0.47;0.40;0.37];

X0=repmat(x0,1,D);%假设8个节点的LA下用户24小时基线负荷相同
for i=1:8
    X0(:,i)=X0(:,i)+(N1(i)+N2(i)+N3(i))*Zc/24;
end
Ce=repmat(price_day_ahead,1,D);%假设8个节点的LA下用户24小时不响应时电价相同
X1=X0;%初始化矩阵X0，否则在执行PSO中生成攻击向量的这个过程中调用的矩阵X1不对。
xx0=X0(t,:);%,t时段各个节点的原始功率，一直恒定，用于判别Delta
data_a=zeros(1,T);
num_a=zeros(1,T);
data_am=zeros(1,T);
MM=nchoosek(D,T); %从n各元素中取m个元素的所有组合数（相当于所有的攻击可能性）
%XM=zeros(MM,D);
%FV=zeros(1,MM);
A0=get01(D,T);%生成0-1矩阵
X00=X0;%为了固定住P_b不随后面迭代过程X0的变化而变化，定义X00，在下层函数中维持住变化量幅度不超过原始数据的0.7-1.3倍，计算对电力系统影响时，也用的对最初值的增幅
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
        if T==2
            [mf0,data_a]=outersolve_2D(20,0.8,0.5,0.5,10);
        elseif T==3
            [mf0,data_a]=outersolve_3D(20,0.8,0.5,0.5,10);
        elseif T==4
            [mf0,data_a]=outersolve_4D(20,0.8,0.5,0.5,10);    
        end

%         for j=1:30%进行30次迭代
%             for i=ind
%             X1(:,i) = lowlevelsolve(X0(:,i),N1(i),N2(i),N3(i),Zc);%x1是节点LA运营后的负荷向量
%             end
% %           Pn_d = X1(t,:)-(X0(t,:)+Zc*(N1(i)+N2(i)+N3(i))/24);%t时段内每个节点LA的增量，LA影响下的节点
%             x = uplevelsolve(X1(t,:),Pn_b,Ce(t,:),N1(i),N2(i),N3(i),branch_num);%x是生成的攻击向量,这里的p_b是不随迭代过程某次攻击后X0变化的
%             if mf<f1(x,X1(t,:)) %mf、mx、mx1是单次指定攻击节点数量的最大值
%                 mx = x;
%                 mx1 = X1(t,:);
%                 mf = f1(x,X1(t,:));
%             else
%             end
%             X0(t,:)=mx;%此次迭代的mx为t时段的对于各个节点的此次迭代最优攻击量
%         end
    else
    end


    if maxf<mf0 %mf、mx、mx1是单次指定攻击节点数量的最大值
        maxf = mf0;
        num_a = ind;
        data_am=data_a;
    end
end
% % data_ta=[data_ta;data_am];
% % num_ta=[num_ta;num_a];
% maxx - x;
% maxx1 - X1;
% F1=f1(maxx,maxx1);
% F2=f2(maxx,maxx1);
% for i=1:D
%     x = 1:1:24;% 24个时段
%     z1 = normalsolve(i); %正常时每个LA负荷    
%     if num_a(num_a==i)%判断i是否在num_a中
%         [m,n]=find(num_a==i);
%         [z2,Price_Charge] = innersolve(data_am(n),z1,i);%被攻击攻击后
%     else
%         [z2,Price_Charge] = normalsolve(i);   %被攻击攻击后
%     end
%     z1=z1';
%     z2=z2';
%     hold on
%     plot3(x,i*ones(size(x)),z1,'b.--','linewidth',1)%画正常时
%     plot3(x,i*ones(size(x)),z2,'r.:','linewidth',1)%画被攻击后
%     axis([1 24 0 9 0 4000])
%     box on
%     grid on
%     view(-20,22)
% end
% % end


%选择


for i=num_a
    x = 1:1:24;% 24个时段
    [m,n]=find(num_a==i);%% 找到对应节点
    [z0,pcout,cost,Price_Charge0] = normalsolve(i); %正常时每个LA负荷 
    [z2,pcout1,costa,Price_Charge] = innersolve(data_am(n),z0,pcout,i,Price_Charge0);%被攻击后


 figure
    plot(x,z0,'b.--','linewidth',1)%画正常时
    hold on
    plot(x,z2,'r.:','linewidth',1)%画被攻击后
%     axis([1 24 1500 15000])
    hold off
    xlabel('时间（h）');
    ylabel('LA负荷（KW）'); 
    legend('正常LA响应','受攻击后LA响应');

 figure
    plot(x,Price_Charge0,'g.--','linewidth',1)%画正常时
    hold on
    plot(x,Price_Charge,'b.:','linewidth',1)%画被攻击后
%     axis([1 24 1500 15000])
    hold off
    xlabel('时间（h）');
    ylabel('电价'); 
    legend('正常LA响应','受攻击后LA响应');
    hold on

 figure
    plot(x,cost,'g.--','linewidth',1)%画正常时
    hold on
    plot(x,costa,'b.:','linewidth',1)%画被攻击后
%     axis([1 24 1500 15000])
    hold off
    xlabel('时间（h）');
    ylabel('LA收益'); 
    legend('正常LA响应','受攻击后LA响应');
    hold on

 end









% figure;
% plot(x,z0,'--b^','linewidth',1)%画正常时
% hold on
% for ub=[0.15,0.25,0.35]
%     plot(x,z2,'r.:','linewidth',1)%画被攻击后
%     hold on
% end







% plot(x,z2,'--p','linewidth',1)%画最优值
% legend('初值','u=15%','u=25%','u=35%','最优值');
% axis([0,24,4000,12000])%x,y轴范围
% xlabel('时刻')  %x轴坐标描述
% ylabel('负荷（kw）') %y轴坐标描述
% % a2_8_;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%用描点覆盖了本firgure内前面的表面功夫
% figure;
% plot(x,z0,'--b^','linewidth',1)%画正常时
% hold on
% ub=0.25;
% for vb=[0.6,1.2,1.5]
%     plot(x,z2,'r.:','linewidth',1)%画被攻击后
%     hold on
% end
% plot(x,z2,'--p','linewidth',1)%画最优值
% legend('初值','u=25%,v=60%','u=25%,v=120%','u=25%,v=150%','最优值');
% axis([0,24,4000,12000])%x,y轴范围
% xlabel('时刻')  %x轴坐标描述
% ylabel('负荷（kw）') %y轴坐标描述
% % b2_8_;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%用描点覆盖了本firgure内前面的表面功夫

toc
disp(['运行时间: ',num2str(toc)]);