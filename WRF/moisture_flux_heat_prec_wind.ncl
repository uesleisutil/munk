;;; moisture_flux_heat_prec_wind.ncl ;;;
; Author      - Ueslei Adriano Sutil   ;
; Created     - 02 May 2018            ;
; Last update - 04 May 2018            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Prototype scripts and go.
load "/home/ueslei/NCL/loads.ncl"
begin

; Add more memory.
setvalues NhlGetWorkspaceObjectId()
 "wsMaximumSize" : 700000000
end setvalues

; Open files.
wrf_normal = addfile("/media/ueslei/Ueslei/SC_2008/Outputs/wrf_normal.nc","r")
wrf_cold   = addfile("/media/ueslei/Ueslei/SC_2008/Outputs/wrf_cold.nc","r")
t_step     = 12
spacing    = 20
level      = 0

; Plotting options.
pltType          = "png"
pltType@wkWidth  = 3000
pltType@wkHeight = 3000
pltName          = "adv_fluxes_20"
pltDir           = "./"
pltPath          = pltDir + pltName
wks              = gsn_open_wks(pltType, pltName)
cmap1            = read_colormap_file("MPL_RdBu")
cmap             = cmap1(::-1,:)
prec_color       = read_colormap_file("WhViBlGrYeOrRe")
gsn_define_colormap(wks, "MPL_jet")

; Get variables.
lat              = wrf_cold->XLAT(t_step,::spacing,0)
lon              = wrf_cold->XLONG(t_step,0,::spacing)
lsm              = wrf_cold->LANDMASK(t_step,::spacing,::spacing)

; COA_normal.
uv_normal        = wrf_user_getvar(wrf_normal,"uvmet10",-1)
u_normal         = uv_normal(0,t_step,::spacing,::spacing)
v_normal         = uv_normal(1,t_step,::spacing,::spacing)
mix_ratio_normal = wrf_normal->QVAPOR(t_step,level,::spacing,::spacing)
lh_normal        = wrf_normal->LH(t_step,::spacing,::spacing)
sh_normal        = wrf_normal->HFX(t_step,::spacing,::spacing)
prec_normal      = wrf_normal->RAINNC(t_step,::spacing,::spacing)

; COA_cold.
uv_cold          = wrf_user_getvar(wrf_cold,"uvmet10",-1)
u_cold           = uv_cold(0,t_step,::spacing,::spacing)
v_cold           = uv_cold(1,t_step,::spacing,::spacing)
mix_ratio_cold   = wrf_cold->QVAPOR(t_step,level,::spacing,::spacing)
lh_cold          = wrf_cold->LH(t_step,::spacing,::spacing)
sh_cold          = wrf_cold->HFX(t_step,::spacing,::spacing)
prec_cold        = wrf_cold->RAINNC(t_step,::spacing,::spacing)

; Calculate specific humidity and difference between runs.
spec_hum_normal = ((mix_ratio_normal/(1+mix_ratio_normal)))
spec_hum_cold   = ((mix_ratio_cold/(1+mix_ratio_cold)))
spec_hum_diff    = spec_hum_normal-spec_hum_cold

; Calculate Total Heat Flux and difference between runs.
thf_normal = lh_normal + sh_normal
thf_cold   = lh_cold + sh_cold
thf_diff   = thf_normal - thf_cold

; Calculate moisture flux advection and difference between runs
dqdy_normal        = center_finite_diff_n(mix_ratio_normal, lat, False, 0, 0)
dqdx_normal        = center_finite_diff_n(mix_ratio_normal, lon, False, 0, 0)
m_flux_adv_normal = (dqdx_normal*u_normal+dqdy_normal*v_normal) ; kg/kg/s
;m_flux_adv_normal  = (m_flux_adv_normal1^10)

dqdy_cold          = center_finite_diff_n(mix_ratio_cold, lat, False, 0, 0)
dqdx_cold          = center_finite_diff_n(mix_ratio_cold, lon, False, 0, 0)
m_flux_adv_cold   = (dqdx_cold*u_cold+dqdy_cold*v_cold) ; kg/kg/s
;m_flux_adv_cold    = (m_flux_adv_cold1^10)

