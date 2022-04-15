%
%  funcion randWilks
%
%  Esta funcion genera una muestra de tamaño N de una ley Lambda de
%  Wilks con parametros p, a, b. (Atencion: a>=p).
%
function L=randWilks(p,a,b,N)
   nx=a+1; ny=b+1; % sumamos 1 a ambas, ya que la Lambda tiene distribucion \Lambda(p, a-1, b-1)
   L=zeros(N,1);
%  los vectores de medias se generan a partir de uniformes, pero
%  tambien podrian entrarse como argumentos de la funcion.
   mux=rand(1,p); muy=10*rand(1,p);
   ux=ones(nx,1); uy=ones(ny,1);
%
   for i=1:N
%  generacion de la primera muestra de normales
      Zx=randn(nx,p);
      X=ux*mux+Zx;
      A=nx*cov(X,1);
%  generacion de la segunda muestra de normales
      Zy=randn(ny,p);
      Y=uy*muy+Zy;
      B=ny*cov(Y,1);
%  obtencion de la Lambda de Wilks
      L(i,1)=det(A)/det(A+B);
   end
   histogram(L)
end   
   