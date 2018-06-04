;;; moisture_flux_heat_prec_wind.ncl ;;;
; Author      - Ueslei Adriano Sutil   ;
; Created     - 24 May 2018            ;
; Last update - 24 May 2018            ;
;                                      ;
; About: This scrpts creates several plots of the moisture flux vertically
;        integrated,
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Prototype scripts.
print("Stage 1: Loading prototype scripts.")
load "/home/ueslei/NCL/loads.ncl"
begin

; Allocate more memory.
print("Stage 2: Allocating memory.")
setvalues NhlGetWorkspaceObjectId()
 "wsMaximumSize" : 700000000
end setvalues

; Open files.
print("Stage 3: Opening files.")
wrf_normal = addfile("/media/ueslei/Ueslei/SC_2008/Outputs/wrf_normal.nc","r")
wrf_cold   = addfile("/media/ueslei/Ueslei/SC_2008/Outputs/wrf_cold.nc","r")
t_step     = 12
spacing    = 5
level      = 0

; Workspace options.
print("Stage 4: Setting workspace options.")
pltType          = "png"
pltType@wkWidth  = 3000
pltType@wkHeight = 3000
pltName          = "moisture_flux"
pltDir           = "./"
pltPath          = pltDir + pltName
wks              = gsn_open_wks(pltType, pltName)
cmap1            = read_colormap_file("MPL_RdBu")
cmap             = cmap1(::-1,:)
prec_color       = read_colormap_file("WhViBlGrYeOrRe")
hgt_color        = read_colormap_file("OceanLakeLandSnow")
gsn_define_colormap(wks, "MPL_jet")

; Get variables.
print("Stage 5: Extracting latitude and longitude variables.")
lat              = wrf_cold->XLAT(t_step,::spacing,0)
lon              = wrf_cold->XLONG(t_step,0,::spacing)

; COA_normal.
print("Stage 6: Extracting COA_normal variables.")
uvm_normal       = wrf_user_getvar(wrf_normal,"uvmet",t_step)
u_normal         = uvm_normal(0,:,::spacing,::spacing)
v_normal         = uvm_normal(1,:,::spacing,::spacing)
mix_ratio_normal = wrf_normal->QVAPOR(t_step,:,::spacing,::spacing)
lh_normal        = wrf_normal->LH(t_step,::spacing,::spacing)
sh_normal        = wrf_normal->HFX(t_step,::spacing,::spacing)
prec_normal      = wrf_normal->RAINNC(t_step,::spacing,::spacing)
p_normal         = wrf_normal->P(t_step,:,::spacing,::spacing)
pb_normal        = wrf_normal->PB(t_step,:,::spacing,::spacing)
ppb_normal       = (p_normal+pb_normal)*0.01
ppb_normal@description = "Pressure"
ppb_normal@units       = "hPa"
delete([/p_normal,pb_normal/])

; COA_cold.
print("Stage 7: Extracting COA_cold variables.")
uvm_cold         = wrf_user_getvar(wrf_cold,"uvmet",t_step)
u_cold           = uvm_cold(0,:,::spacing,::spacing)
v_cold           = uvm_cold(1,:,::spacing,::spacing)
mix_ratio_cold   = wrf_cold->QVAPOR(t_step,:,::spacing,::spacing)
lh_cold          = wrf_cold->LH(t_step,::spacing,::spacing)
sh_cold          = wrf_cold->HFX(t_step,::spacing,::spacing)
prec_cold        = wrf_cold->RAINNC(t_step,::spacing,::spacing)
p_cold           = wrf_cold->P(t_step,:,::spacing,::spacing)
pb_cold          = wrf_cold->PB(t_step,:,::spacing,::spacing)
ppb_cold         = (p_cold+pb_cold)
ppb_cold@description = "Pressure"
ppb_cold@units       = "hPa"
delete([/p_cold,pb_cold/])

; Calculate Specific Humidity and difference between runs.
print("Stage 8: Calculating specific humidity and difference between runs.")
spec_hum_normal     = mix_ratio_normal/(1+mix_ratio_normal)
spec_hum_cold       = mix_ratio_cold/(1+mix_ratio_cold)

spec_hum_normal_sup = spec_hum_normal(0,:,:)*1000
spec_hum_cold_sup   = spec_hum_cold(0,:,:)*1000
spec_hum_diff_sup   = spec_hum_normal_sup-spec_hum_cold_sup

; Calculate Total Heat Flux and difference between runs.
print("Stage 9: Calculating Total Heat FLux and difference between runs.")
thf_normal = lh_normal  + sh_normal
thf_cold   = lh_cold    + sh_cold
thf_diff   = thf_normal - thf_cold
delete([/lh_normal,sh_normal,lh_cold,sh_cold/])

; Calculate Precipitation difference between runs.
print("Stage 10: Calculating Precipitation difference between runs.")
prec_diff = prec_normal-prec_cold

; Interpolates Specific Humidity and Wind components then calculates Moisture Flux Vertically Integrated over 1000 to 850 hPa.
; COA_normal
print("Stage 11:  Interpolates Specific Humidity and Wind componentsm then calculates Moisture Flux Vertically Integrated over 1000 to 850 hPa for COA_normal.")
q_plane_normal_1000 = wrf_user_intrp3d(spec_hum_normal,ppb_normal,"h",1000,0.,False)
q_plane_normal_850  = wrf_user_intrp3d(spec_hum_normal,ppb_normal,"h",850,0.,False)
u_plane_normal_1000 = wrf_user_intrp3d(u_normal,ppb_normal,"h",1000,0.,False)
u_plane_normal_850  = wrf_user_intrp3d(u_normal,ppb_normal,"h",850,0.,False)
v_plane_normal_1000 = wrf_user_intrp3d(v_normal,ppb_normal,"h",1000,0.,False)
v_plane_normal_850  = wrf_user_intrp3d(v_normal,ppb_normal,"h",850,0.,False)

