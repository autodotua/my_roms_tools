function [varNames,varDescriptions]=get_all_biology_vars(model)
    if ~exist('model','var')
        configs
        model=roms.biology.model;
    end
    if model=="cosine"
        varNames = ["NO3", "NH4", "SiOH", "PO4", "S1_N", ...
            "S1_C", "S1CH", "S2_N", "S2_C", "S2CH", ...
            "S3_N", "S3_C", "S3CH", "Z1_N", "Z1_C", ...
            "Z2_N", "Z2_C", "BAC_", "DD_N", "DD_C", ...
            "DDSi", "LDON", "LDOC", "SDON", "SDOC", ...
            "CLDC", "CSDC", "DDCA", "oxyg", "Talk", ...
            "TIC", "S1_Fe", "S2_Fe", "S3_Fe", "FeD"];
        varDescriptions = [
            "硝酸盐NO3", "铵盐NH4", "硅酸盐SiO4", "磷酸盐PO4", "小型浮游植物氮" ...
            "小型浮游植物碳", "小型浮游植物叶绿素", "硅藻氮", "硅藻碳", "硅藻叶绿素"...
            "石藻氮", "石藻碳", "石藻叶绿素", "小型浮游动物氮", "小型浮游动物碳"...
            "中型浮游动物氮", "中型浮游动物碳", "细菌", "碎屑氮", "碎屑碳"...
            "生物硅酸盐", "可溶性有机氮", "可溶性有机碳", "半可溶性有机氮", "半可溶性有机碳"...
            "有色可溶性有机碳", "有色半可溶性有机碳", "颗粒无机碳", "溶解氧", "总碱度"...
            "总二氧化碳", "小型浮游植物铁", "硅藻铁", "石藻铁", "可用溶解铁"
            ];
    elseif model=="fennel"
        varNames=["NO3" "NH4" "PO4" ...
            "chlorophyll" "phytoplankton" "zooplankton" ...
            "LdetritusN" "LdetritusC" "SdetritusN" "SdetritusC" ...
            "TIC" "alkalinity" "oxygen"];
        varDescriptions=["硝酸盐NO3", "铵盐NH4" "磷酸盐PO4" ...
            "叶绿素" "浮游植物" "浮游动物"...
            "大碎屑-氮" "大碎屑-碳" "小碎屑-氮" "小碎屑-碳" ...
            "总无机碳" "总碱度" "溶解氧"];
    else
        error("未知生态模型")
    end
end