m_flux_adv_diff    = m_flux_adv_normal-m_flux_adv_cold

; Calculate precipitation difference between runs
prec_diff = prec_normal-prec_cold

; Calculate wind speed and difference between runs
wsp_normal = wind_speed(u_normal,v_normal)
wsp_cold   = wind_speed(u_cold,v_cold)
wsp_diff   = wsp_normal-wsp_cold

; Attach 2D coordinates.
lh = wrf_normal->LH(t_step,::spacing,::spacing)

copy_VarCoords(lh,spec_hum_cold)
copy_VarCoords(lh,m_flux_adv_cold)
copy_VarCoords(lh,spec_hum_normal)
copy_VarCoords(lh,m_flux_adv_normal)
copy_VarCoords(lh,m_flux_adv_diff)
copy_VarCoords(lh,spec_hum_diff)

spec_hum_cold@lat2d   = wrf_cold->XLAT(0,::spacing,::spacing)
spec_hum_cold@lon2d   = wrf_cold->XLONG(0,::spacing,::spacing)
m_flux_adv_cold@lat2d = wrf_cold->XLAT(0,::spacing,::spacing)
m_flux_adv_cold@lon2d = wrf_cold->XLONG(0,::spacing,::spacing)

spec_hum_normal@lat2d   = wrf_cold->XLAT(0,::spacing,::spacing)
spec_hum_normal@lon2d   = wrf_cold->XLONG(0,::spacing,::spacing)
m_flux_adv_normal@lat2d = wrf_cold->XLAT(0,::spacing,::spacing)
m_flux_adv_normal@lon2d = wrf_cold->XLONG(0,::spacing,::spacing)

spec_hum_diff@lat2d   = wrf_cold->XLAT(0,::spacing,::spacing)
spec_hum_diff@lon2d   = wrf_cold->XLONG(0,::spacing,::spacing)
m_flux_adv_diff@lat2d = wrf_cold->XLAT(0,::spacing,::spacing)
m_flux_adv_diff@lon2d = wrf_cold->XLONG(0,::spacing,::spacing)

; Resources
plot                            = new(15,graphic)
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
res@mpLandFillColor             = "gray"
res@mpProvincialLineThicknessF  = 5
res@mpNationalLineThickness     = 5
res@mpGeophysicalLineThicknessF = 5.0
res@sfXArray                    = lon
res@sfYArray                    = lat

; COA_normal - Specific Umidity.
res_sp_normal                           = res
res_sp_normal@cnFillOn                  = True
res_sp_normal@cnLinesOn                 = False
res_sp_normal@cnLevelSelectionMode      = "ManualLevels"
res_sp_normal@cnMinLevelValF            = 0.01
res_sp_normal@cnMaxLevelValF            = 0.014
res_sp_normal@cnLevelSpacingF           = 0.00005
res_sp_normal@lbLabelFontHeightF        = 0.014
res_sp_normal@lbTitleFontHeightF        = .015
res_sp_normal@lbTitleString             = "[kg/kg]"
res_sp_normal@lbOrientation             = "Horizontal"
res_sp_normal@lbTitleFontThicknessF     = 1
res_sp_normal@pmLabelBarOrthogonalPosF  = 0.139
res_sp_normal@pmLabelBarWidthF          = 0.5
res_sp_normal@pmLabelBarHeightF         = 0.059
res_sp_normal@gsnCenterString           = "Specific Umidity: COA~B~normal~N~"
res_sp_normal@sfXArray                  = lon
res_sp_normal@sfYArray                  = lat
res_sp_normal@lbLabelAngleF             = 30

