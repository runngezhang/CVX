function v = cvx( s, b, d, clean )

%CVX   The CVX disciplined convex programming system.
%   CVX is a modeling framework for building, constructing, and solving
%   disciplined convex programs. CVX has online help for many functions and
%   operations, divided into several subsection:
%      cvx/commands   - Top-level commands to control CVX
%      cvx/keywords   - Keywords for declaring variables and objectives
%      cvx/builtins   - Built-in operators and functions supported in CVX models
%      cvx/functions  - Additional functions added by CVX
%      cvx/sets       - Definitions of common convex sets
%      cvx/structures - Matrix structure definitions
%   CVX also provides an extensive user guide in PDF format, which is found
%   in its top directory. This directory can be found by typing
%      cvx_where
%   at the command prompt.

switch nargin,
    case 2,
        d = [];
        clean = false;
    case 3,
        clean = true;
    case 1,
        if isa( s, 'cvx' ),
            v = s;
        else
            v = class( struct( 'size_', size( s ), 'basis_', sparse( s(:).' ), 'dual_', '', 'dof_', [], 'slow_', nnz( isinf( s ) | isnan( s ) ) ~= 0 ), 'cvx', cvxobj );
        end
        return
    case 0,
        v = class( struct( 'size_', [ 0, 0 ], 'basis_', sparse( 1, 0 ), 'dual_', '', 'dof_', [], 'slow_', false ), 'cvx', cvxobj );
        return
end
slow = false;
if isempty( b ),
    b = sparse( 1, prod( s ) );
end
switch numel( s ),
    case 2,
    case 1,
        s( 1, 2 ) = 1;
    case 0,
        s = [ 0, 0 ];
    otherwise,
        if s(end) == 1,
            s = s( 1 : max( 2, find( s > 1, 1, 'last' ) ) );
        end
end
% if ~all( isfinite( nonzeros( b ) ) ),
%     slow = true;
%     tt = any( isnan( b ), 1 ) | sum( isinf( b ), 1 ) > isinf( b( 1, : ) );
%     b( :, tt ) = 0;
%     b( 1, tt ) = NaN;
% end
if clean,
    b1 = b( 1, : );
    if nnz( b ) == nnz( b1 ),
        v = reshape( cvx_sparse_if( b1 ), s );
        return
    end
end

v = class( struct( 'size_', s, 'basis_', b, 'dual_', '', 'dof_', d, 'slow_', slow ), 'cvx', cvxobj );

% Copyright 2005-2014 CVX Research, Inc.
% See the file LICENSE.txt for full copyright information.
% The command 'cvx_where' will show where this file is located.
