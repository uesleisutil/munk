;*************************************************
; corel_3.ncl
;
; Concepts illustrated:
;   - Calculating a two-dimensional correlation in time
;   - Reordering an array
;   - Copying attributes from one variable to another
;   - Copying coordinate arrays from one variable to another
;
;************************************************

 load "/home/ueslei/Documentos/NCL/scripts/loads.ncl"

 begin
   
 
;************************************************
; open file and read in variable
;***********************************************
  dir = "/home/ueslei/Documentos/Dissertação/Dados/COAWST/"
  a   = addfile(dir+"wrfout_d01_2006-08-27_00:00:00","r")
  
  lat2d = a->XLAT(0,:,0)
  lon2d = a->XLONG(0,0,:)
  
  lsm = wrf_user_getvar(a,"LANDMASK",-1)  
  lh1  = wrf_user_getvar(a,"LH",-1)   
  sst1 = wrf_user_getvar(a,"SST",-1)  

  sst = mask(sst1,lsm.ge.1,False)
  lh  = mask(lh1,lsm.ge.1,False)

  copy_VarCoords(lh1, lh)
  copy_VarCoords(sst1, sst)

  printVarSummary(sst)
;************************************************
; reorder to get time as right most dimension
;***********************************************
  ts1 = lh(south_north|:,west_east|:,Time|:)
  ts2 = sst(south_north|:,west_east|:,Time|:)
;************************************************
; calculate cross correlations
;************************************************
  maxlag = 13                                    ; set lag
; note, the max lag should not be more than N/4
  
  ccr = esccr(ts1,ts2,maxlag)                   ; calc cross correlations

; copy meta data and coordinate variables using contributed functions
  copy_VarAtts(ts1, ccr)                    
  copy_VarCoords_1(ts2,ccr)
;************************************************
; plot the correlations
;************************************************
  wks  = gsn_open_wks("png","corel")              ; open a ps plot
  gsn_define_colormap(wks,"BlWhRe")              ; choose colormap
 
  res                               = True                ; make plot mods
  res@cnFillOn                      = True                ; turn on color
  res@gsnSpreadColors               = True                ; use full colormap
  res@lbLabelAutoStride             = True                ; automatic lb label stride
  res@cnLinesOn                     = False               ; turn off contour lines
  res@cnLevelSelectionMode          = "ManualLevels"      ; manually set cn levels
  res@cnMinLevelValF                = -1.                 ; min level
  res@cnMaxLevelValF                =  1.                 ; max level
  res@cnLevelSpacingF               = .1                  ; contour level spacing
  res@mpDataSetName                 = "Earth..4"
  res@mpDataBaseVersion             = "MediumRes"
  res@mpOutlineOn                   = True
  res@mpGeophysicalLineThicknessF   = 3
  res@mpNationalLineThicknessF      = 3
  res@mpFillOn                      = True
  res@lbOrientation                 = "Horizontal"
  res@mpOutlineBoundarySets         = "National"                              ; divisão dos países
  res@mpOutlineSpecifiers           = (/"Brazil:states"/)                     ; divisão dos estados brasileiros
  res@mpProvincialLineThicknessF    = 3              ; State line thickness  
  res@mpNationalLineThicknessF      = 3              ; Continent line thickness
  res@mpPerimLineThicknessF         = 3.0
  res@gsnMajorLatSpacing            = 05
  res@gsnMajorLonSpacing            = 10 
  res@mpMinLonF                     = min(lon2d)             ; longitude oeste
  res@mpMaxLonF                     = max(lon2d)             ; longitude leste
  res@mpMinLatF                     = min(lat2d)            ; latitude sul
  res@mpMaxLatF                     = max(lat2d)            ; latitude norte

  lag                      = 0
  printVarSummary(ccr)
  res@tiMainString         = "Correlations at lag "+lag


  plot = gsn_csm_contour_map_ce(wks,ccr(:,:,lag),res) 
;************************************************
end