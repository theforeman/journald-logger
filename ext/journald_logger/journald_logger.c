/* Do not add C line and file to the log messages */
#define SD_JOURNAL_SUPPRESS_LOCATION

#include <ruby.h>
#include <systemd/sd-journal.h>

void Init_journald_logger();

/* initializers */
void jdl_init_modules();
void jdl_init_constants();
void jdl_init_methods();

/* methods */
VALUE jdl_native_print(VALUE v_self, VALUE priority, VALUE message);
//VALUE jdl_native_send();
VALUE jdl_native_perror(VALUE v_self, VALUE message);

VALUE mJournald;
VALUE mNative;

void Init_journald_logger()
{
    jdl_init_modules();
    jdl_init_constants();
    jdl_init_methods();
}

void jdl_init_modules()
{
    mJournald = rb_define_module("Journald");
    mNative   = rb_define_module_under(mJournald, "Native");
}

void jdl_init_constants()
{
    rb_define_const(mJournald, "LOG_EMERG",   INT2NUM(LOG_EMERG));    /* system is unusable */
    rb_define_const(mJournald, "LOG_ALERT",   INT2NUM(LOG_ALERT));    /* action must be taken immediately */
    rb_define_const(mJournald, "LOG_CRIT",    INT2NUM(LOG_CRIT));     /* critical conditions */
    rb_define_const(mJournald, "LOG_ERR",     INT2NUM(LOG_ERR));      /* error conditions */
    rb_define_const(mJournald, "LOG_WARNING", INT2NUM(LOG_WARNING));  /* warning conditions */
    rb_define_const(mJournald, "LOG_NOTICE",  INT2NUM(LOG_NOTICE));   /* normal but significant condition */
    rb_define_const(mJournald, "LOG_INFO",    INT2NUM(LOG_INFO));     /* informational */
    rb_define_const(mJournald, "LOG_DEBUG",   INT2NUM(LOG_DEBUG));    /* debug-level messages */
}

void jdl_init_methods()
{
    rb_define_singleton_method(mNative, "print",  jdl_native_print, 2);
    //rb_define_singleton_method(mNative, "send", jdl_native_send, );
    rb_define_singleton_method(mNative, "perror", jdl_native_perror, 1);
}

VALUE jdl_native_print(VALUE v_self, VALUE v_priority, VALUE v_message)
{
    int priority, result;
    char *message;

    priority = NUM2INT(v_priority);
    message  = RSTRING_PTR(v_message);

    result = sd_journal_print(priority, "%s", message);

    return INT2NUM(result);
}

VALUE jdl_native_perror(VALUE v_self, VALUE v_message)
{
    int result;
    char *message;

    message = RSTRING_PTR(v_message);

    result = sd_journal_perror(message);

    return INT2NUM(result);
}
