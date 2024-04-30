function r=roms_uv_to_speed(u,v)
    arguments
        u(:,:,:,:) double {mustBeNumeric}
        v(:,:,:,:) double {mustBeNumeric}
    end
    u=0.5*(u(:,1:end-1,:,:)+u(:,2:end,:,:));
    v=0.5*(v(1:end-1,:,:,:)+v(2:end,:,:,:));
    r=sqrt(u.*u+v.*v);