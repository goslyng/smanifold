%  smanifold, Copyright (C) 2009-2012, Stefan Sommer (sommer@diku.dk)
%  https://github.com/nefan/smanifold.git
% 
%  This file is part of smanifold.
% 
%  smanifold is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation, either version 3 of the License, or
%  (at your option) any later version.
% 
%  smanifold is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
% 
%  You should have received a copy of the GNU General Public License
%  along with smanifold.  If not, see <http://www.gnu.org/licenses/>.
%  

function [g,Js,gs,Vvp,rs] = exactHCAFgrad(data,datak,v,ys,ws,Logxys,rs,Vk,B,k,mode,Fgrad,gradTol,debug)
%
% evaluate projection gradients
%

if debug
    global timeGrad;
end

N = size(data,2);

Vvp = null([Vk v]');
gs = []; % mainly for visualization
manifold.dim = size(B,2);
g = zeros(manifold.dim,1);        
Js = zeros(manifold.dim*N,manifold.dim-(k+1));   
% debug
if debug
    tic
end   
results = cell(1,N);
parfor j = 1:N
    x = data(:,j);
    y = ys(:,j);            
    w = ws(:,j);            
    Logxy = Logxys(:,j);
    results{j} = Fgrad(x,datak(:,j),y,w,Logxy,Vk,v,Vvp,gradTol);
end

for j = 1:N
    res = results{j};

    Js(1+(j-1)*manifold.dim:j*manifold.dim,:) = res{1}; % Bx, Vvp

	gs(:,j) = Vvp*res{2}; % gradient in B
    g = g+gs(:,j); % accumulated gradient
            
    Bx = res{3};                
    rs(:,j) = Bx'*Logxys(:,j); % Bx
end
% debug
if debug
    timeGrad = timeGrad + toc;
end   

Js = Js/N;
g = g/N;