; COA_cold - Specific Umidity.
res_sp_cold                           = res
res_sp_cold@cnFillOn                  = True
res_sp_cold@cnLinesOn                 = False
res_sp_cold@cnLevelSelectionMode      = "ManualLevels"
res_sp_cold@cnMinLevelValF            = 0.01
res_sp_cold@cnMaxLevelValF            = 0.014
res_sp_cold@cnLevelSpacingF           = 0.00005
res_sp_cold@lbLabelFontHeightF        = 0.014
res_sp_cold@lbTitleFontHeightF        = .015
res_sp_cold@lbTitleString             = "[kg/kg]"
res_sp_cold@lbOrientation             = "Horizontal"
res_sp_cold@lbTitleFontThicknessF     = 1
res_sp_cold@pmLabelBarOrthogonalPosF  = 0.139
res_sp_cold@pmLabelBarWidthF          = 0.5
res_sp_cold@pmLabelBarHeightF         = 0.059
res_sp_cold@gsnCenterString           = "Specific Umidity: COA~B~cold~N~"
res_sp_cold@sfXArray                  = lon
res_sp_cold@sfYArray                  = lat
res_sp_cold@lbLabelAngleF             = 30

; COA_normal - COA_cold: Specific Umidity.
res_sp_diff                           = res
res_sp_diff@cnFillOn                  = True
res_sp_diff@cnLinesOn                 = False
res_sp_diff@cnLevelSelectionMode      = "ManualLevels"
res_sp_diff@cnMinLevelValF            = -0.002
res_sp_diff@cnMaxLevelValF            = 0.002
res_sp_diff@cnLevelSpacingF           = 0.00005
res_sp_diff@lbLabelFontHeightF        = 0.014
res_sp_diff@lbTitleFontHeightF        = .015
res_sp_diff@lbTitleString             = "[kg/kg]"
res_sp_diff@lbOrientation             = "Horizontal"
res_sp_diff@lbTitleFontThicknessF     = 1
res_sp_diff@pmLabelBarOrthogonalPosF  = 0.139
res_sp_diff@pmLabelBarWidthF          = 0.5
res_sp_diff@pmLabelBarHeightF         = 0.059
res_sp_diff@gsnCenterString           = "Specific Umidity: COA~B~normal~N~ - COA~B~cold~N~"
res_sp_diff@sfXArray                  = lon
res_sp_diff@sfYArray                  = lat
res_sp_diff@cnFillPalette             = cmap
res_sp_diff@lbLabelAngleF             = 30

; COA_normal - Total Heat Flux.
res_thf_normal                           = res
res_thf_normal@cnFillOn                  = True
res_thf_normal@cnLinesOn                 = False
res_thf_normal@cnLevelSelectionMode      = "ManualLevels"
res_thf_normal@cnMinLevelValF            = 0
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
res_thf_normal@gsnCenterString           = "Total Heat Flux: COA~B~normal~N~"
res_thf_normal@sfXArray                  = lon
res_thf_normal@sfYArray                  = lat

; COA_cold - Total Heat Flux.
res_thf_cold                           = res
res_thf_cold@cnFillOn                  = True
res_thf_cold@cnLinesOn                 = False
res_thf_cold@cnLevelSelectionMode      = "ManualLevels"
res_thf_cold@cnMinLevelValF            = 0
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
res_thf_cold@gsnCenterString           = "Total Heat Flux: COA~B~cold~N~"
res_thf_cold@sfXArray                  = lon
res_thf_cold@sfYArray                  = lat

; COA_normal - COA_cold: Total Heat Flux.
res_thf_diff                           = res
res_thf_diff@cnFillOn                  = True
res_thf_diff@cnLinesOn                 = False
res_thf_diff@cnLevelSelectionMode      = "ManualLevels"
res_thf_diff@cnMinLevelValF            = -100
res_thf_diff@cnMaxLevelValF            = 100
res_thf_diff@cnLevelSpacingF           = 1
res_thf_diff@lbLabelFontHeightF        = 0.014
res_thf_diff@lbTitleFontHeightF        = .015
res_thf_diff@lbTitleString             =  "[W m~S~-2~N~]"
res_thf_diff@lbOrientation             = "Horizontal"
res_thf_diff@lbTitleFontThicknessF     = 1
res_thf_diff@pmLabelBarOrthogonalPosF  = 0.139
res_thf_diff@pmLabelBarWidthF          = 0.5
res_thf_diff@pmLabelBarHeightF         = 0.059
res_thf_diff@gsnCenterString           = "Total Heat Flux: COA~B~normal~N~ - COA~B~cold~N~"
res_thf_diff@sfXArray                  = lon
res_thf_diff@sfYArray                  = lat
res_thf_diff@cnFillPalette             = cmap