mfvi_u_normal       = (((u_plane_normal_1000*q_plane_normal_1000)-(u_plane_normal_850*q_plane_normal_850)/2)*(1000-850))
mfvi_v_normal       = (((v_plane_normal_1000*q_plane_normal_1000)-(v_plane_normal_850*q_plane_normal_850)/2)*(1000-850))


; COA_cold
print("Stage 12: Interpolates Specific Humidity and Wind components then calculates Moisture Flux Vertically Integrated over 1000 to 850 hPa for COA_cold.")
q_plane_cold_1000 = wrf_user_intrp3d(spec_hum_cold,ppb_cold,"h",1000,0.,False)
q_plane_cold_850  = wrf_user_intrp3d(spec_hum_cold,ppb_cold,"h",850,0.,False)
u_plane_cold_1000 = wrf_user_intrp3d(u_cold,ppb_cold,"h",1000,0.,False)
u_plane_cold_850  = wrf_user_intrp3d(u_cold,ppb_cold,"h",850,0.,False)
v_plane_cold_1000 = wrf_user_intrp3d(v_cold,ppb_cold,"h",1000,0.,False)
v_plane_cold_850  = wrf_user_intrp3d(v_cold,ppb_cold,"h",850,0.,False)

mfvi_u_cold       = (((u_plane_cold_1000*q_plane_cold_1000)-(u_plane_cold_850*q_plane_cold_850)/2)*(1000-850))
mfvi_v_cold       = (((v_plane_cold_1000*q_plane_cold_1000)-(v_plane_cold_850*q_plane_cold_850)/2)*(1000-850))

print("Stage 13: Calculate the difference between COA_normal and COA_cold Moisture Flux Advenction.")
mfvi_diff_u      = mfvi_u_normal-mfvi_u_cold
mfvi_diff_v      = mfvi_v_normal-mfvi_v_cold

mfvi_diff_u_2    = mfvi_u_normal-mfvi_u_cold
mfvi_diff_v_2    = mfvi_v_normal-mfvi_v_cold

print("Stage 14: Calculate COA_normal and COA_cold Moisture Flux Advenction Divergence.")
mfvid_cold1   = uv2dv_cfd(mfvi_u_cold,mfvi_v_cold,lat,lon,0)
mfvid_cold    = mfvid_cold1*100000
mfvid_normal1 = uv2dv_cfd(mfvi_u_normal,mfvi_v_normal,lat,lon,0)
mfvid_normal  = (mfvid_normal1)*100000
mfvid_diff    = mfvid_normal-mfvid_cold

; Resources
print("Stage 14: Setting plot resources.")
plot                            = new(21,graphic)
res                             = True
res@gsnDraw                     = False
res@gsnFrame                    = False
res@lbLabelBarOn                = True
res@cnInfoLabelOn               = False
res@gsnLeftString               = ""
res@gsnRightString              = ""
res@gsnLeftStringFontHeightF    = 0.001
res@cnLineLabelsOn              = False
res@cnFillOn                    = True
res@cnLinesOn                   = False
res@tmYROn                      = False
res@tmXTOn                      = False
res@tmXBTickSpacingF            = 1.
res@tmYLTickSpacingF            = 1
res@tmXBLabelFontHeightF        = 0.015
res@tmYLLabelFontHeightF        = 0.015
res@tiMainString                = " "
res@mpLimitMode                 = "LatLon"
res@mpMinLatF                   = -29.
res@mpMaxLatF                   = -24.
res@mpMinLonF                   = -50.
res@mpMaxLonF                   = -44.
res@gsnAddCyclic                = False
res@mpFillOn                    = True
res@mpPerimOn                   = True
res@mpGridAndLimbOn             = False
res@mpOutlineOn                 = True
res@mpOutlineBoundarySets       = "National"
res@mpDataSetName               = "Earth..4"
res@mpDataBaseVersion           = "MediumRes"
res@mpOutlineSpecifiers         = (/"Brazil:states"/)
res@lbTitleOn                   = True
res@lbTitleString               = " "
res@lbTitleFontHeightF          = 0.015
res@lbTitlePosition             = "Bottom"
res@lbLabelFontHeightF          = 0.015
res@lbBoxSeparatorLinesOn       = False
res@lbTitleOffsetF              = 0.2
res@pmLabelBarOrthogonalPosF    = 0.15
res@pmLabelBarWidthF            = 0.5
res@pmLabelBarHeightF           = 0.06
res@mpProvincialLineColor       = "black"
res@mpGeophysicalLineColor      = "black"
res@mpNationalLineColor         = "black"
res@mpLandFillColor             = "white"
res@mpProvincialLineThicknessF  = 2
res@mpNationalLineThicknessF    = 2
res@mpGeophysicalLineThicknessF = 2.0
res@sfXArray                    = lon
res@sfYArray                    = lat
res@pmTickMarkDisplayMode       = "Always"

; COA_normal - Specific Umidity.
res_sp_normal_sup                           = res
res_sp_normal_sup@cnFillOn                  = True
res_sp_normal_sup@cnLinesOn                 = False
res_sp_normal_sup@cnLevelSelectionMode      = "ManualLevels"
res_sp_normal_sup@cnMinLevelValF            = 8
res_sp_normal_sup@cnMaxLevelValF            = 14
res_sp_normal_sup@cnLevelSpacingF           = 0.05
res_sp_normal_sup@lbLabelFontHeightF        = 0.014
res_sp_normal_sup@lbTitleFontHeightF        = .015
res_sp_normal_sup@lbTitleString             = "[g kg~S~-1~N~]"
res_sp_normal_sup@lbOrientation             = "Horizontal"
res_sp_normal_sup@lbTitleFontThicknessF     = 1
res_sp_normal_sup@pmLabelBarOrthogonalPosF  = 0.139
res_sp_normal_sup@pmLabelBarWidthF          = 0.5
res_sp_normal_sup@pmLabelBarHeightF         = 0.059
res_sp_normal_sup@gsnCenterString           = "Specific Humidity:~C~         COA~B~normal~N~"
res_sp_normal_sup@sfXArray                  = lon
res_sp_normal_sup@sfYArray                  = lat
;res_sp_normal_sup@lbLabelAngleF             = -30
res_sp_normal_sup@lbLabelAutoStride         = False
res_sp_normal_sup@lbLabelStride             = 10

