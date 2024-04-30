function fill_rst_bio_to_ini(rstFile,iniFile)
    names=get_all_biology_vars;
    nc_fill_values_from_another(rstFile,iniFile,names,@(x) p(x))
    
    function r=p(x)
        r=x(:,:,:,end);
        %maxv=prctile(r(:),95);
        %r(~isnan(r) & r>maxv)=maxv;
        r(isnan(r))=0;
    end
end