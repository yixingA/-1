function f = maxf1_1D(x0,N)
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
num_steps = 24; % 时间步长（h）

% 各管道长度 (m)
L = [100, 150, 200, 120, 180, 130, 170, 140];

% 各管道内径 (m)
di = [0.1, 0.12, 0.15, 0.08, 0.11, 0.09, 0.13, 0.10];

% 各管道外径 (m)
do = [0.12, 0.14, 0.17, 0.10, 0.13, 0.11, 0.15, 0.12];

% 各管道平均直径
D = (di + do) / 2;



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



% 压力波动参数
A = pi * (D/2).^2;  % 各管道截面积 (m^2)
f1 = 0.02 * ones(1, num_pipes); % 各管道摩擦系数
K = 0.5 * ones(1, num_pipes);  % 各管道局部阻力系数
rho = 1000;         % 热媒密度 (kg/m^3)
Q0 = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]; % 初始流量 (m^3/s)
rho = 1000;         % 流体密度 (kg/m^3)
cp = 4186;          % 流体比热容 (J/(kg·K))
delta_T = 10;       % 流体进出口温差 (K)
Qh0 = rho * cp * delta_T * Q0;

t1=0;
% 初始化变量
Q_loss = zeros(num_pipes, num_steps); % 各管道热损失 (W)
T_fluid = repmat(T_fluid_initial', 1, num_steps); % 热媒温度 (°C)
Q_load=0;
T_indoor = zeros(1, num_steps); % 室内温度 (°C)
T_indoor(1) = 20; % 初始室内温度 (°C)
Q = repmat(Q0', 1,num_steps); % 流量矩阵
Qh = repmat(Qh0', 1,num_steps); % 热负荷矩阵
Delta_P = zeros(num_pipes,num_steps); % 压力损失矩阵
Qh0 = rho * cp * delta_T * Q0; 




%% 两个节点受攻击的矩阵数置换
for i=1:N
%     tic;
    %[z0,Pc00] = normalsolve(ind(1));%x1是节点LA运营后的负荷向量
  
   % [y0,Pc01,P_C0] = innersolve(x0(i),z0,Pc00,ind(1));%x1是攻击节点LA运营后的负荷向量
   
    [z0,Pc00,Cost_total0,Price_Charge0] = normalsolve(ind(1)); %正常时每个LA负荷 
%    [y0,Pc01,P_C0] = innersolve(x0(i),z0,Pc00,ind(1),Price_Charge0);%被攻击后
     [y0,Pc01,P_C0] = innersolve1(x0(i),z0,Pc00,ind(1),Price_Charge0);%被攻击后


%     tt(i) = toc;
%     plot(tt);
    X1=X0;
    X11=X00;
    X11(:,ind(1))=z0;
    X1(:,ind(1))=y0;

    Ce(:,ind(1))=P_C0;
    %%
    Pn_d = X1(t,:)-X11(t,:);
%     if Pn_d(:)<0
    Pn_b = X00(t,:);
    R=0;%初始化LA经济损失
    Cz=0;%初始化攻击总代价
    H=10;%用户满意度赔偿
    
    
    %% 管道热损失计算
    dQ_loss=zeros(1,24);
    if Pn_d>0
    Q_load=Q_load+Pn_d;
    delta_T = Q_load / (m_dot * cp); % 热媒温度变化 (K)
    T_fluid(i) = T_fluid(i) + delta_T; % 更新热媒温度


    % 计算每根管道的热损失
    

    dQ_loss=0;%初始化线路功率增量
        o=0;%% 4个聚合商节点对应的管道线路
        for i=ind
            switch i
                case 1
                    o=1;
                case 2
                    o=2;
                case 3
                    o=3;
                case 4
                    o=4;
                
            end  


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
        
        for j=ind 
           
        % 计算热损失
        Q_loss(i) =Q_loss(i) + U * A * (T_fluid(i) - T_ambient); % 热损失 (W)

       dT_indoor = alpha * (mean(T_fluid(i)) - T_indoor(i)); % 室内温度变化率
       T_indoor(i) = T_indoor(i) + dT_indoor; % 更新室内温度
       
       end
    end
    dQ_loss=(Q_loss(i,t)-Q_loss(i,t-1));%热损失增量
end

    dQ_loss=sum(dQ_loss(i));


    S = exp(-abs(T_indoor(1,t) - T_desired) / Delta_T_tolerance);%满意度
 

  %% 管道压力损失    
%delta_P1=zeros(8,24);
     Qh(ind,t) = Qh0(ind) + Pn_d(ind);

    Q(ind, t) = Qh(ind,t) / (rho * cp * delta_T)


       % 计算各管道流速
    v = Q(ind,t) / A(1,ind);
    
    % 计算各管道压力损失
    Delta_P(ind,t) = f1(ind) .* (L(ind) ./ D(ind)) .* (rho * v.^2 / 2) + K(ind) .* (rho * v.^2 / 2);

% 计算攻击管道压力波动

%delta_P(i) = Delta_P(i) - Delta_P(i);
delta_P1=Delta_P(ind,t)-Delta_P(ind,t-1);
 
 end
  
delta_P1=sum(delta_P1);

%% 总损失

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
    
    
    f(i) = (w*(dQ_loss+delta_P1)+(1-w)*R/1000)/Cz;
%     f(i) = (w*Lambda+(1-w)*R/1000);
%     else
%     end


end

