function [ff,ym] = outersolve_1D(N,c_1,c_2,c_3,ger)
%% 初始化种群
f= @(a) maxf1_1D(a,N); % 函数表达式 待优化
% figure(1);
% [x0_1, x0_2]=meshgrid(0:.2:20);
% y0=f(x0_1,x0_2);
% mesh(x0_1, x0_2, y0);
% hold on;


% N = 20;                         % 初始种群个数
d = 1;                          % 空间维数
x=zeros(N,d);
% ger = 10;                      % 最大迭代次数     
limit = [0.001, 0.01;0.001,0.01];                % 设置位置参数限制(矩阵的形式可以多维)
vlimit = [-0.0008, 0.0008;-0.0008, 0.0008];               % 设置速度限制
% c_1 = 0.8;                        % 惯性权重
% c_2 = 0.5;                       % 自我学习因子
% c_3 = 0.5;                       % 群体学习因子 
 for i = 1:d
    x(:,i) = limit(i, 1) + (limit(i, 2) - limit(i, 1)) * rand(N, 1);%初始种群的位置
end    
v = rand(N, d);                  % 初始种群的速度
xm = x;                          % 每个个体的历史最佳位置
ym = zeros(1, d);                % 种群的历史最佳位置
fxm = zeros(N, 1);               % 每个个体的历史最佳适应度
fym = -inf;                      % 种群历史最佳适应度

% plot3(xm(:,1),xm(:,2),f(xm(:,1),xm(:,2)), 'ro');title('初始状态图');
% hold on;
% figure(2);
% mesh(x0_1, x0_2, y0);
% hold on;
% plot3(xm(:,1),xm(:,2),f(xm(:,1),xm(:,2)), 'ro');
% hold on;
%% 粒子群工作
iter = 1;
% times = 1; 
record = zeros(ger, 1);          % 记录器
while iter <= ger
     fx = f(x(:,1)) ; % 个体当前适应度   
     for i = 1:N      
        if fxm(i) < fx(i)
            fxm(i) = fx(i);     % 更新个体历史最佳适应度
            xm(i,:) = x(i,:);   % 更新个体历史最佳位置
        end 
     end
if fym < max(fxm)
        [fym, nmax] = max(fxm);   % 更新群体历史最佳适应度
        ym = xm(nmax, :);      % 更新群体历史最佳位置
 end
    v = v * c_1 + c_2 * rand *(xm - x) + c_3 * rand *(repmat(ym, N, 1) - x);% 速度更新
    % 边界速度处理
    for i=1:d 
        for j=1:N
        if  v(j,i)>vlimit(i,2)
            v(j,i)=vlimit(i,2);
        end
        if  v(j,i) < vlimit(i,1)
            v(j,i)=vlimit(i,1);
        end
        end
    end       
    x = x + v;% 位置更新
    % 边界位置处理
    for i=1:d 
        for j=1:N
        if  x(j,i)>limit(i,2)
            x(j,i)=limit(i,2);
        end
        if  x(j,i) < limit(i,1)
            x(j,i)=limit(i,1);
        end
        end
    end
    record(iter) = fym;%最大值记录
%     if times >= 10
%         cla;
%         mesh(x0_1, x0_2, y0);
%         plot3(x(:,1),x(:,2),f(x(:,1),x(:,2)), 'ro');title('状态位置变化');
%         pause(0.5);
%         times=0;
%     end
    iter = iter+1;
%     times=times+1;
end

%% 状态画图

% figure(3);plot(record);title('收敛过程')
% figure(4);
% mesh(x0_1, x0_2, y0);
% hold on;
% plot3(x(:,1),x(:,2),f(x(:,1),x(:,2)), 'ro');title('最终状态图');

% disp(['最大值：',num2str(fym)]);
% disp(['变量取值：',num2str(ym)]);
% toc
% disp(['运行时间: ',num2str(toc)]);
ff=fym;


