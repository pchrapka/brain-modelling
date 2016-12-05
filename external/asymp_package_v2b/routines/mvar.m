function [IP,pf,A,pb,B,ef,eb,vaic,Vaicv]=mvar(u,maxIP,alg,criterion)
% Estimate MVAR
%
%[IP,pf,A,pb,B,ef,eb,vaic,Vaicv] = mvar(u,maxIP,alg,criterion)
%
% input: u     - data rows
%        maxIP - externaly defined maximum IP
%        alg   - for algorithm (=1 Nutall-Strand), (=2 - mlsm) ,
%                              (=3 - Vieira Morf), (=4 - QR artfit)
%        criterion for order choice - 0: MDL
%                                     1: AIC; 2: Hanna-Quinn, 3 Schwartz,
%                                     4: FPE, 5 - fixed order in maxIP
% output: See Data Structure Data Base
%

[nSegLength,nChannels] = size(u');
if nargin<3, alg=1; criterion=1; end % defaults
if nargin<4, criterion=1; end        % defaults

if criterion==5 % Fixed order in maxIP
    if maxIP==0
        pf=u*u';     % Eq. (15.90) Equation numbering refers to Marple Jr.
        pb=pf;       % Eq. (15.90)
        ef=u;
        eb=u;
        npf=size(pf);
        A=zeros(npf,npf,0);
        B=A;
        vaic=det(pf);
        Vaicv=det(pf);
        IP=0;
        return
    end
    IP=maxIP;
    
    switch alg      %  Formula from Marple Jr.
        case 1,
            [pf A pb B ef eb]=mcarns(u,IP);
            pf=pf(:,:)/nSegLength; %Nuttall-Strand needs scaling.
        case 2,
            [pf A ef]=cmlsm(u,IP);
            B  = [ ]; eb = [ ]; pb = [ ];
            pf=pf(:,:)/nSegLength;
        case 3,
            [pf A pb B ef eb]=mcarvm(u,IP);
            pf=pf(:,:)/nSegLength; %Vieira-Morf needs scaling.
        case 4,
            [pf A ef]=arfitcaps(u,IP);
            B  = [ ]; eb = [ ]; pb = [ ];
            % Arfit does not need scaling. pf=pf;
    end
    
    vaic=length(u)*log(det(pf))+2*(nChannels*nChannels)*IP;
    Vaicv=vaic;
    % fprintf('IP=%0.f  vaic=%f\n',IP,vaic);
    return
end
%
vaicv=0;
if nargin<2
    maxOrder=30;
    disp(['maxOrder limited to ' int2str(maxOrder)])
    UpperboundOrder = round(3*sqrt(nSegLength)/nChannels); % Marple Jr. p. 409
    % Suggested by Nuttall, 1976.
    UpperboundOrder = min([maxOrder UpperboundOrder]);
else
    maxOrder=maxIP;
    UpperboundOrder=maxIP;
    disp(['maxOrder limited to ' int2str(maxOrder)])
end
IP=1;
Vaicv=zeros(maxOrder+1,1);
while IP <= UpperboundOrder,
    switch alg
        case 1, %  Extracted from Marple Jr.
            [npf na npb nb nef neb]=mcarns(u,IP);
        case 2,
            [npf na nef]=cmlsm(u,IP);
        case 3,
            [npf na npb nb nef neb]=mcarvm(u,IP);
        case 4,
            [npf na nef]=arfitcaps(u,IP);
    end
    %  criterion
    
    switch criterion
        case 1, % AIC
            vaic=length(u)*log(det(npf)) ...
                +2*(nChannels*nChannels)*IP;
        case 2,  % Hannan-Quinn
            vaic=length(u)*log(det(npf)) ...
                + 2*log(log(length(u)))*(nChannels*nChannels)*IP;
        case 3, % Schwartz
            vaic=length(u)*log(det(npf)) ...
                +(log(length(u)))*(nChannels*nChannels)*IP;
        case 4, % FPE
            vaic=log(det(npf)*((length(u)+nChannels*IP+1) ...
                /length(u)-nChannels*IP-1)^nChannels);
        otherwise
            %nop
    end
    
    Vaicv(IP+1)=vaic;
    fprintf('IP=%0.f  vaic=%f\n',IP,vaic);
    if (vaic>vaicv) && (IP~=1),
        vaic=vaicv;
        break;
    end; % Akaike condition
    vaicv=vaic;
    pf = npf;
    A  = na;
    ef = nef;
    if alg==1
        B  = nb;
        eb = neb;
        pb = npb;
    else % review status for backward prediction in clmsm
        B  = [];
        eb = [];
        pb = [];
    end
    IP=IP+1;
end;

disp(' ')
IP=IP-1;
vaic=vaicv;
Vaicv=Vaicv(2:IP+1);

switch alg
    case {1,3}, %Nuttall-Strand and Vieira-Morf need scaling.
        pf=pf(:,:)/nSegLength;
    case 4,
        pf=pf; % arfit does not need scaling.
    otherwise  %
        pf=pf(:,:)/nSegLength;
end;
