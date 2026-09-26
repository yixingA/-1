function f = maxf1_2D(x0,x1,N)
global ind
global Cm
global X0
global X00
global t
global Ce
global numnodes
global branch_num
global Pl_b
global G
global w
global price_day_ahead

pt=1.2*price_day_ahead;
Lambda_P=zeros(1,branch_num);
% tt = zeros(1,100);
% z0=ones(N,1)*ind(1);
% z1=ones(N,1)*ind(2);
f=zeros(N,1);
Ps=zeros(1,numnodes);
%% 两个节点受攻击的矩阵数置换
for i=1:N
%     tic;
    [z0,Pc00,cost0,P0] = normalsolve(ind(1));%x1是节点LA运营后的负荷向量
    [z1,Pc11,cost1,P1] = normalsolve(ind(2));%x1是节点LA运营后的负荷向量
    [y0,Pca0,costa0,P_C0] = innersolve(x0(i),z0,Pc00,ind(1),P0);%x1是节点LA运营后的负荷向量
    [y1,Pca1,costa1,P_C1] = innersolve(x1(i),z1,Pc11,ind(2),P1);%x1是节点LA运营后的负荷向量
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
    for k=1:branch_num %对电力系统的损失
        Pl_d=0;%初始化线路功率增量
        o=0;
        for j=ind
            switch j
                case 1
                    o=4;
                case 2
                    o=7;
                case 3
                    o=9;
                case 4
                    o=11;
                case 5
                    o=14;
                case 6
                    o=19;
                case 7
                    o=23;
                case 8
                    o=27;
            end
                    Pl_d = Pl_d+ G(k,o)*Pn_d(j);%节点i增量对线路k的功率增量的影响
        end
        Lambda_P(k) = (Pl_d)/Pl_b(k);%线路k的功率变化率为所有节点对其的增量和除以该点基线负荷
    end
    Lambda=sum(Lambda_P);%t时段的总波动率
    for k=ind %对LA经济损失
        Ps(k) = Pn_d(k)-Pn_b(k)*1.3;%节点LA响应电量-电网下达响应电量最大阈值（电网下达中心*1.3）
        if(Ps(k)<=0)
            Ps(k)=0;
        else
        end
        ppen = (1+Ps(k)/Pn_b(k))*Ps(k);%违约金函数
        R = R+ppen*Ps(k)+(pt(k)-Ce(k))*Pn_d(k);
        Cz = Cz+Cm(k);
    end
    f(i) = (w*Lambda+(1-w)*R/1000)/Cz;
%     f(i) = (w*Lambda+(1-w)*R/1000);
%     else
%     end
end



