function show_simulation_and_observation_core(sim_x,sim_y,sim_value,obs_x,obs_y,obs_value,type,show_border,show_text,texts,contour_text,contour_step)
    arguments
        sim_x(:,:) double,
        sim_y(:,:) double,
        sim_value(:,:) double,
        obs_x(:,1) double
        obs_y(:,1) double
        obs_value(:,1) double
        type(1,1) string {mustBeMember(type,["pcolor","contour"])}="pcolor",
        show_border(1,1) logical=0
        show_text(1,1) logical=1,
        texts(:,1) string=[],
        contour_text(1,1) logical=1,
        contour_step(:,1) double{mustBePositive}=0.2
    end
    if type=="pcolor"
        pcolorjw(sim_x,sim_y,sim_value)
    else
        contourf(sim_x,sim_y,sim_value,ShowText=contour_text,LevelStep=contour_step)
    end
    %zlim([0,3e-3])
    hold on

    indexs=find(obs_x<max(sim_x(:)) & obs_x>min(sim_x(:))...
        & obs_y<max(sim_y(:)) & obs_y>min(sim_y(:)));
    obs_x=obs_x(indexs);
    obs_y=obs_y(indexs);
    obs_value=obs_value(indexs);
    scatter(obs_x,obs_y,20,obs_value,'filled')
    if show_border
        scatter(obs_x,obs_y,20,'w')
    end
    if show_text
        if isempty(texts)
            t= text(obs_x+0.03,obs_y,num2str(round(obs_value,2)),'Color','White');
        else
            t=  text(obs_x+0.03,obs_y,texts,'Color','White');
        end
        for st=t'
            st.Clipping='on';
        end
    end