function text_left_top(str,marginLeft,marginTop,padding,backgroundTranparent)
    arguments
        str(1,1) string
        marginLeft(1,1) double=0.03
        marginTop(1,1) double=0.03;
        padding(1,1) double=1;
        backgroundTranparent(1,1) logical =0
    end
    project_data
    gcaPosition=get(gca,'Position');
    gcfPosition=get(gcf,'Position');
    height=gcaPosition(4)*gcfPosition(4);
    t=text(marginLeft,1- marginTop,str, FontSize=graphData.fontSize, FontName=graphData.font, Color='black',Units='normalized',VerticalAlignment='top',BackgroundColor='w', Margin=padding);
    if backgroundTranparent
        set(t, 'BackgroundColor', 'none');
    end
end
