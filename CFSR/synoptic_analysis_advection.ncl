;;; synoptic_analysis_advection.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 21 Apr 2016                                      ;
; Last modified  - 21 Apr 2016                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts, open file and begin.                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1.1. Prototype scripts.

  load "/home/uesleisutil/NCL/loads.ncl"

; 1.2. Begin. 

  begin

  f   = addfile("/home/uesleisutil/Documentos/diss/cfsr/cfsr.nc","r")
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Set variables and do,                                          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 2.1. Set time.
  time         = f->time
  times        = cd_calendar(time, -3) ; YYYYMMDDHH
  times        = times-1
  ntimes       = dimsizes(times) 

; 2.2. Set, manually, the pressure levels.
  height       = (/250/)   

; 2.3. Set start.
  do it        = 0,30   
  print("Working on " +height+ " hPa. Time: " + times(it) )
   
; 2.5. Set variables.
   u           = f->U_GRD_L100(it,{height},:,:)
   v           = f->V_GRD_L100(it,{height},:,:)
   hgt         = f->HGT_L100(it,{height},:,:)
   wrf_smooth_2d(hgt, 20)
   lat2d       = f->lat 
   lon2d       = f->lon 

; 2.6. Calculate relative vorticity.
   vort1       = uv2dv_cfd(u,v,lat2d,lon2d,2)
   vort        = vort1*100000 ; normalize vorticity to 10^-5 s^-1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Set global Resources                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  res                                    = True
  res@gsnFrame                           = False
  res@gsnDraw                            = False
  res@gsnLeftString                      = " "
  res@gsnRightString                     = " "
  res@gsnCenterString                    = " "
  res@gsnCenterStringOrthogonalPosF      = 0.01
  ;res@gsnAddCyclic                       = True
  res@tfDoNDCOverlay                     = True          ; Necessary for contours to be overlaid correctly on WRF projection
  res@tiXAxisString                      = " "
  res@tiYAxisString                      = " "
  res@tiMainString                       = times(it)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4. Set map Resources I                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  mpres                                  = True
  mpres                                  = res
  mpres@mpDataSetName                    = "Earth..4"          ; This new database contains
  mpres@mpDataBaseVersion                = "MediumRes"         ; Medium resolution database
  mpres@mpOutlineOn                      = True                ; Turn on map outlines
  mpres@mpDataBaseVersion                = "MediumRes"
  mpres@mpOutlineSpecifiers              = (/"Brazil:states"/)  
  mpres@mpGridAndLimbOn                  = True               ; Default is every 15 deg
  mpres@mpGridLatSpacingF                = 15
  mpres@mpGridLonSpacingF                = 15 
  mpres@mpProvincialLineColor            = "black"             ; States line color line
  mpres@mpGeophysicalLineColor           = "black"             ; Contour map color line
  mpres@mpNationalLineColor              = "black"             ; Continent  olor line
  mpres@pmLegendOrthogonalPosF           = -0.99               ; Wind legend localization
  mpres@pmLegendParallelPosF             = 1.0                 ; Wind legend localization
  mpres@mpProvincialLineThicknessF       = 3                   ; State line thickness  
  mpres@mpNationalLineThicknessF         = 3                   ; Continent line thickness
  mpres@mpGeophysicalLineThicknessF      = 3.0 
  mpres@mpPerimOn                        = True
  mpres@mpPerimLineThicknessF            = 3.0
  mpres@mpMinLonF                        = -85.0               ; longitude oeste
  mpres@mpMaxLonF                        = -25.0               ; longitude leste
  mpres@mpMinLatF                        = -50.0               ; latitude sul
  mpres@mpMaxLatF                        = 15.0               ; latitude norte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 5. Set Resources                                                  ;
