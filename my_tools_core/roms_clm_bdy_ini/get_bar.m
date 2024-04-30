function [ubar,vbar]=get_bar(roms_grid_info,u,v,theta)
    % 获取UV压力
    arguments
        roms_grid_info
        u(:,:,:) double
        v(:,:,:) double
        theta(1,1) double
    end
    cc=roms_zint_mw(u,roms_grid_info);
    ubar=rho2u_2d_mw(u2rho_2d_mw(cc)./roms_grid_info.h);
    cc=roms_zint_mw(v,roms_grid_info);
    vbar=rho2v_2d_mw(v2rho_2d_mw(cc)./roms_grid_info.h);
    uv=(u2rho_2d_mw(ubar)+sqrt(-1)*v2rho_2d_mw(vbar)).*theta;
    ubar=rho2u_2d_mw(real(uv));
    vbar=rho2v_2d_mw(imag(uv));
end