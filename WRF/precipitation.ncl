;;; precipitation.ncl ;;;;;;.....;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 27 Nov 2015                                      ;
; Last modified  - 09 Apr 2016                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts, open file and begin.                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1.1. Prototype scripts.
load "/home/uesleisutil/NCL/loads.ncl"

begin

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Open File                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  dir1         = "/home/uesleisutil/Documentos/Dissertação/Dados/" 
  a            = addfile(dir1+"coawst.nc","r")
; 1.4. Max memory.

  setvalues NhlGetWorkspaceObjectId()
  "wsMaximumSize" : 400000000
  end setvalues

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Read variables at first time step.                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  times  = wrf_user_getvar(a,"times",-1)  ; get all times in the file
  ntimes = dimsizes(times)                ; number of times in the fil
  ntimes = (dimsizes(times)-1) 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Time loop, workstation and print working on.                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  times1 = wrf_user_getvar(a,"Times",-1)   ; get all times in the file
  time_3 = wrf_times_c(times1, 3)          ; yyyymmddhh

  do it  = 17,ntimes-1  
  it2 = it-1

  wks    = gsn_open_wks("png",time_3(it))
  gsn_define_colormap(wks,"MPL_jet") 

  print("Working on time: " + times(it))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4. Set variables.                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  rainc  = wrf_user_getvar(a, "RAINC", -1)
  rainnc = wrf_user_getvar(a, "RAINNC", -1)
  rainsh = wrf_user_getvar(a, "RAINSH", -1)

  lat = a->XLAT(0,:,:)
  lon = a->XLONG(0,:,:)

  raint1 = ((rainc(it,:,:))+(rainnc(it,:,:))+(rainsh(it,:,:)))
  raint2 = ((rainc(it2,:,:))+(rainnc(it2,:,:))+(rainsh(it2,:,:)))
  raint = raint1 - raint2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 5. Set Resources                                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 5.1 Global Resources

  res                                 = True
  res@gsnLeftString                   = " "
  res@gsnRightString                  = " "
  res@gsnCenterString                 = times(it)
  res@gsnCenterStringOrthogonalPosF   = 0.01
  res@tfDoNDCOverlay                  = True           
  res@InitTime                        = False          
  res@Footer                          = False          
  res@mpLimitMode                     = "LatLon"
  res@mpMinLonF                       = -65.0             ; longitude oeste
  res@mpMaxLonF                       = -25.0             ; longitude leste
  res@mpMinLatF                       = -50.0             ; latitude sul
  res@mpMaxLatF                       = -15.0             ; latitude norte
  res@sfXArray                        = lon
  res@sfYArray                        = lat
  res@gsnAddCyclic                    = False

; 5.2 Map Resources

  mpres                               = res
  mpres@gsnMaximize                   = False          ; Maximize plot in frame.
  mpres@mpDataSetName                 = "Earth..4"     ; This new database contains
  mpres@mpDataBaseVersion             = "MediumRes"    ; Medium resolution database
  mpres@mpOutlineOn                   = True           ; Turn on map outlines
  mpres@mpDataBaseVersion             = "MediumRes"
  mpres@mpOutlineSpecifiers           = (/"Brazil:states"/)  
  mpres@mpFillBoundarySets            = "National"
  mpres@mpGridAndLimbOn               = False          ; Default is every 15 deg
  mpres@mpProvincialLineColor         = "black"        ; States line color line
  mpres@mpGeophysicalLineColor        = "black"        ; Contour map color line
  mpres@mpNationalLineColor           = "black"        ; Continent  olor line
  mpres@pmLegendOrthogonalPosF        = -1.99          ; Wind legend localization
  mpres@pmLegendParallelPosF          = 1.0            ; Wind legend localization
  mpres@mpProvincialLineThicknessF    = 3              ; State line thickness  
  mpres@mpNationalLineThicknessF      = 3              ; Continent line thickness
  mpres@mpGeophysicalLineThicknessF   = 3.0
  mpres@mpPerimOn                     = True

; 5.3 Optional Resources

  opts                                = True
  opts@FieldTitle                     = "Precipita"+cedil+atilde+"o Total (mm) "               ; overwrite the filed name
  opts@cnFillOn                       = True  
  opts@lbTitleOn                      = True                                ; remove field name from label bar
  opts@cnLevelSelectionMode           = "ExplicitLevels"
  opts@cnLevels                       = ispan(0,50,1)

; 5.4. Plot Resources

  pltres                              = True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 6. Plot                                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  contour = wrf_contour(a,wks,raint(:,:),opts)
  plot    = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)

end do
end