;;;;;;;;;;;;;;;;; ,,;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 5.1. Set resorces for 250 hPa
  if (height.eq.250)then  

         ; 5.1.1 Workstation option        
         wks                                    = gsn_open_wks("png","./cfsr_250/250_"+it)
         gsn_define_colormap(wks,"cmp_b2r")                      ; Colorbar
                  
         ; 5.1.2. Wind speed contour resources.
                  w1_res                                 = res
         w1_res@cnFillOn                        = True  
         w1_res@cnLinesOn                       = False 
         w1_res@cnLevelSelectionMode            = "ManualLevels"
         w1_res@cnMinLevelValF                  = -12.                 ; set min contour level
         w1_res@cnMaxLevelValF                  = 12.                 ; set max contour level
         w1_res@cnLevelSpacingF                 = 1                   ; set contour spacing
         w1_res@lbTitleFontHeightF              = .015                    
         w1_res@lbOrientation                   = "Vertical"
         w1_res@lbTitleFontThicknessF           = 1
         contour_wind                           = gsn_csm_contour(wks,vort,w1_res)

         ; 5.1.3. Wind speed vector resources.
         w2_res                                 = res         
         w2_res@vcGlyphStyle                    = "CurlyVector"       ; turn on curly vectors
         w2_res@vcMinDistanceF                  = 0.045               ; thin out vectors
         w2_res@vcLineArrowThicknessF           = 4
         w2_res@vcRefAnnoOn                     = True
         w2_res@vcRefAnnoSide                   = "Bottom"

         w2_res@vcMonoLineArrowColor            = True                ; color arrows based on magnitude
         w2_res@vcMinFracLengthF                = 0.9

         w2_res@pmLabelBarWidthF                = 0.38                ; make it thinner
         w2_res@pmLabelBarHeightF               = 0.05
         w2_res@lbPerimOn                       = False               ; no box around it
         w2_res@pmLabelBarParallelPosF          = 0.
         w2_res@pmLabelBarOrthogonalPosF        = 0.1
         w2_res@lbLabelFontHeightF              = 0.014

         w2_res@vcRefAnnoString2On              = True
         w2_res@vcRefAnnoPerimOn                = True
         w2_res@vcRefAnnoOrthogonalPosF         = -1.249
         w2_res@vcRefAnnoParallelPosF           = 1.0
         w2_res@vcRefLengthF                    = 0.050               ; reference vector length
         w2_res@vcRefMagnitudeF                 = 10
         w2_res@vcRefAnnoFontThicknessF         = 1
         w2_res@vcRefAnnoString1                = "10 m/s"
         w2_res@vcRefAnnoBackgroundColor        = "White"

         w2_res@vcVectorDrawOrder               = "PostDraw"
         vector_wind                            = gsn_csm_vector(wks,u,v,w2_res)

         ; 5.1.4. Geopotential Height contour resources.
         hgt_res                                = res
         hgt_res@cnLineColor                    = "Blue"
         hgt_res@cnLevelSelectionMode           = "ExplicitLevels"
         hgt_res@cnLevels                       = ispan(9500,11100,80)
         ;hgt_res@cnLineLabelBackgroundColor     = -1                  ; transparent
         hgt_res@cnLineThicknessF               = 4.5
         hgt_res@cnHighLabelsOn                 = False
         hgt_res@cnLowLabelsOn                  = False
         hgt_res@cnHighLabelBackgroundColor     = -1
         hgt_res@cnLowLabelBackgroundColor      = -1
         hgt_res@cnInfoLabelString              = " "
         hgt_res@cnInfoLabelOrthogonalPosF      = 0.237
         hgt_res@cnInfoLabelParallelPosF        = 0.79
         hgt_res@cnInfoLabelFontColor           = "Black"
         hgt_res@cnInfoLabelPerimOn             = False   
         hgt_res@cnHighLowLabelOverlapMode      = "OmitOverVPAndHL"

         contour_hgt                            = gsn_csm_contour(wks,hgt,hgt_res)
    end if