; COA_normal - Moisture Flux Advection.
res_mfa_normal                           = res
res_mfa_normal@cnFillOn                  = True
res_mfa_normal@cnLinesOn                 = False
res_mfa_normal@cnLevelSelectionMode      = "ManualLevels"
res_mfa_normal@cnMinLevelValF            = -0.04
res_mfa_normal@cnMaxLevelValF            =  0.04
res_mfa_normal@cnLevelSpacingF           =  0.0005
res_mfa_normal@lbLabelFontHeightF        = 0.014
res_mfa_normal@lbTitleFontHeightF        = .015
res_mfa_normal@lbTitleString             = "[kg/kg/s]"
res_mfa_normal@lbOrientation             = "Horizontal"
res_mfa_normal@lbTitleFontThicknessF     = 1
res_mfa_normal@pmLabelBarOrthogonalPosF  = 0.139
res_mfa_normal@pmLabelBarWidthF          = 0.5
res_mfa_normal@pmLabelBarHeightF         = 0.059
res_mfa_normal@gsnCenterString           = "Moisture Flux Advection: COA~B~normal~N~"
res_mfa_normal@sfXArray                  = lon
res_mfa_normal@sfYArray                  = lat
res_mfa_normal@cnFillPalette             = cmap

; COA_cold - Moisture Flux Advection.
res_mfa_cold                           = res
res_mfa_cold@cnFillOn                  = True
res_mfa_cold@cnLinesOn                 = False
res_mfa_cold@cnLevelSelectionMode      = "ManualLevels"
res_mfa_cold@cnMinLevelValF            =  -0.04
res_mfa_cold@cnMaxLevelValF            =  0.04
res_mfa_cold@cnLevelSpacingF           =  0.0005
res_mfa_cold@lbLabelFontHeightF        = 0.014
res_mfa_cold@lbTitleFontHeightF        = .015
res_mfa_cold@lbTitleString             = "[kg/kg/s]"
res_mfa_cold@lbOrientation             = "Horizontal"
res_mfa_cold@lbTitleFontThicknessF     = 1
res_mfa_cold@pmLabelBarOrthogonalPosF  = 0.139
res_mfa_cold@pmLabelBarWidthF          = 0.5
res_mfa_cold@pmLabelBarHeightF         = 0.059
res_mfa_cold@gsnCenterString           = "Moisture Flux Advection: COA~B~cold~N~"
res_mfa_cold@sfXArray                  = lon
res_mfa_cold@sfYArray                  = lat
res_mfa_cold@cnFillPalette             = cmap

; COA_cold - COA_normal - Moisture Flux Advection.
res_mfa_diff                           = res
res_mfa_diff@cnFillOn                  = True
res_mfa_diff@cnLinesOn                 = False
res_mfa_diff@cnLevelSelectionMode      = "ManualLevels"
res_mfa_diff@cnMinLevelValF            = -0.04
res_mfa_diff@cnMaxLevelValF            =  0.04
res_mfa_diff@cnLevelSpacingF           =  0.0005
res_mfa_diff@lbLabelFontHeightF        = 0.014
res_mfa_diff@lbTitleFontHeightF        = .015
res_mfa_diff@lbTitleString             = "[kg/kg/s]"
res_mfa_diff@lbOrientation             = "Horizontal"
res_mfa_diff@lbTitleFontThicknessF     = 1
res_mfa_diff@pmLabelBarOrthogonalPosF  = 0.139
res_mfa_diff@pmLabelBarWidthF          = 0.5
res_mfa_diff@pmLabelBarHeightF         = 0.059
res_mfa_diff@gsnCenterString           = "Moisture Flux Advection: COA~B~normal~N~ - COA~B~cold~N~"
res_mfa_diff@sfXArray                  = lon
res_mfa_diff@sfYArray                  = lat
res_mfa_diff@cnFillPalette             = cmap

