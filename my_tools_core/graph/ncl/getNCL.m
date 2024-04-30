function getNCL
% @author: slandarer
main_forder_name='NCL_RGB';
main_website_path='https://www.ncl.ucar.edu/Document/Graphics/color_table_gallery.shtml#SVG';
if ~exist(main_forder_name,'dir')
   mkdir(main_forder_name);
end

% 获取每一个面板位置
main_content=webread(main_website_path);
class_sep=[regexpi(main_content,'<a name='),length(main_content)];

className{length(class_sep)-1}='';
colorName{length(class_sep)-1}={''};
for i=1:length(class_sep)-1
    class_content=main_content(class_sep(i):class_sep(i+1));

    % 获取各类名称
    class_begin=10;
    class_end=regexpi(class_content,'></a>');
    class_name=class_content(class_begin:class_end(1)-2);
    className{i}=class_name;
    class_forder_name=['NCL_RGB\',class_name];
    if ~exist(class_forder_name,'dir')
        mkdir(class_forder_name);
    end

    % 获取每个示意图名称
    img_begin=regexpi(class_content,'Images/');
    img_end=regexpi(class_content,'_labelbar');

    % 循环获取颜色
    tColorNameCell={};
    disp(' ')
    for j=1:length(img_begin)
        color_name=class_content(img_begin(j)+7:img_end(j)-1);
        tColorNameCell{j}=color_name;
        color_website_path=['https://www.ncl.ucar.edu/Document/Graphics/ColorTables/Files/',color_name,'.rgb'];
        disp(['正在获取','Class(',num2str(i),')[',class_name,']->Color(',num2str(j),')[',color_name,']'])
        websave([class_forder_name,'\',color_name,'.txt'],color_website_path);
    end
    colorName{i}=tColorNameCell;
end
% save nclCM_Name.mat className colorName
end