; COA_cold - Specific Umidity.
res_sp_cold_sup                           = res
res_sp_cold_sup@cnFillOn                  = True
res_sp_cold_sup@cnLinesOn                 = False
res_sp_cold_sup@cnLevelSelectionMode      = "ManualLevels"
res_sp_cold_sup@cnMinLevelValF            = 8
res_sp_cold_sup@cnMaxLevelValF            = 14
res_sp_cold_sup@cnLevelSpacingF           = 0.05
res_sp_cold_sup@lbLabelFontHeightF        = 0.014
res_sp_cold_sup@lbTitleFontHeightF        = .015
res_sp_cold_sup@lbTitleString             = "[g kg~S~-1~N~]"
res_sp_cold_sup@lbOrientation             = "Horizontal"
res_sp_cold_sup@lbTitleFontThicknessF     = 1
res_sp_cold_sup@pmLabelBarOrthogonalPosF  = 0.139
res_sp_cold_sup@pmLabelBarWidthF          = 0.5
res_sp_cold_sup@pmLabelBarHeightF         = 0.059
res_sp_cold_sup@gsnCenterString           = "Specific Humidity:~C~         COA~B~cold~N~"
res_sp_cold_sup@sfXArray                  = lon
res_sp_cold_sup@sfYArray                  = lat
;res_sp_cold_sup@lbLabelAngleF             = -30
res_sp_cold_sup@lbLabelAutoStride         = False
res_sp_cold_sup@lbLabelStride             = 10

; COA_normal - COA_cold: Specific Umidity.
res_sp_diff_sup                       = res
res_sp_diff_sup@cnFillOn                  = True
res_sp_diff_sup@cnLinesOn                 = False
res_sp_diff_sup@cnLevelSelectionMode      = "ManualLevels"
res_sp_diff_sup@cnMinLevelValF            = -2.5
res_sp_diff_sup@cnMaxLevelValF            = 2.5
res_sp_diff_sup@cnLevelSpacingF           = 0.05
res_sp_diff_sup@lbLabelFontHeightF        = 0.014
res_sp_diff_sup@lbTitleFontHeightF        = .015
res_sp_diff_sup@lbTitleString             = "[g kg~S~-1~N~]"
res_sp_diff_sup@lbOrientation             = "Horizontal"
res_sp_diff_sup@lbTitleFontThicknessF     = 1
res_sp_diff_sup@pmLabelBarOrthogonalPosF  = 0.139
res_sp_diff_sup@pmLabelBarWidthF          = 0.5
res_sp_diff_sup@pmLabelBarHeightF         = 0.059
res_sp_diff_sup@gsnCenterString           = "Specific Humidity:~C~COA~B~normal~N~ - COA~B~cold~N~"
res_sp_diff_sup@sfXArray                  = lon
res_sp_diff_sup@sfYArray                  = lat
res_sp_diff_sup@cnFillPalette             = cmap
;res_sp_diff_sup@lbLabelAngleF             = -30
res_sp_diff_sup@lbLabelAutoStride         = False
res_sp_diff_sup@lbLabelStride             = 10

; COA_normal - Total Heat Flux.
res_thf_normal                           = res
res_thf_normal@cnFillOn                  = True
res_thf_normal@cnLinesOn                 = False
res_thf_normal@cnLevelSelectionMode      = "ManualLevels"
res_thf_normal@cnMinLevelValF            = -50
res_thf_normal@cnMaxLevelValF            = 450
res_thf_normal@cnLevelSpacingF           = 5
res_thf_normal@lbLabelFontHeightF        = 0.014
res_thf_normal@lbTitleFontHeightF        = .015
res_thf_normal@lbTitleString             = "[W m~S~-2~N~]"
res_thf_normal@lbOrientation             = "Horizontal"
res_thf_normal@lbTitleFontThicknessF     = 1
res_thf_normal@pmLabelBarOrthogonalPosF  = 0.139
res_thf_normal@pmLabelBarWidthF          = 0.5
res_thf_normal@pmLabelBarHeightF         = 0.059
res_thf_normal@gsnCenterString           = "Total heat flux:~C~     COA~B~normal~N~"
res_thf_normal@sfXArray                  = lon
res_thf_normal@sfYArray                  = lat
res_thf_normal@lbLabelAutoStride         = False
res_thf_normal@lbLabelStride             = 10

; COA_cold - Total Heat Flux.
res_thf_cold                           = res
res_thf_cold@cnFillOn                  = True
res_thf_cold@cnLinesOn                 = False
res_thf_cold@cnLevelSelectionMode      = "ManualLevels"
res_thf_cold@cnMinLevelValF            = -50
res_thf_cold@cnMaxLevelValF            = 450
res_thf_cold@cnLevelSpacingF           = 5
res_thf_cold@lbLabelFontHeightF        = 0.014
res_thf_cold@lbTitleFontHeightF        = .015
res_thf_cold@lbTitleString             =  "[W m~S~-2~N~]"
res_thf_cold@lbOrientation             = "Horizontal"
res_thf_cold@lbTitleFontThicknessF     = 1
res_thf_cold@pmLabelBarOrthogonalPosF  = 0.139
res_thf_cold@pmLabelBarWidthF          = 0.5
res_thf_cold@pmLabelBarHeightF         = 0.059
res_thf_cold@gsnCenterString           = "Total heat flux:~C~       COA~B~cold~N~"
res_thf_cold@sfXArray                  = lon
res_thf_cold@sfYArray                  = lat
res_thf_cold@lbLabelAutoStride         = False
res_thf_cold@lbLabelStride             = 10

