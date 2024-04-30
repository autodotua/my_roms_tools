function text_right_bottom(str,marginRight,marginBottom,padding,backgroundTranparent)
    arguments
        str(1,1) string
        marginRight(1,1) double=0.03
        marginBottom(1,1) double=0.03;
        padding(1,1) double=1;
        backgroundTranparent(1,1) logical =0
    end
    project_data
    gcaPosition=get(gca,'Position');
    gcfPosition=get(gcf,'Position');
    height=gcaPosition(4)*gcfPosition(4);
    t=text(1-marginRight,marginBottom,str, FontSize=graphData.fontSize, FontName=graphData.font, Color='black',Units='normalized',VerticalAlignment='top',BackgroundColor='w', Margin=padding);
    if backgroundTranparent
        set(t, 'BackgroundColor', 'none');
    end
end
