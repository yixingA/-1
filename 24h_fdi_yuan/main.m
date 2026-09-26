clc;clear;close all;% 程序初始化
close all
%% 读取数据
shuju=xlsread('load数据.xlsx'); %导入优化后的电热负荷
Eload=shuju(2,:);
Hload=shuju(3,:);

T=[0	0	0	0	0.22	1.95	4.58	7.86	12.28	17.21	26.45	34.91	42.27	52.45	63.70	72.02	75.07	78.03	77.05	72.26	75.10	70.42	73.176	72.21];


t1=T(1);%1h时风机出力
t2=T(2);
t3=T(3);
t4=T(4);
t5=T(5);
t6=T(6);
t7=T(7);
t8=T(8);
t9=T(9);
t10=T(10);
t11=T(11);
t12=T(12);
t13=T(13);
t14=T(14);
t15=T(15);
t16=T(16);
t17=T(17);
t18=T(18);
t19=T(19);
t20=T(20);
t21=T(21);
t22=T(22);
t23=T(23);
t24=T(24);

% Display result
% disp(['Output power: ', num2str(t1), ' W']);
%% 设置数据存储矩阵
a=zeros(24,10);
k=zeros(24,9);
%g=zeros(24,3);

[a(1,1),a(1,2),a(1,3),a(1,4),a(1,5),a(1,6),a(1,7),a(1,8),a(1,9),a(1,10),a(1,11)]=h1(Eload(1),Hload(1),t1);
[a(2,1),a(2,2),a(2,3),a(2,4),a(2,5),a(2,6),a(2,7),a(2,8),a(2,9),a(2,10),a(2,11)]=h2(Eload(2),Hload(2),t2);
[a(3,1),a(3,2),a(3,3),a(3,4),a(3,5),a(3,6),a(3,7),a(3,8),a(3,9),a(3,10),a(3,11)]=h3(Eload(3),Hload(3),t3);
[a(4,1),a(4,2),a(4,3),a(4,4),a(4,5),a(4,6),a(4,7),a(4,8),a(4,9),a(4,10),a(4,11)]=h4(Eload(4),Hload(4),t4);
[a(5,1),a(5,2),a(5,3),a(5,4),a(5,5),a(5,6),a(5,7),a(5,8),a(5,9),a(5,10),a(5,11)]=h5(Eload(5),Hload(5),t5);
[a(6,1),a(6,2),a(6,3),a(6,4),a(6,5),a(6,6),a(6,7),a(6,8),a(6,9),a(6,10),a(6,11)]=h6(Eload(6),Hload(6),t6);
[a(7,1),a(7,2),a(7,3),a(7,4),a(7,5),a(7,6),a(7,7),a(7,8),a(7,9),a(7,10),a(7,11)]=h7(Eload(7),Hload(7),t7);
[a(8,1),a(8,2),a(8,3),a(8,4),a(8,5),a(8,6),a(8,7),a(8,8),a(8,9),a(8,10),a(8,11)]=h8(Eload(8),Hload(8),t8);
[a(9,1),a(9,2),a(9,3),a(1,4),a(9,5),a(9,6),a(9,7),a(9,8),a(9,9),a(9,10),a(9,11)]=h9(Eload(9),Hload(9),t9);
[a(10,1),a(10,2),a(10,3),a(10,4),a(10,5),a(10,6),a(10,7),a(10,8),a(10,9),a(10,10),a(10,11)]=h10(Eload(10),Hload(10),t10);
[a(11,1),a(11,2),a(11,3),a(11,4),a(11,5),a(11,6),a(11,7),a(11,8),a(11,9),a(11,10),a(11,11)]=h11(Eload(11),Hload(11),t11);
[a(12,1),a(12,2),a(12,3),a(12,4),a(12,5),a(12,6),a(12,7),a(12,8),a(12,9),a(12,10),a(12,11)]=h12(Eload(12),Hload(12),t12);
[a(13,1),a(13,2),a(13,3),a(13,4),a(13,5),a(13,6),a(13,7),a(13,8),a(13,9),a(13,10),a(13,11)]=h13(Eload(13),Hload(13),t13);
[a(14,1),a(14,2),a(14,3),a(14,4),a(14,5),a(14,6),a(14,7),a(14,8),a(14,9),a(14,10),a(14,11)]=h14(Eload(14),Hload(14),t14);
[a(15,1),a(15,2),a(15,3),a(15,4),a(15,5),a(15,6),a(15,7),a(15,8),a(15,9),a(15,10),a(15,11)]=h15(Eload(15),Hload(15),t15);
[a(16,1),a(16,2),a(16,3),a(16,4),a(16,5),a(16,6),a(16,7),a(16,8),a(16,9),a(16,10),a(16,11)]=h16(Eload(16),Hload(16),t16);
[a(17,1),a(17,2),a(17,3),a(17,4),a(17,5),a(17,6),a(17,7),a(17,8),a(17,9),a(17,10),a(17,11)]=h17(Eload(17),Hload(17),t17);
[a(18,1),a(18,2),a(18,3),a(18,4),a(18,5),a(18,6),a(18,7),a(18,8),a(18,9),a(18,10),a(18,11)]=h18(Eload(18),Hload(18),t18);
[a(19,1),a(19,2),a(19,3),a(19,4),a(19,5),a(19,6),a(19,7),a(19,8),a(19,9),a(19,10),a(19,11)]=h19(Eload(19),Hload(19),t19);
[a(20,1),a(20,2),a(20,3),a(20,4),a(20,5),a(20,6),a(20,7),a(20,8),a(20,9),a(20,10),a(20,11)]=h20(Eload(20),Hload(20),t20);
[a(21,1),a(21,2),a(21,3),a(21,4),a(21,5),a(21,6),a(21,7),a(21,8),a(21,9),a(21,10),a(21,11)]=h21(Eload(21),Hload(21),t21);
[a(22,1),a(22,2),a(22,3),a(22,4),a(22,5),a(22,6),a(22,7),a(22,8),a(22,9),a(22,10),a(22,11)]=h22(Eload(22),Hload(22),t22);
[a(23,1),a(23,2),a(23,3),a(23,4),a(23,5),a(23,6),a(23,7),a(23,8),a(23,9),a(23,10),a(23,11)]=h23(Eload(23),Hload(23),t23);
[a(24,1),a(24,2),a(24,3),a(24,4),a(24,5),a(24,6),a(24,7),a(24,8),a(24,9),a(24,10),a(24,11)]=h24(Eload(24),Hload(24),t24);




