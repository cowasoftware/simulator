#include "TrafficLightEditPanelVM.h"
#include "../control/ui_simulator_control.h"
#include <QDebug>
#include <sstream>


// UNKNOWN = 0, RED = 1, YELLOW =2 , GREEN = 3, BLACK = 4, WAIT = 5
static int index_to_color(int index) {
    return index;
}

static int color_to_index(int color) {
    return color;
}

SignalFlowList::SignalFlowList(QObject* parent) : QAbstractListModel(parent) {}

QHash<int, QByteArray> SignalFlowList::roleNames() const
{
  return QHash<int, QByteArray>{
      {(int)Role::Color, QByteArray("color")},
      {(int)Role::Time, QByteArray("time")},
  };
}
Qt::ItemFlags SignalFlowList::flags(const QModelIndex& index) const
{
  Qt::ItemFlags flags = QAbstractItemModel::flags(index);
  flags |= Qt::ItemIsEditable;
  return flags;
}

int SignalFlowList::rowCount(const QModelIndex& parent) const
{
  Q_UNUSED(parent);
  return _data.size();
}

bool SignalFlowList::setData(const QModelIndex& index, const QVariant& value, int role)
{
  if (index.isValid()) {
    auto& item = _data[index.row()];
    switch (role) {
    case Role::Color:
      item.color = index_to_color(value.toInt());
      Q_EMIT dataChanged(index, index, QVector<int>() << Role::Color);
      break;
    case Role::Time:
      item.time = value.toInt();
      Q_EMIT dataChanged(index, index, QVector<int>() << Role::Time);
      break;
    }
    return true;
  }
  return false;
}

QVariant SignalFlowList::data(const QModelIndex& index, int role) const
{
  if (index.row() >= 0 && index.row() < (int)_data.size()) {
    switch (role) {
    case Role::Color: return color_to_index(_data[index.row()].color);
    case Role::Time: return _data[index.row()].time;
    }
  }
  return {};
}

SignalFlowList::Data const& SignalFlowList::get(size_t index)
{
  return _data[index];
}

void SignalFlowList::set(std::vector<Data> const& data)
{
  beginResetModel();
  _data = data;
  endResetModel();
}

void SignalFlowList::set(std::vector<Data>&& data)
{
  beginResetModel();
  _data = std::move(data);
  endResetModel();
}

void SignalFlowList::insert(size_t index, Data const& data)
{
  beginInsertRows(QModelIndex(), index, index);
  _data.insert(_data.begin() + index, data);
  endInsertRows();
}

void SignalFlowList::push_back(Data const& item)
{
  beginInsertRows(QModelIndex(), _data.size(), _data.size());
  _data.push_back(item);
  endInsertRows();
}
void SignalFlowList::emplace_back(Data&& item)
{
  beginInsertRows(QModelIndex(), _data.size(), _data.size());
  _data.emplace_back(std::move(item));
  endInsertRows();
}
void SignalFlowList::append(std::vector<Data> const& data)
{
  if (!data.empty()) {
    beginInsertRows(QModelIndex(), _data.size(), _data.size() + data.size() - 1);
    _data.insert(_data.end(), data.begin(), data.end());
    endInsertRows();
  }
}

void SignalFlowList::replace(size_t inx, Data const& item)
{
  _data[inx] = item;
  Q_EMIT dataChanged(index(inx), index(inx), QVector<int>() << Role::Color << Role::Time);
}

void SignalFlowList::remove(size_t index, size_t count)
{
  size_t min_count = (index + count) < _data.size() ? count : (_data.size() - index);

  beginRemoveRows(QModelIndex(), index, index + min_count - 1);
  _data.erase(_data.begin() + index, _data.begin() + index + min_count);
  endRemoveRows();
}

void SignalFlowList::move(size_t from, size_t to)
{
  beginMoveRows(QModelIndex(), from, from, QModelIndex(), from > to ? (to) : (to + 1));
  std::swap(_data[from], _data[to]);
  endMoveRows();
}

void SignalFlowList::clear()
{
  if (!_data.empty()) {
    beginRemoveRows(QModelIndex(), 0, _data.size() - 1);
    _data.clear();
    endRemoveRows();
  }
}

void SignalFlowList::addItem(qint32 color, qint32 time)
{
  int color_index = color_to_index(color);
  push_back(Data{color_index, time});
}

void SignalFlowList::removeItem(qint32 index)
{
  remove(index, 1);
}

void SignalFlowList::moveItem(qint32 from, qint32 to)
{
  move(from, to);
}

