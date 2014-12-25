function [Ws, lambdas, Cps, last_break, active_set] = lars_regression(Y, X, maxcomps, positive, noise)

% run LARS for regression problems with LASSO penalty, with optional positivity constraints
% Author: Ari Pakman


% Input Parameters:
%   Y:           Y(:,t) is the observed data at time t
%   X:           the regresion problem is Y=X*W + noise
%   maxcomps:    maximum number of active components to allow
%   positive:    a flag to enforce positivity
%   noise:       the noise of the observation equation. if it is not
%                provided as an argument, the noise is computed from the
%                variance at the end point of the algorithm. The noise is
%                used in the computation of the Cp criterion.


% Output Parameters:
%   Ws: weights from each iteration
%   lambdas: lambda values at each iteration
%   Cps: C_p estimates
%   last_break:     last_break(m) == n means that the last break with m non-zero weights is at Ws(:,:,n)



verbose=false;
%verbose=true;

k=1;

T = size(Y,2); % # of time steps
N = size(X,2); % # of compartments



W = zeros(N,k);
active_set = zeros(N,k);
visited_set = zeros(N,k);

lambdas = [];
Cps = [];

Ws=zeros(size(W,1),size(W,2),maxcomps);  % Just preallocation. Ws may end with more or less than maxcomp columns


%% 

r = X'*Y(:);         % N-dim vector
M = -X'*X;            % N x N matrix 

%% begin main loop

%fprintf('\n i = ');
i = 1;

while 1
    
  %  fprintf('%d,',i);
    
    %% calculate new gradient component if necessary

    if i>1 && new && visited_set(new) ==0         

        visited_set(new) =1;    % remember this direction was computed

    end

    %% Compute full gradient of Q 

    dQ = r + M*W;
        
    %% Compute new W
    if i == 1
        if positive
            dQa = dQ;
        else
            dQa = abs(dQ);
        end
        [lambda, new] = max(dQa(:));
    
        if lambda < 0
            disp('All negative directions!')
            break
        end
        
    else

        % calculate vector to travel along 
         
%        disp('calc velocity')
        
        [avec, gamma_plus, gamma_minus] = calcAvec(new, dQ, W, lambda, active_set, M, positive);        
        
        % calculate time of travel and next new direction 
                
        if new==0                               % if we just dropped a direction we don't allow it to emerge 
            if dropped_sign == 1                % with the same sign
                gamma_plus(dropped) = inf;
            else
                gamma_minus(dropped) = inf;
            end 
        end
                   

        gamma_plus(active_set == 1) = inf;       % don't consider active components 
        gamma_plus(gamma_plus <= 0) = inf;       % or components outside the range [0, lambda]
        gamma_plus(gamma_plus> lambda) =inf;
        [gp_min, gp_min_ind] = min(gamma_plus(:));


        if positive
            gm_min = inf;                         % don't consider new directions that would grow negative
        else
            gamma_minus(active_set == 1) = inf;            
            gamma_minus(gamma_minus> lambda) =inf;
            gamma_minus(gamma_minus <= 0) = inf;                
            [gm_min, gm_min_ind] = min(gamma_minus(:));

        end

        [g_min, which] = min([gp_min, gm_min]);

        if g_min == inf;               % if there are no possible new components, try move to the end
            g_min = lambda;            % This happens when all the components are already active or, if positive==1, when there are no new positive directions 
        end
                 
        

        % LARS check  (is g_min*avec too large?)
        gamma_zero = -W(active_set == 1)  ./ avec;
        gamma_zero_full = zeros(N,k);
        gamma_zero_full(active_set == 1) = gamma_zero;
        gamma_zero_full(gamma_zero_full <= 0) = inf;
        [gz_min, gz_min_ind] = min(gamma_zero_full(:));
        
        if gz_min < g_min            
            if verbose
                fprintf('DROPPING active weight: %d.\n', gz_min_ind)
            end
            active_set(gz_min_ind) = 0;
            dropped = gz_min_ind;
            dropped_sign = sign(W(dropped));
            W(gz_min_ind) = 0;
            avec = avec(gamma_zero ~= gz_min);
            g_min = gz_min;
            new = 0;
            
        elseif g_min < lambda
            if  which == 1
                new = gp_min_ind;
                if verbose
                    fprintf('new positive component: %d.\n', new)
                end
            else
                new = gm_min_ind;
		if verbose
                    fprintf('new negative component: %d.\n', new)
		end
            end
        end
                               
        W(active_set == 1) = W(active_set == 1) + g_min * avec;
        
        if positive
            if any (W<0)
                min(W)
                error('negative W component');
            end
        end
        
        lambda = lambda - g_min;
    end

    
  
% Compute error for Cp estimates
Cps(i) = sum((Y(:) -X*W).^2);

%%  Update weights and lambdas 
        
    lambdas(i) = lambda;
    Ws(:,:,i)=W;

%% Check finishing conditions    
    
    if lambda ==0 || (new && sum(active_set(:)) == maxcomps)        
        if verbose
            fprintf('end. \n');
        end
        
        break
    end

%%   
    if new        
        active_set(new) = 1;
    end

    
    i = i + 1;
end
%% end main loop 

%% final calculation of mus

Ws= Ws(:,:,1:length(lambdas));


last_break=[];              
for j = 2:i                          % start from i==2 to avoid the case of activesum == 0 
    f = find(Ws(:,:,j));
    activesum = length(f);
    last_break(activesum)= j;
end


max_dof = min(length(last_break), maxcomps);        % maximum number of components

Cs = [];

if exist('noise', 'var')
    sigma2 = noise; 
else
    sigma2 = var(X*W -Y(:));
end
    
for j = 1:max_dof
    Cs(j) = Cps(last_break(j)) + 2* j* sigma2;    
end


Cps = Cs; %/(size(Y,1)*T);




end

%%%%%%%%%% begin auxiliary functions %%%%%%%%%%


%%
function [avec, gamma_plus, gamma_minus] = calcAvec(new, dQ, W, lambda, active_set, M, positive)

[r,c] = find(active_set);
Mm = -M(r,r);


Mm=(Mm + Mm')/2;

% verify that there is no numerical instability 
eigMm = eig(Mm);
if any(eigMm < 0)
    min(eigMm)
    error('The matrix Mm has negative eigenvalues')  
end


b = sign(W);
if new
    b(new) = sign(dQ(new));
end
b = b(active_set == 1);

avec = Mm\b;

if positive 
    if new 
        in = sum(active_set(1:new));
        if avec(in) <0
            new
            error('new component of a is negative')
        end
    end
end

    

one_vec = ones(size(W));

dQa = zeros(size(W));
for j=1:length(r)
    dQa = dQa + avec(j)*M(:, r(j));
end

gamma_plus = (lambda - dQ)./(one_vec + dQa);
gamma_minus = (lambda + dQ)./(one_vec - dQa);

end


