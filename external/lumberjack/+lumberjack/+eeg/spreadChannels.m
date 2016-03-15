function [ OutputMat ] = spreadChannels( InputMat, SpreadDist, Multiplier )
%SPREADCHANNELS Spreads columns for better separation while plotting.
%   SPREADCHANNELS(X,D,M) spreads the columns in X by D after multiplying
%   by M. M should be 1 by default.
%
%   For EEG data X is [samples channels]

[Rows, Cols] = size(InputMat);

Spread = (Cols - 1):-1:0;
Spread = Spread * SpreadDist;
SpreadMat = repmat(Spread,Rows,1);

OutputMat = InputMat*Multiplier + SpreadMat;

end

