;;; sst_tend.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)         ;
; Created        - 13 Sep 2017                                       ;
; Last modified  - 07 Nov 2017                                       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Load prototype scripts
load "/home/ueslei/NCL/loads.ncl"
begin

model = "wrs_d01"
;model = "wr_d01"
;model = "wrf_d01"
;model = "wrs_d02"
;model = "wr_d02"
;model = "wrf_d02"

; Open files
if (model.eq."wr_d01")then
a = addfile("/media/ueslei/Ueslei/INPE/PCI/ciclone_2014/Outputs/WR/wr_d01.nc","r")
end if
if (model.eq."wrs_d01")then
a = addfile("/media/ueslei/Ueslei/INPE/PCI/ciclone_2014/Outputs/WRS/wrs_d01.nc","r")
end if
if (model.eq."wrf_d01")then
a = addfile("/media/ueslei/Ueslei/INPE/PCI/ciclone_2014/Outputs/WRF/wrf_d01.nc","r")
end if
if (model.eq."wr_d02")then
a = addfile("/media/ueslei/Ueslei/INPE/PCI/ciclone_2014/Outputs/WR/wr_d02.nc","r")
end if
if (model.eq."wrs_d02")then
a = addfile("/media/ueslei/Ueslei/INPE/PCI/ciclone_2014/Outputs/WRS/wrs_d01.nc","r")
end if
if (model.eq."wrf_d02")then
a = addfile("/media/ueslei/Ueslei/INPE/PCI/ciclone_2014/Outputs/WRF/wrf_d01.nc","r")
end if


; Read variables at first time step.
times  = wrf_user_getvar(a,"times",-1)
ntimes = dimsizes(times)

; Format date to yyymmddhh.
times1 = wrf_user_getvar(a,"Times",-1)
time_3 = wrf_times_c(times1, 3) ; yyyymmddhh

; Workstation
pltType          = "png"
pltType@wkWidth  = 1000
pltType@wkHeight = 1000
if (model.eq."wr_d01")then
pltName          = "sst_tend_wr_d01"
end if
if (model.eq."wrs_d01")then
pltName          = "sst_tend_wrs_d01"
end if
if (model.eq."wrf_d01")then
pltName          = "sst_tend_wrf_d01"
end if
if (model.eq."wr_d02")then
pltName          = "sst_tend_wr_d02"
end if
if (model.eq."wrs_d02")then
pltName          = "sst_tend_wrs_d02"
end if
if (model.eq."wrf_d02")then
pltName          = "sst_tend_wrf_d02"
end if
pltDir           = "./"
pltPath          = pltDir + pltName
wks              = gsn_open_wks(pltType, pltName)
gsn_define_colormap(wks, "balance")

; Allocate more memory space
setvalues NhlGetWorkspaceObjectId()
 "wsMaximumSize" : 500000000
end setvalues

; Set variables
lsm = wrf_user_getvar(a,"LANDMASK",0)
lat = a->XLAT(0,:,:)
lon = a->XLONG(0,:,:)

; WRF SST
sst_wrf_1    = a->SST(64:88,:,:) ; 25 a 28 de agosto
sst_wrf_2    = mask(sst_wrf_1,lsm.ge.1,False) ; (1 for land, 0 for water)
sst_wrf_3    = sst_wrf_2-273.15
media_wrf    = dim_avg_n_Wrap(sst_wrf_3,0)
sst_wrf_4    = a->SST(63,:,:)
sst_wrf_5    = mask(sst_wrf_4,lsm.ge.1,False) ; (1 for land, 0 for water)
sst_wrf      = sst_wrf_5-273.15
sst_wrf_tend = media_wrf-sst_wrf

; WRF LH
lh_wrf_1     = a->LH(64:88,:,:) ; 25 a 28 de agosto
lh_wrf_2     = mask(lh_wrf_1,lsm.ge.1,False) ; (1 for land, 0 for water)
media_wrf_lh = dim_avg_n_Wrap(lh_wrf_2,0)
lh_wrf_4     = a->LH(63,:,:)
lh_wrf       = mask(lh_wrf_4,lsm.ge.1,False) ; (1 for land, 0 for water)
lh_wrf_tend  = media_wrf_lh-lh_wrf

