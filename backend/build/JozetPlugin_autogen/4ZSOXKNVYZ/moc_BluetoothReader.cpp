/****************************************************************************
** Meta object code from reading C++ file 'BluetoothReader.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.11.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../System/Readers/BluetoothReader.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'BluetoothReader.h' doesn't include <QObject>."
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
struct qt_meta_tag_ZN5jozet15BluetoothReaderE_t {};
} // unnamed namespace

template <> constexpr inline auto jozet::BluetoothReader::qt_create_metaobjectdata<qt_meta_tag_ZN5jozet15BluetoothReaderE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "jozet::BluetoothReader",
        "devicesChanged",
        "",
        "handleBluetoothOutput",
        "onConnectTimeout",
        "setPower",
        "on",
        "scan",
        "start",
        "connectDevice",
        "address",
        "disconnectDevice",
        "forgetDevice",
        "updateDevices",
        "availableDevices",
        "QVariantList"
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'devicesChanged'
        QtMocHelpers::SignalData<void()>(1, 2, QMC::AccessPublic, QMetaType::Void),
        // Slot 'handleBluetoothOutput'
        QtMocHelpers::SlotData<void()>(3, 2, QMC::AccessPrivate, QMetaType::Void),
        // Slot 'onConnectTimeout'
        QtMocHelpers::SlotData<void()>(4, 2, QMC::AccessPrivate, QMetaType::Void),
        // Method 'setPower'
        QtMocHelpers::MethodData<void(bool)>(5, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Bool, 6 },
        }}),
        // Method 'scan'
        QtMocHelpers::MethodData<void(bool)>(7, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Bool, 8 },
        }}),
        // Method 'connectDevice'
        QtMocHelpers::MethodData<void(const QString &)>(9, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 10 },
        }}),
        // Method 'disconnectDevice'
        QtMocHelpers::MethodData<void(const QString &)>(11, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 10 },
        }}),
        // Method 'forgetDevice'
        QtMocHelpers::MethodData<void(const QString &)>(12, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 10 },
        }}),
        // Method 'updateDevices'
        QtMocHelpers::MethodData<void()>(13, 2, QMC::AccessPublic, QMetaType::Void),
    };
    QtMocHelpers::UintData qt_properties {
        // property 'availableDevices'
        QtMocHelpers::PropertyData<QVariantList>(14, 0x80000000 | 15, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 0),
    };
    QtMocHelpers::UintData qt_enums {
    };
    return QtMocHelpers::metaObjectData<BluetoothReader, qt_meta_tag_ZN5jozet15BluetoothReaderE_t>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject jozet::BluetoothReader::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN5jozet15BluetoothReaderE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN5jozet15BluetoothReaderE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN5jozet15BluetoothReaderE_t>.metaTypes,
    nullptr
} };

void jozet::BluetoothReader::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<BluetoothReader *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->devicesChanged(); break;
        case 1: _t->handleBluetoothOutput(); break;
        case 2: _t->onConnectTimeout(); break;
        case 3: _t->setPower((*reinterpret_cast<std::add_pointer_t<bool>>(_a[1]))); break;
        case 4: _t->scan((*reinterpret_cast<std::add_pointer_t<bool>>(_a[1]))); break;
        case 5: _t->connectDevice((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 6: _t->disconnectDevice((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 7: _t->forgetDevice((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 8: _t->updateDevices(); break;
        default: ;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        if (QtMocHelpers::indexOfMethod<void (BluetoothReader::*)()>(_a, &BluetoothReader::devicesChanged, 0))
            return;
    }
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast<QVariantList*>(_v) = _t->availableDevices(); break;
        default: break;
        }
    }
}

const QMetaObject *jozet::BluetoothReader::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *jozet::BluetoothReader::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN5jozet15BluetoothReaderE_t>.strings))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int jozet::BluetoothReader::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 9)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 9;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 9)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 9;
    }
    if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 1;
    }
    return _id;
}

// SIGNAL 0
void jozet::BluetoothReader::devicesChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}
QT_WARNING_POP
