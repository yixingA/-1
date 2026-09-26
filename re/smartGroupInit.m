function population = smartGroupInit(groupSize,groupDimension)
%% 读取数据
shuju=xlsread('LA数据.xlsx'); %把一天划分为24小时
pe_hrid_S=shuju(3,:); %购热价
pe_hrid_B=shuju(4,:); %售热价

x=zeros(groupSize,groupDimension);%某个体

c=rand(1,2);
while (sum(c)>=1||sum(c)<=0.4)
 c=rand(1,2);
end
 
for i=1:groupSize
    for j=1:groupDimension
        if j<25
            x(i,j)=pe_hrid_B(j)+rand()*(pe_hrid_S(j)-pe_hrid_B(j));%售电价
%         elseif   j>24&&j<49
%              x(i,j)=ph_min(j-24)+rand()*(ph_max(j-24)-ph_min(j-24));%售热价                          
        end
    end
       population(i,:) = x(i,:);
end
  

    return;
                
            
            
            
            
