function v = cvx_classify( x )

% Classifications:
% 1  - negative constant
% 2  - zero
% 3  - positive constant
% 4  - complex constant
% 5  - negative concave
% 6  - concave
% 7  - positive concave
% 8  - negative affine
% 9  - real affine
% 10 - positive affine
% 11 - negative convex
% 12 - convex
% 13 - positive convex
% 14 - complex affine
% 15 - log concave
% 16 - log affine
% 17 - log convex monomial
% 18 - log convex posynomial
% 19 - invalid

global cvx___
if isempty( x ),
    v = zeros( size( x ) );
    return
end
v = 3 * cvx_vexity( x ) + cvx_sign( x );
b = x.basis_ ~= 0;
q = sum( b, 1 );
s = b( 1, : );

% Constants
tt = q == s;
if any( tt ),
    v( tt ) = sign( x.basis_( 1, tt ) ) + 2;
    if ~isreal( x.basis_ ),
        ti = any( imag( x.basis_ ), 1 );
        v( tt & ti ) = 4;
    end
end

% Invalids
tn = isnan( v );
v( tn ) = 19;

% Non-constants
tt = ~tt & ~tn(:)';
if any( tt ),
    temp = v( tt );
    temp = temp + 9;
    v( tt ) = temp;
    if ~isreal( x.basis_ ),
        ti = any( imag( x.basis_ ), 1 );
        v( tt & ti ) = 14;
    end
end

% Geometrics
if nnz( cvx___.exp_used ),
    t1 = v(:) == 13;
    tt = find( ( t1 | v(:) == 19 ) & q(:) == 1 );
    if ~isempty( tt ),
        [ rx, cx, vx ] = find( x.basis_( :, tt ) );
        qq = reshape( cvx___.logarithm( rx ), size( vx ) ) & ( vx > 0 );
        v( tt( cx( qq ) ) ) = 16 + sign( cvx___.vexity( cvx___.logarithm( rx( qq ) ) ) );
    end
    tt = find( t1 & q(:) > 1 );
    if ~isempty( tt ),
        [ rx, cx, vx ] = find( x.basis_( :, tt ) );
        qq = ( ~reshape( cvx___.logarithm( rx ), size( vx ) ) & ( rx > 1 ) ) | vx < 0;
        tt( cx( qq ) ) = [];
        v( tt ) = 18;
    end
end

% Copyright 2005-2014 CVX Research, Inc.
% See the file LICENSE.txt for full copyright information.
% The command 'cvx_where' will show where this file is located.
