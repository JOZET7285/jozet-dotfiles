/****************************************************************************
** Meta object code from reading C++ file 'VolumeReader.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.11.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../System/Readers/VolumeReader.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'VolumeReader.h' doesn't include <QObject>."
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
struct qt_meta_tag_ZN5jozet12VolumeReaderE_t {};
} // unnamed namespace

template <> constexpr inline auto jozet::VolumeReader::qt_create_metaobjectdata<qt_meta_tag_ZN5jozet12VolumeReaderE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "jozet::VolumeReader",
        "dataUpdated",
        "",
        "playingApplications",
        "QVariantList",
        "setPlaybackVolume",
        "volume",
        "setInputVolume",
        "setApplicationVolume",
        "uint32_t",
        "pid",
        "setPlaybackMuted",
        "muted",
        "setInputMuted",
        "setDefaultPlaybackDevice",
        "index",
        "setDefaultInputDevice",
        "setApplicationMuted"
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'dataUpdated'
        QtMocHelpers::SignalData<void()>(1, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'playingApplications'
        QtMocHelpers::MethodData<QVariantList() const>(3, 2, QMC::AccessPublic, 0x80000000 | 4),
        // Method 'setPlaybackVolume'
        QtMocHelpers::MethodData<void(int)>(5, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Int, 6 },
        }}),
        // Method 'setInputVolume'
        QtMocHelpers::MethodData<void(int)>(7, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Int, 6 },
        }}),
        // Method 'setApplicationVolume'
        QtMocHelpers::MethodData<void(uint32_t, int)>(8, 2, QMC::AccessPublic, QMetaType::Void, {{
            { 0x80000000 | 9, 10 }, { QMetaType::Int, 6 },
        }}),
        // Method 'setPlaybackMuted'
        QtMocHelpers::MethodData<void(bool)>(11, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Bool, 12 },
        }}),
        // Method 'setInputMuted'
        QtMocHelpers::MethodData<void(bool)>(13, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Bool, 12 },
        }}),
        // Method 'setDefaultPlaybackDevice'
        QtMocHelpers::MethodData<void(uint32_t)>(14, 2, QMC::AccessPublic, QMetaType::Void, {{
            { 0x80000000 | 9, 15 },
        }}),
        // Method 'setDefaultInputDevice'
        QtMocHelpers::MethodData<void(uint32_t)>(16, 2, QMC::AccessPublic, QMetaType::Void, {{
            { 0x80000000 | 9, 15 },
        }}),
        // Method 'setApplicationMuted'
        QtMocHelpers::MethodData<void(uint32_t, bool)>(17, 2, QMC::AccessPublic, QMetaType::Void, {{
            { 0x80000000 | 9, 10 }, { QMetaType::Bool, 12 },
        }}),
    };
    QtMocHelpers::UintData qt_properties {
    };
    QtMocHelpers::UintData qt_enums {
    };
    return QtMocHelpers::metaObjectData<VolumeReader, qt_meta_tag_ZN5jozet12VolumeReaderE_t>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject jozet::VolumeReader::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN5jozet12VolumeReaderE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN5jozet12VolumeReaderE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN5jozet12VolumeReaderE_t>.metaTypes,
    nullptr
} };

void jozet::VolumeReader::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<VolumeReader *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->dataUpdated(); break;
        case 1: { QVariantList _r = _t->playingApplications();
            if (_a[0]) *reinterpret_cast<QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 2: _t->setPlaybackVolume((*reinterpret_cast<std::add_pointer_t<int>>(_a[1]))); break;
        case 3: _t->setInputVolume((*reinterpret_cast<std::add_pointer_t<int>>(_a[1]))); break;
        case 4: _t->setApplicationVolume((*reinterpret_cast<std::add_pointer_t<uint32_t>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<int>>(_a[2]))); break;
        case 5: _t->setPlaybackMuted((*reinterpret_cast<std::add_pointer_t<bool>>(_a[1]))); break;
        case 6: _t->setInputMuted((*reinterpret_cast<std::add_pointer_t<bool>>(_a[1]))); break;
        case 7: _t->setDefaultPlaybackDevice((*reinterpret_cast<std::add_pointer_t<uint32_t>>(_a[1]))); break;
        case 8: _t->setDefaultInputDevice((*reinterpret_cast<std::add_pointer_t<uint32_t>>(_a[1]))); break;
        case 9: _t->setApplicationMuted((*reinterpret_cast<std::add_pointer_t<uint32_t>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<bool>>(_a[2]))); break;
        default: ;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        if (QtMocHelpers::indexOfMethod<void (VolumeReader::*)()>(_a, &VolumeReader::dataUpdated, 0))
            return;
    }
}

const QMetaObject *jozet::VolumeReader::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *jozet::VolumeReader::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN5jozet12VolumeReaderE_t>.strings))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int jozet::VolumeReader::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
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
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 10;
    }
    return _id;
}

// SIGNAL 0
void jozet::VolumeReader::dataUpdated()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}
QT_WARNING_POP