TrafficLightEditPanelVM::TrafficLightEditPanelVM(QObject* parent) : QObject(parent)
{
  _forwordSignalFlowListModel = new SignalFlowList(this);
  _leftSignalFlowListModel = new SignalFlowList(this);
  _rightSignalFlowListModel = new SignalFlowList(this);
  _uturnSignalFlowListModel = new SignalFlowList(this);

  set_forwordSignalFlowList(QVariant::fromValue(_forwordSignalFlowListModel));
  set_leftSignalFlowList(QVariant::fromValue(_leftSignalFlowListModel));
  set_rightSignalFlowList(QVariant::fromValue(_rightSignalFlowListModel));
  set_uturnSignalFlowList(QVariant::fromValue(_uturnSignalFlowListModel));

  auto insertCall = [](SignalFlowList* listModel, TrafficLightModel* model, int type, int start) {
    if (model) {
      auto iter = std::find_if(model->sublights.begin(), model->sublights.end(),
                               [type](SubLight* sublight) { return sublight->type == type; });

      if (iter == model->sublights.end()) {
        auto sublight = new SubLight();
        sublight->type = type;
        model->sublights.append(sublight);
        iter = model->sublights.end() - 1;
      }

      if (iter != model->sublights.end()) {
        auto sublight = *iter;
        auto const& item = listModel->get(start);
        sublight->states.push_back(item.color);
        sublight->intervals.push_back(item.time);
      }
    }
  };

  auto removeCall = [](TrafficLightModel* model, int type, int start) {
    if (model) {
      auto iter = std::find_if(model->sublights.begin(), model->sublights.end(),
                               [type](SubLight* sublight) { return sublight->type == type; });

      if (iter != model->sublights.end()) {
        auto sublight = *iter;
        sublight->states.removeAt(start);
        sublight->intervals.removeAt(start);
      }
    }
  };

  auto dataSetCall = [](SignalFlowList* listModel, TrafficLightModel* model, int type, int start,
                        const QVector<int>& roles) {
    if (model) {
      auto iter = std::find_if(model->sublights.begin(), model->sublights.end(),
                               [type](SubLight* sublight) { return sublight->type == type; });
      if (iter != model->sublights.end()) {
        auto sublight = *iter;
        for (auto role : roles) {
          switch (role) {
          case SignalFlowList::Role::Color:
            if (start < sublight->states.length()) sublight->states[start] = listModel->get(start).color;
            break;
          case SignalFlowList::Role::Time:
            if (start < sublight->intervals.length()) sublight->intervals[start] = listModel->get(start).time;
            break;
          default: break;
          }
        }
      }
    }
  };

  connect(this, &TrafficLightEditPanelVM::triggerChanged, [this]() {
    auto trigger_by_herocar = get_trigger();
    _lightModel->trigger = trigger_by_herocar == 1 ? true : false;
    auto str = get_herocarPos().toStdString();
    std::vector<std::string> vecInfo = Util::Split(str, ",");
    if (vecInfo.size() == 2) {
      _lightModel->hero_car_x = (atof(vecInfo[0].c_str()) * 100)/100;
      _lightModel->hero_car_y = (atof(vecInfo[1].c_str()) * 100)/100;
    }
  });

  connect(this, &TrafficLightEditPanelVM::herocarPosChanged, [this]() {
    auto trigger_by_herocar = get_trigger();
    _lightModel->trigger = trigger_by_herocar == 1 ? true : false;
    auto str = get_herocarPos().toStdString();
    std::vector<std::string> vecInfo = Util::Split(str, ",");
    if (vecInfo.size() == 2) {
      _lightModel->hero_car_x = (atof(vecInfo[0].c_str()) * 100)/100;
      _lightModel->hero_car_y = (atof(vecInfo[1].c_str()) * 100)/100;
    }
  });

  connect(_forwordSignalFlowListModel, &SignalFlowList::rowsInserted, this,
          [insertCall, this](const QModelIndex& parent, int start, int end) {
            insertCall(_forwordSignalFlowListModel, _lightModel, TrafficLightModel::FORWARD, start);
          });

  connect(_forwordSignalFlowListModel, &SignalFlowList::rowsRemoved, this,
          [removeCall, this](const QModelIndex& parent, int start, int end) {
            removeCall(_lightModel, TrafficLightModel::FORWARD, start);
          });

  connect(_forwordSignalFlowListModel, &SignalFlowList::dataChanged, this,
          [dataSetCall, this](const QModelIndex& topLeft, const QModelIndex& bottomRight,
                              const QVector<int>& roles = QVector<int>()) {
            dataSetCall(_forwordSignalFlowListModel, _lightModel, TrafficLightModel::FORWARD, topLeft.row(), roles);
          });

  connect(_leftSignalFlowListModel, &SignalFlowList::rowsInserted, this,
          [insertCall, this](const QModelIndex& parent, int start, int end) {
            insertCall(_leftSignalFlowListModel, _lightModel, TrafficLightModel::LEFT, start);
          });

  connect(_leftSignalFlowListModel, &SignalFlowList::rowsRemoved, this,
          [removeCall, this](const QModelIndex& parent, int start, int end) {
            removeCall(_lightModel, TrafficLightModel::LEFT, start);
          });

  connect(_leftSignalFlowListModel, &SignalFlowList::dataChanged, this,
          [dataSetCall, this](const QModelIndex& topLeft, const QModelIndex& bottomRight,
                              const QVector<int>& roles = QVector<int>()) {
            dataSetCall(_leftSignalFlowListModel, _lightModel, TrafficLightModel::LEFT, topLeft.row(), roles);
          });

  connect(_rightSignalFlowListModel, &SignalFlowList::rowsInserted, this,
          [insertCall, this](const QModelIndex& parent, int start, int end) {
            insertCall(_rightSignalFlowListModel, _lightModel, TrafficLightModel::RIGHT, start);
          });

  connect(_rightSignalFlowListModel, &SignalFlowList::rowsRemoved, this,
          [removeCall, this](const QModelIndex& parent, int start, int end) {
            removeCall(_lightModel, TrafficLightModel::RIGHT, start);
          });

  connect(_rightSignalFlowListModel, &SignalFlowList::dataChanged, this,
          [dataSetCall, this](const QModelIndex& topLeft, const QModelIndex& bottomRight,
                              const QVector<int>& roles = QVector<int>()) {
            dataSetCall(_rightSignalFlowListModel, _lightModel, TrafficLightModel::RIGHT, topLeft.row(), roles);
          });

  connect(_uturnSignalFlowListModel, &SignalFlowList::rowsInserted, this,
          [insertCall, this](const QModelIndex& parent, int start, int end) {
            insertCall(_uturnSignalFlowListModel, _lightModel, TrafficLightModel::UTURN, start);
          });

  connect(_uturnSignalFlowListModel, &SignalFlowList::rowsRemoved, this,
          [removeCall, this](const QModelIndex& parent, int start, int end) {
            removeCall(_lightModel, TrafficLightModel::UTURN, start);
          });

  connect(_uturnSignalFlowListModel, &SignalFlowList::dataChanged, this,
          [dataSetCall, this](const QModelIndex& topLeft, const QModelIndex& bottomRight,
                              const QVector<int>& roles = QVector<int>()) {
            dataSetCall(_uturnSignalFlowListModel, _lightModel, TrafficLightModel::UTURN, topLeft.row(), roles);
          });
}

