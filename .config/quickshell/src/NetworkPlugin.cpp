#include <QQmlExtensionPlugin>
#include <qqml.h>
#include "NetworkManager.h"

class NetworkPlugin : public QQmlExtensionPlugin {
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface/1.0")

public:
    void registerTypes(const char *uri) override {
        // Esto registra tu clase para que puedas hacer "import com.tuusuario.network 1.0"
        qmlRegisterType<NetworkManager>(uri, 1, 0, "NetworkManager");
    }
};