;----------------------------------------------------------------------
; wrf_interp_3.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Interpolating a vertical cross-section from a 3D WRF-ARW field.
;----------------------------------------------------------------------
; wrf_user_vert_cross and wrf_user_interp_level replace the 
; deprecated wrf_user_intrp3d function. 
;
; NCL V6.6.0 or higher is required to run this example.
;----------------------------------------------------------------------

begin
Loop = (/"00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60","61","62","63","64","65","66","67","68","69","70","71","72","73","74","75","76","77","78","79","80","81","82","83","84","85","86","87","88","89","90","91","92","93","94","95","96","97","98","99"/)

Domain  = (/"1","2","3","4"/)
Lat_o   = 41.093
Lat_f   = (/43.088947,42.101391,41.355423/)
Lon_o   = -71.135
Lon_f   = (/-76.154480,-72.590279,-72.102760/)

Path     = "/shared/airmg/MIKE/WRFv4.1.3/Build_WRF/DATA/NAM12k_2004/Testing_Domains/Domain_successful_d07/wrfout_files/wrfprd/"
do j=0,3-1
  print(j)
  Listing = systemfunc("ls "+Path+"*wrfout_d0"+Domain(j)+"*")
  hours = dimsizes(Listing)
  do i=0,hours-1
  	a       = addfile(Listing(i),"r")
  	;Convert to height using geopotential height interpolation
  	go      = 9.80665
  	PH_st   = wrf_user_getvar(a, "PH",0)
  	PH_us   = PH_st(1:50,:,:)
  	PHB_st  = wrf_user_getvar(a, "PHB",0)
  	PHB_us  = PHB_st(1:50,:,:)
  	z    = (PH_us+PHB_us)/go          ; grid point height
  
  	;For the same height, calculate wind speed
  	;U   = wrf_user_getvar(a, "U",0)     ; cloud field
  	;V   = wrf_user_getvar(a, "V",0)     ; cloud field
  	;WS_z  = wind_speed(U,V)

  	;For temperature
  	P    = wrf_user_getvar(a, "P",0)
  	Pb   = wrf_user_getvar(a, "PB",0)
  	P    = P+Pb

  	T    = wrf_user_getvar(a, "T",0)
  	T    = T+300
	TK = wrf_tk (P, T)
	;qv    = wrf_user_getvar(a, "QVAPOR",0)
;P,Pb,P,T,TK,PH_st,PH_us,PHB_st,PHB_us,z,Listing,lats,lons
  	;Get coordinates
  	lats = wrf_user_getvar(a, "lat",0)
  	lons = wrf_user_getvar(a, "lon",0)

  	;Start and end points of cross section
  	start_lat       = Lat_o
  	end_lat         = Lat_f(j)
  	start_lon       = Lon_o
  	end_lon         = Lon_f(j)

  	;plotting
  	opt             = True
  	opt@latlon      = True
  	opt@linecoords  = True
  	opt@file_handle = a
  	ws_latlon       = wrf_user_vert_cross(TK,z,(/start_lon,start_lat,end_lon,end_lat/),opt)
  	wks = gsn_open_wks("png","HR_"+Loop(i))
  	res                      = True
  	res@gsnMaximize          = True     ; maximize plot in frame
  	res@cnFillOn             = True     ; turn on contour fill
  	;res@ContourParameters = (/ 220., 320., 5./)
  	res@cnLinesOn            = False    ; turn off contour lines
  	res@cnLineLabelsOn       = False    ; turn off line labels
  	res@lbOrientation        = "Vertical"
  	res@lbLabelFontHeightF   = 0.01
  	res@tiMainString         = "Cross section from ("+start_lat+","+start_lon+ \
                                           ") to ("+end_lat + ","+end_lon+")"
  	res@gsnStringFontHeightF = 0.015
  	res@tmXBLabelFontHeightF = 0.01
  	res@tmXBLabelAngleF      = 45.
	;res@trYLog = True
        res@trYMinF = 1
        res@trYMaxF = 10000
;--Explicitly set lat/lon labels for X axis
  	xvalues = ispan(0,dimsizes(ws_latlon(0,:))-1,1)
  	ll_step = 15                                       ; step interval for tickmarks
  	res@tmXBMode          = "Explicit"
  	res@tmXBValues        = xvalues(::ll_step)
  	res@tmXBLabels        = sprintf("%6.2f",ws_latlon@lats(::ll_step)) + "~S~o~N~N~C~" + \
                          sprintf("%6.2f",ws_latlon@lons(::ll_step)) + "~S~o~N~E"
  	plot = gsn_csm_contour(wks,ws_latlon,res)
	end do
GIF_File = systemfunc("convert -delay 50 -loop 0 *.png CROSSSec_d0"+Domain(j)+".gif")
	delete([/res,xvalues,ws_latlon,P,Pb,P,T,TK,PH_st,PH_us,PHB_st,PHB_us,z,Listing,lats,lons/])
;        delete([/res,xvalues,ws_latlon,qv,PH_st,PH_us,PHB_st,PHB_us,z,Listing,lats,lons/])

end do
CLEAN    = systemfunc("rm *.png*")
end