; Resources
plot                                  = new(6,graphic)
res                                    = True
res@gsnDraw                            = False
res@gsnFrame                           = False
res@lbLabelBarOn                       = True
res@cnInfoLabelOn                      = False
res@gsnLeftString                      = ""
res@gsnRightString                     = ""
res@gsnLeftStringFontHeightF           = 0.001
res@cnLineLabelsOn                     = False
res@cnFillOn                           = True
res@cnLinesOn                          = False
res@tmYROn                             = False
res@tmXTOn                             = False
res@tmXBTickSpacingF                   = 5.
res@tmYLTickSpacingF                   = 5.
res@tmXBLabelFontHeightF               = 0.015
res@tmYLLabelFontHeightF               = 0.015
res@tiMainString                       = " "
res@mpLimitMode                        = "LatLon"
res@gsnAddCyclic                       = False
res@mpFillOn                           = True
res@mpPerimOn                          = True
res@mpGridAndLimbOn                    = False
res@mpOutlineOn                        = True
res@mpCenterLonF                       = -45
res@mpMinLatF                          = -50.
res@mpMaxLatF                          = -20.
res@mpMinLonF                          = -60.
res@mpMaxLonF                          = -30.
res@mpOutlineBoundarySets              = "National"
res@mpDataSetName                      = "Earth..4"
res@mpDataBaseVersion                  = "MediumRes"
res@mpOutlineSpecifiers                = (/"Brazil:states"/)
res@lbTitleOn                          = True
res@lbTitleString                      = " "
res@lbTitleFontHeightF                 = 0.015
res@lbTitlePosition                    = "Bottom"
res@lbLabelFontHeightF                 = 0.015
res@lbBoxSeparatorLinesOn              = False
res@lbTitleOffsetF                     = 0.2
res@pmLabelBarOrthogonalPosF           = 0.15
res@pmLabelBarWidthF                   = 0.5
res@pmLabelBarHeightF                  = 0.06
res@sfXArray                           = lon
res@sfYArray                           = lat
res@mpProvincialLineColor              = "white"
res@mpGeophysicalLineColor             = "white"
res@mpNationalLineColor                = "white"
res@mpLandFillColor                    = "black"

; Plot resources
; Model SST tend
res_sst_tend                           = res
res_sst_tend@cnFillOn                  = True
res_sst_tend@cnLinesOn                 = False
res_sst_tend@cnLevelSelectionMode      = "ManualLevels"
res_sst_tend@cnMinLevelValF            = -1.
res_sst_tend@cnMaxLevelValF            = 1.
res_sst_tend@cnLevelSpacingF           = 0.01
res_sst_tend@lbLabelFontHeightF        = 0.014
res_sst_tend@lbTitleFontHeightF        = .015
res_sst_tend@lbTitleString             = "[~S~o~N~C]"
res_sst_tend@lbOrientation             = "Horizontal"
res_sst_tend@lbTitleFontThicknessF     = 1
res_sst_tend@pmLabelBarOrthogonalPosF  = 0.109
res_sst_tend@pmLabelBarWidthF          = 0.5
res_sst_tend@pmLabelBarHeightF         = 0.059
if (model.eq."wr_d01")then
res_sst_tend@gsnCenterString           = "WR_d01: SST tendency"
end if
if (model.eq."wrs_d01")then
res_sst_tend@gsnCenterString           = "WRS_d01: SST tendency"
end if
if (model.eq."wrf_d01")then
res_sst_tend@gsnCenterString           = "WRF_d01: SST tendency"
end if
if (model.eq."wr_d02")then
res_sst_tend@gsnCenterString           = "WR_d02: SST tendency"
end if
if (model.eq."wrs_d02")then
res_sst_tend@gsnCenterString           = "WRS_d02: SST tendency"
end if
if (model.eq."wrf_d02")then
res_sst_tend@gsnCenterString           = "WRF_d02: SST tendency"
end if

; Model SST AUG 24 18Z
res_sst_24                             = res
res_sst_24@cnFillOn                    = True
res_sst_24@cnLinesOn                   = False
res_sst_24@cnLevelSelectionMode        = "ManualLevels"
res_sst_24@cnMinLevelValF              = 2.
res_sst_24@cnMaxLevelValF              = 28.
res_sst_24@cnLevelSpacingF             = 0.2
res_sst_24@lbLabelFontHeightF          = 0.014
res_sst_24@lbTitleFontHeightF          = .015
res_sst_24@lbTitleString               = "[~S~o~N~C]"
res_sst_24@lbOrientation               = "Horizontal"
res_sst_24@lbTitleFontThicknessF       = 1
res_sst_24@pmLabelBarOrthogonalPosF    = 0.109
res_sst_24@pmLabelBarWidthF            = 0.5
res_sst_24@pmLabelBarHeightF           = 0.059
if (model.eq."wr_d01")then
res_sst_24@gsnCenterString             = "WR_d01: 24 AUG 21Z SST"
end if
if (model.eq."wrs_d01")then
res_sst_24@gsnCenterString             = "WRS_d01: 24 AUG 21Z SST"
end if
if (model.eq."wrf_d01")then
res_sst_24@gsnCenterString             = "WRF_d01: 24 AUG 21Z SST"
end if
if (model.eq."wr_d02")then
res_sst_24@gsnCenterString             = "WR_d02: 24 AUG 21Z SST"
end if
if (model.eq."wrs_d02")then
res_sst_24@gsnCenterString             = "WRS_d02: 24 AUG 21Z SST"
end if
if (model.eq."wrf_d02")then
res_sst_24@gsnCenterString             = "WRF_d02: 24 AUG 21Z SST"
end if
res_sst_24@cnFillPalette               = "MPL_jet"