for i=1:1:9
    for l=1:24
    k(l,i)=a(l,i);
    end
end

% for l=1:24
%     g(l,1)=a(l,13);
%     g(l,2)=a(l,14);
%     g(l,3)=a(l,15);
% end







%% 调度画图

% figure%上下子图
% 
% bar([k(:,1),k(:,2),k(:,3),k(:,4),k(:,5),k(:,6),k(:,7),k(:,8),k(:,9)]);
% %k(:,1),k(:,1),k(:,1),k(:,1),k(:,1),k(:,1),k(:,1),k(:,1),k(:,1),k(:,1),k(:,1),k(:,1),k(:,1),k(:,1),k(:,1),k(:,1),
% % ylim([-100 1500])
% % yticks(-100:200:1500)
% colororder('default')
% hold on
% xlim([1 24])
% xticks(1:1:24)%x坐标
% xticklabels({'0:00','1:00','2:00','3:00','4:00','5:00','6:00','7:00','8:00','9:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00','19:00','20:00','21:00','22:00','23:00'});
% ylabel('Power/KW') 
% xlabel('Time/h') 
% % set(gca,'YLim',[0 300]);
% set(gca,'FontSize',10,'Fontname', 'Arial');
% lgd=legend('EOU1', 'EOU2','EOU3','DG','CHP-P','CHP-H','P2G','DH', 'HOU8','HOU9','NumColumns',4);%图例(TH表示燃煤火电厂，boiler表示燃煤锅炉)
% set(lgd,'FontName','Times New Roman','FontSize',11,'FontWeight','normal','FontSize',5);
% legend('boxoff') 