void TrafficLightEditPanelVM::selectSignalObject(QObject* object)
{
  // if (static_cast<TrafficLightModel*>(object) != _lightModel) {
  // }
  auto forwordSignalFLowData = std::vector<SignalFlowList::Data>{};
  auto leftSignalFLowData = std::vector<SignalFlowList::Data>{};
  auto rightSignalFLowData = std::vector<SignalFlowList::Data>{};
  auto uturnSignalFLowData = std::vector<SignalFlowList::Data>{};

  // 更新lightModel
  _lightModel = static_cast<TrafficLightModel*>(object);

  if (_lightModel) {
    // qDebug() << "selectSignalObject: " << _lightModel->getId() << Qt::endl;
    set_title(QString("%1-%2").arg("红绿灯", _lightModel->getId()));
    set_trigger(_lightModel->trigger ? 1: 0);
    std::ostringstream buffer;
    
    buffer<< std::to_string(_lightModel->hero_car_x) <<","<<std::to_string(_lightModel->hero_car_y);
    set_herocarPos(QString::fromStdString(buffer.str()));

    set_isCrosswalk(_lightModel->is_crosswalk);

    for (auto& sublight : _lightModel->sublights) {
      switch (sublight->type) {
      case TrafficLightModel::Type::FORWARD:
        // qDebug() << "FORWARD:";
        for (auto i = 0; i < sublight->states.length(); i++) {
          // qDebug() << sublight->states[i]<< ","<< sublight->intervals[i]<< Qt::endl;
          forwordSignalFLowData.push_back(SignalFlowList::Data{sublight->states[i], sublight->intervals[i]});
        }
        break;
      case TrafficLightModel::Type::LEFT:
        // qDebug() << "LEFT:";
        for (auto i = 0; i < sublight->states.length(); i++) {
          // qDebug() << sublight->states[i]<< ","<< sublight->intervals[i] << Qt::endl;
          leftSignalFLowData.push_back(SignalFlowList::Data{sublight->states[i], sublight->intervals[i]});
        }
        break;
      case TrafficLightModel::Type::RIGHT:
        for (auto i = 0; i < sublight->states.length(); i++) {
          rightSignalFLowData.push_back(SignalFlowList::Data{sublight->states[i], sublight->intervals[i]});
        }

        break;
      case TrafficLightModel::Type::UTURN:
        for (auto i = 0; i < sublight->states.length(); i++) {
          uturnSignalFLowData.push_back(SignalFlowList::Data{sublight->states[i], sublight->intervals[i]});
        }
        break;
      default: break;
      }
    }
  }
  else {
    set_title(QString(""));
    set_trigger(0);
  }
  _forwordSignalFlowListModel->set(forwordSignalFLowData);
  _leftSignalFlowListModel->set(leftSignalFLowData);
  _rightSignalFlowListModel->set(rightSignalFLowData);
  _uturnSignalFlowListModel->set(uturnSignalFLowData);
}
