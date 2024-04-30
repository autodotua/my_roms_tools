
function out = fill_invalid_data(a)
    % 这个文件使用5点拉普拉斯滤波器填充陆地点或无效数据点。对于水域点（有效点），它们的原始值不变。
    % im - 数据的行
    % jm - 数据的列
    % a - 需要处理的数据（陆地点设为NaN）
    % out- 结果

    [im,jm] = size(a);
    ii = find(~isnan(a));
    av = sum(a(ii))/length(ii); % 计算有效数据点的平均值

    jj = find(isnan(a));
    if (length(ii) < 2)
        a(jj) = av; % 找到无效点并用平均值填充它们
    else
        [X,Y] = meshgrid([1:jm],[1:im]);
        a(jj) = griddata(X(ii),Y(ii),a(ii),X(jj),Y(jj),'nearest');
    end

    b = a; % 定义一个工作数组

    % 五点拉普拉斯滤波器平滑。
    lpp = 100; % 进行100次平滑，循环次数越多，场越平滑

    for k=1:lpp
        i=[2:im-1];
        j=[2:jm-1];
        cc(i,j)=b(i,j)+0.5/4*(b(i+1,j)+b(i,j-1)+b(i-1,j)+b(i,j+1)-4*b(i,j));

        % 将边界设置为下一个内部点相等
        cc(1,:) =cc(2,:);
        cc(im,:)=cc(im-1,:);
        cc(:,1) =cc(:,2);
        cc(:,jm)=cc(:,jm-1);

        b(jj)=cc(jj);
    end

    a(jj)=cc(jj); % 只更改无效数据点，保持有效点不变
    out=a;
end
