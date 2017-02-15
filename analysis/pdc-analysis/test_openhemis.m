
close all

n = 30;
[x, y, z] = ellipsoid(0,0,0,5,10,5,n);
npoints = n+1;

figure
surf(x, y, z)
axis equal
xlabel('x');
ylabel('y');
zlabel('z');


idx_left = x(:) < 0;
idx_right = ~idx_left;

angle = pi/4;
 % counter clockwise for left
Rz_ccw = [cos(angle) -sin(angle) 0; sin(angle) cos(angle) 0; 0 0 1];
angle = -pi/4;
% clockwise for right
Rz_cw = [cos(angle) -sin(angle) 0; sin(angle) cos(angle) 0; 0 0 1];

% rotate the coordinates
coords = [x(:) y(:) z(:)];
coords_temp = coords;
coord_temp(idx_right,:) = coords(idx_right,:)*Rz_cw';
coord_temp(idx_left,:) = coords(idx_left,:)*Rz_ccw';

offset = 5*2;
nright = sum(idx_right);
nleft = sum(idx_left);
coord_temp(idx_right,1) = coord_temp(idx_right,1) + repmat(offset,nright,1);
coord_temp(idx_left,1) = coord_temp(idx_left,1) + repmat(-offset,nleft,1);

x_new = reshape(coord_temp(:,1),npoints,npoints);
y_new = reshape(coord_temp(:,2),npoints,npoints);
z_new = reshape(coord_temp(:,3),npoints,npoints);

figure
surf(x_new, y_new, z_new)
axis equal
xlabel('x');
ylabel('y');
zlabel('z');