function A = getFLELinearModel(x0)
% Here A is the stacked version of the FLE model.  If you want individual
% marker sections, then you just need to extract those 6 x 6 sections.
%#eml

N = size(x0,1);
%%demean the markers.
x = x0 - repmat(mean(x0),N,1);

%% transform the markers into principal axes.
[U L V] = svd(x);
L0 = diag(L);
% get the lambda squared values
Lambda2 = (L0).^2;

x = x*V;

A = zeros(6,6,N);
for i = 1:N
    % Row 1:
    r = 1;
    A(r,1,i) = 1/N + 2*x(i,2)^2/(Lambda2(1) + Lambda2(2)) ...
        + 2*x(i,3)^2/(Lambda2(1) + Lambda2(3)) ...
        - x(i,2)^2*Lambda2(2) / (Lambda2(2) + Lambda2(1))^2 ...
        - x(i,3)^2*Lambda2(3) / (Lambda2(3) + Lambda2(1))^2 ;
    A(r,2,i) = -2*(x(i,2)*x(i,1)/(Lambda2(2) + Lambda2(1)));
    A(r,3,i) = -2*(x(i,3)*x(i,1)/(Lambda2(3) + Lambda2(1)));
    A(r,4,i) = -1*x(i,2)^2*Lambda2(1)/(Lambda2(2) + Lambda2(1))^2;
    A(r,5,i) = -2*x(i,2)*x(i,3)*Lambda2(1)/((Lambda2(2) + Lambda2(1))*(Lambda2(3) + Lambda2(1)));
    A(r,6,i) = -1*x(i,3)^2*Lambda2(1)/(Lambda2(3) + Lambda2(1))^2;
    
    % Row 2:
    r = r+1;
    A(r,1,i) = x(i,1)*x(i,2)*Lambda2(2)/(Lambda2(2) + Lambda2(1))^2 ...
        - x(i,1)*x(i,2)/(Lambda2(2) + Lambda2(1));
    A(r,2,i) = 1/N + x(i,3)^2/(Lambda2(3) + Lambda2(1)) ...
        + x(i,3)^2/(Lambda2(3) + Lambda2(2)) ...
        + (x(i,2)^2 + x(i,1)^2)/(Lambda2(2) + Lambda2(1)) ...
        - x(i,3)^2 * Lambda2(3) / ((Lambda2(3) + Lambda2(1))*(Lambda2(3) + Lambda2(2)));
    A(r,3,i) = x(i,3) * x(i,2) * Lambda2(2)/((Lambda2(2) + Lambda2(1)) * (Lambda2(3) + Lambda2(2)))...
        - x(i,3)*x(i,2)/(Lambda2(3) + Lambda2(2));
    A(r,4,i) = -1*x(i,2)*x(i,1)/(Lambda2(2) + Lambda2(1)) ...
        + x(i,1)*x(i,2)*Lambda2(1)/(Lambda2(2) + Lambda2(1))^2;
    A(r,5,i) = x(i,1)*x(i,3)*Lambda2(1)/((Lambda2(3) + Lambda2(1))*(Lambda2(2) + Lambda2(1)))...
        -x(i,3)*x(i,1)/(Lambda2(3) + Lambda2(1));
    A(r,6,i) = 0;
    
    % Row 3:
    r = r+1;
    A(r,1,i) = -1*x(i,1)*x(i,3)/(Lambda2(3) + Lambda2(1))^2 ...
        + x(i,1)*x(i,3)*Lambda2(3)/(Lambda2(3) + Lambda2(1))^2;
    A(r,2,i) = -1*x(i,3)*x(i,2)/(Lambda2(3) + Lambda2(2)) ...
        + x(i,2)*x(i,3)*Lambda2(3)/((Lambda2(3) + Lambda2(1))*(Lambda2(3) + Lambda2(2)));
    A(r,3,i) = 1/N + x(i,2)^2/(Lambda2(2) + Lambda2(1)) ...
        + x(i,1)^2/(Lambda2(3) + Lambda2(1)) ...
        + x(i,2)^2/(Lambda2(3) + Lambda2(2)) ...
        + x(i,3)^2/(Lambda2(3) + Lambda2(1)) ...
        - x(i,2)^2*Lambda2(2)/((Lambda2(2) + Lambda2(1))*(Lambda2(3) + Lambda2(2)));
    A(r,4,i) = 0;
    A(r,5,i) = -1*x(i,2)*x(i,1)/(Lambda2(2) + Lambda2(1)) ...
        + x(i,1)*x(i,2)*Lambda2(1)/((Lambda2(2) + Lambda2(1))*(Lambda2(3) + Lambda2(1)));
    A(r,6,i) = x(i,1)*x(i,3)*Lambda2(1)/(Lambda2(3) + Lambda2(1))^2 ...
        - x(i,3)*x(i,1)/(Lambda2(3) + Lambda2(1));
    
    % Row 4:
    r = r+1;
    A(r,1,i) = -1*x(i,1)^2*Lambda2(2)/(Lambda2(2) + Lambda2(1))^2;
    A(r,2,i) = -2*x(i,2)*x(i,1)/(Lambda2(2) + Lambda2(1));
    A(r,3,i) = -2*x(i,1)*x(i,3)*Lambda2(2)/((Lambda2(3) + Lambda2(2))*(Lambda2(2) + Lambda2(1)));
    A(r,4,i) = 1/N + 2*x(i,1)^2/(Lambda2(2) + Lambda2(1)) ...
        - x(i,3)^2*Lambda2(3)/(Lambda2(3) + Lambda2(2))^2 ...
        + 2*x(i,3)^2/(Lambda2(3) + Lambda2(2)) ...
        - x(i,1)^2*Lambda2(1)/(Lambda2(2) + Lambda2(1))^2;
    A(r,5,i) = -2*x(i,3)*x(i,2)/(Lambda2(3) + Lambda2(2));
    A(r,6,i) = -1*x(i,3)^2*Lambda2(2)/(Lambda2(3) + Lambda2(2))^2;
    
    % Row 5:
    r = r+1;
    A(r,1,i) = 0;
    A(r,2,i) = x(i,1)*x(i,3)*Lambda2(3)/((Lambda2(3) + Lambda2(2))*(Lambda2(3) + Lambda2(1))) ...
        -x(i,3)*x(i,1)/(Lambda2(3) + Lambda2(1));
    A(r,3,i) = x(i,2)*x(i,1)*Lambda2(2)/((Lambda2(2) + Lambda2(1))*(Lambda2(3) + Lambda2(2))) ...
        -x(i,2)*x(i,1)/(Lambda2(2) + Lambda2(1));
    A(r,4,i) = -1*x(i,3)*x(i,2)/(Lambda2(3) + Lambda2(2)) ...
        + x(i,2)*x(i,3)*Lambda2(3)/(Lambda2(3)+Lambda2(2))^2;
    A(r,5,i) = 1/N + x(i,1)^2/(Lambda2(2) + Lambda2(1)) ...
        + x(i,2)^2/(Lambda2(3) + Lambda2(2)) ...
        + x(i,3)^2/(Lambda2(3) + Lambda2(2)) ...
        + x(i,1)^2/(Lambda2(3) + Lambda2(1)) ...
        - x(i,1)^2*Lambda2(1)/((Lambda2(2) + Lambda2(1))*(Lambda2(3) + Lambda2(1)));
    A(r,6,i) = x(i,2)*x(i,3)*Lambda2(2)/(Lambda2(3) + Lambda2(2))^2 ...
        - x(i,3)*x(i,2)/(Lambda2(3) + Lambda2(2));
    
    % Row 6:
    r = r+1;
    A(r,1,i) = -1*x(i,1)^2*Lambda2(3)/(Lambda2(3) + Lambda2(1))^2;
    A(r,2,i) = -2*x(i,1)*x(i,2)*Lambda2(3)/((Lambda2(3) + Lambda2(2))*(Lambda2(3) + Lambda2(1)));
    A(r,3,i) = -2*x(i,3)*x(i,1)/(Lambda2(3) + Lambda2(1));
    A(r,4,i) = -1*x(i,2)^2 * Lambda2(3)/(Lambda2(3) + Lambda2(2))^2;
    A(r,5,i) = -2*x(i,3)*x(i,2)/(Lambda2(3) + Lambda2(2));
    A(r,6,i) = 1/N + 2*x(i,1)^2/(Lambda2(3) + Lambda2(1)) ...
        + 2*x(i,2)^2/(Lambda2(3) + Lambda2(2)) ...
        - x(i,1)^2*Lambda2(1)/(Lambda2(3) + Lambda2(1))^2 ...
        - x(i,2)^2*Lambda2(2)/(Lambda2(3) + Lambda2(2))^2;
    A(:,:,i) = eye(6) - A(:,:,i);
end