; 5.2. Set resources for 500 hPa
  if (height.eq.500)then 
        
         ; 5.1. Workstation option        
                 ; 5.1.1 Workstation option        
         wks                                    = gsn_open_wks("png","./cfsr_500/500_"+it)
         gsn_define_colormap(wks,"MPL_RdBu")                      ; Colorbar
                  
         ; 5.1.2. Wind speed contour resources.
         w1_res                                 = res
         w1_res@cnFillOn                        = True  
         w1_res@cnLinesOn                       = False 
         w1_res@cnLevelSelectionMode            = "ManualLevels"
         w1_res@cnMinLevelValF                  = -12.                 ; set min contour level
         w1_res@cnMaxLevelValF                  = 12.                 ; set max contour level
         w1_res@cnLevelSpacingF                 = 1                   ; set contour spacing
         w1_res@lbTitleFontHeightF              = .015                    
         w1_res@lbOrientation                   = "Vertical"
         w1_res@lbTitleFontThicknessF           = 1
         contour_wind                           = gsn_csm_contour(wks,vort,w1_res)

         ; 5.1.3. Wind speed vector resources.
         w2_res                                 = res         
         w2_res@vcGlyphStyle                    = "CurlyVector"       ; turn on curly vectors
         w2_res@vcMinDistanceF                  = 0.045               ; thin out vectors
         w2_res@vcLineArrowThicknessF           = 4
         w2_res@vcRefAnnoOn                     = True
         w2_res@vcRefAnnoSide                   = "Bottom"

         w2_res@vcMonoLineArrowColor            = True                ; color arrows based on magnitude
         w2_res@vcMinFracLengthF                = 0.9

         w2_res@pmLabelBarWidthF                = 0.38                ; make it thinner
         w2_res@pmLabelBarHeightF               = 0.05
         w2_res@lbPerimOn                       = False               ; no box around it
         w2_res@pmLabelBarParallelPosF          = 0.
         w2_res@pmLabelBarOrthogonalPosF        = 0.1
         w2_res@lbLabelFontHeightF              = 0.014

         w2_res@vcRefAnnoString2On              = True
         w2_res@vcRefAnnoPerimOn                = True
         w2_res@vcRefAnnoOrthogonalPosF         = -1.249
         w2_res@vcRefAnnoParallelPosF           = 1.0
         w2_res@vcRefLengthF                    = 0.050               ; reference vector length
         w2_res@vcRefMagnitudeF                 = 10
         w2_res@vcRefAnnoFontThicknessF         = 1
         w2_res@vcRefAnnoString1                = "10 m/s"
         w2_res@vcRefAnnoBackgroundColor        = "White"

         w2_res@vcVectorDrawOrder               = "PostDraw"
         vector_wind                            = gsn_csm_vector(wks,u,v,w2_res)

         ; 5.1.4. Geopotential Height contour resources.
         hgt_res                                = res
         hgt_res@cnLineColor                    = "Blue"
         hgt_res@cnLevelSelectionMode           = "ExplicitLevels"
         hgt_res@cnLevels                       = ispan(4500,6000,50)
         ;hgt_res@cnLineLabelBackgroundColor     = -1                  ; transparent
         hgt_res@cnLineThicknessF               = 4.5
         hgt_res@cnHighLabelsOn                 = False
         hgt_res@cnLowLabelsOn                  = False
         hgt_res@cnHighLabelBackgroundColor     = -1
         hgt_res@cnLowLabelBackgroundColor      = -1
         hgt_res@cnInfoLabelString              = " "
         hgt_res@cnInfoLabelOrthogonalPosF      = 0.237
         hgt_res@cnInfoLabelParallelPosF        = 0.79
         hgt_res@cnInfoLabelFontColor           = "Black"
         hgt_res@cnInfoLabelPerimOn             = False   
         hgt_res@cnHighLowLabelOverlapMode      = "OmitOverVPAndHL"

         contour_hgt                            = gsn_csm_contour(wks,hgt,hgt_res)
    end if

