;;; bias_rmse_roms_ostia.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)         ;
; Created        - 23 Aug 2017                                       ;
; Last modified  - 23 Aug 2017                                       ;
; About          - Calculate and plot the Bias and RMSE using ROMS   ;
;                  and OSTIA datasets.                               ;
; Caution        - Post-process the data before using this script!   ;                                    ;
;                  cdo selvar,SST,LANDMASK wrfout.. wrs_I_t02_aug.nc ;
;                  cdo daymean wrs_I_t02_aug.nc wrs_I_t02_daily.nc   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;.;;;

; Load prototype scripts
load "/home/uesleisutil/NCL/loads.ncl"

; Begin the script
begin

 ; Regrid new coords
 yo           = fspan(-50.,-20.,576)
 xo           = fspan(-60.,-30.,461)
 yo@long_name = "south_north"
 xo@long_name = "west_east"
 yo@units     = "degrees_north"
 xo@units     = "degrees_east"

 ; Calculate the Bias
 ; WRF data
 model           = addfile("/media/uesleisutil/Ueslei/INPE/2014/Outputs/WRF/wrf_I_t01_aug.nc","r")
 model_latlon    = addfile("/media/uesleisutil/Ueslei/INPE/2014/Outputs/WRF/wrf_I_t01.nc","r")
 nl1             = 691 ; lat 20S
 nl0             = 116 ; lat 50S
 ml0             = 142 ; lon 60W
 ml1             = 602 ; lon 30W
 lat_mod         = model_latlon->XLAT (0,nl0:nl1,0)
 lon_mod         = model_latlon->XLONG(0,0,ml0:ml1)
 lsm             = model->LANDMASK(0,nl0:nl1,ml0:ml1)

 model_sst       = model->SST(:,nl0:nl1,ml0:ml1)
 model_sst2      = model_sst-273.15
 model_sst3      = mask(model_sst2,lsm.ge.1,False)
 copy_VarCoords(model_sst,model_sst3)

 model_sst_mean   = dim_avg_n_Wrap(model_sst3,0)
 model_sst_regrid = linint2_Wrap(lon_mod,lat_mod,model_sst_mean,True,xo,yo,0)

 model_sst_regrid!0           = "south_north"
 model_sst_regrid!1           = "west_east"
 model_sst_regrid&south_north = yo
 model_sst_regrid&west_east   = xo

 delete([/nl1,nl0,ml0,ml1,lat_mod,lon_mod,lsm,model_sst2,model_sst_mean/])

 ; OSTIA data
 ostia   = addfile("/media/uesleisutil/Ueslei/INPE/2014/Dados/GLORYS/glorys_aug.nc","r")
 nl0     = -50.
 nl1     = -20.
 ml0     = -60.
 ml1     = -30.
 lat_sat = ostia->latitude({nl0:nl1})
 lon_sat = ostia->longitude({ml0:ml1})

 ostia_sst = short2flt(ostia->thetao(:,0,{nl0:nl1},{ml0:ml1}))
 ostia_sst = ostia_sst

 ostia_sst_regrid = linint2_Wrap(lon_sat,lat_sat,ostia_sst,True,xo,yo,0)
 printVarSummary(ostia_sst_regrid)
 ostia_sst_mean_regrid = dim_avg_n_Wrap(ostia_sst_regrid,0)
 copy_VarCoords(model_sst_regrid,ostia_sst_mean_regrid)

 ; Calculate bias
 bias = model_sst_regrid-ostia_sst_mean_regrid                        ; >0 - modelo mais quente
 copy_VarCoords(model_sst_regrid,bias)

 ; Atributes
 model_sst_regrid&south_north      = yo
 ostia_sst_mean_regrid&south_north = yo
 bias&south_north                  = yo

 model_sst_regrid&west_east        = xo
 ostia_sst_mean_regrid&west_east   = xo
 bias&west_east                    = xo

 delete([/ostia,nl0,nl1,ml0,ml1,lat_sat,lon_sat/])

 ; Calculate RMSE

 model_daily= addfile("/media/uesleisutil/Ueslei/INPE/2014/Outputs/WRF/wrf_I_t01_daily.nc","r")

 nl1     = 691 ; lat 20S
 nl0     = 116 ; lat 50S
 ml0     = 142 ; lon 60W
 ml1     = 602 ; lon 30W
 lat_mod = model_latlon->XLAT (0,nl0:nl1,0)
 lon_mod = model_latlon->XLONG(0,0,ml0:ml1)
 lsm     = model_daily->LANDMASK(0,nl0:nl1,ml0:ml1)

 sst_model_daily1 = model_daily->SST(:,nl0:nl1,ml0:ml1)
 sst_model_daily2 = sst_model_daily1-273.15
 sst_model_daily  = mask(sst_model_daily2,lsm.ge.1,False)
 copy_VarCoords(sst_model_daily1,sst_model_daily)

 sst_model_daily_regrid = linint2_Wrap(lon_mod,lat_mod,sst_model_daily,True,xo,yo,0)

 sst_model_daily_regrid!1           = "south_north"
 sst_model_daily_regrid!2           = "west_east"
 sst_model_daily_regrid&south_north = yo
 sst_model_daily_regrid&west_east   = xo

 rmse = dim_rmsd_n_Wrap(sst_model_daily_regrid,ostia_sst_regrid,0)

 ; Workstation
 pltType          = "png"
 pltType@wkWidth  = 1000
 pltType@wkHeight = 1000
 pltName          = "bias_rmse_roms_ostia"
 pltDir           = "./"
 pltPath          = pltDir + pltName
 wks              = gsn_open_wks(pltType, pltName)
 gsn_define_colormap(wks, "thermal")

 setvalues NhlGetWorkspaceObjectId()
   "wsMaximumSize" : 500000000
 end setvalues

 ; Resources
 plot    = new(4,graphic)
 res                          = True
 res@gsnDraw                  = False                ; don't draw
 res@gsnFrame                 = False                ; don't advance frame
 res@lbLabelBarOn             = True
 res@cnInfoLabelOn            = False
 res@gsnLeftString            = ""
 res@gsnRightString           = ""
 res@gsnLeftStringFontHeightF = 0.001
 res@cnLineLabelsOn           = False                ; do not use line labels
 res@cnFillOn                 = True                 ; color fill
 res@cnLinesOn                = False                ; do not draw contour lines
 res@tmYROn                   = False                ; Turn off right and top tick marks
 res@tmXTOn                   = False                ; Turn off right and top tick marks
 res@tmXBTickSpacingF         = 5.
 res@tmYLTickSpacingF         = 5.
 res@tmXBLabelFontHeightF     = 0.015
 res@tmYLLabelFontHeightF     = 0.015
 res@tiMainString             = " "                  ; set the main title
 res@sfXArray                 = xo
 res@sfYArray                 = yo
 res@mpLimitMode              = "LatLon"
 res@gsnAddCyclic             = False
 res@mpFillOn                 = True
 res@mpPerimOn                = True
 res@mpGridAndLimbOn          = False               ; Default is every 15 deg
 res@mpOutlineOn              = True                ; Turn on map outlines
 res@mpCenterLonF             = -45
 res@mpMinLatF                = -50.
 res@mpMaxLatF                = -20.
 res@mpMinLonF                = -60.
 res@mpMaxLonF                = -30.
 res@mpOutlineBoundarySets    = "National"
 res@mpDataSetName            = "Earth..4"     ; This new database contains
 res@mpDataBaseVersion        = "MediumRes"    ; Medium resolution database
 res@mpOutlineSpecifiers      = (/"Brazil:states"/)
 res@lbTitleOn                = True
 res@lbTitleString            = " "
 res@lbTitleFontHeightF       = 0.015
 res@lbTitlePosition          = "Bottom"
 res@lbLabelFontHeightF       = 0.015
 res@lbBoxSeparatorLinesOn    = False
 res@lbTitleOffsetF           = 0.2
 res@pmLabelBarOrthogonalPosF = 0.15
 res@pmLabelBarWidthF         = 0.5
 res@pmLabelBarHeightF        = 0.06

 ; Plot resources
 res0                         = res
 res1                         = res
 res2                         = res
 res3                         = res

 ; ROMS mean plot resources
 res0@gsnCenterString         = "SST ROMS"
 res0@cnLevelSelectionMode    = "ManualLevels"       ; set manual contour levels
 res0@cnMinLevelValF          = 0                      ; set min contour level
 res0@cnMaxLevelValF          = 30                   ; set max contour level
 res0@cnLevelSpacingF         = 0.2                   ; set contour spacing
 res0@lbTitleString           = "SST [~S~o~N~C]"
 res0@lbTitleFontHeightF      = 0.015
 ;res0@pmLabelBarParallelPosF  = 1.50

 ; OSTIA mean plot resources
 res1@gsnCenterString         = "SST OSTIA"
 res1@cnLevelSelectionMode    = "ManualLevels"       ; set manual contour levels
 res1@cnMinLevelValF          = 0                      ; set min contour level
 res1@cnMaxLevelValF          = 30                   ; set max contour level
 res1@cnLevelSpacingF         = 0.2                   ; set contour spacing
 res1@lbTitleString           = "SST [~S~o~N~C]"
 res1@lbTitleFontHeightF      = 0.015
 ;res1@lbLabelBarOn             = False

 ; Bias plot resources
 res2@gsnCenterString         = "Bias: ROMS minus OSTIA"
 res2@cnLevelSelectionMode    = "ManualLevels"       ; set manual contour levels
 res2@cnMinLevelValF          = -4                      ; set min contour level
 res2@cnMaxLevelValF          = 4                   ; set max contour level
 res2@cnLevelSpacingF         = 0.05                   ; set contour spacing
 res2@cnFillPalette           = "balance"
 res2@lbTitleString           = "SST [~S~o~N~C]"
 res2@lbTitleFontHeightF      = 0.015

 ; RMSE plot resources
 res3@gsnCenterString         = "RMSE: ROMS and OSTIA"
 res3@cnLevelSelectionMode    = "ManualLevels"       ; set manual contour levels
 res3@cnMinLevelValF          = 0                      ; set min contour level
 res3@cnMaxLevelValF          = 4                   ; set max contour level
 res3@cnLevelSpacingF         = 0.05                   ; set contour spacing
 res3@cnFillPalette           = "thermal"
 res3@lbTitleString           = "SST [~S~o~N~C]"
 res3@lbTitleFontHeightF      = 0.015

 ; Plots
 plot(0) = gsn_csm_contour_map(wks,model_sst_regrid,res0)
 plot(1) = gsn_csm_contour_map(wks,ostia_sst_mean_regrid,res1)
 plot(2) = gsn_csm_contour_map(wks,bias,res2)
 plot(3) = gsn_csm_contour_map(wks,rmse,res3)

 ; Panel resources
 resP                              = True
 resP@gsnPanelCenter               = True
 resP@gsnPanelLabelBar             = True
 resP@gsnPanelBottom               = 0.08
 resP@lbLabelBarOn                 = False
 gsn_panel(wks,plot,(/2,2/),resP)

 ; Minimize blank space
 system("convert -trim "+pltPath+"."+pltType+" "+pltPath+"."+pltType)

 end
