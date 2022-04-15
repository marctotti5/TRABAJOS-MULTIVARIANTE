function LeyGrandesNumeros(N,n)
for i=1:N
% generamos N muestras de tamaño n de una Unif[0,2]x[3,4] 
% y para cada muestra calculamos su vector de medias
   X=[2*rand(n,1) 3*ones(n,1)+rand(n,1)]; 
   m(i,:)=mean(X);
end  
% dibujamos los N vectores de medias
figure
plot(m(:,1),m(:,2),'.b','MarkerSize',10)
axis([0 2 3 4])
hold on
plot(1,3.5,'ko')
end
