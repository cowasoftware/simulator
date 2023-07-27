#include "map_list_model.h"

#include "client/logger.h"

enum { MapListModelRole = Qt::UserRole + 1 };

int MapListModel::rowCount(const QModelIndex& parent) const
{
  return map_items_.size();
}

QVariant MapListModel::data(const QModelIndex& index, int role) const
{
  if (index.row() >= 0 && index.row() < (int)map_items_.size()) {
    if (role == MapListModelRole) {
      MapItem* object = map_items_.at(index.row());
      return QVariant::fromValue(object);
    }
  }
  return QVariant(0);
}

QHash<int, QByteArray> MapListModel::roleNames() const
{
  return rolesNames_;
}

MapListModel::MapListModel(QObject* parent) : QAbstractListModel(parent)
{
  rolesNames_[MapListModelRole] = "MapListModelRole";
}

MapListModel::~MapListModel() {}

void MapListModel::flush(std::shared_ptr<QList<QString>> map_list)
{
  QListIterator<QString> iter(*map_list.get());
  map_items_.clear();
  while (iter.hasNext()) {
    MapItem* item = new MapItem(this);

    item->setTitle(iter.next());
    map_items_.emplace_back(item);
    ready_ = true;
  }
  SINFO << "MapListModel flush";
}
