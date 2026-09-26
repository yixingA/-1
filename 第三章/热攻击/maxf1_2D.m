function f = maxf1_2D(x0,x1,N)
global ind
global Cm
global X0
global X00
global t
global Ce

global w
global price_day_ahead
pt=1.2*price_day_ahead;

% tt = zeros(1,100);
% z0=ones(N,1)*ind(1);
% z1=ones(N,1)*ind(2);
f=zeros(N,1);%N为初始种群数



%% 热力系统

%% 系统参数

num_pipes = 8; % 管道数量
num_steps = 24; % 时间步长

% 各管道长度 (m)
L = [100, 150, 200, 120, 180, 130, 170, 140];

% 各管道内径 (m)
di = [0.1, 0.12, 0.15, 0.08, 0.11, 0.09, 0.13, 0.10];

% 各管道外径 (m)
do = [0.12, 0.14, 0.17, 0.10, 0.13, 0.11, 0.15, 0.12];

% 各管道保温材料导热系数 (W/m·K)
k_ins = [0.04, 0.05, 0.03, 0.06, 0.04, 0.05, 0.03, 0.06];

% 各管道保温层厚度 (m)
t_ins = [0.02, 0.03, 0.025, 0.015, 0.02, 0.025, 0.015, 0.03];

% 初始热媒温度 (°C)
T_fluid_initial = [80, 85, 90, 75, 82, 78, 88, 83];
T_ambient = 15; % 环境温度 (°C)

% 对流换热系数（假设为常数）
hi = 100; % 管道内表面对流换热系数 
ho = 10; % 管道外表面对流换热系数 

% 热媒参数
m_dot = 10; % 热媒质量流量 (kg/s)
cp = 4186; % 热媒比热容 (水, J/kg·K)


% 用户满意度参数
T_desired = 22; % 用户期望的室内温度 (°C)
Delta_T_tolerance = 2; % 用户对温度偏差的容忍范围 (°C)
alpha = 0.01; % 热传递系数


t1=0;
% 初始化变量
Q_loss = zeros(num_pipes, num_steps); % 各管道热损失 (W)
T_fluid = repmat(T_fluid_initial', 1, num_steps); % 热媒温度 (°C)
Q_load=0;
T_indoor = zeros(1, num_steps); % 室内温度 (°C)
T_indoor(1) = 20; % 初始室内温度 (°C)



%% 两个节点受攻击的矩阵数置换
for i=1:N
%     tic;
    [z0,Pc00] = normalsolve(ind(1));%x1是节点LA运营后的负荷向量
    [z1,Pc11] = normalsolve(ind(2));%x1是节点LA运营后的负荷向量
    [y0,P_C0] = innersolve(x0(i),z0,Pc00,ind(1));%x1是攻击节点LA运营后的负荷向量
    [y1,P_C1] = innersolve(x1(i),z1,Pc11,ind(2));%x1是攻击节点LA运营后的负荷向量
%     tt(i) = toc;
%     plot(tt);
    X1=X0;
    X11=X00;
    X11(:,ind(1))=z0;
    X11(:,ind(2))=z1;
    X1(:,ind(1))=y0;
    X1(:,ind(2))=y1;
%     X0(:,ind(1))=y0;
%     X0(:,ind(2))=y1;
    Ce(:,ind(1))=P_C0;
    Ce(:,ind(2))=P_C1;
    %%
    Pn_d = X1(t,:)-X11(t,:);
%     if Pn_d(:)<0
    Pn_b = X00(t,:);
    R=0;%初始化LA经济损失
    Cz=0;%初始化攻击总代价
    H=10;%用户满意度赔偿
    
    
    %% 管道热损失计算
  for t1 = 1:num_steps
    % 热负荷突增
    if t1 >= t
         Q_load = Pn_d; % 热负荷增量
    else
         Q_load = 0; % 无热负荷增量
    end
    

    delta_T = Q_load / (m_dot * cp); % 热媒温度变化 (K)
    T_fluid(:, t1) = T_fluid(:, t1-1) + delta_T; % 更新热媒温度


    % 计算每根管道的热损失
    for i = ind
        % 计算管道内半径和外半径
        ri = di(i) / 2; % 内半径 (m)
        ro = do(i) / 2 + t_ins(i); % 外半径 (包括保温层) (m)
        
        % 计算总传热系数 U
        term1 = 1 / hi; % 内表面对流换热项
        %term2 = ro * log(ro / (di(i)/2)) / k_ins(i); % 保温层热传导项
        term3 = 1 / ho; % 外表面对流换热项
        U = 1 / (term1 +  term3); % 总传热系数 (W/m)
        
        % 计算管道外表面面积
        A = pi * (do(i) + 2 * t_ins(i)) * L(i); % 外表面面积 (m)
        
        for j=ind %% 5个聚合商节点对应的管道线路
           
        % 计算热损失
        Q_loss(i, t1) =Q_loss + U * A * (T_fluid(i, t1) - T_ambient); % 热损失 (W)

       dT_indoor = alpha * (mean(T_fluid(:, t1)) - T_indoor(t1-1)); % 室内温度变化率
       T_indoor(t1) = T_indoor(t1-1) + dT_indoor; % 更新室内温度

       end
    end
  end
       
    end
       Q_loss(i)=sum(Q_loss(i, t1));
       S = exp(-abs(T_indoor - T_desired) / Delta_T_tolerance);






%% 对热力系统损失


 


    for k=ind %对LA经济损失
        Ps(k) = Pn_d(k)-Pn_b(k)*1.3;%节点LA响应电量-电网下达响应电量最大阈值（电网下达中心*1.3）
        if(Ps(k)<=0)
            Ps(k)=0;
        else
        end
        ppen = (1+Ps(k)/Pn_b(k))*Ps(k);%违约金函数
        R = R+ppen*Ps(k)+(pt(k)-Ce(k))*Pn_d(k)+H*S;
        Cz = Cz+Cm(k);
    end
    f(i) = (w*Q_loss(k)+(1-w)*R/1000)/Cz;
%     f(i) = (w*Lambda+(1-w)*R/1000);
%     else
%     end
end



