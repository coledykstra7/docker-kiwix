#!/bin/sh
# Shared script to start kiwix-serve

# KIWIX_ARCHIVE_CACHE_SIZE: Number of open readers (~ZIM), default: 421 (10% of getBookCount_not_protected)
# export KIWIX_ARCHIVE_CACHE_SIZE=421
# KIWIX_SEARCHER_CACHE_SIZE: Number of open searchers, default: 421 (idem KIWIX_ARCHIVE_CACHE_SIZE)
# export KIWIX_SEARCHER_CACHE_SIZE=421
# ZIM_DIRENTCACHE: Number of dirent kept in cache per ZIM, default: 512 (low impact on memory)
# export ZIM_DIRENTCACHE=512
# ZIM_DIRENTLOOKUPCACHE: Idem ZIM_DIRENTCACHE, default: 1024 (low impact on memory)
# export ZIM_DIRENTLOOKUPCACHE=1024
# ZIM_CLUSTERCACHE: Number of cluster kept in cache per ZIM, default: 16
# export ZIM_CLUSTERCACHE=16

# Usage:
#        kiwix-serve [OPTIONS] ZIM_PATH+
#        kiwix-serve --library [OPTIONS] LIBRARY_PATH
# 
# Purpose:
#        Deliver ZIM file(s) articles via HTTP
# 
# Mandatory arguments:
#        LIBRARY_PATH            XML library file path listing ZIM file to serve. To be used only with the --library argument.
#        ZIM_PATH                ZIM file path(s)
# 
# Optional arguments:
# 
#        -h, --help              Print this help
# 
#        -a, --attachToProcess   Exit if given process id is not running anymore
#        -d, --daemon            Detach the HTTP server daemon from the main process
#        -i, --address           Listen only on this ip address, all available ones otherwise
#        -M, --monitorLibrary    Monitor the XML library file and reload it automatically
#        -m, --nolibrarybutton   Don't print the builtin home button in the builtin top bar overlay
#        -n, --nosearchbar       Don't print the builtin bar overlay on the top of each served page
#        -b, --blockexternal     Prevent users from directly accessing external links
#        -p, --port              TCP port on which to listen to HTTP requests (default: 80)
#        -r, --urlRootLocation   URL prefix on which the content should be made available (default: /)
#        -s, --searchLimit       Maximun number of zim in a fulltext multizim search (default: No limit)
#        -t, --threads           Number of threads to run in parallel (default: 4)
#        -v, --verbose           Print debug log to STDOUT
#        -V, --version           Print software version
#        -z, --nodatealiases     Create URL aliases for each content by removing the date
#        -c, --customIndex       Add path to custom index.html for welcome page
#        -L, --ipConnectionLimit Max number of (concurrent) connections per IP (default: infinite, recommended: >= 6)
#        -k, --skipInvalid       Startup even when ZIM files are invalid (those will be skipped)
# 
# Documentation:
#        Source code             https://github.com/kiwix/kiwix-tools
#        More info               https://wiki.kiwix.org/wiki/Kiwix-serve


exec kiwix-serve $@ --library "$LIBRARY_PATH"