% figure(13)%上下子图
% subplot(2,1,1)
% yyaxis left
% bar([k(:,1),k(:,2),k(:,3),k(:,4),k(:,5),k(:,6),k(:,7),k(:,8),k(:,9),k(:,10),k(:,11),k(:,12)]);
% %k(:,1),k(:,1),k(:,1),k(:,1),k(:,1),k(:,1),k(:,1),k(:,1),k(:,1),k(:,1),k(:,1),k(:,1),k(:,1),k(:,1),k(:,1),k(:,1),
% ylim([-100 1500])
% yticks(-100:200:1500)
% colororder('default')
% hold on
% 
% yyaxis right
% plot(a(:,4),'-','LineWidth',1.5,'Marker','*','MarkerSize',5,'Color','g');
% colororder('default')
% xticklabels({'0:00','1:00','2:00','3:00','4:00','5:00','6:00','7:00','8:00','9:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00','19:00','20:00','21:00','22:00','23:00'});
% set(gca,'YLim',[0 1200]);
% ylabel('Power/KW') 
% xlabel('Time/h') 
% set(gca,'FontSize',10,'Fontname', 'Arial');
% hold on
% 
% % plot(a(:,8),'-','LineWidth',1.5,'Marker','*','MarkerSize',5,'Color','r');
% colororder('default')
% 
% ylabel('Power/KW') 
% xlabel('Time/h') 
% set(gca,'FontSize',10,'Fontname', 'Arial');
% hold on
% ylim([0 250])
% yticks(0:50:250)
% xlim([1 24])
% xticks(1:1:24)%x坐标
% xticklabels({'0:00','1:00','2:00','3:00','4:00','5:00','6:00','7:00','8:00','9:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00','19:00','20:00','21:00','22:00','23:00'});
% ylabel('Power/KW') 
% xlabel('Time/h') 
% 
% % set(gca,'YLim',[0 300]);
% set(gca,'FontSize',10,'Fontname', 'Arial');
% lgd=legend('POD1', 'POD2','POD3','DG','CHP-P','CHP-H','P2G','DH', 'HOD8','HOD9','GW1','GW2','UMCE', 'UMCH','NumColumns',4);%图例(TH表示燃煤火电厂，boiler表示燃煤锅炉)
% set(lgd,'FontName','Times New Roman','FontSize',11,'FontWeight','normal','FontSize',5);
% legend('boxoff') 
% 
% 
% 
% subplot(2,1,2)
% for n=1:3
% plot(g(:,n),'-','LineWidth',1.5,'Marker','*','MarkerSize',5);
% colororder('default')
%  xlim([1 24])
% xticks(1:1:24)%x坐标
% xticklabels({'0:00','1:00','2:00','3:00','4:00','5:00','6:00','7:00','8:00','9:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00','19:00','20:00','21:00','22:00','23:00'});
% set(gca,'YLim',[0 1200]);
% ylabel('Power/KW') 
% xlabel('Time/h') 
% set(gca,'FontSize',10,'Fontname', 'Arial');
% hold on
% end
% 
% lgd1=legend('∑P', '∑H','∑G');%图例(TH表示燃煤火电厂，boiler表示燃煤锅炉)
% set(lgd1,'FontName','Times New Roman','FontSize',11,'FontWeight','normal');
% legend('boxoff') 

 
% figure%%柱状图双坐标
% yyaxis left
% 
% bar(k(),1);
% colororder('default')
% set(gca,'XTick',0:25);%x坐标
% set(gca,'XLim',[0 25]);
% set(gca,'YLim',[0 300]);
% % for j=1:12
% % plot(k(:,j));
% % ylabel('Power/KW') 
% % xlabel('Time/h') 
% % set(gca,'FontSize',15,'Fontname', 'Arial');
% % end
% hold on
% 
% 
% yyaxis right
% for n=1:3
% plot(g(:,n),'-','LineWidth',2,'Marker','o','MarkerSize',5);
% end
% colororder('default')
% set(gca,'XTick',0:25);%x坐标
% set(gca,'XLim',[0 25]);
% set(gca,'YLim',[200 800]);
% ylabel('Power/KW') 
% xlabel('Time/h') 
% set(gca,'FontSize',15,'Fontname', 'Arial');
% legend('PV', 'W','TH1','TH2','CHP-P','CHP-H','boiler1','boiler2','load-p','load-h','load-g')%图例(TH表示燃煤火电厂，boiler表示燃煤锅炉)
% legend('boxoff') 


