function A = get01(n,t)
%t个1,n个节点，n-t个0
A=unique(perms([ones(1,t),zeros(1,n-t)]),'rows');
end