; COA_normal - COA_cold: Total Heat Flux.
res_thf_diff                           = res
res_thf_diff@cnFillOn                  = True
res_thf_diff@cnLinesOn                 = False
res_thf_diff@cnLevelSelectionMode      = "ManualLevels"
res_thf_diff@cnMinLevelValF            = -120
res_thf_diff@cnMaxLevelValF            = 120
res_thf_diff@cnLevelSpacingF           = 1
res_thf_diff@lbLabelFontHeightF        = 0.014
res_thf_diff@lbTitleFontHeightF        = .015
res_thf_diff@lbTitleString             =  "[W m~S~-2~N~]"
res_thf_diff@lbOrientation             = "Horizontal"
res_thf_diff@lbTitleFontThicknessF     = 1
res_thf_diff@pmLabelBarOrthogonalPosF  = 0.139
res_thf_diff@pmLabelBarWidthF          = 0.5
res_thf_diff@pmLabelBarHeightF         = 0.059
res_thf_diff@gsnCenterString           = "~C~   Total heat flux:~C~COA~B~normal~N~ - COA~B~cold~N~"
res_thf_diff@sfXArray                  = lon
res_thf_diff@sfYArray                  = lat
res_thf_diff@cnFillPalette             = cmap
res_thf_diff@lbLabelAutoStride         = False
res_thf_diff@lbLabelStride             = 20

; COA_normal - Meridional moisture flux vertically integrated from 850 hPa to 1000 hPa.
res_merid_mfvi_normal                           = res
res_merid_mfvi_normal@cnFillOn                  = True
res_merid_mfvi_normal@cnLinesOn                 = False
res_merid_mfvi_normal@cnLevelSelectionMode      = "ManualLevels"
res_merid_mfvi_normal@cnMinLevelValF            = -20
res_merid_mfvi_normal@cnMaxLevelValF            = -5
res_merid_mfvi_normal@cnLevelSpacingF           = 0.1
res_merid_mfvi_normal@lbLabelFontHeightF        = 0.014
res_merid_mfvi_normal@lbTitleFontHeightF        = .015
res_merid_mfvi_normal@lbTitleString             = "[kg m~S~-1~N~ s~S~-1~N~]"
res_merid_mfvi_normal@lbOrientation             = "Horizontal"
res_merid_mfvi_normal@lbTitleFontThicknessF     = 1
res_merid_mfvi_normal@pmLabelBarOrthogonalPosF  = 0.139
res_merid_mfvi_normal@pmLabelBarWidthF          = 0.5
res_merid_mfvi_normal@pmLabelBarHeightF         = 0.059
res_merid_mfvi_normal@gsnCenterString           = "Vertically integrated meridional moisture flux:~C~                            COA~B~normal~N~"
res_merid_mfvi_normal@sfXArray                  = lon
res_merid_mfvi_normal@sfYArray                  = lat
res_merid_mfvi_normal@lbLabelAutoStride         = False
res_merid_mfvi_normal@lbLabelStride             = 20

; COA_cold - Meridional moisture flux vertically integrated from 850 hPa to 1000 hPa.
res_merid_mfvi_cold                           = res
res_merid_mfvi_cold@cnFillOn                  = True
res_merid_mfvi_cold@cnLinesOn                 = False
res_merid_mfvi_cold@cnLevelSelectionMode      = "ManualLevels"
res_merid_mfvi_cold@cnMinLevelValF            = -20
res_merid_mfvi_cold@cnMaxLevelValF            = -5
res_merid_mfvi_cold@cnLevelSpacingF           = 0.1
res_merid_mfvi_cold@lbLabelFontHeightF        = 0.014
res_merid_mfvi_cold@lbTitleFontHeightF        = .015
res_merid_mfvi_cold@lbTitleString             = "[kg m~S~-1~N~ s~S~-1~N~]"
res_merid_mfvi_cold@lbOrientation             = "Horizontal"
res_merid_mfvi_cold@lbTitleFontThicknessF     = 1
res_merid_mfvi_cold@pmLabelBarOrthogonalPosF  = 0.139
res_merid_mfvi_cold@pmLabelBarWidthF          = 0.5
res_merid_mfvi_cold@pmLabelBarHeightF         = 0.059
res_merid_mfvi_cold@gsnCenterString           = "Vertically integrated meridional moisture flux:~C~                               COA~B~cold~N~"
res_merid_mfvi_cold@sfXArray                  = lon
res_merid_mfvi_cold@sfYArray                  = lat
res_merid_mfvi_cold@lbLabelAutoStride         = False
res_merid_mfvi_cold@lbLabelStride             = 20

; COA_normal - COA_cold: Meridional moisture flux vertically integrated.
res_merid_mfvi_diff                           = res
res_merid_mfvi_diff@cnFillOn                  = True
res_merid_mfvi_diff@cnLinesOn                 = False
res_merid_mfvi_diff@cnLevelSelectionMode      = "ManualLevels"
res_merid_mfvi_diff@cnMinLevelValF            = -7
res_merid_mfvi_diff@cnMaxLevelValF            = 7
res_merid_mfvi_diff@cnLevelSpacingF           = 0.1
res_merid_mfvi_diff@lbLabelFontHeightF        = 0.014
res_merid_mfvi_diff@lbTitleFontHeightF        = .015
res_merid_mfvi_diff@lbTitleString             = "[kg m~S~-1~N~ s~S~-1~N~]"
res_merid_mfvi_diff@lbOrientation             = "Horizontal"
res_merid_mfvi_diff@lbTitleFontThicknessF     = 1
res_merid_mfvi_diff@pmLabelBarOrthogonalPosF  = 0.139
res_merid_mfvi_diff@pmLabelBarWidthF          = 0.5
res_merid_mfvi_diff@pmLabelBarHeightF         = 0.059
res_merid_mfvi_diff@gsnCenterString           = "Vertically integrated meridional moisture flux: ~C~                     COA~B~normal~N~ - COA~B~cold~N~"
res_merid_mfvi_diff@sfXArray                  = lon
res_merid_mfvi_diff@sfYArray                  = lat
res_merid_mfvi_diff@cnFillPalette             = cmap
res_merid_mfvi_diff@lbLabelAutoStride         = False
res_merid_mfvi_diff@lbLabelStride             = 10

