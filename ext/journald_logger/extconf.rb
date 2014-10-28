require 'mkmf'

LIBDIR      = RbConfig::CONFIG['libdir']
INCLUDEDIR  = RbConfig::CONFIG['includedir']

HEADER_DIRS = [INCLUDEDIR]

LIB_DIRS = [LIBDIR]

dir_config('systemd', HEADER_DIRS, LIB_DIRS)

# check headers
abort 'systemd/sd-journal.h is missing. please install systemd-journal' unless find_header('systemd/sd-journal.h')

# check functions
%w(sd_journal_print sd_journal_sendv sd_journal_perror).each do |func|
   abort "#{func}() is missing. systemd-journal is not usable" unless find_library('systemd-journal', func)
end

create_makefile('journald_logger/journald_logger')
