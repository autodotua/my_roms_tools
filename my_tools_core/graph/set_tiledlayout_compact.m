function set_tiledlayout_compact(tls)
    arguments (Repeating)
        tls
    end
    for tl=tls
        set(tl{1},'Padding','compact','TileSpacing','Compact');
    end