; COA_normal - Zonal moisture flux vertically integrated from 850 hPa to 1000 hPa.
res_zonal_mfvi_normal                           = res
res_zonal_mfvi_normal@cnFillOn                  = True
res_zonal_mfvi_normal@cnLinesOn                 = False
res_zonal_mfvi_normal@cnLevelSelectionMode      = "ManualLevels"
res_zonal_mfvi_normal@cnMinLevelValF            = -10
res_zonal_mfvi_normal@cnMaxLevelValF            = 5
res_zonal_mfvi_normal@cnLevelSpacingF           = 0.1
res_zonal_mfvi_normal@lbLabelFontHeightF        = 0.014
res_zonal_mfvi_normal@lbTitleFontHeightF        = .015
res_zonal_mfvi_normal@lbTitleString             = "[kg m~S~-1~N~ s~S~-1~N~]"
res_zonal_mfvi_normal@lbOrientation             = "Horizontal"
res_zonal_mfvi_normal@lbTitleFontThicknessF     = 1
res_zonal_mfvi_normal@pmLabelBarOrthogonalPosF  = 0.139
res_zonal_mfvi_normal@pmLabelBarWidthF          = 0.5
res_zonal_mfvi_normal@pmLabelBarHeightF         = 0.059
res_zonal_mfvi_normal@gsnCenterString           = "Vertically integrated zonal moisture flux:~C~                          COA~B~normal~N~"
res_zonal_mfvi_normal@sfXArray                  = lon
res_zonal_mfvi_normal@sfYArray                  = lat
res_zonal_mfvi_normal@lbLabelAutoStride         = False
res_zonal_mfvi_normal@lbLabelStride             = 10

; COA_cold - Zonal moisture flux vertically integrated from 850 hPa to 1000 hPa.
res_zonal_mfvi_cold                           = res
res_zonal_mfvi_cold@cnFillOn                  = True
res_zonal_mfvi_cold@cnLinesOn                 = False
res_zonal_mfvi_cold@cnLevelSelectionMode      = "ManualLevels"
res_zonal_mfvi_cold@cnMinLevelValF            = -10
res_zonal_mfvi_cold@cnMaxLevelValF            = 5
res_zonal_mfvi_cold@cnLevelSpacingF           = 0.1
res_zonal_mfvi_cold@lbLabelFontHeightF        = 0.014
res_zonal_mfvi_cold@lbTitleFontHeightF        = .015
res_zonal_mfvi_cold@lbTitleString             = "[kg m~S~-1~N~ s~S~-1~N~]"
res_zonal_mfvi_cold@lbOrientation             = "Horizontal"
res_zonal_mfvi_cold@lbTitleFontThicknessF     = 1
res_zonal_mfvi_cold@pmLabelBarOrthogonalPosF  = 0.139
res_zonal_mfvi_cold@pmLabelBarWidthF          = 0.5
res_zonal_mfvi_cold@pmLabelBarHeightF         = 0.059
res_zonal_mfvi_cold@gsnCenterString           = "Vertically integrated zonal moisture flux:~C~                           COA~B~cold~N~"
res_zonal_mfvi_cold@sfXArray                  = lon
res_zonal_mfvi_cold@sfYArray                  = lat
res_zonal_mfvi_cold@lbLabelAutoStride         = False
res_zonal_mfvi_cold@lbLabelStride             = 10

; COA_normal - COA_cold: Zonal moisture flux vertically integrated from 850 hPa to 1000 hPa.
res_zonal_mfvi_diff                           = res
res_zonal_mfvi_diff@cnFillOn                  = True
res_zonal_mfvi_diff@cnLinesOn                 = False
res_zonal_mfvi_diff@cnLevelSelectionMode      = "ManualLevels"
res_zonal_mfvi_diff@cnMinLevelValF            = -7
res_zonal_mfvi_diff@cnMaxLevelValF            = 7
res_zonal_mfvi_diff@cnLevelSpacingF           = 0.1
res_zonal_mfvi_diff@lbLabelFontHeightF        = 0.014
res_zonal_mfvi_diff@lbTitleFontHeightF        = .015
res_zonal_mfvi_diff@lbTitleString             = "[kg m~S~-1~N~ s~S~-1~N~"
res_zonal_mfvi_diff@lbOrientation             = "Horizontal"
res_zonal_mfvi_diff@lbTitleFontThicknessF     = 1
res_zonal_mfvi_diff@pmLabelBarOrthogonalPosF  = 0.139
res_zonal_mfvi_diff@pmLabelBarWidthF          = 0.5
res_zonal_mfvi_diff@pmLabelBarHeightF         = 0.059
res_zonal_mfvi_diff@gsnCenterString           = "Vertically integrated zonal moisture flux: ~C~                   COA~B~normal~N~ - COA~B~cold~N~"
res_zonal_mfvi_diff@sfXArray                  = lon
res_zonal_mfvi_diff@sfYArray                  = lat
res_zonal_mfvi_diff@cnFillPalette             = cmap
res_zonal_mfvi_diff@lbLabelAutoStride         = False
res_zonal_mfvi_diff@lbLabelStride             = 10