; WRF SST mean AUG 25-28
res_sst_2528                           = res
res_sst_2528@cnFillOn                  = True
res_sst_2528@cnLinesOn                 = False
res_sst_2528@cnLevelSelectionMode      = "ManualLevels"
res_sst_2528@cnMinLevelValF            = 2.
res_sst_2528@cnMaxLevelValF            = 28
res_sst_2528@cnLevelSpacingF           = 0.2
res_sst_2528@lbLabelFontHeightF        = 0.014
res_sst_2528@lbTitleFontHeightF        = .015
res_sst_2528@lbTitleString             = "[~S~o~N~C]"
res_sst_2528@lbOrientation             = "Horizontal"
res_sst_2528@lbTitleFontThicknessF     = 1
res_sst_2528@pmLabelBarOrthogonalPosF  = 0.119
res_sst_2528@pmLabelBarWidthF          = 0.5
res_sst_2528@pmLabelBarHeightF         = 0.059
if (model.eq."wr_d01")then
res_sst_2528@gsnCenterString           = "WR_d01: 25 to 28 AUG SST mean"
end if
if (model.eq."wrs_d01")then
res_sst_2528@gsnCenterString           = "WRS_d01: 25 to 28 AUG SST mean"
end if
if (model.eq."wrf_d01")then
res_sst_2528@gsnCenterString           = "WRF_d01: 25 to 28 AUG SST mean"
end if
if (model.eq."wr_d02")then
res_sst_2528@gsnCenterString           = "WR_d02: 25 to 28 AUG SST mean"
end if
if (model.eq."wrs_d02")then
res_sst_2528@gsnCenterString           = "WRS_d02: 25 to 28 AUG SST mean"
end if
if (model.eq."wrf_d02")then
res_sst_24@gsnCenterString             = "WRF_d02: 24 AUG 21Z SST"
end if
res_sst_2528@cnFillPalette             = "MPL_jet"

; Model LH tend
res_lh_tend                            = res
res_lh_tend@cnFillOn                   = True
res_lh_tend@cnLinesOn                  = False
res_lh_tend@cnLevelSelectionMode       = "ManualLevels"
res_lh_tend@cnMinLevelValF             = -100.
res_lh_tend@cnMaxLevelValF             = 100.
res_lh_tend@cnLevelSpacingF            = 1
res_lh_tend@lbLabelFontHeightF         = 0.014
res_lh_tend@lbTitleFontHeightF         = .015
res_lh_tend@lbTitleString              = "[W/m~S~2~N~]"
res_lh_tend@lbOrientation              = "Horizontal"
res_lh_tend@lbTitleFontThicknessF      = 1
res_lh_tend@pmLabelBarOrthogonalPosF   = 0.109
res_lh_tend@pmLabelBarWidthF           = 0.5
res_lh_tend@pmLabelBarHeightF          = 0.059
if (model.eq."wr_d01")then
res_lh_tend@gsnCenterString            = "WR_d01: LH tendency"
end if
if (model.eq."wrs_d01")then
res_lh_tend@gsnCenterString            = "WRS_d01: LH tendency"
end if
if (model.eq."wrf_d01")then
res_lh_tend@gsnCenterString            = "WRF_d01: LH tendency"
end if
if (model.eq."wr_d02")then
res_lh_tend@gsnCenterString            = "WR_d02: LH tendency"
end if
if (model.eq."wrs_d02")then
res_lh_tend@gsnCenterString            = "WRS_d02: LH tendency"
end if
if (model.eq."wrf_d02")then
res_lh_tend@gsnCenterString            = "WRF_d02: LH tendency"
end if

