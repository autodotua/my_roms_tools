# my_roms_tools
基于MATLAB的ROMS区域海洋模式预处理、后处理工具包

该工具包为本人进行ROMS相关科研时编写，暂时非直接公开。有需要的，可向我发邮件索取。邮箱地址：autodotua@outlook.com。

将在后续公开代码，预计时间：2024年6月。

**如果您使用本人修改的工具（`my_tools_core`）做出了相关成果，如发表了论文等，恳请给本项目点个Star。**


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



## 项目代码：`my_tools_project`

| 文件名         | 内容                 |
| -------------- | -------------------- |
| `bundle`       | 项目所有代码的集合   |
| `project_data` | 项目代码的常量、配置 |
| `show_area`    | 绘制研究区域示意图   |

### 项目1：杭州湾污染物 `hzw`

#### 污染物扩散：`diffuse`

| 文件名                         | 内容                                                 |
| ------------------------------ | ---------------------------------------------------- |
| `add_ini_bdy_dye`              | 向初始场和边界场文件中添加示踪剂                     |
| `adjust_tide`                  | 调整潮汐和分潮的振幅，使其更符合实际                 |
| `compare`                      | 比较不同污染物、不同季节的模拟结果与观测值对比及绘图 |
| `compare_single`               | 单个污染物、单个季节的模拟结果与观测值的对比及绘图   |
| `create_real_emmision_points`  | 基于政府发布数据创建河流源和排污点                   |
| `read_emmision_table`          | 读取并处理排放清单Excel表格                          |
| `show_degradation_coefficient` | 显示降解系数的分布                                   |
| `show_emission_points`         | 绘制排放点位置                                       |
| `show_value_change`            | 绘制某一个值的变化                                   |
| `show_year_average`            | 显示各污染物年平均分布                               |

#### 观测数据：`observation`

| 文件名                            | 内容                                                         |
| --------------------------------- | ------------------------------------------------------------ |
| `ParseWaterQualityJson`           | 解析从生态环境部下载的海洋水质观测数据JSON的C#工具           |
| `draw_observations_position`      | 绘制观测点位置                                               |
| `get_observations`                | 从Excel中读取观测数据                                        |
| `get_observations_of_all`         | 从`ParseWaterQualityJson`处理结果中读取指定范围和时间的观测数据 |
| `get_observation_of_cluster`      | 从`ParseWaterQualityJson`处理结果中读取聚类后的数据          |
| `get_observations_of_site_groups` | 从`ParseWaterQualityJson`处理结果中读取根据站点号分组的观测数据 |
| `observation_interpolation`       | 观测值插值并绘制地图                                         |
| `show_obs_and_emis`               | 同时绘制观测点和排放的位置                                   |
| `show_observations_per_quarter`   | 绘制每个季度的污染物的浓度                                   |

#### 源强估算：`trace`

| 文件名                                            | 内容                                                         |
| ------------------------------------------------- | ------------------------------------------------------------ |
| `GridClassificationTool`                          | 用于绘制虚拟排放点的C#写的WPF工具                            |
| `add_ini_bdy_tracer`                              | 向初始场和边界场中加入示踪剂                                 |
| `create_manual_virtual_emission_points`           | 创建包含由`GridClassificationTool`创建的虚拟排放点的河流文件 |
| `create_manual_virtual_emission_points_with_time` | 创建包含由`GridClassificationTool`创建的虚拟排放点的河流文件，排放流量随时间而改变 |
| `create_virtual_emission_points`                  | 创建包含由代码指定的排放点位置的河流文件                     |
| `export_mask`                                     | 创建海陆掩膜ASCII文件，供`GridClassificationTool`使用        |
| `show_contributions`                              | 绘制每个排放区域对研究区域的贡献                             |
| `trace`                                           | 对每种污染物、每个季节的污染源排放通量或浓度进行溯源，并绘制地图 |
| `trace_single`                                    | 对单个污染物和季节的污染源排放通量或浓度进行溯源，并绘制地图 |

#### 水动力：`water`