; COA_normal - Moisture Fluxes vertically integrated from 700 to 1000 hPa.
res_mfvi_normal                           = res
res_mfvi_normal@vcGlyphStyle              = "Vector"
res_mfvi_normal@vcMonoLineArrowColor      = True
res_mfvi_normal@vcMinDistanceF            = 1.030
res_mfvi_normal@vcRefMagnitudeF           = 20
res_mfvi_normal@vcRefLengthF              = 0.050
res_mfvi_normal@gsnCenterString           = "Vertically integrated moisture flux:~C~                    COA~B~normal~N~"
res_mfvi_normal@vfXArray                  = lon
res_mfvi_normal@vfYArray                  = lat
res_mfvi_normal@vcLevelSelectionMode      = "ManualLevels"
res_mfvi_normal@vcLevelSpacingF           = 0.1;
res_mfvi_normal@vcMinLevelValF            = 10
res_mfvi_normal@vcMaxLevelValF            = 20
res_mfvi_normal@vcLineArrowThicknessF     = 2
res_mfvi_normal@lbLabelFontHeightF        = 0.014
res_mfvi_normal@lbTitleFontHeightF        = .015
res_mfvi_normal@lbTitleString             = "[kg m~S~-1~N~ s~S~-1~N~]"
res_mfvi_normal@lbOrientation             = "Horizontal"
res_mfvi_normal@lbLabelAutoStride         = False
res_mfvi_normal@lbLabelStride             = 20
res_mfvi_normal@lbTitleFontThicknessF     = 1
res_mfvi_normal@vcRefAnnoOn               = True
res_mfvi_normal@vcRefAnnoSide             = "Top"
res_mfvi_normal@vcRefAnnoString2On        = True
res_mfvi_normal@vcRefAnnoString2          ="kg m~S~-1~N~ s~S~-1~N~"
res_mfvi_normal@vcRefAnnoPerimOn          = True
res_mfvi_normal@vcRefAnnoFontHeightF      = 0.014
res_mfvi_normal@vcRefAnnoOrthogonalPosF   = -0.18
res_mfvi_normal@vcRefAnnoParallelPosF     = 0.14
res_mfvi_normal@gsnScalarContour          = True

; COA_cold - Moisture Fluxes vertically integrated from 1000 to 850 hPa.
res_mfvi_cold                           = res
res_mfvi_cold@vcGlyphStyle              = "Vector"
res_mfvi_cold@vcMonoLineArrowColor      = True
res_mfvi_cold@vcMinDistanceF            = 1.035
res_mfvi_cold@vcRefMagnitudeF           = 20
res_mfvi_cold@vcRefLengthF              = 0.050
res_mfvi_cold@gsnCenterString           = "Vertically integrated moisture flux:~C~                     COA~B~cold~N~"
res_mfvi_cold@vfXArray                  = lon
res_mfvi_cold@vfYArray                  = lat
res_mfvi_cold@vcLevelSelectionMode      = "ManualLevels"
res_mfvi_cold@vcLevelSpacingF           = 0.1;
res_mfvi_cold@vcMinLevelValF            = 10
res_mfvi_cold@vcMaxLevelValF            = 20
res_mfvi_cold@vcLineArrowThicknessF     = 2
res_mfvi_cold@lbLabelFontHeightF        = 0.014
res_mfvi_cold@lbTitleFontHeightF        = .015
res_mfvi_cold@gsnScalarContour         = True
res_mfvi_cold@lbTitleString             = "[kg m~S~-1~N~ s~S~-1~N~]"
res_mfvi_cold@lbOrientation             = "Horizontal"
res_mfvi_cold@lbTitleFontThicknessF     = 1
res_mfvi_cold@vcRefAnnoOn               = True
res_mfvi_cold@vcRefAnnoSide             = "Top"
res_mfvi_cold@vcRefAnnoString2On        = True
res_mfvi_cold@vcRefAnnoString2          ="kg m~S~-1~N~ s~S~-1~N~"
res_mfvi_cold@vcRefAnnoPerimOn          = True
res_mfvi_cold@vcRefAnnoFontHeightF      = 0.014
res_mfvi_cold@vcRefAnnoOrthogonalPosF   = -0.18
res_mfvi_cold@vcRefAnnoParallelPosF     = 0.14
res_mfvi_cold@lbLabelAutoStride         = False
res_mfvi_cold@lbLabelStride             = 20

; COA_cold - COA_normal -  Moisture Fluxes vertically integrated from 1000 to 850 hPa.
res_mfvi_diff                           = res
res_mfvi_diff@vcGlyphStyle              = "Vector"
res_mfvi_diff@vcMonoLineArrowColor      = True
res_mfvi_diff@vcMinDistanceF            = 1.035
res_mfvi_diff@vcRefMagnitudeF           = 20
res_mfvi_diff@vcRefLengthF              = 0.050
res_mfvi_diff@gsnCenterString           = "Vertically integrated moisture fluxd:~C~          COA~B~normal~N~ - COA~B~cold~N~"
res_mfvi_diff@vfXArray                  = lon
res_mfvi_diff@vfYArray                  = lat
res_mfvi_diff@vcLevelSelectionMode      = "ManualLevels"
res_mfvi_diff@vcLevelSpacingF           = 0.1;
res_mfvi_diff@vcMinLevelValF            = 0
res_mfvi_diff@vcMaxLevelValF            = 50
res_mfvi_diff@vcLineArrowThicknessF     = 2
res_mfvi_diff@lbLabelFontHeightF        = 0.014
res_mfvi_diff@lbTitleFontHeightF        = .015
res_mfvi_diff@lbTitleString             = "[kg m~S~-1~N~ s~S~-1~N~]"
res_mfvi_diff@lbOrientation             = "Horizontal"
res_mfvi_diff@lbTitleFontThicknessF     = 1
res_mfvi_diff@vcRefAnnoOn               = True
res_mfvi_diff@vcRefAnnoSide             = "Top"
res_mfvi_diff@vcRefAnnoString2On        = True
res_mfvi_diff@vcRefAnnoString2          ="kg m~S~-1~N~ s~S~-1~N~"
res_mfvi_diff@vcRefAnnoPerimOn          = True
res_mfvi_diff@vcRefAnnoFontHeightF      = 0.014
res_mfvi_diff@vcRefAnnoOrthogonalPosF   = -0.18
res_mfvi_diff@vcRefAnnoParallelPosF     = 0.14
res_mfvi_diff@lbLabelAutoStride         = False
res_mfvi_diff@lbLabelStride             = 10
res_mfvi_diff@gsnScalarContour          = True

