function [varargout] = write_vista_mesh(varargin)

% WRITE_VISTA_MESH is implemented as a mex file
%
% Use as
%   write_vista_mesh(filename,nodes,elements,labels)
% or
%   write_vista_mesh(filename,nodes,elements,labels,tensors)
% where 
%   filename          the name to be saved (with extension .v)
%   nodes             n. of nodes*3 field with the position of the nodes
%   elements          n. of elements*8 field with the elements
%   labels            n. of elements vector with the elements labels
%   tensors           (optional, has to be tested) is a n. of elements*6 field
%                     with the tensor conductivity values in order xx-xy-xz-yy-yz-zz.
%
% $Id: write_vista_mesh.m 8776 2013-11-14 09:04:48Z roboos $

% Copyright (C) 2011, Johannes Vorwerk, Cristiano Micheli

error('The mex file %s is missing', [mfilename '.' mexext]);

