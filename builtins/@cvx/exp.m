function y = exp( x )

%   Disciplined convex programming information:
%       EXP(X) is convex and nondecreasing in X. When used in CVX
%       expressions, X must be real. Typically, X must also be affine
%       or convex; X can also be concave, but this produces a log-concave
%       result with very limited usefulness.
%
%   Disciplined geometric programming information:
%       EXP(X) is typically not used in geometric programs. However,
%       EXP(X), where X is a monomial or posynomial, can be included in 
%       geometric programs wherever a posynomial would be appropriate.

cvx_expert_check( 'exp', x );
            
persistent remap funcs
if isempty( remap ),
    remap = cvx_remap( { 'constant' }, { 'convex', 'concave' } );
    funcs = { @exp_1, @exp_2 };
end

try
    y = unary_op( 'exp', funcs, remap, x );
catch exc
    if isequal( exc.identifier, 'CVX:DCPError' ), throw( exc ); 
    else rethrow( exc ); end
end

function y = exp_1( x )
% Constant
y = cvx( exp( cvx_constant( x ) ) );

function y = exp_2( x )
% Affine, convex, concave
global cvx___
x = sparsify( x, 'exponential' );
[ rx, cx, vx ] = find( x.basis_ );
tt = rx == 1;  rx( tt ) = [];
cc = cx( tt ); cx( tt ) = [];
vc = vx( tt ); % vx( tt ) = [];
exps = cvx___.exponential( rx, 1 );
tt = exps == 0;
if any( tt ),
    n1 = unique( rx( tt ) );
    n2 = newvar( cvx___.problems( end ).self, '', length( n1 ) );
    [ n2, dummy ] = find( n2.basis_ ); %#ok
    cvx___.exponential( n1, 1 ) = n2( : );
    cvx___.logarithm( n2, 1 ) = n1( : );
    cvx___.vexity( n2 ) = 1;
    cvx___.sign( n2 ) = 1;
    n2 = n2( cvx___.vexity( n1 ) < 0 );
    if ~isempty( n2 ),
        cvx___.vexity( n2 ) = NaN;
        cvx___.nan_used = true;
        cvx___.canslack( n2 ) = +1;
    end
    exps = cvx___.exponential( rx, 1 );
    cvx___.exp_used = true;
end
nb = size( x.basis_, 2 );
bx = sparse( exps, cx, 1, full( max( exps ) ), nb );
if ~isempty( cc ),
    bx = bx * diag(exp(sparse(cc,1,vc,nb,1)));
end
y = cvx( x.size_, bx );

% Copyright 2005-2014 CVX Research, Inc.
% See the file LICENSE.tx for full copyright information.
% The command 'cvx_where' will show where this file is located.
