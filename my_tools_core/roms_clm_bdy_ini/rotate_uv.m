function [u,v,theta]=rotate_uv(roms_grid_info, u, v)
    theta=exp(-sqrt(-1)*mean(mean(roms_grid_info.angle)));
    uv=(u2rho_3d_mw(u)+sqrt(-1)*v2rho_3d_mw(v)).*theta;
    u=rho2u_3d_mw(real(uv)); v=rho2v_3d_mw(imag(uv));
end
