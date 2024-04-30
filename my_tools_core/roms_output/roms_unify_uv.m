function [psi_u,psi_v,speed]=roms_unify_uv(u,v)
    arguments
        u {mustBeNumeric}
        v {mustBeNumeric}
    end
    if ndims(u)~=ndims(v)
        error("uv维度不同");
    end

    switch ndims(u)
        case 2
            u=0.5*(u(:,1:end-1)+u(:,2:end));
            v=0.5*(v(1:end-1,:)+v(2:end,:));
        case 3
            u=0.5*(u(:,1:end-1,:)+u(:,2:end,:));
            v=0.5*(v(1:end-1,:,:)+v(2:end,:,:));
        case 4
            u=0.5*(u(:,1:end-1,:,:)+u(:,2:end,:,:));
            v=0.5*(v(1:end-1,:,:,:)+v(2:end,:,:,:));
    end
    psi_u=u;
    psi_v=v;
    speed=sqrt(u.*u+v.*v);

