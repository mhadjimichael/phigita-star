# 
# Server parameters 
# 
ns_section ns/server/${server_static} 
ns_param enabletclpages     0
ns_param MaxBusyThreads     100
ns_param MaxWait            20


ns_param maxconnections    100 ;# GN:number of connections to be served by a connection thread before it restarts, the "maxconnections" setting can be tricky, since making it too large can cause your system to thrash. 
ns_param maxthreads        10
ns_param minthreads        5
ns_param connsperthread    ${connsperthread}
ns_param lowwatermark      10
ns_param highwatermark     100
#ns_param maxdropped        0
ns_param threadtimeout     120       ;# Idle threads die at this rate (used to be set to 1800)




#
# Connection Thread Pools
#
ns_section "ns/server/${server_static}/pools"
ns_param js  "js pool"
ns_param css "css pool"
ns_param img "img pool"
ns_param cover "book cover pool"
#ns_param graphics "graphics pool"

ns_section "ns/server/${server_static}/pool/js"
ns_param   minthreads 3
ns_param   maxthreads 10
ns_param   map "GET /js"
ns_param   map "POST /js"
ns_param   map "HEAD /js"
ns_param   x-expires    "90d"

ns_section "ns/server/${server_static}/pool/css"
ns_param   minthreads 3
ns_param   maxthreads 10
ns_param   map "GET /css"
ns_param   map "POST /css"
ns_param   map "HEAD /css"
#ns_param add_header test-img-header
#ns_param expires 30d

ns_section "ns/server/${server_static}/pool/img"
ns_param   minthreads 3
ns_param   maxthreads 10
ns_param   map "GET /img"
ns_param   map "POST /img"
ns_param   map "HEAD /img"
ns_param   x-add-header [list [list Cache-Control "public"]]
ns_param   x-expires    "max"

ns_section "ns/server/${server_static}/pool/cover"
ns_param   minthreads 3
ns_param   maxthreads 10
ns_param   map "GET /cover"
ns_param   map "POST /cover"
ns_param   map "HEAD /cover"
ns_param   x-root /web/data/books/
ns_param   x-add-header [list [list Cache-Control "public"]]
ns_param   x-expires    "max"

ns_section "ns/server/${server_static}/pool/graphics"
ns_param   minthreads 3
ns_param   maxthreads 10
ns_param   map "GET /graphics"
ns_param   map "POST /graphics"
ns_param   map "HEAD /graphics"
ns_param   x-root /web/servers/service-phigita/www/graphics/
ns_param   x-add-header [list [list Cache-Control "public"]]
ns_param   x-expires    "max"





# 
# Tcl Configuration 
# 
ns_section ns/server/${server_static}/tcl
ns_param library            ${serverroot}/vhost-static/tcl
ns_param autoclose 	      on 
ns_param debug 		      false
ns_param nsvbuckets           16
ns_param lazyloader           false ;# true for lazy loader
ns_param memoizecache         100000 ;# default is 10MB


#ns_section ns/server/${server_static}/vhost
#ns_param enabled 1
#ns_param stripwww 1
#ns_param stripport 1
#ns_param hostprefix "/web/data/build/"  ;# {hostprefix}/{fastpath.pagedir}
#ns_param hosthashlevel "0" ;# 0-5



#ns_section "ns/server/${server_static}/fastpath"
##ns_param        serverdir      ""       ;# default: ""
#ns_param        pagedir        "/web/data/build/resources"       ;# default: "pages"
##ns_param        cache          true     ;# default: false
##ns_param        cachemaxsize   10240000  ;# default: 1024*10000
##ns_param        cachemaxentry  8192      ;# default: 8192
#ns_param        mmap             true     ;# default: false
#ns_param        directoryfile    ""       ;# index.adp index.tcl index.html index.htm
#ns_param        directorylisting "false"     ;# default: simple => _ns_dirlist for directoryproc
#ns_param        directoryproc    ""          ;# if directorylisting=simple, default is _ns_dirlist
#ns_param        directoryadp     ""





#---------------------------------------------------------------------
# 
# Access log -- nslog 
# 
#---------------------------------------------------------------------
ns_section ns/server/${server_static}/module/nslog 
    #
    # General parameters
    #
    ns_param   file         ${webroot}/log/access.${server_static}.log

    #ns_param   maxbuffer       100 ;# 0, number of logfile entries to keep in memory before flushing to disk
    #
    # Control what to log
    #
    #ns_param   suppressquery   true    ;# false, suppress query portion in log entry
    #ns_param   logreqtime      true    ;# false, include time to service the request
    ns_param    logpartialtimes true    ;# false, include high-res start time and partial request durations (accept, queue, filter, run)
    #ns_param   formattedtime   true    ;# true, timestamps formatted or in secs (unix time)
    #ns_param   logcombined     true    ;# true, Log in NSCA Combined Log Format (referer, user-agent)
    ns_param   extendedheaders "COOKIE Host Referer X-Forwarded-For"  ;# space delimited list of HTTP heads to log per entry
    ns_param   checkforproxy   true    ;# false, check for proxy header (X-Forwarded-For)
    #
    #
    # Control log file rolling
    #
    #ns_param   maxbackup       100 ;# 10, max number of backup log files
    #ns_param   rolllog     true    ;# true, should server log files automatically
    #ns_param   rollhour        0   ;# 0, specify at which hour to roll
    #ns_param   rollonsignal    true    ;# false, perform roll on a sighup
    ns_param   rollfmt      %Y-%m-%d-%H:%M  ;# format appendend to log file name

# rolls the server log on the same basis as the access log 
# {server}/tcl/logroll.tcl depends on rollday, rollhour, rollfmt being set
ns_param rollday            *
ns_param rollhour           0



#
# SSL
#

ns_section    "ns/server/${server_static}/module/nsssl"
       # cat host.cert host.key > server.pem
       ns_param      certificate	/web/data/ssl/phigita.net.pem ;# $serverroot/etc/next-scripting.org.pem
ns_param      address    	"192.168.10.1";# $address
       ns_param      port       	$httpsport
       #ns_param      ciphers    	"ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP"
       #ns_param      ciphers    	"ECDHE-RSA-RC4-SHA:RC4+SHA1+RSA"
       ns_param      ciphers            "RC4:HIGH:!aNULL:!MD5;"
       ns_param      protocols          "!SSLv2"
       ns_param      verify     	0
       ns_param      writerthreads      5 
       ns_param      writersize         10
       ns_param	     writerbufsize	16384	;# 8192, buffer size for writer threads
       ns_param	     writerstreaming	false	;# false
       ns_param      deferaccept	true    ;# false, Performance optimization,


ns_section ns/server/${server_static}/modules 
ns_param nslog          ${bindir}/nslog.so 
ns_param nslog          ${bindir}/nsssl.so 


