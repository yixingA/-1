function  [t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13,t14,t15,t16,t17,t18,t19,t20,t21,t22,t23,t24] = turbine(kw,cw1,Nw,TIME)
%% 天气概率%% 天气类型
%     WType[1 2 3
%           4 5 6]
%        晴天	阴天	雨天
% 多风（多风，晴天）（多风，阴天）	（多风，雨天）
% 少风（少风，晴天）（多风，阴天）	（多风，雨天）
%
% pWeather = [
% 0.216
% 0.147
% 0.042
% 0.504
% 0.063
% 0.028
% ];
% 风机初始化
% 尺度参数
% 风机总数   风速形状参数   尺度参数
% Ratio_w=0.2;
% Nw = 10*Ratio_w;       kw= 2;   cw1 = 10;

%% 随机产生这一天的风速12，然后插值成96个
rnd1 = rand(1,12);
v = cw1 * (-log(rnd1)).^(1/kw);% 威布尔分布随机数产生风速
v1 = [];
v1 = [v(12),v(1,:)];
t = 8*(0:12);
i = 1:TIME;
v = interp1(t,v1,i,'linear');  
T=0;
belta=5;%修正系数
for i = 1:TIME
  % 每一台正常运行风机的出力，由出力模型w(v)产生
  P_w_01(i) = w(v(i));

  %故障率考虑随风速增加
  p1w = 0.05 + 0.5 * 0.005 * (v(i)-cw1);%故障概率
  p0w = 1 - p1w; %正常概率
  %正常运行风机数量（二项分布）
  n0(i) = binornd(ceil(Nw) , p0w); 
  %风机总出力上限 = 正常数量 * 每台最大出力
end
% 风电场出力
P_w_max = n0 .* P_w_01.*belta;
%% 风机24h出力值
t1=P_w_max(1);%1h时风机出力
t2=P_w_max(2);
t3=P_w_max(3);
t4=P_w_max(4);
t5=P_w_max(5);
t6=P_w_max(6);
t7=P_w_max(7);
t8=P_w_max(8);
t9=P_w_max(9);
t10=P_w_max(10);
t11=P_w_max(11);
t12=P_w_max(12);
t13=P_w_max(13);
t14=P_w_max(14);
t15=P_w_max(15);
t16=P_w_max(16);
t17=P_w_max(17);
t18=P_w_max(18);
t19=P_w_max(19);
t20=P_w_max(20);
t21=P_w_max(21);
t22=P_w_max(22);
t23=P_w_max(23);
t24=P_w_max(24);
%% 画图
% figure('name','turbine','color','w')
% plot(P_w_max);
% hold on