; COA_normal: precipitation.
mfvid_res_normal                           = res
mfvid_res_normal@cnFillOn                  = True
mfvid_res_normal@cnLinesOn                 = False
mfvid_res_normal@cnLevelSelectionMode      = "ManualLevels"
mfvid_res_normal@cnMinLevelValF            = -30
mfvid_res_normal@cnMaxLevelValF            = 30.
mfvid_res_normal@cnLevelSpacingF           = 0.5
mfvid_res_normal@lbLabelFontHeightF        = 0.014
mfvid_res_normal@lbTitleFontHeightF        = .015
mfvid_res_normal@lbTitleString             = "[mm day~S~-1~N~]"
mfvid_res_normal@lbOrientation             = "Horizontal"
mfvid_res_normal@lbTitleFontThicknessF     = 1
mfvid_res_normal@pmLabelBarWidthF          = 0.5
mfvid_res_normal@pmLabelBarHeightF         = 0.059
mfvid_res_normal@gsnCenterString           = "Vertically integrated moisture flux divergent:~C~                                COA~B~normal~N~"
mfvid_res_normal@cnFillPalette             = cmap
mfvid_res_normal@lbLabelAutoStride         = False
mfvid_res_normal@lbLabelStride             = 10

; COA_cold: precipitation.
mfvid_res_cold                           = res
mfvid_res_cold@cnFillOn                  = True
mfvid_res_cold@cnLinesOn                 = False
mfvid_res_cold@cnLevelSelectionMode      = "ManualLevels"
mfvid_res_cold@cnMinLevelValF            = -30
mfvid_res_cold@cnMaxLevelValF            = 30.
mfvid_res_cold@cnLevelSpacingF           = 0.5
mfvid_res_cold@lbLabelFontHeightF        = 0.014
mfvid_res_cold@lbTitleFontHeightF        = .015
mfvid_res_cold@lbTitleString             = "[mm day~S~-1~N~]"
mfvid_res_cold@lbOrientation             = "Horizontal"
mfvid_res_cold@lbTitleFontThicknessF     = 1
mfvid_res_cold@pmLabelBarWidthF          = 0.5
mfvid_res_cold@pmLabelBarHeightF         = 0.059
mfvid_res_cold@gsnCenterString           = "Vertically integrated moisture flux divergent:~C~                                COA~B~cold~N~"
mfvid_res_cold@cnFillPalette             = cmap
mfvid_res_cold@lbLabelAutoStride         = False
mfvid_res_cold@lbLabelStride             = 10

; COA_normal - COA_cold precipitation difference.
mfvid_res_diff                       = res
mfvid_res_diff@cnFillOn              = True
mfvid_res_diff@cnLinesOn             = False
mfvid_res_diff@cnLevelSelectionMode  = "ManualLevels"
mfvid_res_diff@cnMinLevelValF        = -28
mfvid_res_diff@cnMaxLevelValF        = 28.
mfvid_res_diff@cnLevelSpacingF       = 0.5
mfvid_res_diff@lbLabelFontHeightF    = 0.014
mfvid_res_diff@lbTitleFontHeightF    = .015
mfvid_res_diff@lbTitleString         = "[mm day~S~-1~N~]"
mfvid_res_diff@lbOrientation         = "Horizontal"
mfvid_res_diff@lbTitleFontThicknessF = 1
mfvid_res_diff@pmLabelBarWidthF      = 0.5
mfvid_res_diff@pmLabelBarHeightF     = 0.059
mfvid_res_diff@gsnCenterString       = "Vertically integrated moisture flux divergent:~C~                      COA~B~normal~N~ - COA~B~cold~N~"
mfvid_res_diff@cnFillPalette         = cmap
mfvid_res_normal@lbLabelStride       = 10

; COA_normal: precipitation.
prec_res_normal                           = res
prec_res_normal@cnFillOn                  = True
prec_res_normal@cnLinesOn                 = False
prec_res_normal@cnLevelSelectionMode      = "ManualLevels"
prec_res_normal@cnMinLevelValF            = 0
prec_res_normal@cnMaxLevelValF            = 310.
prec_res_normal@cnLevelSpacingF           = 2
prec_res_normal@lbLabelFontHeightF        = 0.014
prec_res_normal@lbTitleFontHeightF        = .015
prec_res_normal@lbTitleString             = "[mm]"
prec_res_normal@lbOrientation             = "Horizontal"
prec_res_normal@lbTitleFontThicknessF     = 1
prec_res_normal@pmLabelBarWidthF          = 0.5
prec_res_normal@pmLabelBarHeightF         = 0.059
prec_res_normal@gsnCenterString           = "Precipitation:~C~    COA~B~normal~N~"
prec_res_normal@cnFillPalette             = prec_color
prec_res_normal@lbLabelAutoStride         = False
prec_res_normal@lbLabelStride             = 15