; COA_normal: precipitation.
prec_res_normal                           = res
prec_res_normal@cnFillOn                  = True
prec_res_normal@cnLinesOn                 = False
prec_res_normal@cnLevelSelectionMode      = "ManualLevels"
prec_res_normal@cnMinLevelValF            = 0
prec_res_normal@cnMaxLevelValF            = 312.
prec_res_normal@cnLevelSpacingF           = 2
prec_res_normal@lbLabelFontHeightF        = 0.014
prec_res_normal@lbTitleFontHeightF        = .015
prec_res_normal@lbTitleString             = "[mm]"
prec_res_normal@lbOrientation             = "Horizontal"
prec_res_normal@lbTitleFontThicknessF     = 1
prec_res_normal@pmLabelBarWidthF          = 0.5
prec_res_normal@pmLabelBarHeightF         = 0.059
prec_res_normal@gsnCenterString           = "Precipitation: COA~B~normal~N~"
prec_res_normal@cnFillPalette             = prec_color

; COA_cold: precipitation.
prec_res_cold                           = res
prec_res_cold@cnFillOn                  = True
prec_res_cold@cnLinesOn                 = False
prec_res_cold@cnLevelSelectionMode      = "ManualLevels"
prec_res_cold@cnMinLevelValF            = 0
prec_res_cold@cnMaxLevelValF            = 312.
prec_res_cold@cnLevelSpacingF           = 2
prec_res_cold@lbLabelFontHeightF        = 0.014
prec_res_cold@lbTitleFontHeightF        = .015
prec_res_cold@lbTitleString             = "[mm]"
prec_res_cold@lbOrientation             = "Horizontal"
prec_res_cold@lbTitleFontThicknessF     = 1
prec_res_cold@pmLabelBarWidthF          = 0.5
prec_res_cold@pmLabelBarHeightF         = 0.059
prec_res_cold@gsnCenterString           = "Precipitation: COA~B~cold~N~"
prec_res_cold@cnFillPalette             = prec_color

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
prec_diff_res@gsnCenterString       = "Precipitation: COA~B~normal~N~ - COA~B~cold~N~"
prec_diff_res@cnFillPalette         = cmap

; COA_normal wind speed.
res_wsp_normal                       = res
res_wsp_normal@cnFillOn              = True
res_wsp_normal@cnLinesOn             = False
res_wsp_normal@cnLevelSelectionMode  = "ManualLevels"
res_wsp_normal@cnMinLevelValF        = 0
res_wsp_normal@cnMaxLevelValF        = 13.
res_wsp_normal@cnLevelSpacingF       = 0.1
res_wsp_normal@lbLabelFontHeightF    = 0.014
res_wsp_normal@lbTitleFontHeightF    = .015
res_wsp_normal@lbTitleString         = "[m s~S~-1~N~]"
res_wsp_normal@lbOrientation         = "Horizontal"
res_wsp_normal@lbTitleFontThicknessF = 1
res_wsp_normal@pmLabelBarWidthF      = 0.5
res_wsp_normal@pmLabelBarHeightF     = 0.059
res_wsp_normal@gsnCenterString       = "Wind speed: COA~B~normal~N~"

