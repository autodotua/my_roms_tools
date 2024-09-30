# my_roms_tools
基于MATLAB的ROMS区域海洋模式预处理、后处理工具包

该工具包为本人进行ROMS相关科研时编写。所有公开的代码可以免费用于学习、科研工作等，但不可用于商业行为，不可盈利。

**如果您使用本人修改的工具（仅`my_tools_`前缀的目录为本人开发，其余来自[COAWST](https://github.com/DOI-USGS/COAWST)）做出了相关成果，如发表了论文等，恳请给本项目点个Star。**

MATLAB-based pre-processing and post-processing toolkit for ROMS regional ocean models

This toolkit is written for my ROMS related scientific research. All the open code can be used for free for study, research work, etc., but not for commercial behavior, not for profit.

**If you use my modified tools (only the `my_tools_` prefixed directory is developed by me, the rest is from [COAWST](https://github.com/DOI-USGS/COAWST)) to produce relevant results, such as published papers, etc., you are kindly requested to give a Star to this project.**

# 介绍

## 原版COAWST_ TOOLS

基于COAWST模式附带的工具包，用于制作ROMS模式的预处理文件，以及用于我的项目的分析、绘图。

mfiles目录下是一组Matlab的预处理/后处理工具

## 更改

- 本项目将多个文件中分散的配置进行了综合，使用 `config.m`文件进行统一管理
- 增加或修复了部分ROMS和SWAN工具，例如添加河流文件、增加初始场示踪剂等。
- 增加了一些通用型工具

## 软件要求

- MATLAB R2019b+
  - Image Processing Toolbox
  - Mapping Toolbox
  - Optimization Toolbox
  - Parallel Computing Toolbox
  - Statistic and Machine Learning Toolbox
  - Symbolic Math Toolbox
- Python 3.5+
  - requests

# 目录和文件

## 目录

### 原版目录

这些是COAWST工具包中自带的目录。目录中的部分文件可能也被我修改了。

| 目录名           | 内容                                                                                   |
| ---------------- | -------------------------------------------------------------------------------------- |
| `inwave_tools` | inwave模式工具                                                                  |
| `m_map`        | 地图的绘制等                                                                           |
| `mtools`       | ROMS创建网格、加载NC文件、将网格转为scrip、从ROMS网格创建WRF网格等工具                 |
| `roms_clm`     | 创建边界、初始文件、气候文件等。主驱动文件是roms_master_climatology_coawst_mw.m        |
| `rutgers`      | 来自Rutgers的水深测量、边界、海岸线、强迫、网格、陆地掩膜、 netcdf、海水、和实用文件夹 |
| `swan_forc`    | 读取WW3 Grib2文件并创建SWAN Trap强迫文件，主驱动文件是ww3_swan_input.m                 |
| `tides`        | 为ROMS创建潮汐强迫                                                                     |

### 新增目录

| 文件名             | 内容                                     |
| ------------------ | ---------------------------------------- |
| `my_tools_core`    | 用于ROMS输入输出的核心代码函数库         |
| `my_tools_temp`    | 临时代码                                 |
| `my_tools_project` | 用于污染物扩散模拟和溯源研究中的专有代码 |

## 基本

| 文件名        | 内容                                           |
| ------------- | ---------------------------------------------- |
| `add_paths` | 将当前目录注册到MATLAB中，并注册 `nctoolbox` |
| `configs`   | 集合的配置文件                                 |

## 核心代码：`my_tools_core`

### ROMS网格：`roms_grid`

| 文件名                           | 内容                                                  |
| -------------------------------- | ----------------------------------------------------- |
| `roms_create_grid_core`          | 创建ROMS网格                                          |
| `roms_create_grid_from_wrfinput` | 从WRF的 `wrfinput`文件创建ROMS网格                    |
| `roms_fill_grid_h_core`          | 向ROMS网格文件中填充深度信息                          |
| `roms_fix_h`                     | 修复GridBuilder导出的网格文件深度问题                 |
| `roms_get_grid_details`          | 获取ROMS网格的详细信息                                |
| `roms_get_volumes`               | 获取ROMS网格中每个单元格的体积                        |
| `roms_get_xy_by_lonlat_core`     | 根据经纬度获取ROMS网格的XY位置                        |
| `roms_load_grid_rho`             | 从网格文件获取ROMS网格中rho的经度、纬度和海陆掩膜矩阵 |
| `roms_load_grid_psi`             | 从网格文件获取ROMS网格中psi的经度、纬度和海陆掩膜矩阵 |

### ROMS水文：`roms_clm_bdy_ini`

创建初始场、边界场、气候态强迫文件

| 文件名                        | 内容                                           |
| ----------------------------- | ---------------------------------------------- |
| **`roms_create_clm_bdy_ini`** | 创建ROMS的初始场、气象场、边界场文件           |
| `create_bdy`                  | 根据已有的clm文件创建边界文件                  |
| `create_clm_nc`               | 根据给定的变量创建clm的nc文件                  |
| `create_clms`                 | 创建指定时间的合并的clm文件                    |
| `create_single_clm`           | 创建单个clm文件                                |
| **`download_hycom`**          | 下载指定时间和区域的HYCOM数据                  |
| **`download_cmems`**          | 下载指定时间和区域的CEMEMS数据（包含生态变量） |
| `get_bar`                     | 根据UV计算Ubar和Vbar                           |
| `get_hycom_info`              | 获取HYCOM数据的信息                            |
| `get_roms_grid_info`          | 获取ROMS网格信息                               |
| `merge_clms`                  | 合并一个时间一个的clm文件                      |
| `rotate_uv`                   | 将横平竖直的UV进行旋转以符合ROMS网格           |

### ROMS大气：`roms_atom`

| 文件名                             | 内容                                                  |
| ---------------------------------- | ----------------------------------------------------- |
| `download_fnl`                     | 批量下载NCEP FNL数据                                  |
| **`roms_create_force_NCEP`**       | 通过NCEP的FNL数据，创建大气强迫文件                   |
| `roms_add_radiations_NCEP`         | 通过NCEP的DS083.3数据向大气强迫文件中加入短波辐射数据 |
| `roms_create_force_radiation_ERA5` | 通过欧洲中心的ERA5数据，创建短波辐射、长波辐射文件    |

### ROMS潮汐：`roms_tides`

| 文件名                        | 内容                                  |
| ----------------------------- | ------------------------------------- |
| `roms_create_tides_tpx`       | 基于TPX的两个`.m`文件创建ROMS潮汐文件 |
| **`roms_create_tides_tpxo9`** | 基于TPXO9创建ROMS潮汐文件             |

### ROMS示踪剂：`roms_tracer`

| 文件名                         | 内容                                                         |
| ------------------------------ | ------------------------------------------------------------ |
| `roms_add_passive_tracer_core` | 向初始场和边界场中添加被动示踪剂                             |
| `roms_add_tracer_from_xyz`     | 从XYZ类型的数据集中提取数据，向初始文件、边界文件、气候态文件中添加（生物等）示踪剂变量 |
| `roms_add_tracer_to_bdy_nc`    | 将数据写入到边界文件                                         |
| `roms_add_tracer_to_clm_nc`    | 将数据写入到气候态文件                                       |
| `roms_get_dye`                 | 获得nc文件中的示踪剂                                         |

### ROMS漂浮子：`roms_float`

| 文件名                      | 内容                                                         |
| --------------------------- | ------------------------------------------------------------ |
| `roms_create_floats`        | 创建ROMS漂浮子文件                                           |
| `roms_create_timely_floats` | 创建ROMS漂浮子文件，在同一地点每隔一定时间生成一个漂浮子     |
| `show_floats`               | 显示漂浮子轨迹                                               |
| `floats_contribution`       | 基于漂浮子，计算不同释放源对某一海域的贡献，即有多少粒子曾经经过指定海域 |

### ROMS生物：`roms_biology`

| 文件名                 | 内容                           |
| ---------------------- | ------------------------------ |
| `get_all_biology_vars` | 获取所有生物变量的变量名和描述 |
| `mgL2mmolm3`           | 将mg/L转换为millimole/m^3      |

### ROMS输出：`roms_output`

| 文件名           | 内容                               |
| ---------------- | ---------------------------------- |
| `roms_get_times` | 获取ROMS的nc文件中的时间序列       |
| `roms_unify_uv`  | 将ROMS的U和V分量统一大小并计算速度 |

### SWAN：swan

| 文件名                      | 内容             |
| --------------------------- | ---------------- |
| `swan_create_boundary_core` | 创建SWAN的边界场 |

### 插值相关：`roms_interpolate`

| 文件名                         | 内容                                                         |
| ------------------------------ | ------------------------------------------------------------ |
| **`interpolate_xyz_to_sigma`** | 将基于一维XY(Z)正交网格的数据插值插值为ROMS的i-j-σ地形追随坐标系网格数据 |
| `convert_rho_to_uv`            | 将输入的rho网格转换为u或v网格                                |
| `fill_invalid_data`            | 使用5点拉普拉斯滤波器填充陆地点或无效数据点                  |
| `get_xyz_data_info`            | 获取XY(Z)正交网格的数据的基本信息及需要处理的数据边界        |
| `interpolate_z_to_sigma`       | 将基于确定深度的z网格插值为地形追随的σ网格                   |

### 河流：`roms_river`

| 文件名                    | 内容             |
| ------------------------- | ---------------- |
| `roms_create_rivers_core` | 创建ROMS河流文件 |

### NetCDF：`nc`

| 文件名                         | 内容                                                         |
| ------------------------------ | ------------------------------------------------------------ |
| `fill_rst_bio_to_ini`          | 将模拟中生成的rst文件（最后时刻）的变量写入到初始场文件中，用于旋转模拟 |
| `nc_compact`                   | 将nc文件进行压缩。可输出每个变量独立的nc/mat文件。可去除z纬。可将double转为float。 |
| `nc_dem_clip_core`             | 将DEM的nc文件进行裁剪，减小文件体积便于处理和导入GridBuilder |
| `nc_extract_variables`         | 将nc文件中的变量导出为mat文件                                |
| `nc_fill_values_from_another`  | 将nc文件中的某个变量复制到另一个文件中的相同变量             |
| `read_data`                    | 读取普通nc文件或经过`nc_compact`处理后的nc/mat文件/目录      |
| `roms_add_variable_to_xyzt_nc` | 在nc文件中生成一个xyzt（或xy、xyt、xyz）维度的变量，并写入数据 |

### 绘图：`graph`

| 文件名                                 | 内容                                                      |
| -------------------------------------- | --------------------------------------------------------- |
| `ncl`                                  | NCL colormap包                                            |
| `a2z_string`                           | 获取a到z的字符数组或其中一个字符                          |
| `apply_colors`                         | 将给定的颜色关键帧插值到指定数量然后应用colormap          |
| `apply_font`                           | 应用字体和字号                                            |
| `color_*`                              | 应用指定颜色的colormap                                    |
| `draw_background`                      | 在指定区域绘制一块纯色背景                                |
| `draw_border`                          | 在当前坐标区的四边绘制边框                                |
| `draw_map`                             | 绘制基于地图坐标系的网格图                                |
| `draw_monthly_profile`                 | 绘制单个变量每月剖面图                                    |
| `draw_profile`                         | 绘制多个变量的平均剖面图                                  |
| `draw_single_lonlat_tick`              | 显示多图tile时，左侧tile显示y坐标，底部tile显示x坐标      |
| `draw_time_series_lines`               | 绘制某几个变量在某一（几）个位置随时间变化的折线图        |
| `draw_time_series_maps`                | 绘制某几个变量在不同月份的地图                            |
| `equal_aspect_ratio`                   | 限制坐标系等比例为1:1                                     |
| `save_all_figures`                     | 将所有figure保存为图片                                    |
| `set_gcf_size`                         | 设置图窗大小                                              |
| `set_tiledlayout_compact`              | 设置`tiledlayout`的Margin和内部tile之间的间距为较小值     |
| `show_simulation_and_observation_core` | 用填色图和带颜色的点表示模拟值和观测值                    |
| `show_value_change_core`               | 显示某一点或某一柱或某一片的值随时间的变化                |
| `text_corner`                          | 在图的角落添加文字                                        |
| `text_left_top`                        | 在图的左上角添加白底黑字文字标签。过时，使用`text_corner` |
| `text_right_bottom`                    | 在图的右下角添加白底黑字文字标签。过时，使用`text_corner` |



### 精度评估

| 文件名    | 内容                                 |
| --------- | ------------------------------------ |
| `get_ioa` | 计算一致性指数（Index of agreement） |
| `get_r`   | 计算皮尔逊相关系数（r）              |
| `get_mb`  | 计算平均偏差（Mean Bias）            |


# ROMS

## 创建网格

使用 `GridBuilder`来创建网格。

~~首先执行 `roms_create_grid_from_wrfinput`，从 `wrfinput`创建网格，在弹出的窗口中根据海岸线编辑水陆点；或执行 `roms_create_grid_core`，根据高程文件来创建网格。。然后执行 `roms_fill_grid_h`填充水深。~~

## 边界场、初始场、气候态逼近场

### 下载HYCOM数据

编辑 `download_hycom.py`，指定区域和时间，使用Python下载所需的HYCOM数据。

手动下载：位于[HYCOM](http://tds.hycom.org/thredds/catalog.html)（hybrid coordinate ocean model，混合坐标海洋模型）。这里选用的是GOFS 3.0: HYCOM + NCODA Global 1/12° Analysis (NRL)-[`GLBu0.08/expt_90.9 (2012-05 to 2013-08)/`](http://tds.hycom.org/thredds/catalogs/GLBu0.08/expt_90.9.html)，选择[Hindcast Data: May-2012 to Aug-2013](http://tds.hycom.org/thredds/catalogs/GLBu0.08/expt_90.9.html?dataset=GLBu0.08-expt_90.9)，然后选择OPeNDAP：[//tds.hycom.org/thredds/dodsC/GLBu0.08/expt_90.9](http://tds.hycom.org/thredds/dodsC/GLBu0.08/expt_90.9.html)，其中有个Data URL后面就是所需要的地址。

### 确认示踪剂配置

若需要示踪剂，则编辑 `roms_add_tracer`文件，在需要的地方填充初始时刻的示踪剂浓度。

### 制作文件

执行 `roms_create_clm_bdy_ini`。会生成：

- 初始场文件：`roms_ini.nc `
- 边界文件：`roms_bdy.nc`
- 气象文件：`roms_clm.nc`

对于嵌套中的子区域，需要创建初始场和气象文件。可以和上面进行相同的步骤，也可以：

```matlab
create_roms_child_init( roms_grid, roms_child_grid, 'Sandy_ini.nc',  'Sandy_ini_ref3.nc') 
create_roms_child_clm( roms_grid, roms_child_grid,  'Sandy_clm.nc', 'Sandy_clm_ref3.nc')
```

这一部分还未进行修改。

## 潮汐场

### 低精度潮汐

需要 `tpx_h.mat`和 `tpx_uv.mat`文件。进入[Revision 41](https://coawstmodel.sourcerepo.com/coawstmodel/data/)，选择[tide](https://coawstmodel.sourcerepo.com/coawstmodel/data/tide/)，下载[adcirc..](https://coawstmodel.sourcerepo.com/coawstmodel/data/tide/adcirc_ec2001v2e_fix.mat)或[tpx_h.mat](https://coawstmodel.sourcerepo.com/coawstmodel/data/tide/tpx_h.mat)和[tpx_uv.mat](https://coawstmodel.sourcerepo.com/coawstmodel/data/tide/tpx_uv.mat)。这个网站用IE才能打开，Chromium打不开，因为加密方式太老了。

确保 `roms_create_tides`中调用的是 `roms_create_tides_tpx`。执行 `roms_create_tides`。

### 高精度潮汐

使用 `TPXO9`进行创建。下载地址未知。

确保 `roms_create_tides`中调用的是 `roms_create_tides_tpxo9`。执行 `roms_create_tides`。

## 大气强迫场

### 风、温湿度

下载NCEP的FNL数据，不要重命名，放在配置中的 `roms.res.force_ncep_dir`下。

执行 `roms_create_ncep_force`

### 辐射

下载链接：[ERA5 hourly data on single levels from 1940 to present](https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels?tab=form)

在`Variable`中找到`Radiation and heat`，勾选：

- Surface net solar radiation（ssr，太阳短波辐射）
- Surface net thermal radiation（str，向上长波辐射，物体由于存在温度而辐射的长波）
- Surface thermal radiation downwards（strd，向下短波辐射，云、大气等由于存在温度而向下辐射的长波）

选择需要的Year、Month、Day、Time，在Geographical area中指定需要的范围，Format选择NetCDF，然后`Submit Form`。

等待请求完成，下载数据，保证文件名与`configs`中相同。

执行`roms_create_force_radiation_ERA5`

## 河流

编辑 `roms_create_rivers`，确认河流的位置、流量等信息。如果启用了示踪剂，则设置示踪剂浓度。之后执行。

## 最终所必需的文件（非嵌套）

- 网格文件：`roms_grid.nc`
- 初始场文件：`roms_ini.nc `
- 边界文件（若需要）：`roms_bdy.nc`
- 气候态逼近文件（若需要）：`roms_clm.nc`
- 潮汐强迫文件（若需要）：`roms_tides.nc`
- 河流强迫文件（若需要）：`roms_rivers.nc`

# 注

- `my_tools_core\graph\ncl`下的数据和代码来自slandarer，具体见代码中的注释。

- 部分代码基于COAWST工具包改编，而非本仓库原创。

- 2024年起，下载CMEMS的代码已经过时，需要修改后才可使用。

- 代码已申请软件著作权，请勿牟利。