; Model LH AUG 24 18Z
res_lh_24                              = res
res_lh_24@cnFillOn                     = True
res_lh_24@cnLinesOn                    = False
res_lh_24@cnLevelSelectionMode         = "ManualLevels"
res_lh_24@cnMinLevelValF               = 0.
res_lh_24@cnMaxLevelValF               = 500.
res_lh_24@cnLevelSpacingF              = 10
res_lh_24@lbLabelFontHeightF           = 0.014
res_lh_24@lbTitleFontHeightF           = .015
res_lh_24@lbTitleString                = "[W/m~S~2~N~]"
res_lh_24@lbOrientation                = "Horizontal"
res_lh_24@lbTitleFontThicknessF        = 1
res_lh_24@pmLabelBarOrthogonalPosF     = 0.109
res_lh_24@pmLabelBarWidthF             = 0.5
res_lh_24@pmLabelBarHeightF            = 0.059
if (model.eq."wr_d01")then
res_lh_24@gsnCenterString              = "WR_d01: 24 AUG 21Z LH"
end if
if (model.eq."wrs_d01")then
res_lh_24@gsnCenterString              = "WRS_d01: 24 AUG 21Z LH"
end if
if (model.eq."wrf_d01")then
res_lh_24@gsnCenterString              = "WRF_d01: 24 AUG 21Z LH"
end if
if (model.eq."wr_d02")then
res_lh_24@gsnCenterString              = "WR_d02: 24 AUG 21Z LH"
end if
if (model.eq."wrs_d02")then
res_lh_24@gsnCenterString              = "WRS_d02: 24 AUG 21Z LH"
end if
if (model.eq."wrf_d02")then
res_lh_24@gsnCenterString              = "WRF_d02: 24 AUG 21Z LH"
end if
res_lh_24@cnFillPalette                = "MPL_jet"

; Model LH mean AUG 25-28
res_lh_2528                            = res
res_lh_2528@cnFillOn                   = True
res_lh_2528@cnLinesOn                  = False
res_lh_2528@cnLevelSelectionMode       = "ManualLevels"
res_lh_2528@cnMinLevelValF             = 0.
res_lh_2528@cnMaxLevelValF             = 500.
res_lh_2528@cnLevelSpacingF            = 10
res_lh_2528@lbLabelFontHeightF         = 0.014
res_lh_2528@lbTitleFontHeightF         = .015
res_lh_2528@lbTitleString              = "[W/m~S~2~N~]"
res_lh_2528@lbOrientation              = "Horizontal"
res_lh_2528@lbTitleFontThicknessF      = 1
res_lh_2528@pmLabelBarOrthogonalPosF   = 0.119
res_lh_2528@pmLabelBarWidthF           = 0.5
res_lh_2528@pmLabelBarHeightF          = 0.059
if (model.eq."wr_d01")then
res_lh_2528@gsnCenterString            = "WR_d01: 25 to 28 AUG LH mean"
end if
if (model.eq."wrs_d01")then
res_lh_2528@gsnCenterString            = "WRS_d01: 25 to 28 AUG LH mean"
end if
if (model.eq."wrf_d01")then
res_lh_2528@gsnCenterString            = "WRF_d01: 25 to 28 AUG LH mean"
end if
if (model.eq."wr_d02")then
res_lh_2528@gsnCenterString            = "WR_d02: 25 to 28 AUG LH mean"
end if
if (model.eq."wrs_d02")then
res_lh_2528@gsnCenterString            = "WRS_d02: 25 to 28 AUG LH mean"
end if
if (model.eq."wrf_d02")then
res_lh_2528@gsnCenterString            = "WRF_d02: 25 to 28 AUG LH mean"
end if
res_lh_2528@cnFillPalette              = "MPL_jet"

; Plots
plot(0) = gsn_csm_contour_map(wks,sst_wrf,res_sst_24)
plot(1) = gsn_csm_contour_map(wks,media_wrf,res_sst_2528)
plot(2) = gsn_csm_contour_map(wks,sst_wrf_tend,res_sst_tend)
plot(3) = gsn_csm_contour_map(wks,lh_wrf,res_lh_24)
plot(4) = gsn_csm_contour_map(wks,media_wrf_lh,res_lh_2528)
plot(5) = gsn_csm_contour_map(wks,lh_wrf_tend,res_lh_tend)

; Panel resources
resP                              = True
resP@gsnPanelCenter               = True
resP@gsnPanelLabelBar             = True
resP@gsnPanelBottom               = 0.08
resP@lbLabelBarOn                 = False

resP@gsnPanelMainFontHeightF      = 0.012
resP@gsnPanelYWhiteSpacePercent   = 5.
gsn_panel(wks,plot,(/2,3/),resP)

; Minimize blank space
system("convert -trim "+pltPath+"."+pltType+" "+pltPath+"."+pltType)

end
