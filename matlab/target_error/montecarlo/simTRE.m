function [probeTipError, probeTipMeas, refTipError, refTipMeas,...
    combinedTipError, combinedTipMeas]...
    = simTRE(Sigma, N, probeRig, probeTrue, refRig, refTrue, varargin)

%**************************************************************************
% Simulate the Target Registration Error using Monte Carlo
%
%       Written by Andrew Wiles, May 23, 2007
%           - Modified March 21, 2008 to add conditions for non-homogenous
%           FLE models.
%
%**************************************************************************

% default parameters.
regMethod = 'IsotropicSVD';
verbose = 0;
bWeight = 0;

if(nargin > 6)
    nVarArgs = length(varargin);
    i = 1;
    while( i <= nVarArgs)
        if( strcmp(varargin{i},'RegistrationMethod'))
            i=i+1;
            regMethod = varargin{i};
            if( strcmp(regMethod, 'IsotropicSVD') )
                bWeight = 0;
            elseif( strcmp(regMethod, 'AnisotropicIterative') )
                bWeight = 1;
            end
        elseif( strcmp(varargin{i}, 'Verbose'))
            verbose = 1;
        else
            error('Unknown parameter: %s', varargin{i})
        end
    end
end

% check whether the FLE model is homogenous or not.
if( ndims(Sigma) == 3 )
    bHomogenous = 0;
elseif( ismatrix(Sigma))
    bHomogenous = 1;
else
    error('The FLE matrix has incorrect dimensions.');
end

%set-up the paramters.
nProbeMarkers = size(probeRig.mrk,1);
probeTipMeas = zeros(N,3);
probeTipError = zeros(N,3);

if( bHomogenous )
    [V,D] = eig(Sigma); % this is needed to create error values.
else
    V = zeros(3,3,nProbeMarkers);
    D = zeros(3,3,nProbeMarkers);
    if( bWeight )
        W = zeros(3,3,nProbeMarkers);
    end
    for i = 1:nProbeMarkers
        [V(:,:,i),D(:,:,i)] = eig(Sigma(:,:,i));
        if( bWeight )
            W(:,:,i) = V(:,:,i) * inv(sqrt(D(:,:,i))) * V(:,:,i)';
        end
    end
end

if(nargin > 4)
    refTipMeas = zeros(N,3);
    refTipError = zeros(N, 3);
    nRefMarkers = size(refRig.mrk,1);
    combinedTipMeas = zeros(N,3);
    combinedTipError = zeros(N, 3);
end


% what is the true tip position?
probeXfrm = getRigidXfrmSVD(probeRig.mrk, probeTrue.mrk);
probeTip = (probeXfrm.rot * probeRig.tip')' + probeXfrm.pos;
if(nargin > 4)
    refXfrm = getRigidXfrmSVD(refRig.mrk, refTrue.mrk);
    refTip = (refXfrm.rot * refRig.tip')' + refXfrm.pos;
    combinedTip = (refXfrm.rot' * (probeTip - refXfrm.pos)')';
    %DEBUG:
    %probeXfrm.rot
    %refXfrm.rot
    %refDist = sqrt(combinedTip*combinedTip');
    %Dist = sqrt((refTip-probeTip)*(refTip-probeTip)');
    %fprintf('DEBUG:getTipErrors:\n\trefDist = %f\n\tdist = %f\n', refDist, Dist);
end

randerr = randn(N,3,nProbeMarkers);
for i = 1:nProbeMarkers
    if( bHomogenous )
        randerr(:,:,i) = randerr(:,:,i)*(D^0.5)*V';
    else
        D0 = D(:,:,i);
        V0 = V(:,:,i);
        randerr(:,:,i) = randerr(:,:,i)*(D0^0.5)*V0';
    end
end

for i = 1:N
    %probeMrkError = (V*(D^.5)*(randn(nProbeMarkers,3))')';
    %     if( bHomogenous )
    %         probeMrkError = (randn(nProbeMarkers, 3))*(D^0.5)*V';
    %     else
    %         probeMrkError = zeros(nProbeMarkers, 3);
    %         for j=1:nProbeMarkers
    %             D0 = D(:,:,j);
    %             V0 = V(:,:,j);
    %             probeMrkError(j,:) = (randn(1,3))*(D0^0.5)*V0';
    %         end
    %     end
    probeMrkError = reshape(randerr(i,:,:), 3, nProbeMarkers)';
    probeMrkMeas = probeTrue.mrk + probeMrkError;
    switch( regMethod )
        case 'IsotropicSVD'
            probeXfrm = getRigidXfrmSVD(probeRig.mrk, probeMrkMeas);
        case 'AnisotropicIterative'
            %TODO: clean up and put into proper code format.
            [R,t,FRE,n] = anisotropic_point_register(probeRig.mrk', probeMrkMeas', W);
            %fprintf('Sample: %d FRE: %2.2f, nIters: %d\n', i, FRE, n);
            probeXfrm.pos = t';
            probeXfrm.rot = R;
        otherwise
            error('Invalid registration method given: %s', regMethod);
    end

    probeTipMeas(i,:) = (probeXfrm.rot * probeRig.tip')' + probeXfrm.pos;
    probeTipError(i, :) = probeTipMeas(i,:) - probeTip;
    if(nargin > 4)
        %TODO: need to update this to handle non-homogenous. i.e. the FLE
        %matrix needs to be 3x3xN where N is the total number of probe and
        %reference markers.
        refMrkError = (V*(D^.5)*(randn(nRefMarkers,3))')';
        refMrkMeas = refTrue.mrk + refMrkError;
        refXfrm = getRigidXfrmSVD(refRig.mrk, refMrkMeas);
        refTipMeas(i,:) = (refXfrm.rot * refRig.tip')' + refXfrm.pos;
        refTipError(i, :) = refTipMeas(i,:) - refTip;
        combinedTipMeas(i, :) = (refXfrm.rot' * (probeTipMeas(i,:) - refXfrm.pos)')';
        combinedTipError(i, :) = combinedTipMeas(i,:) - combinedTip;
    end
end