| 文件名             | 内容                                                         |
| ------------------ | ------------------------------------------------------------ |
| `DownloadTideData` | 从[海事服务网](https://www.cnss.com.cn/tide/)爬取指定站点的潮高数据 |
| `show_flow`        | 绘制24小时流场图                                             |
| `show_tide`        | 进行潮汐验证并绘图                                           |

#### 水交换：`water_exchange`

| 文件名                             | 内容                                     |
| ---------------------------------- | ---------------------------------------- |
| `add_water_exchange_dye`           | 向初始场文件中添加用于水交换研究的示踪剂 |
| `create_water_exchange_rivers`     | 创建用于水交换研究的不含示踪剂浓度的河流 |
| `get_points_in_range`              | 筛选在指定范围内的点集                   |
| `show_half_exchange_map`           | 绘制水体半交换时间地图                   |
| `show_tracer_map`                  | 绘制示踪剂浓度时间序列图                 |
| `show_tracer_percent_in_each_part` | 绘制不同示踪剂在不同区域中的浓度变化图   |

### 项目2：东海生态 `dh`

#### 输入文件制作：`input`

| 文件名                     | 内容                                                         |
| -------------------------- | ------------------------------------------------------------ |
| `add_bio_to_rivers`        | 向河流中添加生物河流。在`create_bio_rivers`后执行            |
| `add_real_bio_varibles`    | 向初始文件、边界文件、气候态文件中加入生物变量，并创建包含生物变量的河流文件 |
| `create_bio_rivers`        | 创建项目2河流                                                |
| `get_all_biology_var_info` | 包含需要写入的生物变量的信息                                 |

#### 模型验证及其对比：`compare`

| 文件名                         | 内容                                |
| ------------------------------ | ----------------------------------- |
| `compare_chl_with_clm`         | 与气候态文件中的叶绿素进行对比      |
| `compare_chl_with_CMEMS`       | 与CMEMS再分析资料比较叶绿素         |
| `compare_chl_with_oceancolour` | 与OceanColour遥感反演资料比较叶绿素 |
| `compare_SST_with_Argo`        | 与Argo浮标比较温度                  |
| `compare_SST_with_AVHRR`       | 与AVHRR卫星反演温度数据比较水温     |

#### 绘图：`graph`

| 文件名                          | 内容                             |
| ------------------------------- | -------------------------------- |
| `draw_biology_profile`          | 绘制用于该项目的剖面图           |
| `draw_biology_time_series_maps` | 绘制用于该项目的时间序列地图     |
| `draw_seasonal_currents`        | 绘制每个季节的海流               |
| `draw_seasonal_wind`            | 绘制每个季节的风                 |
| `draw_sensitivity_testing_bars` | 绘制敏感性试验中典型位置的条形图 |
| `draw_sensitivity_testing_maps` | 绘制敏感性试验中的地图           |

# 核心配置：`config.m`

在进行一切操作之前，首先需要编辑配置文件 `configs.m`。

## 路径

| 用户输入 | 子配置项        | 含义                                            | 格式       |
| -------- | --------------- | ----------------------------------------------- | ---------- |
| √       | `project_dir` | 项目目录，进行预处理的目录                      | `string` |
| √       | `build_dir`   | 模拟文件的输出目录，仅在Linux下直接后处理时指定 | `string` |

## time：时间

| 用户输入 | 子配置项         | 含义                 | 格式                           |
| -------- | ---------------- | -------------------- | ------------------------------ |
| √       | `start`        | 开始时间             | `int[6]`，分别为年月日时分秒 |
| √       | `stop`         | 结束时间             | `int[6]`，分别为年月日时分秒 |
|          | `start_julian` | 开始时刻的简化儒略日 |                                |
|          | `stop_julian`  | 结束时刻的简化儒略日 |                                |
|          | `days`         | 总天数               |                                |

## grid：网格

| 用户输入 | 子配置项        | 含义                        | 格式                                    |
| -------- | --------------- | --------------------------- | --------------------------------------- |
| √       | `longitude`   | 经度范围                    | `double[2]`，分别为西侧经度、东侧经度 |
| √       | `latitude`    | 经度范围                    | `double[2]`，分别为南侧纬度、北侧纬度 |
| √       | `size`        | 网格大小（分辨率）          | `int[2]`，分别为Lm、Mm                |
| √       | `N`           | 垂向分层                    | `int`                                 |
| √       | `theta_s`     | 地形跟随坐标θs参数         | `double`                              |
| √       | `theta_b`     | 地形跟随坐标θb参数         | `double`                              |
| √       | `Tcline`      | 地形跟随坐标关键深度参数    | `double`                              |
| √       | `Hmin`        | 最小深度值                  | `double`                              |
| √       | `Vtransform`  | 地形跟随坐标Vtransform参数  | `int`                                 |
| √       | `Vstretching` | 地形跟随坐标Vstretching参数 | `int`                                 |

## input：输入文件

| 用户输入 | 子配置项           | 含义           | 格式       |
| -------- | ------------------ | -------------- | ---------- |
| √       | `grid`           | 网格文件       | `string` |
| √       | `bot`            | 地形文件       | `string` |
| √       | `force`          | 气象强迫场文件 | `string` |
| √       | `climatology`    | 气候强迫场文件 | `string` |
| √       | `initialization` | 初始场文件     | `string` |
| √       | `boundary`       | 边界场文件     | `string` |
| √       | `tides`          | 潮汐强迫场文件 | `string` |
| √       | `rivers`         | 河流文件       | `string` |

## output：输出文件

| 用户输入 | 子配置项    | 含义       | 格式       |
| -------- | ----------- | ---------- | ---------- |
| √       | `hisotry` | 历史文件   | `string` |
| √       | `floats`  | 漂浮子文件 | `string` |

## res：数据资源路径

#### 气象

| 用户输入 | 子配置项                     | 含义                                                         | 格式             |
| -------- | ---------------------------- | ------------------------------------------------------------ | ---------------- |
| √        | `force_ncep_dir`             | NCEP FNL数据的文件夹位置<br />需要下载[NCEP的FNL数据](https://rda.ucar.edu/datasets/ds083.2/)，作为气象强迫文件的插值源。 | `string`         |
| √        | `force_ncep_step`            | 所提供的NCEP FNL数据的时间分辨率                             | `double`（小时） |
| √        | `force_ncep_radiation_files` | 包含辐射数据的NCEP DS083.3数据的文件通配名                   | `string`         |
| √        | `force_era5_radiation_file`  | 包含辐射数据的ERA5数据的文件名                               | `string`         |

#### 地形

| 用户输入 | 子配置项                                                     | 含义                                                         | 格式     |
| -------- | ------------------------------------------------------------ | ------------------------------------------------------------ | -------- |
| √        | `elevation`                                                  | 全球地形文件，用于网格文件的插值<br />ETOPO1可以从[此处](https://www.ngdc.noaa.gov/mgg/global/)下载，选择Cell/pixel-registered，netCDF，...gmt4.grd.gz<br />SRTM15可以从[此处](https://topex.ucsd.edu/WWW_html/srtm15_plus.html)下载，选择[FTP SRTM15+ and source identification (SID)](https://topex.ucsd.edu/pub/srtm15_plus/)，[SRTM15_V2.4.nc](https://topex.ucsd.edu/pub/srtm15_plus/SRTM15_V2.4.nc) | `string` |
| √        | `elevation_longitude`<br />`elevation_latitude`<br />`elevation_altitude` | 高程文件中经度、纬度、海拔的字段名                           | `string` |
| √        | `gshhs_f`                                                    | 全球海岸线文件<br />用于编辑水陆点，可以从[此处](https://www.soest.hawaii.edu/pwessel/gshhg/)下载，选择binary files。 | `string` |

#### 潮汐

| 用户输入 | 子配置项              | 含义                                                         | 格式     |
| -------- | --------------------- | ------------------------------------------------------------ | -------- |
| √        | `tpx_uv`<br />`tpx_h` | 潮汐文件<br />用于制作潮汐文件，可以从[此处](https://coawstmodel.sourcerepo.com/coawstmodel/data/tide/)下载。 | `string` |
| √        | `tpxo9`               | 高精度TPXO9的潮汐文件所在目录                                | `string` |
| √        | `tpxo9_days`          | 使用TPXO9的潮汐时，指定估计的模拟总时间（天）                | `int`    |

#### 水文（本地）

| 用户输入 | 子配置项                                                     | 含义                                                         | 格式              |
| -------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ----------------- |
| √        | `hydrodynamics`                                              | 本地海洋数据的位置                                           | `string`          |
|          | `hydrodynamics_type`                                         | 本地海洋数据的数据源                                         | `"HYCOM"|"CMEMS"` |
| √        | `hydrodynamics_step_time_hour`                               | 本地海洋数据的时间分辨率                                     | `double`（小时）  |
| √        | `_latitude`<br />`_longitude`<br />`_depth`<br />`_time`<br />`_u`<br />`_v`<br />`_temp`<br />`_salt`<br />`_surface_elevation` | 本地海洋数据的经度、纬度、深度、时间、U速度、V速度、温度、盐度、海表高度变量名 | `string`          |
| √        | `hycom_t0dt`                                                 | 本地海洋数据的基准时间                                       | `datetime`        |
|          | `hycom_t0`                                                   | 以日为单位存储的本地海洋数据的基准时间                       | `double`          |
| √        | `hycom_tunit`                                                | 本地海洋数据中1个时间单位表示的时间长度                      | `double`（小时）  |

## tracer：示踪剂

| 用户输入 | 子配置项                                             | 含义                              | 格式                                                                                                          |
| -------- | ---------------------------------------------------- | --------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| √       | `count`                                            | 示踪剂图层数量                    | `int`                                                                                                       |
| √       | `age`                                              | 是否启用平均年龄 `AGE_MEAN`功能 | `logical`                                                                                                   |
| 延迟     | `densities`                                        | 示踪剂的浓度                      | `{double[grid.size(1)+1,grid.size(2)+1,grid.N,tracer.count]}`<br />元胞数组的长度应与配置的示踪剂数量相同。 |
| 延迟     | `ages`                                             | 示踪剂的初始年龄                  | `{double[grid.size(1)+1,grid.size(2)+1,grid.N,tracer.count]}`<br />元胞数组的长度应与配置的示踪剂数量相同。 |
| 延迟     | `east`<br />`west`<br />`south`<br />`north` | 边界示踪剂的浓度                  | `{double[grid.size(1/2),grid.N,tracer.count]}`<br />元胞数组的长度应与配置的示踪剂数量相同。                |

## rivers：河流

| 用户输入 | 子配置项               | 含义               | 格式                                                                                                                                                    |
| -------- | ---------------------- | ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| √       | `count`              | 河流数量           | `int`                                                                                                                                                 |
| 延迟     | `location`           | 河流所在的坐标     | `int[rivers.count,2]`<br />行数为河流数量，每一行分别为横坐标和纵坐标。<br />`LuvSrc`时，指的是U/V面的位置；`LwSrc`时，指的是ρ点的位置。         |
| 延迟     | `direction`          | 流向               | `int[rivers.count,2]`<br />`LuvSrc`时，值为0（U方向）或1（V方向）；`LwSrc`时，值为2                                                               |
| 延迟     | `time`               | 时间               | `double[]`<br />应覆盖模拟时间段                                                                                                                      |
| 延迟     | `transport`          | 流量               | `double[rivers.count,grid.N,rivers.time]`<br />`LuvSrc`时，具有正负，正值代表向数值更大的方向流动；`LwSrc`时，恒为正数。<br />单位：$m ^ 3 / s$ |
| 延迟     | `v_shape`            | 垂向流量分配       | `double[rivers.count,grid.N]`<br />流量在垂直层上的分布的百分比，每一列的总和应当为1。                                                                |
| 延迟     | `temp`<br />`salt` | 温度<br />盐度     | `double[rivers.count,grid.N,rivers.time]`<br />单位分别为摄氏度、？                                                                                   |
| 延迟     | `dye`<br />`ages`  | 示踪剂及其初始年龄 | `{double[rivers.count,grid.N,rivers.time]}`<br />元胞数组的长度应与配置的示踪剂数量相同。                                                             |

## biology：生物

| 用户输入 | 子配置项 | 含义             | 格式                |
| -------- | -------- | ---------------- | ------------------- |
| √        | `model`  | 所使用的生物模型 | `"fennel"|"cosine"` |

## io：输入输出

| 用户输入 | 子配置项    | 含义           | 格式                                                        |
| -------- | ----------- | -------------- | ----------------------------------------------------------- |
| √       | `deflate` | 压缩机别 | `int[0:9]`<br />越大，压缩机别越高，0表示不压缩 |
| √ | `shuffle` | 压缩时是否开启乱序数据写入 | `logical` |

# 项目配置：`project_data.m`

## 字符串常量：`strs`

| 配置名     | 含义       |
| ---------- | ---------- |
| `language` | 语言       |
| `axis_*`   | 坐标系标签 |
| `tide_*`   | 潮站名     |
| `legend_*` | 图例名     |
| `title_*`  | 图名       |

## 项目通用常量：`projectData`

| 配置名            | 含义                                                       |
| ----------------- | ---------------------------------------------------------- |
| `pollutionNames`  | 污染物的名称                                               |
| `studyRange`      | 研究区域（能完全包含杭州湾的多边形）                       |
| `obsRange`        | 用于对比和溯源的观测值的选取区域                           |
| `maxValue`        | 各污染物能够达到的最大浓度（用于绘图）                     |
| `colormapSteps`   | 各污染物的`colorbar`的段数                                 |
| `bdy`             | 各污染物的边界强迫浓度                                     |
| `factor`          | 各指标的污染源（河流、排污口）浓度与海洋（监测）浓度的比值 |
| `excludeSites`    | 对结果进行对比和评估时，排除的异常值站点的站点号（废弃）   |
| `emissionList`    | 排放清单Excel文件                                          |
| `observationInfo` | 水质观测数据CSV文件                                        |

## 源强估算常量：`traceData`

| 配置名             | 含义                                                         |
| ------------------ | ------------------------------------------------------------ |
| `obsExtra`         | 额外的虚拟观测站的位置（前两列）和浓度值                     |
| `partCount`        | 排放区域的数量                                               |
| `riverPartCount`   | 排放区域中，属于河流的数量                                   |
| `simFluxs`         | 各区域（列）的每个月份（行）的流量，其中河流使用真实流量，考虑月流量的不同，其他使用恒定值 |
| `refFluxs`         | 不同污染物（行），不同沿岸排放区域（列）的基于沿海排污数据的参考污染物通量 |
| `refConcentration` | 不同污染物（行），不同河流排放区域（列）的基于河流水质数据的参考污染物通量 |
| `partNames`        | 各部分的名称                                                 |
| `pointPerPart`     | 每个部分的实际排放点数量                                     |
| `maxValues`        | 各污染物能够达到的最大浓度（用于绘图）                       |
| `repeat`           | 每个示踪剂的重复生成次数。总的生成示踪剂数量为$(partCount+1) \times repeat$ |

## 生态常量：`bioData`

| 配置名               | 含义                             |
| -------------------- | -------------------------------- |
| `tests`              | 敏感性试验案例地址               |
| `testNames`          | 敏感性试验案例名                 |
| `locations`          | 典型位置经纬度坐标               |
| `locationNames`      | 典型位置地名                     |
| `colorRanges`        | 每类变量在表层的值域             |
| `profileColorRanges` | 每类变量在绘制剖面图时的值域     |
| `maxDepth`           | 每类变量在绘制剖面图时的最大深度 |
| `varName`            | 每个变量的名称                   |
| `dh`                 | 东海的经纬度坐标范围             |

## 绘图常量：`graphData`

| 配置名                     | 含义                                   |
| -------------------------- | -------------------------------------- |
| `*Values/Labels`           | 需要在地图坐标轴上注明的经纬度值和标签 |
| `landColor`                | 用来表示陆地的颜色                     |
| `fontSize`/`lagerFontSize` | 字体大小                               |
| `font`                     | 字体                                   |

# ROMS

## 创建网格

使用 `GridBuilder`来创建网格。

~~首先执行 `roms_create_grid_from_wrfinput`，从 `wrfinput`创建网格，在弹出的窗口中根据海岸线编辑水陆点；或执行 `roms_create_grid_core`，根据高程文件来创建网格。。然后执行 `roms_fill_grid_h`填充水深。~~

## 边界场、初始场、全域逼近场

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
- 全域逼近文件（若需要）：`roms_clm.nc`
- 潮汐强迫文件（若需要）：`roms_tides.nc`
- 河流强迫文件（若需要）：`roms_rivers.nc`

# 其他

## ROMS创建嵌套网格

由于暂时没有需求，因此没有写成工具。
查看WRF网格和ROMS父网格的位置：

```matlab
netcdf_load('wrfinput_d01') 
figure 
pcolorjw(XLONG,XLAT,double(1-LANDMASK)) 
hold on 
netcdf_load('wrfinput_d02') 
pcolorjw(XLONG,XLAT,double(1-LANDMASK)) 
plot(XLONG(1,:),XLAT(1,:),'r'); plot(XLONG(end,:),XLAT(end,:),'r') 
plot(XLONG(:,1),XLAT(:,1),'r'); plot(XLONG(:,end),XLAT(:,end),'r') 
% plot roms parent grid 
netcdf_load(roms_grid); 
plot(lon_rho(1,:),lat_rho(1,:),'k'); 
plot(lon_rho(end,:),lat_rho(end,:),'k') 
plot(lon_rho(:,1),lat_rho(:,1),'k'); 
plot(lon_rho(:,end),lat_rho(:,end),'k') 
text(-75,29,'roms parent grid') 
text(-77,27,'wrf parent grid') 
text(-77.2,34,'wrf child grid') 
```

确定ROMS子网格的位置：

```matlab
Istr=22; Iend=60; Jstr=26; Jend=54; %确定范围
plot(lon_rho(Istr,Jstr),lat_rho(Istr,Jstr),'m+') 
plot(lon_rho(Istr,Jend),lat_rho(Istr,Jend),'m+') 
plot(lon_rho(Iend,Jstr),lat_rho(Iend,Jstr),'m+') 
plot(lon_rho(Iend,Jend),lat_rho(Iend,Jend),'m+') 
ref_ratio=3; %子网格的密度是父网格的3倍。计算公式是：(60-22)*3-1,(54-26)*3-1=116,86
roms_child_grid='....nc'; 
%coarse2fine是自定义函数，用于创建分辨率更高的ROMS网格。F = coarse2fine(Ginp,Gout,Gfactor,Imin,Imax,Jmin,Jmax)
%给定一个粗分辨率nc文件(Ginp)，此函数在粗网格坐标(Imin,Jmin)和(Imax,Jmax)指定的区域中创建一个更细分辨率的网格。请注意(Imin,Jmin)和(Imax,Jmax)索引是根据psi点的，因为它实际上定义了精细网格的物理边界。网格细化系数用Gfactor指定。
F=coarse2fine(roms_grid,roms_child_grid, ref_ratio,Istr,Iend,Jstr,Jend); 
Gnames={roms_grid,roms_child_grid}; 
[S,G]=contact(Gnames,'roms_contact.nc'); %这个输出文件之后用于in文件中的NGCNAME参数
%contact是自定义函数，用于设置ROMS嵌套网格之间的接触点。contact(Gnames, Cname, Lmask, MaskInterp, Lplot)，参数分别为输入nc文件名、输出nc文件名，后面三个都有默认值。输入文件名需要按从大到小的顺序。
```

计算子网格的水深：

```matlab
netcdf_load(roms_child_grid) 
load USeast_bathy.mat 
h=griddata(h_lon,h_lat,h_USeast,lon_rho,lat_rho); %拟合，获得一个116*86的矩阵
%vq = griddata(x,y,v,xq,yq) 使 v = f(x,y) 形式的曲面与向量 (x,y,v) 中的散点数据拟合。griddata 函数在 (xq,yq) 指定的查询点对曲面进行插值并返回插入的值 vq。曲面始终穿过 x 和 y 定义的数据点。
h(isnan(h))=5; 
h(2:end-1,2:end-1)=0.2*(h(1:end-2,2:end-1)+h(2:end-1,2:end-1)+h(3:end,2:end-1)+h(2:end-1,1:end-2)+h(2:end-1,3:end)); 
ncwrite(roms_child_grid,'h',h)
%下面都是画图
figure 
pcolorjw(lon_rho,lat_rho,h) 
hold on 
load coastline.mat 
plot(lon,lat,'r') 
caxis([5 2500]); colorbar 
```

基于WRF的掩膜重新计算ROMS的掩膜：

```matlab
netcdf_load('wrfinput_d01'); 
%原文档中用的是TriScatteredInterp，但是MATLAB文档显示不推荐使用TriScatteredInterp，因此换成了scatteredInterpolant。这两个函数功能是相同的，不过TriScatteredInterp是老版函数
F = scatteredInterpolant(double(XLONG(:)),double(XLAT(:)),double(1-LANDMASK(:)),'nearest'); 
roms_mask=F(lon_rho,lat_rho); 

water = double(roms_mask); 
u_mask = water(1:end-1,:) & water(2:end,:); 
v_mask= water(:,1:end-1) & water(:,2:end); 
psi_mask= water(1:end-1,1:end-1) & water(1:end-1,2:end) & water(2:end,1:end-1) & water(2:end,2:end); 
ncwrite(roms_child_grid,'mask_rho',roms_mask); 
ncwrite(roms_child_grid,'mask_u',double(u_mask)); 
ncwrite(roms_child_grid,'mask_v',double(v_mask)); 
ncwrite(roms_child_grid,'mask_psi',double(psi_mask));

%下面都是画图
figure 
pcolorjw(lon_rho,lat_rho,roms_mask) 
hold on 
plot(lon,lat,'r') 
```

## 海洋数据下载

其中有个[网址](http://tds.hycom.org/thredds/dodsC/GLBa0.08/expt_90.9)，来自于[HYCOM](http://tds.hycom.org/thredds/catalog.html)（hybrid coordinate ocean model，混合坐标海洋模型）。这里选用的是GOFS 3.0: HYCOM + NCODA Global 1/12° Analysis (NRL)-[`GLBu0.08/expt_90.9 (2012-05 to 2013-08)/`](http://tds.hycom.org/thredds/catalogs/GLBu0.08/expt_90.9.html)，选择[Hindcast Data: May-2012 to Aug-2013](http://tds.hycom.org/thredds/catalogs/GLBu0.08/expt_90.9.html?dataset=GLBu0.08-expt_90.9)，然后选择OPeNDAP：[//tds.hycom.org/thredds/dodsC/GLBu0.08/expt_90.9](http://tds.hycom.org/thredds/dodsC/GLBu0.08/expt_90.9.html)，其中有个Data URL后面就是所需要的地址。

> OPeNDAP是一个专门为本地系统透明的访问远程数据的客户端服务器系统，采用此系统客户端无需知道服务器端的存储格式、架构以及所采用的环境

进入[Revision 41](https://coawstmodel.sourcerepo.com/coawstmodel/data/)，选择[tide](https://coawstmodel.sourcerepo.com/coawstmodel/data/tide/)，下载[adcirc..](https://coawstmodel.sourcerepo.com/coawstmodel/data/tide/adcirc_ec2001v2e_fix.mat)或[tpx_h.mat](https://coawstmodel.sourcerepo.com/coawstmodel/data/tide/tpx_h.mat)和[tpx_uv.mat](https://coawstmodel.sourcerepo.com/coawstmodel/data/tide/tpx_uv.mat)。这个网站用IE才能打开，Chromium打不开，因为加密方式太老了。

编辑 `Tools/mfiles/tides/create_roms_tides`。修改 `Gname`到网格路径。修改 `g`到模拟的开始时间。如果用adcirc，那么修改 `if (adcirc)`后的路径。如果用ocu，那么修改上面到 `adcirc=0;osu=1`，然后修改 `if (osu)`后的路径。这里需要用ocu，用adcirc会报错。

## SWAN生成边界场文件代码的修改

在用户手册（3.4/3.7）中，提供了两种方法：TPAR (parametric foring files)或2D Spec files (spectral foring files)。但是由于数据源的格式和地址发生了改变，因此两种方法全部失效。在COAWST3.7中，更新了相关的Matlab工具，但是手册尚未更新。因此最新的工具进行介绍自己摸索出来的方法。

目前此处数据源来自于：[NCEP WAVEWATCH III Hindcast and Reanalysis Archives](https://polar.ncep.noaa.gov/waves/hindcasts/multi_1/) 。数据介绍见 [README.txt](COAWST.assets\README.txt) 。

打开 `Tools/mfiles/swan_forc/create_swanTpar_from_WW3.m`，编辑：

```matlab
working_dir='C:\Users\autod\Desktop\maria' %工作路径
yearww3='2018' %年份
mmww3='07' %月份
modelgrid='C:\Users\autod\Desktop\maria\roms_grid.nc'; %SWAN（未测试）或者ROMS网格的路径
specres=20; %每一条边界的长度，这个数值越大，生成的文件越少。
ww3_grid='glo_30m' %数据源。这里选的glo_30m是全球30m数据。
```

~~可以直接执行，但是程序会下载整个月的数据，分辨率为3小时，每个小时的数据大约需要1分钟。目前不知道为什么要下载整个月的数据。~~

~~对同目录下的 `readww3_2TPAR.m`进行修改，找到 `timeww3=ncread(hsurl,'time'); timeww3=timeww3(1:end-1);`这两行，这两行取了全部的月份。在这两行下面添加一行：`timeww3=[(<起始日>-1)*8:<结束日>*8];`（经查看，数据分辨率为3小时）~~

~~这样就只会生成所需要的日期的边界数据了。~~

~~生成的数据包括 `Bound_spec_command`和一系列的 `TPAR*.txt`。前者中的命令需要复制到SWAN的配置文件中。~~

在[NCEI网站](https://www.ncei.noaa.gov/thredds-ocean/catalog/ncep/nww3/catalog.html)下载所需要的数据，进入所需要的年份和月份，进入 `gribs`，打开 `multi_1.glo_30m.tp|hs|dp.*.grb2`三个文件，选择其中的HTTPServer进行下载。也可以直接在[NCEP网站](https://polar.ncep.noaa.gov/waves/hindcasts/multi_1/)中下载。

下载完之后是3个grib2文件，使用 `wgrib2.exe <输入grib2文件> -netcdf <输出nc文件>`转换为nc文件。

由于OPeNDAP提供的变量名等与进入 `create_swanTpar_from_WW3`，修改：

1. 重新指定 `tpurl`、`hsurl`、`dpurl`的链接为三个nc文件的路径
2. 修改变量：

   1. `ncread(hsurl,'lon')`→`ncread(hsurl,'longitude')`
   2. ``ncread(hsurl,'lat')`→`ncread(hsurl,'latitude')`
   3. `Significant_height_of_combined_wind_waves_and_swell_surface`→`HTSGW_surface`
   4. `Primary_wave_mean_period_surface`→`PERPW_surface`
   5. `Primary_wave_direction_surface`→`DIRPW_surface`
3. 由于从OPeNDAP获取的数据和转成nc以后的数据存在左右的翻转，因此需要去掉几个 `fliplr`函数：

   1. `griddedInterpolant(daplon,fliplr(daplat),fliplr(hs),method)`→`griddedInterpolant(daplon,daplat,hs,method)`
   2. `FCr.Values=fliplr(tp)`→`FCr.Values=tp`
   3. `FCr.Values=fliplr(Dwave_Ax)`→`FCr.Values=Dwave_Ax`
   4. `FCr.Values=fliplr(Dwave_Ay)`→`FCr.Values=Dwave_Ay`
4. 在 `timeww3`的定义后修改循环为：

   ```matlab
   for mm=1:length(timeww3)
       timeww3(mm)=index; %手动提供时间索引
       index=index+1;
       time(mm)=datenum(str2num(yearww3),str2num(mmww3),1,timeww3(mm)*3,0,0); %3是指分辨率为3x
   end
   ```
