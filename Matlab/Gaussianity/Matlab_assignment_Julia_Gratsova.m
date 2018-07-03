% Assignment : Matlab
% Programming Languages for Data Engineering AC50002
% By Julia Gratsova 130017011
%--------------------------------------------------------------------------

% 1. Generate 200 real numbers from a Gaussian distribution with mean 0
% and standard deviation 1. Generate a histogram, choosing the number of
% bins with the Freedman-Diaconis rule.
pd = makedist('Normal');
rng default;  % for reproducibility
gaus_dist = random(pd,200,1);
[N,edges] = histcounts(gaus_dist,'BinMethod','fd');
histogram_axis = [-5 5 0 50];

% Plot the histogram
histogram(gaus_dist,edges)
title('Gaussian Distribution with the Freedman-Diaconis Rule')
xlabel('Value')
ylabel('Frequency')
axis(histogram_axis);


% 2. Run a Chi-square test for Gaussianity and report the result in terms of
%answer (Yes/No) and significance level
h = chi2gof(gaus_dist);
disp(h)
if h==0
   disp('Yes, it is a Gaussian Distribution at 5% significance level')
else
   disp('No, it is not a Gaussian Distribution at 5% significance level')
end

% 3.a Eliminate 10 random numbers from the initial set and replace them with
%numbers drawn from a uniform distribution with mean 0 and standard
%deviation 3
%mean = (a+b)/2 , sigma = (b-a)/(sqrt(12)) =>(b-a)/2 = (sqrt(3)sigma)
%a = ((b+a)/2) - (b-a)/2 = mean - (sqrt(3)sigma)
%a = 0-(sqrt(3)*3)= -5.1961;  a = -b => b = 5.1961
a=-5.1961;
b=5.1961;

% Number generation from a uniform distribution
unif_dist= a + (b-a)*rand(200,1);


% 5. Number replacement of 10 samples for 10 tests, using created function
%'replace'
[test10_dist,s,cutoff]= replace(gaus_dist, unif_dist, 10, 10);

% Plot the histogram with the replaced data
figure;
histogram(test10_dist,edges)
title('Distribution with the Sample Replacement')
xlabel('Value')
ylabel('Frequency')
axis(histogram_axis);

% 3.b The function to generate a single replacement set
function [test_dist,sigma,cutoff_ind] = replace(gaussian, uniform, sample, test_runs)

    sigma = [];
    cutoff_ind=0;
    
    for i=1:test_runs
        
          for j=1:sample
            % Get new random set of numbers to be replaced from the
            % Gaussian distribution
            ind = randi(length(gaussian));
            % Replace a sample from the Gaussian distribution with a new one from
            % the Uniform distribution
            gaussian(ind) = uniform(ind);
          end
        
        % 4. Test for Gaussianity
        sigma = [sigma,std(gaussian)];
        h = chi2gof(gaussian);
        
        % Report when and if the test passes the Gaussianity check 
        if h~=0 && cutoff_ind==0
           cutoff_ind=i;
           disp(['Test run '...
               num2str(cutoff_ind) ' / 10' ' failed the Gaussianity check']) 
        end
            
                
    end
    
    test_dist = gaussian;
end




