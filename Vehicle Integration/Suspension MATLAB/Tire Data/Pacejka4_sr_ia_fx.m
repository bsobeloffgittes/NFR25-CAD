function fx = Pacejka4_sr_ia_fx(P,X)

D = (P(1) + P(2)/1000*X(:,2)).*X(:,2);
fx = D.*sin(P(4)*atan(P(3).*X(:,1)));

end
