function fy = Pacejka4_lateral(P,X)

D = (P(1) + P(2)/1000*X(:,2)).*X(:,2);
fy = D.*sin(P(4)*atan(P(3).*X(:,1)));

end
