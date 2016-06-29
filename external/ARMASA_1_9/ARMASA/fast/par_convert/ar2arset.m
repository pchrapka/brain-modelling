function [ar,rc,ASAcontrol] = ar2arset(ar,req_order,last)
%AR2ARSET AR parameters to optimal lower-order AR models
%   [AR,RC] = AR2ARSET(AR) determines all lower-order 
%   reflectioncoefficients RC, corresponding to the AR-parameter vector 
%   AR, by applying a reversed Levinson-Durbin recursion.
%   
%   [SET_AR,SET_RC] = AR2ARSET(AR,REQ_ORDER) returns intermediate AR 
%   parameter vectors in the cell array SET_AR and an array SET_RC of 
%   reflectioncoefficients, both corresponding to orders requested by 
%   REQ_ORDER. REQ_ORDER must be either a row of ascending AR-orders, or 
%   a single AR-order.
%   
%   A parametervector in SET_AR of order LOWORDER represents an AR-model 
%   that gives the best description (in the sense of prediction) based on 
%   LOWORDER+1 autocovariances of the AR-model with parameter vector AR.
%   
%   AR2ARSET is an ARMASA main function.
%   
%   See also: RC2ARSET, COV2ARSET.

%   References: P. Stoica and R.L. Moses, Introduction to Spectral
%               Analysis, Prentice-Hall, Inc., New Jersey, 1997,
%               Chapter 3.

%Header
%=====================================================================

%Declaration of variables
%------------------------

%Declare and assign values to local variables
%according to the input argument pattern
switch nargin
case 1 
   if isa(ar,'struct'), ASAcontrol=ar; ar=[];
   else, ASAcontrol=[];
   end
   req_order=[];
case 2 
   if isa(req_order,'struct'), ASAcontrol=req_order; req_order=[]; 
   else, ASAcontrol=[]; 
   end
case 3 
   if isa(last,'struct'), ASAcontrol=last;
   else, error(ASAerr(39))
   end
otherwise
   error(ASAerr(1,mfilename))
end

if isequal(nargin,1) & ~isempty(ASAcontrol)
      %ASAcontrol is the only input argument
   ASAcontrol.error_chk = 0;
   ASAcontrol.run = 0;
end

%ARMASA-function version information
%-----------------------------------

%This ARMASA-function is characterized by
%its current version,
ASAcontrol.is_version = [2001 2 12 11 0 0];
%and its compatability with versions down to,
ASAcontrol.comp_version = [2000 12 30 20 0 0];

%Checks
%------

if ~any(strcmp(fieldnames(ASAcontrol),'error_chk')) | ASAcontrol.error_chk
   %Perform standard error checks
   %Input argument format checks
   ASAcontrol.error_chk = 1;
   if ~isnum(ar)
      error(ASAerr(11,'ar'))
   end
   if ~isavector(ar)
      error(ASAerr(15,'ar'))
   elseif size(ar,1)>1
      ar = ar';
      warning(ASAwarn(25,{'column';'ar';'row'},ASAcontrol))         
   end
   if ~isempty(req_order)
      if ~isnum(req_order) | ~isintvector(req_order) |...
            req_order(1)<0 | ~isascending(req_order)
         error(ASAerr(12,{'requested';'req_order'}))
      elseif size(req_order,1)>1
         req_order = req_order';
         warning(ASAwarn(25,{'column';'req_order';'row'},ASAcontrol))
      end
   end
   
   %Input argument value checks
   if ~isreal(ar)
      error(ASAerr(13))
   end
   if ar(1)~=1
      error(ASAerr(23,{'ar','parameter'}))
   end
   if ~isempty(req_order) & req_order(end) > length(ar)-1
      error(ASAerr(24,'AR parameters'))
   end
end

if ~any(strcmp(fieldnames(ASAcontrol),'version_chk')) | ASAcontrol.version_chk
      %Perform version check
   ASAcontrol.version_chk = 1;
      
   %Make sure the requested version of this function
   %complies with its actual version
   ASAversionchk(ASAcontrol);
end

if ~any(strcmp(fieldnames(ASAcontrol),'run')) | ASAcontrol.run
      %Run the computational kernel
   ASAcontrol.run = 1;

%Main   
%===========================================================
    
%Recursion initialization
%------------------------  

l_ar = length(ar);
rc = zeros(1,l_ar);
rc_temp = ar(l_ar);
rc(l_ar) = rc_temp;
store = ~isempty(req_order);
if store
   counter = length(req_order);
   min_k = req_order(1)+1;
   ar_stack = cell(counter,1);
   rc_stack = zeros(1,counter);
   if req_order(counter)==l_ar-1
      ar_stack{counter} = ar;
      rc_stack(counter) = ar(l_ar);
      counter = counter-1;
   end
else
   ar_stack = ar;
   min_k = 1;
end

%Reversed Levinson Durbin recursion
%----------------------------------

for k = l_ar-1:-1:min_k
   ar = (1/(1-rc_temp^2))*(ar(1:k+1)-rc_temp*ar(k+1:-1:1));
   rc_temp = ar(k);
   rc(k) = rc_temp;
   ar(1) = 1;
   if store & k==req_order(counter)+1
      ar_stack{counter} = ar(1:k);
      rc_stack(counter) = rc_temp;
      counter = counter-1;
   end
end

%Output argument arrangement
%---------------------------

if ~isempty(req_order)
   ar = ar_stack;
   rc = rc_stack;
else
   ar = ar_stack;
end

%Footer
%=====================================================

else %Skip the computational kernel
   %Return ASAcontrol as the first output argument
   if nargout>1
      warning(ASAwarn(9,mfilename,ASAcontrol))
   end
   ar = ASAcontrol;
   ASAcontrol = [];
end

%Program history
%======================================================================
%
% Version                Programmer(s)          E-mail address
% -------                -------------          --------------
% former versions        P.M.T. Broersen        p.m.t.broersen@tudelft.nl
% [2000 12 30 20 0 0]    W. Wunderink           wwunderink01@freeler.nl
% [2001  2 12 11 0 0]          ,,                          ,,