; 5.3. Set resources for 850 hPa
  if (height.eq.850)then ; 850 hPa
         
         ; 5.1.1 Workstation option        
         wks                                    = gsn_open_wks("png","./cfsr_850/850_"+it)
         gsn_define_colormap(wks,"cmp_b2r")                      ; Colorbar
                  
         ; 5.1.2. Wind speed contour resources.
         w1_res                                 = res
         w1_res@cnFillOn                        = True  
         w1_res@cnLinesOn                       = False 
         w1_res@cnLevelSelectionMode            = "ManualLevels"
         w1_res@cnMinLevelValF                  = 00.                 ; set min contour level
         w1_res@cnMaxLevelValF                  = 40.                 ; set max contour level
         w1_res@cnLevelSpacingF                 = 1                   ; set contour spacing
         w1_res@lbTitleFontHeightF              = .015                    
         w1_res@lbOrientation                   = "Vertical"
         w1_res@lbTitleFontThicknessF           = 1
         contour_wind                           = gsn_csm_contour(wks,wnd_spd,w1_res)

         ; 5.1.3. Wind speed vector resources.
         w2_res                                 = res         
         w2_res@vcGlyphStyle                    = "CurlyVector"       ; turn on curly vectors
         w2_res@vcMinDistanceF                  = 0.045               ; thin out vectors
         w2_res@vcLineArrowThicknessF           = 4
         w2_res@vcRefAnnoOn                     = False
         w2_res@vcRefAnnoSide                   = "Bottom"

         w2_res@vcMonoLineArrowColor            = True                ; color arrows based on magnitude
         w2_res@vcMinFracLengthF                = 0.9

         w2_res@pmLabelBarWidthF                = 0.38                ; make it thinner
         w2_res@pmLabelBarHeightF               = 0.05
         w2_res@lbPerimOn                       = False               ; no box around it
         w2_res@pmLabelBarParallelPosF          = 0.
         w2_res@pmLabelBarOrthogonalPosF        = 0.1
         w2_res@lbLabelFontHeightF              = 0.014

         w2_res@vcRefAnnoString2On              = True
         w2_res@vcRefAnnoPerimOn                = True
         w2_res@vcRefAnnoOrthogonalPosF         = -1.249
         w2_res@vcRefAnnoParallelPosF           = 1.0
         w2_res@vcRefLengthF                    = 0.050               ; reference vector length
         w2_res@vcRefMagnitudeF                 = 10
         w2_res@vcRefAnnoFontThicknessF         = 1
         w2_res@vcRefAnnoString1                = "10 m/s"
         w2_res@vcRefAnnoBackgroundColor        = "White"

         w2_res@vcVectorDrawOrder               = "PostDraw"
         vector_wind                            = gsn_csm_vector(wks,u,v,w2_res)

         ; 5.1.4. Geopotential Height contour resources.
         hgt_res                                = res
         hgt_res@cnLineColor                    = "White"
         hgt_res@cnLevelSelectionMode           = "ExplicitLevels"
         hgt_res@cnLevels                       = ispan(900,2000,80)
         hgt_res@cnLineLabelBackgroundColor     = -1                  ; transparent
         hgt_res@cnLineThicknessF               = 4.5
         hgt_res@cnHighLabelsOn                 = True
         hgt_res@cnLowLabelsOn                  = True
         hgt_res@cnHighLabelBackgroundColor     = -1
         hgt_res@cnLowLabelBackgroundColor      = -1
         hgt_res@cnInfoLabelString              = " "
         hgt_res@cnInfoLabelOrthogonalPosF      = 0.237
         hgt_res@cnInfoLabelParallelPosF        = 0.79
         hgt_res@cnInfoLabelFontColor           = "Black"
         hgt_res@cnInfoLabelPerimOn             = False   
         hgt_res@cnHighLowLabelOverlapMode      = "OmitOverVPAndHL"
         contour_hgt                            = gsn_csm_contour(wks,hgt,hgt_res)

    end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 6. Set map Resources II                                          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  mpres@gsnFrame                         = False
  mpres@gsnDraw                          = False
  mpres                                  = wrf_map_resources(f,mpres)
  map                                    = gsn_csm_map(wks,mpres)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 7. Overlay plots on map and draw                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  overlay(map,vector_wind)
  overlay(map,contour_wind) 
  overlay(map,contour_hgt) 

  draw(map)   ; This will draw all overlaid plots and the map
  frame(wks)
  end do

  end