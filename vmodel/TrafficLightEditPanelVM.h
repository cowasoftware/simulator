#pragma once

#include "common/qmlutil.h"
#include <QObject>
#include <QDebug>
#include <vector>
#include <QAbstractListModel>

class TrafficLightModel;

class SignalFlowList : public QAbstractListModel
{
Q_OBJECT
public:
    enum Role{
        Color,
        Time,
    };
    struct Data
    {
        qint32 color;
        qint32 time;
    };
public:
    SignalFlowList(QObject *parent = nullptr);

public:
    virtual Qt::ItemFlags flags(const QModelIndex &index) const override;
    virtual int rowCount(const QModelIndex &parent) const override;
    virtual QHash<int, QByteArray> roleNames() const override;
    virtual QVariant data(const QModelIndex &index, int role) const override;
    virtual bool setData(const QModelIndex &index, const QVariant &value, int role) override;
    Data const& get(size_t index);
    void set(std::vector<Data> const &data);
    void set(std::vector<Data> &&data);
    void insert(size_t index, Data const &item);
    void push_back(Data const &item);
    void emplace_back(Data &&item);
    void append(std::vector<Data> const &data);
    void replace(size_t index, Data const& item);
    void remove(size_t index, size_t count);
    void move(size_t from, size_t to);
    void clear();

public:
    Q_INVOKABLE void addItem(qint32 color, qint32 time);
    Q_INVOKABLE void removeItem(qint32 index);
    Q_INVOKABLE void moveItem(qint32 from, qint32 to);
public:
    std::vector<Data> _data;
    QHash<int, QByteArray> _roles;
};

class TrafficLightEditPanelVM : public QObject
{
    Q_OBJECT
    READ_PROPERTY(QString, title,"")
    PROPERTY(qint32, trigger, 0)
    PROPERTY(QString, herocarPos, "")
    PROPERTY(bool, visible, false)
    PROPERTY(bool, isCrosswalk, false)
    PROPERTY(QVariant,forwordSignalFlowList,QVariant())
    PROPERTY(QVariant,leftSignalFlowList,QVariant())
    PROPERTY(QVariant,rightSignalFlowList,QVariant())
    PROPERTY(QVariant,uturnSignalFlowList,QVariant())
public:
    TrafficLightEditPanelVM(QObject *parent = nullptr);

public:
    Q_INVOKABLE void selectSignalObject(QObject* obj);

private:
    SignalFlowList* _forwordSignalFlowListModel = nullptr;
    SignalFlowList* _leftSignalFlowListModel = nullptr;
    SignalFlowList* _rightSignalFlowListModel = nullptr;
    SignalFlowList* _uturnSignalFlowListModel = nullptr;
    TrafficLightModel* _lightModel = nullptr;
};
