/****************************************************************************
** Generated QML type registration code
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <QtQml/qqml.h>
#include <QtQml/qqmlmoduleregistration.h>

#if __has_include(<SystemManager.h>)
#  include <SystemManager.h>
#endif


#if !defined(QT_STATIC)
#define Q_QMLTYPE_EXPORT Q_DECL_EXPORT
#else
#define Q_QMLTYPE_EXPORT
#endif
Q_QMLTYPE_EXPORT void qml_register_types_Jozet_System()
{
    QT_WARNING_PUSH QT_WARNING_DISABLE_DEPRECATED
    qmlRegisterTypesAndRevisions<jozet::SystemManager>("Jozet.System", 1);
    QT_WARNING_POP
    qmlRegisterModule("Jozet.System", 1, 0);
}

static const QQmlModuleRegistration jozetSystemRegistration("Jozet.System", qml_register_types_Jozet_System);
