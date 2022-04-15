function [npcf,Fratioreal,Fratioperm]=permsvd(x,flagprep,npermmax,flagproj,conf)

% PCA component selection by permutation testing. If using this software please cite:
% R. Vitale, J.A. Westerhuis, T. Naes, A.K. Smilde, O.E. de Noord, A.
% Ferrer, Selecting the number of components in Principal Component
% Analysis by permutation testing, Journal of Chemometrics, 2017 (31),
% e2937
%
% npcf = permsvd(x) % minimum call
% [npcf,Fratioreal,Fratioperm]=permsvd(x,flagprep,npermmax,flagproj,conf)
% % complete call
% 
%
% INPUTS:
%
% x: [NxM] original data
%
% flagprep: [1x1] 0 for no preprocessing on x; 1 for mean-centering; 2 for
% auto-scaling. Default: 2
%
% npermmax: [1x1] maximum number of permutations. Default: 300
%
% flagproj: [1x1] orthogonalisation approach. 1 for P1; 2 for P2; 3 for P3;
% 4 for P4; 5 for P5. Default: 3
%
% conf: [1x1] confidence level for the test (e.g. 95 for 95%). Default: 95
%
%
% OUTPUTS:
%
% npcf: [1x1] estimated number of PCA factors
%
% Fratioreal: [1xrank(x)] F statistic values for all the extractable
% components of x
%
% Fratioperm: [(npermmax)x(npcf+1)] empirical null-distributions of the
% F statistic for all the significant components plus one.
%
%
% EXAMPLE OF USE: Random data
%
% x = simuleMV(20,10,8);
% npcf = permsvd(x,2,300,3,95);
%
%
% codified by: Raffaele Vitale (rvitale86@gmail.com)
% last modification: 29/Aug/2018
%
% Copyright (C) 2016  Universitat Politecnica de Valencia, Valencia
% Copyright (C) 2016  Raffaele Vitale
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

%% Parameter checking and initialisation

if nargin<1
    error('Error in the number of arguments. Type ''help permsvd'' for more info.')
end
if nargin<2 || isempty(flagprep)
    flagprep=2;
end
if nargin<3 || isempty(npermmax)
    npermmax=300;
end
if nargin<4 || isempty(flagproj)
    flagproj=3;
end
if nargin<5 || isempty (conf)
    conf=95;
end

%% Main code

% Preprocessing

if flagprep==0
    x_p=x;
elseif flagprep==1
    x_p=x-repmat(mean(x),size(x,1),1);
elseif flagprep==2
    x_p=(x-repmat(mean(x),size(x,1),1))./repmat(std(x),size(x,1),1);
end

% Singular Value Decomposition of x

[u,s,v]=svd(x_p);
t=u*s;
eigreal=diag(s.^2)';

rkeff=rank(x_p);
for npc=1:rkeff
    Fratioreal(npc)=(eigreal(npc))/(sum(eigreal(npc:rkeff)));  
end

% Test for the first component

for nperm=1:npermmax
    
    for nvar=1:size(x_p,2)
        xperm(:,nvar)=x_p(randperm(size(x_p,1)),nvar);
    end
    
    [~,sperm,~]=svds(xperm,1);
    Fratioperm(nperm,1)=sperm.^2/sum(sum(xperm.^2));
    
end

% Test for the a-th component (a>1)

while  size(Fratioperm,2)<size(Fratioreal,2) && Fratioreal(size(Fratioperm,2))>prctile(Fratioperm(:,end),conf)

    e=x_p-t(:,1:size(Fratioperm,2))*v(:,1:size(Fratioperm,2))';
    
    for nperm=1:npermmax
    
        for nvar=1:size(e,2)
            eperm(:,nvar)=e(randperm(size(e,1)),nvar);
        end
        
        switch flagproj
            
            case 1
                epermorth=u(:,size(Fratioperm,2)+1:end)*u(:,size(Fratioperm,2)+1:end)'*eperm*v(:,size(Fratioperm,2)+1:end)*v(:,size(Fratioperm,2)+1:end)';
                
            case 2
                if size(x,1)<size(x,2)
                epermorth=eperm-u(:,1:size(Fratioperm,2))*u(:,1:size(Fratioperm,2))'*eperm;
                else
                epermorth=eperm-eperm*v(:,1:size(Fratioperm,2))*v(:,1:size(Fratioperm,2))';
                end
                
            case 3
                if size(x,1)<size(x,2)
                [ures,~,~]=svd(eperm);
                epermorth=eperm-ures(:,1:size(Fratioperm,2))*ures(:,1:size(Fratioperm,2))'*eperm;
                else
                [~,~,vres]=svd(eperm);
                epermorth=eperm-eperm*vres(:,1:size(Fratioperm,2))*vres(:,1:size(Fratioperm,2))';
                end
                
            case 4
                if size(x,1)<size(x,2)
                epermorth=eperm-u(:,rkeff:-1:rkeff-size(Fratioperm,2)+1)*u(:,rkeff:-1:rkeff-size(Fratioperm,2)+1)'*eperm;
                else
                epermorth=eperm-eperm*v(:,rkeff:-1:rkeff-size(Fratioperm,2)+1)*v(:,rkeff:-1:rkeff-size(Fratioperm,2)+1)';
                end
                
            case 5
                if size(x,1)<size(x,2)
                [ures,~,~]=svd(eperm);
                epermorth=eperm-ures(:,rank(eperm):-1:rank(eperm)-size(Fratioperm,2)+1)*ures(:,rank(eperm):-1:rank(eperm)-size(Fratioperm,2)+1)'*eperm;
                else
                [~,~,vres]=svd(eperm);
                epermorth=eperm-eperm*vres(:,rank(eperm):-1:rank(eperm)-size(Fratioperm,2)+1)*vres(:,rank(eperm):-1:rank(eperm)-size(Fratioperm,2)+1)';
                end
        
        end
        
        [~,sresperm,~]=svds(epermorth,1);
        Fratioperm_tmp(nperm,1)=sresperm.^2/sum(sum(epermorth.^2));
        
    end
    
    Fratioperm=[Fratioperm Fratioperm_tmp];
    
end

npcf=size(Fratioperm,2)-1;

%% Output display

disp(['The number of significant components is ',num2str(npcf)]);