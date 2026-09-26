function [pv1,pv2,pv3,pv4,pv5,pv6,pv7,pv8,pv9,pv10,pv11,pv12,pv13,pv14,pv15,pv16,pv17,pv18,pv19,pv20,pv21,pv22,pv23,pv24] = PV_new(TIME,Ratio_p,M,Q,P,PV,n,r,delt,fai,S,gama)
%PV(NEW) 此处显示有关此函数的摘要
%   此处显示详细说明
TIME=24;
%% 光伏参数
Ratio_p=1;
M = 1 *Ratio_p; %全部光伏板数
Q = 0.001;%光伏板的不可用率
P = 1-Q;%光伏板的可用率
PV=0;
n=160; %日期
r=1+0.034*cos(2*pi*n/365);
delt=23.45*sin(2*pi*(284+n)/365)/180*pi;
fai=23/180*pi;%纬度
S=0/180*pi;   %倾角
gama=0/180*pi;  %方位角

% t=(-pi):0.01:(pi);
% cosct=sin(delt)*(sin(fai)*cos(S)-sin(S)*cos(fai)*cos(gama))+sin(S)*sin(gama)...
%     *cos(delt)*sin(t)+cos(delt)*cos(t)*(cos(fai)*cos(S)+sin(fai)*sin(S)*cos(gama));
% I=r*cosct;
% for i=1:length(t)
%     if I(i)<0
%         I(i)=0;
%     end
% end
% % plot((t/pi+1)*12,I)
% % hold on

t =(-pi):pi/TIME*2:(pi);
t = t(2:end);
cosct=sin(delt)*(sin(fai)*cos(S)-sin(S)*cos(fai)*cos(gama))+sin(S)*sin(gama)...
    *cos(delt)*sin(t)+cos(delt)*cos(t)*(cos(fai)*cos(S)+sin(fai)*sin(S)*cos(gama));
I=r*cosct;

for i=1: TIME
    if I(i)<0
        I(i)=0;
    end
end
% plot((t/pi+1)*12,I,'.')
% hold off
I=I*1353;


miu=0.7;%均值
cigma=0.05;%标准差
a=miu*(miu*(1-miu)/cigma^2-1);%两个参数
b=(1-miu)*(miu*(1-miu)/cigma^2-1);


% 有什么用....
Tamax=29; %该日最高温度
Tamin=15; %最低温度
Ta=(Tamax+Tamin)/2+(Tamax-Tamin)/2*sin(t+pi/4);

I0=1000;%测试条件下的
alp=-0.0045;%光伏功率温度系数
T0=25;%基准温度


%% 全部光伏板数（给定比率）
M = 20 *Ratio_p;
% 光伏故障概率 修复时间10天=1/36 a
q = 0.00013/36.5;
q2 = 0.253/36.5;
q3 = 0.046/36.5;
q4 = 0.015/36.5;
%光伏板的可用率
Pr = (1-q^M)*(1-q2)*(1-q3)*(1-q4);
% 光照因素
MIU   = [ 0.808  0.322  0.239];
SIGMA = [0.175  0.216  0.214];
% 温度因素
Tmax = [30 25 20];
Tmin = [20 18 15];

%% 光伏故障和出力的模型（参数由coefficiency决定: M, P, I, a, b）

belta=5;%修正系数

x=betarnd(a,b,1,length(I));

I_real=x.*I;%光强修正

Tt=Ta+I_real.*(Ta-20)/800;%温度修正

m = binornd(ceil(M),Pr,1,TIME);  %没有坏的光伏板数比例

P_p_max =belta.* m .* I_real.*(1+alp*(Tt-T0))/I0; %最大出力
% for i=1:TIME
%  PV=PV+P_p_max(i);24h光伏总出力
% end
%% 24h 光照出力值
pv1=P_p_max(1);
pv2=P_p_max(2);
pv3=P_p_max(3);
pv4=P_p_max(4);
pv5=P_p_max(5);
pv6=P_p_max(6);
pv7=P_p_max(7);
pv8=P_p_max(8);
pv9=P_p_max(9);
pv10=P_p_max(10);
pv11=P_p_max(11);
pv12=P_p_max(12);
pv13=P_p_max(13);
pv14=P_p_max(14);
pv15=P_p_max(15);
pv16=P_p_max(16);
pv17=P_p_max(17);
pv18=P_p_max(18);
pv19=P_p_max(19);
pv20=P_p_max(20);
pv21=P_p_max(21);
pv22=P_p_max(22);
pv23=P_p_max(23);
pv24=P_p_max(24);


%% 画图
% figure('name','PV_new','color','w') 
% plot(P_p_max);
% hold on