; COA_cold wind speed.
res_wsp_cold                       = res
res_wsp_cold@cnFillOn              = True
res_wsp_cold@cnLinesOn             = False
res_wsp_cold@cnLevelSelectionMode  = "ManualLevels"
res_wsp_cold@cnMinLevelValF        = 0
res_wsp_cold@cnMaxLevelValF        = 13.
res_wsp_cold@cnLevelSpacingF       = 0.1
res_wsp_cold@lbLabelFontHeightF    = 0.014
res_wsp_cold@lbTitleFontHeightF    = .015
res_wsp_cold@lbTitleString         = "[m s~S~-1~N~]"
res_wsp_cold@lbOrientation         = "Horizontal"
res_wsp_cold@lbTitleFontThicknessF = 1
res_wsp_cold@pmLabelBarWidthF      = 0.5
res_wsp_cold@pmLabelBarHeightF     = 0.059
res_wsp_cold@gsnCenterString       = "Wind speed: COA~B~cold~N~"

; COA_normal - COA_cold wind speed difference.
res_wsp_diff                       = res
res_wsp_diff@cnFillOn              = True
res_wsp_diff@cnLinesOn             = False
res_wsp_diff@cnLevelSelectionMode  = "ManualLevels"
res_wsp_diff@cnMinLevelValF        = -3.5
res_wsp_diff@cnMaxLevelValF        = 3.5
res_wsp_diff@cnLevelSpacingF       = 0.1
res_wsp_diff@lbLabelFontHeightF    = 0.014
res_wsp_diff@lbTitleFontHeightF    = .015
res_wsp_diff@lbTitleString         = "[m s~S~-1~N~]"
res_wsp_diff@lbOrientation         = "Horizontal"
res_wsp_diff@lbTitleFontThicknessF = 1
res_wsp_diff@pmLabelBarWidthF      = 0.5
res_wsp_diff@pmLabelBarHeightF     = 0.059
res_wsp_diff@gsnCenterString       = "Wind speed: COA~B~normal~N~ - COA~B~cold~N~"
res_wsp_diff@cnFillPalette         = cmap

; Do the contours
contour_sp_normal   = gsn_csm_contour_map(wks,spec_hum_normal,res_sp_normal)
contour_sp_cold     = gsn_csm_contour_map(wks,spec_hum_cold,res_sp_cold)
contour_sp_diff     = gsn_csm_contour_map(wks,spec_hum_diff,res_sp_diff)
contour_thf_normal  = gsn_csm_contour_map(wks,thf_normal,res_thf_normal)
contour_thf_cold    = gsn_csm_contour_map(wks,thf_cold,res_thf_cold)
contour_thf_diff    = gsn_csm_contour_map(wks,thf_diff,res_thf_diff)
contour_mfa_normal  = gsn_csm_contour_map(wks,m_flux_adv_normal,res_mfa_normal)
contour_mfa_cold    = gsn_csm_contour_map(wks,m_flux_adv_cold,res_mfa_cold)
contour_mfa_diff    = gsn_csm_contour_map(wks,m_flux_adv_diff,res_mfa_diff)
contour_prec_normal = gsn_csm_contour_map(wks,prec_normal,prec_res_normal)
contour_prec_cold   = gsn_csm_contour_map(wks,prec_cold,prec_res_cold)
contour_prec_diff   = gsn_csm_contour_map(wks,prec_diff,prec_diff_res)
contour_wsp_normal  = gsn_csm_contour_map(wks,wsp_normal,res_wsp_normal)
contour_wsp_cold    = gsn_csm_contour_map(wks,wsp_cold,res_wsp_cold)
contour_wsp_diff    = gsn_csm_contour_map(wks,wsp_diff,res_wsp_diff)



; Paneling resources.
pres                  = True
pres@gsnMaximize      = True
pres@txString         = " "
pres@gsnPanelLabelBar = False
pres@gsnPanelRowSpec  = True

; Plot.
gsn_panel(wks,(/contour_sp_normal,contour_sp_cold,contour_sp_diff,contour_mfa_normal,contour_mfa_cold,contour_mfa_diff,contour_thf_normal,contour_thf_cold,contour_thf_diff,contour_prec_normal,contour_prec_cold,contour_prec_diff,contour_wsp_normal,contour_wsp_cold,contour_wsp_diff/),(/3,3,3,3,3/),pres)

; Delete blank space.
system("convert -trim "+pltPath+"."+pltType+" "+pltPath+"."+pltType)

end
