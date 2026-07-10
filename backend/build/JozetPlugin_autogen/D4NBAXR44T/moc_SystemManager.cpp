/****************************************************************************
** Meta object code from reading C++ file 'SystemManager.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.11.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../System/SystemManager.h"
#include <QtNetwork/QSslError>
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'SystemManager.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 69
#error "This file was generated using the moc from 6.11.1. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
QT_WARNING_DISABLE_GCC("-Wuseless-cast")
namespace {
struct qt_meta_tag_ZN5jozet13SystemManagerE_t {};
} // unnamed namespace

template <> constexpr inline auto jozet::SystemManager::qt_create_metaobjectdata<qt_meta_tag_ZN5jozet13SystemManagerE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "jozet::SystemManager",
        "QML.Element",
        "auto",
        "QML.AddedInVersion",
        "65280",
        "ramUsageChanged",
        "",
        "cpuUsageChanged",
        "diskUsageChanged",
        "cpuTempChanged",
        "weatherChanged",
        "networkChanged",
        "bluetoothChanged",
        "volumeChanged",
        "update",
        "fetchWeather",
        "handleNetworkReply",
        "QNetworkReply*",
        "reply",
        "playbackDeviceInfo",
        "QVariantMap",
        "inputDeviceInfo",
        "playingApplications",
        "QVariantList",
        "availableNetworks",
        "scanNetworks",
        "connectToNetwork",
        "ssid",
        "password",
        "scanBluetooth",
        "start",
        "connectBluetooth",
        "address",
        "disconnectBluetooth",
        "forgetBluetooth",
        "setPlaybackVolume",
        "volume",
        "setInputVolume",
        "setPlaybackMuted",
        "muted",
        "setInputMuted",
        "setApplicationVolume",
        "uint32_t",
        "pid",
        "setDefaultPlaybackDevice",
        "index",
        "setDefaultInputDevice",
        "ramUsage",
        "cpuUsage",
        "diskUsage",
        "cpuTemp",
        "weather",
        "ethernetInfo",
        "wifiInfo",
        "availableBluetoothDevices",
        "isVolumeReady"
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'ramUsageChanged'
        QtMocHelpers::SignalData<void()>(5, 6, QMC::AccessPublic, QMetaType::Void),
        // Signal 'cpuUsageChanged'
        QtMocHelpers::SignalData<void()>(7, 6, QMC::AccessPublic, QMetaType::Void),
        // Signal 'diskUsageChanged'
        QtMocHelpers::SignalData<void()>(8, 6, QMC::AccessPublic, QMetaType::Void),
        // Signal 'cpuTempChanged'
        QtMocHelpers::SignalData<void()>(9, 6, QMC::AccessPublic, QMetaType::Void),
        // Signal 'weatherChanged'
        QtMocHelpers::SignalData<void()>(10, 6, QMC::AccessPublic, QMetaType::Void),
        // Signal 'networkChanged'
        QtMocHelpers::SignalData<void()>(11, 6, QMC::AccessPublic, QMetaType::Void),
        // Signal 'bluetoothChanged'
        QtMocHelpers::SignalData<void()>(12, 6, QMC::AccessPublic, QMetaType::Void),
        // Signal 'volumeChanged'
        QtMocHelpers::SignalData<void()>(13, 6, QMC::AccessPublic, QMetaType::Void),
        // Slot 'update'
        QtMocHelpers::SlotData<void()>(14, 6, QMC::AccessPrivate, QMetaType::Void),
        // Slot 'fetchWeather'
        QtMocHelpers::SlotData<void()>(15, 6, QMC::AccessPrivate, QMetaType::Void),
        // Slot 'handleNetworkReply'
        QtMocHelpers::SlotData<void(QNetworkReply *)>(16, 6, QMC::AccessPrivate, QMetaType::Void, {{
            { 0x80000000 | 17, 18 },
        }}),
        // Method 'playbackDeviceInfo'
        QtMocHelpers::MethodData<QVariantMap() const>(19, 6, QMC::AccessPublic, 0x80000000 | 20),
        // Method 'inputDeviceInfo'
        QtMocHelpers::MethodData<QVariantMap() const>(21, 6, QMC::AccessPublic, 0x80000000 | 20),
        // Method 'playingApplications'
        QtMocHelpers::MethodData<QVariantList() const>(22, 6, QMC::AccessPublic, 0x80000000 | 23),
        // Method 'availableNetworks'
        QtMocHelpers::MethodData<QVariantList() const>(24, 6, QMC::AccessPublic, 0x80000000 | 23),
        // Method 'scanNetworks'
        QtMocHelpers::MethodData<void()>(25, 6, QMC::AccessPublic, QMetaType::Void),
        // Method 'connectToNetwork'
        QtMocHelpers::MethodData<void(const QString &, const QString &)>(26, 6, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 27 }, { QMetaType::QString, 28 },
        }}),
        // Method 'scanBluetooth'
        QtMocHelpers::MethodData<void(bool)>(29, 6, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Bool, 30 },
        }}),
        // Method 'connectBluetooth'
        QtMocHelpers::MethodData<void(const QString &)>(31, 6, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 32 },
        }}),
        // Method 'disconnectBluetooth'
        QtMocHelpers::MethodData<void(const QString &)>(33, 6, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 32 },
        }}),
        // Method 'forgetBluetooth'
        QtMocHelpers::MethodData<void(const QString &)>(34, 6, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 32 },
        }}),
        // Method 'setPlaybackVolume'
        QtMocHelpers::MethodData<void(int)>(35, 6, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Int, 36 },
        }}),
        // Method 'setInputVolume'
        QtMocHelpers::MethodData<void(int)>(37, 6, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Int, 36 },
        }}),
        // Method 'setPlaybackMuted'
        QtMocHelpers::MethodData<void(bool)>(38, 6, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Bool, 39 },
        }}),
        // Method 'setInputMuted'
        QtMocHelpers::MethodData<void(bool)>(40, 6, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Bool, 39 },
        }}),
        // Method 'setApplicationVolume'
        QtMocHelpers::MethodData<void(uint32_t, int)>(41, 6, QMC::AccessPublic, QMetaType::Void, {{
            { 0x80000000 | 42, 43 }, { QMetaType::Int, 36 },
        }}),
        // Method 'setDefaultPlaybackDevice'
        QtMocHelpers::MethodData<void(uint32_t)>(44, 6, QMC::AccessPublic, QMetaType::Void, {{
            { 0x80000000 | 42, 45 },
        }}),
        // Method 'setDefaultInputDevice'
        QtMocHelpers::MethodData<void(uint32_t)>(46, 6, QMC::AccessPublic, QMetaType::Void, {{
            { 0x80000000 | 42, 45 },
        }}),
    };
    QtMocHelpers::UintData qt_properties {
        // property 'ramUsage'
        QtMocHelpers::PropertyData<int>(47, QMetaType::Int, QMC::DefaultPropertyFlags, 0),
        // property 'cpuUsage'
        QtMocHelpers::PropertyData<int>(48, QMetaType::Int, QMC::DefaultPropertyFlags, 1),
        // property 'diskUsage'
        QtMocHelpers::PropertyData<double>(49, QMetaType::Double, QMC::DefaultPropertyFlags, 2),
        // property 'cpuTemp'
        QtMocHelpers::PropertyData<int>(50, QMetaType::Int, QMC::DefaultPropertyFlags, 3),
        // property 'weather'
        QtMocHelpers::PropertyData<QString>(51, QMetaType::QString, QMC::DefaultPropertyFlags, 4),
        // property 'availableNetworks'
        QtMocHelpers::PropertyData<QVariantList>(24, 0x80000000 | 23, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 5),
        // property 'ethernetInfo'
        QtMocHelpers::PropertyData<QVariantMap>(52, 0x80000000 | 20, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 5),
        // property 'wifiInfo'
        QtMocHelpers::PropertyData<QVariantMap>(53, 0x80000000 | 20, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 5),
        // property 'availableBluetoothDevices'
        QtMocHelpers::PropertyData<QVariantList>(54, 0x80000000 | 23, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 6),
        // property 'playbackDeviceInfo'
        QtMocHelpers::PropertyData<QVariantMap>(19, 0x80000000 | 20, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 7),
        // property 'inputDeviceInfo'
        QtMocHelpers::PropertyData<QVariantMap>(21, 0x80000000 | 20, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 7),
        // property 'playingApplications'
        QtMocHelpers::PropertyData<QVariantList>(22, 0x80000000 | 23, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 7),
        // property 'isVolumeReady'
        QtMocHelpers::PropertyData<bool>(55, QMetaType::Bool, QMC::DefaultPropertyFlags, 7),
    };
    QtMocHelpers::UintData qt_enums {
    };
    QtMocHelpers::UintData qt_constructors {};
    QtMocHelpers::ClassInfos qt_classinfo({
            {    1,    2 },
            {    3,    4 },
    });
    return QtMocHelpers::metaObjectData<SystemManager, void>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums, qt_constructors, qt_classinfo);
}
Q_CONSTINIT const QMetaObject jozet::SystemManager::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN5jozet13SystemManagerE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN5jozet13SystemManagerE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN5jozet13SystemManagerE_t>.metaTypes,
    nullptr
} };

void jozet::SystemManager::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<SystemManager *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->ramUsageChanged(); break;
        case 1: _t->cpuUsageChanged(); break;
        case 2: _t->diskUsageChanged(); break;
        case 3: _t->cpuTempChanged(); break;
        case 4: _t->weatherChanged(); break;
        case 5: _t->networkChanged(); break;
        case 6: _t->bluetoothChanged(); break;
        case 7: _t->volumeChanged(); break;
        case 8: _t->update(); break;
        case 9: _t->fetchWeather(); break;
        case 10: _t->handleNetworkReply((*reinterpret_cast<std::add_pointer_t<QNetworkReply*>>(_a[1]))); break;
        case 11: { QVariantMap _r = _t->playbackDeviceInfo();
            if (_a[0]) *reinterpret_cast<QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 12: { QVariantMap _r = _t->inputDeviceInfo();
            if (_a[0]) *reinterpret_cast<QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 13: { QVariantList _r = _t->playingApplications();
            if (_a[0]) *reinterpret_cast<QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 14: { QVariantList _r = _t->availableNetworks();
            if (_a[0]) *reinterpret_cast<QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 15: _t->scanNetworks(); break;
        case 16: _t->connectToNetwork((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2]))); break;
        case 17: _t->scanBluetooth((*reinterpret_cast<std::add_pointer_t<bool>>(_a[1]))); break;
        case 18: _t->connectBluetooth((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 19: _t->disconnectBluetooth((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 20: _t->forgetBluetooth((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 21: _t->setPlaybackVolume((*reinterpret_cast<std::add_pointer_t<int>>(_a[1]))); break;
        case 22: _t->setInputVolume((*reinterpret_cast<std::add_pointer_t<int>>(_a[1]))); break;
        case 23: _t->setPlaybackMuted((*reinterpret_cast<std::add_pointer_t<bool>>(_a[1]))); break;
        case 24: _t->setInputMuted((*reinterpret_cast<std::add_pointer_t<bool>>(_a[1]))); break;
        case 25: _t->setApplicationVolume((*reinterpret_cast<std::add_pointer_t<uint32_t>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<int>>(_a[2]))); break;
        case 26: _t->setDefaultPlaybackDevice((*reinterpret_cast<std::add_pointer_t<uint32_t>>(_a[1]))); break;
        case 27: _t->setDefaultInputDevice((*reinterpret_cast<std::add_pointer_t<uint32_t>>(_a[1]))); break;
        default: ;
        }
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        switch (_id) {
        default: *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType(); break;
        case 10:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType(); break;
            case 0:
                *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType::fromType< QNetworkReply* >(); break;
            }
            break;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        if (QtMocHelpers::indexOfMethod<void (SystemManager::*)()>(_a, &SystemManager::ramUsageChanged, 0))
            return;
        if (QtMocHelpers::indexOfMethod<void (SystemManager::*)()>(_a, &SystemManager::cpuUsageChanged, 1))
            return;
        if (QtMocHelpers::indexOfMethod<void (SystemManager::*)()>(_a, &SystemManager::diskUsageChanged, 2))
            return;
        if (QtMocHelpers::indexOfMethod<void (SystemManager::*)()>(_a, &SystemManager::cpuTempChanged, 3))
            return;
        if (QtMocHelpers::indexOfMethod<void (SystemManager::*)()>(_a, &SystemManager::weatherChanged, 4))
            return;
        if (QtMocHelpers::indexOfMethod<void (SystemManager::*)()>(_a, &SystemManager::networkChanged, 5))
            return;
        if (QtMocHelpers::indexOfMethod<void (SystemManager::*)()>(_a, &SystemManager::bluetoothChanged, 6))
            return;
        if (QtMocHelpers::indexOfMethod<void (SystemManager::*)()>(_a, &SystemManager::volumeChanged, 7))
            return;
    }
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast<int*>(_v) = _t->ramUsage(); break;
        case 1: *reinterpret_cast<int*>(_v) = _t->cpuUsage(); break;
        case 2: *reinterpret_cast<double*>(_v) = _t->diskUsage(); break;
        case 3: *reinterpret_cast<int*>(_v) = _t->cpuTemp(); break;
        case 4: *reinterpret_cast<QString*>(_v) = _t->weather(); break;
        case 5: *reinterpret_cast<QVariantList*>(_v) = _t->availableNetworks(); break;
        case 6: *reinterpret_cast<QVariantMap*>(_v) = _t->ethernetInfo(); break;
        case 7: *reinterpret_cast<QVariantMap*>(_v) = _t->wifiInfo(); break;
        case 8: *reinterpret_cast<QVariantList*>(_v) = _t->availableBluetoothDevices(); break;
        case 9: *reinterpret_cast<QVariantMap*>(_v) = _t->playbackDeviceInfo(); break;
        case 10: *reinterpret_cast<QVariantMap*>(_v) = _t->inputDeviceInfo(); break;
        case 11: *reinterpret_cast<QVariantList*>(_v) = _t->playingApplications(); break;
        case 12: *reinterpret_cast<bool*>(_v) = _t->isVolumeReady(); break;
        default: break;
        }
    }
}

const QMetaObject *jozet::SystemManager::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *jozet::SystemManager::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN5jozet13SystemManagerE_t>.strings))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int jozet::SystemManager::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 28)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 28;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 28)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 28;
    }
    if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 13;
    }
    return _id;
}

// SIGNAL 0
void jozet::SystemManager::ramUsageChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void jozet::SystemManager::cpuUsageChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void jozet::SystemManager::diskUsageChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void jozet::SystemManager::cpuTempChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 3, nullptr);
}

// SIGNAL 4
void jozet::SystemManager::weatherChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 4, nullptr);
}

// SIGNAL 5
void jozet::SystemManager::networkChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 5, nullptr);
}

// SIGNAL 6
void jozet::SystemManager::bluetoothChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 6, nullptr);
}

// SIGNAL 7
void jozet::SystemManager::volumeChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 7, nullptr);
}
QT_WARNING_POP
