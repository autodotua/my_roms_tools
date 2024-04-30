function equal_aspect_ratio(axs)
    arguments (Repeating)
        axs
    end
    for ax = axs
        ax{1}.DataAspectRatio=[1,1,1];
    end