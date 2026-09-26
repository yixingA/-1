function f = minf2(x,y,M)
 
f = f2(x,y) + M*( (max(0,-1*g1(x,y))).^2  + (max(0,-1*g2(x,y))).^2  );