; COA_cold: precipitation.
prec_res_cold                           = res
prec_res_cold@cnFillOn                  = True
prec_res_cold@cnLinesOn                 = False
prec_res_cold@cnLevelSelectionMode      = "ManualLevels"
prec_res_cold@cnMinLevelValF            = 0
prec_res_cold@cnMaxLevelValF            = 310.
prec_res_cold@cnLevelSpacingF           = 2
prec_res_cold@lbLabelFontHeightF        = 0.014
prec_res_cold@lbTitleFontHeightF        = .015
prec_res_cold@lbTitleString             = "[mm]"
prec_res_cold@lbOrientation             = "Horizontal"
prec_res_cold@lbTitleFontThicknessF     = 1
prec_res_cold@pmLabelBarWidthF          = 0.5
prec_res_cold@pmLabelBarHeightF         = 0.059
prec_res_cold@gsnCenterString           = "Precipitation:~C~     COA~B~cold~N~"
prec_res_cold@cnFillPalette             = prec_color
prec_res_cold@lbLabelAutoStride         = False
prec_res_cold@lbLabelStride             = 15

; COA_normal - COA_cold precipitation difference.
prec_diff_res                       = res
prec_diff_res@cnFillOn              = True
prec_diff_res@cnLinesOn             = False
prec_diff_res@cnLevelSelectionMode  = "ManualLevels"
prec_diff_res@cnMinLevelValF        = -200
prec_diff_res@cnMaxLevelValF        = 200.
prec_diff_res@cnLevelSpacingF       = 5
prec_diff_res@lbLabelFontHeightF    = 0.014
prec_diff_res@lbTitleFontHeightF    = .015
prec_diff_res@lbTitleString         = "[mm]"
prec_diff_res@lbOrientation         = "Horizontal"
prec_diff_res@lbTitleFontThicknessF = 1
prec_diff_res@pmLabelBarWidthF      = 0.5
prec_diff_res@pmLabelBarHeightF     = 0.059
prec_diff_res@gsnCenterString       = "~C~    Precipitation:~C~COA~B~normal~N~ - COA~B~cold~N~"
prec_diff_res@cnFillPalette         = cmap

; Do the contours.
print("Stage 15: Doing the contour.")
contour_sp_normal     = gsn_csm_contour_map(wks,spec_hum_normal_sup,res_sp_normal_sup)
contour_sp_cold       = gsn_csm_contour_map(wks,spec_hum_cold_sup,res_sp_cold_sup)
contour_sp_diff       = gsn_csm_contour_map(wks,spec_hum_diff_sup,res_sp_diff_sup)

contour_thf_normal    = gsn_csm_contour_map(wks,thf_normal,res_thf_normal)
contour_thf_cold      = gsn_csm_contour_map(wks,thf_cold,res_thf_cold)
contour_thf_diff      = gsn_csm_contour_map(wks,thf_diff,res_thf_diff)


contour_mfvi_v_normal = gsn_csm_contour_map(wks,mfvi_v_normal,res_zonal_mfvi_normal)
contour_mfvi_v_cold   = gsn_csm_contour_map(wks,mfvi_v_cold,res_zonal_mfvi_cold)
contour_mfvi_v_diff   = gsn_csm_contour_map(wks,mfvi_diff_v,res_zonal_mfvi_diff)

contour_mfvi_u_normal = gsn_csm_contour_map(wks,mfvi_u_normal,res_merid_mfvi_normal)
contour_mfvi_u_cold   = gsn_csm_contour_map(wks,mfvi_u_cold,res_merid_mfvi_cold)
contour_mfvi_u_diff   = gsn_csm_contour_map(wks,mfvi_diff_u,res_merid_mfvi_diff)

contour_mfvid_normal  = gsn_csm_contour_map(wks,mfvid_normal,mfvid_res_normal)
contour_mfvid_cold    = gsn_csm_contour_map(wks,mfvid_cold,mfvid_res_cold)
contour_mfvid_diff    = gsn_csm_contour_map(wks,mfvid_diff,mfvid_res_diff)

vector_mfvi_cold      = gsn_csm_vector_map(wks,mfvi_u_cold,mfvi_v_cold,res_mfvi_cold)
vector_mfvi_normal    = gsn_csm_vector_map(wks,mfvi_u_normal,mfvi_v_normal,res_mfvi_normal)
vector_mfvi_diff      = gsn_csm_vector_map(wks,mfvi_diff_u_2,mfvi_diff_v_2,res_mfvi_diff)

contour_prec_normal   = gsn_csm_contour_map(wks,prec_normal,prec_res_normal)
contour_prec_cold     = gsn_csm_contour_map(wks,prec_cold,prec_res_cold)
contour_prec_diff     = gsn_csm_contour_map(wks,prec_diff,prec_diff_res)

; Paneling resources.
print("Stage 16: Setting panelling resources.")
pres                  = True
pres@gsnMaximize      = True
pres@txString         = " "
pres@gsnPanelLabelBar = False
pres@gsnPanelRowSpec  = True

; Plot.
print("Stage 17: Ploting.")
gsn_panel(wks,(/contour_sp_normal,contour_sp_cold,contour_sp_diff,\
                contour_mfvi_v_normal,contour_mfvi_v_cold,contour_mfvi_v_diff,\
                contour_mfvi_u_normal,contour_mfvi_u_cold,contour_mfvi_u_diff,\
                contour_mfvid_normal,contour_mfvid_cold,contour_mfvid_diff,\
                vector_mfvi_normal,vector_mfvi_cold,vector_mfvi_diff,\
                contour_thf_normal,contour_thf_cold,contour_thf_diff,\
                contour_prec_normal,contour_prec_cold,contour_prec_diff\
                /),(/3,3,3,3,3,3,3/),pres)

; Delete blank space.
print("Stage 18: Deleting blank space around figure.")
system("convert -trim "+pltPath+"."+pltType+" "+pltPath+"."+pltType)

end
