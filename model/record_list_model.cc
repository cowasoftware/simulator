#include "record_list_model.h"

#include "client/logger.h"

RecordListModel::RecordListModel(QObject* parent) : QObject(parent) {}

RecordListModel::~RecordListModel() {}

void RecordListModel::clear() {}

void RecordListModel::flush(std::shared_ptr<QList<QString>> record_list)
{
  QListIterator<QString> iter(*record_list.get());
  while (iter.hasNext()) {
    RecordItem* item = new RecordItem(this);
    item->setTitle(iter.next());
    record_items_.push_back(item);
    ready_ = true;
  }
  SINFO << "RecordListModel flush";
}
