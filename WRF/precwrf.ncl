 ;******************************************************************;
;* Script    - precwrf.ncl                                         *;
;*                                                                 *;
;* Author    - Ueslei Adriano Sutil                                *;
;*                                                                 *;
;* Created   - 01 set 2015                                         *;
;* Update    - 01 jun 2015                                         *;
;*                                                                 *;
;* About     - This program is a script that will plot total pre-  *;
;*             cipitation on WRF model.                            *;
;* Input     - WRF                                                 *;
;* Variables - RAINC e RAINNC                                      *;
;*                                                                 *;
;*******************************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts, open file and begin.                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 load "/home/ueslei/Documentos/NCL/scripts/loads.ncl"

; 1.2. Begin.
  
begin

; 1.3. Open files.

  dir = "/home/ueslei/Documentos/Dissertação/Dados/WRF/" 
a    = addfile(dir+"wrfout_d01_2006-08-27_00:00:00.nc","r")

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

do it  = 1,ntimes-1  
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


raint1 = ((rainc(it,:,:))+(rainnc(it,:,:))+(rainsh(it,:,:)))
raint2 = ((rainc(it2,:,:))+(rainnc(it2,:,:))+(rainsh(it2,:,:)))
raint = raint1 - raint2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 5. Set Resources                                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 5.1 Map Resources

mpres                               = True
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

; 5.2 Global Resources

res                                 = True
res@gsnLeftString                   = " "
res@gsnRightString                  = " "
res@gsnCenterString                 = times(it)
res@gsnCenterStringOrthogonalPosF   = 0.01
res@tfDoNDCOverlay                  = True           ; Necessary for contours to be overlaid correctly on WRF projection
res@InitTime                        = False          ; do not plot initial time
res@Footer                          = False          ; switch footers off

; 5.3 Optional Resources

opts                                = True
opts@FieldTitle                     = "Precipitacao Total (kg m~S~-2~N~) "               ; overwrite the filed name
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