% figure%%柱状单坐标
% bar(k(),0.5,'LineWidth',0.5,'LineStyle','--');
% 
% colororder('default')
% set(gca,'XTick',0:25);%x坐标
% set(gca,'XLim',[0 25]);
% set(gca,'YLim',[0 300]);
% hold on
% 
% for n=1:3
% plot(g(:,n),'-','LineWidth',2,'Marker','o','MarkerSize',5);
% colororder('default')
% set(gca,'XTick',0:25);%x坐标
% set(gca,'XLim',[0 25]);
% set(gca,'YLim',[200 800]);
% ylabel('Power/KW') 
% xlabel('Time/h') 
% set(gca,'FontSize',15,'Fontname', 'Arial');
% hold on
% end
% legend('POD1', 'POD2','POD3','POD4','CHP-P','CHP-H','P2G','HOD7', 'HOD8','HOD9','GW1','GW2','∑P', '∑H','∑G')%图例(TH表示燃煤火电厂，boiler表示燃煤锅炉)
% legend('boxoff') 
% figure%柱状左坐标，线形图右坐标
% yyaxis left
% bar(k(),0.5,'LineWidth',0.5,'LineStyle','--');
% 
% colororder('default')
% xticks(1:1:24)%x坐标
% xticklabels({'0:00','1:00','2:00','3:00','4:00','5:00','6:00','7:00','8:00','9:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00','19:00','20:00','21:00','22:00','23:00'});
% % set(gca,'YLim',[0 300]);
% hold on
% 
% yyaxis right
% for n=1:3
% plot(g(:,n),'-','LineWidth',2,'Marker','o','MarkerSize',5);
% colororder('default')
%  xlim([1 24])
% xticks(1:1:24)%x坐标
% xticklabels({'0:00','1:00','2:00','3:00','4:00','5:00','6:00','7:00','8:00','9:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00','19:00','20:00','21:00','22:00','23:00'});
% set(gca,'YLim',[0 1200]);
% ylabel('Power/KW') 
% xlabel('Time/h') 
% set(gca,'FontSize',15,'Fontname', 'Arial');
% hold on
% end
% lgd2=legend('POD1', 'POD2','POD3','POD4','CHP-P','CHP-H','P2G','HOD7', 'HOD8','HOD9','GW1','GW2','∑P', '∑H','∑G')%图例(TH表示燃煤火电厂，boiler表示燃煤锅炉)
% set(lgd2,'FontName','Times New Roman','FontSize',11,'FontWeight','normal','FontSize',5);
% legend('boxoff') 




% figure%%线状图左右坐标轴
% yyaxis left
% for j=1:12
% plot(a(:,j),'-','LineWidth',1,'Marker','.','MarkerSize',13);
% colororder('default')
% xlim([1 24])
% xticks(1:1:24)%x坐标
% xticklabels({'0:00','1:00','2:00','3:00','4:00','5:00','6:00','7:00','8:00','9:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00','19:00','20:00','21:00','22:00','23:00'})
% hold on
% end
% yyaxis right
% for j=13:15
% plot(a(:,j),'-','LineWidth',2,'Marker','o','MarkerSize',5);
% xlim([1 24])
% xticks(1:1:24)%x坐标
% xticklabels({'0:00','1:00','2:00','3:00','4:00','5:00','6:00','7:00','8:00','9:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00','19:00','20:00','21:00','22:00','23:00'})
% colororder('default')
% hold on
% end
% legend('POD1', 'POD2','POD3','POD4','CHP-P','CHP-H','P2G','HOD7', 'HOD8','HOD9','GW1','GW2','∑P', '∑H','∑G')
% legend('boxoff')
% figure%%单坐标轴，总负荷在上面
% for j=1:12
% plot(a(:,j),'-','LineWidth',1,'Marker','.','MarkerSize',13);
% colororder('default')
% xlim([1 24])
% xticks(1:1:24)%x坐标
% xticklabels({'0:00','1:00','2:00','3:00','4:00','5:00','6:00','7:00','8:00','9:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00','19:00','20:00','21:00','22:00','23:00'})
% hold on
% end
% for j=13:15
% plot(a(:,j),'--','LineWidth',2,'Marker','o','MarkerSize',6);
% colororder('default')
% xlim([1 24])
% xticks(1:1:24)%x坐标
% xticklabels({'0:00','1:00','2:00','3:00','4:00','5:00','6:00','7:00','8:00','9:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00','19:00','20:00','21:00','22:00','23:00'})
% hold on
% end
% legend('POD1', 'POD2','POD3','POD4','CHP-P','CHP-H','P2G','HOD7', 'HOD8','HOD9','GW1','GW2','∑P', '∑H','∑G')
%  legend('boxoff')
