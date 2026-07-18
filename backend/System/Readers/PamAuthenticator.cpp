#include "PamAuthenticator.h"
#include <security/pam_appl.h>
#include <cstdlib>
#include <cstring>

namespace jozet {

struct PamAuthData {
    const char *password;
};

static int pam_conv_handler(int num_msg, const struct pam_message **msg, 
                            struct pam_response **resp, void *appdata_ptr) {
    if (num_msg <= 0 || num_msg > PAM_MAX_NUM_MSG) return PAM_CONV_ERR;

    PamAuthData *auth_data = static_cast<PamAuthData *>(appdata_ptr);
    *resp = static_cast<struct pam_response *>(calloc(num_msg, sizeof(struct pam_response)));

    if (!*resp) return PAM_BUF_ERR;

    for (int i = 0; i < num_msg; ++i) {
        if (msg[i]->msg_style == PAM_PROMPT_ECHO_OFF || msg[i]->msg_style == PAM_PROMPT_ECHO_ON) {
            (*resp)[i].resp = strdup(auth_data->password);
        }
    }
    return PAM_SUCCESS;
}

PamAuthenticator::PamAuthenticator(QObject *parent) : QObject(parent) {}

bool PamAuthenticator::authenticate(const QString &username, const QString &password) {
    QByteArray userBytes = username.toUtf8();
    QByteArray passBytes = password.toUtf8();

    PamAuthData auth_data;
    auth_data.password = passBytes.constData();

    struct pam_conv conv = {
        pam_conv_handler,
        &auth_data
    };

    pam_handle_t *pamh = nullptr;
    int retval;

    retval = pam_start("login", userBytes.constData(), &conv, &pamh);

    if (retval == PAM_SUCCESS) {
        retval = pam_authenticate(pamh, 0);
    }

    if (retval == PAM_SUCCESS) {
        retval = pam_acct_mgmt(pamh, 0);
    }

    pam_end(pamh, retval);

    return retval == PAM_SUCCESS;
}

}