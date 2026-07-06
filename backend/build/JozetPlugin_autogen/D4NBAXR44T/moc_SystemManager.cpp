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
        "cpuTempChanged",
        "diskUsageChanged",
        "uptimeChanged",
        "weatherChanged",
        "update",
        "readCpuTemperature",
        "fetchWeather",
        "handleNetworkReply",
        "QNetworkReply*",
        "reply",
        "ramUsage",
        "cpuUsage",
        "cpuTemp",
        "diskUsage",
        "weather",
        "uptime"
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'ramUsageChanged'
        QtMocHelpers::SignalData<void()>(5, 6, QMC::AccessPublic, QMetaType::Void),
        // Signal 'cpuUsageChanged'
        QtMocHelpers::SignalData<void()>(7, 6, QMC::AccessPublic, QMetaType::Void),
        // Signal 'cpuTempChanged'
        QtMocHelpers::SignalData<void()>(8, 6, QMC::AccessPublic, QMetaType::Void),
        // Signal 'diskUsageChanged'
        QtMocHelpers::SignalData<void()>(9, 6, QMC::AccessPublic, QMetaType::Void),
        // Signal 'uptimeChanged'
        QtMocHelpers::SignalData<void()>(10, 6, QMC::AccessPublic, QMetaType::Void),
        // Signal 'weatherChanged'
        QtMocHelpers::SignalData<void()>(11, 6, QMC::AccessPublic, QMetaType::Void),
        // Slot 'update'
        QtMocHelpers::SlotData<void()>(12, 6, QMC::AccessPrivate, QMetaType::Void),
        // Slot 'readCpuTemperature'
        QtMocHelpers::SlotData<int()>(13, 6, QMC::AccessPrivate, QMetaType::Int),
        // Slot 'fetchWeather'
        QtMocHelpers::SlotData<void()>(14, 6, QMC::AccessPrivate, QMetaType::Void),
        // Slot 'handleNetworkReply'
        QtMocHelpers::SlotData<void(QNetworkReply *)>(15, 6, QMC::AccessPrivate, QMetaType::Void, {{
            { 0x80000000 | 16, 17 },
        }}),
    };
    QtMocHelpers::UintData qt_properties {
        // property 'ramUsage'
        QtMocHelpers::PropertyData<int>(18, QMetaType::Int, QMC::DefaultPropertyFlags, 0),
        // property 'cpuUsage'
        QtMocHelpers::PropertyData<int>(19, QMetaType::Int, QMC::DefaultPropertyFlags, 1),
        // property 'cpuTemp'
        QtMocHelpers::PropertyData<int>(20, QMetaType::Int, QMC::DefaultPropertyFlags, 2),
        // property 'diskUsage'
        QtMocHelpers::PropertyData<double>(21, QMetaType::Double, QMC::DefaultPropertyFlags, 3),
        // property 'weather'
        QtMocHelpers::PropertyData<QString>(22, QMetaType::QString, QMC::DefaultPropertyFlags, 5),
        // property 'uptime'
        QtMocHelpers::PropertyData<QString>(23, QMetaType::QString, QMC::DefaultPropertyFlags, 4),
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
        case 2: _t->cpuTempChanged(); break;
        case 3: _t->diskUsageChanged(); break;
        case 4: _t->uptimeChanged(); break;
        case 5: _t->weatherChanged(); break;
        case 6: _t->update(); break;
        case 7: { int _r = _t->readCpuTemperature();
            if (_a[0]) *reinterpret_cast<int*>(_a[0]) = std::move(_r); }  break;
        case 8: _t->fetchWeather(); break;
        case 9: _t->handleNetworkReply((*reinterpret_cast<std::add_pointer_t<QNetworkReply*>>(_a[1]))); break;
        default: ;
        }
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        switch (_id) {
        default: *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType(); break;
        case 9:
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
        if (QtMocHelpers::indexOfMethod<void (SystemManager::*)()>(_a, &SystemManager::cpuTempChanged, 2))
            return;
        if (QtMocHelpers::indexOfMethod<void (SystemManager::*)()>(_a, &SystemManager::diskUsageChanged, 3))
            return;
        if (QtMocHelpers::indexOfMethod<void (SystemManager::*)()>(_a, &SystemManager::uptimeChanged, 4))
            return;
        if (QtMocHelpers::indexOfMethod<void (SystemManager::*)()>(_a, &SystemManager::weatherChanged, 5))
            return;
    }
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast<int*>(_v) = _t->ramUsage(); break;
        case 1: *reinterpret_cast<int*>(_v) = _t->cpuUsage(); break;
        case 2: *reinterpret_cast<int*>(_v) = _t->cpuTemp(); break;
        case 3: *reinterpret_cast<double*>(_v) = _t->diskUsage(); break;
        case 4: *reinterpret_cast<QString*>(_v) = _t->weather(); break;
        case 5: *reinterpret_cast<QString*>(_v) = _t->uptime(); break;
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
        if (_id < 10)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 10;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 10)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 10;
    }
    if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 6;
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
void jozet::SystemManager::cpuTempChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void jozet::SystemManager::diskUsageChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 3, nullptr);
}

// SIGNAL 4
void jozet::SystemManager::uptimeChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 4, nullptr);
}

// SIGNAL 5
void jozet::SystemManager::weatherChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 5, nullptr);
}
QT_WARNING_POP
